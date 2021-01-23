import 'package:flutter/material.dart';
import 'loan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:convert' as convert;

class Login extends StatefulWidget{
  @override
  LoginState createState() {
    // TODO: implement createState
    return LoginState();
  }

}

class LoginState extends State<Login>{

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String username = "";
  String password = "";
  bool _loading = false;

  bool positiveMessage = false;
  String message = "";

  Future<void> _getToken() async {

    final SharedPreferences prefs = await _prefs;
    final token = prefs.getString('TOKEN') ?? null;

    if(token != null){
      //redirect to loan_page for now
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoanPage())
      );
    }
  }

  Future<void> _saveToken(String token) async {

    final SharedPreferences prefs = await _prefs;
    final savedToken = prefs.setString('TOKEN', token);
  }

  Future<void> _saveUser(var user) async {

    final SharedPreferences prefs = await _prefs;
    final firstName = prefs.setString('USER_FIRST_NAME', user['first_name']);
    final middleName = prefs.setString('USER_MIDDLE_NAME', user['middle_name']);
    final lastName = prefs.setString('USER_LAST_NAME', user['last_name']);
    final email = prefs.setString('USER_EMAIL', user['email']);
    final phone = prefs.setString('USER_PHONE', user['phone']);
    final photo = prefs.setString('USER_PHOTO', user['photo']);
  }

  @override
  void initState(){
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

    _attemptLogin(String username, String password) async {
      setState(() {
        _loading = true;
      });
      final url = Constants.Routes['LOGIN'];
      var requestBody = {'email': username, 'password': password};
      var response = await http.post(url, body: requestBody);

      if(response.statusCode == 200){
        setState(() {
          _loading = false;
        });
        var responseBody = convert.jsonDecode(response.body);
        _saveToken(responseBody['data']['token']);
        _saveUser(responseBody['data']['user']);

        setState(() {
          _loading = false;
          positiveMessage = true;
          message = 'Login Successful...';
        });

        //_scaffold.currentState.showSnackBar(SnackBar(content: Text("Login successful")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoanPage())
        );

      }else{

        var responseBody;

        try{
          responseBody = convert.jsonDecode(response.body);
          setState(() {
            _loading = false;
            positiveMessage = false;
            message = responseBody['message'];
          });

          _scaffold.currentState.showSnackBar( SnackBar(content: Text(responseBody['message']) ));
          print('Failed response code: ${response.statusCode}');
          print('Failed response body: ${response.body}');
        }catch(e){
          setState(() {
            _loading = false;
            positiveMessage = false;
            message = 'Network error';
          });

          print('Error response: ${e.toString()}');
        }



      }
    }

    handleSubmit(){

      // TODO: implement build

      // if(username.isEmpty){
      //   _scaffold.currentState.showSnackBar(SnackBar(content: Text("You didn't enter your username")));
      //   return;
      // }
      // if(password.isEmpty){
      //   _scaffold.currentState.showSnackBar(SnackBar(content: Text("You didn't enter your password")));
      //   return;
      // }

      // _attemptLogin(username, password);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoanPage()));

    }


    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Sign in", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: <Widget>[
          Column(

              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: <Widget>[
                              Padding(

                                padding: EdgeInsets.fromLTRB(0.0, 42.0, 0.0, 32.0),
                                child: Image(image: AssetImage('assets/images/gabsynpeyzs_purple.png')),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 8.0),
                                child: Text(message, style: TextStyle(fontSize: 16, color: positiveMessage ? Color.fromRGBO(0, 100, 0, 1) : Color.fromRGBO(255, 100, 0, 1)),),
                              ),

                              TextField(
                                keyboardType: TextInputType.text,
                                style: TextStyle(fontSize: 16),
                                autofocus: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  hintText: "Username",
                                ),
                                onChanged: (value) => {
                                  username = value
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0)
                                    ),
                                    hintText: "Password",

                                  ),
                                  onChanged: (value) => {
                                    password = value
                                  },
                                  obscureText: true,
                                ),
                              ),

                            ],
                          ),
                        )
                    )

                ),
                SizedBox(
                    width: double.infinity,
                    height: 92.0,
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          child: Text("Sign in"),
                          color: Colors.purple,
                          onPressed: () => handleSubmit(),

                        )
                    )
                )

              ]
          ),
          Center(
            child: _loading ? CircularProgressIndicator() : null,
          )
        ],
      )

    );

  }

}