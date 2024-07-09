import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class demo extends StatefulWidget {
  const demo({super.key});

  @override
  State<demo> createState() => _demoState();
}

class _demoState extends State<demo> {
  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child: Scaffold(
        body: Consumer<HomeProvider>(
          builder: (__, homeprovider, _) {
            return Column(
              children: [
                TextField(),
                ElevatedButton(
                    onPressed: () {
                      homeprovider.showLoader();
                    },
                    child: Text('data'))
              ],
            );
          },
        ),
      ),
    );
  }
}
