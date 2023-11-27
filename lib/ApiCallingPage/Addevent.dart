import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class Addevent {

  Future<http.StreamedResponse?> addEventDetails(
      userId,
      userName,
      eventname,
      eventtype,
      eventdatetime,
      eventaddress,
      eventdescription,
      eventvideo,
      List<String> eventimage) async {

      http.StreamedResponse? response;

    try{

     var request = http.MultipartRequest('POST',
         Uri.parse('https://www.profileace.com/wherenx_user/public/api/business/business-event-create'));
      request.fields.addAll({
             'user_id' : userId,
            'user_name' : userName,
            'event_name' : eventname,
            'event_type' : eventtype,
            'event_datetime' : eventdatetime,
            'event_address' : eventaddress,
            'event_description' : eventdescription,});

      request.files.add(await http.MultipartFile.fromPath('event_video', eventvideo));
      for(int i=0; i<eventimage.length;i++){
         request.files.add(await http.MultipartFile.fromPath('event_image[]', eventimage[i]));
      }
      response = await request.send();
      //response = await request.send();

    }catch(e){

      e.toString();
      print("usernotexits  $e");

    }
    return response;
  }
}
