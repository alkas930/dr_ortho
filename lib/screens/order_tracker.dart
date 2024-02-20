// // ignore_for_file: library_private_types_in_public_api

// import 'dart:convert';
// import 'package:drortho/components/searchcomponent.dart';
// import 'package:drortho/models/order_tracker.dart';
// import 'package:drortho/utilities/loadingWrapperWithoutProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:order_tracker_zen/order_tracker_zen.dart';

// class OrderTracker extends StatefulWidget {
//   const OrderTracker({
//     super.key,
//   });

//   @override
//   State<OrderTracker> createState() => _OrderTrackerState();
// }

// List<Map<String, dynamic>> data = [];

// class _OrderTrackerState extends State<OrderTracker> {
//   // Future<void> fetchData() async {
//   //   try {
//   //     // Read the JSON file
//   //     String jsonString = await DefaultAssetBundle.of(context)
//   //         .loadString('assets/trackOrder.json');
//   //     final jsonData = jsonDecode(jsonString);

//   //     print('***********************${jsonData}');
//   //     setState(() {
//   //       data = List<Map<String, dynamic>>.from(
//   //           jsonData['tracking_data']['shipment_track_activities']);
//   //     });
//   //   } catch (e) {
//   //     print('Error: $e');
//   //   }
//   // }

//   Future<ShipmentTrack> loadTrackingData() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/trackOrder.json');
//     return ShipmentTrack.fromJson(jsonDecode(jsonString));
//   }

//   late Future<ShipmentTrack> _orderTrackingData;

//   @override
//   void initState() {
//     super.initState();
//     // fetchData();
//     _orderTrackingData = loadTrackingData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<ShipmentTrack>(
//         future: _orderTrackingData,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final data = snapshot.data!;
//             return _buildTrackingList(data); // Call UI building function
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error loading data'));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       // body: Column(
//       //   children: [
//       //     const SearchComponent(
//       //       isBackEnabled: true,
//       //     ),
//       //     Padding(
//       //       padding: const EdgeInsets.all(20),
//       //       child: OrderTrackerZen(tracker_data: [
//       //         TrackerData(
//       //           title: 'Order Placed',
//       //           date: "Sat, 8 Apr '22",
//       //           tracker_details: [
//       //             TrackerDetails(
//       //               title: "Your order was placed on DrOrtho",
//       //               datetime: "Sat, 8 Apr '22 - 17:17",
//       //             ),
//       //             TrackerDetails(
//       //               title: "Zenzzen Arranged A Callback Request",
//       //               datetime: "Sat, 8 Apr '22 - 17:42",
//       //             ),
//       //           ],
//       //         ),
//       //         TrackerData(
//       //           title: 'Order Shipped',
//       //           date: "Sat, 8 Apr '22",
//       //           tracker_details: [
//       //             TrackerDetails(
//       //               title: "Your order was shipped with MailDeli",
//       //               datetime: "Sat, 8 Apr '22 - 17:17",
//       //             ),
//       //             TrackerDetails(
//       //               title: "Zenzzen Arranged A Callback Request",
//       //               datetime: "Sat, 8 Apr '22 - 17:42",
//       //             ),
//       //           ],
//       //         ),
//       //         TrackerData(
//       //           title: 'Order Delivered',
//       //           date: "Sat, 8 Apr '22",
//       //           tracker_details: [
//       //             TrackerDetails(
//       //               title: "You received your order, by MailDeli",
//       //               datetime: "Sat, 8 Apr '22 - 17:17",
//       //             ),
//       //           ],
//       //         )
//       //       ]),
//       //     ),

//       //   ],
//       // ),
//     );
//   }

//   Widget _buildTrackingList(ShipmentTrack data) {
//     return ListView.builder(
//       itemCount: data.shipmentId,
//       itemBuilder: (context, index) {
//         final track = data.shipmentId;

//         // ... (logic to format and display data points like awb_code, courier_name, current_status, delivered_date)

//         return Card(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Display order details
//                 // ...

//                 // Display current status with color based on status
//                 // ...

//                 // Optionally display timestamps or activity history
//                 // ...

//                 // // Display POD image if available
//                 // if (track.pod != null)
//                 //   AdvancedNetworkImage(
//                 //     imageUrl: track.pod,
//                 //     placeholder: CircularProgressIndicator(),
//                 //     errorWidget: Icon(Icons.error),
//                 //   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:drortho/components/searchcomponent.dart';
// import 'package:flutter/material.dart';
// import 'package:order_tracker_zen/order_tracker_zen.dart';

