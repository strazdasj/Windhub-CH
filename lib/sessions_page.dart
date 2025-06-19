import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sessions_detail_page.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SessionsState();
}

class _SessionsState extends State {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(221, 17, 101, 112),
      systemNavigationBarColor: Color.fromARGB(221, 17, 101, 112),
    ));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 253, 253),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/P1015742.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.15),
                  BlendMode.src,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: statusBarHeight + 10),
                  Text(
                    'Epic Sessions',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                      height: 5, // Adjust the height of the divider
                      thickness: 5,
                      color: Color.fromARGB(221, 17, 101, 112)),
                  const SizedBox(height: 50),
                  BuildSessionButton(
                      "Urnersee", "urnersee", "2024-05-24", "3-4bft")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget BuildSessionButton(
      String lake, String lakeImg, String date, String strength) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double boxHeight = 80;
    return GestureDetector(
        onTap: () {
          // Handle navigation here
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SessionsDetailPage(
                lake: lake,
                lake_img: lakeImg,
                date: date,
                strength: strength,
              ),
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
                  image: AssetImage('assets/images/${lakeImg}_forecast.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
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
              top: 20, // Adjust the top position as needed
              left: 20,
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 5, // Adjust the top position as needed
              right: 20,
              child: Text(
                lake,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 5, // Adjust the top position as needed
              right: 20,
              child: Text(
                strength,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ));
  }
}
