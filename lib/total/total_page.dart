import 'package:flutter/material.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';

class TotalPage extends StatelessWidget {
  TotalPage(this.items, this.members);
  List<Item> items;
  List<Member> members;
  @override
  Widget build(BuildContext context) {
    items.forEach((element) {
      print(element.title);
    });
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text(
          'Total',
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
          trailing: Text('$moneyEachMember'),
        ),
      );
      resultListTile.add(widget);
      totalMoney += moneyEachMember;
    }

    var totalWidget = Card(
      child: ListTile(
        title: Text('全ての合計'),
        subtitle: Text('$totalMoney'),
      ),
    );
    resultListTile.insert(0, totalWidget);

    return resultListTile;
  }
}
