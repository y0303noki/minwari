import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:uuid/uuid.dart';

import 'member_list_page.dart';

enum Answers { OK, CANCEL }

class AddMemberPage extends StatelessWidget {
//  List<Widget> listTiles = [];
  final memberNameEditingController = TextEditingController();
  final memberMemoEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateMemberModel>(
        create: (_) => AddUpdateMemberModel(),
        child: Consumer<AddUpdateMemberModel>(
            builder: (consumerContext, model, child) {
          print('itam_page Consumer');
          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MemberListPage(),
                          fullscreenDialog: false),
                    );
                  },
                ),
              ),
              actions: [],
              title: Text(
                'ホーム',
              ),
              backgroundColor: Colors.black87,
              centerTitle: true,
              elevation: 0.0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('メンバー追加'),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '名前',
                    ),
                    controller: memberNameEditingController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'メモとか'),
                    controller: memberMemoEditingController,
                  ),
                  RaisedButton(
                    child: Text('追加する'),
                    onPressed: () async {
                      model.name = memberNameEditingController.text;
                      model.memo = memberMemoEditingController.text;
                      await addMember(model, context);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

Future addMember(AddUpdateMemberModel model, BuildContext context) async {
  try {
    final String now = DateTime.now().toString();
    final Member newMember = Member(
        id: Uuid().v1(),
        tripId: '',
        name: model.name,
        memo: model.memo,
        createdAt: now,
        updatedAt: now);
    await model.addMember(newMember);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('保存しました。'),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(e.toString()),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
