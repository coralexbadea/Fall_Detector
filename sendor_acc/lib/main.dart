import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() => runApp(AccelerometerApp());

class AccelerometerApp extends StatefulWidget {
  @override
  _AccelerometerAppState createState() => _AccelerometerAppState();
}

class _AccelerometerAppState extends State<AccelerometerApp> {
  AccelerometerEvent? _accelerometerEvent;
  String? _prediction;
  bool _showingWarning = false;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) async {
      if (!_showingWarning) {
        final response = await http.post(
          Uri.parse('http://192.168.1.200:5000/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'x': event.x,
            'y': event.y,
            'z': event.z,
          }),
        );
        if (int.parse(response.body) == 0) {
          debugPrint(response.body);
          _showWarning();
        }
        setState(() {
          _accelerometerEvent = event;
          _prediction = response.body;
        });
      }
    });
  }

  void _showWarning() {
    _showingWarning = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accelerometer App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Accelerometer App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _accelerometerEvent != null
                    ? 'Accelerometer Values:\n\nX: ${_accelerometerEvent!.x.toStringAsFixed(2)}\nY: ${_accelerometerEvent!.y.toStringAsFixed(2)}\nZ: ${_accelerometerEvent!.z.toStringAsFixed(2)}'
                    : 'Waiting for accelerometer values...',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                _prediction ?? '',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              _showingWarning
                  ? Column(children: [
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Fall!',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.green,
                            ),
                          )),
                      ElevatedButton(
                        onPressed: () {
                          _showingWarning = false;
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ])
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
