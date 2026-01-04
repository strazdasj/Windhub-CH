import 'dart:convert';
import 'package:flutter/material.dart';
import 'forecast_detail_page.dart';
import 'forecast_detail_page_loc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForecastPage extends StatefulWidget {
  const ForecastPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForecastState();
}

class _ForecastState extends State<ForecastPage> {
  String? foundVillage;
  bool locationEnabled = false;
  bool isLoading = true;
  double? latitude;
  double? longitude;
  List<String> favoriteLakes = []; // List of favorite lake names

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _getLocationAndVillage();
  }

  Future<void> _getLocationAndVillage() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedForeverDialog();
      setState(() {
        isLoading = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    );
    locationEnabled = true;
    latitude = position.latitude;
    longitude = position.longitude;
    final village =
        await _getVillageName(position.latitude, position.longitude);
    if (!mounted) return;
    setState(() {
      foundVillage = village;
      isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteLakes = prefs.getStringList('favoriteLakes') ?? [];
    });
  }

  Future<void> _toggleFavorite(String lakeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteLakes.contains(lakeName)) {
        favoriteLakes.remove(lakeName);
      } else {
        favoriteLakes.add(lakeName);
      }
      prefs.setStringList('favoriteLakes', favoriteLakes);
    });
  }

  Future<String?> _getVillageName(double latitude, double longitude) async {
    final apiUrl =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'User-Agent': 'WindsurfAppCH/1.0 (strazdasj2@gmail.com)',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['address']['village'] ??
            data['address']['city'] ??
            data['address']['town'] ??
            'Unknown Location';
      }
    } catch (e) {
      print('Error fetching village name: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(221, 17, 101, 112),
      systemNavigationBarColor: Color.fromARGB(221, 17, 101, 112),
    ));
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    const double spaceHeight = 10;

    // List of lake buttons with favorites on top, excluding the current location button
    final lakeNames = [
      {"name": "Ägerisee", "img": "ägerisee"},
      {"name": "Bielersee", "img": "bielersee"},
      {"name": "Bodensee", "img": "bodensee"},
      {"name": "Greifensee", "img": "greifensee"},
      {"name": "Hallwilersee", "img": "hallwilersee"},
      {"name": "Lac Leman", "img": "lacleman"},
      {"name": "Lago di Como", "img": "como"},
      {"name": "Lago di Lugano", "img": "luganersee"},
      {"name": "Lago Maggiore", "img": "maggiore"},
      {"name": "Murtensee", "img": "murtensee"},
      {"name": "Neuenburgersee", "img": "neuenburger"},
      {"name": "Sempachersee", "img": "sempachersee"},
      {"name": "Sihlsee", "img": "sihlsee"},
      {"name": "Silvaplana", "img": "silvaplana"},
      {"name": "Untersee", "img": "untersee"},
      {"name": "Urnersee", "img": "urnersee"},
      {"name": "Walensee", "img": "walensee"},
      {"name": "Zugersee", "img": "zugersee"},
      {"name": "Zürisee (Stäfa)", "img": "zürisee"},
      {"name": "Zürichsee (Thalwil)", "img": "thalwil"},
    ];

    // Sort the lake list so favorites come first
    final sortedLakes = [
      ...lakeNames.where((lake) => favoriteLakes.contains(lake['name']!)),
      ...lakeNames.where((lake) => !favoriteLakes.contains(lake['name']!)),
    ];

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
                    'Forecast',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                      height: 5,
                      thickness: 5,
                      color: Color.fromARGB(221, 17, 101, 112)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          isLoading
                              ? CircularProgressIndicator()
                              : foundVillage != null
                                  ? BuildLakeButtonLoc(
                                      foundVillage!,
                                      "current_loc",
                                      false,
                                      latitude!,
                                      longitude!)
                                  : Text('Local GPS Location not found.'),
                          const SizedBox(height: spaceHeight),
                          for (var lake in sortedLakes) ...[
                            BuildLakeButton(lake['name']!, lake['img']!,
                                favoriteLakes.contains(lake['name']!)),
                            const SizedBox(height: spaceHeight),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildLakeButton(String lake, String lakeImg, bool isFavorite) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double boxHeight = 80;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ForecastDetailPage(lake: lake, lake_img: lakeImg),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
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
            top: 20,
            left: 20,
            child: Text(
              lake,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 15,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.yellow : Colors.white,
                size: 40,
              ),
              onPressed: () => _toggleFavorite(lake),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildLakeButtonLoc(String lake, String lakeImg, bool isFavorite,
      double latitude, double longitude) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double boxHeight = 80;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ForecastDetailPageLoc(
              lake: foundVillage!,
              lat: latitude,
              lon: longitude,
              lake_img: "current_loc",
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
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
              color: Color.fromARGB(221, 17, 101, 112),
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
            top: 20,
            left: 20,
            child: Text(
              lake,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Icon(
              Icons.location_pin,
              color: Colors.redAccent,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
            'Please enable location services to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
            'Please grant location permission to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied Forever'),
        content: const Text(
            'Location access is permanently denied. You need to enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
