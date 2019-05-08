import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../models/news.dart';

import '../widgets/logout.dart';
import '../widgets/newscard.dart';
import '../widgets/loaders/loader_1.dart';

class NewsPage extends StatefulWidget {
  final MainModel model;

  NewsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewsPageState();
  }
}

class _NewsPageState extends State<NewsPage> {
  Widget drawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('choose'),
          ),

          ListTile(

            leading:  Icon(Icons.arrow_back),
            title: Text('home Page'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<News> news) {
    print(news.length);
    if (news.length > 0) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            NewsCard(news[index], index),
        itemCount: news.length,
      );
    } else {
      return Container(
        child: Center(
          child: Text('no news found'),
        ),
      );
    }
  }

  Widget _news() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: ColorLoader2())
            : _buildNewsList(model.displayNews);
      },
    );
  }

  @override
  void initState() {
    widget.model.fetchNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: () {
          print('back button presses');
          Navigator.pop(context, false);
          return Future.value(false);
          //true, true closes the app
          //true, false goes back but deletes the product.
          //false, true closes the app
          //false, false goes back, product saved.
          //remove navigator.pop statement(false), no back allowed
          //remove navigator.pop statement(true), back allowed, but null returned
          //remove return (false), back allowed, but null returned
          //remove return (true), back allowed, product deleted.
        },
        child: Scaffold(
          drawer: drawer(),
          appBar: AppBar(
            title: Text('news page'),
          ),
          body: _news(),
        ));
  }
}
