import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tulpar_chat_app/pages/auth/login_page.dart';
import 'package:tulpar_chat_app/pages/home_page.dart';
import 'package:tulpar_chat_app/service/auth_service.dart';
import 'package:tulpar_chat_app/service/database_service.dart';
import 'package:tulpar_chat_app/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  final String profilePic;
  const ProfilePage(
      {super.key,
      required this.email,
      required this.userName,
      required this.profilePic});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .updateTheProfilePhoto();
        },
        child: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      drawer: Drawer(
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
            (widget.profilePic != '')
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.profilePic, scale: 2.0),
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
                widget.userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 25),
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
              onTap: () {
                nextScreenReplace(context, const HomePage());
              },
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.group,
                color: Colors.white,
              ),
              title: Text(
                "Groups",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 20),
              ),
            ),

            //PROFILE TILE
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white.withOpacity(0.8),
                ),
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
                      content: const Text('Are you sure you want to logout?',
                          style: TextStyle(color: Colors.white, fontSize: 15)),
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
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            )),
                        TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
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
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.profilePic.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profilePic),
                radius: 100,
              )
            else
              // Display a default profile icon if profilePic is empty or null
              CircleAvatar(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                radius: 100,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 180,
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Username  ',
                  style: TextStyle(fontSize: 21, color: Colors.white),
                ),
                Text(
                  "@${widget.userName}",
                  style: const TextStyle(fontSize: 21, color: Colors.white),
                ),
              ],
            ),
            Divider(
              height: 30,
              color: Theme.of(context).secondaryHeaderColor,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email  ",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 21, color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
