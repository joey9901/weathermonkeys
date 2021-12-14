import 'settings_page.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(WeatherMonkeysApp());

// Main App (Stateless)
class WeatherMonkeysApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Monkeys',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Graph Screen'),
    );
  }
}

// HomePage with State (Stateful)
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// Home Page State
class _MyHomePageState extends State<MyHomePage> {

  //int interval_to_display = 365;

  // List + Addition for Temperature Sensor Data
  List<lopy_sensor> temperature_sensor = [/*interval_to_display*/]; // blank initially

  List<lopy_sensor> _createTemperatureDataList() {
  temperature_sensor.add(new lopy_sensor(new DateTime.now(), parse_lopy_temperature()));
  return temperature_sensor;
  }

  // List + Addition for Light Sensor Data
  List<lopy_sensor> light_sensor = [/*interval_to_display*/]; // blank initially

  List<lopy_sensor> _createLightDataList() {
  temperature_sensor.add(new lopy_sensor(new DateTime.now(), parse_lopy_light()));
  return pressure_sensor;
  }

  // List + Addition Function for Pressure Sensor Data
  List<lopy_sensor> pressure_sensor = [/*interval_to_display*/]; // blank initially

  List<lopy_sensor> _createPressureDataList() {
  temperature_sensor.add(new lopy_sensor(new DateTime.now(), parse_lopy_pressure()));
  return pressure_sensor;
  }

  // Refresh State function
  void _refreshData(/*int m_interval*/) {
    setState(() {
      _createTemperatureDataList();
      _createLightDataList();
      _createPressureDataList();
      //interval_to_display = m_interval;
    });
  }

  // Home Page State Widget
  @override
  Widget build(BuildContext context)
  {
    // Generating list of Graph Series to display
    List<charts.Series<lopy_sensor, DateTime>> _createSampleData()
    {
      final temperature_data = _createTemperatureDataList();

      final light_data = _createLightDataList();

      final pressure_data = _createPressureDataList();

      return [
        new charts.Series(
          id: 'Temperature',
          colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
          areaColorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault.lighter,
          domainFn: (lopy_sensor lopy, _) => lopy.m_time,
          measureFn: (lopy_sensor lopy, _) => lopy.m_sensorData,
          data: temperature_data,
        ),
        // new charts.Series(
        //   id: 'Light',
        //   colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        //   areaColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault.lighter,
        //   domainFn: (lopy_sensor lopy, _) => lopy.m_time,
        //   measureFn: (lopy_sensor lopy, _) => lopy.m_sensorData,
        //   data: light_data,
        // ),
        new charts.Series(
          id: 'Pressure',
          colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
          areaColorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault.lighter,
          domainFn: (lopy_sensor lopy, _) => lopy.m_time,
          measureFn: (lopy_sensor lopy, _) => lopy.m_sensorData,
          data: pressure_data,
        ),
      ];
    }
    var chart = charts.TimeSeriesChart(_createSampleData(), animate: true, defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: true), dateTimeFactory: const charts.LocalDateTimeFactory(),);
    // Creating Chart Child-Widget
    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 400.0,
        child: chart,
      ),
    );

    // Returning Appbar as a Widget for our Home Page
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Monkeys", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SettingsPage()), (Route<dynamic> route) => false);
            },
            child: Text("Change Settings", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
      Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white70, Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              chartWidget,
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child:  RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 165),
                      child: new Text("Hour"),
                      onPressed: _refreshData,
                      color:  Colors.deepPurple,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child:  RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 165),
                      child: new Text("Day"),
                      onPressed: _refreshData,
                      color:  Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child:  RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 165),
                      child: new Text("Month"),
                      onPressed: _refreshData,
                      color:  Colors.deepPurple,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child:  RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 160),
                      child: new Text("Year"),
                      onPressed: _refreshData,
                      color:  Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh Data',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

// Custom Structure for sensor data
class lopy_sensor{
  final DateTime m_time;
  final double m_sensorData;

  lopy_sensor(this.m_time, this.m_sensorData);
}


// Unfinished sections with Data Parse
double vasia = 2.0;

double parse_lopy_temperature () {
  vasia = vasia + 3;
  return vasia;
}

double parse_lopy_light () {
  vasia = vasia + 5;
  return vasia;
}

double parse_lopy_pressure () {
  vasia = vasia + 7;
  return vasia;
}

// TODO: Implement Parsing Function
// Future parse_data(String mode) async {
//   // Open a connection (testdb should already exist)
//   final conn = await MySqlConnection.connect(ConnectionSettings(
//       host: '192.168.43.247',
//       port: 3306,
//       user: 'joey_9901',
//       db: 'wmdb',
//       password: 'joey_9901'));
//
//   // Insert some data
//   var result = await conn.query(
//       'insert into users (name, email, age) values (?, ?, ?)',
//       ['Bob', 'bob@bob.com', 25]);
//   print('Inserted row id=${result.insertId}');
//
//   // Finally, close the connection
//   await conn.close();
// }
