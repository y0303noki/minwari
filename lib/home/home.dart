import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/member/member_list_page.dart';

class HomePage extends StatelessWidget {
  List<Widget> listTiles = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateItemModel>(
        create: (_) => AddUpdateItemModel()..getItems(-3),
        child: Consumer<AddUpdateItemModel>(
            builder: (consumerContext, model, child) {
          print('consumer');
          if (model.itemsDecoded == null) {
          } else {
            final test2 = model.itemsDecoded;
            listTiles = _setItems(test2);
          }

          return Scaffold(
            appBar: Header(),
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
                          final test = await model.getItems(-3);
                          listTiles = _setItems(test);
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
                  model.getItems(-3);
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
          ))
      .toList();
  return listItems;
}

//openDialog(BuildContext context, AddUpdateItemModel model) {
//  String title = '';
//  int money = 0;
//  String person = '';
//  showDialog<Answers>(
//    context: context,
//    builder: (BuildContext context) => AlertDialog(
//      title: Text('タイトルを入力'),
//      content: Column(
//        children: [
//          TextField(
//            autofocus: true,
//            decoration: InputDecoration(
//              labelText: 'イベントの名前',
//            ),
//            onChanged: (value) {
//              title = value;
//            },
//          ),
//          TextField(
//            autofocus: true,
//            decoration: InputDecoration(
//              labelText: '金額',
//            ),
//            onChanged: (value) {
//              money = int.parse(value);
//            },
//          ),
//          TextField(
//            autofocus: true,
//            decoration: InputDecoration(
//              labelText: '人',
//            ),
//            onChanged: (value) {
//              person = value;
//            },
//          ),
//        ],
//      ),
//      actions: [
//        SimpleDialogOption(
//          child: Text('Yes'),
//          onPressed: () {
//            Navigator.pop(context, Answers.OK);
//          },
//        ),
//        SimpleDialogOption(
//          child: Text('NO'),
//          onPressed: () {
//            Navigator.pop(context, Answers.CANCEL);
//          },
//        ),
//      ],
//    ),
//  ).then((value) async {
//    switch (value) {
//      case Answers.OK:
//        final String now = DateTime.now().toString();
//        final Item newItem = Item(
//            id: -1,
//            tripId: -3,
//            title: title,
//            money: money,
//            createdAt: now,
//            updatedAt: now);
//        await model.addItem(newItem);
//        print('アイテム追加した');
//        return 'TEST!';
//        break;
//      case Answers.CANCEL:
//        break;
//    }
//  });
//}
