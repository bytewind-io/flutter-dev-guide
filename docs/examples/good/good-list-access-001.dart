// ✅ Безопасный доступ к элементам списка с проверкой границ
class ConversationListItem extends StatelessWidget {
  final ConversationModel model;
  
  const ConversationListItem({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final conversationUsers = model.conversationUsers;
    final hasUsers = conversationUsers.isNotEmpty;
    
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          switch (model.type) {
            ConversationType.privateConversation => _buildPrivateAvatar(),
            ConversationType.group => hasUsers && conversationUsers.length == 1
                ? UserAvatarFromUserModelWidget(
                    size: MetricsSizes.size20,
                    user: conversationUsers[0], // ✅ Безопасно - проверили длину
                  )
                : _buildGroupAvatars(conversationUsers),
          },
        ],
      ),
    );
  }

  Widget _buildPrivateAvatar() {
    // ✅ Безопасный доступ с проверкой
    final firstUser = model.getFirstUser;
    final secondUser = model.getSecondUser;
    
    if (firstUser == null || secondUser == null) {
      return const SizedBox.shrink(); // ✅ Fallback для null значений
    }
    
    return UserAvatarFromUserModelWidget(
      size: MetricsSizes.size20,
      user: firstUser.name == model.name ? firstUser : secondUser,
    );
  }

  Widget _buildGroupAvatars(List<UserModel> users) {
    // ✅ Проверяем наличие достаточного количества элементов
    if (users.length < 2) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: MetricsSizes.size40,
      height: MetricsSizes.size40,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          UserAvatarFromUserModelWidget.fromUser(
            size: MetricsSizes.size14,
            user: users[0], // ✅ Безопасно - проверили длину
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
                user: users[1], // ✅ Безопасно - проверили длину
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Другие примеры безопасной работы со списками
class GoodListExamples {
  void safeAccess(List<String> items) {
    // ✅ Проверка перед доступом
    if (items.isNotEmpty) {
      final first = items[0]; // Безопасно
      final last = items[items.length - 1]; // Безопасно
    }
    
    // ✅ Использование безопасных методов
    final firstElement = items.elementAtOrNull(0); // Возвращает null если индекс вне границ
    final lastElement = items.elementAtOrNull(items.length - 1);
    
    // ✅ Проверка достаточного количества элементов
    if (items.length >= 2) {
      final first = items[0];
      final second = items[1];
      // работа с элементами
    }
  }
  
  void safeIteration(List<int> numbers) {
    // ✅ Итерация с проверкой границ
    for (int i = 0; i < numbers.length && i < 5; i++) {
      print(numbers[i]); // Безопасно
    }
    
    // ✅ Использование take для ограничения количества элементов
    final limitedNumbers = numbers.take(5).toList();
    for (final number in limitedNumbers) {
      print(number); // Безопасно
    }
  }
  
  void safeBatchAccess(List<UserModel> users) {
    // ✅ Проверка перед доступом к нескольким элементам
    if (users.length >= 3) {
      final first = users[0];
      final second = users[1];
      final third = users[2];
      // работа с тремя пользователями
    } else if (users.length >= 2) {
      final first = users[0];
      final second = users[1];
      // работа с двумя пользователями
    } else if (users.isNotEmpty) {
      final first = users[0];
      // работа с одним пользователем
    } else {
      // список пуст
    }
  }
}
