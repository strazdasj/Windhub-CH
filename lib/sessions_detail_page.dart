import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SessionsDetailPage extends StatefulWidget {
  final String lake;
  final String lake_img;
  final String date;
  final String strength;
  const SessionsDetailPage(
      {super.key,
      required this.lake,
      required this.lake_img,
      required this.date,
      required this.strength});
  @override
  State<StatefulWidget> createState() => _SessionsDetailState();
}

class _SessionsDetailState extends State<SessionsDetailPage> {
  Future<Map<String, dynamic>>?
      fetchedContentFuture; // Future for fetching content

  // Function to fetch content
  Future<Map<String, dynamic>> fetchContent() async {
    var response = await http.get(Uri.parse(
        "https://jkatkus.pythonanywhere.com/sessions/${widget.lake_img}/${widget.date}"));
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
            return LoadingContent(lake: widget.lake, date: widget.date);
          } else if (snapshot.hasError) {
            // If an error occurs during fetching data, display an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // If the future completes successfully, display the content
            return TransitionedContent(
              lake: widget.lake,
              people_json: snapshot.data!,
              strength: widget.strength,
              date: widget.date,
            );
          }
        },
      ),
    );
  }
}

class LoadingContent extends StatelessWidget {
  final String lake;
  final String date;
  const LoadingContent({super.key, required this.lake, required this.date});
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
                            color: Colors.grey), // Set arrow color to grey
                        onPressed: () {
                          // Add functionality to go back
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        "$date - $lake",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70, // Set text color to grey
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
  final String date;
  final String strength;
  final Map<String, dynamic> people_json;
  const TransitionedContent(
      {super.key,
      required this.lake,
      required this.people_json,
      required this.date,
      required this.strength});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var peopleList = people_json["result"];
    // Processing the JSON data for wind speed

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
                        "$date - $lake",
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
                const SizedBox(height: 20),
                BuildSessionButton(context, peopleList[0])
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget BuildSessionButton(BuildContext context, userinfo) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.9;
    double boxHeight = 160;
    const double fontsizeButton = 20;
    return Stack(
      children: [
        Container(
          height: boxHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            color: Colors.black12,
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
        const Positioned(
            top: 15,
            left: 10,
            child: Icon(Icons.account_circle, size: fontsizeButton)),
        Positioned(
          top: 10, // Adjust the top position as needed
          left: 45,
          child: Text(
            userinfo["user"],
            style: const TextStyle(
              fontSize: fontsizeButton,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Positioned(
            top: 44,
            left: 10,
            child: Icon(
              Icons.settings,
              size: fontsizeButton,
            )),
        Positioned(
          top: 40, // Adjust the top position as needed
          left: 45,
          child: Text(
            userinfo["material"],
            softWrap: true,
            style: const TextStyle(
              fontSize: fontsizeButton,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
