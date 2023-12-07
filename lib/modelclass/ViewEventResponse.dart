class ViewEventResponse {
  String? status;
  String? operation;
  String? message;
  List<Data>? data;

  ViewEventResponse({this.status, this.operation, this.message, this.data});

  ViewEventResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    operation = json['operation'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['operation'] = this.operation;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? userName;
  String? eventName;
  String? eventType;
  String? startEventDatetime;
  String? eventAddress;
  String? eventDescription;
  String? eventVideo;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? endEventDatetime;
  List<PeventImage>? peventImage;

  Data(
      {this.id,
      this.userId,
      this.userName,
      this.eventName,
      this.eventType,
      this.startEventDatetime,
      this.eventAddress,
      this.eventDescription,
      this.eventVideo,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.endEventDatetime,
      this.peventImage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    eventName = json['event_name'];
    eventType = json['event_type'];
    startEventDatetime = json['start_event_datetime'];
    eventAddress = json['event_address'];
    eventDescription = json['event_description'];
    eventVideo = json['event_video'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    endEventDatetime = json['end_event_datetime'];
    if (json['pevent_image'] != null) {
      peventImage = <PeventImage>[];
      json['pevent_image'].forEach((v) {
        peventImage!.add(new PeventImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['event_name'] = this.eventName;
    data['event_type'] = this.eventType;
    data['start_event_datetime'] = this.startEventDatetime;
    data['event_address'] = this.eventAddress;
    data['event_description'] = this.eventDescription;
    data['event_video'] = this.eventVideo;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['end_event_datetime'] = this.endEventDatetime;
    if (this.peventImage != null) {
      data['pevent_image'] = this.peventImage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PeventImage {
  int? id;
  int? eventId;
  String? image;
  String? createdAt;
  String? updatedAt;

  PeventImage(
      {this.id, this.eventId, this.image, this.createdAt, this.updatedAt});

  PeventImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    eventId = json['event_id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['event_id'] = this.eventId;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}