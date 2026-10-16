class RatingReviewItem {
  final int reviewId;
  final int userId;
  final int contentId;
  final int rating;
  final String title;
  final String comment;
  final int createdAt;

  RatingReviewItem({
    required this.reviewId,
    required this.userId,
    required this.contentId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
  });

  factory RatingReviewItem.fromJson(Map<String, dynamic> json) {
    return RatingReviewItem(
      reviewId: json['reviewId'] is int ? json['reviewId'] : int.tryParse(json['reviewId']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      contentId: json['contentId'] is int ? json['contentId'] : int.tryParse(json['contentId']?.toString() ?? '0') ?? 0,
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.tryParse(json['createdAt']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'contentId': contentId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}

class RatingReviewPageable {
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  RatingReviewPageable({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory RatingReviewPageable.fromJson(Map<String, dynamic> json) {
    return RatingReviewPageable(
      pageNumber: json['pageNumber'] is int ? json['pageNumber'] : int.tryParse(json['pageNumber']?.toString() ?? '0') ?? 0,
      pageSize: json['pageSize'] is int ? json['pageSize'] : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      offset: json['offset'] is int ? json['offset'] : int.tryParse(json['offset']?.toString() ?? '0') ?? 0,
      paged: json['paged'] == true,
      unpaged: json['unpaged'] == true,
    );
  }
}

class RatingReviewPagination {
  final List<RatingReviewItem> content;
  final RatingReviewPageable? pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final bool first;
  final int size;
  final int number;
  final int numberOfElements;
  final bool empty;

  RatingReviewPagination({
    required this.content,
    this.pageable,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.empty,
  });

  factory RatingReviewPagination.fromJson(Map<String, dynamic> json) {
    var rawContent = json['content'] as List? ?? [];
    List<RatingReviewItem> contentList = rawContent
        .map((item) => RatingReviewItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return RatingReviewPagination(
      content: contentList,
      pageable: json['pageable'] != null ? RatingReviewPageable.fromJson(json['pageable'] as Map<String, dynamic>) : null,
      last: json['last'] == true,
      totalElements: json['totalElements'] is int ? json['totalElements'] : int.tryParse(json['totalElements']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int ? json['totalPages'] : int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      first: json['first'] == true,
      size: json['size'] is int ? json['size'] : int.tryParse(json['size']?.toString() ?? '10') ?? 10,
      number: json['number'] is int ? json['number'] : int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      numberOfElements: json['numberOfElements'] is int ? json['numberOfElements'] : int.tryParse(json['numberOfElements']?.toString() ?? '0') ?? 0,
      empty: json['empty'] == true,
    );
  }
}

class RatingReviewDataWrapper {
  final RatingReviewPagination? ratingAndReview;

  RatingReviewDataWrapper({this.ratingAndReview});

  factory RatingReviewDataWrapper.fromJson(Map<String, dynamic> json) {
    return RatingReviewDataWrapper(
      ratingAndReview: json['RatingAndRewiew'] != null
          ? RatingReviewPagination.fromJson(json['RatingAndRewiew'] as Map<String, dynamic>)
          : (json['ratingAndReview'] != null
              ? RatingReviewPagination.fromJson(json['ratingAndReview'] as Map<String, dynamic>)
              : null),
    );
  }
}
