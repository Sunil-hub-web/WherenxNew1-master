import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wherenxnew1/UserScerrn/AddEventsDetails.dart';
import 'package:wherenxnew1/UserScerrn/HomeScreen.dart';
import 'package:wherenxnew1/UserScerrn/ViewSingleEvent.dart';

import '../ApiCallingPage/ViewEventData.dart';
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
  String filePath1 = "";
  bool isfavourite = true, isnotfavourite = false;
  int selectedIndex = -1, selectedIndex1 = -1;

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

    http.Response? response = await ViewEventData().getEventData();
    var jsonResponse = json.decode(response!.body);
    var eventdataresponse = ViewEventResponse.fromJson(jsonResponse);

    if (eventdataresponse.status == "200") {
      if (eventdataresponse.data!.isNotEmpty) {
        for (int i = 0; i < eventdataresponse.data!.length; i++) {
          vieweventdata.add(eventdataresponse.data![i]);
        }
      }
    }

    print("userdatalist ${vieweventdata.toString()}");

    return vieweventdata;
  }

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
            height: 85.h,
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
            child: Container(
              child: FutureBuilder(
                  future: showEventData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 60.h,
                        width: 100.w,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: vieweventdata.length,
                            itemBuilder: (context, int index) {
                              return GestureDetector(
                                child: Container(
                                    width: 100.w,
                                    height: 44.h,
                                    child: Card(
                                        elevation: 5,
                                        shadowColor: Colors.black12,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                final route = MaterialPageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (_) =>
                                                      ViewSingleEvent(
                                                          eventId: vieweventdata[index].id!),
                                                );
                                                Navigator.push(context, route);
                                              },
                                              child: Container(
                                                height: 20.h,
                                                width: 100.w,
                                                margin: const EdgeInsets.only(
                                                  top: 10,
                                                  left: 5,
                                                  right: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(
                                                          Dimensions.size20),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        vieweventdata[index]
                                                            .peventImage![0]
                                                            .image!,
                                                      ),
                                                      fit: BoxFit.cover,
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 7.w,
                                                        height: 5.h,
                                                        alignment:
                                                            Alignment.topRight,
                                                        margin: const EdgeInsets
                                                            .fromLTRB(
                                                            0, 0, 10, 0),
                                                        decoration:
                                                            BoxDecoration(
                                                          image: profileImage ==
                                                                  ""
                                                              ? const DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/profileimage.jpg'), //Your Background image
                                                                )
                                                              : DecorationImage(
                                                                  image: NetworkImage(
                                                                      profileImage),
                                                                  fit: BoxFit
                                                                      .cover,

                                                                  //Your Background image
                                                                ),
                                                          border: Border.all(
                                                              width: 2.0,
                                                              color:
                                                                  Colors.white),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${vieweventdata[index].userName}",
                                                        style: TextStyle(
                                                            fontSize: 15.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          // isfavourite = false;
                                                          // isnotfavourite = true;
                                                          selectedIndex = index;

                                                          setState(() {});
                                                        },
                                                        child: Visibility(
                                                          visible: isfavourite,
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
                                                              height: 3.h,
                                                              width: 8.w,
                                                              child: selectedIndex ==
                                                                      index
                                                                  ? Image.asset(
                                                                      'assets/images/favourite2.png')
                                                                  : Image.asset(
                                                                      'assets/images/favourite1.png'),
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
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                  Container(
                                              margin:
                                                  EdgeInsets.only(left: 4.h),
                                              child: Text(
                                                  "${vieweventdata[index].eventName}",
                                                  style: TextStyle(
                                                      fontSize: 15.sp)),
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(left: 4.h),
                                              child: Text(
                                                  "${vieweventdata[index].eventDatetime}",
                                                  style: TextStyle(
                                                      fontSize: 15.sp)),
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
                                                        Alignment.topRight,
                                                    margin: const EdgeInsets
                                                        .fromLTRB(0, 0, 10, 0),
                                                    decoration: BoxDecoration(
                                                      image:
                                                          const DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/location.png'),
                                                        //Your Background image
                                                      ),
                                                      border: Border.all(
                                                          width: 2.0,
                                                          color: Colors.white),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${vieweventdata[index].eventAddress}",
                                                    style: TextStyle(
                                                        fontSize: 15.sp),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                 Container(
                                              height: 4.h,
                                              width: 18.w,
                                              margin: EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                gradient: const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color.fromRGBO(
                                                          31, 203, 220, 1),
                                                      Color.fromRGBO(
                                                          0, 184, 202, 1)
                                                    ]),
                                              ),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 5.0,
                                                          bottom: 5.0),
                                                  textStyle: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                onPressed: () {},
                                                child: Row(
                                                  children: <Widget>[
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.normal,
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
                                        ))),
                              );
                            }),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ));
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
