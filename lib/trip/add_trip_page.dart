import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:trip_money_local/trip/trip_list_page.dart';
import 'package:uuid/uuid.dart';

enum Answers { OK, CANCEL }

class AddTripPage extends StatelessWidget {
  AddTripPage(this.trip);
  Trip trip;
//  List<Widget> listTiles = [];
  final tripNameEditingController = TextEditingController();
  final tripMemoEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isUpdate = trip != null;
    if (isUpdate) {
      tripNameEditingController.text = trip.name;
      tripMemoEditingController.text = trip.memo;
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateTripModel>(
        create: (_) => AddUpdateTripModel(),
        child: Consumer<AddUpdateTripModel>(
            builder: (consumerContext, model, child) {
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
                          builder: (context) => TripListPage(),
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
                  Text(isUpdate ? '旅行を編集' : '旅行を追加'),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '旅行名',
                    ),
                    controller: tripNameEditingController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'メモとか'),
                    controller: tripMemoEditingController,
                  ),
                  RaisedButton(
                    child: Text(isUpdate ? '編集する' : '追加する'),
                    onPressed: () async {
                      model.name = tripNameEditingController.text;
                      model.memo = tripMemoEditingController.text;
                      await addTrip(model, context);
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

Future addTrip(AddUpdateTripModel model, BuildContext context) async {
  try {
    final String now = DateTime.now().toString();
    final Trip newTrip = Trip(
        id: Uuid().v1(),
        name: model.name,
        memo: model.memo,
        updatedAt: now,
        createdAt: now);
    await model.addTrip(newTrip);
    final Member sampleMember = Member(
        id: Uuid().v1(),
        tripId: newTrip.id,
        name: 'サンプルメンバー',
        memo: null,
        color: null,
        updatedAt: now,
        createdAt: now);
    await AddUpdateMemberModel().addMember(sampleMember);
    final Item sampleItem = Item(
      id: Uuid().v1(),
      tripId: newTrip.id,
      title: 'サンプルタスク',
      money: 1000,
      memberId: sampleMember.id,
      memo: null,
      isPaid: false,
      createdAt: now,
      updatedAt: now,
    );
    await AddUpdateItemModel().addItem(sampleItem);
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

Future updateTrip(
    AddUpdateTripModel model, BuildContext context, Trip updatedTrip) async {
  try {
    final String now = DateTime.now().toString();
    updatedTrip.name = model.name;
    updatedTrip.memo = model.memo;
    updatedTrip.updatedAt = now;
    await model.updateTrip(updatedTrip);
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
