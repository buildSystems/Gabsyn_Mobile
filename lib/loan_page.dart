import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'login.dart';
import 'result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:convert' as convert;
import 'functions.dart';
import 'dart:io';

class LoanPage extends StatefulWidget{
  @override
  LoanState createState() {
    // TODO: implement createState
    return LoanState();
  }

}

enum Employment {employed, unemployed}

class LoanState extends State<LoanPage>{

  int _selectedIndex = 0;
  String _token = '';
  bool _loading = false;

  String currentUserFirstName = "";
  String currentUserLastName = "";
  String currentUserEmail = "";
  String currentUserPhone = "";
  String currentUserImage = "";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _getUser() async {

    SharedPreferences prefs = await _prefs;
    final user = prefs.getString('USER_FIRST_NAME') ?? null;

    if(user == null){
      //redirect to login for now
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login())
      );
    }else{

      currentUserFirstName = prefs.getString('USER_FIRST_NAME');
      currentUserLastName = prefs.getString('USER_LAST_NAME');
      currentUserEmail = prefs.getString('USER_EMAIL');
      currentUserPhone = prefs.getString('USER_PHONE');
      currentUserImage = prefs.getString('USER_PHOTO');
    }
  }

  Future<void> _getToken() async {

    final SharedPreferences prefs = await _prefs;
    final token = prefs.getString('TOKEN') ?? null;

    if(token == null){
      //redirect to login for now
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login())
      );
    }else{
      setState((){
        _token = token;
      });
    }
  }


  String principal = "";
  String interest = "";

  String dropdownValue = '12 Months';
  String loanTypeValue = 'Salary Loan';
  List<String> _duration = <String>['1 Month', '2 Months', '3 Months', '4 Months',
    '5 Months', '6 Months', '7 Months', '8 Months',
    '9 Months', '10 Months', '11 Months', '12 Months'];
  TextEditingController _controller = TextEditingController();

  var loans = {'--Select Loan Type--':'0.0 0.0', 'Salary Loan':'97.1128 5.0', 'Asset-Backed Loan':'130.864 7.0', 'Business/SME Loan':'130.864 7.0',
    'Asset-Financing Loan':'130.864 7.0', 'Rent Advance Loan':'97.1128 5.0', 'Self-Employed Loan':'130.864 7.0',
    'One-Month Loan':'97.1128 5.0', 'Co-operativeLoan':'70.26 3.5', 'Staff Loan':'60.95 3.0',
    'Agricultural Loan':'97.1128 5.0', 'Personal Loan':'97.1128 5.0', 'Returning Client Loan':'79.384 4.0',
    'Public Sector Loan':'114.2455 6.0', 'Salary Advance (1 Month)':'97.1128 5.0', 'School Fee':'106.0026 5.5',
    'Loan Refinancing':'130.864 7.0', 'Rate A+':'97.1128 5.0', 'Rate A':'97.1128 5.0',
    'Rate B':'106.0026 5.5', 'Rate C':'120.51 6.5'};


  String clientFirstName = '';
  TextEditingController clientFirstNameController = new TextEditingController();

  String clientMiddleName = '';
  TextEditingController clientMiddleNameController = new TextEditingController();

  String clientLastName = '';
  TextEditingController clientLastNameController = new TextEditingController();

  String clientEmail = '';
  TextEditingController clientEmailController = new TextEditingController();

  String clientPhone = '';
  TextEditingController clientPhoneController = new TextEditingController();

  String clientAddress = '';
  TextEditingController clientAddressController = new TextEditingController();

  String clientCompanyName = '';
  TextEditingController clientCompanyNameController = new TextEditingController();

  String clientCompanyAddress = '';
  TextEditingController clientCompanyAddressController = new TextEditingController();

  Employment employment = Employment.employed;
  static int pageViewPage = 0;
  String _selectedEmploymentType = '--Employment Type--';
  var _employmentTypes = ['--Employment Type--', 'Permanent', 'Contract'];
  String _selectedEmploymentSector = '--Employment Sector--';
  var _employmentSectors = ['--Employment Sector--', 'Private', 'Public'];
  String _selectedLoanType = '--Loan type--';
  var _loanTypes = ['--Loan type--', 'Salary Earner Loan',
                    'Salary Advance (1 Month)', 'Business/SME Loan',
                    'Micro Business Loan', 'Co-operative Loan'];
  String clientCompanyPhone = '';
  TextEditingController clientCompanyPhoneController = new TextEditingController();

  String clientEmploymentDate = '';
  TextEditingController clientEmploymentDateController = new TextEditingController();

  String clientNetMonthlySalary = '';
  TextEditingController clientNetMonthlySalaryController = new TextEditingController();

  String nokFirstName = '';
  TextEditingController nokFirstNameController = new TextEditingController();

  String nokMiddleName = '';
  TextEditingController nokMiddleNameController = new TextEditingController();

  String nokLastName = '';
  TextEditingController nokLastNameController = new TextEditingController();

  String nokAddress = '';
  TextEditingController nokAddressController = new TextEditingController();

  String nokEmail = '';
  TextEditingController nokEmailController = new TextEditingController();

  String nokPhone = '';
  TextEditingController nokPhoneController = new TextEditingController();

  String nokRelationship = '';
  TextEditingController nokRelationshipController = new TextEditingController();

  String loanAmount = '';
  TextEditingController loanAmountController = new TextEditingController();

  String loanPurpose = '';
  TextEditingController loanPurposeController = new TextEditingController();

  String loanTenure = '';
  TextEditingController loanTenureController = new TextEditingController();

  String accountName = '';
  TextEditingController accountNameController = new TextEditingController();

  String accountNumber = '';
  TextEditingController accountNumberController = new TextEditingController();

  String bvn = '';
  TextEditingController bvnController = new TextEditingController();


  String _selectedBank = '--Select Bank--';
  var _banks = ['--Select Bank--', 'Access Bank', 'Access Bank (Diamond)',
                'ALAT by WEMA', 'ASO Savings and Loans', 'Bowen Microfinance Bank',
                'CEMCS Microfinance Bank', 'Citibank Nigeria', 'Ecobank Nigeria',
                'Ekondo Microfinance Bank', 'Fidelity Bank', 'First Bank of Nigeria',
                'First City Monument Bank', 'FSDH Merchant Bank Limited', 'Globus Bank',
                'Hackman Microfinance Bank', 'Guaranty Trust Bank', 'Hasal Microfinance Bank',
                'Heritage Bank', 'Jaiz Bank', 'Keystone Bank', 'Kuda Bank',
                'Lagos Building Investment Company Plc.', 'One Finance', 'Parallex Bank',
                'Parkway - ReadyCash', 'Polaris Bank', 'Providus Bank', 'Rubies MFB',
                'Sparkle Microfinance Bank', 'Stanbic IBTC Bank', 'Standard Chartered Bank',
                'Sterling Bank', 'Suntrust Bank', 'TAJ Bank', 'TCF MFB', 'Titan Bank',
                'Union Bank of Nigeria', 'United Bank For Africa', 'Unity Bank',
                'VFD', 'Wema Bank', 'Zenith Bank'];


  //Pertaining to the collections page
  String collectionSearch = '';
  var _collectionUsers = [];
  var collectionUserId = 0;
  var collectionAmount = '';
  var collectionUserFirstName = '';
  var collectionUserLastName = '';

  //Now the settings page

  signOut() async {
    //
    //We just clear the shared preferences and redirect to login

    SharedPreferences prefs = await _prefs;
    await prefs.clear();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login())
    );
  }

  confirmSignOut(){
    //
    showConfirmDialog(context, "Are you sure you want to Sign out?", "Signing out", "Yes", "No", signOut);
  }

  searchForCollectionMatches(searchText) async {
    if(searchText.trim() != ''){
      //showAlertDialog(context, 'Yep!  We can do the search now', 'Here we go', 'Okay');
      //print('You are searching...');
      final url = Constants.Routes['FETCH_COLLECTION_MATCHES'];
      var requestBody = {
        'search': searchText
      };

      var response = await http.post(url, body: requestBody, headers:{HttpHeaders.authorizationHeader: "Bearer ${_token}"} );

      setState(() {
        _loading = true;
      });
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        try{
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
//          showAlertDialog(context, message, 'Found Matches', "OK");
          setState(() {
            _collectionUsers = responseBody['data']['users'];
          });

        }catch(e){
          print('Response body: ');
          print(response.body);
        }
      }else if(response.statusCode == 206){
        setState(() {
          _loading = false;
        });
        try{
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
          showAlertDialog(context, message, 'No Matches Found', "OK");
        }catch(e){
          print('Response body: ');
          print(response.body);
        }
      }else{
        setState(() {
          _loading = false;
        });
        try{
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
          showAlertDialog(context, message, 'Network Error', "OK");
        }catch(e){
          print('Response body: ');
          print(response.body);
        }
      }

    }
  }


  submitApplication() async {
//    print('You are submitting...');
    final url = Constants.Routes['CREATE_USER_AND_LOAN'];
    var requestBody = {
      "first_name": clientFirstName,
      "middle_name": clientMiddleName,
      "last_name": clientLastName,
      "phone": clientPhone,
      "address": clientAddress,
      "email": clientEmail,

      "employment": employment.toString(),
      "employment_type": _selectedEmploymentType,
      "employment_sector": _selectedEmploymentSector,
      "company_name": clientCompanyName,
      "company_address": clientCompanyAddress,
      "employment_date": clientEmploymentDate,
      "net_monthly_salary": clientNetMonthlySalary,

      "next_of_kin_first_name": nokFirstName,
      "next_of_kin_middle_name": nokMiddleName,
      "next_of_kin_last_name": nokLastName,
      "next_of_kin_phone": nokPhone,
      "next_of_kin_address": nokAddress,
      "next_of_kin_email": nokEmail,
      "relationship": nokRelationship,

      "amount": loanAmount,
      "purpose": loanPurpose,
      "tenure": loanTenure,
      "loan_type": _selectedLoanType,

      "account_name": accountName,
      "account_number": accountNumber,
      "bank_id": _selectedBank,
      "bvn": bvn
    };

    var response = await http.post(url, body: requestBody, headers:{HttpHeaders.authorizationHeader: "Bearer ${_token}"} );
    setState(() {
      _loading = true;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      try{
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Application successful', "OK");
        setState(() {
          pageViewPage = 8;
        });
      }catch(e){
        print('Response body: ');
        print(response.body);
      }
    }else{
      setState(() {
        _loading = false;
      });
      try{
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        var data = responseBody['data'];
        if(data.contains('users_email_unique')){
          showAlertDialog(context, "The email has already been taken", 'Application failed', "OK");
        }else if(data.contains('Email address is not verified')) {
          showAlertDialog(context, "The email, ${clientEmail}, cannot be used", 'Application failed', "OK");
        }else{
          showAlertDialog(context, message, 'Application failed', "OK");
        }

        print('Response body: ');
        print(response.body);
      }catch(e){
        print('Response status: ');
        print(response.statusCode);
        print('Response body: ');
        //print(response.body);
        showAlertDialog(context, response.body, 'Error', "OK");
      }
    }
  }

  submitCollection()  async {

//    showAlertDialog(context, "I think you want to submit  collection", "Collection", "OK");

    final url = Constants.Routes['REGISTER_COLLECTION'];
    var requestBody = {
      'id': '${collectionUserId}',
      'amount': collectionAmount,
      'comment': ''
    };

    var response = await http.post(url, body: requestBody, headers:{HttpHeaders.authorizationHeader: "Bearer ${_token}"} );

    setState(() {
      _loading = true;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      try{
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Success', "OK");
        setState(() {
          collectionUserId = 0;
        });
      }catch(e){
        print('Response body: ');
        print(response.body);
      }
    }else{
      setState(() {
        _loading = false;
      });
      try{
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Network Error', "OK");
      }catch(e){
        print('Response body: ');
        print(response.body);
      }
    }
  }

  confirmSubmitCollection(){
    showConfirmDialog(context,  "Are you sure you want to record a savings of NGN ${collectionAmount} against ${collectionUserFirstName} ${collectionUserLastName}?",
        "Hold on!", "Yes",  "No", submitCollection);
  }

  @override
  void initState(){
    super.initState();
    _getUser();
    _getToken();
    clientFirstNameController.addListener(() { clientFirstName = clientFirstNameController.text; });
    clientMiddleNameController.addListener(() { clientMiddleName = clientMiddleNameController.text; });
    clientLastNameController.addListener(() { clientLastName = clientLastNameController.text; });
    clientEmailController.addListener(() { clientEmail = clientEmailController.text; });
    clientPhoneController.addListener(() { clientPhone = clientPhoneController.text; });
    clientAddressController.addListener(() { clientAddress = clientAddressController.text; });
    clientCompanyNameController.addListener(() { clientCompanyName = clientCompanyNameController.text; });
    clientCompanyAddressController.addListener(() { clientCompanyAddress = clientCompanyAddressController.text; });
    clientCompanyPhoneController.addListener(() { clientCompanyPhone = clientCompanyPhoneController.text; });
    clientEmploymentDateController.addListener(() { clientEmploymentDate = clientEmploymentDateController.text; });
    clientNetMonthlySalaryController.addListener(() { clientNetMonthlySalary = clientNetMonthlySalaryController.text; });

    nokFirstNameController.addListener(() { nokFirstName = nokFirstNameController.text; });
    nokMiddleNameController.addListener(() { nokMiddleName = nokMiddleNameController.text; });
    nokLastNameController.addListener(() { nokLastName = nokLastNameController.text; });
    nokEmailController.addListener(() { nokEmail = nokEmailController.text; });
    nokPhoneController.addListener(() { nokPhone = nokPhoneController.text; });
    nokAddressController.addListener(() { nokAddress = nokAddressController.text; });
    nokRelationshipController.addListener(() { nokRelationship = nokRelationshipController.text; });

    loanAmountController.addListener(() { loanAmount = loanAmountController.text; });
    loanTenureController.addListener(() { loanTenure = loanTenureController.text; });
    loanPurposeController.addListener(() { loanPurpose = loanPurposeController.text; });

    accountNumberController.addListener(() { accountNumber = accountNumberController.text; });
    accountNameController.addListener(() { accountName = accountNameController.text; });
    bvnController.addListener(() { bvn = bvnController.text; });
  }

  @override
  void dispose(){
    clientFirstNameController.dispose();
    clientMiddleNameController.dispose();
    clientLastNameController.dispose();
    clientEmailController.dispose();
    clientPhoneController.dispose();
    clientAddressController.dispose();
    clientCompanyNameController.dispose();
    clientCompanyAddressController.dispose();
    clientCompanyPhoneController.dispose();
    clientEmploymentDateController.dispose();
    clientNetMonthlySalaryController.dispose();

    nokFirstNameController.dispose();
    nokMiddleNameController.dispose();
    nokLastNameController.dispose();
    nokEmailController.dispose();
    nokPhoneController.dispose();
    nokAddressController.dispose();
    nokRelationshipController.dispose();

    loanAmountController.dispose();
    loanTenureController.dispose();
    loanPurposeController.dispose();

    accountNumberController.dispose();
    accountNameController.dispose();
    bvnController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

    PageController pageController = PageController(initialPage: pageViewPage);

    handleCalculate(){

      if(principal.isEmpty){
        _scaffold.currentState.showSnackBar(SnackBar(content: Text("The principal cannot be empty")));
        return;

      }
      if(interest.isEmpty){
        _scaffold.currentState.showSnackBar(SnackBar(content: Text("The interest cannot be empty")));
        return;

      }
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultPage(principal: principal, interest: interest, duration: dropdownValue))
      );
    }

    _setNewTab(int index){
      setState(() {
        _selectedIndex = index;
      });
    }

    List<Widget> _widgetOptions = <Widget>[
      SingleChildScrollView(
        child: Column(

          children: <Widget>[
            Text("Welcome, ${currentUserFirstName}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: EdgeInsets.all(20.0),
              child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){_setNewTab(1);},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.collections_bookmark, size: 50, color: Colors.white,),
                                  Text("Account Opening", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),

                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){_setNewTab(1);},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.collections, size: 50, color: Colors.white,),
                                  Text("Book Loan", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){_setNewTab(2);},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.credit_card, size: 50, color: Colors.white,),
                                  Text("Cash Collections", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){print('Micro Loan');},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.account_balance, size: 50, color: Colors.white,),
                                  Text("Loan Repayment", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){print('Reports');},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.report, size: 50, color: Colors.white,),
                                  Text("Reports", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: (){print('Mail');},
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(-5, 5),
                                    blurRadius: 10
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple
                          ),

                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.mail, size: 50, color: Colors.white,),
                                  Text("Mail", style: TextStyle(fontSize: 14, color: Colors.white70))
                                ],
                              )
                          ),
                        ),

                      ),
                    ),
                  ]
              ),
            ),
          ],
        ),

      ),
      PageView(
          pageSnapping: true,
          onPageChanged: (index){
            setState((){
              pageViewPage = index;
            });
            print('The current page: ${pageController.page}');
            print('The page index: ${index}');
          },
          controller: pageController,
          children: <Widget>[
          ///The Personal details here
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24.0),
              child: (
                Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Text("Client Personal Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                     Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: TextField(
                          controller: clientFirstNameController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 16),
                          autofocus: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)
                            ),
                            hintText: "First name",
                          ),
                          onChanged: (value) => {
                              clientFirstName = value
                          },
                        ),
                     ),
                   Padding(
                     padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextField(
                        controller: clientMiddleNameController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          hintText: "Middle name (Optional)",
                        ),
                        onChanged: (value) => {

                            clientMiddleName = value

                        },
                      ),
                   ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextField(
                        controller: clientLastNameController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          hintText: "Last name",
                        ),
                        onChanged: (value) => {
                            clientLastName = value
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextField(
                        controller: clientAddressController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          hintText: "Address",
                        ),
                        onChanged: (value) => {

                            clientAddress = value

                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextField(
                        controller: clientEmailController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          hintText: "Email address",
                        ),
                        onChanged: (value) => {

                            clientEmail = value

                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextField(
                        controller: clientPhoneController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          hintText: "Phone no",
                        ),
                        onChanged: (value) => {

                            clientPhone = value

                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () {pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.linear);},
                          tooltip: 'Next Page',
                          child: Icon(Icons.chevron_right),

                        ),
                      ),
                    )

                  ],
                )
              ),
            )
          ),
          ///The employment details here
          SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: (
                      Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text("Employment Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          SizedBox(

                            height: 80,
                            child: GridView.count(
                                crossAxisCount: 2,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('Employed'),
                                    leading: Radio(
                                      value: Employment.employed,
                                      groupValue: employment,
  //                                      onChanged: (value){employment = value;},
                                      onChanged: (Employment value) {
                                        setState(() {
                                          employment = value;

                                        });
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text('Unemployed'),
                                    leading: Radio(
  //                                      onChanged: (value){employment = value;},
                                      value: Employment.unemployed,
                                      groupValue: employment,
                                      onChanged: (Employment value) {
                                        setState(() {
                                          employment = value;
                                        });
                                      },
                                    ),
                                  )
                                ]
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
  //                                style: TextStyle(height: 42, fontSize: 16),
                                hint: Text('Employment type'), // Not necessary for Option 1
                                value: _selectedEmploymentType,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedEmploymentType = newValue;
                                  });
                                },
                                items: _employmentTypes.map((employmentType) {
                                  return DropdownMenuItem(
                                    child: new Text(employmentType),
                                    value: employmentType,
                                  );
                                }).toList(),
                              ),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
  //                                style: TextStyle(height: 42, fontSize: 16),
                                hint: Text('Employment sector'), // Not necessary for Option 1
                                value: _selectedEmploymentSector,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedEmploymentSector = newValue;
                                  });
                                },
                                items: _employmentSectors.map((employmentSector) {
                                  return DropdownMenuItem(
                                    child: new Text(employmentSector),
                                    value: employmentSector,
                                  );
                                }).toList(),
                              ),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: clientCompanyNameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Company name",
                              ),
                              onChanged: (value) => {
                                clientCompanyName = value
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: clientCompanyAddressController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Company Address",
                              ),
                              onChanged: (value) => {
                                clientCompanyAddress = value
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: clientCompanyPhoneController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Company phone",
                              ),
                              onChanged: (value) => {
                                clientCompanyPhone = value
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: clientEmploymentDateController,
                              keyboardType: TextInputType.datetime,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Employment date",
                              ),
                              onChanged: (value) => {
                                clientEmploymentDate = value
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: clientNetMonthlySalaryController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Net monthly salary",
                              ),
                              onChanged: (value) => {
                                clientNetMonthlySalary = value
                              },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FloatingActionButton(
                                    onPressed: () =>
                                    pageController
                                        .animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                    tooltip: 'Next page',
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    onPressed: () =>
                                    pageController
                                        .animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                    tooltip: 'Next page',
                                    child: Icon(Icons.chevron_right),

                                   ),
                                ),
                              ],
                            )

                          )

                        ],
                      )
                  ),
                )
            ),
          ///The next of kin details here
          SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: (
                      Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text("Next of Kin Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokFirstNameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "First name",
                              ),
                              onChanged: (value) => {

                                nokFirstName = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokMiddleNameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Middle name (Optional)",
                              ),
                              onChanged: (value) => {

                                nokMiddleName = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokLastNameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Last name",
                              ),
                              onChanged: (value) => {

                                nokLastName = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokAddressController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Address",
                              ),
                              onChanged: (value) => {

                                  nokAddress = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokEmailController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Email address",
                              ),
                              onChanged: (value) => {

                                  nokEmail = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokPhoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Phone no",
                              ),
                              onChanged: (value) => {

                                  nokPhone = value

                              },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: nokRelationshipController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Relationship e.g. Brother",
                              ),
                              onChanged: (value) => {

                                  nokRelationship = value

                              },
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),

                                    ),
                                  ),
                                ],
                              )

                          )

                        ],
                      )
                  ),
                )
            ),
          ///The loan details here
          SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: (
                      Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text("Loan Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
  //                                style: TextStyle(height: 42, fontSize: 16),
                                hint: Text('Loan type'), // Not necessary for Option 1
                                value: _selectedLoanType,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedLoanType = newValue;
                                  });
                                },
                                items: _loanTypes.map((String value) {
                                                return DropdownMenuItem(
                                                    value: value,
                                                    child: Text(value)
                                                );
                                 }).toList(),
                              ),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: loanAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Amount",
                              ),
                              onChanged: (value) => {

                                  loanAmount = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: loanPurposeController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Purpose",
                              ),
                              onChanged: (value) => {

                                  loanPurpose = value

                              },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: loanTenureController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Loan Tenure",
                              ),
                              onChanged: (value) => {

                                  loanTenure = value

                              },
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(4, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),

                                    ),
                                  ),
                                ],
                              )

                          )

                        ],
                      )
                  ),
                )
            ),
          ///The bank details
          SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: (
                      Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text("Bank Account Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
  //                                style: TextStyle(height: 42, fontSize: 16),
                                hint: Text('Bank name'), // Not necessary for Option 1
                                value: _selectedBank,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedBank = newValue;
                                  });
                                },
                                items: _banks.map((bank) {
                                  return DropdownMenuItem(
                                    child: new Text(bank),
                                    value: bank,
                                  );
                                }).toList(),
                              ),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: accountNameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Account name",
                              ),
                              onChanged: (value) => {

                                  accountName = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: accountNumberController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Account number",
                              ),
                              onChanged: (value) => {

                                  accountNumber = value

                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextField(
                              controller: bvnController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16),
                              autofocus: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "BVN",
                              ),
                              onChanged: (value) => {
                                  bvn = value
                              },
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(5, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),

                                    ),
                                  ),
                                ],
                              )

                          )

                        ],
                      )
                  ),
                )
            ),
          ///For the preview of information
          SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: (
                      Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text("Preview Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
  //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black
                            ),
                          ),
                          Text("Personal Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      ///First name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
    child: Container(
                                            width: 150,
    child: Text('First name:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientFirstName)
                                      ),
                                    ]
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Middle name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Middle name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientMiddleName)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Last name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Last name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(clientLastName)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Email:', style: TextStyle(fontWeight: FontWeight.bold))
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmail)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                        ///Phone
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                            width: 150,
                                              child: Text('Phone no:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            child: Text(clientPhone)
                                        ),
                                      ],
                                    ),

                                ],

                              ),
                            ),

                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black,),
                          ),
                          Text("Employment Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[

                                  Row(
                                    children: <Widget>[
                                      ///Employed or not
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Employment:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(employment.toString() == "Employment.employed" ? "employed" : "unemployed")
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Employment sector
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Employment sector:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentSector)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[

                                      ///Employment type
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Employment type:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentType)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Company name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Company name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyName)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Company Address
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Company address:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyAddress)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Company Phone
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Company phone:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyPhone)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Employment Date
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Employment date:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmploymentDate)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Net salary
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                            width: 150,
                                            child: Text('Net monthly salary:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(clientNetMonthlySalary)
                                      ),

                                    ],
                                  ),


                                ],

                              ),
                            ),

                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black,),
                          ),
                          Text("Next of Kin Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              child: Column(

                                children: <Widget>[

                                  Row(
                                    children: <Widget>[
                                      ///First name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('First name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokFirstName)
                                      ),

                                    ],
                                  ),

                                  Row(
                                      children: <Widget>[
                                        ///Middle name
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Container(
                                            width: 150,
                                              child: Text('Middle name:', style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Text(nokMiddleName)
                                        ),

                                      ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Last name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Last name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokLastName)
                                      ),
                                    ]
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Address
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Address:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokAddress)
                                      ),

                                    ]
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Email:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokEmail)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Phone
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
    child: Container(
                                            width: 150,
    child: Text('Phone no:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokPhone)
                                      ),

                                    ]
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Relationship
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                            width: 150,
                                            child: Text('Relationship:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(nokRelationship)
                                      ),

                                    ]
                                  ),

                                ],

                              ),
                            ),

                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black,),
                          ),
                          Text("Loan Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(

                              child: Column(

                                children: <Widget>[

                                  Row(
                                      children: <Widget>[
                                        ///Loan type
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Container(
                                            width: 150,
                                              child: Text('Loan type:', style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(_selectedLoanType)
                                        ),

                                      ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Loan amount
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Loan amount:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanAmount)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Loan tenure
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan tenure:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanTenure)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Loan purpose
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan purpose:', style: TextStyle(fontWeight: FontWeight.bold))
    ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(loanPurpose)
                                      ),
                                    ],
                                  ),
                                ],

                              ),
                            ),

                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black,),
                          ),
                          Text("Bank Account Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              height:150,
                              width: double.infinity,
                              child: Column(

                                children: <Widget>[

                                  Row(
                                    children: <Widget>[
                                      ///Bank name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                              child: Text('Bank:', style: TextStyle(fontWeight: FontWeight.bold))
                                           ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedBank)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Account name
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Account name:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountName)
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///Account number
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                            width: 150,
                                            child: Text('Account number:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountNumber)
                                      ),

                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      ///BVN
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                            width: 150,
                                            child: Text('BVN:', style: TextStyle(fontWeight: FontWeight.bold))
                                          ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(bvn)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal:16.0),
                            child:Container(
                              height:1.0,
                              width: double.infinity,
                              color: Colors.black,),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () =>
                                          pageController
                                              .animateToPage(4, duration: Duration(milliseconds: 400), curve: Curves.linear),

                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => {showConfirmDialog(context,
                                                          'Are you sure you want to submit?',
                                                          "Submit Application" , "Yes", "No",
                                                          submitApplication)},
                                      tooltip: 'Submit',
                                      child: Icon(Icons.chevron_right),

                                    ),
                                  ),
                                ],
                              )

                          )
                        ],
                      )
                  ),
                )
            ),
          ],
        ),
      Stack(
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
                                TextField(
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 16),
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0)
                                    ),
                                    hintText: "Search by name, email, or phone number",
                                  ),
                                  onChanged: (value) => {
                                    collectionSearch = value
                                  },
                                  onSubmitted: (value){
                                    searchForCollectionMatches(value);
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children:
                                      _collectionUsers.map((user){
                                        return Card(
                                                child: ListTile(
                                                  onTap: (){
                                                    collectionUserId = user['id'];
                                                    collectionUserFirstName = user['first_name'];
                                                    collectionUserLastName = user['last_name'];
                                                    _scaffold.currentState.showBottomSheet(
                                                                (context) => Container(
                                                                  height: 300,
                                                                  color: Colors.white,
                                                                  width: double.infinity,
                                                                  child: Center(
                                                                    child: Column(
                                                                      children: <Widget>[
                                                                        Padding(
                                                                            padding: EdgeInsets.all(32.0),
                                                                            child:  Text(
                                                                                "Record saving for ${user['first_name']} ${user['last_name']}",
                                                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)
                                                                            )

                                                                        ),
                                                                        Divider(),
                                                                        Padding(
                                                                          padding: EdgeInsets.all(16),
                                                                          child: TextField(
                                                                            controller: nokMiddleNameController,
                                                                            keyboardType: TextInputType.number,
                                                                            style: TextStyle(fontSize: 16),
                                                                            autofocus: false,
                                                                            decoration: InputDecoration(
                                                                              border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(30.0)
                                                                              ),
                                                                              hintText: "Enter the amount",
                                                                            ),
                                                                            onChanged: (value) => {
                                                                              collectionAmount = value
                                                                            },
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width: double.infinity,
                                                                            height: 92.0,
                                                                            child: Padding(
                                                                                padding: EdgeInsets.all(16.0),
                                                                                child: RaisedButton(
                                                                                  textColor: Colors.white,
                                                                                  child: Text("Submit"),
                                                                                  color: Colors.purple,
                                                                                  onPressed: () => confirmSubmitCollection(),

                                                                                )
                                                                            )
                                                                        )
                                                                      ],
                                                                    )
                                                                  )
                                                                )
                                                              );
                                                            },
                                                  leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(user['photo'].contains('http') ? user['photo'] : "${Constants.SITE_ROUTE}${user['photo']}" ),
                                                  ),
                                                  title: Text("${user['first_name']} ${user['last_name']}"),
                                                  subtitle: Text(user['email'] != null ? "${user['email']}" : "${user['phone']}"),
                                                  )
                                              );
                                          }).toList()
                                  ),
                                ),

                              ],
                            ),
                          )
                      )

                  ),

                ]
            ),
            Center(
              child: _loading ? CircularProgressIndicator() : null,
            )
          ],
        ),
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Container(
  //              color: Colors.purpleAccent,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
                  child:  Center(
                      child: CircleAvatar(
                        radius: 92,
                        backgroundImage: NetworkImage(currentUserImage.startsWith('http') ?
                        currentUserImage :
                        '${Constants.SITE_ROUTE}${currentUserImage}'),
                      )
                  ),

                ),

              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 5 / 2,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 8, 16),
                    child: Center(
                      child: TextField(
                        controller: TextEditingController()..text = currentUserFirstName,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 16),

                      ),
                    )

                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
                    child: TextField(
                      controller: TextEditingController()..text = currentUserLastName,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 16),

                    ),

                  ),
                ],
              ),

              Padding(
                  padding: EdgeInsets.all(16),
                  child:  Center(
                      child: Text(currentUserEmail)
                  )

              ),

              Padding(
                  padding: EdgeInsets.all(16),
                  child:  Center(
                      child: Text(currentUserPhone)
                  )

              ),


              SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                      child: RaisedButton(
                        textColor: Colors.white,
                        child: Text("Sign out"),
                        color: Colors.purple,
                        onPressed: () => confirmSignOut(),

                      )
                  )
              )

            ],
          ),
      ),
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

                            padding: EdgeInsets.all(16),
                            child: Text("Loan Details",  textAlign: TextAlign.left, style: TextStyle(fontSize: 16),  ),
                          ),

                          TextFormField(
                            keyboardType: TextInputType.numberWithOptions(),
                            style: TextStyle(fontSize: 16),
                            autofocus: false,
                            initialValue: principal,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)
                              ),
                              hintText: "Principal",
                            ),
                            onChanged: (value) => {
                              principal = value
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.numberWithOptions(),
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0)
                                ),
                                hintText: "Interest",

                              ),
  //                      onChanged: (value) => {
  //                        interest = value
  //                      },
                              readOnly: true,
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Loan Type"),

                                      DropdownButton<String>(
                                        value: loanTypeValue,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                            color: Colors.deepPurple
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            loanTypeValue = newValue;
                                            interest = loans[loanTypeValue].split(' ')[1];
                                            _controller.text = interest;
                                          });
                                        },
                                        items: loans.keys
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        })
                                            .toList(),
                                      ),
                                    ],
                                  )

                              )
                          ),

                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Loan Duration"),
                                      DropdownButton<String>(
                                        value: dropdownValue,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                            color: Colors.deepPurple
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            dropdownValue = newValue;

                                          });
                                        },
                                        items: _duration
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        })
                                            .toList(),
                                      ),
                                    ],
                                  )

                              )
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
                      child: Text("Calculate"),
                      color: Colors.purple,
                      onPressed: () => handleCalculate(),

                    )
                )
            )

          ]
        )
    ];

    // TODO: implement build
    return  Scaffold(
          key: _scaffold,
          appBar: AppBar(
            title: Text("Dashboard", style: TextStyle(color: Colors.white)),
          ),
          body: Stack(
            children: <Widget>[
              Center(
                  child: _widgetOptions.elementAt(_selectedIndex)
              ),
              Center(
                  child: _loading ? CircularProgressIndicator() : null
              ),
            ],

          ),
          bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                  canvasColor: Colors.purple,
                  // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                  primaryColor: Colors.purpleAccent,
                  textTheme: Theme
                      .of(context)
                      .textTheme
                      .copyWith(caption: new TextStyle(color: Colors.white))
              ),
            child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                unselectedItemColor: Colors.purpleAccent,
                elevation: 8.0,
                onTap: _setNewTab,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      title: Text('Home')
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle),
                      title: Text('Loan')
                  ),

                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet),
                      title: Text('Collections')
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      title: Text('Settings')
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.dialpad),
                      title: Text('Calculator')
                  ),
                ]
            ),
          )

    );
  }

}
