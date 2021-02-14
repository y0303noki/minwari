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
import 'dart:math';

enum Answers { OK, CANCEL }

class AddTripPage extends StatelessWidget {
  AddTripPage(this.trip);
  Trip trip;
//  List<Widget> listTiles = [];
  final tripNameEditingController = TextEditingController();
  final tripMemoEditingController = TextEditingController();
  final tripEventDateEditingController = TextEditingController();
  final tripEventEndDateEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isUpdate = trip != null;
    if (isUpdate) {
      tripNameEditingController.text = trip.name;
      tripMemoEditingController.text = trip.memo;
      if (trip.eventAt != null) {
        tripEventDateEditingController.text = trip.eventAt;
      }
      if (trip.eventEndAt != null) {
        tripEventEndDateEditingController.text = trip.eventEndAt;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => TripListPage(),
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
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(labelText: '出発日'),
                    controller: tripEventDateEditingController,
                    onTap: () async {
                      // tripの更新なら初期値を更新前でセット
                      DateTime initial = DateTime.now();
                      if (tripEventDateEditingController.text != '') {
                        initial =
                            DateTime.parse(tripEventDateEditingController.text);
                      }

                      final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now().add(Duration(days: 360)));
                      if (picked != null) {
                        final year = picked.year;
                        final month = picked.month < 10
                            ? '0${picked.month}'
                            : '${picked.month}';
                        final day = picked.day < 10
                            ? '0${picked.day}'
                            : '${picked.day}';
                        final eventDateStr =
                            '${year.toString()}-$month-${day.toString()}';
                        tripEventDateEditingController.text = eventDateStr;
                        // 日時反映
                      }
                    },
                  ),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(labelText: '帰宅日'),
                    controller: tripEventEndDateEditingController,
                    onTap: () async {
                      // tripの更新なら初期値を更新前でセット
                      DateTime initial = DateTime.now();
                      if (tripEventEndDateEditingController.text != '') {
                        initial = DateTime.parse(
                            tripEventEndDateEditingController.text);
                      }

                      final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now().add(Duration(days: 360)));
                      if (picked != null) {
                        final year = picked.year;
                        final month = picked.month < 10
                            ? '0${picked.month}'
                            : '${picked.month}';
                        final day = picked.day < 10
                            ? '0${picked.day}'
                            : '${picked.day}';
                        final eventDateStr =
                            '${year.toString()}-$month-${day.toString()}';
                        tripEventEndDateEditingController.text = eventDateStr;
                        // 日時反映
                      }
                    },
                  ),
                  RaisedButton(
                    child: Text(isUpdate ? '編集する' : '追加する'),
                    onPressed: () async {
                      model.name = tripNameEditingController.text;
                      model.memo = tripMemoEditingController.text;
                      model.eventDate = tripEventDateEditingController.text;
                      model.eventEndDate =
                          tripEventEndDateEditingController.text;
                      if (isUpdate) {
                        await updateTrip(model, context, trip);
                      } else {
                        await addTrip(model, context);
                      }
                    },
                  ),
                  Visibility(
                    // 編集モードのの時だけ削除ボタンを表示する
                    visible: isUpdate,
                    child: RaisedButton(
                        color: Colors.red,
                        child: Text(
                          '削除する',
                        ),
                        onPressed: () async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("削除しますか？"),
                                content: Text('この項目を削除すると復元することはできません。'),
                                actions: [
                                  FlatButton(
                                    onPressed: () async {
                                      await model.deleteTrip(trip);
                                      // ダイアログを消してtrip画面まで戻る
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              TripListPage(),
                                          transitionDuration:
                                              Duration(seconds: 0),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      '削除する',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(
                                      'キャンセル',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
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
    String thumbnail = await makeThumbnails(model);
    final String now = DateTime.now().toString();
    final String eventDate = model.eventDate.toString();
    final String eventEndAt = model.eventEndDate.toString();
    final Trip newTrip = Trip(
        id: Uuid().v1(),
        name: model.name,
        memo: model.memo,
        thumbnail: thumbnail,
        eventAt: eventDate,
        eventEndAt: eventEndAt,
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
    updatedTrip.eventAt = model.eventDate;
    updatedTrip.eventEndAt = model.eventEndDate;
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

Future<String> makeThumbnails(AddUpdateTripModel model) async {
  List<Trip> trips = await model.getTrips();
  // 0~5までの乱数生成
  int loopBreakNumber = 0;
  while (true) {
    Random random = new Random();
    int randomNumber = random.nextInt(5);
    String imageName = 'images/tripImage$randomNumber.jpg';
    Trip findTrip = null;
    if (trips != null && !trips.isEmpty) {
      findTrip = trips.firstWhere((element) => element.thumbnail == imageName,
          orElse: () => null);
    }

    if (findTrip == null) {
      return imageName;
    }
    loopBreakNumber++;
    print(loopBreakNumber);
    if (loopBreakNumber > 10) {
      // 10回以上ループしてたら無限ループの危険。強制終了
      return imageName;
    }
  }
}
