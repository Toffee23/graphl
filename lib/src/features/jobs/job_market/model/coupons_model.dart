class AllCouponsModel {
  String? id;
  String? title;
  bool? deleted;
  String? expiryDate;
  DateTime? dateCreated;
  int? useLimit;
  bool? isExpired;
  bool? userSaved;
  String? code;
  Owner? owner;

  AllCouponsModel({
    this.id,
    this.title,
    this.deleted,
    this.expiryDate,
    this.useLimit,
    this.isExpired,
    this.code,
    this.owner,
    this.dateCreated,
    this.userSaved,
  });

  AllCouponsModel copyWith({
    String? id,
    String? title,
    bool? deleted,
    String? expiryDate,
    DateTime? dateCreated,
    int? useLimit,
    bool? isExpired,
    bool? userSaved,
    String? code,
    Owner? owner,
  }) {
    return AllCouponsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      deleted: deleted ?? this.deleted,
      expiryDate: expiryDate ?? this.expiryDate,
      dateCreated: dateCreated ?? this.dateCreated,
      useLimit: useLimit ?? this.useLimit,
      isExpired: isExpired ?? this.isExpired,
      userSaved: userSaved ?? this.userSaved,
      code: code ?? this.code,
      owner: owner ?? this.owner,
    );
  }

  AllCouponsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    deleted = json['deleted'];
    expiryDate = json['expiryDate'];
    useLimit = json['useLimit'];
    isExpired = json['isExpired'];
    code = json['code'];
    userSaved = json['userSaved'];
    dateCreated = DateTime.parse(json['dateCreated']);
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
  }
  AllCouponsModel.fromWebsocket(Map<String, dynamic> json) {
    id = (json['id'] as int).toString();
    title = json['title'];
    deleted = json['deleted'];
    expiryDate = json['expiryDate'];
    useLimit = json['useLimit'];
    isExpired = json['isExpired'];
    code = json['code'];
    userSaved = json['userSaved'];
    dateCreated = DateTime.parse(json['dateCreated']);
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['deleted'] = this.deleted;
    data['expiryDate'] = this.expiryDate;
    data['useLimit'] = this.useLimit;
    data['isExpired'] = this.isExpired;
    data['dateCreated'] = this.dateCreated;
    data['code'] = this.code;
    data['userSaved'] = this.userSaved;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    return data;
  }
}

class Owner {
  String? id;
  String? fullName;
  String? profilePictureUrl;
  String? username;

  Owner({
    this.id,
    this.fullName,
    this.username,
    this.profilePictureUrl,
  });

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    profilePictureUrl = json['profilePictureUrl'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['profilePictureUrl'] = this.profilePictureUrl;
    return data;
  }
}
