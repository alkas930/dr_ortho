// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:drortho/utilities/loadingWrapperWithoutProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/apiconstants.dart';
import '../constants/colorconstants.dart';
import '../constants/stringconstants.dart';
import '../models/userModel.dart';
import '../providers/homeProvider.dart';
import '../utilities/databaseProvider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel user = UserModel();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController landmarkAddressController =
      TextEditingController();
  final TextEditingController cityAddressController = TextEditingController();
  final TextEditingController stateAddressController = TextEditingController();
  final TextEditingController pincodeAddressController =
      TextEditingController();
  bool isEditable = false;
  bool isLoading = false;

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        deleteUserAccount();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Account"),
      content: const Text("Do you want to delete account ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLogoutDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(color: themeRed),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        logoutUser();
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      title: const Text("Logout Account"),
      content: const Text("Do you want to logout account ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  openUpdateDialog(String header, bool isNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text("Update Contact Details"),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                              _textEditingController.clear();
                            },
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        keyboardType:
                            isNumber ? TextInputType.phone : TextInputType.text,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          labelText: header,
                          errorMaxLines: 2,
                        ),
                        validator: (value) => value!.isEmpty ||
                                !RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)
                            ? 'Please enter a valid name'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                            color: themeRed, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        if (_textEditingController.text.isNotEmpty) {
                          if (isNumber) {
                            Map data = {};
                            data["billing"] = {
                              "phone": _textEditingController.text
                            };
                            updateUserAccount(data);
                          } else {
                            Map data = {};
                            data["billing"] = {
                              "address_1": _textEditingController.text
                            };
                            updateUserAccount(data);
                          }
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                          _textEditingController.clear();
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  getUser() async {
    UserModel user = await DatabaseProvider().retrieveUserFromTable();
    setState(() {
      this.user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  updateUserAccount(
    Map data,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      UserModel user = await DatabaseProvider().retrieveUserFromTable();
      if (user.id != null) {
        final Map response = await ApiClient()
            .callPutAPI("${updateAccountEndpoint}${user.id}", data);
        Map address = {};
        address["billing"] = response["billing"];
        address["shipping"] = response["shipping"];
        user.address = jsonEncode(address);
        await DatabaseProvider().updateUserData(user, user.id);
        const snackBar = SnackBar(
          content: Text('Account updated successfully!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isEditable = false;
        });
        getUser();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  deleteUserAccount() async {
    try {
      UserModel user = await DatabaseProvider().retrieveUserFromTable();
      if (user.id != null) {
        final Map response = await ApiClient()
            .calDeleteAPI("${deleteAccountEndpoint}${user.id}", null);
        await DatabaseProvider().cleanUserTable();

        setState(() {
          user = UserModel();
        });

        const snackBar = SnackBar(
          content: Text('Account deleted successfully!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getAddress(String key) {
    try {
      //city
      //state
      //pincode
      return jsonDecode(user.address!)["billing"][key]!.toString();
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: loadingWrapperWithoutProvider(
          isLoading: isLoading,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "Hello, ${user.name ?? "Guest"}",
                  style: const TextStyle(color: bottomBarColor, fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                if (user.id != null) ...[
                  GestureDetector(
                    onTap: () {
                      homeProvider.getUserOrders();
                      Navigator.pushNamed(context, ordersRoute);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "My Orders",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  const Text(
                    "Contact Details",
                    style: TextStyle(color: bottomBarColor, fontSize: 12),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      openUpdateDialog("Mobile Number", true);
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mobile Number",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "+91 XXXXXXXXX",
                                style: TextStyle(
                                    fontSize: 10, color: hintTextColor),
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 10,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  const Text(
                    "Email Address",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.email ?? "",
                          style: const TextStyle(
                              fontSize: 10, color: hintTextColor),
                        ),
                      ),
                      // const Icon(
                      //   Icons.edit,
                      //   size: 10,
                      //   color: Colors.black,
                      // )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  GestureDetector(
                    onTap: () {
                      // openUpdateDialog("Mailing Address", false);
                      if (!isEditable) {
                        firstNameController.text = getAddress("first_name");
                        lastNameController.text = getAddress("last_name");
                        streetAddressController.text = getAddress("address_1");
                        landmarkAddressController.text =
                            getAddress("address_2");
                        cityAddressController.text = getAddress("city");
                        stateAddressController.text = getAddress("state");
                        pincodeAddressController.text = getAddress("postcode");
                      }
                      setState(() {
                        isEditable = !isEditable;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Shipping Address",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              Icons.edit,
                              size: 10,
                              color: Colors.black,
                            )
                          ],
                        ),
                        if (!isEditable) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("first_name"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("last_name"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("address_1"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("address_2"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("city"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("state"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              getAddress("postcode"),
                              style: const TextStyle(
                                  fontSize: 10, color: hintTextColor),
                            ),
                          )
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                                controller: firstNameController,
                                hintText: "First Name"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                                controller: lastNameController,
                                hintText: "Last Name"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                                controller: streetAddressController,
                                hintText: "H.no.- Street Address"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                              controller: landmarkAddressController,
                              hintText: "Landmark",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                              controller: cityAddressController,
                              hintText: "City",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                              controller: stateAddressController,
                              hintText: "State",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Input(
                              controller: pincodeAddressController,
                              hintText: "Pincode",
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showAlertDialog(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        deleteAccountText,
                        style: TextStyle(
                          color: bottomBarColor,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isEditable) ...[
                          GestureDetector(
                            onTap: () {
                              Map data = {};
                              data["billing"] = {
                                "first_name": firstNameController.text,
                                "last_name": lastNameController.text,
                                "address_1": streetAddressController.text,
                                "address_2": landmarkAddressController.text,
                                "city": cityAddressController.text,
                                "state": stateAddressController.text,
                                "postcode": pincodeAddressController.text
                              };
                              data["shipping"] = {
                                "first_name": firstNameController.text,
                                "last_name": lastNameController.text,
                                "address_1": streetAddressController.text,
                                "address_2": landmarkAddressController.text,
                                "city": cityAddressController.text,
                                "state": stateAddressController.text,
                                "postcode": pincodeAddressController.text
                              };
                              updateUserAccount(data);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: const BoxDecoration(
                                  color: bottomBarColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: const Text(
                                saveText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        GestureDetector(
                          onTap: () {
                            showLogoutDialog(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: const BoxDecoration(
                                color: themeRed,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: const Text(
                              logoutText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Image.asset(helloImage),
                  const Center(
                    child: Text(
                      pleaseLoginText,
                      style: TextStyle(color: hintTextColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, authentication);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                          color: themeRed,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: const Text(
                        loginText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  logoutUser() async {
    await DatabaseProvider().cleanUserTable();

    setState(() {
      user = UserModel();
    });

    const snackBar = SnackBar(
      content: Text('User logged out successfully!'),
      // action: SnackBarAction(
      //   label: 'Undo',
      //   onPressed: () {
      //     // Some code to undo the change.
      //   },
      // ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      // autofocus: true,
      maxLines: 1,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(232, 232, 232, 0.5),
        hintText: hintText,
        hintStyle: const TextStyle(color: strikethroughColor),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
                color: strikethroughColor, width: 1, style: BorderStyle.solid)),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
                color: strikethroughColor, width: 1, style: BorderStyle.solid)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        isDense: true, // Added this
      ),
      style: const TextStyle(fontSize: 12),
      textInputAction: TextInputAction.search,
    );
  }
}
