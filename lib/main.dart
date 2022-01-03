import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

List<String> getSelectedSensors(){
  return ["py-saxion", "py-wierden"];
}

dynamic getSelectedDate(){
  return "2022-1-1 19:44:19";
}

Future getData(String table, String date) async {
  date = Uri.encodeComponent(date);
  List<String> sensors = getSelectedSensors();
  String sensors_url = "";
  int index = 0;
  if (sensors.length > 0){
    for (String str in sensors){
      sensors_url = sensors_url + "&sensors[${index}]=${str}";
      index++;
    }
  }

  final response = await http.get(
      Uri.parse("http://217.123.63.98/test3.php?table=${table}&date=${date}${sensors_url}"),
      headers: {
        "Accept": "application/json",
        "Access-Control_Allow_Origin": "*"
      });

  if(response.statusCode == 200) {

    // print(response.body);

    var jsonresponse = response.body;
    List<dynamic> decodedjson = jsonDecode(jsonresponse);

    return decodedjson;

  } else {
    throw Exception('URL incorrect.');
  }
}

dynamic getAllFutureDevices() async{
  List json = await getData("device", "0-0-0 0:00:00");
  return json;
}

Future<List> parse_lopy(String table, String date) async {
  List decodedjson = await getData(table, date);
  List<String> timeList = [];
  List<double> temperatureList = [];
  List<double> lightList = [];
  List<double> pressureList = [];
  for (var i in decodedjson){
    timeList.add(i["received_time"]);
    double temperature = double.parse(i["temperature"]);
    temperatureList.add(temperature);
    double light = double.parse(i["light"]);
    lightList.add(light);
    double pressure = double.parse(i["pressure"]);
    pressureList.add(pressure);
  }
  return await [timeList.reversed.toList(), temperatureList.reversed.toList(), lightList.reversed.toList(), pressureList.reversed.toList()];
}

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

  late List<TempData> tempData;

  late List<LightData> lightData;

  late List<PressureData> pressureData;

  late ChartSeriesController _tempSeriesController;

  late ChartSeriesController _lightSeriesController;

  late ChartSeriesController _pressureSeriesController;

  late RangeController _rangeController;


  @override
  void initState(){
    _rangeController = RangeController(
        start: _values.start,
        end: _values.end
    );
    getAllDevices();
    tempData = getTempData();
    lightData = getLightData();
    pressureData = getPressureData();
    Timer.periodic(const Duration(minutes: 2), updateDataSource);
    super.initState();
  }

  //int time = 19;
  void updateDataSource(Timer timer){
    parse_lopy("lopy", getSelectedDate()).then((result) {
      setState(() {
        final List timeList = result[0];
        final List temperatureList = result[1];
        final List lightList = result[2];
        final List pressureList = result[3];
        for(int i = 0; i < temperatureList.length; i++){
          tempData.add(TempData(timeList[i], temperatureList[i]));
          lightData.add(LightData(timeList[i], lightList[i]));
          pressureData.add(PressureData(timeList[i], pressureList[i]));
          tempData.removeAt(0);
          lightData.removeAt(0);
          pressureData.removeAt(0);
          _tempSeriesController.updateDataSource(
              addedDataIndex: tempData.length - 1,
              removedDataIndex: 0
          );
          _lightSeriesController.updateDataSource(
              addedDataIndex: lightData.length - 1,
              removedDataIndex: 0
          );
          _pressureSeriesController.updateDataSource(
              addedDataIndex: pressureData.length - 1,
              removedDataIndex: 0
          );
        }
      });
    });
  }

  List<TempData> getTempData() {
    List<TempData> tempData = [];
    parse_lopy("lopy", getSelectedDate()).then((result) {
      setState(() {
        List temperatureList = result[1];
        List timeList = result[0];
        for(int i = 0; i < temperatureList.length; i++) {
          tempData.add(TempData(timeList[i], temperatureList[i]));
        }
        print(temperatureList);
      });
    });
    return tempData;
  }

  List<LightData> getLightData() {
    List<LightData> lightData = [];
    parse_lopy("lopy", getSelectedDate()).then((result) {
      setState(() {
        List lightList = result[2];
        List timeList = result[0];
        for(int i = 0; i < lightList.length; i++) {
          lightData.add(LightData(timeList[i], lightList[i]));
        }
        print(lightList);
      });
    });
    return lightData;
  }

  List<PressureData> getPressureData() {
    List<PressureData> pressureData = [];
    parse_lopy("lopy", getSelectedDate()).then((result) {
      setState(() {
        List pressureList = result[3];
        List timeList = result[0];
        for(int i = 0; i < pressureList.length; i++) {
          pressureData.add(PressureData(timeList[i], pressureList[i]));
        }
        print(pressureList);
      });
    });
    return pressureData;
  }

  List getAllDevices() {
    List devices = [];
    getAllFutureDevices().then((result) {
      setState(() {
        for (var i in result) {
          devices.add(i["device_name"]);
        }
      });
    });
    return devices;
  }

  final DateTime _min = DateTime(2021, 12, 10), _max = DateTime(2022, 01, 02);
  SfRangeValues _values = SfRangeValues(DateTime(2022, 01, 01), DateTime(2022, 01, 02));



  // Home Page State Widget
  @override
  Widget build(BuildContext context)
  {

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

                        ],
                      ),
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
                        allowImplicitScrolling: false,
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
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            //child: Expanded(
                                            child: SfRangeSelector(
                                              controller: _rangeController,
                                              min: _min,
                                              max: _max,
                                              //interval: 1,
                                              showLabels: true,
                                              showTicks: true,
                                              initialValues: _values,
                                              child: Container(
                                                height: 500,
                                                child: SfCartesianChart(
                                                    enableAxisAnimation: true,
                                                    margin: EdgeInsets.all(5),
                                                    primaryXAxis: CategoryAxis(
                                                      // minimum: _min,
                                                      // maximum: _max,
                                                      //rangeController: _rangeController
                                                      //edgeLabelPlacement: EdgeLabelPlacement.none
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                      //autoScrollingMode: AutoScrollingMode.start,
                                                      labelFormat: '{value}°C',
                                                    ),
                                                    title: ChartTitle(
                                                        text: 'Temperature data ',
                                                        alignment: ChartAlignment.near,
                                                        textStyle: TextStyle(
                                                          color: colorCustom,
                                                          fontFamily: 'Roboto',
                                                          //fontStyle: FontStyle.,
                                                          fontSize: 18,
                                                        )
                                                    ),
                                                    series: <LineSeries>[
                                                      // Renders line chart
                                                      LineSeries<TempData, String>(
                                                        markerSettings: MarkerSettings(
                                                          borderWidth: 3,
                                                        ),
                                                        selectionBehavior: SelectionBehavior(
                                                            selectionController: _rangeController
                                                        ),
                                                        onRendererCreated: (ChartSeriesController controller){
                                                          _tempSeriesController = controller;
                                                        },
                                                        dataSource: tempData,
                                                        xValueMapper: (TempData temp, _) => temp.time,
                                                        yValueMapper: (TempData temp, _) => temp.temp,
                                                        color: colorCustom,

                                                      )
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      //),
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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
                                                        onRendererCreated: (ChartSeriesController controller){
                                                          _lightSeriesController = controller;
                                                        },
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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
                                                        onRendererCreated: (ChartSeriesController controller){
                                                          _pressureSeriesController = controller;
                                                        },
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
                                                primaryXAxis: CategoryAxis(
                                                    labelIntersectAction: AxisLabelIntersectAction.wrap
                                                ),
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                        labelFormat: '{value}°C'
                                                    ),
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
                                                        xValueMapper: (TempData temp, _) => temp.time,
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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
                                                primaryXAxis: CategoryAxis(
                                                    labelIntersectAction: AxisLabelIntersectAction.wrap
                                                ),
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                        labelFormat: '{value}°C'
                                                    ),
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
                                                        xValueMapper: (TempData temp, _) => temp.time,
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                        labelFormat: '{value}°C'
                                                    ),
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
                                                        xValueMapper: (TempData temp, _) => temp.time,
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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
                                                    primaryXAxis: CategoryAxis(
                                                        labelIntersectAction: AxisLabelIntersectAction.wrap
                                                    ),
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

//List<TempData> getTempData() {}

}

// class RangeController {
// }

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
  TempData(this.time, this.temp);
  final String time;
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
