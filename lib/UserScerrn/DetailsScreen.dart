import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wherenxnew1/ApiCallingPage/DeletePinRequest.dart';
import 'package:wherenxnew1/ApiCallingPage/PinCoutDetails.dart';
import 'package:wherenxnew1/ApiCallingPage/ViewReviewList.dart';
import 'package:wherenxnew1/ApiCallingPage/ViewVideoReview.dart';
import 'package:wherenxnew1/UserScerrn/VideoReviewDetailsScreen.dart';
import 'package:wherenxnew1/model/SinglePageDetails.dart';
import 'package:wherenxnew1/modelclass/DeletePinData.dart';
import 'package:wherenxnew1/modelclass/PinCountResponse.dart';
import 'package:wherenxnew1/modelclass/ViewReviewResponse.dart';
import '../ApiCallingPage/PinThePlaceFile.dart';
import '../ApiCallingPage/ViewUserProfileImage.dart';
import '../ApiImplement/ViewDialog.dart';
import '../Dimension.dart';
import '../Helper/img.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../Routes/RouteHelper.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../modelclass/PinPlace_Response.dart';
import '../modelclass/ProfileImageResponse.dart';
import '../modelclass/ShowVideoReviewResponse.dart';

enum Share {
  facebook,
  twitter,
  whatsapp,
  whatsapp_business,
  share_system,
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List images = [
    "star-icon.png",
    "direction-s.png",
    "Pin-s.png",
  ];
  List item1 = [];
  List item2 = [];
  List<ReviewDetails> reviewDet = [];
  List<VideoReviewDetails> videoreviewDet = [];
  List<String> str_userinfoPin = [];

  int datadouble = 0,
      userId = 0,
      reviewlength = 0,
      videoreviewlength = 0,
      closeopenHoursDay = 0;
  String placeId = "",
      strrating = "",
      reviewlist = "",
      reviewlist1 = "",
      reviewlist2 = "",
      profileImage = "",
      openHours = "",
      closeHours = "",
      closeopenHoursDate = "",
      dateName = "",
      delightId = "",
      str_Url = "",
      insertPinStatues = "1",
      str_count = "0";

  double startlatitude1 = 0.0,
      startlongitude1 = 0.0,
      locationlatitude1 = 0.0,
      locationlongitude2 = 0.0,
      valuedistansce2 = 0.0;

  bool isVisible = false, isVisible1 = false;

  String googleApikey = "AIzaSyAuFYxq-RX0I1boI5HU5-olArirEi2Ez8k";
  SinglePageDetails singlePageDetails = SinglePageDetails();

  //String googleApikey = "AIzaSyAuFYxq-RX0I1boI5HU5-olArirEi2Ez8k";

  VideoPlayerController? controller;
  String videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  List<Widget> cards = List.generate(5, (i) => CustomCard()).toList();

  Future<SinglePageDetails> getSinglePlace() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    placeId = pre.getString("placeId") ?? "";
    delightId = pre.getString("delightId") ?? "";
    userId = pre.getInt("userId") ?? 0;
    str_userinfoPin = pre.getStringList("userinfoPin") ?? [];

    String place1 = "ChIJbVztMfYhDogRqLNzF3Xxvas";

    String strUserid = userId.toString();
    showProfileImage(strUserid);

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApikey');
    var response = await http.get(url);
    singlePageDetails = SinglePageDetails.fromJson(jsonDecode(response.body));

    String photo = singlePageDetails.result!.photos?[0].photoReference ?? "";
    var rating = singlePageDetails.result?.rating;

    if (rating == null) {
      strrating = "0.0";
    } else {
      strrating = rating.toString();
    }

    reviewlist = singlePageDetails.result?.reviews?.length.toString() ?? "";

    datadouble = singlePageDetails.result?.reviews?.length ?? 0;
    closeHours = singlePageDetails
            .result?.currentOpeningHours?.periods?[0].close?.time ??
        "";
    openHours =
        singlePageDetails.result?.currentOpeningHours?.periods?[0].open?.time ??
            "";
    closeopenHoursDate = singlePageDetails
            .result?.currentOpeningHours?.periods?[0].close?.date ??
        "";
    if (closeopenHoursDate == "") {
      dateName = "";
    } else {
      dateName = DateFormat('EEEE')
          .format(DateFormat("yyyy-MM-dd").parse(closeopenHoursDate));
    }

    // String data = getWeekdayName(int.parse(closeopenHoursDate));
    print("userdatadate $dateName   $closeopenHoursDate");
    str_Url = singlePageDetails.result!.url!;

    // SharedPreferences pre1 = await SharedPreferences.getInstance();
    pre.setString("placename", singlePageDetails.result!.name!);
    pre.setString("placeType", singlePageDetails.result!.types![0]);
    pre.setString("profileImage",
        singlePageDetails.result?.photos?[0].photoReference ?? "");
    pre.setInt(
        "profileImagehight", singlePageDetails.result?.photos?[0].width ?? 0);

