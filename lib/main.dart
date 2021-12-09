import 'settings_page.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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

class lopy_sensor {
  final DateTime m_time;
  final double m_sensorData;

  lopy_sensor(this.m_time, this.m_sensorData);
}

double vasia = 2.0;

double parse_Lopy () {
  vasia = vasia + 3;
  return vasia;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context)
  {
    List<charts.Series<lopy_sensor, DateTime>> _createSampleData()
    {
      final data = [
        new lopy_sensor(new DateTime(2021, 12, 5), parse_Lopy()),
        new lopy_sensor(new DateTime(2021, 12, 6), parse_Lopy()),
        new lopy_sensor(new DateTime(2021, 12, 7), parse_Lopy()),
        new lopy_sensor(new DateTime.now(), parse_Lopy()),
      ];

      return [
        new charts.Series(
          id: 'Lopy',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (lopy_sensor lopy, _) => lopy.m_time,
          measureFn: (lopy_sensor lopy, _) => lopy.m_sensorData,
          // When the measureLowerBoundFn and measureUpperBoundFn is defined,
          // the line renderer will render the area around the bounds.
          // measureLowerBoundFn: (TimeSeriesSales sales, _) => sales.sales - 5,
          // measureUpperBoundFn: (TimeSeriesSales sales, _) => sales.sales + 5,
          data: data,
        )
      ];
    }

    var chart = charts.TimeSeriesChart(_createSampleData(), animate: true,);

    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 400.0,
        child: chart,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Home Page", style: TextStyle(color: Colors.white)),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              chartWidget,
            ],
          )
      ),
    );
  }
}

