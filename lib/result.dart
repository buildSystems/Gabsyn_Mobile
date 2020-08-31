import 'package:flutter/material.dart';
import 'package:number_display/number_display.dart';
import 'dart:convert';


class ResultPage extends StatelessWidget{

  String principal = "";
  String interest = "";
  String duration = "";

  final display = createDisplay(length: 10, decimal: 2);

  ResultPage({Key key, this.principal, this.interest, this.duration}): super(key: key);

  @override
  Widget build(BuildContext context) {

    double totalInterest = double.parse(interest) * double.parse(principal) * double.parse(duration.split(" ")[0])/ 100;
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            title: Text("Loan Result")
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 15.0),
                          child: Text("EMI", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                          child: Text(duration, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                        ),

                        Text("Interest: ${display(totalInterest) }"),
                      ],
                    )
                  )
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(0.0, 32, 0.0, 0.0),
                child: SizedBox(
                  width: double.infinity,

                  child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 15.0),
                                child: Text("Monthly Payment", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 15.0),
                                child: Text(display(((totalInterest + double.parse(principal)) / double.parse(duration.split(" ")[0]))), style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                                child: LinearProgressIndicator(
                                  value: double.parse(principal) / (totalInterest + double.parse(principal)),
                                  backgroundColor: Colors.red,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 10.0,
                                              height: 10.0,
                                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue
                                              ),
                                            ),
                                            Text("Principal")
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 10.0,
                                              height: 10.0,
                                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                              ),
                                            ),
                                            Text("${display(double.parse(principal))}", style: TextStyle(fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ],
                                    ),

                                    Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 10.0,
                                              height: 10.0,
                                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red
                                              ),
                                            ),
                                            Text("Interest")
                                          ],
                                        ),
                                        Row(

                                          children: <Widget>[
                                            Container(
                                              width: 10.0,
                                              height: 10.0,
                                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                              ),
                                            ),
                                            Text("${display(totalInterest)}", style: TextStyle(fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                              ),

                            ],
                          )
                      )
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Text("")
              ),

              SizedBox(
                width: double.infinity,
                height: 92.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical:16.0, horizontal: 0.0),
                  child: RaisedButton(
                    textColor: Colors.white,
                    child: Text("Back"),
                    color: Colors.purple,
                    onPressed: () {Navigator.pop(context);},
                  )
                )
              ),

            ],
          )

        )
    );
  }

}
