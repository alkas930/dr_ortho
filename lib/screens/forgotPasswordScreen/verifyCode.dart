// ignore_for_file: prefer_typing_uninitialized_variables, no_logic_in_create_state, use_build_context_synchronously

import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/screens/forgotPasswordScreen/forgotPassword.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

class VerifyCode extends StatefulWidget {
  final emailInputController;
  const VerifyCode({
    super.key,
    this.emailInputController,
  });

  @override
  State<VerifyCode> createState() =>
      _VerifyCodeState(email: emailInputController);
}

class _VerifyCodeState extends State<VerifyCode> {
  final email;
  _VerifyCodeState({required this.email});
  TextEditingController codeController = TextEditingController();

  bool isActive = false;

  getVerifyCode() async {
    try {
      if (kDebugMode) {
        print('------------------------- ${codeController.text} $email');
      }
      final response = await ApiClient().callPostAPI(validateCode, {
        "email": email,
        "code": codeController.text,
      });

      if (response['data']['status'] == 200) {
        setState(() {});
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ForgotPassword(
                      emailInputController: email,
                      codeController: codeController.text,
                    )),
            (route) => false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('something went wrong $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'A password reset code has been sent to your email address.',
                        style: TextStyle(
                            color: themeRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: .4),
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                maxLines: 1,
                                controller: codeController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Code',
                                  hintStyle: TextStyle(color: hintTextColor),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeRed, width: 2),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      gapPadding: 0),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 12),
                                textInputAction: TextInputAction.next,
                                // validator: (value) {
                                //   if (value!.isEmpty ||
                                //       !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                //           .hasMatch(value)) {
                                //     return 'Please enter a valid email';
                                //   }

                                //   return null;
                                // },
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () => getVerifyCode(),
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
                              'Verify Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 13, horizontal: 32),
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
      ),
    );
  }
}
