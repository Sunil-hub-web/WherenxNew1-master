import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wherenxnew1/ApiCallingPage/Addevent.dart';

import '../ApiImplement/ViewDialog.dart';
import '../Helper/img.dart';
import '../Routes/RouteHelper.dart';
import '../videorecording/FileCompressionApi.dart';
import 'package:http/http.dart' as http;

class AddEventsDetails extends StatefulWidget {
  const AddEventsDetails({super.key});

  @override
  State<AddEventsDetails> createState() => _AddEventsDetailsState();
}

class _AddEventsDetailsState extends State<AddEventsDetails> {
  TextEditingController textYouName = TextEditingController();
  TextEditingController textYourEventName = TextEditingController();
  TextEditingController textEventType = TextEditingController();
  TextEditingController textEventAddress = TextEditingController();
  TextEditingController textEventDescription = TextEditingController();
  TextEditingController currentDateTime = TextEditingController();

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  List<String> filepathdet = [];
  File? galleryFile;
  String filePath1 = "", videofilepath = "";
  bool isImageVisiable = false, isVideoVisiable = false;
  MediaInfo? compressedVideoInfo;
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      // ignore: unnecessary_null_comparison
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        print("imagelist $imagefiles");

        for (int i = 0; i < imagefiles!.length; i++) {
          filepathdet.add(imagefiles![i].path);
        }
        isImageVisiable = true;
        print("Yourdatafile  $filepathdet");
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
      () async {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
          genThumbnailFile(galleryFile?.path);
          print("imagevideo${galleryFile?.path}");
          File file = new File(galleryFile!.path);
          final info = await FileCompressionApi.compressVideo(file);
          compressedVideoInfo = info;
          var filePath = compressedVideoInfo?.file?.path;
          videofilepath = filePath!;
          print("videofilepath  $videofilepath");

          // MediaInfo? compressedVideoInfo = info;
          _videoPlayerController =
              VideoPlayerController.networkUrl(Uri.parse(videofilepath));
          await _videoPlayerController?.initialize();
          await _videoPlayerController?.setLooping(true);
          await _videoPlayerController?.play();

          isVideoVisiable = true;
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
        String formattedDate =
            DateFormat('yyyy-MM-dd - HH:mm').format(pickedDate);
        currentDateTime.text = formattedDate.toString();
      });
  }

  dateTimePickerWidget(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate) {
      // After selecting the date, display the time picker.
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          // Handle the selected date and time here.
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            print(selectedDateTime);
            setState(() {
              currentDate = selectedDateTime;
              String formattedDate =
                  DateFormat('d MMM, yyyy  hh:mm').format(selectedDateTime);
              currentDateTime.text = formattedDate.toString();
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
  }

  Future genThumbnailFile(String? filePath) async {
    var imagefilepath = await VideoThumbnail.thumbnailFile(
      video: filePath!,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 200,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    setState(() {
      final file = File(imagefilepath!);
      filePath1 = file.path;
    });

    print("filepathimage${filePath1}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(
              "assets/images/arrow.png",
              height: 20,
              width: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Create Events",
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                // Container(
                //   margin: const EdgeInsets.all(15),
                //   child: Text(
                //     "Upload Event Details",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //         fontSize: 17.sp,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black87),
                //   ),
                // ),
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
                Visibility(
                  visible: isImageVisiable,
                  child: Container(
                    height: 20.h,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filepathdet.length,
                        itemBuilder: (context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 20.h,
                              width: (30.w),
                              margin: const EdgeInsets.only(
                                  top: 5, left: 5, right: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                // Image border
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(48),
                                  // Image radius
                                  child: Image.file(File(filepathdet[index]),
                                      fit: BoxFit
                                          .cover) /*Image.network(nearbyLocations[index].icon!,)*/,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                // Visibility(
                //   visible: isVideoVisiable,
                //   child: Container(
                //     height: 20.h,
                //     width: MediaQuery.of(context).size.width,
                //     child: VideoPlayer(_videoPlayerController!)
                //   ),
                // ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: textYouName,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          hintText: 'Enter Your Name Here',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(1),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: textYourEventName,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          hintText: 'Enter Your Event Name Here',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(1),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: textEventType,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          hintText: 'Event Type',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(1),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      onTap: () {
                        // _selectDate(context);
                        dateTimePickerWidget(context);
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
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
                Container(
                  margin: const EdgeInsets.all(1),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: textEventAddress,
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: 'Event Address',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(1),
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: textEventDescription,
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

                      if (textYouName.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(context, "Enter User Name");
                      } else if (textYourEventName.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Enter User Event Name");
                      } else if (textEventType.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Enter User Event Type");
                      } else if (textEventAddress.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Enter User Event Address");
                      } else if (textEventDescription.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Enter User Event Description");
                      } else if (currentDateTime.text.toString().isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Select Event Date Time");
                      } else if (filepathdet.isEmpty) {
                        Left_indicator_bar_Flushbar(
                            context, "Select Your Event Image");
                      } else {
                        ViewDialog(context: context).showLoadingIndicator(
                            "Create Event Wait...", "Event Details", context);

                        SharedPreferences pre =
                            await SharedPreferences.getInstance();
                        int userId = pre.getInt("userId") ?? 0;
                        String str_userId = userId.toString();

                        http.StreamedResponse? response = await Addevent()
                            .addEventDetails(
                                str_userId,
                                textYouName.text.toString(),
                                textYouName.text.toString(),
                                textEventType.text.toString(),
                                currentDateTime.text.toString(),
                                textEventAddress.text.toString(),
                                textEventDescription.text.toString(),
                                videofilepath,
                                filepathdet);

                        print(
                            "usereventdetails ${str_userId}  ${textYouName.text.toString()}  ${textYouName.text.toString()}  ${textEventType.text.toString()}  "
                            "${currentDateTime.text.toString()}  ${textEventAddress.text.toString()}  ${textEventDescription.text.toString()}  "
                            "${videofilepath}  ${filepathdet}");

                        var respStr = await response?.stream.bytesToString();
                        print("userdataresponse  $respStr");
                        print("userdataresponse1  $response");
                        print("userdataresponse2  ${response?.statusCode}");

                        if (response?.statusCode == 200) {
                          ViewDialog(context: context).hideOpenDialog();

                          //  print("show your message ${await response?.stream.bytesToString()}");

                          Fluttertoast.showToast(
                              msg: "Event successfully create.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);

                          textYouName.text = "";
                        } else {
                          ViewDialog(context: context).hideOpenDialog();

                          print("show your message1${response?.reasonPhrase}");

                          Fluttertoast.showToast(
                              msg: "Event not create.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      }
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
        ));
  }

  void Left_indicator_bar_Flushbar(BuildContext context, String Message) {
    Flushbar(
      message: Message,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: Colors.red[300],
    )..show(context);
  }
}
