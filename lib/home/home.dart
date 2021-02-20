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
import 'package:trip_money_local/footer/trip_footer.dart';
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
              centerTitle: false,
// そのうち設定アイコンに機能を持たせる
//              actions: [
//                IconButton(icon: Icon(Icons.settings), onPressed: () async {}),
//              ],
              title: Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.black87,
            ),
            body: Column(
              children: [
                Container(
                  color: Colors.black87,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FlatButton(
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0))),
                            child: const Text('TODO'),
                            color: this.switchType == SwitchType.UN_PAID
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Colors.grey[600],
                            onPressed: () {
                              switchButtonService
                                  .setSwitchType(SwitchType.UN_PAID);
                              model.getItems(SwitchType.UN_PAID);
                            },
                          ),
                        ),
                        Container(
                          color: Colors.black87,
                          height: 50,
                          width: 5,
                        ),
                        Expanded(
                          child: FlatButton(
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0))),

                            child: const Text('DONE'),
                            color: this.switchType == SwitchType.PAID
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Colors.grey[600],
//                          shape: Border(
//                            bottom: BorderSide(color: Colors.green),
//                          ),
                            onPressed: () {
                              switchButtonService
                                  .setSwitchType(SwitchType.PAID);
                              model.getItems(SwitchType.PAID);
                            },
                          ),
                        ),
                        Container(
                          color: Colors.black87,
                          height: 50,
                          width: 5,
                        ),
                        Expanded(
                          child: FlatButton(
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0))),
                            child: const Text('ALL'),
                            color: this.switchType == SwitchType.All
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Colors.grey[600],
                            onPressed: () {
                              switchType = SwitchType.All;
                              switchButtonService.setSwitchType(SwitchType.All);
                              model.getItems(SwitchType.All);
                            },
                          ),
                        ),
                      ]),
                ),
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
                ),
                TripFooter(selectedTrip),
              ],
            ),
            floatingActionButton: Container(
              margin: EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                onPressed: () async {
                  List<Member> members =
                      await AddUpdateMemberModel().getMembers();
                  // タスク追加ダイアログ呼び出し
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
            ),
            bottomNavigationBar: Footer(),
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
          await _showItemDetail(context, item, member, members, model);
        },
        onLongPress: () async {
          List<Member> members = await AddUpdateMemberModel().getMembers();
          // タスク追加ダイアログ呼び出し
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddItemPage(members, item),
                fullscreenDialog: false),
          ).then((value) async {
            // ここで画面遷移から戻ってきたことを検知できる
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
    style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
    underline: Container(
      height: 0,
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

_showItemDetail(BuildContext context, Item item, Member member,
    List<Member> members, AddUpdateItemModel model) async {
  SwitchButtonService switchButtonService = SwitchButtonService();
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      return Container(
        child: SimpleDialog(
//          title: Text(item.title),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      item.title,
                      style: TextStyle(fontSize: 25),
                    )),
                Stack(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 50,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(Icons.edit_rounded),
                        onPressed: () async {
                          List<Member> members =
                              await AddUpdateMemberModel().getMembers();
                          // タスク追加ダイアログ呼び出し
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddItemPage(members, item),
                                fullscreenDialog: false),
                          ).then((value) async {
                            // ここで画面遷移から戻ってきたことを検知できる
                            String switchType =
                                switchButtonService.getSwitchType();
                            model.getItems(switchType);
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

//              child: FlatButton(
//                  child: Text('編集'),
//                  onPressed: () async {
//                    List<Member> members =
//                        await AddUpdateMemberModel().getMembers();
//                    // タスク追加ダイアログ呼び出し
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => AddItemPage(members, item),
//                          fullscreenDialog: false),
//                    ).then((value) async {
//                      // ここで画面遷移から戻ってきたことを検知できる
//                      String switchType = switchButtonService.getSwitchType();
//                      model.getItems(switchType);
//                      Navigator.of(context).pop();
//                    });
//                  }),

            // コンテンツ領域
            Container(
              width: width,
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.person),
                  Container(
                    width: 10,
                  ),
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
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.money),
                  Container(
                    width: 10,
                  ),
                  Text('${item.money.toString()}円'),
                ],
              ),
            ),
// TODO:割り勘金額一旦消す
//          SimpleDialogOption(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.start,
//              children: [
//                Icon(null),
//                Text(
//                    '${item.money} / ${members.length} = ${(item.money / members.length).ceil()}(円/人)'),
//              ],
//            ),
//          ),

            Column(
                children: _makeCheckBoxWidget(context, item, members, model)),

            item.memo != ''
                ? Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
//              mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.note),
                        Container(
                          width: 10,
                        ),
                        Text(item.memo ?? ''),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      );
    },
  );
}

List<Widget> _makeCheckBoxWidget(BuildContext context, Item item,
    List<Member> members, AddUpdateItemModel model) {
  List<String> checkList =
      item.checkMemberList == null ? [] : item.checkMemberList;
  List<Widget> checkBoxWidget = new List<Widget>();
  for (var i = 0; i < members.length; i++) {
    String checkMemberId = checkList
        .firstWhere((check) => check == members[i].id, orElse: () => null);
    bool isCheck = checkMemberId != null;
    checkBoxWidget.add(Row(
      children: [
        Checkbox(
          activeColor: Colors.blue,
          value: isCheck,
          onChanged: (value) {
            if (value) {
              checkList.add(members[i].id);
            } else {
              if (checkMemberId != null) {
                checkList.removeWhere((check) => check == checkMemberId);
              }
            }
            isCheck = value;
            item.checkMemberList = checkList;
            model.updateItem(item);
            Navigator.of(context).pop();
            Member itemMember = members.firstWhere(
                (element) => element.id == item.memberId,
                orElse: () => null);
            _showItemDetail(context, item, itemMember, members, model);
          },
        ),
        Text(members[i].name),
      ],
    ));
  }
  return checkBoxWidget;
}
