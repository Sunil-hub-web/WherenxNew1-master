import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class PinPlaces{

  Future<http.Response> insertPinPlaces( userId,  delightId, delightName,  placeId,  latitude,  longitude, name,  website,
      address,  city, state, zip, phonenumber,  description, opentime, closetime, openfromto, photolink, rating, commentsrating,
      mapurl, openClose) async{
    
    http.Response response;
    
    response = await http.post(Uri.parse(ApiUrl.pinThisBusiness),

      headers: <String,String>{'Content-Type': 'application/json; charset=UTF-8',},


      body: jsonEncode(<String,String>{ "user_id":userId, "delight_id":delightId, "delight_name": delightName, "place_id": placeId, "latitude": latitude,
        "longitude": longitude, "name": name, "website": website, "address": address, "city": city, "state":state, "zip": zip,
        "phonenumber":phonenumber, "description":description, "opentime":opentime, "closetime":closetime, "openfromto":openfromto,
        "photolink":photolink, "rating":rating, "commentsrating":commentsrating, "mapurl":mapurl, "openClose":openClose}));

    return response;

  }

}