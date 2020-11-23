import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/member/add_member_page.dart';

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
          if (model.members == null) {
          } else {
            listTiles = _setMembers(model.members);
          }
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
                          builder: (context) => HomePage(),
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
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 更新ボタン（ダサいので変えたい）
                    IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () async {
                          final test = await model.getMembers(-3);
                          listTiles = _setMembers(test);
                        }),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await model.deleteAllMember(-3);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddMemberPage(),
                      fullscreenDialog: true),
                ).then((value) {
                  // ここで画面遷移から戻ってきたことを検知できる
                  print('モドてきたメンバ');
                  model.getMembers(-3);
                });
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

_setMembers(List<Member> members) {
  final listMembers = members
      .map((member) => ListTile(
            leading: Icon(Icons.person),
            title: Text(member.name),
          ))
      .toList();
  return listMembers;
}
