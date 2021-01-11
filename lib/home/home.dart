import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/Item/switch_button_service.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/switchType.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/footer/footer.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/member/member_list_page.dart';
import 'package:trip_money_local/trip/trip_list_page.dart';

class HomePage extends StatelessWidget {
  List<Widget> listTiles = [];
  Trip selectedTrip;
  SwitchButtonService switchButtonService = SwitchButtonService();
  String switchType;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateItemModel>(
        create: (_) => AddUpdateItemModel()..getItems(SwitchType.UN_PAID),
        child: Consumer<AddUpdateItemModel>(
            builder: (consumerContext, model, child) {
          print('consumer');
          if (model.selectedTrip == null) {
            selectedTrip = null;
          } else {
            selectedTrip = model.selectedTrip;
          }

          if (model.items == null) {
            listTiles = [];
          } else {
            listTiles = _setItems(model.items, model.members, model, context);
          }

          this.switchType = switchButtonService.getSwitchType();
          if (this.switchType == null) {
            this.switchType = SwitchType.UN_PAID;
          }

          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(icon: Icon(Icons.settings), onPressed: () async {}),
              ],
              title: Text(
                'ホーム',
              ),
              backgroundColor: Colors.black87,
              centerTitle: true,
              elevation: 0.0,
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    selectedTrip == null ? '読み込み中...' : selectedTrip.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RaisedButton(
                          child: const Text('未精算'),
                          color: this.switchType == SwitchType.UN_PAID
                              ? Colors.white70
                              : Colors.white,
                          shape: Border(
                            bottom: BorderSide(color: Colors.orange),
                            right: BorderSide(color: Colors.grey),
                          ),
                          onPressed: () {
                            switchButtonService
                                .setSwitchType(SwitchType.UN_PAID);
                            model.getItems(SwitchType.UN_PAID);
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          child: const Text('精算済み'),
                          color: this.switchType == SwitchType.PAID
                              ? Colors.white70
                              : Colors.white,
                          shape: Border(
                            bottom: BorderSide(color: Colors.green),
                            right: BorderSide(color: Colors.grey),
                          ),
                          onPressed: () {
                            switchButtonService.setSwitchType(SwitchType.PAID);
                            model.getItems(SwitchType.PAID);
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          child: const Text('全て'),
                          color: this.switchType == SwitchType.All
                              ? Colors.white70
                              : Colors.white,
                          shape: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            switchType = SwitchType.All;
                            switchButtonService.setSwitchType(SwitchType.All);
                            model.getItems(SwitchType.All);
                          },
                        ),
                      ),
                    ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: dropDownList(context, model),
                  )
                ]),
                Expanded(
                  child: Container(
                    child: ListView(
                      children: listTiles,
                    ),
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
                      builder: (context) => AddItemPage(members, null),
                      fullscreenDialog: true),
                ).then((value) async {
                  // ここで画面遷移から戻ってきたことを検知できる
                  switchButtonService.setSwitchType(SwitchType.UN_PAID);
                  model.getItems(SwitchType.UN_PAID);
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
            bottomNavigationBar: Footer(),

//            bottomNavigationBar: BottomNavigationBar(
//              items: bottomList,
//              currentIndex: _selectedIndex,
//              selectedItemColor: Colors.amber[800],
//              onTap: (int index) {
//                _onItemTapped(index, context);
//              },
//            ),
          );
        }),
      ),
    );
  }
}

_onItemTapped(int index, BuildContext context) {
  print(index);
  if (index == 0) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(), fullscreenDialog: true),
    );
  } else if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MemberListPage(), fullscreenDialog: true),
    );
  } else if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TripListPage(), fullscreenDialog: true),
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

List<Widget> _setItems(List<Item> items, List<Member> members,
    AddUpdateItemModel model, BuildContext context) {
  SwitchButtonService switchButtonService = SwitchButtonService();
  if (items == null) {
    return [];
  }

  if (members == null) {
    return [];
  }

  List<Widget> listItems = [];
  SwitchButtonService switchButtonService2 = SwitchButtonService();
  String type = switchButtonService2.getSwitchType();

  for (var item in items) {
    Member member =
        members.firstWhere((m) => m.id == item.memberId, orElse: () => null);
    listItems.add(Dismissible(
      direction: type == SwitchType.All
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      key: Key(item.id),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
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
            },
          );
        } else {
          return true;
        }
      },
      onDismissed: (direction) async {
        // スワイプ方向がendToStart（画面左から右）の場合の処理
        if (direction == DismissDirection.endToStart) {
          model.deleteItem(item);
          // スワイプ方向がstartToEnd（画面右から左）の場合の処理
        } else {
          model.updateIsPayItem(item);
        }
      },
      // スワイプ方向がendToStart（画面左から右）の場合のバックグラウンドの設定
      background: Container(
        alignment: Alignment.centerLeft,
        color: type == SwitchType.UN_PAID ? Colors.green : Colors.orange,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
          child: Icon(
              type == SwitchType.UN_PAID
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: Colors.white),
        ),
      ),

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
        leading: item.isPaid
            ? const Icon(Icons.check)
            : const Icon(Icons.radio_button_unchecked_outlined),
        title: Text(item.title),
        subtitle: Text(
          member != null ? member.name : 'メンバーが削除されています',
          style: member != null
              ? null
              : TextStyle(
                  color: Colors.red,
                ),
        ),
        trailing: Text('${item.money.toString()}円'),
        onTap: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text(item.title),
                children: [
                  // コンテンツ領域
                  SimpleDialogOption(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.person),
                        Text(
                          member != null ? member.name : 'メンバーが削除されています',
                          style: member != null
                              ? null
                              : TextStyle(
                                  color: Colors.red,
                                ),
                        ),
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.attach_money),
                        Text('${item.money.toString()}円'),
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(null),
                        Text(
                            '${item.money} / ${members.length} = ${(item.money / members.length).ceil()}(円/人)'),
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.note),
                        Text(item.memo),
                      ],
                    ),
                  ),
                  RaisedButton(
                      child: Text('編集画面へ'),
                      onPressed: () async {
                        List<Member> members =
                            await AddUpdateMemberModel().getMembers();
                        // アイテム追加ダイアログ呼び出し
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddItemPage(members, item),
                              fullscreenDialog: false),
                        ).then((value) async {
                          // ここで画面遷移から戻ってきたことを検知できる
                          String switchType =
                              switchButtonService.getSwitchType();
                          model.getItems(switchType);
                          Navigator.of(context).pop();
                        });
                      })
                ],
              );
            },
          );
        },
        onLongPress: () async {
          List<Member> members = await AddUpdateMemberModel().getMembers();
          // アイテム追加ダイアログ呼び出し
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddItemPage(members, item),
                fullscreenDialog: false),
          ).then((value) async {
            // ここで画面遷移から戻ってきたことを検知できる
            print('モドてきた');
            String switchType = switchButtonService.getSwitchType();
            model.getItems(switchType);
            model.getItems(switchType);
          });
        },
      ),
    ));
  }

  return listItems;
}

// ドロップダウン
Widget dropDownList(BuildContext context, AddUpdateItemModel model) {
  String dropdownValue = model.selectedOrderType ?? model.orderTypeJPList.first;
  return DropdownButton<String>(
    value: dropdownValue,
    icon: Icon(Icons.arrow_downward),
    iconSize: 24,
    elevation: 16,
    style: TextStyle(color: Colors.black),
    underline: Container(
      height: 2,
      color: Colors.grey,
    ),
    onChanged: (String newValue) {
      model.setOrderItem(newValue);
    },
    items: model.orderTypeJPList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}
