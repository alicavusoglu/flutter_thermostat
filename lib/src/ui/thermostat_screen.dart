import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:thermostat/src/models/thermometer_value.dart';
import 'package:thermostat/src/ui/thermostat.dart';
import '../blocs/thermometer_bloc.dart';


class ThermostatScreen extends StatefulWidget {
  @override
  _ThermostatScreenState createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen> {
  IO.Socket socket ;

  static const textColor = const Color(0xFFFFFFFD);

  bool _turnOn;
  double room_state=0;

  StreamController<int> target_degree_stream_controller=StreamController<int>();

  @override
  void initState() {
    _turnOn = true;
    socket = IO.io('http://thermostat-server.herokuapp.com', <String, dynamic>{
      'transports': ['websocket'] // optional
    });
    socket.on('connect', (_) {
      print('connect');
    });
    socket.on('event', (data) => print(data));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    socket.on('room_state', (data) {
      setState(() {

        room_state=double.parse(data["value"]["\$numberDecimal"]);
        _turnOn=data["is_working"];
      });
    });
    socket.on('target_degree', (data) {
      setState(() {
        target_degree_stream_controller.sink.add(int.parse(data["value"]["\$numberDecimal"]));
      });
    });
    super.initState();



  }


  @override
  Widget build(BuildContext context) {
    bloc.fetchAllValues();
    return new Scaffold(
      body: new Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F2027),
          /*gradient: new LinearGradient(
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF2C5364),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),*/
        ),
        child: new SafeArea(
          child: new Column(
             crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                height: 52.0,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            'Home - Çavuşoğlu',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          new Text(
                            '',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 12.0,
                            ),
                          ),
                          new SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              new Expanded(
                child: new Center(
                  child: StreamBuilder<int>(
                    stream: target_degree_stream_controller.stream,
                    builder: (context, snapshot) {
                      if(!snapshot.hasData)
                        return new Container();
                      return new Thermostat(
                        radius: 150.0,
                        turnOn: _turnOn,
                        modeIcon: Icon(
                          Icons.wb_sunny,
                          color: Color(0xFF3CAEF4),
                        ),
                        textStyle: new TextStyle(
                          color: textColor,
                          fontSize: 34.0,
                        ),
                        minValue: 15,
                        maxValue: 28,
                        initialValue: snapshot.data,
                        onValueChanged: (value) {
                          final Map<String, dynamic> data = new Map<String, dynamic>();
                          data['value'] =value;
                          socket.emit('target_degree',data);
                        },
                      );
                    }
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new Container(
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new  Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.home,
                              color: const Color(0xFFA9A6AF),
                              size: 40.0,
                            )
                            ,
                            Text(room_state.toString()+ "°C",style: const TextStyle(
                              color: const Color(0xFFA9A6AF),
                              fontSize: 28.0,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Container(
                //width: double.infinity,
                height: 1.0,
                color: Colors.white.withOpacity(0.2),
              ),
              new Container(
                margin: EdgeInsets.symmetric(vertical: 24.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BottomButton(
                      icon: new Icon(
                        Icons.ac_unit,
                        color: _turnOn ? Color(0xFF4EC4EC) : Colors.white,
                      ),
                      text: 'Durdur',
                      onTap: () {
                        setState(() {




                          _turnOn = !_turnOn;
                        });
                      },
                    ),
//                    BottomButton(
//                      icon: new Icon(
//                        Icons.invert_colors,
//                        color: Colors.white,
//                      ),
//                      text: 'Fan',
//                    ),
                    BottomButton(
                      icon: new Icon(
                        Icons.schedule,
                        color: Colors.white,
                      ),
                      text: 'Haftalık Plan',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final Widget icon;
  final String text;

  const InfoIcon({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        icon,
        new SizedBox(width: 8.0),
        new Text(
          text,
          style: const TextStyle(
            color: const Color(0xFFA9A6AF),
            fontSize: 12.0,
          ),
        ),
        new SizedBox(width: 12.0),
      ],
    );
  }
}

class BottomButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const BottomButton({
    Key key,
    this.icon,
    this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onTap,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
            width: 52.0,
            height: 52.0,
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3F5BFA)),
            ),
            child: icon,
          ),
          new Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          )
        ],
      ),
    );
  }
}

bool almostEqual(double a, double b, double eps) {
  return (a - b).abs() < eps;
}

bool angleBetween(
    double angle1, double angle2, double minTolerance, double maxTolerance) {
  final diff = (angle1 - angle2).abs();
  return diff >= minTolerance && diff <= maxTolerance;
}
