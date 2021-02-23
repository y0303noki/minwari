import 'package:flutter/material.dart';
import 'package:trip_money_local/home/home.dart';
import 'package:trip_money_local/member/member_list_page.dart';
import 'package:trip_money_local/trip/trip_list_page.dart';

import 'footer_navigation_model.dart';

class Footer extends StatelessWidget {
  FooterNavigationService footerNavigationService = FooterNavigationService();
  int _selectedIndex = 0;
  String footerType;
  @override
  Widget build(BuildContext context) {
    footerType = this.footerNavigationService.getFooterType();
    if (footerType == null) {
      footerType = 'Home';
    }
    return BottomNavigationBar(
//      backgroundColor: Colors.green.withOpacity(0.3),
      fixedColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: footerType == 'Home' ? Colors.blue : Colors.grey,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: footerType == 'Member' ? Colors.blue : Colors.grey,
          ),
          label: 'Member',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.leave_bags_at_home,
            color: footerType == 'Trip' ? Colors.blue : Colors.grey,
          ),
          label: 'Event',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (int index) {
        _selectedIndex = index;
        if (index == 0) {
          this.footerNavigationService.setFooterType('Home');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => HomePage(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        } else if (index == 1) {
          this.footerNavigationService.setFooterType('Member');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  MemberListPage(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        } else if (index == 2) {
          this.footerNavigationService.setFooterType('Trip');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => TripListPage(),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        }

        footerType = footerNavigationService.getFooterType();
        print(footerType);
      },
    );
  }

  _onItemTapped(int index, BuildContext context) {
    if (index == 0) {
      this.footerNavigationService.setFooterType('Home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(), fullscreenDialog: false),
      );
    } else if (index == 1) {
      this.footerNavigationService.setFooterType('Member');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MemberListPage(), fullscreenDialog: false),
      );
    } else if (index == 2) {
      this.footerNavigationService.setFooterType('Trip');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TripListPage(), fullscreenDialog: false),
      );
    }

    footerType = footerNavigationService.getFooterType();
  }
}
