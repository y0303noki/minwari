import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/member/add_member_model.dart';

enum Answers { OK, CANCEL }

class AddItemPage extends StatelessWidget {
//  List<Widget> listTiles = [];
  final itemNameEditingController = TextEditingController();
  final personEditingController = TextEditingController();
  final itemMoneyEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
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
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('アイテム追加'),
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
//                          _showModalPicker(context, personEditingController,
//                              members, selectTrip);
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '金額'),
                    controller: itemMoneyEditingController,
                    keyboardType: TextInputType.number,
                  ),
                  RaisedButton(
                    child: Text('追加する'),
                    onPressed: () async {
                      model.title = itemNameEditingController.text;
//                      model.memberName = personEditingController.text;
                      model.money =
                          int.tryParse(itemMoneyEditingController.text);
                      await addItem(model, context);
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

Future addItem(AddUpdateItemModel model, BuildContext context) async {
  try {
    final String now = DateTime.now().toString();
    final Item newItem = Item(
        id: -1,
        tripId: '',
        title: model.title,
        money: model.money,
        createdAt: now,
        updatedAt: now);
    await model.addItem(newItem);
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
