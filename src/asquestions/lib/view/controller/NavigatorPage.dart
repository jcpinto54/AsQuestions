import 'package:asquestions/controller/CloudFirestoreController.dart';
import 'package:asquestions/view/pages/ConferenceQuestionsPage.dart';
import 'package:asquestions/view/pages/HomePage.dart';
import 'package:asquestions/view/pages/UserProfilePage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NavigatorPage extends StatefulWidget {
  final CloudFirestoreController _firestore;

  NavigatorPage(this._firestore);

  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  DocumentReference _userReference;
  bool showLoadingIndicator = false;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    this.refreshModel(true);
  }

  Future<void> refreshModel(bool showIndicator) async {
    Stopwatch sw = Stopwatch()..start();
    setState(() {
      showLoadingIndicator = showIndicator;
    });
    _userReference = await widget._firestore.getUserReferenceByUsername("Username1");
    if (this.mounted)
      setState(() {
        showLoadingIndicator = false;
      });
    print("User Reference fetch time: " + sw.elapsed.toString());
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    PageController _pageController = PageController();
    List<Widget> _screens = [
      HomePage(),
      ConferenceQuestionsPage(widget._firestore),
      UserProfilePage(widget._firestore, _userReference)
    ];

    void _onPageChanged(int index) {
      _pageController.jumpToPage(index);
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blue,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.blue,
        animationDuration: Duration(milliseconds: 300),
        height: 50,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(_currentIndex);
          });
        },
        items: <Widget>[
          Icon(Icons.home_rounded, size: 30, color: Colors.white),
          Icon(Icons.question_answer_rounded, size: 30, color: Colors.white),
          Icon(Icons.person_rounded, size: 30, color: Colors.white)
        ],
      ),
    );
  }
}
