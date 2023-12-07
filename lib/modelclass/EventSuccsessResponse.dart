class EventSuccsessResponse {
  String? status;
  String? operation;
  String? message;

  EventSuccsessResponse({this.status, this.operation, this.message});

  EventSuccsessResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    operation = json['operation'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['operation'] = this.operation;
    data['message'] = this.message;
    return data;
  }
}