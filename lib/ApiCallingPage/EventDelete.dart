
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class EventDelete{
  Future<http.Response> deleteEventDetails(id) async {
    http.Response response;

    response = await http.post(Uri.parse(ApiUrl.business_event_delete),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"id": id}));

    return response;
  }

}