import 'package:apptv02/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFocusNode = FocusNode();
  final _loginFocusNode2 = FocusNode();

  @override
  void dispose() {
    _loginFocusNode.dispose();
    _loginFocusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FocusScope.of(context).requestFocus(_loginFocusNode);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/preview_main_ui_background_image.png'),
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                focusNode: _loginFocusNode,
                autofocus: true,
                onFocusChange: (value) {
                  if (value) setState(() {});
                },
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  clipBehavior: Clip.hardEdge,
                  width: _loginFocusNode.hasFocus ? 230 : 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                focusNode: _loginFocusNode2,
                onFocusChange: (value) {
                  if (value) setState(() {});
                },
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  clipBehavior: Clip.hardEdge,
                  width: _loginFocusNode2.hasFocus ? 230 : 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
