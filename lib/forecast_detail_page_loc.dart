import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ForecastDetailPageLoc extends StatefulWidget {
  final double lat;
  final double lon;
  final String lake;
  final String lake_img;
  const ForecastDetailPageLoc(
      {super.key,
      required this.lat,
      required this.lon,
      required this.lake,
      required this.lake_img});
  @override
  State<StatefulWidget> createState() => _ForecastDetailStateLoc();
}

class _ForecastDetailStateLoc extends State<ForecastDetailPageLoc> {
  Future<Map<String, dynamic>>?
      fetchedContentFuture; // Future for fetching content

  // Function to fetch content
  Future<Map<String, dynamic>> fetchContent() async {
    var response = await http.get(Uri.parse(
        "https://jkatkus.pythonanywhere.com/forecast_loc/${widget.lat}/${widget.lon}"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return parsed JSON
    } else {
      throw Exception('Failed to load content');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchedContentFuture =
        fetchContent(); // Assign the future when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 253, 253),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchedContentFuture, // Pass the future to the FutureBuilder
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, display a loading indicator
            return LoadingContent(
              lake: widget.lake,
            );
          } else if (snapshot.hasError) {
            // If an error occurs during fetching data, display an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // If the future completes successfully, display the content
            return TransitionedContent(
              lake: widget.lake,
              forecast_json: snapshot.data!,
            );
          }
        },
      ),
    );
  }
}

class LoadingContent extends StatelessWidget {
  final String lake;

  const LoadingContent({super.key, required this.lake});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.075;
    //double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: statusBarHeight),
                Container(
                  color: Color.fromARGB(
                      221, 17, 101, 112), // Set the background color to black
                  child: Row(
                    children: <Widget>[
                      const SizedBox(height: 70),
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black), // Set arrow color to grey
                        onPressed: () {
                          // Add functionality to go back
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        lake,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Set text color to grey
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Color.fromARGB(221, 17, 101, 112),
                ),
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        )
      ],
    );
  }
}

class TransitionedContent extends StatelessWidget {
  final String lake;
  final Map<String, dynamic> forecast_json;
  const TransitionedContent(
      {super.key, required this.lake, required this.forecast_json});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.075;
    double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    List<DataPoint> chartDataWindSpeed = [];
    List<DataPoint> chartDataWindGusts = [];
    // Processing the JSON data for wind speed
    forecast_json['wind_speed_10m'].forEach((key, value) {
      chartDataWindSpeed.add(DataPoint(DateTime.parse(key), value.toDouble()));
    });

    // Processing the JSON data for wind gusts
    forecast_json['wind_gusts_10m'].forEach((key, value) {
      chartDataWindGusts.add(DataPoint(DateTime.parse(key), value.toDouble()));
    });

    List<DataPoint> chartDataTemperature = [];
    forecast_json['temperature_2m'].forEach((index, value) {
      if (DateTime.parse(index).hour % 3 == 0 &&
          DateTime.parse(index).hour != 0) {
        chartDataTemperature
            .add(DataPoint(DateTime.parse(index), value.toDouble()));
      }
    });

    List<DataPoint> directionDataTemperature = [];
    forecast_json['wind_direction_10m'].forEach((index, value) {
      if (DateTime.parse(index).hour % 3 == 0 &&
          DateTime.parse(index).hour != 0) {
        directionDataTemperature
            .add(DataPoint(DateTime.parse(index), value.toDouble()));
      }
    });

