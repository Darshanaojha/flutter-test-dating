
class AppSettingRequest {
   String minimumAge;
   String maximumAge;
   String rangeKm;

  AppSettingRequest({
    required this.minimumAge,
    required this.maximumAge,
    required this.rangeKm,
  });

  factory AppSettingRequest.fromJson(Map<String, dynamic> json) {
    return AppSettingRequest(
      minimumAge: json['minimumAge'],
      maximumAge: json['maximumAge'],
      rangeKm: json['rangeKm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumAge': minimumAge,
      'maximumAge': maximumAge,
      'rangeKm': rangeKm,
    };
  }
}