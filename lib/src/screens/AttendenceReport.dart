import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/constants/url.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AttendenceReport extends StatefulWidget {
  const AttendenceReport({super.key});

  @override
  State<AttendenceReport> createState() => _AttendenceReportState();
}

class _AttendenceReportState extends State<AttendenceReport> {
  static const MethodChannel _channel = MethodChannel('wifi_channel');
  List<String> name = ['Ashutosh', 'Asim'];

  @override
  Widget build(BuildContext context) {
    TextEditingController dateController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => {
            // Navigator.pushNamed(context, '/home')
            Navigator.of(context).pop()
          },
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        title: const Text(
          'Attendance Report',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // color: Colors.greenAccent,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              // width: MediaQuery.of(context).size.width*0.9,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                    //  Any decoration in Sized Box
                    //   color: Colors.red
                    ),
                child: Center(
                  child: Text(
                    'Pick a date to get the attendence Report',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            SizedBox(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: "Enter Date",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      )),
                  readOnly: true,
                  // when true user cannot edit text
                  onTap: () async {
                    //when click we have to show the datepicker
                    DateTime? datePicked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2014),
                        lastDate: DateTime(2027));
                    if (datePicked != null) {
                      if (kDebugMode) {
                        print("date selected : $datePicked ");
                      }
                      dateController.text =
                          DateFormat('yMd').format(datePicked);
                    }
                  }),
            ),
            SizedBox(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    getAttendanceDetails(dateController.text);
                    // print("Date --> ${dateController.text}");
                    // print("Date --> ${dateController.text.replaceAll('/', '-')}");
                  },
                  style: TextButton.styleFrom(
                    fixedSize:
                        Size.fromWidth(MediaQuery.of(context).size.width * 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue.shade900,
                  ),
                  child: const Text(
                    'SHOW DETAILS',
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontFamily: 'Heading'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: name.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(name[index]),
                      trailing: IconButton(
                        onPressed: () {
                          name.removeAt(index);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void showLoader(BuildContext context, bool val) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent dismissing the loader with a tap outside
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // Disable the back button handling
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.26,
              height: MediaQuery.of(context).size.height * 0.26,
              child: Image.asset(ImagePath.loader),
            ),
          ),
        );
      },
    );
  }

  void endLoader() {
    Navigator.pop(context);
  }

  void getAttendanceDetails(String date) async{
    showLoader(context,true);
    var url = '${URL.baseUrl}getAttendanceByDate?_format=json';
    var payload = {
      "date": date
    };
    var token = true;
    try {
      var res =
      await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("Result is : $res");
      }
      if (res['code'] == '200') {
        var result = res;
        if (kDebugMode) {
          print("Result is ${result['data']}");
        }
        endLoader();
      } else {
        endLoader();
        // showAlertDialog("Alert", res['message']);
      }
    } catch (error) {
      endLoader();
      // showAlertDialog("Alert", "Something went wrong!");
    }
  }
}

// class AttendanceData {
//   late final int attendanceType;
//   late final String start;
//   late final String end;
//   MyObject(this.title, this.description, );
// }
