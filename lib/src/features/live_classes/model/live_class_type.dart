import 'dart:convert';


enum LiveClassType { LIVE_CLASS, LIVE_SESSION }

enum ClassDifficulty {
  BEGINNER,
  INTERMEDIATE,
  ADVANCED;

  factory ClassDifficulty.fromString(String value) {
    return switch (value.toUpperCase()) {
      'BEGINNER' => ClassDifficulty.BEGINNER,
      'INTERMEDIATE' => ClassDifficulty.INTERMEDIATE,
      _ => ClassDifficulty.ADVANCED,
    };
  }
}

class LiveClassesInput {
  String id;
  String title;
  LiveClassType liveType;
  String description;
  double price;
  DateTime startTime;
  int duration;
  String? preparation;
  ClassDifficulty classDifficulty;
  List<String>? category;
  List<String> banners;
  List<LiveClassTimelineInput>? timeline;
  double rating;
  String ownersUsername;
  String ownersProfilePicture;

  LiveClassesInput({
    required this.id,
    required this.ownersUsername,
    required this.ownersProfilePicture,
    required this.rating,
    required this.title,
    required this.liveType,
    required this.description,
    required this.price,
    required this.startTime,
    required this.duration,
    this.preparation,
    required this.classDifficulty,
    this.category,
    required this.banners,
    this.timeline,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        // 'ownersUsername': ownersUsername,
        // 'ownersProfilePicture': ownersProfilePicture,
        'rating': rating,
        'title': title,
        'liveType': liveType.name,
        'description': description,
        'price': price,
        'startTime': startTime.toIso8601String(),
        'duration': duration,
        'preparation': preparation,
        'classDifficulty': classDifficulty.name,
        'category': category,
        'banners': banners,
        'timeline': timeline?.map((e) => e.toJson()).toList(),
      };

  factory LiveClassesInput.fromJson(Map<String, dynamic> json) {
    return LiveClassesInput(
      id: json['id'],
      rating: json['user']['rating'],
      ownersUsername: json['user']['username'],
      ownersProfilePicture: json['user']['profilePicture'],
      title: json['title'],
      liveType:
          LiveClassType.values.firstWhere((e) => e.name == json['liveType']),
      description: json['description'],
      price: json['price'].toDouble(),
      startTime: DateTime.parse(json['startTime']),
      duration: json['duration'],
      preparation: json['preparation'],
      classDifficulty: ClassDifficulty.values.firstWhere(
          (e) => e.name == json['classDifficulty']), // Adjust for your enum
      category: json['category'] != null
          ? (jsonDecode(json['category']) as List).map((e) => '$e').toList()
          : null,
      banners: (jsonDecode(json['banners']) as List).map((e) => '$e').toList(),
      timeline: json['timeline'] != null
          ? List<LiveClassTimelineInput>.from(
              json['timeline'].map((x) => LiveClassTimelineInput.fromJson(x)))
          : null,
    );
  }
}
class LiveClasses {
  String id;
  String title;
  LiveClassType liveType;
  String description;
  double price;
  DateTime startTime;
  int duration;
  String? preparation;
  ClassDifficulty classDifficulty;
  List<String>? category;
  List<String> banners;
  List<LiveClassTimelineInput>? timelines;
  String ownersUsername;
  String ownersProfilePicture;

  LiveClasses({
    required this.id,
    required this.ownersUsername,
    required this.ownersProfilePicture,
    required this.title,
    required this.liveType,
    required this.description,
    required this.price,
    required this.startTime,
    required this.duration,
    this.preparation,
    required this.classDifficulty,
    this.category,
    required this.banners,
    this.timelines,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'liveType': liveType.name,
        'description': description,
        'price': price,
        'startTime': startTime.toIso8601String(),
        'duration': duration,
        'preparation': preparation,
        'classDifficulty': classDifficulty.name,
        'category': category,
        'banners': banners,
        'timelines': timelines?.map((e) => e.toJson()).toList(),
      };

  factory LiveClasses.fromJson(Map<String, dynamic> json) {
    return LiveClasses(
      id: json['id'],
      ownersUsername: json['user']['username']??'',
      ownersProfilePicture: json['user']['profilePicture']??'',
      title: json['title'],
      liveType:
          LiveClassType.values.firstWhere((e) => e.name == json['liveType']),
      description: json['description'],
      price: json['price'].toDouble(),
      startTime: DateTime.parse(json['startTime']),
      duration: json['duration'],
      preparation: json['preparation'],
      classDifficulty: ClassDifficulty.values.firstWhere(
          (e) => e.name == json['classDifficulty']), // Adjust for your enum
      category: json['category'] != null
          ? (jsonDecode(json['category']) as List).map((e) => '$e').toList()
          : null,
      banners: (jsonDecode(json['banners']) as List).map((e) => '$e').toList(),
      timelines: json['timelines'] != null
          ? List<LiveClassTimelineInput>.from(
              json['timelines'].map((x) => LiveClassTimelineInput.fromJson(x)))
          : null,
    );
  }
}

class LiveClassTimelineInput {
  int step;
  String title;
  String description;
  int duration;
  bool delete = false;

  LiveClassTimelineInput({
    required this.step,
    required this.title,
    required this.description,
    required this.duration,
    required this.delete,
  });

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'description': description,
        'duration': duration,
        'delete': delete,
      };

  factory LiveClassTimelineInput.fromJson(Map<String, dynamic> json) {
    return LiveClassTimelineInput(
      step: json['step'],
      title: json['title'],
      description: json['description'],
      duration: int.parse('${json['duration']}'),
      delete: json['delete'] ?? false,
    );
  }
}
