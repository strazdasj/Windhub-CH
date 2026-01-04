import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forecast_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'unit_notifier.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewsState();
}

class _NewsState extends State {
  Future<Map<String, dynamic>>?
      fetchedContentFuture; // Future for fetching content

  // Function to fetch content
  Future<Map<String, dynamic>> fetchContent(String unit) async {
    var response = await http.get(Uri.parse(
        "https://jkatkus.pythonanywhere.com/SpotsOfTheDay_cached/1/$unit"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load content');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, _) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 232, 253, 253),
          body: FutureBuilder<Map<String, dynamic>>(
            future: fetchContent(unit),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingContent();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return TransitionedContent(
                  forecast_json: snapshot.data!,
                  context: context,
                  unit: unit,
                );
              }
            },
          ),
        );
      },
    );
  }
}

class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});
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
  final Map<String, dynamic> forecast_json;
  final BuildContext context;
  final String unit;
  const TransitionedContent({
    super.key,
    required this.forecast_json,
    required this.context,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.075;
    double contentFontSize = screenWidth * 0.06;
    const double boxHeight = 80;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(221, 17, 101, 112),
      systemNavigationBarColor: Color.fromARGB(221, 17, 101, 112),
    ));
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0), // Adjust the top padding
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: statusBarHeight + 10),
                Text(
                  'Spots of Tomorrow',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(
                    // Add a Divider widget
                    height: 5, // Adjust the height of the divider
                    thickness: 5,
                    color: Color.fromARGB(
                        221, 17, 101, 112) // Adjust the color of the divider
                    ),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                      const SizedBox(height: 10),
                      Text(
                        '1. ${forecast_json["1"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "1", unit),
                      const SizedBox(height: 20),
                      Text(
                        '2. ${forecast_json["2"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "2", unit),
                      const SizedBox(height: 20),
                      Text(
                        '3. ${forecast_json["3"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "3", unit),
                      const SizedBox(height: 20),
                      Text(
                        '4. ${forecast_json["4"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "4", unit),
                    ])))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget BuildLakeButton(
      Map<String, dynamic> forecastJson, String idx, String unit) {
    double screenWidth = MediaQuery.of(context).size.width;
    double contentFontSize = screenWidth * 0.06;
    const double boxHeight = 80;
    return GestureDetector(
      onTap: () {
        // Handle navigation here
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ForecastDetailPage(
                    lake: forecastJson[idx]["lake"],
                    lake_img: forecastJson[idx]["lake_back"]),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Define the starting position
              const end = Offset.zero; // Define the ending position
              const curve = Curves.ease; // Define the curve for the animation

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            height: boxHeight,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/${forecastJson[idx]["lake_back"]}_forecast.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10, // Adjust the top position as needed
            left: 20,
            child: Text(
              "${forecastJson[idx]["temp"]}°",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 10, // Adjust the top position as needed
            right: 20,
            child: Text(
              "${forecastJson[idx]["rain"]}mm",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 10, // Adjust the top position as needed
            right: screenWidth / 2 - 120,
            width: 200,
            child: Text(
              "${forecastJson[idx]["wind"]} - ${forecastJson[idx]["gusts"]} $unit",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 10, // Adjust the top position as needed
            right: screenWidth / 2 - 270,
            width: 500,
            child: Text(
              "Best time: ${DateTime.parse(forecastJson[idx]["time"]).hour - 2}:00 - ${DateTime.parse(forecastJson[idx]["time"]).hour + 1}:00",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
