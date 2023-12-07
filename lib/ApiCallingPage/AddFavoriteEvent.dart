
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class AddFavoriteEvent {

    Future<http.Response> addFavoriteEventDet(event_id, user_id) async {
    http.Response response;

    response = await http.post(Uri.parse(ApiUrl.business_favorite_event_create),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"event_id": event_id, "user_id":user_id}));

    return response;
  }
}