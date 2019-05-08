import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

class CarListPage extends StatefulWidget {
  final MainModel model;

  CarListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CarListPageState();
  }
}

class _CarListPageState extends State<CarListPage> {
  List<String> allCars = ['car1', 'car2', 'car3'];

  @override
  initState() {
    //widget.model.fetchCars();
    super.initState();
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car list',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(allCars[index]),
                  onDismissed: (DismissDirection direction) {
                    if (direction == DismissDirection.startToEnd ||
                        direction == DismissDirection.endToStart) {
//                    model.selectProduct(model.allProducts[index].product_id);
//                    model.deleteproduct();
                      allCars.removeAt(index);
                    }
                  },
                  background: Container(
                    color: Colors.greenAccent,
                    child: Icon(
                      Icons.delete,
                      size: 70.0,
                      color: Colors.white,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 12.5,
                      ),
                      Text(allCars[index], style: TextStyle(fontSize: 20.0),),
                      SizedBox(
                        height: 3.0,
                      ),
                  FlatButton(
                    child: Text('details'),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/car_detail/' + allCars[index]);
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0)),
                  ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Divider(
                        height: 1.25,
                      ),

                    ],
                  ),
                );
              },
              itemCount: allCars.length,
            ),
      ),
    );
  }
}
