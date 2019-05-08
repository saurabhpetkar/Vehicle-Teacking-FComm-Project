import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:location/location.dart' as geoloc;
import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../models/user.dart';
import '../models/auth.dart';
import '../models/news.dart';

class ConnectedModel extends Model {
  bool _isloading = false;
  User _authenticatedUser;
  double _latitude = 13.5567943;
  double _longitude = 80.025118;
  String ip_address = 'http://10.0.51.59:8000';
  String user_location = 'Chennai';
  String _selectedUrl = null;
  List<News> _news = [];
  int _index;
}

class UserModel extends ConnectedModel {
  Timer _authtimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  User get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      int phone, String username, String number_plate,
      [AuthMode _authmode = AuthMode.login]) async {
    _isloading = true;
    notifyListeners();

    String ip_address = 'http://127.0.0.1:8000/api/token/';
    final Map<String, dynamic> authdata_signup = {
      'email': email,
      'password': password,
      'phone_number': phone,
      'username': username,
      'number_plate': number_plate,
      'returnSecureToken': true,
    };

    final Map<String, dynamic> authdata_login = {
      'username': username,
      'password': password,
    };

    bool haserror = true;
    String message = 'incorrect data entered';
    print(authdata_signup);
    http.Response response;

    if (_authmode == AuthMode.login) {
      String link = ip_address;
      print('ye hai link ${link}');

      response = await http.post(
        link,
        body: json.encode(authdata_login),
        headers: {'Content-Type': 'application/json'},
      );
    }
// else {
//      String link = ip_address + '/auth/user/create/';
//
//      response = await http.post(
//        link,
//        body: json.encode(authdata_signup),
//        headers: {'Content-Type': 'application/json'},
//      );
//
//      if (response.statusCode != 400 || response.statusCode != 401) {
//        String link = ip_address + '/auth/token/obtain/';
//        response = await http.post(
//          link,
//          body: json.encode(authdata_login),
//          headers: {'Content-Type': 'application/json'},
//        );
//      }
//    }
    print('ye hai response ${json.decode(response.body)}');
    final Map<String, dynamic> responsedata = json.decode(response.body);
    print('ye hai status code ${response.statusCode}');

    if (response.statusCode != 400 && response.statusCode != 401) {
      haserror = false;
      _authenticatedUser = User(
        refresh: responsedata['refresh'],
        access: responsedata['access'],
        username: username,
      );

      setAuthTimeout(1 * 3600 * 24); //1day timeout in seconds
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: 1 * 3600 * 24)); //1 day in seconds

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('refresh', responsedata['refresh']);
      prefs.setString('username', username);
      prefs.setString('access', responsedata['access']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
      _userSubject.add(true);
    }

    _isloading = false;
    notifyListeners();
    return {'success': !haserror, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String access = prefs.getString('access');
    _userSubject.add(false);
    if (access != null) {
      //logged in
      final String expiryTime = prefs.getString('expiryTime');
      print('autoAuthenticate');
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTime);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      _authenticatedUser = User(
        access: prefs.getString('access'),
        refresh: prefs.getString('refresh'),
        username: prefs.getString('username'),
      );
      final int tokenlifespan = parsedExpiryTime.difference(now).inSeconds;
      setAuthTimeout(tokenlifespan);
      _userSubject.add(true);
      notifyListeners();
    }
    //logged out hai
  }

  void logout() async {
    print('logout ho raha hai');
    _authtimer.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access');
    prefs.remove('refresh');
    prefs.remove('username');
    _authenticatedUser = null;
    _userSubject.add(false);
    print('logout ho gaya');
  }

  void setAuthTimeout(int time) {
    _authtimer = Timer(Duration(seconds: time), () {
      logout();
      print('logout, automatic');
    });
  }
}

class NewsModel extends ConnectedModel {
  int no_of_news = 0;
  News selectednews;
  String selectedId;

  void selectNews(String id) {
    print('selectNews main');

    selectedId = id;
    print(id);
  }

  void setUrl(String url) {
    _selectedUrl = url;
  }

  String get selectedUrl {
    return _selectedUrl;
  }

  List<News> get allnews {
    return List.from(_news);
  }

  List<News> get displayNews {
    return List.from(_news);
  }

  void selectIndex(int index) {
    _index = index;
  }

  int get selectedIndex {
    return _index;
  }

  Future<Null> fetchNews() async {
    _isloading = true;
    notifyListeners();
    print('fetch ho raha hai');
    String link = 'http://127.0.0.1:8000/api/v1/articles';
    http.Response response;
    response = await http.get(
      link,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + _authenticatedUser.access
      },
    );
    print('this is the status ${response.statusCode}');
    print('print/fetch ho gaya!!');
    final List<News> fetchedProductList = [];
    final List productListData = json.decode(response.body);
    print('decode  ${productListData.length}');

    if (productListData == null) {
      print('fnull hai');

      _isloading = false;
      notifyListeners();
      return;
    }
    for (int i = 0; i < productListData.length; i++) {
      String old_desc = productListData[i]['description'];
      List<String> split_desc = old_desc.split('>');
      List<String> desc = split_desc[1].split('<');

      final News news = News(
        title: productListData[i]['title'],
        description: desc[0],
        url: productListData[i]['url'],
      );

      fetchedProductList.add(news);
    }

    _news = fetchedProductList;
    _isloading = false;
    notifyListeners();
  }
}

class Utilitymodel extends ConnectedModel {
  bool get isLoading {
    return _isloading;
  }
}

class Locationmodel extends ConnectedModel {
  void getAddress() async {
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_latitude},${_longitude}&key=AIzaSyAIJtykBRaxn1aNhQ5SR-k1aglZ65ghY6U';
    http.Response response = await http.get(url);

    Map<String, dynamic> decoded = json.decode(response.body);
    if (decoded['error_message'] != null) {
      print(response.body);
      print(
          'cant fetch your location, api key problem, default location set to Chennai');
      user_location = 'Chennai';
    } else {
      user_location =
          decoded['results'][0]['address_components'][3]['long_name'];
    }
  }

  void setLocation(double latitude, double longitude) {
    //print('setloc function called');
    if (latitude != null && longitude != null) {
      _latitude = latitude;
      _longitude = longitude;
    }
  }

  Future<Map<String, bool>> uploadImage(File image, String image_path) async {
    Map<String, bool> user_response = {'success': false};
    Map<String, String> headers = {
      "Authorization": "Bearer ${_authenticatedUser.access}"
    };
    var request = new http.MultipartRequest(
        "POST", Uri.parse(ip_address + '/api/start_tracking/image/'));
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image_path,
      contentType: new MediaType('image', 'jpg'),
    ));
    request.headers.addAll(headers);
    request.send().then((response) {
      print('\nresponse after image upload ${response.statusCode}\n');
      if (response.statusCode == 200 || response.statusCode == 201)
        user_response['success'] = true;
    });

    return user_response;
  }
}
