import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'package:thermostat/src/models/thermometer_value.dart';

class ThermometerProvider {
  Client client = Client();

  Future<ThermometerValue> fetchThermometerValue() async {
//    print("entered");
    final response = await client
        .get("http://api.diyetify.com/foods/thermometer/",
    headers:{HttpHeaders.authorizationHeader:"Token 9888f6469cd11ca4ca365f4e6fbf700d4a94cb55"});
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var decoded=json.decode(response.body);
      return ThermometerValue.fromJson(decoded[0]);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}