import 'package:flutter/material.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/switchType.dart';

class TotalPage extends StatelessWidget {
  TotalPage(this.items, this.members, this.switchType);
  List<Item> items;
  List<Member> members;
  String switchType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text(
          'Total $switchType',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black87,
        centerTitle: false,
        elevation: 0.0,
      ),
      body: ListView(
        children: _createTotalWidget(items),
      ),
    );
  }

  List<Card> _createTotalWidget(List<Item> items) {
    List<Card> resultListTile = [];
    int totalMoney = 0;
    for (Member member in members) {
      int moneyEachMember = 0;
      // 対象のメンバーのアイテムだけ抽出
      List<Item> itemsFilter =
          items.where((element) => element.memberId == member.id).toList();
      if (itemsFilter == null) {
        itemsFilter = [];
      }
      // 金額を加算
      itemsFilter.forEach((element) {
        moneyEachMember += element.money;
      });

      var widget = Card(
        child: ListTile(
          leading: Icon(Icons.person_outline_rounded),
          title: Text(member.name),
          trailing: Text('$moneyEachMember円'),
        ),
      );
      resultListTile.add(widget);
      totalMoney += moneyEachMember;
    }

    var totalWidget = Card(
      child: ListTile(
//        leading: Text('SUM'),
        title: Text('合計'),
        trailing: Text('$totalMoney円'),
      ),
    );
    resultListTile.insert(0, totalWidget);

    return resultListTile;
  }
}
