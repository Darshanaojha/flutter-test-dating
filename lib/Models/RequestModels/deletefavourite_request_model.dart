class DeleteFavouritesRequest {
  String favouriteId;

  DeleteFavouritesRequest({
    required this.favouriteId,
  });

  factory DeleteFavouritesRequest.fromJson(Map<String, dynamic> json) {
    return DeleteFavouritesRequest(
      favouriteId: json['favourite_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favourite_id': favouriteId,
    };
  }
}
