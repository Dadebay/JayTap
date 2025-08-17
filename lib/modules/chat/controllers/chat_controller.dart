import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../views/chat_model.dart';

class ChatController extends GetxController {
  var students = <ChatModel>[].obs;
  var messagesMap = <int, RxList<Message>>{}.obs;
  var messageText = ''.obs;
  var selectedMessages = <String>{}.obs;
  var isSelectionMode = false.obs;

  final myUserId = 0; // senin ID'in
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadOfflineUsers();
  }

  void _loadOfflineUsers() {
    students.assignAll([
      ChatModel(id: 1, username: "Hoja Nepesow", lastMessage: "Salam, Gowymysynyz ? ", photo: "assets/images/realtor/1.webp"),
      ChatModel(id: 2, username: "Ayna Geldiýewa", lastMessage: "Goyan jayynyz satlykmy ?", photo: "assets/images/realtor/2.webp"),
      ChatModel(id: 3, username: "Meret Durdyýew", lastMessage: 'Baha Naceden ? ', photo: "assets/images/realtor/3.webp"),
      ChatModel(id: 4, username: "BagdaGul Nepesowa", lastMessage: "Aloo nomer berda agam ? ", photo: "assets/images/realtor/4.webp"),
      ChatModel(id: 5, username: "Kerim Geldiýew", lastMessage: "Design gowy bolupdyrmy ?", photo: "assets/images/realtor/5.webp"),
      ChatModel(id: 6, username: "Maral Durdyýewa", lastMessage: 'Vpn naceden agam ? ', photo: "assets/images/realtor/6.webp"),
    ]);

    for (var user in students) {
      messagesMap[user.id] = <Message>[
        Message(id: DateTime.now().millisecondsSinceEpoch.toString() + "_1", senderId: user.id, content: "Salam", dateTime: DateTime.now().subtract(Duration(minutes: 5))),
        Message(id: DateTime.now().millisecondsSinceEpoch.toString() + "_2", senderId: myUserId, content: "Salam. Näme habar?", dateTime: DateTime.now().subtract(Duration(minutes: 3))),
      ].obs;
    }
  }

  List<Message> getMessages(int userId) {
    return messagesMap[userId] ?? <Message>[];
  }

  void sendMessage(int userId) {
    if (messageText.trim().isEmpty) return;
    messagesMap[userId]?.insert(
        0,
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: myUserId,
          content: messageText.trim(),
          dateTime: DateTime.now(),
        ));
    messageText.value = '';
  }

  // Resim gönderme
  Future<void> sendImage(int userId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      messagesMap[userId]?.insert(
          0,
          Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: myUserId,
            content: "Resim",
            dateTime: DateTime.now(),
            imagePath: image.path,
            type: MessageType.image,
          ));
    }
  }

  // Mesaj seçme/seçimi kaldırma
  void toggleMessageSelection(String messageId) {
    if (selectedMessages.contains(messageId)) {
      selectedMessages.remove(messageId);
    } else {
      selectedMessages.add(messageId);
    }

    if (selectedMessages.isEmpty) {
      isSelectionMode.value = false;
    } else if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
  }

  // Seçilen mesajları silme
  void deleteSelectedMessages(int userId) {
    if (selectedMessages.isEmpty) return;

    messagesMap[userId]?.removeWhere((message) => selectedMessages.contains(message.id));
    selectedMessages.clear();
    isSelectionMode.value = false;
  }

  // Seçim modunu iptal etme
  void cancelSelection() {
    selectedMessages.clear();
    isSelectionMode.value = false;
  }

  // Mesaj uzun basma
  void onMessageLongPress(String messageId) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
      selectedMessages.add(messageId);
    }
  }
}
