// ❌ Обращение к элементам списка без проверки границ
class ConversationListItem extends StatelessWidget {
  final ConversationModel model;
  
  const ConversationListItem({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          // ❌ Обращение к элементам без проверки длины
          if (model.conversationUsers.length == 1)
            UserAvatarFromUserModelWidget(
              size: MetricsSizes.size20,
              user: model.getFirstUser,
            )
          else if (model.type == ConversationType.privateConversation)
            UserAvatarFromUserModelWidget(
              size: MetricsSizes.size20,
              user: model.getFirstUser.name == model.name 
                ? model.getFirstUser 
                : model.getSecondUser,
            )
          else
            SizedBox(
              width: MetricsSizes.size40,
              height: MetricsSizes.size40,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  // ❌ Краш при пустом списке - нет проверки
                  UserAvatarFromUserModelWidget.fromUser(
                    size: MetricsSizes.size14,
                    user: model.getSecondUser, // ❌ Может быть null
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: UserAvatarFromUserModelWidget.fromUser(
                        size: 13.25,
                        user: model.getFirstUser, // ❌ Может быть null
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ❌ Другие примеры небезопасной работы со списками
class BadListExamples {
  void unsafeAccess(List<String> items) {
    // ❌ Прямой доступ без проверки
    final first = items[0]; // Краш если список пуст
    final last = items[items.length - 1]; // Краш если список пуст
    
    // ❌ Использование first/last без проверки
    final firstElement = items.first; // Краш если список пуст
    final lastElement = items.last; // Краш если список пуст
    
    // ❌ Доступ к нескольким элементам без проверки
    if (items.length > 0) {
      final first = items[0]; // ✅ Проверили первый элемент
      final second = items[1]; // ❌ Но не проверили второй!
    }
  }
  
  void unsafeIteration(List<int> numbers) {
    // ❌ Итерация с фиксированными индексами
    for (int i = 0; i < 5; i++) {
      print(numbers[i]); // ❌ Краш если в списке меньше 5 элементов
    }
  }
}
