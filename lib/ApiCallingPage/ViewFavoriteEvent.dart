
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class ViewFavoriteEvent {

  Future<http.Response?> getFavroitEvents(String userId) async {
   http.Response? response;
    try {
      response = await http.post(Uri.parse(ApiUrl.business_favorite_event_show),
      headers: <String,String>{ 'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String,String>{'user_id' : userId,}));

    } catch (e) {
      log(e.toString());
    }

    return response;

  }
}