import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/tutorial/tutorial_model.page.dart';

enum Answers { OK, CANCEL }

class TutorialPage extends StatelessWidget {
  List<Stack> stackList = [];
  int stackCount = 6;
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    TextStyle messageStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Theme.of(context).textTheme.bodyText1.color,
    );

    for (int i = 0; i < stackCount; i++) {
      // ドットのicon作成
      List<Icon> icons = new List<Icon>();
      for (int l = 0; l < stackCount; l++) {
        Icon icon;
        // 対象の番号だけアイコンを黒くする
        if (i == l) {
          icon = Icon(
            Icons.circle,
            color: Colors.black,
            size: 10,
          );
        } else {
          icon = Icon(
            Icons.circle,
            color: Colors.grey,
            size: 10,
          );
        }
        icons.add(icon);
      }

      String message = '';
      if (i == 0) {
        message = 'Eventタブから新しいイベントを作成します';
      } else if (i == 1) {
        message = 'Memberタブから参加する人を自由に登録します';
      } else if (i == 2) {
        message = 'Homeタブから新しいタスクを登録します';
      } else if (i == 3) {
        message = 'TODOのタスクは右スワイプでDONEに移動します。';
      } else if (i == 4) {
        message = 'DONEのタスクは右スワイプでTODOに移動します。';
      } else if (i == 5) {
        message = '左にスワイプすると削除します。';
      }

      Stack static = Stack(children: [
        Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Container(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'images/tutorial$i.png',
                    height: size.height * 0.6,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle,
            ),
          ),
        ]),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: icons,
            ),
          ),
        ),
      ]);

      stackList.add(static);
    }

    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text(
          '操作説明',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
//            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ChangeNotifierProvider<TutorialModel>(
        create: (_) => TutorialModel(),
        child:
            Consumer<TutorialModel>(builder: (consumerContext, model, child) {
          return Stack(
            children: [
              stackList[currentIndex],
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 80),
                      child: Center(
                        child: Container(
                          child: IconButton(
                            iconSize: 50,
                            onPressed: currentIndex <= 0
                                ? null
                                : () {
                                    currentIndex--;

                                    model.reNotifyListeners();
                                  },
                            color: Colors.blue,
                            icon: Icon(
                              Icons.arrow_back_ios,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 80),
                      child: Center(
                        child: Container(
                          child: IconButton(
                            iconSize: 50,
                            onPressed: currentIndex >= stackCount - 1
                                ? null
                                : () {
                                    currentIndex++;
                                    model.reNotifyListeners();
                                  },
                            color: Colors.blue,
                            icon: Icon(
                              Icons.arrow_forward_ios,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
