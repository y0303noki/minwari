import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:trip_money_local/trip/trip_list_page.dart';

enum Answers { OK, CANCEL }

class AddTripPage extends StatelessWidget {
//  List<Widget> listTiles = [];
  final tripNameEditingController = TextEditingController();
  final tripMemoEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      home: ChangeNotifierProvider<AddUpdateTripModel>(
        create: (_) => AddUpdateTripModel(),
        child: Consumer<AddUpdateTripModel>(
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
                  Text('旅行を追加'),
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
                    child: Text('追加する'),
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
        name: model.name, memo: model.memo, updatedAt: now, createdAt: now);
    await model.addTrip(newTrip);
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
