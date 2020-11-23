import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/member/add_member_model.dart';

class MemberListPage extends StatelessWidget {
  List<Widget> listTiles = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateMemberModel>(
        create: (_) => AddUpdateMemberModel()
          ..getMembers(-3).then((value) => listTiles = _setMembers(value)),
        child: Consumer<AddUpdateMemberModel>(
            builder: (consumerContext, model, child) {
          print('member_list_page Consumer');
          return Scaffold(
            appBar: Header(),
//        body: ChangeNotifierProvider<AddUpdateMemberModel>(
//          // 画面遷移時にメンバーを表示させる
//          create: (_) => AddUpdateMemberModel()
//            ..getMembers(-3).then((value) => listTiles = _setMembers(value)),
//          child: Consumer<AddUpdateMemberModel>(
//              builder: (consumerContext, model, child) {
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 戻るボタン
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () async {
                          Navigator.pop(context);
                        }),
                    // 更新ボタン（ダサいので変えたい）
                    IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () async {
                          final test = await model.getMembers(-3);
                          listTiles = _setMembers(test);
                        }),
                  ],
                  // メンバー管理ボタン
                ),
                Expanded(
                  child: ListView(
                    children: listTiles,
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // アイテム追加ダイアログ呼び出し
                openMemberDialog(context, model);
              },
              child: Icon(Icons.person_add),
              backgroundColor: Colors.green,
            ),
          );
        }),
      ),
    );
  }
}

void openMemberDialog(BuildContext context, AddUpdateMemberModel model) {
  String name = '';
  String memo = '';
  showDialog<Answers>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('名前を入力'),
      content: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'メンバーの名前',
            ),
            onChanged: (value) {
              name = value;
            },
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'メモ（いらん？）',
            ),
            onChanged: (value) {
              memo = value;
            },
          ),
        ],
      ),
      actions: [
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () {
            Navigator.pop(context, Answers.OK);
          },
        ),
        SimpleDialogOption(
          child: Text('NO'),
          onPressed: () {
            Navigator.pop(context, Answers.CANCEL);
          },
        ),
      ],
    ),
  ).then((value) async {
    switch (value) {
      case Answers.OK:
        final String now = DateTime.now().toString();
        final Member newMember = Member(
            id: -1,
            tripId: -3,
            name: name,
            memo: memo,
            createdAt: now,
            updatedAt: now);
        await model.addMember(newMember);
        break;
      case Answers.CANCEL:
        break;
    }
  });
}

_setMembers(List<Member> members) {
  final listMembers = members
      .map((member) => ListTile(
            leading: Icon(Icons.person),
            title: Text(member.name),
          ))
      .toList();
  return listMembers;
}
