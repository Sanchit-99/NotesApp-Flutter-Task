import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

showAlertDialog(
    {required BuildContext context,
    String? title,
    String? subTitle,
    required bool withButton}) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title ?? ''),
    content: Text(subTitle ?? ''),
    actions: [
      if (withButton) okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget showLoader() {
  return Center(
    child: Lottie.asset('assets/loading.json', height: 100, width: 100),
  );
}

Widget notesCard(
    {required double width,
    required double height,
    required BuildContext context,
    required String title,
    required String subTitle,
    required String date,
    required bool isFav}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          height: 100,
          width: width,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Icon(
                    isFav ? Icons.star : Icons.star_outline,
                    color: isFav ? Color(0xfff1a005) : Colors.grey,
                  ),
                  Icon(Icons.more_vert)
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: width * 0.65,
                    child: Text(
                      subTitle.length > 110
                          ? subTitle.substring(0, 110) + '...'
                          : subTitle,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: width * 0.25,
                    child: Text(date,
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w300)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Divider()
    ],
  );
}

String parseDateTime(DateTime dateTime) {
  String day = dateTime.day.toString();
  String month = dateTime.month.toString();
  String year = dateTime.year.toString();
  String hour = dateTime.hour.toString();
  String min = dateTime.minute.toString();
  return day + "/" + month + "/" + year + ", " + hour + ":" + min;
}
