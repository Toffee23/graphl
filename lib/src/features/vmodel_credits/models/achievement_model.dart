
class AchievementModel {
  String id;
  int timesEarned;
  DateTime dateEarned;
  // Va user;
  Achievement achievement;

  AchievementModel({
    required this.id,
    required this.timesEarned,
    required this.dateEarned,
    // required this.user,
    required this.achievement,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
        id: json["id"],
        timesEarned: json["timesEarned"],
        dateEarned: DateTime.parse(json["dateEarned"]),
        // user: User.fromJson(json["user"]),
        achievement: Achievement.fromJson(json["achievement"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "timesEarned": timesEarned,
        "dateEarned": dateEarned.toIso8601String(),
        // "user": user.toJson(),
        "achievement": achievement.toJson(),
      };
}

class Achievement {
  String id;
  String title;
  String description;
  String badge;
  dynamic badgeUrl;
  DateTime dateCreated;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeUrl,
    required this.dateCreated,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        badge: json["badge"],
        badgeUrl: json["badgeUrl"],
        dateCreated: DateTime.parse(json["dateCreated"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "badge": badge,
        "badgeUrl": badgeUrl,
        "dateCreated": dateCreated.toIso8601String(),
      };
}
