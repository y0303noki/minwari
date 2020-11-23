import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_page.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/header/header.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';

class TripListPage extends StatelessWidget {
  List<Widget> listTiles = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateTripModel>(
        create: (_) => AddUpdateTripModel()
          ..getTrips().then((value) => listTiles = _setTrips(value)),
        child: Consumer<AddUpdateTripModel>(
            builder: (consumerContext, model, child) {
          print('trip_list_page Consumer');
          return Scaffold(
            appBar: Header(),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 戻るボタン
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () async {
                          Navigator.pop(context);
                        }),
                    // 更新ボタン（ダサいので変えたい）
                    IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () async {
                          final test = await model.getTrips();
                          listTiles = _setTrips(test);
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
                // アイテム追加ダイアログ呼び出し
                openTripDialog(context, model);
              },
              child: Icon(Icons.add_box),
              backgroundColor: Colors.green,
            ),
          );
        }),
      ),
    );
  }
}

void openTripDialog(BuildContext context, AddUpdateTripModel model) {
  String name = '';
  String memo = '';
  showDialog<Answers>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('名前を入力'),
      content: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: '旅行の名前',
            ),
            onChanged: (value) {
              name = value;
            },
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'メモ（いらん？）',
            ),
            onChanged: (value) {
              memo = value;
            },
          ),
        ],
      ),
      actions: [
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () {
            Navigator.pop(context, Answers.OK);
          },
        ),
        SimpleDialogOption(
          child: Text('NO'),
          onPressed: () {
            Navigator.pop(context, Answers.CANCEL);
          },
        ),
      ],
    ),
  ).then((value) async {
    switch (value) {
      case Answers.OK:
        final Trip newTrip = Trip(name: name, memo: memo);
        await model.addTrip(newTrip);
        break;
      case Answers.CANCEL:
        break;
    }
  });
}

_setTrips(List<Trip> members) {
  final listTrips = members
      .map((member) => ListTile(
            leading: Icon(Icons.star),
            title: Text(member.name),
          ))
      .toList();
  return listTrips;
}
