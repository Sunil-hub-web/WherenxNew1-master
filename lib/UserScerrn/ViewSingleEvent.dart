import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wherenxnew1/UserScerrn/EventDetails.dart';

import '../ApiCallingPage/ViewSingleEventList.dart';
import 'package:http/http.dart' as http;

import '../ApiCallingPage/ViewUserProfileImage.dart';
import '../Dimension.dart';
import '../modelclass/ProfileImageResponse.dart';
import '../modelclass/SingleEventResponse.dart';

class ViewSingleEvent extends StatefulWidget {
  final int eventId;

  ViewSingleEvent({super.key, required this.eventId});

  @override
  State<ViewSingleEvent> createState() => _ViewSingleEventState();
}

class _ViewSingleEventState extends State<ViewSingleEvent> {
  String profileImage = "",
      username = "",
      eventname = "",
      eventtype = "",
      eventdatetime = "",
      eventaddress = "",
      eventdescription = "",
      eventdescription1 = "",
      eventvideo = "";
  int userId = 0;
  bool isfavourite = true, isnotfavourite = false;

  List<PeventImage> eventImageDeta = [];
  late VideoPlayerController _videoPlayerController;

  // late Future<void> _initializeVideoPlayerFuture;

  Future<String?> showEventData() async {
    String str_eventId = widget.eventId.toString();

    http.Response? response =
        await ViewSingleEventList().viewSingleEventList(str_eventId);
    var jsonResponse = json.decode(response.body);
    var eventdataresponse = SingleEventResponse.fromJson(jsonResponse);

    if (eventdataresponse.status == "200") {
      Fluttertoast.showToast(
          msg: eventdataresponse.message ?? "",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      username = eventdataresponse.data?[0].userName ?? "";
      eventname = eventdataresponse.data?[0].eventName ?? "";
      eventtype = eventdataresponse.data?[0].eventType ?? "";
      eventdatetime = eventdataresponse.data?[0].eventDatetime ?? "";
      eventaddress = eventdataresponse.data?[0].eventAddress ?? "";
      eventdescription = eventdataresponse.data?[0].eventDescription ?? "";
      eventvideo = eventdataresponse.data?[0].eventVideo ?? "";
      eventImageDeta = eventdataresponse.data?[0].peventImage ?? [];

      eventdescription1 =
          "Most apps contain several screens for displaying different types of information. "
          "For example, an app might have a screen that displays products. When the user taps the image of a "
          "product, a new screen displays details about the product.";

      //   _initVideoPlayer(eventvideo);
    } else {
      Fluttertoast.showToast(
          msg: eventdataresponse.message ?? "",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));

    return eventdataresponse.status;
  }

  Future _initVideoPlayer(String videopath) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        "https://www.profileace.com/wherenx_user/public/${videopath}"));
    await _videoPlayerController.initialize();
    //_initializeVideoPlayerFuture = _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.pause();
  }

  Future<String> showProfileImage() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    userId = pre.getInt("userId") ?? 0;
    String strUserid = userId.toString();

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
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
    return profileImage;
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _videoPlayerController.dispose();
    _videoPlayerController.pause();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //showEventData();
    showProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, Orientation, ScreenType) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Image.asset(
                "assets/images/arrow.png",
                height: 20,
                width: 20,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventDetails()),
              ),
            ),
            backgroundColor: Colors.white,
            title: Text(
              "View Event Details",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: Colors.white10,
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                width: MediaQuery.of(context).size.width,
                height: 100.h,
                child: Card(
                    elevation: 5,
                    shadowColor: Colors.black12,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: FutureBuilder(
                        future: showEventData(),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Container(
                                //   height: 25.h,
                                //   width: 100.w,
                                //   margin: const EdgeInsets.only(
                                //     top: 5,
                                //     left: 5,
                                //     right: 5,
                                //   ),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     borderRadius: BorderRadius.all(
                                //       Radius.circular(12),
                                //     ),
                                //   ),
                                //   child: ClipRRect(
                                //     borderRadius: BorderRadius.circular(20),
                                //     // Image border
                                //     child: SizedBox.fromSize(
                                //       size: Size.fromRadius(48),
                                //       // Image radius
                                //       child: FutureBuilder(
                                //         future: _initVideoPlayer(eventvideo),
                                //         builder: (context, snapshot) {
                                //           if (snapshot.connectionState ==
                                //               ConnectionState.done) {
                                //             // If the VideoPlayerController has finished initialization, use
                                //             // the data it provides to limit the aspect ratio of the video.
                                //             return AspectRatio(
                                //               aspectRatio: _videoPlayerController
                                //                   .value.aspectRatio,
                                //               // Use the VideoPlayer widget to display the video.
                                //               child: GestureDetector(
                                //                   onTap: () {
                                //                     setState(() {
                                //                       // If the video is playing, pause it.
                                //                       if (_videoPlayerController.value.isPlaying) {
                                //                         _videoPlayerController.pause();
                                //                       } else {
                                //                         // If the video is paused, play it.
                                //                         _videoPlayerController.play();
                                //                       }
                                //                     });
                                //                   },
                                //                   child: VideoPlayer(_videoPlayerController)),
                                //             );
                                //           } else {
                                //             // If the VideoPlayerController is still initializing, show a
                                //             // loading spinner.
                                //             return Center(
                                //                 child: CircularProgressIndicator());
                                //           }
                                //         },
                                //       ), /*Image.network(nearbyLocations[index].icon!,)*/
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  height: 25.h,
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
                                  child: ListView.builder(
                                    itemCount: eventImageDeta.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 35.h,
                                        width: 80.w,
                                        margin: EdgeInsets.all(5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // Image border
                                          child: SizedBox.fromSize(
                                            size: Size.fromRadius(48),
                                            // Image radius
                                            child: Image.network(
                                                eventImageDeta[index].image!,
                                                height: 35.h,
                                                width: 80.w,
                                                fit: BoxFit
                                                    .cover) /*Image.network(nearbyLocations[index].icon!,)*/,
                                          ),
                                        ),
                                      );
                                    },
                                    scrollDirection: Axis.horizontal,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                Text("${username}")
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    isfavourite = false;
                                                    isnotfavourite = true;
                                                    setState(() {});
                                                  },
                                                  child: Visibility(
                                                    visible: isfavourite,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      margin: EdgeInsets.all(5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1),
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(5),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white12,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                Dimensions
                                                                    .size20),
                                                          ),
                                                        ),
                                                        height: 4.h,
                                                        width: 9.w,
                                                        child: Image.asset(
                                                            'assets/images/favourite1.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    isfavourite = true;
                                                    isnotfavourite = false;
                                                    setState(() {});
                                                  },
                                                  child: Visibility(
                                                    visible: isnotfavourite,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      margin: EdgeInsets.all(5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1),
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(5),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white12,
                                                          borderRadius:
                                                              BorderRadius.all(
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
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 4.h),
                                        child: Text("${eventname}",
                                            style: TextStyle()),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 4.h),
                                        child: Text("${eventdatetime}",
                                            style: TextStyle()),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 7.w,
                                            height: 5.h,
                                            alignment: Alignment.topRight,
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 0, 10, 0),
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
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
                                          Text("${eventaddress}")
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 4.h),
                                        child: Text("${eventdescription}",
                                            style: TextStyle()),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        })),
              ),
            ),
          ));
    });
  }
}
