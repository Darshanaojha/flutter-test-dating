
import 'dart:convert';

class BlockToRequestModel {
  String blockto;

  BlockToRequestModel({required this.blockto});

  factory BlockToRequestModel.fromJson(Map<String, dynamic> json) {
    return BlockToRequestModel(
      blockto: json['blockto'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockto': blockto,
    };
  }

  static BlockToRequestModel fromJsonString(String str) {
    return BlockToRequestModel.fromJson(json.decode(str));
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}


class BlockUserRequestModel {
  BlockToRequestModel blockToModel;
  String status;
  DateTime timestamp;

  BlockUserRequestModel({
    required this.blockToModel,
    required this.status,
    required this.timestamp,
  });

  factory BlockUserRequestModel.fromJson(Map<String, dynamic> json) {
    return BlockUserRequestModel(
      blockToModel: BlockToRequestModel.fromJson(json['blockToModel']),
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'blockToModel': blockToModel.toJson(),
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }


  static BlockUserRequestModel fromJsonString(String str) {
    return BlockUserRequestModel.fromJson(json.decode(str));
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
