import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(WorldClock());
}

class WorldClock extends StatelessWidget {
  const WorldClock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      home: Clock(),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  List _timezones = [];
  List _filtertimezones = [];
  bool isSearching = false;
  getTimezones() async {
    try {
      var response = await Dio().get('http://worldtimeapi.org/api/timezone');
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> getTime(String area) async {
    try {
      var response =
          await Dio().get("http://worldtimeapi.org/api/timezone/$area");
      print(response.data['datetime']);
      return response.data['datetime'];
    } catch (e) {
      print(e);
      return "";
    }
  }

  @override
  void initState() {
    getTimezones().then((data) {
      setState(() {
        _timezones = _filtertimezones = data;
      });
    });
    super.initState();
  }

  void _filterTimezone(value) {
    setState(() {
      _filtertimezones = _timezones
          .where((zone) => zone
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .toList();
    });
  }

  Widget _secondPage(String data) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Time')),
      ),
      body: Container(
        child: FutureBuilder(
            future: getTime(data),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                var b = snapshot.data?.split("T");
                var c = b![0].split("-");
                var d = b[1].split(":");
                var date = DateTime(int.parse(c[0]), int.parse(c[1]),
                    int.parse(c[2]), int.parse(d[0]), int.parse(d[1]), 1);
                return Center(
                    child: AnalogClock(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3.0, color: Colors.black),
                      color: Colors.black,
                      shape: BoxShape.circle),
                  width: 200.0,
                  isLive: false,
                  hourHandColor: Colors.white,
                  minuteHandColor: Colors.white,
                  showSecondHand: true,
                  numberColor: Colors.white,
                  showNumbers: true,
                  textScaleFactor: 1.5,
                  showTicks: true,
                  showDigitalClock: true,
                  digitalClockColor: Colors.white,
                  datetime: date,
                ));
              } else {
                return Center(
                    child: SpinKitRotatingCircle(
                  color: Colors.blue,
                  size: 50.0,
                ));
              }
            }),
      ),
    );
  }

  Widget _buildList(List data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(child: Text(data[index])),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => _secondPage(data[index])));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: !isSearching
                ? Text('Timezones')
                : TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.white),
                        hintText: "Search Timezone Here",
                        hintStyle: TextStyle(color: Colors.white)),
                    onChanged: (value) {
                      _filterTimezone(value);
                    },
                  )),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      _filtertimezones = _timezones;
                    });
                  },
                  icon: Icon(Icons.cancel))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      
                    });
                  },
                  icon: Icon(Icons.search))
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: _filtertimezones.length > 0
              ? _buildList(_filtertimezones)
              : Center(
                  child: SpinKitRotatingCircle(
                  color: Colors.blue,
                  size: 50.0,
                ))),
    );
  }
}
