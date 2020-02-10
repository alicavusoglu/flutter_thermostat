class ThermometerValue {
  int id;
  int celciusValue;
  String user;
  String setDate;
  int recordStatusR;

  ThermometerValue(
      {this.id,
        this.celciusValue,
        this.user,
        this.setDate,
        this.recordStatusR});

  ThermometerValue.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    celciusValue = json['celcius_value'];
    user = json['user'];
    setDate = json['set_date'];
    recordStatusR = json['record_status_r'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] =25;
    return data;
  }
}