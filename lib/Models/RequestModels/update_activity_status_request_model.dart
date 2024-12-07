class UpdateActivityStatusRequest {
   String status;


  UpdateActivityStatusRequest({required this.status});

  factory UpdateActivityStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateActivityStatusRequest(
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
