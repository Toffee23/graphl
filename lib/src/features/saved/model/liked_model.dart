// To parse this JSON data, do
//
//     final likedServiceModel = likedServiceModelFromJson(jsonString);

import 'dart:convert';

LikedServiceModel likedServiceModelFromJson(String str) => LikedServiceModel.fromJson(json.decode(str));

String likedServiceModelToJson(LikedServiceModel data) => json.encode(data.toJson());

class LikedServiceModel {
    String? typename;
    Service? service;

    LikedServiceModel({
        this.typename,
        this.service,
    });

    LikedServiceModel copyWith({
        String? typename,
        Service? service,
    }) => 
        LikedServiceModel(
            typename: typename ?? this.typename,
            service: service ?? this.service,
        );

    factory LikedServiceModel.fromJson(Map<String, dynamic> json) => LikedServiceModel(
        typename: json["__typename"],
        service: json["service"] == null ? null : Service.fromJson(json["service"]),
    );

    Map<String, dynamic> toJson() => {
        "__typename": typename,
        "service": service?.toJson(),
    };
}

class Service {
    String? typename;
    User? user;
    String? title;
    String? description;

    Service({
        this.typename,
        this.user,
        this.title,
        this.description,
    });

    Service copyWith({
        String? typename,
        User? user,
        String? title,
        String? description,
    }) => 
        Service(
            typename: typename ?? this.typename,
            user: user ?? this.user,
            title: title ?? this.title,
            description: description ?? this.description,
        );

    factory Service.fromJson(Map<String, dynamic> json) => Service(
        typename: json["__typename"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        title: json["title"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "__typename": typename,
        "user": user?.toJson(),
        "title": title,
        "description": description,
    };
}

class User {
    String? typename;
    String? id;
    String? username;

    User({
        this.typename,
        this.id,
        this.username,
    });

    User copyWith({
        String? typename,
        String? id,
        String? username,
    }) => 
        User(
            typename: typename ?? this.typename,
            id: id ?? this.id,
            username: username ?? this.username,
        );

    factory User.fromJson(Map<String, dynamic> json) => User(
        typename: json["__typename"],
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "__typename": typename,
        "id": id,
        "username": username,
    };
}
