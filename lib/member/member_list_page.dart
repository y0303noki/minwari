import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
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
        create: (_) => AddUpdateMemberModel()..getMembers(),
        child: Consumer<AddUpdateMemberModel>(
            builder: (consumerContext, model, child) {
          print('member_list_page Consumer');
          if (model.members == null) {
          } else {
            listTiles = _setMembers(model.members, model);
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
                          final test = await model.getMembers();
                          listTiles = _setMembers(test, model);
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
                  model.getMembers();
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

//_setMembers(List<Member> members) {
//  if (members == null) {
//    return [];
//  }
//  final listMembers = members
//      .map((member) => ListTile(
//            leading: Icon(Icons.person),
//            title: Text(member.name),
//          ))
//      .toList();
//  return listMembers;
//}

List<Widget> _setMembers(List<Member> members, AddUpdateMemberModel model) {
  if (members == null) {
    return [];
  }
  final listMembers = members
      .map(
        // 左右スワイプで消せるように
        (member) => Dismissible(
          key: Key(member.id),
          onDismissed: (direction) {
            // スワイプ方向がendToStart（画面左から右）の場合の処理
            if (direction == DismissDirection.endToStart) {
              print(1);
              model.deleteMember(member);
              // スワイプ方向がstartToEnd（画面右から左）の場合の処理
            } else {
              print(2);
            }
          },
          // スワイプ方向がendToStart（画面左から右）の場合のバックグラウンドの設定
          background: Container(color: Colors.blue),

          // スワイプ方向がstartToEnd（画面右から左）の場合のバックグラウンドの設定
          secondaryBackground: Container(color: Colors.red),

          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(member.name),
            subtitle: Text(member.tripId),
          ),
        ),
      )
      .toList();
  return listMembers;
}