    List<DataPoint> rainData = [];
    forecast_json["precipitation"].forEach((index, value) {
      rainData.add(DataPoint(DateTime.parse(index), value.toDouble()));
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: statusBarHeight),
                Container(
                  color: Color.fromARGB(
                      221, 17, 101, 112), // Set the background color to black
                  child: Row(
                    children: <Widget>[
                      const SizedBox(height: 70),
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black), // Set arrow color to grey
                        onPressed: () {
                          // Add functionality to go back
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        lake,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Set text color to grey
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Color.fromARGB(221, 17, 101, 112),
                ),
                const SizedBox(height: 40),
                Text(
                  "Wind forecast (kmh)",
                  style: TextStyle(
                    fontSize: contentFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width *
                      2, // Adjust width as needed
                  padding: const EdgeInsets.all(4),
                  child: SfCartesianChart(
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                    ),
                    primaryXAxis: DateTimeAxis(
                        enableAutoIntervalOnZooming: false,
                        autoScrollingDelta: 24,
                        autoScrollingMode: AutoScrollingMode.start,
                        dateFormat: DateFormat('HH:mm'),
                        intervalType: DateTimeIntervalType.hours,
                        interval: 4,
                        majorGridLines: const MajorGridLines(width: 1),
                        majorTickLines: const MajorTickLines(width: 4),
                        minimum: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            max(6, DateTime.now().hour - 4),
                            0),
                        maximum: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + 10,
                            20,
                            0),
                        plotBands: <PlotBand>[
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.5,
                                start: DateTime(2018, 2, 1),
                                end: DateTime.now(),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.25,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    20,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 10,
                                    8,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.grey,
                                opacity: 0.05,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 10,
                                    8,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 10,
                                    20,
                                    0),
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 1,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 1}, ${getWeekdayName(DateTime.now().weekday + 1)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 2,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 2}, ${getWeekdayName(DateTime.now().weekday + 2)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 3,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 3}, ${getWeekdayName(DateTime.now().weekday + 3)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 4}, ${getWeekdayName(DateTime.now().weekday + 4)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 5,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 5}, ${getWeekdayName(DateTime.now().weekday + 5)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 6,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 6}, ${getWeekdayName(DateTime.now().weekday + 6)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 7,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 7}, ${getWeekdayName(DateTime.now().weekday + 7)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 8,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 8}, ${getWeekdayName(DateTime.now().weekday + 8)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 9,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 9}, ${getWeekdayName(DateTime.now().weekday + 9)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.black,
                                opacity: 1,
                                start: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 10,
                                    0,
                                    0),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 10,
                                    0,
                                    5),
                                verticalTextPadding: '-15%',
                                horizontalTextPadding: '3%',
                                text:
                                    "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 10}, ${getWeekdayName(DateTime.now().weekday + 10)} ",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.visible),
                                shouldRenderAboveSeries: true,
                              ),
                              PlotBand(
                                isVisible: true,
                                color: Colors.red,
                                start: DateTime.now(),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    DateTime.now().hour,
                                    DateTime.now().minute + 10),
                              ),
                            ] +
                            chartDataTemperature.map((dataPoint) {
                              return PlotBand(
                                isVisible: true,
                                color: Colors.green,
                                opacity: 0,
                                start: dataPoint.time,
                                end: dataPoint.time,
                                verticalTextPadding: '35%',
                                text: "${dataPoint.value.toInt()}°",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    overflow: TextOverflow.visible),
                                textAngle: 0,
                                shouldRenderAboveSeries: true,
                              );
                            }).toList() +
                            directionDataTemperature.map((dataPoint) {
                              return PlotBand(
                                isVisible: true,
                                color: Colors.green,
                                opacity: 0,
                                start: dataPoint.time,
                                end: dataPoint.time,
                                verticalTextPadding: '20%',
                                text: "➔",
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    overflow: TextOverflow.visible),
                                textAngle: dataPoint.value + 90,
                                shouldRenderAboveSeries: true,
                              );
                            }).toList() +
                            rainData.map((dataPoint) {
                              return PlotBand(
                                isVisible: true,
                                color: Colors.blue,
                                opacity: min(dataPoint.value / 5, 0.3),
                                start: dataPoint.time,
                                end: dataPoint.time
                                    .add(const Duration(hours: 1)),
                              );
                            }).toList()),
                    series: <LineSeries<DataPoint, DateTime>>[
                      LineSeries<DataPoint, DateTime>(
                          dataSource: chartDataWindSpeed,
                          xValueMapper: (DataPoint data, _) => data.time,
                          yValueMapper: (DataPoint data, _) => data.value,
                          name: 'Wind Speed',
                          color: Colors.blue,
                          width: 4),
                      LineSeries<DataPoint, DateTime>(
                          dataSource: chartDataWindGusts,
                          xValueMapper: (DataPoint data, _) => data.time,
                          yValueMapper: (DataPoint data, _) => data.value,
                          name: 'Gusts Speed',
                          color: Colors.orange,
                          width: 4),
                    ],
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Set width to 80% of the screen
                  child: DataTable(
                    columnSpacing: 15,
                    columns: const [
                      // Make the first column wider
                      DataColumn(
                        label: SizedBox(
                          width: 60, // Adjust the width as needed
                          child: Text(''),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80, // Adjust the width as needed
                          child: Text(''),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 20, // Adjust the width as needed
                          child: Text(''),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 20, // Adjust the width as needed
                          child: Text(''),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 40, // Adjust the width as needed
                          child: Text(''),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text(
                            'Today')), // Adjust the content based on your needs
                        DataCell(Text(
                            '${forecast_json["summary"]["0"]["wind"]} / ${forecast_json["summary"]["0"]["gusts"]} kmh')),
                        DataCell(
                          Transform.rotate(
                            angle: (forecast_json["summary"]["0"]["direction"] +
                                    90) *
                                3.1415927 /
                                180, // Convert degrees to radians
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                        DataCell(
                            Text('${forecast_json["summary"]["0"]["temp"]}°')),
                        DataCell(
                            Text('${forecast_json["summary"]["0"]["rain"]}mm')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text(
                            'Tomorrow')), // Adjust the content based on your needs
                        DataCell(Text(
                            '${forecast_json["summary"]["1"]["wind"]} / ${forecast_json["summary"]["1"]["gusts"]} kmh')),
                        DataCell(
                          Transform.rotate(
                            angle: (forecast_json["summary"]["1"]["direction"] +
                                    90) *
                                3.1415927 /
                                180, // Convert degrees to radians
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                        DataCell(
                            Text('${forecast_json["summary"]["1"]["temp"]}°')),
                        DataCell(
                            Text('${forecast_json["summary"]["1"]["rain"]}mm')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 2}, ${getWeekdayName(DateTime.now().weekday + 2)} ")), // Adjust the content based on your needs
                        DataCell(Text(
                            '${forecast_json["summary"]["2"]["wind"]} / ${forecast_json["summary"]["2"]["gusts"]} kmh')),
                        DataCell(
                          Transform.rotate(
                            angle: (forecast_json["summary"]["2"]["direction"] +
                                    90) *
                                3.1415927 /
                                180, // Convert degrees to radians
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                        DataCell(
                            Text('${forecast_json["summary"]["2"]["temp"]}°')),
                        DataCell(
                            Text('${forecast_json["summary"]["2"]["rain"]}mm')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + 3}, ${getWeekdayName(DateTime.now().weekday + 3)} ")), // Adjust the content based on your needs
                        DataCell(Text(
                            '${forecast_json["summary"]["3"]["wind"]} / ${forecast_json["summary"]["3"]["gusts"]} kmh')),
                        DataCell(
                          Transform.rotate(
                            angle: (forecast_json["summary"]["3"]["direction"] +
                                    90) *
                                3.1415927 /
                                180, // Convert degrees to radians
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                        DataCell(
                            Text('${forecast_json["summary"]["3"]["temp"]}°')),
                        DataCell(
                            Text('${forecast_json["summary"]["3"]["rain"]}mm')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class DataPoint {
  final DateTime time;
  final double value;

  DataPoint(this.time, this.value);
}

String getWeekdayName(int weekday) {
  weekday = weekday - 1;
  weekday = weekday % 7;
  switch (weekday) {
    case 0:
      return 'Monday';
    case 1:
      return 'Tuesday';
    case 2:
      return 'Wednesday';
    case 3:
      return 'Thursday';
    case 4:
      return 'Friday';
    case 5:
      return 'Saturday';
    case 6:
      return 'Sunday';
    default:
      return '';
  }
}
