import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tomorrow_page.dart'; // Import the NewsPage file
import 'forecast_page2.dart';
import 'calendar_page.dart';
import 'sessions_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forecast_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'unit_notifier.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required before using SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedUnit = prefs.getString('unit') ?? 'kmh'; // Default to kmh
  unitNotifier.value = savedUnit;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(221, 17, 101, 112),
      systemNavigationBarColor: Color.fromARGB(221, 17, 101, 112)));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.04;

    return SafeArea(
      child: AppBar(
        backgroundColor: const Color.fromARGB(221, 17, 101, 112),
        elevation: 0,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Row(
              children: [
                Image.asset('assets/images/windsurfer_trans.png',
                    width: 50, height: 50),
                Text(
                  'Windhub CH',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
              ],
            ),
            ValueListenableBuilder<String>(
              valueListenable: unitNotifier,
              builder: (context, currentUnit, _) => IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select wind unit'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('km/h'),
                              value: 'kmh',
                              groupValue: currentUnit,
                              onChanged: (value) async {
                                Navigator.of(context).pop();
                                if (value != null) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'unit', value); // ✅ Save the unit
                                  unitNotifier.value = value;
                                }
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('knots'),
                              value: 'knots',
                              groupValue: currentUnit,
                              onChanged: (value) async {
                                Navigator.of(context).pop();
                                if (value != null) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'unit', value); // ✅ Save the unit
                                  unitNotifier.value = value;
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  Future<Map<String, dynamic>>?
      fetchedContentFuture; // Future for fetching content

  // Function to fetch content
  Future<Map<String, dynamic>> fetchContent() async {
    try {
      final url =
          "https://jkatkus.pythonanywhere.com/SpotsOfTheDay_cached/0/${unitNotifier.value}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchContent error: $e');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUnitPreference().then((_) {
      fetchedContentFuture = fetchContent(); // initial fetch after loading unit
    });

    // Listen for unit changes and refresh data when unitNotifier changes:
    unitNotifier.addListener(() {
      setState(() {
        fetchedContentFuture = fetchContent();
      });
    });
  }

  Future<void> _loadUnitPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnit = prefs.getString('unit') ?? 'kmh';
    unitNotifier.value = savedUnit;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 253, 253),
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: CustomAppBar(),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: unitNotifier,
        builder: (context, currentUnit, _) {
          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: fetchContent(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingContent();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return TransitionedContent(
                          forecast_json: snapshot.data!,
                          context: context,
                          unit: unitNotifier.value,
                        );
                      } else {
                        return const Center(child: Text('No data available.'));
                      }
                    },
                  ),
                ],
              ),
              const NewsPage(),
              const ForecastPage(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(221, 17, 101, 112),
        selectedItemColor: const Color.fromARGB(255, 241, 241, 241),
        unselectedItemColor: Colors.black87,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(
                milliseconds: 500), // Adjust the duration as needed
            curve: Curves.easeInOut, // Use a smooth animation curve
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Tomorrow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Forecasts',
          ),
        ],
      ),
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
  final BuildContext context;
  final Map<String, dynamic> forecast_json;
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
                  'Spots of Today',
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
                  color: const Color.fromARGB(
                      221, 17, 101, 112), // Adjust the color of the divider
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
                      BuildLakeButton(forecast_json, "4", unit)
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
