import 'package:flutter/material.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';

class TripFooter extends StatelessWidget {
  TripFooter(this.selectedTrip);
  Trip selectedTrip;
  @override
  Widget build(BuildContext context) {
    String eventAtMonth = '';
    String eventAtDate = '';
    if (selectedTrip != null) {
      List<String> eventAtList = selectedTrip.eventAt.split('-');
      eventAtMonth = eventAtList[1];
      eventAtDate = eventAtList[2];
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
//                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    selectedTrip != null ? selectedTrip.name : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.calendar_today,
            color: Colors.red,
          ),
          Text(
            '$eventAtMonth/$eventAtDate',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