    if (reviewlist.length == 0) {
      reviewlist1 = "Reviews";
      reviewlist2 = "0";
    } else {
      if (reviewlist.length == 1) {
        reviewlist1 = "0" + reviewlist + "  Reviews";
        reviewlist2 = "0" + reviewlist;
      } else {
        reviewlist1 = reviewlist + "  Reviews";
        reviewlist2 = reviewlist;
      }
    }

    if (singlePageDetails.result?.photos?.length == null) {
      isVisible1 = false;
    } else {
      isVisible1 = true;
    }

    _determinePosition1(locationlatitude1, locationlongitude2);

    bool serviceEnabler;
    LocationPermission permission;

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error("Location Permission is denide");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error("Location Permission is denide");
      }
    }

    permission = await Geolocator.checkPermission();
    Position position = await Geolocator.getCurrentPosition();
    _locationData = await location.getLocation();

    startlatitude1 = _locationData.latitude!;
    startlongitude1 = _locationData.longitude!;

    locationlatitude1 = singlePageDetails.result!.geometry!.location!.lat!;
    locationlongitude2 = singlePageDetails.result!.geometry!.location!.lng!;

    valuedistansce2 = calculateDistance2(
        startlatitude1, startlongitude1, locationlatitude1, locationlongitude2);
    String number = valuedistansce2.toStringAsFixed(2);
    double distance = double.parse(number);

    http.Response response_Count =
        await PinCoutDetails().pincoutDetails(placeId);
    var countresponse = jsonDecode(response_Count.body);
    var countResponseData = PinCountResponse.fromJson(countresponse);

    if (countResponseData.status == "200") {
      str_count = countResponseData.count.toString();
    } else {
      str_count = "0";
    }

    item1.add(strrating);
    item1.add("$distance km");
    item1.add("$str_count pins");

    item2.add(reviewlist1);
    item2.add("Directions");
    item2.add("Pins this");

    if (kDebugMode) {
      print("latitudedetails1 $startlatitude1");
      print("latitudedetails $startlongitude1");
    }
    // double value = position12 as double;

    print(photo);
    print(placeId);

    //   Future.delayed( Duration(seconds: 1)).then((value) => setState(() {}));

    return singlePageDetails;
  }

  Future<List<ReviewDetails>> getReviewdetails() async {
    reviewDet.clear();

    SharedPreferences pre = await SharedPreferences.getInstance();
    placeId = pre.getString("placeId") ?? "";
    userId = pre.getInt("userId") ?? 0;

    String strUserid = userId.toString();

    http.Response response =
        await ViewReviewList().getReviewList(strUserid, placeId);
    var jsonResponse = json.decode(response.body);
    var reviewResponse = ViewReviewResponse.fromJson(jsonResponse);

    if (reviewResponse.reviewDetails!.isNotEmpty) {
      for (int i = 0; i < reviewResponse.reviewDetails!.length; i++) {
        reviewDet.add(reviewResponse.reviewDetails![i]);
      }

      reviewlength = reviewDet.length;
    } else {
      Fluttertoast.showToast(
          msg: reviewResponse.message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    return reviewDet;

    Future.delayed(Duration(seconds: 1)).then((value) => setState(() {}));
  }

  Future<List<VideoReviewDetails>> getVideoReview() async {
    videoreviewDet.clear();

    SharedPreferences pre = await SharedPreferences.getInstance();
    placeId = pre.getString("placeId") ?? "";
    userId = pre.getInt("userId") ?? 0;

    print("userdetails $placeId  $userId");

    String strUserid = userId.toString();

    http.Response? response =
        await ViewVideoReview().viewVideoReview(strUserid, placeId);
    var jsonResponse = json.decode(response!.body);
    var videoreviewResponse = ShowVideoReviewResponse.fromJson(jsonResponse);

    if (videoreviewResponse.videoReviewDetails!.isNotEmpty) {
      for (int i = 0; i < videoreviewResponse.videoReviewDetails!.length; i++) {
        videoreviewDet.add(videoreviewResponse.videoReviewDetails![i]);
      }

      videoreviewlength = videoreviewDet.length;

      isVisible = true;
    } else {
      Fluttertoast.showToast(
          msg: videoreviewResponse.message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      isVisible = false;
    }

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));

    return videoreviewDet;
  }

  Future<String> showProfileImage(String strUserid) async {
    print("useruserid  $strUserid");

    http.Response? response =
        await ViewUserProfileImage().getProfileImage(strUserid);
    var jsonResponse = jsonDecode(response.body);
    var userResponse1 = ProfileImageResponse.fromJson(jsonResponse);

    if (userResponse1.status == "success") {
      profileImage = userResponse1.image!;
      print("userProfileimage   $profileImage");
    } else {
      profileImage = "";
    }
    return profileImage;
  }

  File? file;

  List<Data> dataList = [
    Data(name: "Facebook", imageURL: 'assets/images/facebook_share.png'),
    Data(name: "Whatsapp", imageURL: 'assets/images/whatsapp_share.png'),
    // Data(name: "Whatsapp Business",imageURL: 'assets/images/whatsappbusiness_share.png'),
    Data(name: "Twitter", imageURL: 'assets/images/twitter_share.png'),
    Data(name: "More", imageURL: 'assets/images/more_share.png'),
  ];

  String time24to12Format(String? time) {
    int timeInt = int.parse(time!);
    var timeDob = (timeInt / 100);
    String timerStr = timeDob.toString();

    int h = int.parse(timerStr.split(".").first);
    int m = int.parse(timerStr.split(".").last.split(" ").first);

    String send = "";
    if (h > 12) {
      var temp = h - 12;

      if (1 <= temp && temp <= 9) {
        // equivalent of 1 <= i && i <= 10
        send =
            "0$temp:${m.toString().length == 1 ? "0$m" : m.toString()} " "PM";
      } else {
        send = "$temp:${m.toString().length == 1 ? "0$m" : m.toString()} " "PM";
      }
    } else {
      if (1 <= h && h <= 9) {
        // equivalent of 1 <= i && i <= 10
        send = "0$h:${m.toString().length == 1 ? "0$m" : m.toString()}  " "AM";
      } else {
        send = "$h:${m.toString().length == 1 ? "0$m" : m.toString()}  " "AM";
      }
    }

    return send;
  }

  @override
  void initState() {
    super.initState();
    // getSinglePlace();
    getReviewdetails();
    getVideoReview();
    // String datetime = time24to12Format("355");
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    double? _rating;
//    IconData? _selectedIcon;

    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: getSinglePlace(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 300.0,
                      floating: false,
                      pinned: true,

                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.green,

                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        // background: Image(image:
                        //Image.asset("assets/images/food-image.png",fit: BoxFit.cover,), ),
                        background: singlePageDetails
                                    .result?.photos?[0].photoReference ==
                                null
                            ? Image.asset(Img.get('resort_restarunts.jpg'),
                                fit: BoxFit.cover)
                            : getImage(
                                "${singlePageDetails.result?.photos?[0].photoReference}",
                                "${singlePageDetails.result?.photos?[0].width}"),
                      ),
                      systemOverlayStyle: SystemUiOverlayStyle.light,

                      // leading: IconButton(
                      //   icon: const Icon(Icons.menu),
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      // ),
                      // actions: <Widget>[
                      //   IconButton(
                      //     icon: const Icon(Icons.search),
                      //     onPressed: () {},
                      //   ),// overflow menu
                      //   PopupMenuButton<String>(
                      //     onSelected: (String value){},
                      //     itemBuilder: (context) => [
                      //       PopupMenuItem(
                      //         value: "Settings",
                      //         child: Text("Settings"),
                      //       ),
                      //     ],
                      //   )
                      // ],
                    ),
                  ];
                },
                body: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFF8F8F8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 50),
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: Dimensions.screenWidth / 1.5,
                                      child: Text(
                                        singlePageDetails.result?.name ?? "",
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF212828),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 32,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.transparent),
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(const EdgeInsets.only(
                                            left: 0,
                                            right: 0,
                                          )),
                                        ),
                                        onPressed: () {
                                          String strPhotourl =
                                              "${singlePageDetails.result!.photos![0].photoReference!}";
                                          String strData =
                                              "${singlePageDetails.result!.name}, ${singlePageDetails.result!.rating}, ${singlePageDetails.result!.geometry?.location?.lat}, "
                                              " ${singlePageDetails.result!.geometry?.location?.lng}";

                                          showModalBottomSheet<void>(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    Navigator.of(context).pop(),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              10,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      margin: EdgeInsets.only(
                                                          top: 20,
                                                          left: 10,
                                                          right: 10),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFffffff),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 5.0,
                                                            // soften the shadow
                                                            spreadRadius: 5.0,
                                                            //extend the shadow
                                                            offset: Offset(
                                                              1.0,
                                                              // Move to right 5  horizontally
                                                              1.0, // Move to bottom 5 Vertically
                                                            ),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: ListView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        children: dataList
                                                            .map((data) {
                                                          return InkWell(
                                                            onTap: () {
                                                              if (data.name ==
                                                                  "Facebook") {
                                                                onButtonTap(
                                                                    Share
                                                                        .facebook,
                                                                    strData,
                                                                    strPhotourl);
                                                              } else if (data
                                                                      .name ==
                                                                  "Whatsapp") {
                                                                onButtonTap(
                                                                    Share
                                                                        .whatsapp,
                                                                    strData,
                                                                    strPhotourl);
                                                              } else if (data
                                                                      .name ==
                                                                  "Whatsapp Business") {
                                                                onButtonTap(
                                                                    Share
                                                                        .whatsapp_business,
                                                                    strData,
                                                                    strPhotourl);
                                                              } else if (data
                                                                      .name ==
                                                                  "Twitter") {
                                                                onButtonTap(
                                                                    Share
                                                                        .twitter,
                                                                    strData,
                                                                    strPhotourl);
                                                              } else if (data
                                                                      .name ==
                                                                  "More") {
                                                                onButtonTap(
                                                                    Share
                                                                        .share_system,
                                                                    strData,
                                                                    strPhotourl);
                                                              }
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .all(10),
                                                              decoration: BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          width:
                                                                              1.5,
                                                                          color:
                                                                              Colors.white))),
                                                              child: Column(
                                                                children: [
                                                                  Image.asset(
                                                                    data.imageURL,
                                                                    height: 40,
                                                                    width: 40,
                                                                  ),
                                                                  Text(data
                                                                      .name),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: const <Widget>[
                                            Image(
                                              image: AssetImage(
                                                  "assets/images/share-g.png"),
                                              width: 18,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Share",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFA1A8A9),
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      singlePageDetails.result?.types?[0] ?? "",
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          singlePageDetails.result?.openingHours
                                                      ?.openNow ==
                                                  true
                                              ? " open:  "
                                              : " close: ",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          singlePageDetails.result?.openingHours
                                                      ?.openNow ==
                                                  true
                                              ? openHours == ""
                                                  ? ""
                                                  : " Close  "
                                                      "${time24to12Format(singlePageDetails.result?.currentOpeningHours!.periods?[0].close!.time)}"
                                              : openHours == ""
                                                  ? ""
                                                  : " Open  "
                                                      "${time24to12Format(singlePageDetails.result?.currentOpeningHours!.periods?[0].open!.time)} $dateName",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            // color: Colors.blueGrey[50],
                            transform:
                                Matrix4.translationValues(0.0, -32.0, 0.0),
                            child: Center(
                              child: Wrap(
                                children: List<Widget>.generate(
                                  3,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          25, 0, 25, 0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (index == 2) {
                                            if (insertPinStatues == "1") {
                                              ViewDialog(context: context)
                                                  .showLoadingIndicator(
                                                      " Pin this Location Wait...",
                                                      "",
                                                      context);

                                              var openclose = singlePageDetails
                                                          .result
                                                          ?.businessStatus ==
                                                      "OPERATIONAL"
                                                  ? " open:  "
                                                  : " close";

                                              SharedPreferences pre =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final islogin =
                                                  pre.getBool("islogin") ??
                                                      false;
                                              final userId =
                                                  pre.getInt("userId") ?? 0;
                                              final struserId =
                                                  userId.toString();
                                              final strlat = singlePageDetails
                                                  .result!
                                                  .geometry
                                                  ?.location
                                                  ?.lat
                                                  .toString();
                                              final strlng = singlePageDetails
                                                  .result!
                                                  .geometry
                                                  ?.location
                                                  ?.lng
                                                  .toString();
                                              final placeid = singlePageDetails
                                                  .result!.placeId!;
                                              final photo = singlePageDetails
                                                      .result
                                                      ?.photos?[0]
                                                      .photoReference ??
                                                  "";

                                              http.Response response =
                                                  await PinPlaces()
                                                      .insertPinPlaces(
                                                          struserId,
                                                          delightId,
                                                          singlePageDetails
                                                              .result!
                                                              .types![0],
                                                          placeid,
                                                          strlat!,
                                                          strlng!,
                                                          singlePageDetails
                                                              .result!.name!,
                                                          "",
                                                          singlePageDetails
                                                              .result!
                                                              .vicinity!,
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          "",
                                                          photo,
                                                          singlePageDetails
                                                              .result!.rating
                                                              .toString(),
                                                          "",
                                                          str_Url,
                                                          openclose);

                                              print(response);

                                              var pinResponse =
                                                  jsonDecode(response.body);
                                              var userResponse =
                                                  PinThePlace.fromJson(
                                                      pinResponse);

                                              if (userResponse.status ==
                                                  "200") {
                                                ViewDialog(context: context)
                                                    .hideOpenDialog();
                                                insertPinStatues = "2";

                                                Fluttertoast.showToast(
                                                    msg: userResponse.message!,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);

                                                setState(() async {
                                                  //  str_userinfoPin.add(placeid);
                                                  //  SharedPreferences pre = await SharedPreferences.getInstance();
                                                  //  pre.setStringList("userinfoPin", str_userinfoPin); //save List

                                                  http.Response response_Count =
                                                      await PinCoutDetails()
                                                          .pincoutDetails(
                                                              placeId);
                                                  var countresponse =
                                                      jsonDecode(
                                                          response_Count.body);
                                                  var countResponseData =
                                                      PinCountResponse.fromJson(
                                                          countresponse);

                                                  if (countResponseData
                                                          .status ==
                                                      "200") {
                                                    str_count =
                                                        countResponseData.count
                                                            .toString();

                                                    item1
                                                        .add("$str_count pins");
                                                  } else {
                                                    str_count = "0";
                                                  }
                                                });
                                              } else {
                                                ViewDialog(context: context)
                                                    .hideOpenDialog();
                                                insertPinStatues = "1";
                                                Fluttertoast.showToast(
                                                    msg: userResponse.message!,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            } else {
                                              ViewDialog(context: context)
                                                  .showLoadingIndicator(
                                                      " Delete Pin Request Wait...",
                                                      "",
                                                      context);

                                              SharedPreferences pre =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final userId =
                                                  pre.getInt("userId") ?? 0;
                                              String struserId =
                                                  userId.toString();
                                              final placeid = singlePageDetails
                                                  .result!.placeId!;

                                              http.Response response1 =
                                                  await DeletePinRequest()
                                                      .deletePinPlaces(
                                                          struserId, placeid);
                                              print(response1);

                                              var pinResponse =
                                                  jsonDecode(response1.body);
                                              var userResponse =
                                                  DeletePinData.fromJson(
                                                      pinResponse);

                                              if (userResponse.status ==
                                                  "200") {
                                                ViewDialog(context: context)
                                                    .hideOpenDialog();
                                                insertPinStatues = "1";
                                                Fluttertoast.showToast(
                                                    msg: userResponse.message!,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);

                                                setState(() async {
                                                  // str_userinfoPin.remove(placeid);
                                                  //  SharedPreferences pre = await SharedPreferences.getInstance();
                                                  //   pre.setStringList("userinfoPin", str_userinfoPin); //save List

                                                  http.Response response_Count =
                                                      await PinCoutDetails()
                                                          .pincoutDetails(
                                                              placeId);
                                                  var countresponse =
                                                      jsonDecode(
                                                          response_Count.body);
                                                  var countResponseData =
                                                      PinCountResponse.fromJson(
                                                          countresponse);

                                                  if (countResponseData
                                                          .status ==
                                                      "200") {
                                                    str_count =
                                                        countResponseData.count
                                                            .toString();
                                                  } else {
                                                    str_count = "0";
                                                  }
                                                });
                                              } else {
                                                ViewDialog(context: context)
                                                    .hideOpenDialog();
                                                insertPinStatues = "2";
                                                Fluttertoast.showToast(
                                                    msg: userResponse.message!,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            }
                                          }

                                          setState(() async {
                                            http.Response response_Count =
                                                await PinCoutDetails()
                                                    .pincoutDetails(placeId);
                                            var countresponse =
                                                jsonDecode(response_Count.body);
                                            var countResponseData =
                                                PinCountResponse.fromJson(
                                                    countresponse);

                                            if (countResponseData.status ==
                                                "200") {
                                              str_count = countResponseData
                                                  .count
                                                  .toString();
                                            } else {
                                              str_count = "0";
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              child: Material(
                                                color:
                                                    Theme.of(context).cardColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  50),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  50),
                                                          topLeft:
                                                              Radius.circular(
                                                                  50),
                                                          topRight:
                                                              Radius.circular(
                                                                  50)),
                                                ),
                                                elevation: 4,
                                                shadowColor: Colors.black38,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  height: 60,
                                                  width: 60,
                                                  child: Image.asset(
                                                    "assets/images/" +
                                                        images[index],
                                                    width: 10,
                                                    height: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Column(
                                              children: [
                                                item1.length == 0
                                                    ? Text(
                                                        "",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      )
                                                    : Text(
                                                        item1[index],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                item1.length == 0
                                                    ? Text(
                                                        "",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      )
                                                    : Text(
                                                        item2[index],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black38,
                                                            fontSize: 12),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // child: GestureDetector(
                                      //   onTap: (){
                                      //
                                      //   },
                                      //   child: Container(
                                      //     margin: EdgeInsets.all(5),
                                      //     child: CircleAvatar(
                                      //       backgroundColor: Colors.white,
                                      //       radius: 25,
                                      //       backgroundImage: AssetImage(
                                      //           "assets/images/"+images[index],
                                      //
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "About",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  singlePageDetails
                                          .result!.editorialSummary?.overview ??
                                      "",
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              color: Colors.white,
                              elevation: 5,
                              shadowColor: Colors.black26,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 16, right: 16, top: 20, bottom: 18),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width:
                                                  Dimensions.screenWidth / 1.5,
                                              child: Text(
                                                  singlePageDetails
                                                          .result?.vicinity ??
                                                      "",
                                                  maxLines: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12)),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.call),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                singlePageDetails.result!
                                                        .formattedPhoneNumber ??
                                                    "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.blur_circular),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                                onTap: () => singlePageDetails
                                                            .result!.website ==
                                                        ""
                                                    ? ""
                                                    : _launchURL(
                                                        singlePageDetails
                                                            .result!.website),
                                                child: Container(
                                                  width:
                                                      Dimensions.screenWidth /
                                                          1.5,
                                                  child: Text(
                                                      singlePageDetails.result!
                                                              .website ??
                                                          "",
                                                      maxLines: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 12)),
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   children: [
                                    //     const Icon(Icons.email_rounded),
                                    //     const SizedBox( width: 10,),
                                    //     Row(
                                    //       children: const [
                                    //         Text("",
                                    //             maxLines: 2,
                                    //             overflow: TextOverflow.ellipsis,
                                    //             style: TextStyle(
                                    //                 color: Colors.cyan, fontSize: 12)),
                                    //       ],
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Reviews & Rating",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          singlePageDetails.result?.rating ==
                                                  null
                                              ? "0.0"
                                              : singlePageDetails.result?.rating
                                                      .toString() ??
                                                  "0",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            height: 1.8,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Container(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 1),
                                            child: RatingBarIndicator(
                                              rating: singlePageDetails
                                                          .result?.rating ==
                                                      null
                                                  ? 0.0
                                                  : singlePageDetails
                                                      .result?.rating
                                                      .toDouble(),
                                              itemBuilder: (context, index) =>
                                                  Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              direction: Axis.horizontal,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Container(
                                          height: 20,
                                          padding: const EdgeInsets.fromLTRB(
                                              7, 2, 7, 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.black26,
                                          ),
                                          child: Center(
                                              child: reviewlist2.isEmpty
                                                  ? const Text(
                                                      "0",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    )
                                                  : Text(
                                                      reviewlist2,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    )),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 36,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            side: const BorderSide(
                                              color: Color(0xFFDDE4E4),
                                            ),
                                          )),
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                          )),
                                        ),
                                        onPressed: () {
                                          Get.toNamed(
                                              RouteHelper.getaddreviewScreen());
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            SvgPicture.asset(
                                              'assets/images/plus-icon.svg',
                                              width: 16,
                                              color: const Color(0xFF00B8CA),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              "Add Review",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF00B8CA),
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ), // text
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: isVisible1,
                                  child: Container(
                                    width: Dimensions.screenWidth,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 0),
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: singlePageDetails
                                          .result?.photos?.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Get.toNamed(RouteHelper.getVideoReviewDetailsScreen());
                                          },
                                          child: Container(
                                            width: 140,
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 20),
                                            child: Card(
                                              elevation: 4,
                                              color: Colors.white,
                                              shadowColor: Colors.black87,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.size20),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                        Dimensions.size20),
                                                  ),
                                                  // image: DecorationImage(
                                                  //   image: AssetImage(
                                                  //       "assets/images/food-image.png"),
                                                  //   fit: BoxFit.cover,
                                                  // )
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  // Image border
                                                  child: SizedBox.fromSize(
                                                    size: Size.fromRadius(48),
                                                    // Image radius
                                                    child: getImage(
                                                        "${singlePageDetails.result?.photos?[index].photoReference}",
                                                        "${singlePageDetails.result?.photos?[index].width}"),

                                                    //   Column(
                                                    //   mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    //   children: [
                                                    //     const SizedBox(),
                                                    //     const Center(
                                                    //       child: Icon(
                                                    //         CupertinoIcons.play_arrow_solid,
                                                    //         color: Colors.white,
                                                    //         size: 34,
                                                    //       ),
                                                    //     ),
                                                    //     Container(
                                                    //       margin: const EdgeInsets.only(bottom: 10),
                                                    //       transform: Matrix4.translationValues(0.0, -2.0, 0.0),
                                                    //       child: Container(
                                                    //         padding: const EdgeInsets.symmetric(vertical: 1),
                                                    //         child:RatingBarIndicator(
                                                    //           rating: singlePageDetails.result?.rating ?? 0.0,
                                                    //           itemBuilder: (context, index) => Icon(
                                                    //             Icons.star,
                                                    //             color: Colors.amber,
                                                    //           ),
                                                    //           itemCount: 5,
                                                    //           itemSize: 20.0,
                                                    //           direction: Axis.horizontal,
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // )
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: isVisible,
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Video Reviews & Rating",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          ),
                                          Container(
                                            width: Dimensions.screenWidth,
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 18, 0, 0),
                                            height: 200,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: videoreviewDet.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    SharedPreferences pre =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    pre.setString(
                                                        "videoreview",
                                                        videoreviewDet[index]
                                                            .video!);
                                                    pre.setString(
                                                        "videorating",
                                                        videoreviewDet[index]
                                                            .rating!);
                                                    //Get.toNamed(RouteHelper.getVideoReviewDetailsScreen());

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => VideoReviewDetailsScreen(
                                                                filePath:
                                                                    videoreviewDet[
                                                                            index]
                                                                        .video!,
                                                                videorating:
                                                                    videoreviewDet[
                                                                            index]
                                                                        .rating!,
                                                                videoDate:
                                                                    videoreviewDet[
                                                                            index]
                                                                        .reviewDate!,
                                                                videoName:
                                                                    videoreviewDet[
                                                                            index]
                                                                        .reviewerName!,
                                                                profileImage:
                                                                    profileImage)));
                                                  },
                                                  child: Container(
                                                    width: 140,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 20),
                                                    child: Card(
                                                      elevation: 4,
                                                      color: Colors.white,
                                                      shadowColor:
                                                          Colors.black87,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    Dimensions
                                                                        .size20),
                                                      ),
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        Dimensions
                                                                            .size20),
                                                                  ),
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(
                                                                        videoreviewDet[index]
                                                                            .photo!),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                              ),
                                                          child:  Container(
                                                                alignment: Alignment.center,
                                                                padding:
                                                                    const EdgeInsets.symmetric(vertical: 1),
                                                                child: Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 1),
                                                                  height: Dimensions.size35,
                                                                  width: Dimensions.size35,
                                                                child: Image.asset('assets/images/play_button.png'),
                                                              ),

                                                                // RatingBarIndicator(
                                                                //   rating: double.parse(
                                                                //       videoreviewDet[index].rating!),
                                                                //   itemBuilder: (context, index) =>
                                                                //           Icon(Icons.star, color: Colors.amber,),
                                                                //   itemCount: 5,
                                                                //   itemSize: 20.0,
                                                                //   direction: Axis.horizontal,
                                                                // ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                Container(
                                    width: Dimensions.screenWidth,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 0),
                                    child: Column(
                                        children: List<Widget>.generate(
                                      datadouble == 0 ? 0 : datadouble,
                                      (index) {
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: Card(
                                                shadowColor: Colors.transparent,
                                                elevation: 0,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0))),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.black12,
                                                      width: 1.0,
                                                    ),
                                                  )),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 20),
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            flex: 2,
                                                            child: Container(
                                                              width: 40,
                                                              height: 40,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      10,
                                                                      0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(singlePageDetails
                                                                          .result
                                                                          ?.reviews?[
                                                                              index]
                                                                          .profilePhotoUrl ??
                                                                      ""),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 12,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width: Dimensions
                                                                              .screenWidth /
                                                                          2.5,
                                                                      child:
                                                                          Text(
                                                                        singlePageDetails.result?.reviews?[index].authorName ??
                                                                            "",
                                                                        maxLines:
                                                                            10,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      singlePageDetails
                                                                              .result!
                                                                              .reviews?[index]
                                                                              .relativeTimeDescription ??
                                                                          "",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              0),
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          0.0,
                                                                          0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            1),
                                                                    child:
                                                                        RatingBarIndicator(
                                                                      rating: singlePageDetails
                                                                              .result
                                                                              ?.reviews?[index]
                                                                              .rating
                                                                              ?.toDouble() ??
                                                                          0.0,
                                                                      itemBuilder:
                                                                          (context, index) =>
                                                                              Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                      itemCount:
                                                                          5,
                                                                      itemSize:
                                                                          20.0,
                                                                      direction:
                                                                          Axis.horizontal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Container(
                                                        width: Dimensions
                                                                .screenWidth /
                                                            1,
                                                        child: Text(
                                                          singlePageDetails
                                                                  .result
                                                                  ?.reviews?[
                                                                      index]
                                                                  .text ??
                                                              "",
                                                          maxLines: 10,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                      },
                                    ))),
                                Container(
                                    width: Dimensions.screenWidth,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 0),
                                    child: Column(
                                        children: List<Widget>.generate(
                                      reviewlength == 0 ? 0 : reviewlength,
                                      (index) {
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                25, 0, 25, 0),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: Card(
                                                shadowColor: Colors.transparent,
                                                elevation: 0,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0))),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.black12,
                                                      width: 1.0,
                                                    ),
                                                  )),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 20),
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            flex: 2,
                                                            child: Container(
                                                              width: 40,
                                                              height: 40,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      10,
                                                                      0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(
                                                                      "https://www.2designnerds.com/wherenx_user/public/images/${reviewDet[index].profilePhoto}"),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 12,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width: Dimensions
                                                                              .screenWidth /
                                                                          2.5,
                                                                      child:
                                                                          Text(
                                                                        reviewDet[index].reviewerName ??
                                                                            "",
                                                                        maxLines:
                                                                            10,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      reviewDet[index]
                                                                              .reviewDate ??
                                                                          "",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              0),
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          0.0,
                                                                          0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            1),
                                                                    child:
                                                                        RatingBarIndicator(
                                                                      rating: double.parse(
                                                                          reviewDet[index].rating ??
                                                                              "0"),
                                                                      itemBuilder:
                                                                          (context, index) =>
                                                                              Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                      itemCount:
                                                                          5,
                                                                      itemSize:
                                                                          20.0,
                                                                      direction:
                                                                          Axis.horizontal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Container(
                                                        width: Dimensions
                                                                .screenWidth /
                                                            1,
                                                        child: Text(
                                                          reviewDet[index]
                                                                  .message ??
                                                              "",
                                                          maxLines: 10,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                      },
                                    ))),
                                // Container(
                                //   height: 36,
                                //   width: 120,
                                //   child: TextButton(
                                //     style: ButtonStyle(
                                //       backgroundColor:
                                //           MaterialStateProperty.all<Color>(
                                //               Colors.white),
                                //       shape: MaterialStateProperty.all<
                                //               RoundedRectangleBorder>(
                                //           RoundedRectangleBorder(
                                //         borderRadius:
                                //             BorderRadius.circular(50.0),
                                //         side: const BorderSide(
                                //           color: Color(0xFFDDE4E4),
                                //         ),
                                //       )),
                                //       padding:
                                //           MaterialStateProperty.all<EdgeInsets>(
                                //               const EdgeInsets.only(
                                //         left: 12,
                                //         right: 12,
                                //       )),
                                //     ),
                                //     onPressed: () {},
                                //     child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: const <Widget>[
                                //         Text(
                                //           "Load More",
                                //           textAlign: TextAlign.center,
                                //           style: TextStyle(
                                //               fontSize: 13,
                                //               color: Color(0xFF00B8CA),
                                //               fontWeight: FontWeight.normal),
                                //         ), // text
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  Image getImage(String photoReference, String maxwidth) {
    var baseurl = "https://maps.googleapis.com/maps/api/place/photo";
    // var maxwidth = "100";
    // var maxHeight = "100";
    final url =
        "$baseurl?maxwidth=$maxwidth&photo_reference=$photoReference&key=$googleApikey";
    return Image.network(
      url,
      filterQuality: FilterQuality.high,
      fit: BoxFit.cover,
    );
  }

  String getImage1(String photoReference) {
    var baseurl = "https://maps.googleapis.com/maps/api/place/photo";
    var maxWidth = "2000";
    //var maxHeight = "110";
    final url =
        "$baseurl?maxwidth=$maxWidth&photo_reference=$photoReference&key=$googleApikey";
    return url;
  }

  Future showDialog123456() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            elevation: 0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFffffff),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 5.0, //extend the shadow
                      offset: Offset(
                        1.0, // Move to right 5  horizontally
                        1.0, // Move to bottom 5 Vertically
                      ),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: dataList.map((data) {
                    return InkWell(
                      onTap: () {
                        if (data.name == "Facebook") {
                          onButtonTap(Share.facebook, "", "");
                        } else if (data.name == "Whatsapp") {
                          onButtonTap(Share.whatsapp, "", "");
                        } else if (data.name == "Whatsapp Business") {
                          onButtonTap(Share.whatsapp_business, "", "");
                        } else if (data.name == "Twitter") {
                          onButtonTap(Share.twitter, "", "");
                        } else if (data.name == "More") {
                          onButtonTap(Share.share_system, "", "");
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.5, color: Colors.white))),
                        child: Column(
                          children: [
                            Image.asset(
                              data.imageURL,
                              height: 40,
                              width: 40,
                            ),
                            Text(data.name),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )));
      },
    );
  }

  Future<void> _launchURL(String? url) async {
    final Uri uri = Uri.parse(url!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // if (!await launchUrl(_url)) {
  //   throw Exception('Could not launch $_url');
  // }

  Future<void> onButtonTap(
      Share share, String strData, String strPhotourl) async {
    String url = getImage1(strPhotourl);
    String msg = "$strData, $str_Url";

    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      // case Share.messenger:
      //   response = await flutterShareMe.shareToMessenger(url: url, msg: msg);
      //   break;
      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
        break;
      case Share.whatsapp:
        if (file != null) {
          response =
              await flutterShareMe.shareToWhatsApp(imagePath: url, msg: msg);
        } else {
          response = await flutterShareMe.shareToWhatsApp(msg: msg);
        }
        break;
      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(
          msg: msg,
        );
        break;
      // case Share.whatsapp_personal:
      //   response = await flutterShareMe.shareWhatsAppPersonalMessage(
      //       message: msg, phoneNumber: 'phone-number-with-country-code');
      //   break;
      // case Share.share_instagram:
      //   response = await flutterShareMe.shareToInstagram(
      //       filePath: file!.path,
      //       fileType: videoEnable ? FileType.video : FileType.image);
      //   break;
      // case Share.share_telegram:
      //   response = await flutterShareMe.shareToTelegram(msg: msg);
      //   break;
    }
    debugPrint(response);
  }

  void Left_indicator_bar_Flushbar(BuildContext context, String Message) {
    Flushbar(
      message: Message,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      duration: const Duration(seconds: 3),
      leftBarIndicatorColor: Colors.red[300],
    ).show(context);
  }

  _determinePosition1(double latitude, double longitude) async {
    bool serviceEnabler;
    LocationPermission permission;

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error("Location Permission is denide");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error("Location Permission is denide");
      }
    }

    permission = await Geolocator.checkPermission();
    Position position = await Geolocator.getCurrentPosition();
    _locationData = await location.getLocation();

    startlatitude1 = _locationData.latitude!;
    startlongitude1 = _locationData.longitude!;

    valuedistansce2 = calculateDistance2(
        startlatitude1, startlongitude1, latitude, longitude);

    if (kDebugMode) {
      print("latitudedetails1 $startlatitude1");
      print("latitudedetails $startlongitude1");
    }

    // Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  double calculateDistance2(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

