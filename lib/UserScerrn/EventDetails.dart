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
          title: const Text("Event"),
          backgroundColor: const Color(0xFF00B8CA),
          leading: IconButton(
              icon: Image.asset(
                "assets/images/arrow.png",
                height: 20,
                width: 20,
                color: Colors.white,
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
            height: 100.h,
            width: 100.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(6.123234262925839e-17, 1),
                  end: Alignment(-1, 6.123234262925839e-17),
                  colors: [
                    Color.fromRGBO(31, 203, 220, 1),
                    Color.fromRGBO(0, 184, 202, 1)
                  ]),
            ),
            child: FutureBuilder(
                future: showEventData(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      width: 100.w,
                      height: 70.h,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: vieweventdata.length,
                          itemBuilder: (context, int index) {
                            return InkWell(
                              onTap: () {
                                final route = MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_) =>
                                      ViewSingleEvent(eventId: vieweventdata[index].id!),
                                );
                                Navigator.push(context, route);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                width: MediaQuery.of(context).size.width,
                                height: 43.h,
                                child: Card(
                                  elevation: 5,
                                  shadowColor: Colors.black12,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 20.h,
                                        width: 100.w,
                                        margin: const EdgeInsets.only(
                                          top: 5,
                                          left: 5,
                                          right: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12),
                                          ),
                                        ),
                                        child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // Image border
                                              child: SizedBox.fromSize(
                                                size: Size.fromRadius(48),
                                                // Image radius
                                                child: Image.network(
                                                    vieweventdata[index]
                                                        .peventImage![0]
                                                        .image!,
                                                    fit: BoxFit
                                                        .cover) /*Image.network(nearbyLocations[index].icon!,)*/,
                                              ),
                                            )
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 7.w,
                                                  height: 5.h,
                                                  alignment: Alignment.topRight,
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 10, 0),
                                                  decoration: BoxDecoration(
                                                    image: profileImage == ""
                                                        ? const DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/profileimage.jpg'), //Your Background image
                                                          )
                                                        : DecorationImage(
                                                            image: NetworkImage(
                                                                profileImage),
                                                            fit: BoxFit.cover,

                                                            //Your Background image
                                                          ),
                                                    border: Border.all(
                                                        width: 2.0,
                                                        color: Colors.white),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Text(
                                                    "${vieweventdata[index].userName}",
                                                style: TextStyle(fontSize: 15.sp),)
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 4.h),
                                              child: Text(
                                                  "${vieweventdata[index].eventName}",
                                                  style: TextStyle(fontSize: 15.sp)),
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(left: 4.h),
                                              child: Text(
                                                  "${vieweventdata[index].eventDatetime}",
                                                  style: TextStyle(fontSize: 15.sp)),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 7.w,
                                                  height: 5.h,
                                                  alignment: Alignment.topRight,
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 10, 0),
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
                                                style: TextStyle(fontSize: 15.sp),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
      );
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
