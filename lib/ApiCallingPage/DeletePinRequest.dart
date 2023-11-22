import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class DeletePinRequest{

   Future<http.Response> deletePinPlaces( userId, place_id) async{

    http.Response response;

    response = await http.post(Uri.parse(ApiUrl.delete_business_pin),

      headers: <String,String>{'Content-Type': 'application/json; charset=UTF-8',},

      body: jsonEncode(<String,String>{ "user_id":userId, "place_id":place_id}));

    return response;

  }
}