// enum OrderStatus { Processing, Shipped, Delivered }

// class OrderTracker extends StatelessWidget {
//   final OrderStatus? status;

//   OrderTracker({this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const SearchComponent(
//             isBackEnabled: true,
//           ),
//           _buildStatusWidget("Processing", OrderStatus.Processing),
//           _buildStatusWidget("Shipped", OrderStatus.Shipped),
//           _buildStatusWidget("Delivered", OrderStatus.Delivered),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: OrderTrackerZen(tracker_data: [
//               TrackerData(
//                 title: 'Order Placed',
//                 date: "Sat, 8 Apr '22",
//                 tracker_details: [
//                   TrackerDetails(
//                     title: "Your order was placed on DrOrtho",
//                     datetime: "Sat, 8 Apr '22 - 17:17",
//                   ),
//                   TrackerDetails(
//                     title: "Zenzzen Arranged A Callback Request",
//                     datetime: "Sat, 8 Apr '22 - 17:42",
//                   ),
//                 ],
//               ),
//               TrackerData(
//                 title: 'Order Shipped',
//                 date: "Sat, 8 Apr '22",
//                 tracker_details: [
//                   TrackerDetails(
//                     title: "Your order was shipped with MailDeli",
//                     datetime: "Sat, 8 Apr '22 - 17:17",
//                   ),
//                   TrackerDetails(
//                     title: "Zenzzen Arranged A Callback Request",
//                     datetime: "Sat, 8 Apr '22 - 17:42",
//                   ),
//                 ],
//               ),
//               TrackerData(
//                 title: 'Order Delivered',
//                 date: "Sat, 8 Apr '22",
//                 tracker_details: [
//                   TrackerDetails(
//                     title: "You received your order, by MailDeli",
//                     datetime: "Sat, 8 Apr '22 - 17:17",
//                   ),
//                 ],
//               )
//             ]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusWidget(String title, OrderStatus orderStatus) {
//     return Row(
//       children: [
//         _buildStatusIcon(orderStatus),
//         const SizedBox(width: 10),
//         Text(title),
//       ],
//     );
//   }

//   Widget _buildStatusIcon(OrderStatus orderStatus) {
//     IconData iconData;
//     Color color;
//     switch (orderStatus) {
//       case OrderStatus.Processing:
//         iconData = Icons.check;
//         color = status == OrderStatus.Processing ? Colors.green : Colors.grey;
//         break;
//       case OrderStatus.Shipped:
//         iconData = Icons.check;
//         color = status == OrderStatus.Shipped ? Colors.green : Colors.grey;
//         break;
//       case OrderStatus.Delivered:
//         iconData = Icons.check;
//         color = status == OrderStatus.Delivered ? Colors.green : Colors.grey;
//         break;
//     }

//     return Icon(
//       iconData,
//       color: color,
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:drortho/components/searchcomponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TrackingData {
  final int trackStatus;
  final int shipmentStatus;
  final List<Map<String, dynamic>> shipmentTrack;
  final List<Map<String, dynamic>> shipmentTrackActivities;
  final String trackUrl;
  final String etd;

  TrackingData({
    required this.trackStatus,
    required this.shipmentStatus,
    required this.shipmentTrack,
    required this.shipmentTrackActivities,
    required this.trackUrl,
    required this.etd,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      trackStatus: json['tracking_data']['track_status'],
      shipmentStatus: json['tracking_data']['shipment_status'],
      shipmentTrack: List<Map<String, dynamic>>.from(
          json['tracking_data']['shipment_track']),
      shipmentTrackActivities: List<Map<String, dynamic>>.from(
          json['tracking_data']['shipment_track_activities']),
      trackUrl: json['tracking_data']['track_url'],
      etd: json['tracking_data']['etd'],
    );
  }
}

class PackageTracker extends StatefulWidget {
  const PackageTracker({super.key});

  @override
  _PackageTrackerState createState() => _PackageTrackerState();
}

