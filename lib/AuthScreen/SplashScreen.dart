import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wherenxnew1/Dimension.dart';

import '../ApiCallingPage/ShowAllPin.dart';
import '../Routes/RouteHelper.dart';
import '../modelclass/ShowAllPinResponse.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String by = "Polosoft";
  late bool islogin = false;
  int userId = 0;
  String value = "0", value1 = "0";

  List<ShowAllPinResponse> showPinResponse = [];
  List<AllPinList> userinfoPin = [];
  List<String> str_userinfoPin = [];

  Future<List<AllPinList>> showAppPin() async {

    userinfoPin.clear();

    SharedPreferences pre = await SharedPreferences.getInstance();
    islogin = pre.getBool("islogin") ?? false;
    userId = pre.getInt("userId") ?? 0;

    String str_userId = userId.toString();

    print("userdetails ${str_userId}");

    http.Response responseData = await ShowAllPin().showPinDetails(str_userId);

    var jsonResponse = json.decode(responseData.body);
    var pinlistResponse = ShowAllPinResponse.fromJson(jsonResponse);

    if (userinfoPin.isEmpty) {

      if (pinlistResponse.status == "success") {
        for (int i = 0; i < pinlistResponse.allPinList!.length; i++) {
          userinfoPin.add(pinlistResponse.allPinList![i]);
          str_userinfoPin.add(pinlistResponse.allPinList![i].placeId!);
        }

        value = userinfoPin.length.toString();
        value1 = str_userinfoPin.length.toString();

        SharedPreferences pre = await SharedPreferences.getInstance();
        pre.setStringList("userinfoPin", str_userinfoPin); //save List

      } else {

        Fluttertoast.showToast(
            msg: pinlistResponse.message!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      // Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
      print(showPinResponse.toString());
    }

    return userinfoPin;
  }

  Future<void> timerMethod(BuildContext context) async {
    //bool islogin = false;

    SharedPreferences pre = await SharedPreferences.getInstance();
    bool islogin = pre.getBool("islogin") ?? false;

    FirebaseApp firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;

    //   Get.offNamed(RouteHelper.getIntroScreen());

    Timer(
        const Duration(seconds: 2),
        () => islogin == false
            ? user != null
                ? Get.toNamed(RouteHelper.getHomeScreenpage())
                : Get.offNamed(RouteHelper.getIntroScreen())
            : Get.offNamed(RouteHelper.getHomeScreenpage()));

    // if(islogin == false){
    //   if (user != null) {
    //
    //     Get.toNamed(RouteHelper.getHomeScreenpage());
    //     // Navigator.of(context).pushReplacement(
    //     //   MaterialPageRoute(
    //     //     builder: (context) => UserInfoScreen(
    //     //       user: user,
    //     //     ),
    //     //   ),
    //     // );
    //   }else{
    //
    //     Get.toNamed(RouteHelper.getSignUpScreen());
    //   }
    //
    // }
    // else{
    //   Get.toNamed(RouteHelper.getHomeScreenpage());
    // }
  }

  @override
  void initState() {
    timerMethod(context);
    showAppPin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timerMethod(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      body: Container(
        width: Dimensions.screenWidth,
        height: Dimensions.screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(6.123234262925839e-17, 1),
              end: Alignment(-1, 6.123234262925839e-17),
              colors: [
                Color.fromRGBO(31, 203, 220, 1),
                Color.fromRGBO(0, 184, 202, 1)
              ]),
        ),
        child: Column(
          children: <Widget>[
            const Expanded(
              child: SizedBox(),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset(
                      'assets/images/logo_w.png',
                    ),
                  ),
                  const Text(
                    " WhereNX",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "V0.1.1",
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: Dimensions.screenWidth,
//         height: Dimensions.screenHeight,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment(6.123234262925839e-17, 1),
//               end: Alignment(-1, 6.123234262925839e-17),
//               colors: [
//                 Color.fromRGBO(31, 203, 220, 1),
//                 Color.fromRGBO(0, 184, 202, 1)
//               ]),
//         ),
//         child: Column(
//           children: <Widget>[
//             const Expanded(
//               child: SizedBox(),
//             ),
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Container(
//                     height: 50,
//                     width: 50,
//                     child: Image.asset(
//                       'assets/images/logo_w.png',
//                     ),
//                   ),
//                   const Text(
//                     " WhereNX",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 30,
//                         fontWeight: FontWeight.normal),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Align(
//                 alignment: FractionalOffset.bottomCenter,
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 30),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "V0.1.1",
//                         style: TextStyle(
//                             color: Colors.white, fontFamily: 'Poppins'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> timerMethod() async {
//
//     SharedPreferences pre = await SharedPreferences.getInstance();
//     bool islogin = pre.getBool("islogin") ?? false;
//
//     Timer(const Duration(seconds: 2),
//             () => islogin == false ? Get.offNamed(RouteHelper.getIntroScreen()) : Get.offNamed(RouteHelper.getHomeScreenpage()));
//   }
// }
