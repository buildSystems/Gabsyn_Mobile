import 'package:flutter/material.dart';

showConfirmDialog(BuildContext context, String message, String heading,
    String buttonAcceptTitle, String buttonCancelTitle, Function f) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text(buttonCancelTitle),
    onPressed: () {
      Navigator.pop(context);
      print('You cancelled');
    },
  );
  Widget continueButton = FlatButton(
    child: Text(buttonAcceptTitle),
    onPressed: () {
      Navigator.pop(context);
      f();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(heading),
    content: Text(message),
    actions: [
      cancelButton,
      continueButton,
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

showAlertDialog(BuildContext context, String message, String heading,
    String buttonAcceptTitle) {
  // set up the button

  Widget okButton = FlatButton(
    child: Text(buttonAcceptTitle),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(heading),
    content: Text(message),
    actions: [
      okButton,
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