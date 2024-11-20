import 'dart:convert';

class ReportUserReasonFeedbackRequestModel {
  String reportAgainst;
  String reasonId;
  String reason;


  ReportUserReasonFeedbackRequestModel({
    required this.reportAgainst,
    required this.reasonId,
    required this.reason,
  });


  factory ReportUserReasonFeedbackRequestModel.fromJson(Map<String, dynamic> json) {
    return ReportUserReasonFeedbackRequestModel(
      reportAgainst: json['report_against'].toString(),
      reasonId: json['reason_id'].toString(),
      reason: json['reason'].toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'report_against': reportAgainst,
      'reason_id': reasonId,
      'reason': reason,
    };
  }


  static ReportUserReasonFeedbackRequestModel fromJsonString(String str) {
    return ReportUserReasonFeedbackRequestModel.fromJson(json.decode(str));
  }


  String toJsonString() {
    return json.encode(toJson());
  }

  String? validate() {
    if (reportAgainst.isEmpty) {
      return 'Report Against cannot be empty';
    }
    if (reasonId.isEmpty) {
      return 'Reason ID cannot be empty';
    }
    if (reason.isEmpty) {
      return 'Reason cannot be empty';
    }

    
    if (int.tryParse(reasonId) == null) {
      return 'Reason ID must be a valid number';
    }

    return null; 
  }
}

