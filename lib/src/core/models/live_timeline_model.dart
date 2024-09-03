class LiveTimelineModel {
  final id;
  var step;
  var title;
  var description;
  var duration;
  final liveClass;
  final status;
  final dateCreated;
  final lastUpdated;

  LiveTimelineModel(
      {
      this.id,
      this.step,
      this.title,
      this.description,
      this.duration,
      this.liveClass,
      this.status,
      this.dateCreated,
      this.lastUpdated,
      });

  factory LiveTimelineModel.fromJson(Map<String, dynamic> data){
    return LiveTimelineModel(
      id: data["id"],
      step: data["step"],
      title: data["title"],
      description: data["description"],
      duration: data["duration"],
      liveClass: data["liveClass"],
      status: data["status"],
      dateCreated: data["dateCreated"],
      lastUpdated: data["lastUpdated"],
    );
  }

  toJson(){
    return {
      "step": step,
      "title": title,
      "description": description,
      "duration": duration,
    };
  }
}