class UserLocation {
  String? latitude;
  String? longitude;
  String? locationName;

  UserLocation({this.latitude, this.longitude, this.locationName});

  UserLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'] != null ? json['latitude'].toString() : null;
    longitude = json['longitude'] != null ? json['longitude'].toString() : null;
    locationName = json['locationName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['locationName'] = this.locationName;
    return data;
  }
}
