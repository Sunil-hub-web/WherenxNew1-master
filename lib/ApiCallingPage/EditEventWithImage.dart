
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';

class EditEventWithImage {

     Future<http.StreamedResponse?> editEventDetails(
         id,
         userId,
         userName,
         eventname,
         eventtype,
         eventdatetime,
         endeventTime,
         eventaddress,
         eventdescription,) async {

        http.StreamedResponse? response;

      try{

       var request = http.MultipartRequest('POST',
           Uri.parse(ApiUrl.business_event_edit));
        request.fields.addAll({
               'id' : id,
                'user_id' : userId,
               'user_name' : userName,
               'event_name' : eventname,
               'event_type' : eventtype,
               'event_datetime' : eventdatetime,
               'event_address' : eventaddress,
               'event_description' : eventdescription,});

       // request.files.add(await http.MultipartFile.fromPath('event_video', eventvideo));
       //  for(int i=0; i<eventimage.length;i++){
       //     request.files.add(await http.MultipartFile.fromPath('event_image[]', eventimage[i]));
       //  }
        response = await request.send();
        //response = await request.send();

      }catch(e){

        e.toString();
        print("usernotexits  $e");

      }
      return response;
    }

     Future<http.StreamedResponse?> editEventImageDetails(
         event_id,eventimage) async {

        http.StreamedResponse? response;

      try{

       var request = http.MultipartRequest('POST',
           Uri.parse(ApiUrl.business_event_image_edit));
        request.fields.addAll({'event_id' : event_id,});

       // request.files.add(await http.MultipartFile.fromPath('event_video', eventvideo));
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