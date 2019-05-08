import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';


import '../scoped_models/main.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News single_news;
  final int index;

  NewsCard(this.single_news, this.index);

  Future _launchURL(String url) async {
    if(await canLaunch(url)){
      launch(url, forceSafariVC: true, forceWebView: true);
    }else{
      print('cant launch ${url}');
    }
  }

  showlink(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('a different page'),
            content: Text('a webpage'),
            actions: <Widget>[
              FlatButton(
                child: Text('discard'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('delete'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
              single_news.title,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
          ),
          ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
                return FlatButton(
                  child: Text('details'),
                  color: Colors.green,
                  onPressed: () {
                    model.setUrl(single_news.url);
                    _launchURL(single_news.url);
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0)),
                );
              }),
        ],
      ),
    );
  }
}
