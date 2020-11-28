import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/header/header.dart';
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
            listTiles = _setItems(model.items);
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
                        model.deleteAllItem(-3);
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

                          listTiles = _setItems(items);
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
                // アイテム追加ダイアログ呼び出し
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddItemPage(),
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

_setItems(List<Item> items) {
  final listItems = items
      .map((item) => ListTile(
            leading: Icon(Icons.map),
            title: Text(item.title),
            subtitle: Text(item.tripId),
          ))
      .toList();
  return listItems;
}
