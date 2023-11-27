
import 'dart:developer';
import 'package:wherenxnew1/ApiImplement/ApiUrl.dart';
import 'package:http/http.dart' as http;
import '../modelclass/CountriesResponse.dart';

class ViewEventData {

  Future<http.Response?> getEventData() async {
    http.Response? response;
    try {
      var url = Uri.parse("https://www.profileace.com/wherenx_user/public/api/business/business-event-show");
      response = await http.get(url);
    //  return response;
    //   if (response.statusCode == 200) {
    //     List<CountriesResponse> model = userCountriesFromJson(response.body);
    //     return model;
    //   }
    } catch (e) {
      log(e.toString());
    }

    return response;
  }
}