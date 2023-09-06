import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  String imageUrl = '';

  //references of our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection("groups");

  //saving the user data
  Future savingUserData(
    String fullName,
    String email,
  ) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  //getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get use groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //create a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupsCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

// getting the chats
  getChats(String groupId) async {
    return groupsCollection
        .doc(groupId)
        .collection('messages')
        .orderBy("time")
        .snapshots();
  }

  //get group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupsCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot["admin"];
  }

  //getting the group members
  getGroupMembers(groupId) async {
    return groupsCollection.doc(groupId).snapshots();
  }

  //search
  searchByName(String groupName) async {
    return groupsCollection.where("groupName", isEqualTo: groupName).get();
  }

  //function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    //doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReferenece = groupsCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    //if user has our groups -> then remove then or also in other part re join

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

      await groupDocumentReferenece.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });

      await groupDocumentReferenece.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupsCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupsCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString()
    });
  }

  Future<void> updateTheProfilePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('profilePhotos');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      await referenceImageToUpload.putFile(File(file.path));
      imageUrl = await referenceImageToUpload.getDownloadURL();

      userCollection.doc(uid).update({
        'profilePic': imageUrl,
      });
    } else {
      userCollection.doc(uid).update({'profilePic': ''});
    }
  }

  Future<String> getProfilePic() async {
    DocumentSnapshot doc = await userCollection.doc(uid).get();
    if (doc.exists) {
      String profilePicValue = doc.get('profilePic');
      log(profilePicValue);
      return profilePicValue;
    } else {
      log('empty string returned');
      return '';
    }
  }
}
