class PrivacySettings {
    bool? traits;
    bool? pronoun;
    bool? location;
    bool? ethnicity;
    bool? specialty;
    bool? starSign;
    bool? personality;

    PrivacySettings({
        this.traits,
        this.pronoun,
        this.location,
        this.ethnicity,
        this.specialty,
        this.starSign,
        this.personality,
    });

    factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
        traits: json["traits"],
        pronoun: json["pronoun"],
        location: json["location"],
        ethnicity: json["ethnicity"],
        specialty: json["specialty"],
        starSign: json["star_sign"],
        personality: json["personality"],
    );

    Map<String, dynamic> toJson() => {
        "traits": traits,
        "pronoun": pronoun,
        "location": location,
        "ethnicity": ethnicity,
        "specialty": specialty,
        "star_sign": starSign,
        "personality": personality,
    };
}
