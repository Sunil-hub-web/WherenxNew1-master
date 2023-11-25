class PinCountResponse {
  String? status;
  String? operation;
  String? message;
  int? count;

  PinCountResponse({this.status, this.operation, this.message, this.count});

  PinCountResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    operation = json['operation'];
    message = json['message'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['operation'] = this.operation;
    data['message'] = this.message;
    data['count'] = this.count;
    return data;
  }
}