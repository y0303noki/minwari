import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/footer/footer.dart';
import 'package:trip_money_local/footer/footer_navigation_model.dart';
import 'package:trip_money_local/footer/trip_footer.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:trip_money_local/trip/add_trip_page.dart';
import 'dart:math';

class TripListPage extends StatelessWidget {
  GridView listTiles;
  List<Trip> tripList;
  BuildContext tripListPageContext;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ChangeNotifierProvider<AddUpdateTripModel>(
        create: (_) => AddUpdateTripModel()
          ..getTrips().then((value) =>
              listTiles = _setTrips(value, context, AddUpdateTripModel())),
        child: Consumer<AddUpdateTripModel>(
            builder: (consumerContext, model, child) {
          print('trip_list_page Consumer');
          if (model.trips == null) {
          } else {
            this.tripList = model.trips;
            this.tripListPageContext = context;
            listTiles = _setTrips(model.trips, context, model);
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              actions: [],
              title: Text(
                'Event',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.black87,
              centerTitle: false,
              elevation: 0.0,
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                  // メンバー管理ボタン
                ),
                Expanded(
                  child: listTiles ?? Container(),
                ),
                TripFooter(model.selectedTripFromTrip),
              ],
            ),
            floatingActionButton: Container(
              margin: EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                onPressed: () {
                  if (tripList.length >= 5) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('これ以上追加できません。'),
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
                  } else {
                    // タスク追加ダイアログ呼び出し
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTripPage(null),
                          fullscreenDialog: true),
                    ).then((value) {
                      // ここで画面遷移から戻ってきたことを検知できる
                      model.getTrips();
                    });
                  }
                },
                child: Icon(Icons.add_box),
                backgroundColor: Colors.green,
              ),
            ),
            bottomNavigationBar: Footer(),
          );
        }),
      ),
    );
  }

  _setTrips(List<Trip> trips, BuildContext context, AddUpdateTripModel model) {
    if (trips == null) {
      return GridView;
    }
    if (this.tripList == null || this.tripList.isEmpty) {
      this.tripList = [];
    }
    var listTrips = GridView.count(
      padding: EdgeInsets.all(4.0),
      crossAxisCount: 2,
      crossAxisSpacing: 10.0, // 縦
      mainAxisSpacing: 10.0, // 横
      childAspectRatio: 0.8, // 高さ
      shrinkWrap: true,
      children: _getTiles(model, context),
    );
    return listTrips;
  }

  // gridの中身作成
  List<Widget> _getTiles(AddUpdateTripModel model, BuildContext context) {
    final List<Widget> tiles = <Widget>[];
    for (int i = 0; i < this.tripList.length; i++) {
      Trip selectedTrip = this.tripList[i];
      tiles.add(
        Container(
          decoration: BoxDecoration(
            border: model.selectedTripFromTrip == selectedTrip
                ? Border.all(
                    color: Colors.red,
                    width: 5.0,
                  )
                : Border.all(
                    color: Colors.grey,
                  ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GridTile(
            child: InkResponse(
              enableFeedback: true,
              onTap: () async {
                // タップで旅切り替え
                await AddUpdateTripModel().selectedTrip(selectedTrip);
                FooterNavigationService footerNavigationService =
                    FooterNavigationService();
                footerNavigationService.setFooterType('Home');
                Navigator.push(
                    this.tripListPageContext,
                    MaterialPageRoute(
                        builder: (context) => HomePage(),
                        fullscreenDialog: false));
              },
              child: Column(
                children: [
                  Stack(children: [
                    Image.asset(
                      selectedTrip.thumbnail ?? 'images/tripImage0.jpg',
                    ),
                    Icon(
                      Icons.circle,
                      size: 50,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      onPressed: () {
                        _onTileClicked(selectedTrip, model);
                      },
                    ),
                  ]),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${selectedTrip.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          selectedTrip.eventAt,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
//                        Text(
//                          selectedTrip.eventEndAt,
//                          style: TextStyle(
//                            fontSize: 15,
//                          ),
//                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return tiles;
  }

  void _onTileClicked(Trip selectedTrip, AddUpdateTripModel model) {
    Navigator.push(
      this.tripListPageContext,
      MaterialPageRoute(
          builder: (context) => AddTripPage(selectedTrip),
          fullscreenDialog: true),
    ).then((value) {
      // ここで画面遷移から戻ってきたことを検知できる
      model.getTrips();
    });
  }

  Widget _generator(int index) {
    Trip selectedTrip = this.tripList[index];
    var assetsImage = 'images/tripImage0.jpg';
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
//          color: Colors.black,
//          boxShadow: [
//            new BoxShadow(
//              color: Colors.grey,
//              offset: new Offset(5.0, 5.0),
//              blurRadius: 10.0,
//            )
//          ],
        ),
        child: Column(children: [
          Image.asset(
            assetsImage,
            fit: BoxFit.cover,
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '${selectedTrip.name}',
                ),
                Text(
                  selectedTrip.eventAt,
                ),
              ],
            ),
          ),
        ]),
      ),
      onTap: () {},
      onDoubleTap: () async {
        await AddUpdateTripModel().selectedTrip(selectedTrip);
        FooterNavigationService footerNavigationService =
            FooterNavigationService();
        footerNavigationService.setFooterType('Home');
        Navigator.push(
            this.tripListPageContext,
            MaterialPageRoute(
                builder: (context) => HomePage(), fullscreenDialog: false));
      },
      onLongPress: () async {
        Navigator.push(
          this.tripListPageContext,
          MaterialPageRoute(
              builder: (context) => AddTripPage(selectedTrip),
              fullscreenDialog: true),
        ).then((value) {
          // ここで画面遷移から戻ってきたことを検知できる
//          model.getTrips();
        });
      },

//      onDoubleTap: () {
//        _scaffoldKey.currentState.showSnackBar(
//          SnackBar(
//            content: Text('You double tapped on ${index + 1}'),
//            duration: const Duration(seconds: 1),
//          ),
//        );
//      },
    );
  }
}
