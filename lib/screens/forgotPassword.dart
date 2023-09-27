// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/models/userModel.dart';
import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/apiconstants.dart';
import '../providers/homeProvider.dart';
import '../utilities/apiClient.dart';
import 'dart:developer';
import '../utilities/databaseProvider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int? _type = 1; //0 -> sign up, 1 -> sign in
  final _formKey = GlobalKey<FormState>();
  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final _client = ApiClient();
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    bool validateAndSave() {
      final FormState form = _formKey.currentState!;
      if (form.validate()) {
        return true;
      } else {
        return false;
      }
    }

    registerUser(String email, String password) async {
      try {
        homeProvider.showLoader();
        final Map response = await _client.callPostAPI(
            registerEndpoint, {"email": email, "password": password});

        if (response.isNotEmpty) {
          if (response['code'] == 200) {
            setState(() {
              _type = 1;
            });
            const snackBar = SnackBar(
              content: Text('Registration successfull, please continue login!'),
              // action: SnackBarAction(
              //   label: 'Undo',
              //   onPressed: () {
              //     // Some code to undo the change.
              //   },
              // ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            const snackBar = SnackBar(
              content: Text('User already exists'),
              // action: SnackBarAction(
              //   label: 'Undo',
              //   onPressed: () {
              //     // Some code to undo the change.
              //   },
              // ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          const snackBar = SnackBar(
            content: Text('Something went wrong, please try again'),
            // action: SnackBarAction(
            //   label: 'Undo',
            //   onPressed: () {
            //     // Some code to undo the change.
            //   },
            // ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        homeProvider.hideLoader();
      } catch (e) {
        if ((e as Map)['code'] == 406) {
          const snackBar = SnackBar(
            content: Text('User already exists'),
            // action: SnackBarAction(
            //   label: 'Undo',
            //   onPressed: () {
            //     // Some code to undo the change.
            //   },
            // ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          const snackBar = SnackBar(
            content: Text('Something went wrong, please try again'),
            // action: SnackBarAction(
            //   label: 'Undo',
            //   onPressed: () {
            //     // Some code to undo the change.
            //   },
            // ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        homeProvider.hideLoader();
        log('\x1B[31mERROR: $e\x1B[0m');
      }
    }

    loginUser(String email, String password) async {
      try {
        homeProvider.showLoader();
        final Map response = await _client.callPostAPI(
            loginEndpoint, {"username": email, "password": password});

        if (response.isNotEmpty) {
          if (response.containsKey('token')) {
            setSharedPref(false);

            await DatabaseProvider().insertUser(
              UserModel(
                  id: int.parse(response["user_id"]),
                  name: response["user_nicename"],
                  token: response["token"],
                  email: response["user_email"],
                  displayName: response["user_display_name"],
                  address: ""),
            );
            cartProvider.cleanCartItems();
            homeProvider.getUserData();
            Navigator.pushNamedAndRemoveUntil(
                context, tabsRoute, (Route<dynamic> route) => false);
          } else {
            const snackBar = SnackBar(
              content: Text('Incorrect username/password'),
              // action: SnackBarAction(
              //   label: 'Undo',
              //   onPressed: () {
              //     // Some code to undo the change.
              //   },
              // ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          const snackBar = SnackBar(
            content: Text('Incorrect username/password'),
            // action: SnackBarAction(
            //   label: 'Undo',
            //   onPressed: () {
            //     // Some code to undo the change.
            //   },
            // ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        homeProvider.hideLoader();
      } catch (e) {
        const snackBar = SnackBar(
          content: Text('Incorrect username/password'),
          // action: SnackBarAction(
          //   label: 'Undo',
          //   onPressed: () {
          //     // Some code to undo the change.
          //   },
          // ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        homeProvider.hideLoader();
        log('\x1B[31mERROR: ${e}\x1B[0m');
      }
    }

    return Scaffold(
      body: LoadingWrapper(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'forgot passwrod?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bottomBarColor,
                      fontSize: 12),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Column(
                    children: [
                      if (_type == 0)
                        ...authForm(
                            _formKey,
                            emailInputController,
                            passwordInputController,
                            validateAndSave,
                            registerUser,
                            homeProvider,
                            cartProvider),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Center(
                          child: Text(
                            'Create new password',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // RadioListTile(
                      //   // tileColor:
                      //   //     _type == 1 ? Colors.transparent : radioTileColor,
                      //   dense: true,
                      //   activeColor: radioButtonColor,
                      //   value: 1,
                      //   groupValue: _type,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _type = value;
                      //     });
                      //   },
                      //   title: RichText(
                      //     text: const TextSpan(
                      //       children: [
                      //         TextSpan(
                      //           text: 'Create new password',
                      //           style: TextStyle(
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.bold),
                      //         ),
                      //         // TextSpan(
                      //         //   text: alreadyMemberText,
                      //         //   style: TextStyle(
                      //         //     color: Colors.black,
                      //         //   ),
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      if (_type == 1)
                        ...authForm(
                            _formKey,
                            emailInputController,
                            passwordInputController,
                            validateAndSave,
                            loginUser,
                            homeProvider,
                            cartProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> authForm(
      GlobalKey formKey,
      TextEditingController emailInputController,
      TextEditingController passwordInputController,
      Function validate,
      Function continueAuthentication,
      HomeProvider homeProvider,
      CartProvider cartProvider) {
    return [
      Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                maxLines: 1,
                controller: emailInputController,
                decoration: const InputDecoration(
                  hintText: 'new password',
                  hintStyle: TextStyle(color: hintTextColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeRed, width: 2),
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
                validator: (value) => value!.length < 8 || value.length > 16
                    ? 'Password should be 8-16 characters.'
                    : null,
                // validator: (value) {
                //   if (value!.isEmpty ||
                //       !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                //           .hasMatch(value)) {
                //     return 'Please enter a valid email';
                //   }

                //   if (!_isGmail(value)) {
                //     return 'Please enter a valid email address';
                //   }

                //   return null;
                // },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: TextFormField(
                maxLines: 1,
                controller: passwordInputController,
                decoration: const InputDecoration(
                  hintText: 'confirm new password',
                  hintStyle: TextStyle(color: hintTextColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeRed, width: 2),
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
                validator: (value) => value!.length < 8 || value.length > 16
                    ? 'confirm your password'
                    : null,
              ),
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {
          if (validate()) {
            continueAuthentication(
                emailInputController.text, passwordInputController.text);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
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
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        child: Text(
          termsText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  setSharedPref(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isGuest", isGuest);
  }
}
