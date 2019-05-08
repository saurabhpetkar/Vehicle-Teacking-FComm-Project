import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import './pages/auth.dart';
import './pages/home.dart';
import './pages/analysis.dart';
import './pages/news.dart';



import './scoped_models/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  Map<String, double> currentLocation = Map();
  StreamSubscription<Map<String, double>> locationSubscription;
  Location location = Location();
  String error;

  void initState() {
    super.initState();
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
          currentLocation = result;
          _model.setLocation(currentLocation['latitude'], currentLocation['longitude']);

    });
  }

  void initPlatformState() async {
    Future<Map<String, double>> my_location;
    try {
      var my_loc = await location.getLocation;
      print(my_loc);
      error = "";
      print(my_location.runtimeType);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
        error = 'permission denied';
      else if (e.code == 'PERMISSION_DENIED_NEVER_ASK')
        error = 'permission denied - please ask the blah';
      my_location = null;
      print('this is location${my_location}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.black,
        ),

        home:  !_isAuthenticated ? AuthPage() : HomePage(_model),
        routes: {
          '/analysis': (BuildContext context) => !_isAuthenticated ? AuthPage() : AnalysisPage(_model),
          '/news': (BuildContext context) =>
          !_isAuthenticated ? AuthPage() : !_isAuthenticated ? AuthPage() : NewsPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
//          final List<String> pathElements = settings.name.split('/');
//          if (pathElements[0] != '') {
//            return null;
//          }
//          if (pathElements[1] == 'news_detail') {
//            final String newsid = pathElements[2];
//            _model.selectNews(newsid);
//            return MaterialPageRoute(
//                builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : NewsDetailPage());
//          }
//          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => !_isAuthenticated
                ? AuthPage()
                : Center(
                    child: Text('you are home'),
                  ),
          );
        },
      ),
    );
  }
}

