import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class ViewSingleEventList{

   Future<http.Response> viewSingleEventList(eventID) async{

    http.Response response;

    response = await http.post(Uri.parse(ApiUrl.business_event_by_id),

      headers: <String,String>{'Content-Type': 'application/json; charset=UTF-8',},

      body: jsonEncode(<String,String>{"id":eventID}));

    return response;

  }
}