class _PackageTrackerState extends State<PackageTracker> {
  late TrackingData trackingData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String jsonString = '''{
      "tracking_data": {
          "track_status": 1,
          "shipment_status": 7,
          "shipment_track": [
              {
                  "id": 236612717,
                  "awb_code": "141123221084922",
                  "courier_company_id": 51,
                  "shipment_id": 236612717,
                  "order_id": 237157589,
                  "pickup_date": "2022-07-18 20:28:00",
                  "delivered_date": "2022-07-19 11:37:00",
                  "weight": "0.30",
                  "packages": 1,
                  "current_status": "Delivered",
                  "delivered_to": "Chittoor",
                  "destination": "Chittoor",
                  "consignee_name": "",
                  "origin": "Banglore",
                  "courier_agent_details": null,
                  "courier_name": "Xpressbees Surface",
                  "edd": null,
                  "pod": "Available",
                  "pod_status": "https://s3-ap-southeast-1.amazonaws.com/kr-shipmultichannel/courier/51/pod/141123221084922.png"
              }
          ],
          "shipment_track_activities": [
              {
                  "date": "2022-07-19 11:37:00",
                  "status": "DLVD",
                  "activity": "Delivered",
                  "location": "MADANPALLI, Madanapalli, ANDHRA PRADESH",
                  "sr-status": "7",
                  "sr-status-label": "DELIVERED"
              },
              {
                  "date": "2022-07-19 08:57:00",
                  "status": "OFD",
                  "activity": "Out for Delivery Out for delivery: 383439-Nandinayani Reddy Bhaskara Sitics Logistics  (356231) (383439)-PDS22200085719383439-FromMob , MobileNo:- 9963133564",
                  "location": "MADANPALLI, Madanapalli, ANDHRA PRADESH",
                  "sr-status": "17",
                  "sr-status-label": "OUT FOR DELIVERY"
              },
              {
                  "date": "2022-07-19 07:33:00",
                  "status": "RAD",
                  "activity": "Reached at Destination Shipment BagOut From Bag : nxbg03894488",
                  "location": "MADANPALLI, Madanapalli, ANDHRA PRADESH",
                  "sr-status": "38",
                  "sr-status-label": "REACHED AT DESTINATION HUB"
              },
              {
                  "date": "2022-07-18 21:02:00",
                  "status": "IT",
                  "activity": "InTransit Shipment added in Bag nxbg03894488",
                  "location": "BLR/FC1, BANGALORE, KARNATAKA",
                  "sr-status": "18",
                  "sr-status-label": "IN TRANSIT"
              },
              {
                  "date": "2022-07-18 20:28:00",
                  "status": "PKD",
                  "activity": "Picked Shipment InScan from Manifest",
                  "location": "BLR/FC1, BANGALORE, KARNATAKA",
                  "sr-status": "6",
                  "sr-status-label": "SHIPPED"
              },
              {
                  "date": "2022-07-18 13:50:00",
                  "status": "PUD",
                  "activity": "PickDone ",
                  "location": "RTO/CHD, BANGALORE, KARNATAKA",
                  "sr-status": "42",
                  "sr-status-label": "PICKED UP"
              },
              {
                  "date": "2022-07-18 10:04:00",
                  "status": "OFP",
                  "activity": "Out for Pickup ",
                  "location": "RTO/CHD, BANGALORE, KARNATAKA",
                  "sr-status": "19",
                  "sr-status-label": "OUT FOR PICKUP"
              },
              {
                  "date": "2022-07-18 09:51:00",
                  "status": "DRC",
                  "activity": "Pending Manifest Data Received",
                  "location": "RTO/CHD, BANGALORE, KARNATAKA",
                  "sr-status": "NA",
                  "sr-status-label": "NA"
              }
          ],
          "track_url": "https://shiprocket.co//tracking/141123221084922",
          "etd": "2022-07-20 19:28:00",
          "qc_response": {
              "qc_image": "",
              "qc_failed_reason": ""
          }
      }
  }''';
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    setState(() {
      trackingData = TrackingData.fromJson(jsonData);
    });

    if (kDebugMode) {
      print('============json===========$jsonString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: trackingData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SearchComponent(
                  isBackEnabled: true,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      // ListTile(
                      //   title: Text(
                      //       'Current Status: ${trackingData.shipmentTrackActivities.last['activity']}'),
                      //   subtitle: Text(
                      //       'Location: ${trackingData.shipmentTrackActivities.last['location']}'),
                      // ),
                      const Divider(),
                      for (var activity
                          in trackingData.shipmentTrackActivities.reversed)
                        ListTile(
                          leading: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: const Icon(Icons.check,
                                          size: 15, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          title: Text(activity['activity']),
                          subtitle: Text(activity['location']),
                        ),
                      const Divider(),
                      ElevatedButton(
                        onPressed: () async {
                          if (await canLaunch(trackingData.trackUrl)) {
                            await launch(trackingData.trackUrl);
                          } else {
                            throw 'Could not launch ${trackingData.trackUrl}';
                          }
                        },
                        child: const Text('View Tracking Details'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
