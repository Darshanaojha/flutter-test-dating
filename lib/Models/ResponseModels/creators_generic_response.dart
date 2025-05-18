class CreatorGenericResponse {
  final bool success;
  final String message;
  final List<List<CreatorGeneric>> data;

  CreatorGenericResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreatorGenericResponse.fromJson(Map<String, dynamic> json) {
    return CreatorGenericResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List).map((innerList) {
        return (innerList as List).map((item) => CreatorGeneric.fromJson(item)).toList();
      }).toList(),
    );
  }
}

class CreatorGeneric {
  final String id;
  final String title;
  final int status;
  final DateTime created;
  final DateTime updated;

  CreatorGeneric({
    required this.id,
    required this.title,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory CreatorGeneric.fromJson(Map<String, dynamic> json) {
    return CreatorGeneric(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }
}
