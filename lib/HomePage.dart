import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Map<String, dynamic> data = {};
  bool isLoading = true;
  var format = NumberFormat('#,###');

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    isLoading = true;
    setState(() {
      _fetchData();
    });

    _refreshController.refreshCompleted();
  }

  _fetchData() async {
    Uri url = Uri.parse('https://covid19.th-stat.com/api/open/today');
    http.Response response = await http.get(url);

    if (response.statusCode == HttpStatus.ok) {
      var json = convert.jsonDecode(response.body);
      setState(() {
        data = json;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () => _onRefresh())
        ],
        centerTitle: true,
        title: Text('รายงานสถานการณ์ โควิด-19'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(backgroundColor: Colors.amber),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: isLoading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'อัพเดทข้อมูลล่าสุด ${data['UpdateDate']}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.pink),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Text(
                                'ติดเชื้อสะสม ${format.format(data['Confirmed'])}',
                                style: textStyle,
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              child: Text(
                                'ติดเชื้อวันนี้ : ${format.format(data['NewConfirmed'])}',
                                style: textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green[900],
                            ),
                            height: 150,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Column(
                                  children: [
                                    Text('หายแล้ว ', style: textStyle),
                                    Text('${format.format(data['Recovered'])}',
                                        style: textStyle),
                                  ],
                                ),
                                Positioned(
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      Text('วันนี้', style: textStyle),
                                      Text(
                                          '[+${format.format(data['NewRecovered'])}]',
                                          style: textStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.lightBlue[300]),
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'รักษาอยู่ใน รพ.',
                                  style: textStyle,
                                ),
                                Text('${format.format(data['Hospitalized'])}',
                                    style: textStyle)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black54),
                            height: 150,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'เสียชีวิต',
                                      style: textStyle,
                                    ),
                                    Text('${format.format(data['Deaths'])}',
                                        style: textStyle)
                                  ],
                                ),
                                Positioned(
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      Text('วันนี้', style: textStyle),
                                      Text(
                                          '[+${format.format(data['NewDeaths'])}]',
                                          style: textStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  TextStyle textStyle =
      TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
}
