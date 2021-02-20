import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:uuid/uuid.dart';

import 'member_list_page.dart';

enum Answers { OK, CANCEL }

class AddMemberPage extends StatelessWidget {
  AddMemberPage(this.member);
  Member member;
  final memberNameEditingController = TextEditingController();
  final colorNameEditingController = TextEditingController();
  final memberMemoEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isUpdate = member != null;
    if (isUpdate) {
      memberNameEditingController.text = member.name;
      memberMemoEditingController.text = member.memo;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // <- Debug の 表示を OFF
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ChangeNotifierProvider<AddUpdateMemberModel>(
        create: (_) => AddUpdateMemberModel(),
        child: Consumer<AddUpdateMemberModel>(
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
//                          builder: (context) => MemberListPage(),
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
                  Text(isUpdate ? 'メンバーを更新' : 'メンバー追加'),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '名前',
                    ),
                    controller: memberNameEditingController,
                  ),
                  // メンバーごとに色つけたい
//                  TextField(
//                    readOnly: true,
//                    decoration: InputDecoration(
//                      labelText: '色',
//                    ),
//                    controller: colorNameEditingController,
//                    onTap: () async {
//                      final tes = await _askedToLead(context);
//                      print(tes);
//                    },
//                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'メモとか'),
                    controller: memberMemoEditingController,
                  ),
                  TextButton(
                    child: Text(isUpdate ? '更新' : '追加'),
                    onPressed: () async {
                      model.name = memberNameEditingController.text;
                      model.memo = memberMemoEditingController.text;
                      if (isUpdate) {
                        await updateMember(model, context, member);
                      } else {
                        await addMember(model, context);
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

Future addMember(AddUpdateMemberModel model, BuildContext context) async {
  try {
    final String now = DateTime.now().toString();
    final Member newMember = Member(
        id: Uuid().v1(),
        tripId: null,
        name: model.name,
        memo: model.memo,
        createdAt: now,
        updatedAt: now);
    await model.addMember(newMember);
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

Future updateMember(AddUpdateMemberModel model, BuildContext context,
    Member updateMember) async {
  try {
    final String now = DateTime.now().toString();
    updateMember.name = model.name;
    updateMember.memo = model.memo;
    updateMember.updatedAt = now;
    await model.updateMember(updateMember);
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

enum COLOR { BLUE, RED, PINK, ORANGE, YELLOW, PURPLE, BLACK, GREY }

//void openDialog(BuildContext context) {
//  List<SimpleDialogOption> test = [];
//  for (var color in COLOR.values) {
//    var aaa;
//    switch (color) {
//      case COLOR.BLUE:
//        aaa = Colors.blue;
//        break;
//      case COLOR.RED:
//        aaa = Colors.red;
//        break;
//      case COLOR.PINK:
//        aaa = Colors.pink;
//        break;
//      case COLOR.ORANGE:
//        aaa = Colors.orange;
//        break;
//      case COLOR.YELLOW:
//        aaa = Colors.yellow;
//        break;
//      case COLOR.PURPLE:
//        aaa = Colors.purple;
//        break;
//      case COLOR.BLACK:
//        aaa = Colors.black;
//        break;
//      case COLOR.GREY:
//        aaa = Colors.grey;
//        break;
//      default:
//        aaa = Colors.grey;
//        break;
//    }
//    var dialog = SimpleDialogOption(
//      child: Icon(
//        Icons.circle,
//        color: aaa,
//      ),
//      onPressed: () {
////            Navigator.pop(context, 'OK');
//        print(aaa);
//      },
//    );
//    test.add(dialog);
//  }
//  showDialog<COLOR>(
//    context: context,
//    builder: (BuildContext context) => AlertDialog(
//      title: Text('色を選んでください'),
//      actions: test,
//    ),
//  ).then((value) async {
//    switch (value) {
//      case COLOR.BLUE:
//        break;
//      case COLOR.RED:
//        break;
//    }
//  });
//}
//
//createDialogOption(BuildContext context, Answers answer, String str) {
//  return new SimpleDialogOption(
//    child: new Text(str),
//    onPressed: () {
//      Navigator.pop(context, answer);
//    },
//  );
//}

Future<String> _askedToLead(BuildContext context) async {
  List<SimpleDialogOption> test = [];
  for (var color in COLOR.values) {
    var aaa;
    switch (color) {
      case COLOR.BLUE:
        aaa = Colors.blue;
        break;
      case COLOR.RED:
        aaa = Colors.red;
        break;
      case COLOR.PINK:
        aaa = Colors.pink;
        break;
      case COLOR.ORANGE:
        aaa = Colors.orange;
        break;
      case COLOR.YELLOW:
        aaa = Colors.yellow;
        break;
      case COLOR.PURPLE:
        aaa = Colors.purple;
        break;
      case COLOR.BLACK:
        aaa = Colors.black;
        break;
      case COLOR.GREY:
        aaa = Colors.grey;
        break;
      default:
        aaa = Colors.grey;
        break;
    }
    var dialog = SimpleDialogOption(
      child: Icon(
        Icons.crop_square_rounded,
        color: aaa,
      ),
      onPressed: () {
//            Navigator.pop(context, 'OK');
        Navigator.pop(context, aaa.toString());
      },
    );
    test.add(dialog);
  }

  switch (await showDialog<COLOR>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SimpleDialog(
            title: const Text('Select assignment'),
            children: test,
          ),
        );
      })) {
    case COLOR.BLUE:
      // Let's go.
      // ...
      break;
    case COLOR.RED:
      // ...
      break;
  }
}
