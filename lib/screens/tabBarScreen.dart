import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/screens/cartScreen.dart';
import 'package:drortho/screens/homescreen.dart';
import 'package:drortho/screens/moreScreen.dart';
import 'package:drortho/screens/profileScreen.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/imageconstants.dart';
import '../constants/sizeconstants.dart';
import '../utilities/databaseProvider.dart';

class TabBarScreen extends StatefulWidget {
  final int? param;
  const TabBarScreen({super.key, this.param});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState(param: this.param);
}

class _TabBarScreenState extends State<TabBarScreen> {
  int? param;
  _TabBarScreenState({this.param});

  int _selectedIndex = 0;
  final DatabaseProvider db = DatabaseProvider();
  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    if (param == 1) {
      _selectedIndex = 1;
      param = 0;
    }
    super.initState();
  }

  getScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ProfileScreen();
      case 2:
        return CartScreen(
          isScreen: false,
          onHomeNavigate: () {
            _onItemTapped(0);
          },
        );
      case 3:
        return const MoreScreen();
      default:
        return const HomeScreen();
    }
  }

  Tab bottomBarItem(String image, int idx) {
    return Tab(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: bottomBarIconSize,
          height: bottomBarIconSize,
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            color: idx == _selectedIndex ? bottomBarColor : hintTextColor,
          ),
        ),
      ),
    );
  }

  Tab bottomBarNotificationItem(String image, int idx) {
    return Tab(
      icon: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: bottomBarIconSize,
              height: bottomBarIconSize,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                color: idx == _selectedIndex ? bottomBarColor : hintTextColor,
              ),
            ),
          ),
          Consumer<CartProvider>(builder: (_, cartProvider, __) {
            return cartProvider.cartItems.isNotEmpty
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: bottomBarIconSize * 0.50,
                      height: bottomBarIconSize * 0.50,
                      decoration: const BoxDecoration(
                          color: themeRed,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: FittedBox(
                          child: Text(
                        cartProvider.cartItems.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      )),
                    ))
                : const SizedBox.shrink();
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SearchComponent(),
            getScreen(),
          ],
        ),
        bottomNavigationBar: DefaultTabController(
          length: 4,
          initialIndex: _selectedIndex,
          child: TabBar(
              onTap: _onItemTapped,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: bottomBarColor, width: 2),
                insets: EdgeInsets.fromLTRB(32, 0, 32, bottomBarIconSize + 16),
              ),
              tabs: [
                bottomBarItem(homeImage, 0),
                bottomBarItem(userImage, 1),
                bottomBarNotificationItem(shopImage, 2),
                bottomBarItem(moreImage, 3),
              ]),
        ),
      ),
    );
  }
}
