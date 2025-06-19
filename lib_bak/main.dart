import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tomorrow_page.dart'; // Import the NewsPage file
import 'forecast_page2.dart';
import 'calendar_page.dart';
import 'sessions_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forecast_detail_page.dart';

void main() {
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(221, 17, 101, 112),
      systemNavigationBarColor: Color.fromARGB(221, 17, 101, 112),
    ));
    return SafeArea(
      child: AppBar(
        //backgroundColor: Colors.black87,
        backgroundColor: Color.fromARGB(221, 17, 101, 112),
        elevation: 0,
        flexibleSpace: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    'assets/images/windsurfer_trans.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Text(
                'Windhub CH',
                style: TextStyle(
                  //color: Colors.grey,
                  color: Colors.black,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pacifico',
                ),
              ),
            ],
          ),
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
    var response = await http.get(
        Uri.parse("https://jkatkus.pythonanywhere.com/SpotsOfTheDay_cached/0"));
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
        child: CustomAppBar(), // Reuse the CustomAppBar here
      ),
      body: PageView(
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
                future:
                    fetchedContentFuture, // Pass the future to the FutureBuilder
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for the future to complete, display a loading indicator
                    return const LoadingContent();
                  } else if (snapshot.hasError) {
                    // If an error occurs during fetching data, display an error message
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    // If the future completes successfully, display the content
                    return TransitionedContent(
                        forecast_json: snapshot.data!, context: context);
                  }
                },
              ),
            ],
          ),
          const NewsPage(), // Your NewsPage widget
          const ForecastPage(),
          const CalendarPage(),
          const SessionsPage(),
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Sessions',
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
  const TransitionedContent(
      {super.key, required this.forecast_json, required this.context});

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
                      BuildLakeButton(forecast_json, "1"),
                      const SizedBox(height: 20),
                      Text(
                        '2. ${forecast_json["2"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "2"),
                      const SizedBox(height: 20),
                      Text(
                        '3. ${forecast_json["3"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "3"),
                      const SizedBox(height: 20),
                      Text(
                        '4. ${forecast_json["4"]["lake"]}',
                        style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BuildLakeButton(forecast_json, "4")
                    ])))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget BuildLakeButton(Map<String, dynamic> forecastJson, String idx) {
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
              "${forecastJson[idx]["wind"]} - ${forecastJson[idx]["gusts"]} kmh",
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
