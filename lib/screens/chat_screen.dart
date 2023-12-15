// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:globalink/services/chat/chat_service.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String recieverUserEmail;
//   final String recieverUserID;
//   const ChatScreen({super.key, required this.recieverUserEmail, required this.recieverUserID});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//
//   final TextEditingController _messageController = TextEditingController();
//   final ChatService _chatService = ChatService();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//
//   void sendMessage() async{
//     if(_messageController.text.isNotEmpty){
//       await _chatService.sendMessage(widget.recieverUserID, _messageController.text);
//     }
//     _messageController.clear();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.recieverUserEmail),),
//       body: Column(
//         children: [
//           Expanded(
//             child: _buildMessageList(),
//           ),
//
//
//           _buildMessageInput()
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageList(){
//     return StreamBuilder(
//         stream: _chatService.getMessages(widget.recieverUserID, _firebaseAuth.currentUser!.uid),
//         builder: (context, snapshot){
//           if(snapshot.hasError){
//             return Text('Error${snapshot.error}');
//           }
//
//           if(snapshot.connectionState == ConnectionState.waiting){
//             return const Text("Loading...");
//           }
//
//           return ListView(
//             children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
//           );
//         }
//     );
//   }
//
//
//
//   Widget _buildMessageItem(DocumentSnapshot document){
//     Map<String, dynamic> data = document.data()as Map<String, dynamic>;
//     var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;
//
//     return Container(
//       alignment: alignment,
//       child: Column(
//         children: [
//           Text(data['senderEmail']),
//           Text(data['message']),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageInput(){
//     return Row(
//       children: [
//         Expanded(
//             child: TextFormField(
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter message',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: false,
//             ),
//         ),
//         IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_forward_ios)),
//       ],
//     );
//   }
//
//
// }

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isAttachmentUploading = false;

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text('Chat'),
    ),
    body: StreamBuilder<types.Room>(
      initialData: widget.room,
      stream: FirebaseChatCore.instance.room(widget.room.id),
      builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
        initialData: const [],
        stream: FirebaseChatCore.instance.messages(snapshot.data!),
        builder: (context, snapshot) => Chat(
          isAttachmentUploading: _isAttachmentUploading,
          messages: snapshot.data ?? [],
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: types.User(
            id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
          ),
        ),
      ),
    ),
  );
}
