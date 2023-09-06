import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tulpar_chat_app/pages/group_info.dart';
import 'package:tulpar_chat_app/service/database_service.dart';
import 'package:tulpar_chat_app/widgets/message_tile.dart';
import 'package:tulpar_chat_app/widgets/widgets.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool messageImagePickedMenu = false;
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 20),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.groupName,
              style: const TextStyle(fontSize: 25),
              overflow: TextOverflow.fade,
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 30,
              ))
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          messageImagePickedMenu
              ? Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      alignment: Alignment.bottomCenter,
                      width: MediaQuery.of(context).size.width,
                      child: const Text('an image picked'),
                    ),
                    ImagelessTextField(context),
                  ],
                )
              : ImagelessTextField(context)
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container ImagelessTextField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(45)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                cursorColor: Theme.of(context).secondaryHeaderColor,
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            GestureDetector(
              onTap: () async {
                String messageImageUrl = await pickAnImageAndGetUrl();
                if (messageImageUrl != '') {
                  setState(() {
                    messageImagePickedMenu = true;
                  });
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.image_search, color: Colors.white)),
            ),
            GestureDetector(
              onTap: () async {
                sendMessage();
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> pickAnImageAndGetUrl() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('chatImages');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      await referenceImageToUpload.putFile(File(file.path));
      return await referenceImageToUpload.getDownloadURL();
    } else {
      return '';
    }
  }

  chatMessages() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Scroll to the latest message after building the ListView
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 1),
                curve: Curves.easeOut,
              );
            });
          }
          return snapshot.hasData
              ? ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender']);
                  },
                )
              : Container();
        },
      ),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageController.clear();
      });
    }
  }
}
