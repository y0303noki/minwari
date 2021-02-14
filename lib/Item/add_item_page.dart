import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:uuid/uuid.dart';

enum Answers { OK, CANCEL }

class AddItemPage extends StatelessWidget {
  AddItemPage(this.members, this.item);
  final List<Member> members;
  final Item item;
//  List<Widget> listTiles = [];

  @override
  Widget build(BuildContext context) {
    final itemNameEditingController = TextEditingController();
    Member defaultMember = members.first;
    final personEditingController =
        TextEditingController(text: defaultMember.name);
    final itemMoneyEditingController = TextEditingController();
    final itemMemoEditingController = TextEditingController();

    final isUpdate = item != null;
    // 更新なら更新前のデータを反映させる
    if (isUpdate) {
      itemNameEditingController.text = item.title;
      itemMoneyEditingController.text = item.money.toString();
      itemMemoEditingController.text = item.memo;

      defaultMember = members.firstWhere((member) => member.id == item.memberId,
          orElse: () => members.first);
      if (defaultMember != null) {
        personEditingController.text = defaultMember.name;
      }
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ChangeNotifierProvider<AddUpdateItemModel>(
        create: (_) => AddUpdateItemModel(),
        child: Consumer<AddUpdateItemModel>(
            builder: (consumerContext, model, child) {
          print('itam_page Consumer');
          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => HomePage(),
//                          fullscreenDialog: false),
//                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
              actions: [],
              title: Text(
                '',
              ),
              backgroundColor: Colors.black87,
              centerTitle: true,
              elevation: 0.0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(!isUpdate ? 'アイテムを追加' : 'アイテムを編集'),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'タイトル',
                    ),
                    controller: itemNameEditingController,
                  ),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'メンバー',
                    ),
                    controller: personEditingController,
                    onTap: () {
                      _showModalPicker(
                          context, personEditingController, this.members);
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '金額'),
                    controller: itemMoneyEditingController,
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(labelText: 'メモ'),
                    controller: itemMemoEditingController,
                  ),
                  RaisedButton(
                    child: Text(!isUpdate ? '追加する' : '編集する'),
                    onPressed: () async {
                      model.title = itemNameEditingController.text;
//                      model.member = personEditingController.text;
                      Member selectedMember = this.members.firstWhere(
                          (m) => m.name == personEditingController.text);
                      model.memberId = selectedMember.id;
                      model.money =
                          int.tryParse(itemMoneyEditingController.text);
                      model.memo = itemMemoEditingController.text;
                      if (isUpdate) {
                        await upDateItem(model, context, item);
                      } else {
                        await addItem(model, context);
                      }
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

// 新規追加
Future addItem(AddUpdateItemModel model, BuildContext context) async {
  try {
    final String now = DateTime.now().toString();
    final Item newItem = Item(
        id: Uuid().v1(),
        tripId: null,
        title: model.title,
        money: model.money,
        memberId: model.memberId,
        memo: model.memo,
        isPaid: false,
        createdAt: now,
        updatedAt: now);
    await model.addItem(newItem);

//    await showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: Text('保存しました。'),
//          actions: [
//            FlatButton(
//              child: Text('OK'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
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

// 更新
Future upDateItem(
    AddUpdateItemModel model, BuildContext context, Item updateItem) async {
  try {
    final String now = DateTime.now().toString();
    updateItem.title = model.title;
    updateItem.memberId = model.memberId;
    updateItem.money = model.money;
    updateItem.updatedAt = now;
    updateItem.memo = model.memo;
    await model.updateItem(updateItem);
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

// ピッカーからメンバーを選択する
_showModalPicker(BuildContext context, TextEditingController textController,
    List<Member> members) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      List<String> memberNameList = members.map((m) => m.name).toList();
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context, 'picker');
          },
          child: CupertinoPicker(
            itemExtent: 40,
            children: memberNameList.map(_pickerItem).toList(),
            onSelectedItemChanged: (value) {
              textController.text = memberNameList[value].toString();
            },
          ),
        ),
      );
    },
  );
}

Widget _pickerItem(String str) {
  return Text(
    str,
    style: const TextStyle(fontSize: 32),
  );
}
