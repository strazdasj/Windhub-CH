import 'package:flutter/material.dart';

const htmlData = """<script id="wg_fwdg_988948_52_1702153230854">
                      (function (window, document) {
                        var loader = function () {
                          var arg = ["s=988948" ,"m=52","uid=wg_fwdg_988948_52_1702153230854" ,"wj=knots" ,"tj=c" ,"waj=m" ,"tij=cm" ,"odh=5" ,"doh=23" ,"fhours=48" ,"hrsm=1" ,"vt=forecasts" ,"lng=en" ,"p=WINDSPD,GUST,SMER,TMP,CDC,APCP1s"];
                          var script = document.createElement("script");
                          var tag = document.getElementsByTagName("script")[0];
                          script.src = "https://www.windguru.cz/js/widget.php?"+(arg.join("&"));
                          tag.parentNode.insertBefore(script, tag);
                        };
                        window.addEventListener ? window.addEventListener("load", loader, false) : window.attachEvent("onload", loader);
                      })(window, document);
                    </script>""";

class ForecastPage extends StatefulWidget {
  const ForecastPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForecastState();
}

class _ForecastState extends State {
  final List<String> _locations = [
    "Urnersee",
    "Untersee",
    "Silvaplana",
    "Zürisee"
  ]; // Option 2
  String? _selectedLocation; // Option 2
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    double contentFontSize = screenWidth * 0.06;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    bool isDropdownOpen = false;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/P1015742.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.1),
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
                  SizedBox(height: statusBarHeight + 20),
                  Text(
                    'Forecast',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    height: 1,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    hint: const Text(
                      'Please choose a location',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedLocation,
                    dropdownColor: Colors.white,
                    focusColor: Colors.grey,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                    elevation: 8,
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    items: _locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            location,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
