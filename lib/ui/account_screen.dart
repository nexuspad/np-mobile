import 'package:flutter/material.dart';
import 'package:np_mobile/ui/ui_helper.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountState();
  }
}

class AccountState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('account'),
        backgroundColor: UIHelper.blackCanvas(),
      ),
      body: Center(
        child: Text('under construction'),
      ),
    );
  }
}