import 'dart:convert';

import 'package:http/http.dart' as http;

class ViewDelight_List{

  Future<http.Response> getDelightList(String userId) async{

    http.Response response;

    response = await http.post(Uri.parse("https://www.profileace.com/wherenx_user/public/api/business/view-user-delights"),

        headers: <String,String>{

          'Content-Type': 'application/json; charset=UTF-8',
        },

        body: jsonEncode(<String,String>{"user_id" : userId}));

    return response;
  }
}