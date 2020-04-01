import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:rxdart/rxdart.dart';
import 'package:thermostat/src/models/thermometer_value.dart';
import 'package:thermostat/src/resources/repository.dart';

class ThermometerBloc{
  final _repository=Repository();
  final _thermometerFetcher=PublishSubject<ThermometerValue>();
  IO.Socket socket =null;
  Observable<ThermometerValue> get allValues=>_thermometerFetcher.stream;
  int socket_value=0;
  fetchAllValues() async {
    if(socket_value!=0) {
      ThermometerValue tm = ThermometerValue();
      tm.celciusValue = socket_value;
      _thermometerFetcher.sink.add(tm);
    }
    else {
      ThermometerValue itemModel = await _repository.fetchValues();
      _thermometerFetcher.sink.add(itemModel);
    }

      if(socket==null) {
        socket = IO.io('http://thermostat-server.herokuapp.com', <String, dynamic>{
          'transports': ['websocket'] // optional
        });
        socket.on('connect', (_) {
          print('connect');
          socket.emit('room_state', ThermometerValue().toJson());
        });
        socket.on('event', (data) => print(data));
        socket.on('disconnect', (_) => print('disconnect'));
        socket.on('fromServer', (_) => print(_));
        socket.on('target_degree', (data) {
          socket_value=int.parse(data["value"]["\$numberDecimal"]);


          _thermometerFetcher.sink.add(ThermometerValue());
        });
      }
    }



  dispose(){
    _thermometerFetcher.close();
  }
}

final bloc=ThermometerBloc();