class CustomCard extends StatelessWidget {
  CustomCard({super.key});

  SinglePageDetails singlePageDetails = SinglePageDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Card(
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(0))),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 1.0,
                  ),
                )),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/review-img.png"),
                                fit: BoxFit.cover,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 12,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Jason Smith",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                  Text(
                                    "2 Days",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 0),
                                transform:
                                    Matrix4.translationValues(0.0, 0, 0.0),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.star,
                                      color: CupertinoColors.systemYellow,
                                      size: 14,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: CupertinoColors.systemYellow,
                                      size: 14,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: CupertinoColors.systemYellow,
                                      size: 14,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: CupertinoColors.systemYellow,
                                      size: 14,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: CupertinoColors.systemYellow,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Data {
  String name;
  String imageURL;

  Data({required this.name, required this.imageURL});
}

class VideoPlayerList extends StatefulWidget {
  String? video;

  VideoPlayerList(this.video, {super.key});

  @override
  State<VideoPlayerList> createState() => _VideoPlayerListState();
}

class _VideoPlayerListState extends State<VideoPlayerList> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    print("userdetails${widget.video}");
    controller = VideoPlayerController.networkUrl(Uri.parse(
        "https://www.2designnerds.com/wherenx_user/public/${widget.video}"));

    controller?.addListener(() {
      setState(() {});
    });
    controller?.setLooping(true);
    controller?.initialize().then((_) => setState(() {}));
    controller?.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            if (controller!.value.isPlaying) {
              controller?.pause();
            } else {
              controller?.play();
            }
          },
          child: Container(
            width: 140,
            height: 50,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shadowColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.size20),
              ),
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
