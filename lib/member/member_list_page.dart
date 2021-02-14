import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/footer/footer.dart';
import 'package:trip_money_local/footer/trip_footer.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/member/add_member_page.dart';

class MemberListPage extends StatelessWidget {
  List<Widget> listTiles = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ChangeNotifierProvider<AddUpdateMemberModel>(
        create: (_) => AddUpdateMemberModel()..getMembers(),
        child: Consumer<AddUpdateMemberModel>(
            builder: (consumerContext, model, child) {
          print('member_list_page Consumer');
          if (model.members == null) {
          } else {
            listTiles = _setMembers(model.members, model, context);
          }
          return Scaffold(
            appBar: AppBar(
              actions: [],
              title: Text(
                'Member',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.black87,
              centerTitle: false,
              elevation: 0.0,
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                  // メンバー管理ボタン
                ),
                Expanded(
                  child: ListView(
                    children: listTiles,
                  ),
                ),
                TripFooter(model.selectedTrip),
              ],
            ),
            floatingActionButton: Container(
              margin: EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                onPressed: () {
                  if (listTiles.length >= 11) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('これ以上追加できません。'),
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
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddMemberPage(null),
                          fullscreenDialog: true),
                    ).then((value) {
                      // ここで画面遷移から戻ってきたことを検知できる
                      print('モドてきたメンバ');
                      model.getMembers();
                    });
                  }
                },
                child: Icon(Icons.person_add),
                backgroundColor: Colors.green,
              ),
            ),
            bottomNavigationBar: Footer(),
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

List<Widget> _setMembers(
    List<Member> members, AddUpdateMemberModel model, BuildContext context) {
  if (members == null) {
    return [];
  }
  final listMembers = members
      .map(
        // 左右スワイプで消せるように
        (member) => Dismissible(
          key: Key(member.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                if (members.length == 1) {
                  return AlertDialog(
                    title: Text("削除できません"),
                    content: Text('メンバーリストは必ず1つ以上残してください。'),
                    actions: [
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'OK',
                        ),
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: Text("削除しますか？"),
                    content: Text('この項目を削除すると復元することはできません。'),
                    actions: [
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          '削除',
                        ),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'キャンセル',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          },
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
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),

          child: ListTile(
            leading: Icon(Icons.person_outline_rounded),
            title: Text(member.name),
            onTap: () async {
              if (member.memo == '' || member.memo == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddMemberPage(member),
                      fullscreenDialog: true),
                ).then((value) {
                  // ここで画面遷移から戻ってきたことを検知できる
                  model.getMembers();
                });
              } else {
                // タップして詳細表示
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  member.name,
                                  style: TextStyle(fontSize: 25),
                                )),
                            Stack(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 50,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.edit_rounded),
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddMemberPage(member),
                                            fullscreenDialog: false),
                                      ).then((value) async {
                                        // ここで画面遷移から戻ってきたことを検知できる
                                        model.getMembers();
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // コンテンツ領域
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.note),
                              Text(member.memo ?? ''),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            onLongPress: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddMemberPage(member),
                    fullscreenDialog: true),
              ).then((value) {
                // ここで画面遷移から戻ってきたことを検知できる
                model.getMembers();
              });
            },
          ),
        ),
      )
      .toList();
  return listMembers;
}
