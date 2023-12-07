import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wherenxnew1/ApiCallingPage/AddFavoriteEvent.dart';
import 'package:wherenxnew1/ApiCallingPage/EventDelete.dart';
import 'package:wherenxnew1/ApiCallingPage/FavoriteEventDelete.dart';
import 'package:wherenxnew1/ApiCallingPage/ViewFavoriteEvent.dart';
import 'package:wherenxnew1/UserScerrn/AddEventsDetails.dart';
import 'package:wherenxnew1/UserScerrn/EditEventDetails.dart';
import 'package:wherenxnew1/UserScerrn/HomeScreen.dart';
import 'package:wherenxnew1/UserScerrn/ViewSingleEvent.dart';
import 'package:wherenxnew1/modelclass/DeleteEventResponse.dart';
import 'package:wherenxnew1/modelclass/EventSuccsessResponse.dart';
import 'package:wherenxnew1/modelclass/SuccessResponse.dart';

import '../ApiCallingPage/ViewEventData.dart';
import '../ApiImplement/ViewDialog.dart';
import '../Dimension.dart';
import '../Helper/img.dart';
import '../modelclass/ViewEventResponse.dart';
import 'package:http/http.dart' as http;

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  TextEditingController textarea = TextEditingController();
  TextEditingController currentDateTime = TextEditingController();

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  File? galleryFile;
  String filePath1 = "",
      selectedIndex1 = "0",
      selectedIndex2 = "3",
      selectClickEvent = "click1";
  bool isfavourite = true,
      isnotfavourite = false,
      eventlistdata = true,
      faveventdata = false;
  int selectedIndex = -1;

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      // ignore: unnecessary_null_comparison
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        setState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  Future getVideo(
    ImageSource img,
  ) async {
    // Pick an image
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

// Pick a video
    // final XFile? image = await _picker.pickVideo(source: ImageSource.gallery);
    final pickedFile = await imgpicker.pickVideo(
      source: img,
      //preferredCameraDevice: CameraDevice.front,
      // maxDuration: const Duration(minutes: 10)
    );
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
          genThumbnailFile(galleryFile?.path);
          print("imagevideo${galleryFile?.path}");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  DateTime currentDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        currentDateTime.text = currentDate.toString();
      });
  }

  Future genThumbnailFile(String? path) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
        video: path!,
        // thumbnailPath: _tempDir,
        imageFormat: ImageFormat.JPEG,
        //maxHeightOrWidth: 0,
        maxHeight: 3,
        maxWidth: 2,
        quality: 10);

    setState(() {
      final file = File(thumbnail!);
      filePath1 = file.path;
    });

    print("filepathimage${filePath1}");
  }

  String profileImage = "";
  List<ViewEventResponse> visereventresponse = [];
  List<Data> vieweventdata = [];
  List<PeventImage> profileimage = [];

  Future<List<Data>> showEventData() async {

    vieweventdata.clear();

    if (selectClickEvent == "click1") {

     //  vieweventdata.clear();

      eventlistdata = true;
      faveventdata = false;

      http.Response? response = await ViewEventData().getEventData();
      var jsonResponse = json.decode(response!.body);
      var eventdataresponse = ViewEventResponse.fromJson(jsonResponse);

      if (eventdataresponse.status == "200") {
         vieweventdata.clear();
        if (eventdataresponse.data!.isNotEmpty) {
          for (int i = 0; i < eventdataresponse.data!.length; i++) {
            vieweventdata.add(eventdataresponse.data![i]);
          }
        }
      }else{

         Fluttertoast.showToast(
            msg: "Event Not Exist",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      print("userdatalist ${vieweventdata.toString()}");

    } else {

      // vieweventdata.clear();

      eventlistdata = false;
      faveventdata = true;

      SharedPreferences pre = await SharedPreferences.getInstance();
      int userId = pre.getInt("userId") ?? 0;
      String str_userId = userId.toString();

      http.Response? response =
          await ViewFavoriteEvent().getFavroitEvents(str_userId);
      var jsonResponse = json.decode(response!.body);
      var eventdataresponse = ViewEventResponse.fromJson(jsonResponse);

      if (eventdataresponse.status == "200") {
        vieweventdata.clear();
        if (eventdataresponse.data!.isNotEmpty) {
          for (int i = 0; i < eventdataresponse.data!.length; i++) {
            vieweventdata.add(eventdataresponse.data![i]);
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: "Favorite Event Not Exist",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    return vieweventdata;
  }



  Future<bool> removePayment() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove("payment");
  }

  // @override
  // void initState() {
  //   super.initState();
  //   initializePreference().whenComplete(() {
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, Orientation, ScreenType) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Event",
              style: TextStyle(color: Colors.black),
            ),
            //backgroundColor: const Color(0xFF00B8CA),
            backgroundColor: const Color(0xFFF8F8F8),
            leading: IconButton(
              icon: Image.asset(
                "assets/images/arrow.png",
                height: 20,
                width: 20,
                color: Colors.black,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // showDialog(
              //   barrierColor: Colors.black26,
              //   context: context,
              //   builder: (context) {
              //     return setupAlertDialoadContainer();
              //   },
              // );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEventsDetails()),
              );
            },
            label: const Text('Upload Event'),
            icon: const Icon(Icons.add),
          ),
          // backgroundColor: Colors.white10,
          body: Container(
              height: 82.h,
              width: 100.w,
              color: const Color(0xFFF8F8F8),
              /* decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(6.123234262925839e-17, 1),
                  end: Alignment(-1, 6.123234262925839e-17),
                  colors: [
                    Color.fromRGBO(31, 203, 220, 1),
                    Color.fromRGBO(0, 184, 202, 1)
                  ]),
            ),*/
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(2),
                          decoration: selectedIndex1 == "0"
                              ? ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF1FCBDC),
                                      Color(0xFF00B8CA)
                                    ],
                                  ),
                                )
                              : ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    side: BorderSide(
                                      color: Color(0xFFDDE4E4),
                                    ),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.white, Colors.white],
                                  ),
                                ),
                          height: 5.h,
                          width: 45.w,
                          child: ElevatedButton(
                            onPressed: () async {
                              //Get.toNamed(RouteHelper.getotpScreenpage());
                              // Get.back();

                              if (selectedIndex1 == "0") {
                                selectedIndex1 = "1";
                                selectedIndex2 = "2";
                              } else {
                                selectedIndex1 = "0";
                                selectedIndex2 = "3";
                              }

                              selectClickEvent = "click1";

                                eventlistdata = true;
                                faveventdata = false;

                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              minimumSize:
                                  Size(MediaQuery.of(context).size.width, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), // <-- Radius
                              ),
                            ),
                            child: Text('Event',
                                style: TextStyle(
                                    color: selectedIndex1 == "0"
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15)),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(2),
                          decoration: selectedIndex2 == "3"
                              ? ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    side: BorderSide(
                                      color: Color(0xFFDDE4E4),
                                    ),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.white, Colors.white],
                                  ),
                                )
                              : ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF1FCBDC),
                                      Color(0xFF00B8CA)
                                    ],
                                  ),
                                ),
                          height: 5.h,
                          width: 45.w,
                          child: ElevatedButton(
                            onPressed: () async {
                              //Get.toNamed(RouteHelper.getotpScreenpage());
                              // Get.back();

                              if (selectedIndex2 == "3") {
                                selectedIndex1 = "1";
                                selectedIndex2 = "2";
                              } else {
                                selectedIndex1 = "0";
                                selectedIndex2 = "3";
                              }

                              selectClickEvent = "click2";

                                eventlistdata = false;
                                faveventdata = true;

                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              minimumSize:
                                  Size(MediaQuery.of(context).size.width, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), // <-- Radius
                              ),
                            ),
                            child: Text('Favorite Event',
                                style: TextStyle(
                                    color: selectedIndex2 == "3"
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Visibility(
                        visible: eventlistdata,
                        child: FutureBuilder(
                            future: showEventData(),
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: 75.h,
                                  width: 100.w,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: vieweventdata.length,
                                      itemBuilder: (context, int index) {
                                        return GestureDetector(
                                          child: SizedBox(
                                              width: 100.w,
                                              height: 44.h,
                                              child: Card(
                                                  elevation: 5,
                                                  shadowColor: Colors.black12,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          final route =
                                                              MaterialPageRoute(
                                                            fullscreenDialog:
                                                                true,
                                                            builder: (_) =>
                                                                ViewSingleEvent(
                                                                    eventId: vieweventdata[
                                                                            index]
                                                                        .id!),
                                                          );
                                                          Navigator.push(
                                                              context, route);
                                                        },
                                                        child: Container(
                                                          height: 20.h,
                                                          width: 100.w,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            left: 5,
                                                            right: 5,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        Dimensions
                                                                            .size20),
                                                                  ),
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        NetworkImage(
                                                                      vieweventdata[
                                                                              index]
                                                                          .peventImage![
                                                                              0]
                                                                          .image!,
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 100.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 7.w,
                                                                  height: 5.h,
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  margin: const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      10,
                                                                      0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: profileImage ==
                                                                            ""
                                                                        ? const DecorationImage(
                                                                            image:
                                                                                AssetImage('assets/images/profileimage.jpg'), //Your Background image
                                                                          )
                                                                        : DecorationImage(
                                                                            image:
                                                                                NetworkImage(profileImage),
                                                                            fit:
                                                                                BoxFit.cover,

                                                                            //Your Background image
                                                                          ),
                                                                    border: Border.all(
                                                                        width:
                                                                            2.0,
                                                                        color: Colors
                                                                            .white),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${vieweventdata[index].userName}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.sp),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    // isfavourite = false;
                                                                    // isnotfavourite = true;
                                                                    selectedIndex =
                                                                        index;
                                                                    int currentIndex =
                                                                        index;

                                                                    ViewDialog(context: context).showLoadingIndicator(
                                                                        " Add Favorite Event Request Wait...",
                                                                        "Event Details",
                                                                        context);

                                                                    int? ida =
                                                                        vieweventdata[index]
                                                                            .id;
                                                                    String
                                                                        str_ida =
                                                                        ida.toString();
                                                                    int? idb = vieweventdata[
                                                                            index]
                                                                        .userId;
                                                                    String
                                                                        str_idb =
                                                                        idb.toString();

                                                                    http.Response
                                                                        response1 =
                                                                        await AddFavoriteEvent().addFavoriteEventDet(
                                                                            str_ida,
                                                                            str_idb);
                                                                    print(
                                                                        response1);

                                                                    var pinResponse =
                                                                        jsonDecode(
                                                                            response1.body);
                                                                    var userResponse =
                                                                        SuccessResponse.fromJson(
                                                                            pinResponse);

                                                                    if (userResponse
                                                                            .status ==
                                                                        "failed") {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    } else {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      setState(
                                                                          () {
                                                                        selectedIndex =
                                                                            index;
                                                                        int currentIndex =
                                                                            index;

                                                                        //  SharedPreferences pre = await SharedPreferences.getInstance();
                                                                        // pre.setStringList("userinfoPin", str_userinfoPin);//save List
                                                                      });

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    }

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Visibility(
                                                                    visible:
                                                                        isfavourite,
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              5),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              1),
                                                                      child:
                                                                          Container(
                                                                        margin: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                1),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white12,
                                                                          borderRadius:
                                                                              BorderRadius.all(
                                                                            Radius.circular(Dimensions.size20),
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            3.h,
                                                                        width:
                                                                            8.w,
                                                                        child: selectedIndex ==
                                                                                index
                                                                            ? Image.asset('assets/images/favourite2.png')
                                                                            : Image.asset('assets/images/favourite1.png'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                /* InkWell(
                                                      onTap: () {
                                                       // isfavourite = true;
                                                      //  isnotfavourite = false;
                                                        selectedIndex = index;
                                                        setState(() {});
                                                      },
                                                      child: Visibility(
                                                        visible: selectedIndex == -1 ? isnotfavourite = false : selectedIndex == index ? isnotfavourite = false :  isfavourite = true,
                                                        child: Container(
                                                          alignment: Alignment
                                                              .topRight,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  5),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      1),
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .size20),
                                                              ),
                                                            ),
                                                            height: 4.h,
                                                            width: 9.w,
                                                            child: Image.asset(
                                                                'assets/images/favourite2.png'),
                                                          ),
                                                        ),
                                                      ),
                                                    )*/
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 4.h),
                                                            child: Text(
                                                                "${vieweventdata[index].eventName}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp)),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 4.h),
                                                            child: Text(
                                                                "${vieweventdata[index].startEventDatetime}   ${vieweventdata[index].endEventDatetime}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp)),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 7.w,
                                                              height: 5.h,
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
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
                                                                    const DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/location.png'),
                                                                  //Your Background image
                                                                ),
                                                                border: Border.all(
                                                                    width: 2.0,
                                                                    color: Colors
                                                                        .white),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${vieweventdata[index].eventAddress}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.sp),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                height: 4.h,
                                                                width: 16.w,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  gradient: const LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment.bottomCenter,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                            31,
                                                                            203,
                                                                            220,
                                                                            1),
                                                                        Color.fromRGBO(
                                                                            0,
                                                                            184,
                                                                            202,
                                                                            1)
                                                                      ]),
                                                                ),
                                                                child:
                                                                    TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            5.0),
                                                                    textStyle: const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    List<String>
                                                                        dataimage =
                                                                        [];

                                                                    vieweventdata[
                                                                            index]
                                                                        .peventImage
                                                                        ?.forEach(
                                                                            (item) {
                                                                      dataimage.add(
                                                                          "${item.image}");
                                                                      print(
                                                                          "${item.id}: ${item.image}");
                                                                    });

                                                                    SharedPreferences preferences =
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    preferences.setInt(
                                                                        "eventId",
                                                                        vieweventdata[index].id ?? 0);
                                                                    preferences.setString(
                                                                        "userName",
                                                                        vieweventdata[index].userName ?? "");
                                                                    preferences.setString(
                                                                        "eventName",
                                                                        vieweventdata[index].eventName ?? "");
                                                                    preferences.setString(
                                                                        "eventType",
                                                                        vieweventdata[index].eventType ?? "");
                                                                    preferences.setString(
                                                                        "eventDate",
                                                                        vieweventdata[index].startEventDatetime ?? "");
                                                                     preferences.setString(
                                                                        "endeventDate",
                                                                        vieweventdata[index].endEventDatetime ?? "");
                                                                    preferences.setString(
                                                                        "eventAddress",
                                                                        vieweventdata[index].eventAddress ?? "");
                                                                    preferences.setString(
                                                                        "eventDesc",
                                                                        vieweventdata[index].eventDescription ?? "");
                                                                    preferences.setStringList(
                                                                        "evevtimagelist",
                                                                        dataimage);

                                                                    print("userDetaildataq   ${vieweventdata[index].eventName}");

                                                                    Navigator.push(context,
                                                                      MaterialPageRoute(builder: (context) =>
                                                                              const EditEventDetails()),);
                                                                  },
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Text(
                                                                        "  Edit",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                      ),
                                                                      // text
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 4.h,
                                                                width: 18.w,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  gradient: const LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment.bottomCenter,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                            31,
                                                                            203,
                                                                            220,
                                                                            1),
                                                                        Color.fromRGBO(
                                                                            0,
                                                                            184,
                                                                            202,
                                                                            1)
                                                                      ]),
                                                                ),
                                                                child:
                                                                    TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            5.0),
                                                                    textStyle: const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    int currentIndex =
                                                                        index;

                                                                    ViewDialog(context: context).showLoadingIndicator(
                                                                        " Delete Event Request Wait...",
                                                                        "Event Details",
                                                                        context);

                                                                    int? ida =
                                                                        vieweventdata[index]
                                                                            .id;
                                                                    String
                                                                        str_id =
                                                                        ida.toString();

                                                                    http.Response
                                                                        response1 =
                                                                        await EventDelete()
                                                                            .deleteEventDetails(str_id);
                                                                    print(
                                                                        response1);

                                                                    var pinResponse =
                                                                        jsonDecode(
                                                                            response1.body);
                                                                    var userResponse =
                                                                        DeleteEventResponse.fromJson(
                                                                            pinResponse);

                                                                    if (userResponse
                                                                            .status ==
                                                                        "200") {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      setState(
                                                                          () {
                                                                        vieweventdata
                                                                            .removeAt(currentIndex);
                                                                        vieweventdata.removeWhere((item) =>
                                                                            item.id ==
                                                                            ida);

                                                                        //  SharedPreferences pre = await SharedPreferences.getInstance();
                                                                        // pre.setStringList("userinfoPin", str_userinfoPin);//save List
                                                                      });

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    } else {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    }
                                                                  },
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Text(
                                                                        "Delete",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                      ),
                                                                      // text
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ))),
                                        );
                                      }),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
                      ),
                      Visibility(
                        visible: faveventdata,
                        child: FutureBuilder(
                            future: showEventData(),
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: 75.h,
                                  width: 100.w,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: vieweventdata.length,
                                      itemBuilder: (context, int index) {
                                        return GestureDetector(
                                          child: SizedBox(
                                              width: 100.w,
                                              height: 44.h,
                                              child: Card(
                                                  elevation: 5,
                                                  shadowColor: Colors.black12,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          final route =
                                                              MaterialPageRoute(
                                                            fullscreenDialog:
                                                                true,
                                                            builder: (_) =>
                                                                ViewSingleEvent(
                                                                    eventId: vieweventdata[
                                                                            index]
                                                                        .id!),
                                                          );
                                                          Navigator.push(
                                                              context, route);
                                                        },
                                                        child: Container(
                                                          height: 20.h,
                                                          width: 100.w,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            left: 5,
                                                            right: 5,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        Dimensions
                                                                            .size20),
                                                                  ),
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        NetworkImage(
                                                                      vieweventdata[
                                                                              index]
                                                                          .peventImage![
                                                                              0]
                                                                          .image!,
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 100.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 7.w,
                                                                  height: 5.h,
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  margin: const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      10,
                                                                      0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: profileImage ==
                                                                            ""
                                                                        ? const DecorationImage(
                                                                            image:
                                                                                AssetImage('assets/images/profileimage.jpg'), //Your Background image
                                                                          )
                                                                        : DecorationImage(
                                                                            image:
                                                                                NetworkImage(profileImage),
                                                                            fit:
                                                                                BoxFit.cover,

                                                                            //Your Background image
                                                                          ),
                                                                    border: Border.all(
                                                                        width:
                                                                            2.0,
                                                                        color: Colors
                                                                            .white),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${vieweventdata[index].userName}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.sp),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () async {},
                                                                  child: Visibility(
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              5),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              1),
                                                                      child:
                                                                          Container(
                                                                        margin: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                1),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white12,
                                                                          borderRadius:
                                                                              BorderRadius.all(
                                                                            Radius.circular(Dimensions.size20),
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            3.h,
                                                                        width:
                                                                            8.w,
                                                                        child: Image.asset(
                                                                            'assets/images/favourite2.png'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                /* InkWell(
                                                      onTap: () {
                                                       // isfavourite = true;
                                                      //  isnotfavourite = false;
                                                        selectedIndex = index;
                                                        setState(() {});
                                                      },
                                                      child: Visibility(
                                                        visible: selectedIndex == -1 ? isnotfavourite = false : selectedIndex == index ? isnotfavourite = false :  isfavourite = true,
                                                        child: Container(
                                                          alignment: Alignment
                                                              .topRight,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  5),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      1),
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .size20),
                                                              ),
                                                            ),
                                                            height: 4.h,
                                                            width: 9.w,
                                                            child: Image.asset(
                                                                'assets/images/favourite2.png'),
                                                          ),
                                                        ),
                                                      ),
                                                    )*/
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 4.h),
                                                            child: Text(
                                                                "${vieweventdata[index].eventName}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp)),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 4.h),
                                                            child: Text(
                                                                "${vieweventdata[index].startEventDatetime}  ${vieweventdata[index].endEventDatetime}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.sp)),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 7.w,
                                                              height: 5.h,
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
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
                                                                    const DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/location.png'),
                                                                  //Your Background image
                                                                ),
                                                                border: Border.all(
                                                                    width: 2.0,
                                                                    color: Colors
                                                                        .white),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${vieweventdata[index].eventAddress}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.sp),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Container(
                                                              //   height: 4.h,
                                                              //   width: 16.w,
                                                              //   margin:
                                                              //       EdgeInsets.only(
                                                              //           right: 10),
                                                              //   decoration:
                                                              //       BoxDecoration(
                                                              //     borderRadius:
                                                              //         BorderRadius
                                                              //             .circular(
                                                              //                 25),
                                                              //     gradient: const LinearGradient(
                                                              //         begin: Alignment
                                                              //             .topCenter,
                                                              //         end: Alignment
                                                              //             .bottomCenter,
                                                              //         colors: [
                                                              //           Color
                                                              //               .fromRGBO(
                                                              //                   31,
                                                              //                   203,
                                                              //                   220,
                                                              //                   1),
                                                              //           Color
                                                              //               .fromRGBO(
                                                              //                   0,
                                                              //                   184,
                                                              //                   202,
                                                              //                   1)
                                                              //         ]),
                                                              //   ),
                                                              //   child: TextButton(
                                                              //     style: TextButton
                                                              //         .styleFrom(
                                                              //       foregroundColor:
                                                              //           Colors.white,
                                                              //       padding:
                                                              //           const EdgeInsets
                                                              //               .only(
                                                              //               left: 10,
                                                              //               right: 10,
                                                              //               top: 5.0,
                                                              //               bottom:
                                                              //                   5.0),
                                                              //       textStyle:
                                                              //           const TextStyle(
                                                              //               fontSize:
                                                              //                   13),
                                                              //     ),
                                                              //     onPressed:
                                                              //         () async {
                                                              //       List<String>
                                                              //           dataimage =
                                                              //           [];
                                                              //
                                                              //       vieweventdata[
                                                              //               index]
                                                              //           .peventImage
                                                              //           ?.forEach(
                                                              //               (item) {
                                                              //         dataimage.add(
                                                              //             "${item.image}");
                                                              //         print(
                                                              //             "${item.id}: ${item.image}");
                                                              //       });
                                                              //
                                                              //       preferences =
                                                              //           await SharedPreferences
                                                              //               .getInstance();
                                                              //       preferences?.setString(
                                                              //           "userName",
                                                              //           "${vieweventdata[index].userName}");
                                                              //       preferences?.setString(
                                                              //           "eventName",
                                                              //           "${vieweventdata[index].eventName}");
                                                              //       preferences?.setString(
                                                              //           "eventType",
                                                              //           "${vieweventdata[index].eventType}");
                                                              //       preferences?.setString(
                                                              //           "eventDate",
                                                              //           "${vieweventdata[index].eventDatetime}");
                                                              //       preferences?.setString(
                                                              //           "eventAddress",
                                                              //           "${vieweventdata[index].eventAddress}");
                                                              //       preferences?.setString(
                                                              //           "eventDesc",
                                                              //           "${vieweventdata[index].eventDescription}");
                                                              //       preferences
                                                              //           ?.setStringList(
                                                              //               "evevtimagelist",
                                                              //               dataimage);
                                                              //
                                                              //       Navigator.push(
                                                              //         context,
                                                              //         MaterialPageRoute(
                                                              //             builder:
                                                              //                 (context) =>
                                                              //                     const EventDetails()),
                                                              //       );
                                                              //     },
                                                              //     child: Row(
                                                              //       children: <Widget>[
                                                              //         const SizedBox(
                                                              //           width: 5,
                                                              //         ),
                                                              //         const Text(
                                                              //           "  Edit",
                                                              //           textAlign:
                                                              //               TextAlign
                                                              //                   .center,
                                                              //           style:
                                                              //               TextStyle(
                                                              //             fontSize:
                                                              //                 13,
                                                              //             color: Colors
                                                              //                 .white,
                                                              //             fontWeight:
                                                              //                 FontWeight
                                                              //                     .normal,
                                                              //           ),
                                                              //         ),
                                                              //         // text
                                                              //       ],
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              Container(
                                                                height: 4.h,
                                                                width: 18.w,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  gradient: const LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment.bottomCenter,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                            31,
                                                                            203,
                                                                            220,
                                                                            1),
                                                                        Color.fromRGBO(
                                                                            0,
                                                                            184,
                                                                            202,
                                                                            1)
                                                                      ]),
                                                                ),
                                                                child:
                                                                    TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            5.0),
                                                                    textStyle: const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    int currentIndex =
                                                                        index;

                                                                    ViewDialog(context: context).showLoadingIndicator(
                                                                        " Delete Favroit Event Request Wait...",
                                                                        "Event Details",
                                                                        context);

                                                                    int? ida = vieweventdata[index].id;
                                                                    String str_ida = ida.toString();
                                                                    int? idb = vieweventdata[index].userId;
                                                                    String str_idb = idb.toString();

                                                                    http.Response
                                                                        response1 =
                                                                        await FavoriteEventDelete()
                                                                            .deleteFavoriteEventDetails(str_ida,str_idb);
                                                                    print(
                                                                        response1);

                                                                    var pinResponse =
                                                                        jsonDecode(
                                                                            response1.body);
                                                                    var userResponse =
                                                                        EventSuccsessResponse.fromJson(
                                                                            pinResponse);

                                                                    if (userResponse
                                                                            .status ==
                                                                        "200") {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      setState(
                                                                          () {
                                                                        vieweventdata
                                                                            .removeAt(currentIndex);
                                                                        vieweventdata.removeWhere((item) =>
                                                                            item.id ==
                                                                            ida);

                                                                        //  SharedPreferences pre = await SharedPreferences.getInstance();
                                                                        // pre.setStringList("userinfoPin", str_userinfoPin);//save List
                                                                      });

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    } else {
                                                                      ViewDialog(
                                                                              context: context)
                                                                          .hideOpenDialog();

                                                                      Fluttertoast.showToast(
                                                                          msg: userResponse
                                                                              .message!,
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .BOTTOM,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          backgroundColor: Colors
                                                                              .green,
                                                                          textColor: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16.0);
                                                                    }
                                                                  },
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Text(
                                                                        "Delete",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                      ),
                                                                      // text
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ))),
                                        );
                                      }),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
                      )
                    ],
                  )
                ],
              )));
    });
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 100.h,
      width: 100.w,
      margin: EdgeInsets.all(5),
      //  width: MediaQuery.of(context).size.width,
      child: Dialog(
        elevation: 0,
        backgroundColor: Color(0xffffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   margin: const EdgeInsets.all(5),
            //   child: Column(
            //     children: [
            //       filePath1 == ""
            //           ? Card(
            //               elevation: 5,
            //               shadowColor: Colors.black,
            //               color: Colors.white,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Image.asset(
            //                 'assets/images/eventimage.jpg',
            //                 height: 100,
            //                 width: 100,
            //               ),
            //             )
            //           : Card(
            //               elevation: 5,
            //               shadowColor: Colors.black,
            //               color: Colors.white,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Image.file(
            //                 File(filePath1),
            //                 height: 100,
            //                 width: 100,
            //               ),
            //             )
            //     ],
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.all(15),
              child: Text(
                "Upload Event Details",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    openImages();
                    if (kDebugMode) {
                      print("imagedetails$imagefiles");
                      // Navigator.of(context).pop();
                    }
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/images.png',
                            height: 50,
                            width: 50,
                          ),
                          Text("Uplod Image")
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    getVideo(ImageSource.gallery);
                    //   Navigator.of(context).pop();
                    // print("imagedetails123${galleryFile?.path}");
                  },
                  child: Card(
                      elevation: 5,
                      shadowColor: Colors.black,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/uploading.png',
                              height: 50,
                              width: 50,
                            ),
                            Text("Uplod Video")
                          ],
                        ),
                      )),
                )
              ],
            ),
            // Container(
            //   margin: const EdgeInsets.all(5),
            //   child: Card(
            //     elevation: 5,
            //     shadowColor: Colors.black,
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: TextFormField(
            //       controller: textarea,
            //       minLines: 1,
            //       keyboardType: TextInputType.multiline,
            //       decoration: InputDecoration(
            //           contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            //           hintText: 'Enter Your Name Here',
            //           hintStyle: TextStyle(color: Colors.grey),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(10)),
            //           )),
            //     ),
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.all(5),
            //   child: Card(
            //     elevation: 5,
            //     shadowColor: Colors.black,
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: TextFormField(
            //       controller: textarea,
            //       minLines: 1,
            //       keyboardType: TextInputType.multiline,
            //       decoration: InputDecoration(
            //           contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            //           hintText: 'Enter Your Event Name Here',
            //           hintStyle: TextStyle(color: Colors.grey),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(10)),
            //           )),
            //     ),
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.all(5),
            //   child: Card(
            //     elevation: 5,
            //     shadowColor: Colors.black,
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: TextFormField(
            //       controller: textarea,
            //       minLines: 1,
            //       keyboardType: TextInputType.multiline,
            //       decoration: InputDecoration(
            //           contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            //           hintText: 'Event Type',
            //           hintStyle: TextStyle(color: Colors.grey),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(10)),
            //           )),
            //     ),
            //   ),
            // ),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.black,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: currentDateTime,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        hintText: 'Select Date And Time',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: Card(
                elevation: 5,
                shadowColor: Colors.black,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: textarea,
                  minLines: 5,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      hintText: 'Enter Event Description Here',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1FCBDC), Color(0xFF00B8CA)],
                ),
              ),
              height: 46,
              child: ElevatedButton(
                onPressed: () async {
                  //Get.toNamed(RouteHelper.getotpScreenpage());
                  // Get.back();
                },
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  minimumSize: Size(MediaQuery.of(context).size.width, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                ),
                child: const Text('Publish Your Event Now',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
