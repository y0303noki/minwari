import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/member/member_list_page.dart';
import 'package:trip_money_local/trip/trip_list_page.dart';

class HomePage extends StatelessWidget {
  List<Widget> listTiles = [];
  Trip selectedTrip;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateItemModel>(
        create: (_) => AddUpdateItemModel()..getItems(),
        child: Consumer<AddUpdateItemModel>(
            builder: (consumerContext, model, child) {
          print('consumer');
          if (model.items == null) {
            listTiles = [];
          } else {
            listTiles = _setItems(model.items, model.members, model);
          }

          if (model.selectedTrip == null) {
            selectedTrip = null;
          } else {
            selectedTrip = model.selectedTrip;
          }

          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.settings),
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.list),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TripListPage(),
                            fullscreenDialog: false),
                      ).then((value) {
                        // ここで画面遷移から戻ってきたことを検知できる
                        model.getItems();
                      });
                    }),
              ],
              title: Text(
                selectedTrip == null ? '読み込み中...' : selectedTrip.name,
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
                    // 共有設定ボタン
                    // とりあえずデータ全消しボタン
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () async {
                        model.deleteAllItem();
                      },
                    ),
                    // 更新ボタン（ダサいので変えたい）
                    IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () async {
                          List<Item> items = await model.getItems();
                          if (items == null || items.isEmpty) {
                            return;
                          }

                          listTiles = _setItems(items, model.members, model);
                        }),
                    // メンバー管理ボタン
                    IconButton(
                        icon: Icon(Icons.person),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemberListPage(),
                                fullscreenDialog: true),
                          );
                        }),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: listTiles,
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                List<Member> members =
                    await AddUpdateMemberModel().getMembers();
                // アイテム追加ダイアログ呼び出し
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddItemPage(members),
                      fullscreenDialog: true),
                ).then((value) {
                  // ここで画面遷移から戻ってきたことを検知できる
                  print('モドてきた');
                  model.getItems();
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          );
        }),
      ),
    );
  }
}

const List<Widget> listTiles = const [
  ListTile(
    leading: Icon(Icons.map),
    title: Text('Map'),
  ),
  ListTile(
    leading: Icon(Icons.money),
    title: Text('Money'),
  ),
];

List<Widget> _setItems(
    List<Item> items, List<Member> members, AddUpdateItemModel model) {
  if (items == null) {
    return [];
  }

  if (members == null) {
    return [];
  }

//  final listItems = items
//      .map(
//        // 左右スワイプで消せるように
//        (item) => Dismissible(
//          key: Key(item.id),
//          onDismissed: (direction) async {
//            // スワイプ方向がendToStart（画面左から右）の場合の処理
//            if (direction == DismissDirection.endToStart) {
//              print(1);
//              model.deleteItem(item);
//              // スワイプ方向がstartToEnd（画面右から左）の場合の処理
//            } else {
//              print(2);
//            }
//          },
//          // スワイプ方向がendToStart（画面左から右）の場合のバックグラウンドの設定
//          background: Container(color: Colors.blue),
//
//          // スワイプ方向がstartToEnd（画面右から左）の場合のバックグラウンドの設定
//          secondaryBackground: Container(color: Colors.red),
//
//          child: ListTile(
//            leading: Icon(Icons.map),
//            title: Text(item.title),
//            subtitle: Text(members.firstWhere((m) => m.id == item.memberId,
//                        orElse: () => null) !=
//                    null
//                ? members.firstWhere((m) => m.id == item.memberId).name
//                : 'メンバーがいないよ'),
//          ),
//        ),
//      )
//      .toList();

  List<Widget> listItems = [];

  for (var item in items) {
    Member member =
        members.firstWhere((m) => m.id == item.memberId, orElse: () => null);
    listItems.add(Dismissible(
      key: Key(item.id),
      onDismissed: (direction) async {
        // スワイプ方向がendToStart（画面左から右）の場合の処理
        if (direction == DismissDirection.endToStart) {
          print(1);
          model.deleteItem(item);
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
        title: Text(item.title),
        subtitle: Text(member != null ? member.name : 'nullだよ'),
        trailing: Text('${item.money.toString()}円'),
      ),
    ));
  }

  return listItems;
}
