import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/footer/footer.dart';
import 'package:trip_money_local/footer/footer_navigation_model.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:trip_money_local/trip/add_trip_page.dart';

class TripListPage extends StatelessWidget {
  List<Widget> listTiles = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateTripModel>(
        create: (_) => AddUpdateTripModel()
          ..getTrips().then((value) =>
              listTiles = _setTrips(value, context, AddUpdateTripModel())),
        child: Consumer<AddUpdateTripModel>(
            builder: (consumerContext, model, child) {
          print('trip_list_page Consumer');
          if (model.trips == null) {
          } else {
            listTiles = _setTrips(model.trips, context, model);
          }
          return Scaffold(
            appBar: AppBar(
              actions: [],
              title: Text(
                '旅リスト',
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
                    model.selectedTripFromTrip == null
                        ? '読み込み中...'
                        : model.selectedTripFromTrip.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTripPage(null),
                      fullscreenDialog: true),
                ).then((value) {
                  // ここで画面遷移から戻ってきたことを検知できる
                  print('モドてきたtrip');
                  model.getTrips();
                });
              },
              child: Icon(Icons.add_box),
              backgroundColor: Colors.green,
            ),
            bottomNavigationBar: Footer(),
          );
        }),
      ),
    );
  }
}

_setTrips(List<Trip> trips, BuildContext context, AddUpdateTripModel model) {
  if (trips == null) {
    return [];
  }

  final listTrips = trips
      .map(
        (trip) => Dismissible(
            key: Key(trip.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (trips.length == 1) {
                    return AlertDialog(
                      title: Text("削除できません"),
                      content: Text('旅リストは必ず1つ以上残してください。'),
                      actions: [
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'OK',
                          ),
                        ),
                      ],
                    );
                  } else {
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
                  }
                },
              );
            },
            onDismissed: (direction) {
              // スワイプ方向がendToStart（画面左から右）の場合の処理
              if (direction == DismissDirection.endToStart) {
                model.deleteTrip(trip);
                // スワイプ方向がstartToEnd（画面右から左）の場合の処理
              } else {
                print(2);
              }
            },
            // スワイプ方向がendToStart（画面左から右）の場合のバックグラウンドの設定
            background: Container(color: Colors.blue),

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
              leading: Icon(Icons.event),
              title: Text(trip.name),
              subtitle: Text(''),
              onTap: () async {
                await AddUpdateTripModel().selectedTrip(trip);
                FooterNavigationService footerNavigationService =
                    FooterNavigationService();
                footerNavigationService.setFooterType('Home');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(),
                        fullscreenDialog: false));
              },
              onLongPress: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTripPage(trip),
                      fullscreenDialog: true),
                ).then((value) {
                  // ここで画面遷移から戻ってきたことを検知できる
                  print('モドてきたtrip');
                  model.getTrips();
                });
              },
            )),
      )
      .toList();
  return listTrips;
}
