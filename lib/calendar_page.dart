import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Map<DateTime, List<dynamic>> _redEvents = {
    DateTime.utc(2023, 12, 9): ['Event 1'], // Red events
  };

  final Map<DateTime, List<dynamic>> _yellowEvents = {
    DateTime.utc(2023, 12, 10): ['Event 2'], // Yellow events
  };

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double subtitleFontSize = screenWidth * 0.065;
    //double contentFontSize = screenWidth * 0.06;
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
                    'Calendar',
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
                ],
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + 70, // Adjust the position as needed
            left: 0,
            right: 0,
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 124, 196,
                      206), // Change this to your desired selected day color
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color.fromARGB(221, 17, 101,
                      112), // Change this to your desired selected day color
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (day) {
                final redEvents = _redEvents[day] ?? [];
                final yellowEvents = _yellowEvents[day] ?? [];
                return [...redEvents, ...yellowEvents];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    if (_redEvents.containsKey(date)) {
                      return _buildEventMarker(
                          date.day.toString(), Colors.red, Colors.white);
                    } else if (_yellowEvents.containsKey(date)) {
                      return _buildEventMarker(
                          date.day.toString(), Colors.yellow, Colors.black);
                    }
                  }
                  return null;
                },
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showDayDetails(selectedDay); // Show details on day selection
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 100), // Space between calendar and legend
          Positioned(
            top: statusBarHeight + 450, // Adjust the position of the legend
            left: 0,
            right: 0,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarker(String text, Color bgColor, Color textColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDayDetails(DateTime selectedDay) {
    final selectedDayString = selectedDay.toString();
    final truncatedDayString = selectedDayString.substring(0, 10);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Events on the $truncatedDayString'),
          content:
              Text('You selected: $selectedDay'), // Show selected day details
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('Swiss Windsurfing Events', Colors.red, Colors.black),
        _buildLegendItem('Formula Foil Events', Colors.yellow, Colors.black),
        // Add more legend items for different markers/colors as needed
      ],
    );
  }

  Widget _buildLegendItem(String text, Color bgColor, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 15,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
