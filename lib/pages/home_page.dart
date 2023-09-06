import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tulpar_chat_app/helper/helper_functions.dart';
import 'package:tulpar_chat_app/pages/auth/login_page.dart';
import 'package:tulpar_chat_app/pages/profile_page.dart';
import 'package:tulpar_chat_app/pages/search_page.dart';
import 'package:tulpar_chat_app/service/auth_service.dart';
import 'package:tulpar_chat_app/service/database_service.dart';
import 'package:tulpar_chat_app/widgets/group_tile.dart';
import 'package:tulpar_chat_app/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String email = "";
  String userName = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  Future<String> getProfilePic() async {
    String profilePic =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getProfilePic();
    return profilePic;
  }

  gettingUserData() async {
    await HelperFunctions.getEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    //getting the list of snapshots
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
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
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: FutureBuilder(
        future: getProfilePic(),
        builder: (context, snapshot) {
          String profilePic = snapshot.data ?? '';
          return Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            child: ListView(
              children: <Widget>[
                (profilePic != '')
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePic),
                        radius: 90,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 150,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "@$userName",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 22),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  thickness: 1,
                ),

                //GROUPS TILE
                ListTile(
                  onTap: () {},
                  selectedColor: Theme.of(context).primaryColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "Groups",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 20),
                  ),
                ),

                //PROFILE TILE
                ListTile(
                  onTap: () {
                    nextScreenReplace(
                        context,
                        ProfilePage(
                          email: email,
                          userName: userName,
                          profilePic: profilePic,
                        ));
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Icon(
                    Icons.person,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  title: Text(
                    "Profile",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 20),
                  ),
                ),

                //LOG OUT TILE AND ALERT DIALOG
                ListTile(
                  onTap: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          content: const Text(
                              'Are you sure you want to logout?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          actions: [
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16),
                                )),
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor),
                                onPressed: () async {
                                  await authService.signOut();
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false);
                                },
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16),
                                ))
                          ],
                        );
                      },
                    );
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 20),
                  ),
                )
              ],
            ),
          );
        },
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              elevation: 0,
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white),
              ),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            groupName = value;
                          });
                        },
                        cursorColor: Theme.of(context).secondaryHeaderColor,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.add,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          hintText: "New Group Name",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                      ),
              ]),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        _isLoading = true;
                      });

                      DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName,
                              FirebaseAuth.instance.currentUser!.uid, groupName)
                          .whenComplete(() => _isLoading = false);
                      Navigator.of(context).pop();
                      showSnackbar(
                          context, Colors.green, "Group created successfully!");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text('CREATE'),
                )
              ],
            );
          },
        );
      },
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  return GroupTile(
                      userName: userName,
                      groupId: getId(snapshot.data['groups'][index]),
                      groupName: getName(snapshot.data['groups'][index]));
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
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

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 250,
          ),
          GestureDetector(
            onTap: () => noGroupWidget(),
            child: Icon(
              Icons.add_circle,
              color: Theme.of(context).secondaryHeaderColor,
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'You have not joined any groups, tap on the add icon to create a group or also search from top search button',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 20),
          )
        ],
      ),
    );
  }
}
