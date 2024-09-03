class InviteContactModel {
    List<RegisteredUser>? registeredUsers;
    List<UnregisteredContact>? unregisteredContacts;

    InviteContactModel({
        this.registeredUsers,
        this.unregisteredContacts,
    });

    factory InviteContactModel.fromJson(Map<String, dynamic> json) => InviteContactModel(
        registeredUsers: json["registeredUsers"] == null ? [] : List<RegisteredUser>.from(json["registeredUsers"]!.map((x) => RegisteredUser.fromJson(x))),
        unregisteredContacts: json["unregisteredContacts"] == null ? [] : List<UnregisteredContact>.from(json["unregisteredContacts"]!.map((x) => UnregisteredContact.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "registeredUsers": registeredUsers == null ? [] : List<dynamic>.from(registeredUsers!.map((x) => x.toJson())),
        "unregisteredContacts": unregisteredContacts == null ? [] : List<dynamic>.from(unregisteredContacts!.map((x) => x.toJson())),
    };
}

class RegisteredUser {
    String? id;
    String? username;
    Phone? phone;

    RegisteredUser({
        this.id,
        this.username,
        this.phone,
    });

    factory RegisteredUser.fromJson(Map<String, dynamic> json) => RegisteredUser(
        id: json["id"],
        username: json["username"],
        phone: json["phone"] == null ? null : Phone.fromJson(json["phone"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "phone": phone?.toJson(),
    };
}

class Phone {
    String? countryCode;
    String? number;

    Phone({
        this.countryCode,
        this.number,
    });

    factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        countryCode: json["countryCode"],
        number: json["number"],
    );

    Map<String, dynamic> toJson() => {
        "countryCode": countryCode,
        "number": number,
    };
}

class UnregisteredContact {
    String? name;
    String? email;
    String? phoneNumber;

    UnregisteredContact({
        this.name,
        this.email,
        this.phoneNumber,
    });

    factory UnregisteredContact.fromJson(Map<String, dynamic> json) => UnregisteredContact(
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
    };
}
