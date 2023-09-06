import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tulpar_chat_app/helper/helper_functions.dart';
import 'package:tulpar_chat_app/pages/auth/login_page.dart';
import 'package:tulpar_chat_app/pages/home_page.dart';
import 'package:tulpar_chat_app/service/auth_service.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 50,
                              child: Image.asset('assets/lightning.png')),
                          Text("LightChat",
                              style: GoogleFonts.manrope(
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text("Create an account and join the party!",
                          style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      const SizedBox(height: 40),
                      SizedBox(
                          height: 150,
                          child: Image.asset('assets/chat_bubbles.png')),
                      const SizedBox(height: 40),
                      TextFormField(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                        cursorColor: Theme.of(context).secondaryHeaderColor,
                        decoration: textInputDecoration.copyWith(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          labelText: 'Username',
                        ),
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Name cannot be empty!";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).secondaryHeaderColor,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)
                              ? null
                              : "Please enter a valid email!";
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).secondaryHeaderColor,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          prefixIcon: Icon(
                            Icons.key,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value!.length < 6) {
                            return "Password must be at least 6 characters!";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35))),
                          onPressed: () {
                            register();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                            text: 'Already have an account?  ',
                            style: GoogleFonts.manrope(
                                fontSize: 16, color: Colors.white),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login now',
                                style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(
                                      context,
                                      const LoginPage(),
                                    );
                                  },
                              )
                            ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await authService
          .registerUserWithEmailandPassword(
        fullName,
        email,
        password,
      )
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUsernameSF(fullName);
          // ignore: use_build_context_synchronously
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value.toString());
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
