import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wherenxnew1/ApiCallingPage/ViewEventData.dart';

import '../Dimension.dart';
import '../Helper/img.dart';
import '../modelclass/ViewEventResponse.dart';
import 'package:http/http.dart' as http;

class ViewEventDetails extends StatefulWidget {
  ViewEventDetails({super.key});

  @override
  State<ViewEventDetails> createState() => _ViewEventDetailsState();
}

class _ViewEventDetailsState extends State<ViewEventDetails> {
  String profileImage = "";
  List<ViewEventResponse> visereventresponse = [];
  List<Data> vieweventdata = [];
  bool isfavourite = true, isnotfavourite = false;

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

    return vieweventdata;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, Orientation, ScreenType) {
      return Scaffold(
          body: SizedBox(
              height: 100.h,
              width: 100.h,
              child: FutureBuilder(
                  future: showEventData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: 100.w,
                        height: 60.h,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: vieweventdata.length,
                            itemBuilder: (context, int index) {
                              return Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                width: MediaQuery.of(context).size.width,
                                height: 38.h,
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
                                              child: Image.asset(
                                                  Img.get(
                                                      'resort_restarunts.jpg'),
                                                  fit: BoxFit
                                                      .cover) /*Image.network(nearbyLocations[index].icon!,)*/,
                                            ),
                                          )),
                                     Container(
                                       width: 100.h,
                                       child:   Row(
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
                                                  "${vieweventdata[index].userName}")
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
                                                        .symmetric(vertical: 1),
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1),
                                                      decoration: BoxDecoration(
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
                                                        .symmetric(vertical: 1),
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1),
                                                      decoration: BoxDecoration(
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
                                        child: Text(
                                            "${vieweventdata[index].eventName}",
                                            style: TextStyle()),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 4.h),
                                        child: Text(
                                            "${vieweventdata[index].startEventDatetime} +"  "+${vieweventdata[index].endEventDatetime}",
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
                                          Text(
                                              "${vieweventdata[index].eventAddress}")
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })));
    });
  }
}
