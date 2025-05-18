class AddUserToContentRequest {
  final String contentId;
  final int status;

  AddUserToContentRequest({
    required this.contentId,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'status': status,
      };
}
