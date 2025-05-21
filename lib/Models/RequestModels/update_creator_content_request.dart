import 'dart:io';

class UpdateCreatorContentRequest {
  final String contentId;
  final File file;
  final String title;
  final String description;
  final String type;
  final String actualAmount;
  final String offeredDiscount;

  UpdateCreatorContentRequest({
    required this.contentId,
    required this.file,
    required this.title,
    required this.description,
    required this.type,
    required this.actualAmount,
    required this.offeredDiscount,
  });
}