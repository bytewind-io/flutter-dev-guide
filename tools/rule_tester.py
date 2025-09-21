# tools/rule_tester.py
import sys, re, fnmatch, glob, yaml
from pathlib import Path

def glob_match_any(path, patterns):
    if not patterns:
        return True
    return any(fnmatch.fnmatch(path, p) for p in patterns)

def glob_match_none(path, patterns):
    return not any(fnmatch.fnmatch(path, p) for p in patterns or [])

def in_scope(rule, test_path):
    scope = rule.get('scope', {})
    include = scope.get('include_paths', ['**'])
    exclude = scope.get('exclude_paths', [])
    return glob_match_any(test_path, include) and glob_match_none(test_path, exclude)

def matches_disallowed_imports(content, disallowed, allowlist):
    hits = []
    for imp in disallowed or []:
        # ищем форму: import '...';
        pat = re.compile(rf"import\s+['\"]{re.escape(imp)}['\"]")
        if pat.search(content):
            if imp not in (allowlist or []):
                hits.append(imp)
    return hits

def matches_disallowed_calls(content, disallowed_calls):
    hits = []
    for call in disallowed_calls or []:
        if call in content:
            hits.append(call)
    return hits

def matches_patterns(content, patterns):
    hits = []
    for p in patterns or []:
        flags = 0
        if p.get('flags') and 's' in p['flags']:
            flags |= re.S
        if p.get('flags') and 'i' in p['flags']:
            flags |= re.I
        rx = re.compile(p['regex'], flags)
        if rx.search(content):
            hits.append(p['id'])
    return hits

def matches_allowlist_patterns(content, allowlist_patterns):
    """Check if content matches any allowlist pattern (should be excluded)"""
    if not allowlist_patterns:
        return False
    for pattern in allowlist_patterns:
        if re.search(pattern, content):
            return True
    return False

def path_allowlisted(test_path, allowlist_paths):
    return any(fnmatch.fnmatch(test_path, p) for p in (allowlist_paths or []))

def evaluate(rule, test):
    path = test['path']
    content = test['content']
    if not in_scope(rule, path):
        return False  # вне области — не срабатываем
    detect = rule.get('detect', {})
    if path_allowlisted(path, detect.get('allowlist_paths')):
        return False

    # Check allowlist_patterns first - if content matches any, it should be excluded
    if matches_allowlist_patterns(content, detect.get('allowlist_patterns')):
        return False

    # imports / calls / patterns
    import_hits = matches_disallowed_imports(content,
                    detect.get('disallowed_imports'), detect.get('allowlist_imports'))
    call_hits = matches_disallowed_calls(content, detect.get('disallowed_calls'))
    pattern_hits = matches_patterns(content, detect.get('patterns'))

    return bool(import_hits or call_hits or pattern_hits)

def run_file(rule_file):
    data = yaml.safe_load(Path(rule_file).read_text(encoding='utf-8'))
    tests = data.get('tests', {})
    fail = 0

    def run_cases(kind):
        nonlocal fail
        for i, case in enumerate(tests.get(kind, []), 1):
            flagged = evaluate(data, case)
            ok = (flagged if kind == 'should_flag' else not flagged)
            status = "OK" if ok else "FAIL"
            print(f"[{status}] {rule_file} {kind} #{i}: {case['path']}")
            if not ok:
                fail += 1

    run_cases('should_flag')
    run_cases('should_pass')
    return fail

def main():
    if len(sys.argv) < 2:
        print("Usage: python tools/rule_tester.py rules/*.rule.yaml")
        sys.exit(2)
    total_fail = 0
    files = []
    for arg in sys.argv[1:]:
        files.extend(glob.glob(arg))
    for f in files:
        total_fail += run_file(f)
    if total_fail:
        print(f"\nFAILED: {total_fail} test(s)")
        sys.exit(1)
    print("\nALL GREEN")

if __name__ == "__main__":
    main()