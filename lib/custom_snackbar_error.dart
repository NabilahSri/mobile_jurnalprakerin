import 'package:flutter/material.dart';

class CustomSnackBarError {
  static final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static show(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      content: Container(
        width: double.infinity,
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withAlpha(90), width: 2),
            color: Colors.red.withAlpha(20)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              },
              child: Container(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 16),
      duration: Duration(seconds: 3),
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
