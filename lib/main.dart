import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';


void main() => runApp(WeatherMonkeysApp());

// creating the custom color (base color) for the app
Map<int, Color> color ={50:Color.fromRGBO(136,14,79, .1),100:Color.fromRGBO(136,14,79, .2),200:Color.fromRGBO(136,14,79, .3),300:Color.fromRGBO(136,14,79, .4),400:Color.fromRGBO(136,14,79, .5),500:Color.fromRGBO(136,14,79, .6),600:Color.fromRGBO(136,14,79, .7),700:Color.fromRGBO(136,14,79, .8),800:Color.fromRGBO(136,14,79, .9),900:Color.fromRGBO(136,14,79, 1),};
MaterialColor colorCustom = MaterialColor(0xFF115363, color);


// Main App (Stateless)
class WeatherMonkeysApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Monkeys',
      theme: ThemeData(
        primarySwatch: colorCustom,
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

Future getData(String table, String date) async {
  date = Uri.encodeComponent(date);
  final response = await http.get(
      Uri.parse("http://217.123.63.98/test3.php?table=${table}&date=${date}"),
          headers: {
            "Accept": "application/json",
            "Access-Control_Allow_Origin": "*"
          });

  if(response.statusCode == 200) {

    print(response.body);

    var jsonresponse = response.body;
    List<dynamic> decodedjson = jsonDecode(jsonresponse);

    // if (table == "lopy" || table == "dragino") {
    //   for (var i in decodedjson) {
    //     print('${i["received_time"]}');
    //   }
    // } else {
    //   print('${decodedjson}');
    // }

    return decodedjson;

  } else {
    throw Exception('Bad response');
  }
}

Future<List> parse_lopy_temperature(String table, String date) async {
  List decodedjson = await getData(table, date);
  List<String> timeList = [];
  List<double> temperatureList = [];
  for (var i in decodedjson){
    timeList.add(i["received_time"]);
    double temperature = double.parse(i["temperature"]);
    temperatureList.add(temperature);
    TempData(i["received_time"], temperature);
  }
  return await [timeList, temperatureList];
}

// Home Page State
class _MyHomePageState extends State<MyHomePage> {

  int _selectedPage = 0;

  final PageController _pageController = PageController(
  );

  void _changePage(int pageNum) {
    setState(() {
      _selectedPage = pageNum;
      _pageController.jumpToPage(pageNum);
    }
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  String dropdownValue = 'Hour';

  // Home Page State Widget
  @override
  Widget build(BuildContext context)
  {
    String date = "2021-12-25 10:00:00";
    parse_lopy_temperature("lopy", date);

    final List<TempData> tempData = [
      TempData("Monday", 5.5),
      TempData("Tuesday", 8.5),
      TempData("Wednesday", 6.5),
      TempData("Thursday", 8.5),
      TempData("Friday", 2.5),
    ];

    final List<LightData> lightData = [
      LightData("Monday", 80),
      LightData("Tuesday", 85),
      LightData("Wednesday", 75),
      LightData("Thursday", 95),
      LightData("Friday", 90),
    ];

    final List<PressureData> pressureData = [
      PressureData("Monday", 1013.25),
      PressureData("Tuesday", 1040.15),
      PressureData("Wednesday", 1039),
      PressureData("Thursday", 1035),
      PressureData("Friday", 1036),
    ];

    final List<HumData> humData = [
      HumData("Monday", 96),
      HumData("Tuesday", 90),
      HumData("Wednesday", 87),
      HumData("Thursday", 76),
      HumData("Friday", 83),
    ];


    // Returning Appbar as a Widget for our Home Page
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Weather Monkeys",
            style: GoogleFonts.nunito(textStyle: TextStyle(color: Color(0xFFF7F7F7), fontSize: 25))),
        actions: <Widget>[
        ],
      ),
      body:
      Container(
          child: Column(
              children: [
                Container(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],

                      ),
                      child:
                      Row(
                        //children: <Widget>[
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                              child:
                              Container(
                                decoration: BoxDecoration(
                                  //color:  Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                ),
                                child:
                                TabButton(
                                  text: "Temperature",
                                  pageNumber: 0,
                                  selectedPage: _selectedPage,
                                  onPressed: (){
                                    _changePage(0);
                                  },

                                ),
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child:
                            Container(
                              decoration: BoxDecoration(

                              ),
                              child:
                              TabButton(
                                text: "Light",
                                pageNumber: 1,
                                selectedPage: _selectedPage,
                                onPressed: (){
                                  _changePage(1);
                                },

                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child:
                            Container(
                              decoration: BoxDecoration(

                              ),
                              child:
                              TabButton(
                                  text: "Pressure",
                                  pageNumber: 2,
                                  selectedPage: _selectedPage,
                                  onPressed: (){
                                    _changePage(2);
                                  }
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 10, 0),
                            child:
                            Container(
                              decoration: BoxDecoration(

                              ),
                              child:
                              TabButton(
                                text: "Humidity",
                                pageNumber: 3,
                                selectedPage: _selectedPage,
                                onPressed: (){
                                  _changePage(3);
                                },
                              ),
                            ),
                          ),

                          Padding(
                              padding: const EdgeInsets.fromLTRB(80, 15, 30, 0),

                              child: DropdownButton<String>(
                                value: dropdownValue,
                                icon: const Icon(Icons.expand_more),
                                elevation: 10,
                                style: GoogleFonts.nunito(textStyle: TextStyle(color: colorCustom, fontSize: 15, fontWeight: FontWeight.bold)),
                                underline: Container(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>['Hour', 'Day', 'Week', 'Custom']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                          ),
                      ]),
                    )
                ),
                Expanded(
                    child:
                    PageView(
                        onPageChanged: (int page) {
                          setState(() {
                            _selectedPage = page;
                          });
                        },
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        children: [

                          Container(
                              child:
                              Row(
                                  children: [
                                    Expanded(
                                      child:
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SfCartesianChart(
                                                margin: EdgeInsets.all(30),
                                                primaryXAxis: CategoryAxis(),
                                                title: ChartTitle(
                                                    text: 'Temperature data \n',
                                                    alignment: ChartAlignment.near,
                                                    textStyle: TextStyle(
                                                      color: colorCustom,
                                                      fontFamily: 'Roboto',
                                                      //fontStyle: FontStyle.,
                                                      fontSize: 18,
                                                    )
                                                ),
                                                series: <ChartSeries>[
                                                  // Renders line chart
                                                  LineSeries<TempData, String>(
                                                    markerSettings: MarkerSettings(
                                                      borderWidth: 3,
                                                    ),
                                                    dataSource: tempData,
                                                    xValueMapper: (TempData temp, _) => temp.day,
                                                    yValueMapper: (TempData temp, _) => temp.temp,
                                                    color: colorCustom,
                                                  )
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Light data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<LightData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: lightData,
                                                        xValueMapper: (LightData light, _) => light.day,
                                                        yValueMapper: (LightData light, _) => light.light,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Pressure data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<PressureData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: pressureData,
                                                        xValueMapper: (PressureData pressure, _) => pressure.day,
                                                        yValueMapper: (PressureData pressure, _) => pressure.pressure,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Humidity data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<HumData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: humData,
                                                        xValueMapper: (HumData hum, _) => hum.day,
                                                        yValueMapper: (HumData hum, _) => hum.hum,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]

                              )
                          ),
                          Container(
                              child:
                              Row(
                                  children: [
                                    Expanded(
                                      child:
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SfCartesianChart(
                                                margin: EdgeInsets.all(30),
                                                primaryXAxis: CategoryAxis(),
                                                title: ChartTitle(
                                                    text: 'Light data\n',
                                                    alignment: ChartAlignment.near,
                                                    textStyle: TextStyle(
                                                      color: colorCustom,
                                                      fontFamily: 'Roboto',
                                                      //fontStyle: FontStyle.,
                                                      fontSize: 18,
                                                    )
                                                ),
                                                series: <ChartSeries>[
                                                  // Renders line chart
                                                  LineSeries<LightData, String>(
                                                    markerSettings: MarkerSettings(
                                                      borderWidth: 3,
                                                    ),
                                                    dataSource: lightData,
                                                    xValueMapper: (LightData light, _) => light.day,
                                                    yValueMapper: (LightData light, _) => light.light,
                                                    color: colorCustom,
                                                  )
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Temperature data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<TempData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: tempData,
                                                        xValueMapper: (TempData temp, _) => temp.day,
                                                        yValueMapper: (TempData temp, _) => temp.temp,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Pressure data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<PressureData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: pressureData,
                                                        xValueMapper: (PressureData pressure, _) => pressure.day,
                                                        yValueMapper: (PressureData pressure, _) => pressure.pressure,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Humidity data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<HumData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: humData,
                                                        xValueMapper: (HumData hum, _) => hum.day,
                                                        yValueMapper: (HumData hum, _) => hum.hum,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]

                              )
                          ),
                          Container(
                              child:
                              Row(
                                  children: [
                                    Expanded(
                                      child:
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SfCartesianChart(
                                                margin: EdgeInsets.all(30),
                                                primaryXAxis: CategoryAxis(),
                                                title: ChartTitle(
                                                    text: 'Pressure \n',
                                                    alignment: ChartAlignment.near,
                                                    textStyle: TextStyle(
                                                      color: colorCustom,
                                                      fontFamily: 'Roboto',
                                                      //fontStyle: FontStyle.,
                                                      fontSize: 18,
                                                    )
                                                ),
                                                series: <ChartSeries>[
                                                  // Renders line chart
                                                  LineSeries<PressureData, String>(
                                                    markerSettings: MarkerSettings(
                                                      borderWidth: 3,
                                                    ),
                                                    dataSource: pressureData,
                                                    xValueMapper: (PressureData pressure, _) => pressure.day,
                                                    yValueMapper: (PressureData pressure, _) => pressure.pressure,
                                                    color: colorCustom,
                                                  )
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Temperature data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<TempData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: tempData,
                                                        xValueMapper: (TempData temp, _) => temp.day,
                                                        yValueMapper: (TempData temp, _) => temp.temp,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Light data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<LightData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: lightData,
                                                        xValueMapper: (LightData light, _) => light.day,
                                                        yValueMapper: (LightData light, _) => light.light,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Humidity data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<HumData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: humData,
                                                        xValueMapper: (HumData hum, _) => hum.day,
                                                        yValueMapper: (HumData hum, _) => hum.hum,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]

                              )
                          ),
                          Container(
                              child:
                              Row(
                                  children: [
                                    Expanded(
                                      child:
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                        ),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SfCartesianChart(
                                                margin: EdgeInsets.all(30),
                                                primaryXAxis: CategoryAxis(),
                                                title: ChartTitle(
                                                    text: 'Humidity data \n',
                                                    alignment: ChartAlignment.near,
                                                    textStyle: TextStyle(
                                                      color: colorCustom,
                                                      fontFamily: 'Roboto',
                                                      //fontStyle: FontStyle.,
                                                      fontSize: 18,
                                                    )
                                                ),
                                                series: <ChartSeries>[
                                                  // Renders line chart
                                                  LineSeries<HumData, String>(
                                                    markerSettings: MarkerSettings(
                                                      borderWidth: 3,
                                                    ),
                                                    dataSource: humData,
                                                    xValueMapper: (HumData hum, _) => hum.day,
                                                    yValueMapper: (HumData hum, _) => hum.hum,
                                                    color: colorCustom,
                                                  )
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Temperature data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<TempData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: tempData,
                                                        xValueMapper: (TempData temp, _) => temp.day,
                                                        yValueMapper: (TempData temp, _) => temp.temp,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Light data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<LightData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: lightData,
                                                        xValueMapper: (LightData light, _) => light.day,
                                                        yValueMapper: (LightData light, _) => light.light,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: SfCartesianChart(
                                                    margin: EdgeInsets.all(10),
                                                    primaryXAxis: CategoryAxis(),
                                                    title: ChartTitle(
                                                        text: 'Pressure data',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 11,
                                                        )
                                                    ),
                                                    series: <ChartSeries>[
                                                      // Renders line chart
                                                      LineSeries<PressureData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        dataSource: pressureData,
                                                        xValueMapper: (PressureData pressure, _) => pressure.day,
                                                        yValueMapper: (PressureData pressure, _) => pressure.pressure,
                                                        color: colorCustom,
                                                      )
                                                    ]
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]

                              )
                          )

                        ]
                    )
                )
              ]
          )
      ),

    );
  }
}

class TabButton extends StatelessWidget{
  final String? text;
  final int? selectedPage;
  final int? pageNumber;
  final void Function()? onPressed;
  TabButton({this.text, this.selectedPage, this.pageNumber, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: selectedPage == pageNumber ? Colors.grey : Colors.grey[200],
          //borderRadius: pageNumber == 0 ? BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)) : BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
          //borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
        child: Text(
          text ?? "Tab Button",
          style: TextStyle(
              color: selectedPage == pageNumber ? colorCustom : colorCustom,
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}

class TempData {
  TempData(this.day, this.temp);
  final String day;
  final double temp;
}

class LightData {
  LightData(this.day, this.light);
  final String day;
  final int light;
}

class PressureData {
  PressureData(this.day, this.pressure);
  final String day;
  final double pressure;
}

class HumData {
  HumData(this.day, this.hum);

  final String day;
  final int hum;
}