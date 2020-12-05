import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
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
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 更新ボタン（ダサいので変えたい）
                    IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () async {
                          final test = await model.getTrips();
                          listTiles = _setTrips(test, context, model);
                        }),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await model.deleteAllTrip();
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTripPage(),
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
            secondaryBackground: Container(color: Colors.red),
            child: ListTile(
              leading: Icon(Icons.star),
              title: Text(trip.name),
              subtitle: Text(trip.id),
              onTap: () async {
                await AddUpdateTripModel().selectedTrip(trip);
                Navigator.pop(context);
              },
            )),
      )
      .toList();
  return listTrips;
}
