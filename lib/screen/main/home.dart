
import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/createInc.dart';
import 'package:actim/screen/main/drawer.dart';
import 'package:actim/screen/tabs/incopen.dart';
import 'package:actim/screen/tabs/incall.dart';
import 'package:actim/screen/tabs/incclosed.dart';
import 'package:actim/screen/tabs/incinvalid.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final storage = new FlutterSecureStorage();
  int _selectedIndex = 0;
  String role;
  String email;


  @override
  void initState() {
    super.initState();
    //_chekLocalStorageData();
  }

/////////
  Future _navigateToCreateInc(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateIncScreen()));
  }

////
  List<IconData> _icons = [
    Icons.shopping_basket,
    Icons.people,
    Icons.games,
    Icons.games,
  ];

  List<Text> _text = [
    Text(
      'All',
      style: TextStyle(
          fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
    ),
    Text(
      'Open',
      style: TextStyle(
          fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
    ),
    Text(
      'Closed',
      style: TextStyle(
          fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
    ),
    Text(
      'Invalid',
      style: TextStyle(
          fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
    ),
  ];

  /////
  Widget _buildTabContainer(int index) {
    if (index == 0) {
      return IncAllScreen();
    } else if (index == 1) {
      return IncOpenScreen();
    } else if (index == 2) {
      return IncClosedScreen();
    } else if (index == 3) {
      return IncInvalidScreen();
    } else {
      return Container(
        child: Text('No Tab Selected'),
      );
    }
  }

  Widget _buildicon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
              color: _selectedIndex == index
                  ? AppColors.PRIMARY_COLOR_LIGHT
                  : AppColors.PRIMARY_COLOR_DARK,
              borderRadius: BorderRadius.circular(0.0)),
          child: Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _icons[index],
                  color: Colors.white,
                  size: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _text[index],
                )
              ],
            ),
          )),
        ),
      ),
    );
  }

  ////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: DrawerScreen(),
      body: Container(
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _icons
                    .asMap()
                    .entries
                    .map(
                      (MapEntry map) => _buildicon(map.key),
                    )
                    .toList(),
              ),
            ),
            _buildTabContainer(_selectedIndex)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: role == "Support"
          ? Container()
          : FloatingActionButton.extended(
              heroTag: "btn1",
              backgroundColor: AppColors.PRIMARY_COLOR_LIGHT,
              elevation: 3.0,
              icon: const Icon(Icons.add),
              label: const Text('Create An Incident'),
              onPressed: () {
                _navigateToCreateInc(context);
              },
            ),
    );
  }
}
