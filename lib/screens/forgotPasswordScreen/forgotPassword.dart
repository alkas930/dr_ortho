import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/screens/authentication.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true;

  void PassVisiblity() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  bool validateAndSave() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {                                                                                                                                                                             
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SearchComponent(),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
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
                                  // controller: passwordInputController,
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
                                      borderSide:
                                          BorderSide(color: themeRed, width: 2),
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                        gapPadding: 0),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obsecureText,

                                  validator: (value) => value!.length < 8 ||
                                          value.length > 16
                                      ? 'Password should be 8-16 characters.'
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8),
                                child: TextFormField(
                                  maxLines: 1,
                                  // controller: passwordInputController,
                                  decoration: const InputDecoration(
                                    hintText: 'Confirm password',
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
                                  textInputAction: TextInputAction.done,
                                  obscureText: true,
                                  validator: (value) => value!.length < 8 ||
                                          value.length > 16
                                      ? 'Password should be 8-16 characters.'
                                      : null,
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
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AuthenticationScreen()),
                            (route) => false);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 20,
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                            color: bottomBarColor,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
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
    );
  }
}
