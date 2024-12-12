import 'dart:convert';

class HighlightProfileStatusRequest {
   String status;


  HighlightProfileStatusRequest({required this.status});


  factory HighlightProfileStatusRequest.fromJson(Map<String, dynamic> json) {
    return HighlightProfileStatusRequest(
      status: json['status'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }


  String toJsonString() {
    return jsonEncode(toJson());
  }
}
