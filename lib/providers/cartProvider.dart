// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/dbconstants.dart';
import '../models/cartModel.dart';

import '../utilities/databaseProvider.dart';

class CartProvider extends ChangeNotifier {
  final List cartItems = [];

  CartProvider() {
    retrieveCartItems();
  }

  Future<int> insertCartItems(CartModel item) async {

    int result = 0;
    final Database db = await DatabaseProvider().initializedDB();
    // for (var item in items) {
    result = await db.insert(tableName, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // }
    retrieveCartItems();
    return result;
  }

  // insert data
  Future<int> updateCartItems(CartModel item, id) async {
    int result = 0;
    final Database db = await DatabaseProvider().initializedDB();
    // for (var item in items) {
    result = await db.update(tableName, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
        where: 'id = ?',
        whereArgs: [id]);
    // }
    retrieveCartItems();
    return result;
  }

  // retrieve data
  Future<List<CartModel>> retrieveCartItems() async {
    final Database db = await DatabaseProvider().initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query(tableName);
    final List<CartModel> cartItems =
        queryResult.map((e) => CartModel.fromMap(e)).toList();
    this.cartItems.clear();
    this.cartItems.addAll(cartItems);
    notifyListeners();
    return cartItems;
  }

  // delete cart
  Future<void> deleteCartItem(int id) async {
    final db = await DatabaseProvider().initializedDB();
    await db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    retrieveCartItems();
  }

  // clear db
  Future<void> cleanCartItems() async {
    final db = await DatabaseProvider().initializedDB();
    await db.delete(
      tableName,
    );
    retrieveCartItems();
  }
}
