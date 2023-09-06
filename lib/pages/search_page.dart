import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tulpar_chat_app/helper/helper_functions.dart';
import 'package:tulpar_chat_app/pages/chat_page.dart';
import 'package:tulpar_chat_app/service/database_service.dart';
import 'package:tulpar_chat_app/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(children: [
        Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                cursorColor: Theme.of(context).secondaryHeaderColor,
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Search groups...",
                    hintStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.5), width: 2))),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                initiateSearchMethod();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(40)),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              )
            : groupList(),
      ]),
    );
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          hasUserSearched = true;
          _isLoading = false;
        });
      });
    }
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      ),
      subtitle: Text(
        "Admin : ${getName(admin)}",
        style: const TextStyle(color: Colors.white),
      ),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });

            // ignore: use_build_context_synchronously
            showSnackbar(
                context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
            });

            // ignore: unnecessary_brace_in_string_interps, use_build_context_synchronously
            showSnackbar(context, Colors.red, "You left the group $groupName");
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).primaryColor,
                    border: Border.all(color: Colors.white, width: 1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Join",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
