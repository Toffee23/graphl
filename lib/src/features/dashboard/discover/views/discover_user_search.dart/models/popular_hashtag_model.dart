class PopularHashtag {
    PopularHashtag({
        required this.hashtag,
        required this.count,
    });

    final String? hashtag;
    final int? count;

    PopularHashtag copyWith({
        String? hashtag,
        int? count,
    }) {
        return PopularHashtag(
            hashtag: hashtag ?? this.hashtag,
            count: count ?? this.count,
        );
    }

    factory PopularHashtag.fromJson(Map<String, dynamic> json){ 
        return PopularHashtag(
            hashtag: json["hashtag"],
            count: json["count"],
        );
    }

}
