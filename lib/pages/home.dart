import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scoped_model/scoped_model.dart';


import '../scoped_models/main.dart';



import '../widgets/logout.dart';
import '../widgets/home_items.dart';


class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

Widget drawer() {
  return Drawer(
    child: Column(
      children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          title: Text('choose'),
        ),
        Divider(),
        LogoutListTile(),
      ],
    ),
  );
}

class _HomePageState extends State<HomePage> {

  void initState(){
    super.initState();
    widget.model.getAddress();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StaggeredGridView.count(
        //home page
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          myItems(Icons.pie_chart, 'analysis', 0xff3399fe, '/analysis'),
          myItems(Icons.list, 'news', 0xff26cb3c, '/news'),

        ],
        staggeredTiles: [
          StaggeredTile.extent(1, 350.0),
          StaggeredTile.extent(1, 350.0),


        ],
      ),
    );
  }
}
