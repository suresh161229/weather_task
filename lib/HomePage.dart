
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:weather_test/Styles/Styles.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double latitude = 0;
  double longitude = 0;
  Map<String, dynamic>? jsonData;

  Future<void> getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        // print('latitude----' + latitude.toString());
        // print('longitude----' + longitude.toString());
        weatherReport(latitude, longitude);
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future weatherReport(double latitude, double longitude) async {
    var url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&past_days=3');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
       
        setState(() {
          jsonData = jsonDecode(response.body);
        });

        // print('data----------' + jsonData.toString());
        return jsonData;
      } else {
        throw Exception('Failed to load post:');
      }
    } catch (e) {
      print(e.toString());
      return null; // Return null or handle the error as needed.
    }
  }

  getAverage(double value1,double value2){
        double average = (value1 + value2) / 2;
        var stringAVerage = average.toStringAsFixed(1);
        return stringAVerage;
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    // getCurrentDate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Weather Report',style: TxtStyles.appBarTitleStyle,),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Center(
          child: Container(
            height: size.height / 3,
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      const Text('Current Temparature',style: TxtStyles.primaryStyle,),
                      Text('${getAverage(jsonData?["daily"]["temperature_2m_max"][4],jsonData?["daily"]["temperature_2m_min"][4]).toString()}${jsonData?["daily_units"]["temperature_2m_max"]}',style: TxtStyles.ternaryStyle,)

                    ],),
                    Column(children: [
                      const Text('Weather Description',style: TxtStyles.primaryStyle,),
                      Text('${weather_mapping[jsonData?["daily"]["weathercode"][4]]}',style: TxtStyles.ternaryStyle,)

                    ],),
                      Column(children: [
                      const Text(''),
                      Icon(getIconData('${weather_mapping[jsonData?["daily"]["weathercode"][4]]}'),size: 30,)

                    ],),
                  ],
                ),
                const SizedBox(height: 10,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:  [
                    Column(
                      children: [
                        const Text("Date",style: TxtStyles.secondaryStyle,),
                        Text('${jsonData?["daily"]["time"][5].toString()}',style: TxtStyles.primaryStyle,),
                        Text('${jsonData?["daily"]["time"][6].toString()}',style: TxtStyles.primaryStyle,),
                        Text('${jsonData?["daily"]["time"][7].toString()}',style: TxtStyles.primaryStyle,),
                      ],
                    ),
                        Column(
                      children: [
                        const Text('Temparature Range',style: TxtStyles.secondaryStyle,),
                        Text('${jsonData?["daily"]["temperature_2m_min"][5].toString()}'+' - '+'${jsonData?["daily"]["temperature_2m_max"][5].toString()}'+'${jsonData?["daily_units"]["temperature_2m_max"]}',style: TxtStyles.primaryStyle,),
                        Text('${jsonData?["daily"]["temperature_2m_min"][6].toString()}'+' - '+'${jsonData?["daily"]["temperature_2m_max"][6].toString()}'+'${jsonData?["daily_units"]["temperature_2m_max"]}',style: TxtStyles.primaryStyle,),
                        Text('${jsonData?["daily"]["temperature_2m_min"][7].toString()}'+'-'+'${jsonData?["daily"]["temperature_2m_max"][7].toString()}'+'${jsonData?["daily_units"]["temperature_2m_max"]}',style: TxtStyles.primaryStyle,),
                      ],
                    ),
                        Column(
                      children: [
                        const Text("Weather Conditions",style: TxtStyles.secondaryStyle,),
                        Text('${weather_mapping[jsonData?["daily"]["weathercode"][5]]}',style: TxtStyles.primaryStyle,),
                        Text('${weather_mapping[jsonData?["daily"]["weathercode"][6]]}',style: TxtStyles.primaryStyle,),
                        Text('${weather_mapping[jsonData?["daily"]["weathercode"][7]]}',style: TxtStyles.primaryStyle,),
                   
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Container(
                  // padding: const EdgeInsets.all(2.0),
                  width: size.width/3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey[300]
                  ),
                  child: TextButton(onPressed: (){
                    weatherReport(latitude, longitude);
                
                  }, child: const Text('Refresh',style: TxtStyles.primaryStyle,)),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
  var weather_mapping = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Drizzle: Light intensity",
    53: "Drizzle: Moderate intensity",
    55: "Drizzle: Dense intensity",
    56: "Freezing Drizzle: Light intensity",
    57: "Freezing Drizzle: Dense intensity",
    61: "Rain: Slight intensity",
    63: "Rain: Moderate intensity",
    65: "Rain: Heavy intensity",
    66: "Freezing Rain: Light intensity",
    67: "Freezing Rain: Heavy intensity",
    71: "Snow fall: Slight intensity",
    73: "Snow fall: Moderate intensity",
    75: "Snow fall: Heavy intensity",
    77: "Snow grains",
    80: "Rain showers: Slight intensity",
    81: "Rain showers: Moderate intensity",
    82: "Rain showers: Violent intensity",
    85: "Snow showers: Slight intensity",
    86: "Snow showers: Heavy intensity",
    95: "Thunderstorm: Slight intensity",
    96: "Thunderstorm with slight hail",
    99: "Thunderstorm with heavy hail"
};
  IconData getIconData(String weatherDescription) {
    switch (weatherDescription) {
      case "Clear sky":
        return Icons.wb_sunny; 
      case "Mainly clear":
        return Icons.wb_sunny; 
      case "Partly cloudy":
        return Icons.cloud; 
      case "Overcast":
        return Icons.cloud; 
      case "Fog and depositing rime fog":
        return Icons.cloud; 
      case "Drizzle: Light intensity":
        return Icons.grain;
      case "Freezing Rain: Light intensity":
        return Icons.beach_access; 
      case "Freezing Rain: Heavy intensity":
        return Icons.beach_access;
      
      default:
        return Icons.question_mark;
    }
  }
}
