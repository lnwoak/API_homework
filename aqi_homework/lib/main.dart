import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ApiExample(),
    );
  }
}

class ApiExample extends StatefulWidget {
  const ApiExample({super.key});

  @override
  State<ApiExample> createState() => _ApiExampleState();
}

class _ApiExampleState extends State<ApiExample> {
  AqiData? showAqi;
  @override
  void initState() {
    // TODO: implement initState
    fetchAqi();
  }

  void fetchAqi() async {
    try {
      var response = await http.get(
        Uri.parse(
          'https://api.waqi.info/feed/here/?token=950100aec78cfbb25ce1d97cedf32490b28d64ae',
        ),
        // แนะนำใช้ token ของคุณเองแทน demo
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        AqiData aqiData = AqiData.fromJson(data);
        setState(() {
          showAqi = aqiData;
        });
        print('AQI: ${aqiData.aqi}');
        print('City: ${aqiData.city}');
        print('Temperature: ${aqiData.temp} °C');
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Air Quality Index(AQI)')),
        backgroundColor: const Color.fromARGB(255, 180, 198, 230),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 237, 246),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),

            Container(
              height: 100,
              width: 500,
              child: Center(
                child: Text(
                  '${showAqi?.city}',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),

            Container(
              height: 150,
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: getAqiColor(showAqi!.aqi),
              ),
              child: Center(
                child: Text(
                  '${showAqi?.aqi}',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Container(
              height: 150,
              width: 400,
              child: Center(
                child: Text(
                  '${getAqiEmoji(showAqi!.aqi)}  ${getAqiScale(showAqi!.aqi)}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: getAqiColor(showAqi!.aqi),
                  ),
                ),
              ),
            ),

            Container(
              height: 50,
              width: 600,
              child: Center(
                child: Text(
                  'Temperature :${showAqi?.temp} °C',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  fetchAqi();
                },
                child: Text('Refresh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model Class สำหรับ AQI
class AqiData {
  final int aqi;
  final String city;
  final double temp;

  // Constructor
  AqiData(this.aqi, this.city, this.temp);

  // แปลง JSON เป็น Object
  AqiData.fromJson(Map<String, dynamic> json)
    : aqi = json['data']['aqi'],
      city = json['data']['city']['name'],
      temp = json['data']['iaqi']['t']['v'].toDouble();

  Map<String, dynamic> toJson() {
    return {'aqi': aqi, 'city': city, 'temp': temp};
  }
}

String getAqiScale(int aqi) {
  if (aqi <= 50) {
    return "Good";
  } else if (aqi <= 100) {
    return "Moderate";
  } else if (aqi <= 150) {
    return "Unhealthy for Sensitive Groups";
  } else if (aqi <= 200) {
    return "Unhealthy";
  } else if (aqi <= 300) {
    return "Very Unhealthy";
  } else {
    return "Hazardous";
  }
}

Color getAqiColor(int aqi) {
  if (aqi <= 50) {
    return Colors.green;
  } else if (aqi <= 100) {
    return const Color.fromARGB(255, 253, 247, 188);
  } else if (aqi <= 150) {
    return Colors.orange;
  } else if (aqi <= 200) {
    return Colors.red;
  } else if (aqi <= 300) {
    return Colors.purple;
  } else {
    return Colors.brown;
  }
}

String getAqiEmoji(int aqi) {
  if (aqi <= 50) {
    return "😊"; // Good
  } else if (aqi <= 100) {
    return "😐"; // Moderate
  } else if (aqi <= 150) {
    return "😷"; // Unhealthy for Sensitive Groups
  } else if (aqi <= 200) {
    return "🤒"; // Unhealthy
  } else if (aqi <= 300) {
    return "😡"; // Very Unhealthy
  } else {
    return "☠️"; // Hazardous
  }
}
