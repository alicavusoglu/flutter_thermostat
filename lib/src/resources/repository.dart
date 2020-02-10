import 'package:thermostat/src/models/thermometer_value.dart';
import 'package:thermostat/src/resources/thermometer_provider.dart';

class Repository{
  final thermometerProvider =ThermometerProvider();
  Future<ThermometerValue> fetchValues()=>thermometerProvider.fetchThermometerValue();
}