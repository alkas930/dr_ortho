import 'dart:math';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/screens/forgotPasswordScreen/verifyCode.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SendCode extends StatefulWidget {
  const SendCode({super.key});

  @override
  State<SendCode> createState() => _SendCodeState();
}

class _SendCodeState extends State<SendCode> {
  final emailInputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  sendEmailCode() async {
    try {
      final response = await ApiClient().callPostAPI(
          sendResetPasswordEmail, {"email": emailInputController.text});

      if (kDebugMode) {
        print(response);
      }
      if (response['status'] == 200) {
        setState(() {
          validateAndSave();
        });
      }
    } catch (e) {
      log('\x1B[31mERROR: $e\x1B[0m' as num);
    }
  }

  bool _isGmail(String email) {
    return email.endsWith('@gmail.com');
  }

  bool validateAndSave() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      sendEmailCode().toString();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerifyCode(emailInputController: emailInputController.text)));
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
                    'enter your email address',
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                maxLines: 1,
                                controller: emailInputController,
                                decoration: const InputDecoration(
                                  hintText: emailHintText,
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
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                          .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }

                                  if (!_isGmail(value)) {
                                    return 'Please enter a valid email address';
                                  }

                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => validateAndSave(),
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
                            'Send Code',
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
