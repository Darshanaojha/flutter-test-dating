class MarkFavouriteRequestModel {
  String? favouriteId;

  MarkFavouriteRequestModel({
    required this.favouriteId,
  });

  factory MarkFavouriteRequestModel.fromJson(Map<String, dynamic> json) {
    return MarkFavouriteRequestModel(
      favouriteId: json['favourite_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favourite_id': favouriteId,
    };
  }
}
