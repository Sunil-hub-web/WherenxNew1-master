class DeleteEventResponse {
  String? status;
  String? operation;
  String? message;

  DeleteEventResponse({this.status, this.operation, this.message});

  DeleteEventResponse.fromJson(Map<String, dynamic> json) {
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