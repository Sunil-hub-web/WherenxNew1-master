import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class PinCoutDetails{

  Future<http.Response> pincoutDetails(place_id) async {
    http.Response response;

    response = await http.post(Uri.parse(ApiUrl.count_business_pin),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"place_id": place_id}));

    return response;
  }
}