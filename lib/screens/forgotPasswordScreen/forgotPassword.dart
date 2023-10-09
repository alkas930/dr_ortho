// ignore_for_file: no_logic_in_create_state, non_constant_identifier_names, use_build_context_synchronously

import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/screens/authentication.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  final emailInputController;
  final codeController;
  const ForgotPassword(
      {super.key, this.emailInputController, this.codeController});

  @override
  State<ForgotPassword> createState() =>
      _ForgotPasswordState(code: codeController, email: emailInputController);
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final code;
  final email;
  _ForgotPasswordState({required this.code, required this.email});
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true;
  bool _obsecureText2 = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

  resetPass() async {
    if (kDebugMode) {
      print('-------------------------------------');
    }
    try {
      final response = await ApiClient().callPostAPI(setNewPassword, {
        "email": email.toString(),
        "password": passwordController.text,
        "code": code.toString(),
      });
      if (kDebugMode) {
        print(response);
      }
      if (response['data']['status'] == 200) {
        setState(() {});
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const AuthenticationScreen()),
            (route) => false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('something went wrong $e');
      }
    }
  }

  void PassVisiblity() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  void PassVisiblity2() {
    setState(() {
      _obsecureText2 = !_obsecureText2;
    });
  }

  bool validateAndSave() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
          (route) => false);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 30),
              child: Row(
                children: [
                  Text(
                    'enter new password',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: .4),
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 0),
                                  child: TextFormField(
                                    maxLines: 1,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            PassVisiblity();
                                          },
                                          icon: Icon(_obsecureText
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility)),
                                      hintText: passwordHintText,
                                      hintStyle:
                                          const TextStyle(color: hintTextColor),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: themeRed, width: 2),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          gapPadding: 0),
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                    // textInputAction: TextInputAction.done,
                                    obscureText: _obsecureText,
                                    // validator: (value) => value!.length < 8 &&
                                    //         value.length > 16
                                    //     ? 'Password should be 8-16 characters.'
                                    //     : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8),
                                  child: TextFormField(
                                    maxLines: 1,
                                    controller: passwordController2,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            PassVisiblity2();
                                          },
                                          icon: Icon(_obsecureText2
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility)),
                                      hintText: 'Confirm password',
                                      hintStyle:
                                          const TextStyle(color: hintTextColor),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: themeRed, width: 2),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          gapPadding: 0),
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                    // textInputAction: TextInputAction.done,
                                    obscureText: _obsecureText2,
                                    // validator: (value) => value!.length < 8 ||
                                    //         value.length > 16
                                    //     ? 'Password should be 8-16 characters.'
                                    //     : value != passwordController.text
                                    //         ? 'password is not matched'
                                    //         : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => {
                          resetPass(),
                          if (passwordController.text ==
                              passwordController2.text)
                            {resetPass()}
                          else
                            {null}
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                              color: bottomBarColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 32),
                        child: Text(
                          termsText,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
