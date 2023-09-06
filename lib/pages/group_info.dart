import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tulpar_chat_app/pages/home_page.dart';
import 'package:tulpar_chat_app/service/database_service.dart';
import 'package:tulpar_chat_app/widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.adminName,
  });

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    super.initState();
    getMembers();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    title: const Text(
                      'Exit the Group?',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    content: const Text(
                      'Are you sure you want to exit the group?',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )),
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor),
                          onPressed: () async {
                            DatabaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .toggleGroupJoin(widget.groupId,
                                    getName(widget.adminName), widget.groupName)
                                .whenComplete(() {
                              nextScreenReplace(context, const HomePage());
                            });
                          },
                          child: Text(
                            'Exit',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ))
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 20, right: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 35),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Admin :",
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "@${getName(widget.adminName)}",
                        overflow: TextOverflow.clip,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.2),
              thickness: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: memberList(),
            )
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data["members"] != null) {
            if (snapshot.data["members"].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data["members"].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        child: Text(
                          getName(snapshot.data["members"][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        getName(snapshot.data['members'][index]),
                        style: const TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        getId(snapshot.data['members'][index]),
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }
}
