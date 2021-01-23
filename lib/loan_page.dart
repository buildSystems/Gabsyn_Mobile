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
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class LoanPage extends StatefulWidget {
  @override
  LoanState createState() {
    // TODO: implement createState
    return LoanState();
  }
}

enum Employment { employed, unemployed }

enum AccountType { SALARY_EARNER, BUSINESS_OWNER, CORPORATE_ACCOUNT }

enum LoanApplication { NEW_CLIENT, EXISTING_CLIENT, NEW_LOAN }

enum CollectionType { SAVINGS, LOAN_REPAYMENT }

class LoanState extends State<LoanPage> {
  int _selectedIndex = 0; //Holds the bottomsheet selected index
  String _token = '';
  bool _loading = false;

  String currentUserFirstName = "";
  String currentUserLastName = "";
  String currentUserEmail = "";
  String currentUserPhone = "";
  String currentUserImage = "";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var _selectedResidentialStatus = '--Select Status--';
  var _residentialStatuses = ['--Select Status--', 'Rented', 'Outright Ownership', 'Mortgaged', 'Provided by Employer'];

  String clientMoveInDate = "Select move in date";

  var _selectedIndustry = "--Select Industry--";
  var _industries = ['--Select Industry--', 'IT', 'Construction', 'Banking'];

  var cooperativeSavingsController = TextEditingController();//new MoneyMaskedTextController(thousandSeparator: ',', precision: 0);
  var loanSavingsController = TextEditingController();

  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));


  Future<void> _getUser() async {
    SharedPreferences prefs = await _prefs;
    final user = prefs.getString('USER_FIRST_NAME') ?? null;

    if (user == null) {
      //redirect to login for now
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
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

    if (token == null) {
      //redirect to login for now
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      setState(() {
        _token = token;
      });
    }
  }

  String principal = "";
  String interest = "";

  AccountType selectedAccountType;  //Used to hold the kind of account a rep is about to create
  LoanApplication selectedLoanApplication; //This will hold the loan application type.
  CollectionType selectedCollectionType; //This will hold the collection type

  String dropdownValue = '12 Months';
  String loanTypeValue = 'Salary Loan';
  List<String> _duration = <String>[
    '1 Month',
    '2 Months',
    '3 Months',
    '4 Months',
    '5 Months',
    '6 Months',
    '7 Months',
    '8 Months',
    '9 Months',
    '10 Months',
    '11 Months',
    '12 Months'
  ];
  TextEditingController _controller = TextEditingController();

  var loans = {
    '--Select Loan Type--': '0.0 0.0',
    'Salary Loan': '97.1128 5.0',
    'Asset-Backed Loan': '130.864 7.0',
    'Business/SME Loan': '130.864 7.0',
    'Asset-Financing Loan': '130.864 7.0',
    'Rent Advance Loan': '97.1128 5.0',
    'Self-Employed Loan': '130.864 7.0',
    'One-Month Loan': '97.1128 5.0',
    'Co-operativeLoan': '70.26 3.5',
    'Staff Loan': '60.95 3.0',
    'Agricultural Loan': '97.1128 5.0',
    'Personal Loan': '97.1128 5.0',
    'Returning Client Loan': '79.384 4.0',
    'Public Sector Loan': '114.2455 6.0',
    'Salary Advance (1 Month)': '97.1128 5.0',
    'School Fee': '106.0026 5.5',
    'Loan Refinancing': '130.864 7.0',
    'Rate A+': '97.1128 5.0',
    'Rate A': '97.1128 5.0',
    'Rate B': '106.0026 5.5',
    'Rate C': '120.51 6.5'
  };

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

  String clientDOB = 'Date of Birth';
  TextEditingController clientDOBController = new TextEditingController();

  String director1FirstName = '';
  TextEditingController director1FirstNameController = new TextEditingController();

  String director1MiddleName = '';
  TextEditingController director1MiddleNameController = new TextEditingController();

  String director1LastName = '';
  TextEditingController director1LastNameController = new TextEditingController();

  String _selectedDirector1Gender = "--Select Gender--";

  String director1BVN = "";
  TextEditingController director1BVNController = new TextEditingController();

  String director1Email = '';
  TextEditingController director1EmailController = new TextEditingController();

  String director1Phone = '';
  TextEditingController director1PhoneController = new TextEditingController();

  String director1DOB = 'Date of Birth';
  TextEditingController director1DOBController = new TextEditingController();

  String clientAddress = '';
  TextEditingController clientAddressController = new TextEditingController();

  String clientNearestBusStop = '';
  TextEditingController clientNearestBusStopController = new TextEditingController();

  String clientNearestLandmark = '';
  TextEditingController clientNearestLandmarkController = new TextEditingController();

  String clientAnnualRent = '';
  TextEditingController clientAnnualRentController = new TextEditingController();

  String clientCompanyName = '';
  TextEditingController clientCompanyNameController = new TextEditingController();

  String clientCompanyRCNumber = '';
  TextEditingController clientCompanyRCNumberController = new TextEditingController();

  String director1IDNumber = "";
  TextEditingController director1IDNumberController = new TextEditingController();

  String clientStaffIDNumber = "";
  TextEditingController clientStaffIDNumberController = new TextEditingController();

  String clientDesignation = "";
  TextEditingController clientDesignationController = new TextEditingController();

  String clientPayDay = "";
  TextEditingController clientPayDayController = new TextEditingController();

  String clientCompanyAddress = '';
  TextEditingController clientCompanyAddressController =  new TextEditingController();

  String clientMonthlyTurnover = "";
  TextEditingController clientMonthlyTurnoverController =  new TextEditingController();

  String clientNumberOfEmployees = "";
  TextEditingController clientNumberOfEmployeesController =  new TextEditingController();

  String clientCompanyTINNumber;
  TextEditingController clientCompanyTINNumberController =  new TextEditingController();

  Employment employment = Employment.employed;
  
  static int salaryEarnerPageViewPage = 0;
  static int businessOwnerPageViewPage = 0;
  static int corporatePageViewPage = 0;
  static int loanPageViewPage = 0;

  String _selectedEmploymentType = '--Employment Type--';
  var _employmentTypes = ['--Employment Type--', 'Permanent', 'Contract'];
  String _selectedEmploymentSector = '--Employment Sector--';
  var _employmentSectors = ['--Employment Sector--', 'Private', 'Public'];

  String _selectedLoanType = '--Loan type--';

  String _selectedStateOfResidence = '--Select State of Residence--';

  String _selectedDirector1StateOfResidence = '--Select State of Residence--';

  String _selectedDirector1MeansOfID = '--Select a means of Identification--';

  var _loanTypes = [
    '--Loan type--',
    'Salary Earner Loan',
    'Salary Advance (1 Month)',
    'Business/SME Loan',
    'Micro Business Loan',
    'Co-operative Loan'
  ];
  String clientCompanyPhone = '';
  TextEditingController clientCompanyPhoneController =
      new TextEditingController();

  String clientEmploymentDate = 'Select Date of Employment';
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

  String nokOccupation = '';
  TextEditingController nokOccupationController = new TextEditingController();

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

  String clientIDNumber = '';
  TextEditingController clientIDNumberController = new TextEditingController();

  String clientMaritalStatus = '';
  TextEditingController clientMaritalStatusController = new TextEditingController();

  String bvn = '';
  TextEditingController bvnController = new TextEditingController();

  String _selectedBank = '--Select Bank--';
  var _banks = [
    '--Select Bank--',
    'Access Bank',
    'Access Bank (Diamond)',
    'ALAT by WEMA',
    'ASO Savings and Loans',
    'Bowen Microfinance Bank',
    'CEMCS Microfinance Bank',
    'Citibank Nigeria',
    'Ecobank Nigeria',
    'Ekondo Microfinance Bank',
    'Fidelity Bank',
    'First Bank of Nigeria',
    'First City Monument Bank',
    'FSDH Merchant Bank Limited',
    'Globus Bank',
    'Hackman Microfinance Bank',
    'Guaranty Trust Bank',
    'Hasal Microfinance Bank',
    'Heritage Bank',
    'Jaiz Bank',
    'Keystone Bank',
    'Kuda Bank',
    'Lagos Building Investment Company Plc.',
    'One Finance',
    'Parallex Bank',
    'Parkway - ReadyCash',
    'Polaris Bank',
    'Providus Bank',
    'Rubies MFB',
    'Sparkle Microfinance Bank',
    'Stanbic IBTC Bank',
    'Standard Chartered Bank',
    'Sterling Bank',
    'Suntrust Bank',
    'TAJ Bank',
    'TCF MFB',
    'Titan Bank',
    'Union Bank of Nigeria',
    'United Bank For Africa',
    'Unity Bank',
    'VFD',
    'Wema Bank',
    'Zenith Bank'
  ];

  var _states = [
  '--Select State of Origin--',
  'Abia',
  'Adamawa',
  'Akwa Ibom',
  'Anambra',
  'Bauchi',
  'Bayelsa',
  'Benue',
  'Borno',
  'Cross River',
  'Delta',
  'Ebonyi',
  'Edo',
  'Ekiti',
  'Enugu',
  'Gombe',
  'Imo',
  'Jigawa',
  'Kaduna',
  'Kano',
  'Katsina',
  'Kebbi',
  'Kogi',
  'Kwara',
  'Lagos',
  'Nasarawa',
  'Niger',
  'Ogun',
  'Ondo',
  'Osun',
  'Oyo',
  'Plateau',
  'Rivers',
  'Sokoto',
  'Taraba',
  'Yobe',
  'Zamfara',
  'Abuja',
  ];

  var _statesOfResidence = [
    '--Select State of Residence--',
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'Abuja',
  ];

  var _selectedState = '--Select State of Origin--';
  var _selectedGender = "--Select Gender--";
  var _selectedMeansOfID = "--Select a means of Identification--";
  var _maritalStatus = "--Select Marital Status--";

  var _maritalDirector1Status = "--Select Marital Status--";
  var _maritalDirector2Status = "--Select Marital Status--";

  var _selectedDirector1State = "--Select State of Origin--";

  var _gender = ["--Select Gender--", "Male", "Female"];
  var _meansOfIDs = ["--Select a means of Identification--", "National ID Card", "Driver's Licence", "International Passport", "Voter's Card" ];
  var _maritalStatuses = ["--Select Marital Status--", "Single", "Married", "Divorced", "Widowed"];

  //Pertaining to the collections page
  String collectionSearch = '';
  var _loanUsers = [];
  var _collectionUsers = [{
    'id': 1,
    'first_name': 'Segun',
    'last_name': 'Offiong',
    'email': 'offsegun@gmail.com',
    'photo': 'http://whatever',
    'phone':'0800000000'
  }];

  var collectionUserId = 0;
  var collectionAmount = '';
  var collectionUserFirstName = '';
  var collectionUserLastName = '';

  var loanUserId = 0;
  var loanUserFirstName = '';
  var loanUserLastName = '';

  //Now the settings page

  //pertaining to files upload
  var photoFile = null;
  var governmentIDFile = null;
  var companyID = null;
  var utilityBill = null;
  var shopFile = null;
  var shopReceipt = null;
  var stockPhoto = null;
  var signature = null;

  Widget _setPhotoFile() {
    if (photoFile != null) {
      return CircleAvatar(radius: 75, backgroundImage: FileImage(photoFile));
      Image.file(photoFile, width: 200, height: 200);
    } else {
      return CircleAvatar(
          radius: 75, backgroundImage: AssetImage('assets/images/photo.jpg'));
    }
  }

  Widget _setGovernmentIDFile() {
    if (governmentIDFile != null) {
      return Image.file(governmentIDFile, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/id_card.jpg', width: 200);
    }
  }

  Widget _setCompanyID() {
    if (companyID != null) {
      return Image.file(companyID, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/id_card.jpg', width: 200);
    }
  }

  Widget _setUtilityBill() {
    if (utilityBill != null) {
      return Image.file(utilityBill, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/utility_bill.png', width: 200);
    }
  }

  Widget _setShopFile() {
    if (shopFile != null) {
      return Image.file(shopFile, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/shop_icon.png', width: 200);
    }
  }

  Widget _setShopReceiptFile() {
    if (shopReceipt != null) {
      return Image.file(shopReceipt, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/receipt.jpg', width: 200);
    }
  }

  Widget _setStockPhotoFile() {
    if (stockPhoto != null) {
      return Image.file(stockPhoto, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/stock.png', width: 200);
    }
  }

  Widget _setSignatureFile() {
    if (signature != null) {
      return Image.file(signature, width: 200, height: 150);
    } else {
      return Image.asset('assets/images/signature.png', width: 200);
    }
  }

  void _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      photoFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      photoFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openIDGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      governmentIDFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openIDCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      governmentIDFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openCompanyIDGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      companyID = picture;
    });
    Navigator.of(context).pop();
  }

  void _openCompanyIDCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      companyID = picture;
    });
    Navigator.of(context).pop();
  }

  void _openUtilityBillGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      utilityBill = picture;
    });
    Navigator.of(context).pop();
  }

  void _openUtilityBillCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      utilityBill = picture;
    });
    Navigator.of(context).pop();
  }

  void _openShopCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      shopFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openShopGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      shopFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openShopReceiptCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      shopReceipt = picture;
    });
    Navigator.of(context).pop();
  }

  void _openShopReceiptGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      shopReceipt = picture;
    });
    Navigator.of(context).pop();
  }

  void _openStockCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      stockPhoto = picture;
    });
    Navigator.of(context).pop();
  }

  void _openStockGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      stockPhoto = picture;
    });
    Navigator.of(context).pop();
  }

  void _openSignatureCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      signature = picture;
    });
    Navigator.of(context).pop();
  }

  void _openSignatureGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      signature = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get photo from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showIDSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get ID from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openIDGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openIDCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showUtilityBillSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Utility Bill from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openUtilityBillGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openUtilityBillCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showCompanyIDSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Company ID from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openCompanyIDGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCompanyIDCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showShopSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Shop Photo from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openShopGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openShopCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showShopReceiptSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Shop Receipt Photo from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openShopReceiptGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openShopReceiptCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showStockSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Stock Photo from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openStockGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openStockCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> _showSignatureSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Get Signature Photo from..."),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openSignatureGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openSignatureCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  signOut() async {
    //
    //We just clear the shared preferences and redirect to login

    SharedPreferences prefs = await _prefs;
    await prefs.clear();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  confirmSignOut() {
    //
    showConfirmDialog(context, "Are you sure you want to Sign out?",
        "Signing out", "Yes", "No", signOut);
  }

  searchForCollectionMatches(searchText) async {
    if (searchText.trim() != '') {
      //showAlertDialog(context, 'Yep!  We can do the search now', 'Here we go', 'Okay');
      //print('You are searching...');
      final url = Constants.Routes['FETCH_COLLECTION_MATCHES'];
      var requestBody = {'search': searchText};

      var response = await http.post(url,
          body: requestBody,
          headers: {HttpHeaders.authorizationHeader: "Bearer ${_token}"});

      setState(() {
        _loading = true;
      });
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        try {
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
//          showAlertDialog(context, message, 'Found Matches', "OK");
          setState(() {
            _collectionUsers = responseBody['data']['users'];
          });
        } catch (e) {
          print('Response body: ');
          print(response.body);
        }
      } else if (response.statusCode == 206) {
        setState(() {
          _loading = false;
        });
        try {
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
          showAlertDialog(context, message, 'No Matches Found', "OK");
        } catch (e) {
          print('Response body: ');
          print(response.body);
        }
      } else {
        setState(() {
          _loading = false;
        });
        try {
          var responseBody = convert.jsonDecode(response.body);
          var message = responseBody['message'];
          showAlertDialog(context, message, 'Network Error', "OK");
        } catch (e) {
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
      "photo": convert.base64.encode(photoFile.readAsBytesSync()),
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

    var headerMap = Map<String, String>();

    headerMap['Authorization'] = "Bearer ${_token}";

//    var dio = Dio();
//    FormData formData = new FormData.fromMap(requestBody);
//    var response = await dio.post(url, data: formData);

//    var request = http.MultipartRequest('POST', Uri.parse(url));
//    request.files.add(
//        await http.MultipartFile.fromBytes(
//            'photo',
//            File(photoFile).readAsBytesSync(),
//            filename: 'photo'
//        )
//    );
//    request.headers.addAll(headerMap);
//    var response = await request.send();

    var response = await http.post(url,
        body: requestBody,
        headers: {HttpHeaders.authorizationHeader: "Bearer ${_token}"});
    setState(() {
      _loading = true;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      try {
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Application successful', "OK");
        setState(() {
          salaryEarnerPageViewPage = 8;
        });
      } catch (e) {
        print('Response body: ');
        print(response.body);
      }
    } else {
      setState(() {
        _loading = false;
      });
      try {
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        var data = responseBody['data'];
        if (data.contains('users_email_unique')) {
          showAlertDialog(context, "The email has already been taken",
              'Application failed', "OK");
        } else if (data.contains('Email address is not verified')) {
          showAlertDialog(context, "The email, ${clientEmail}, cannot be used",
              'Application failed', "OK");
        } else {
          showAlertDialog(context, message, 'Application failed', "OK");
        }

        print('Response body: ');
        print(response.body);
      } catch (e) {
        print('Response status: ');
        print(response.statusCode);
        print('Response body: ');
        //print(response.body);
        showAlertDialog(context, response.body, 'Error', "OK");
      }
    }
  }

  submitCollection() async {
//    showAlertDialog(context, "I think you want to submit  collection", "Collection", "OK");

    final url = Constants.Routes['REGISTER_COLLECTION'];
    var requestBody = {
      'id': '${collectionUserId}',
      'amount': collectionAmount,
      'comment': ''
    };

    var response = await http.post(url,
        body: requestBody,
        headers: {HttpHeaders.authorizationHeader: "Bearer ${_token}"});

    setState(() {
      _loading = true;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      try {
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Success', "OK");
        setState(() {
          collectionUserId = 0;
        });
      } catch (e) {
        print('Response body: ');
        print(response.body);
      }
    } else {
      setState(() {
        _loading = false;
      });
      try {
        var responseBody = convert.jsonDecode(response.body);
        var message = responseBody['message'];
        showAlertDialog(context, message, 'Network Error', "OK");
      } catch (e) {
        print('Response body: ');
        print(response.body);
      }
    }
  }

  confirmSubmitCollection() {
    showConfirmDialog(
        context,
        "Are you sure you want to record a savings of NGN ${collectionAmount} against ${collectionUserFirstName} ${collectionUserLastName}?",
        "Hold on!",
        "Yes",
        "No",
        submitCollection);
  }

  @override
  void initState() {
    super.initState();
    // _getUser();
    // _getToken();

    //We call and populate states here


    clientFirstNameController.addListener(() {
      clientFirstName = clientFirstNameController.text;
    });
    clientMiddleNameController.addListener(() {
      clientMiddleName = clientMiddleNameController.text;
    });
    clientLastNameController.addListener(() {
      clientLastName = clientLastNameController.text;
    });
    clientEmailController.addListener(() {
      clientEmail = clientEmailController.text;
    });
    clientPhoneController.addListener(() {
      clientPhone = clientPhoneController.text;
    });

    director1FirstNameController.addListener(() {
      director1FirstName = director1FirstNameController.text;
    });
    director1MiddleNameController.addListener(() {
      director1MiddleName = director1MiddleNameController.text;
    });
    director1LastNameController.addListener(() {
      director1LastName = director1LastNameController.text;
    });
    director1EmailController.addListener(() {
      director1Email = director1EmailController.text;
    });
    director1PhoneController.addListener(() {
      director1Phone = director1PhoneController.text;
    });
    director1BVNController.addListener(() {
      director1BVN = director1BVNController.text;
    });

    clientAddressController.addListener(() {
      clientAddress = clientAddressController.text;
    });
    clientDOBController.addListener((){
      clientDOB = clientDOBController.text;
    });
    clientIDNumberController.addListener((){
      clientIDNumber =  clientIDNumberController.text;
    });

    clientMaritalStatusController.addListener((){
      clientMaritalStatus =  clientMaritalStatusController.text;
    });
    clientCompanyNameController.addListener(() {
      clientCompanyName = clientCompanyNameController.text;
    });

    clientCompanyRCNumberController.addListener((){
      clientCompanyRCNumber = clientCompanyRCNumberController.text;
    });

    clientCompanyAddressController.addListener(() {
      clientCompanyAddress = clientCompanyAddressController.text;
    });
    clientCompanyPhoneController.addListener(() {
      clientCompanyPhone = clientCompanyPhoneController.text;
    });
    clientEmploymentDateController.addListener(() {
      clientEmploymentDate = clientEmploymentDateController.text;
    });

    clientStaffIDNumberController.addListener(() {
      clientStaffIDNumber = clientStaffIDNumberController.text;
    });

    clientDesignationController.addListener(() {
      clientDesignation = clientDesignationController.text;
    });

    clientPayDayController.addListener(() {
      clientPayDay = clientPayDayController.text;
    });

    clientNetMonthlySalaryController.addListener(() {
      clientNetMonthlySalary = clientNetMonthlySalaryController.text;
    });

    clientCompanyTINNumberController.addListener(() {
      clientCompanyTINNumber = clientCompanyTINNumberController.text;
    });

    clientNearestBusStopController.addListener(() {
      clientNearestBusStop = clientNearestBusStopController.text;
    });

   clientMonthlyTurnoverController.addListener(() {
     clientMonthlyTurnover = clientMonthlyTurnoverController.text;
   });

    clientNumberOfEmployeesController.addListener(() {
      clientNumberOfEmployees = clientNumberOfEmployeesController.text;
    });

    clientNearestLandmarkController.addListener(() {
      clientNearestLandmark = clientNearestLandmarkController.text;
    });

    clientAnnualRentController.addListener(() {
      clientAnnualRent = clientAnnualRentController.text;
    });

    nokFirstNameController.addListener(() {
      nokFirstName = nokFirstNameController.text;
    });
    nokMiddleNameController.addListener(() {
      nokMiddleName = nokMiddleNameController.text;
    });
    nokLastNameController.addListener(() {
      nokLastName = nokLastNameController.text;
    });
    nokEmailController.addListener(() {
      nokEmail = nokEmailController.text;
    });
    nokPhoneController.addListener(() {
      nokPhone = nokPhoneController.text;
    });
    nokAddressController.addListener(() {
      nokAddress = nokAddressController.text;
    });
    nokRelationshipController.addListener(() {
      nokRelationship = nokRelationshipController.text;
    });
    nokOccupationController.addListener(() {
      nokOccupation = nokOccupationController.text;
    });

    loanAmountController.addListener(() {
      loanAmount = loanAmountController.text;
    });
    loanTenureController.addListener(() {
      loanTenure = loanTenureController.text;
    });
    loanPurposeController.addListener(() {
      loanPurpose = loanPurposeController.text;
    });

    accountNumberController.addListener(() {
      accountNumber = accountNumberController.text;
    });
    accountNameController.addListener(() {
      accountName = accountNameController.text;
    });
    bvnController.addListener(() {
      bvn = bvnController.text;
    });
  }


  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  
  PageController salaryEarnerPageController = PageController(initialPage: salaryEarnerPageViewPage);
  PageController businessOwnerPageController = PageController(initialPage: businessOwnerPageViewPage);
  PageController corporatePageController = PageController(initialPage: corporatePageViewPage);
  PageController loanPageController = PageController(initialPage: loanPageViewPage);

  handleCalculate() {
    if (principal.isEmpty) {
      _scaffold.currentState.showSnackBar(
          SnackBar(content: Text("The principal cannot be empty")));
      return;
    }
    if (interest.isEmpty) {
      _scaffold.currentState.showSnackBar(
          SnackBar(content: Text("The interest cannot be empty")));
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(
                principal: principal,
                interest: interest,
                duration: dropdownValue)));
  }

  _setNewTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
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


    List<Widget> _widgetOptions = <Widget>[
      getLandingPage(),
      getAccountPages(),
      getLoanPages(),
      getCollectionsPage(),
      getReportsPage(),
      getProfilePage(),
      getCalculatorPage()
    ];

    // TODO: implement build
    return Scaffold(
        key: _scaffold,
//        appBar: AppBar(
//          iconTheme: IconThemeData(),
//          title: Text("Dashboard", style: TextStyle(color: Colors.white)),
//        ),
        body: Stack(
          children: <Widget>[
            Center(child: _widgetOptions.elementAt(_selectedIndex)),
            Center(child: _loading ? CircularProgressIndicator() : null),
          ],
        ),
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.purple,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.purpleAccent,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.white))),
          child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              unselectedItemColor: Colors.purpleAccent,
              elevation: 8.0,
              onTap: _setNewTab,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text('Home')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), title: Text('Account')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance),
                    title: Text('Loan')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet),
                    title: Text('Collections')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.report),
                    title: Text('Reports')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), title: Text('Settings')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.dialpad), title: Text('Calculator')),
              ]),
        ));
  }



  //This iis the Landing page
  Widget getLandingPage(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text("Welcome, ${currentUserFirstName}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      onTap: () {
                        _setNewTab(1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 5),
                                  blurRadius: 10),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.purple),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.collections_bookmark,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Account Opening",
                                    style: TextStyle(fontSize: 14, color: Colors.white70))
                              ],
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {

                        _setNewTab(2);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 5),
                                  blurRadius: 10),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.purple),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.collections,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Book Loan",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white70))
                              ],
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        _setNewTab(3);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 5),
                                  blurRadius: 10),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.purple),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.credit_card,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Cash Collections",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white70))
                              ],
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        _setNewTab(4);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(-5, 5),
                                  blurRadius: 10),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.purple),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.report,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Text("Reports",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white70))
                              ],
                            )),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  //Different types of accounts pages
  Widget getDifferentTypesOfAccountsPages(){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Select Account Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          InkWell(
            onTap: (){
              setState(() {
                selectedAccountType = AccountType.SALARY_EARNER;
              });

              print('You just tapped SALARY_EARNER');

            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                color: Colors.purple
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child:Text('Salary Earner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
              )
            )
          ),
          SizedBox(height: 16),
          InkWell(
              onTap: (){
                setState(() {
                  selectedAccountType = AccountType.BUSINESS_OWNER;
                });
                print('You just tapped BUSINESS_OWNER');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Business Owner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),
          SizedBox(height: 16),
          InkWell(
              onTap: (){
                setState(() {
                  selectedAccountType = AccountType.CORPORATE_ACCOUNT;
                });
                print('You just tapped CORPORATE_ACCOUNT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Corporate Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),
          SizedBox(height: 16),
          if(selectedLoanApplication == LoanApplication.NEW_CLIENT)
            Text('Or', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if(selectedLoanApplication == LoanApplication.NEW_CLIENT)
            SizedBox(height: 16),
          if(selectedLoanApplication == LoanApplication.NEW_CLIENT)
            InkWell(
                onTap: (){
                  setState(() {
                    selectedAccountType = null;
                    selectedLoanApplication = null;
                  });
                  print('You just tapped NULL');

                },
                child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.purple
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child:Text('Apply for a Loan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                    )
                )
            ),


        ]
      ),
    );
  }

  //Different types of accounts pages
  Widget getDifferentTypesOfLoansPages(){
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Client for whom you are applying for', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          InkWell(
              onTap: (){
                setState(() {
                  selectedLoanApplication = LoanApplication.NEW_CLIENT;
                });

                print('You just tapped NEW_CLIENT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('New Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),
          SizedBox(height: 16),
          InkWell(
              onTap: (){
                setState(() {
                  selectedLoanApplication = LoanApplication.EXISTING_CLIENT;
                });
                print('You just tapped EXISTING_CLIENT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Existing Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),

        ]
    );
  }

  //This is for account pages
  Widget getAccountPages(){
    if(selectedAccountType == AccountType.SALARY_EARNER){
      return registerSalaryEarner();
    }else if(selectedAccountType == AccountType.BUSINESS_OWNER){
      return registerBusinessOwner();
    }else if(selectedAccountType == AccountType.CORPORATE_ACCOUNT){
      return registerCorporateAccount();
    }else{
      return getDifferentTypesOfAccountsPages();
    }
  }

  //This is for loan pages
  Widget getLoanPages(){
    if(selectedLoanApplication == LoanApplication.NEW_CLIENT){
      // _selectedIndex = 1;
      return getDifferentTypesOfAccountsPages();
    }else if(selectedLoanApplication == LoanApplication.EXISTING_CLIENT){
      return getLoanSearchPage();
    }else if(selectedLoanApplication == LoanApplication.NEW_LOAN){
      return getLoanApplicationPages();
    }else{
      return getDifferentTypesOfLoansPages();
    }
  }

  //Pages for Salary Earner account type
  Widget registerSalaryEarner(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: 16),
          getAccountTypeBar('Create Salary Earner Account'),
          Expanded(
            child: PageView(
                pageSnapping: true,
                onPageChanged: (index) {
                  setState(() {
                    salaryEarnerPageViewPage = index;
                  });
                  print('The current page: ${salaryEarnerPageController.page}');
                  print('The page index: ${index}');
                },
                controller: salaryEarnerPageController,
                children: <Widget>[
                  ///The Personal details here
                  getPersonalDetailsForm(),

                  ///The residential details here
                  getResidentialDetailsForm(),

                  ///The next of kin details here
                  getNextOfKinDetailsForm(),

                  ///The employment details here
                  getEmploymentDetailsForm(),

                  ///Files upload
                  SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('User Photo',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => _showSelectionDialog(context),
                            child: _setPhotoFile(),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: Text('Government ID',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => _showIDSelectionDialog(context),
                            child: _setGovernmentIDFile(),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: Text('Company ID',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => _showCompanyIDSelectionDialog(context),
                            child: _setCompanyID(),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: Text('Utility Bill',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => _showUtilityBillSelectionDialog(context),
                            child: _setUtilityBill(),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: Text('Signature',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => _showSignatureSelectionDialog(context),
                            child: _setSignatureFile(),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(32, 42, 32, 32),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () => goToPreviousFormPage(),
                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => goToNextFormPage(),
                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),

                  ///For the preview of information
                  SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(24.0),
                        child: (Column(
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            Text(
                              "Preview Details",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                  height: 1.0, width: double.infinity, color: Colors.black),
                            ),
                            Text(
                              "Personal Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      ///First name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('First name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientFirstName)),
                                    ]),
                                    Row(
                                      children: <Widget>[
                                        ///Middle name
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Middle name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientMiddleName)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Last name
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Last name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Text(clientLastName)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Email
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Email:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientEmail)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Phone
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                              width: 150,
                                              child: Text('Phone no:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            child: Text(clientPhone)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 1.0,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Employment Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
                                              child: Text('Employment:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(employment.toString() ==
                                                "Employment.employed"
                                                ? "employed"
                                                : "unemployed")),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Employment sector
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Employment sector:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(_selectedEmploymentSector)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Employment type
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Employment type:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(_selectedEmploymentType)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Company name
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Company name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientCompanyName)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Company Address
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Company address:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientCompanyAddress)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Company Phone
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Company phone:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientCompanyPhone)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Employment Date
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Employment date:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(clientEmploymentDate)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Net salary
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                              width: 150,
                                              child: Text('Net monthly salary:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            child: Text(clientNetMonthlySalary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 1.0,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Next of Kin Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
                                              child: Text('First name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Text(nokFirstName)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Middle name
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Middle name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Text(nokMiddleName)),
                                      ],
                                    ),
                                    Row(children: <Widget>[
                                      ///Last name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Last name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokLastName)),
                                    ]),
                                    Row(children: <Widget>[
                                      ///Address
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Address:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokAddress)),
                                    ]),
                                    Row(
                                      children: <Widget>[
                                        ///Email
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Email:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            child: Text(nokEmail)),
                                      ],
                                    ),
                                    Row(children: <Widget>[
                                      ///Phone
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Phone no:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokPhone)),
                                    ]),
                                    Row(children: <Widget>[
                                      ///Relationship
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Relationship:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(nokRelationship)),
                                    ]),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 1.0,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Loan Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
                                              child: Text('Loan type:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(_selectedLoanType)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Loan amount
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Loan amount:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(loanAmount)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Loan tenure
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Loan tenure:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(loanTenure)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Loan purpose
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                              width: 150,
                                              child: Text('Loan purpose:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            child: Text(loanPurpose)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 1.0,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Bank Account Details",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                              child: SizedBox(
                                height: 150,
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
                                              child: Text('Bank:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(_selectedBank)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Account name
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Account name:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(accountName)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///Account number
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Container(
                                              width: 150,
                                              child: Text('Account number:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                            child: Text(accountNumber)),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ///BVN
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Container(
                                              width: 150,
                                              child: Text('BVN:',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold))),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            child: Text(bvn)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 1.0,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),

                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: FloatingActionButton(
                                        onPressed: () => goToPreviousFormPage(),
                                        tooltip: 'Previous page',
                                        child: Icon(Icons.chevron_left),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: FloatingActionButton(
                                        onPressed: () => {
                                          showConfirmDialog(
                                              context,
                                              'Are you sure you want to submit?',
                                              "Submit Application",
                                              "Yes",
                                              "No",
                                              submitApplication)
                                        },
                                        tooltip: 'Submit',
                                        child: Icon(Icons.chevron_right),
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        )),
                      )),

                ],
              ),
          ),
        ],
      ),
    );
  }

  //Pages for Business Owner account type
  Widget registerBusinessOwner(){
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 16),
          getAccountTypeBar('Create Business Owner Account'),
          Expanded(
            child: PageView(
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() {
                  businessOwnerPageViewPage = index;
                });
                print('The current page: ${businessOwnerPageController.page}');
                print('The page index: ${index}');
              },
              controller: businessOwnerPageController,
              children: <Widget>[
                ///The Personal details here
                getPersonalDetailsForm(),

                ///The residential details here
                getResidentialDetailsForm(),

                ///The next of kin details here
                getNextOfKinDetailsForm(),

                ///The employment details here
                getBusinessDetailsForm(),

                ///Files upload
                SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('User Photo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showSelectionDialog(context),
                          child: _setPhotoFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Government ID',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showIDSelectionDialog(context),
                          child: _setGovernmentIDFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Company ID',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showCompanyIDSelectionDialog(context),
                          child: _setCompanyID(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Utility Bill',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showUtilityBillSelectionDialog(context),
                          child: _setUtilityBill(),
                        ),

                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Signature',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showSignatureSelectionDialog(context),
                          child: _setSignatureFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(32, 42, 32, 32),
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FloatingActionButton(
                                    onPressed: () => goToPreviousFormPage(),
                                    tooltip: 'Previous page',
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    onPressed: () => goToNextFormPage(),
                                    tooltip: 'Next page',
                                    child: Icon(Icons.chevron_right),
                                  ),
                                ),
                              ],
                            ))
                      ],
                    )),

                ///For the preview of information
                SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      child: (Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text(
                            "Preview Details",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                                height: 1.0, width: double.infinity, color: Colors.black),
                          ),
                          Text(
                            "Personal Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    ///First name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('First name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientFirstName)),
                                  ]),
                                  Row(
                                    children: <Widget>[
                                      ///Middle name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Middle name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientMiddleName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Last name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Last name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(clientLastName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Email:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmail)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Phone
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Phone no:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(clientPhone)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Employment Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('Employment:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(employment.toString() ==
                                              "Employment.employed"
                                              ? "employed"
                                              : "unemployed")),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment sector
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment sector:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentSector)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment type
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment type:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentType)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company Address
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company address:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyAddress)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company Phone
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company phone:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyPhone)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment Date
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment date:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmploymentDate)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Net salary
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Net monthly salary:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(clientNetMonthlySalary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Next of Kin Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('First name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokFirstName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Middle name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Middle name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokMiddleName)),
                                    ],
                                  ),
                                  Row(children: <Widget>[
                                    ///Last name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Last name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokLastName)),
                                  ]),
                                  Row(children: <Widget>[
                                    ///Address
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Address:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokAddress)),
                                  ]),
                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Email:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokEmail)),
                                    ],
                                  ),
                                  Row(children: <Widget>[
                                    ///Phone
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Phone no:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokPhone)),
                                  ]),
                                  Row(children: <Widget>[
                                    ///Relationship
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('Relationship:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(nokRelationship)),
                                  ]),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Loan Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('Loan type:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedLoanType)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan amount
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan amount:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanAmount)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan tenure
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan tenure:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanTenure)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan purpose
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan purpose:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(loanPurpose)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Bank Account Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              height: 150,
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
                                            child: Text('Bank:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedBank)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Account name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Account name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Account number
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Account number:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountNumber)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///BVN
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('BVN:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(bvn)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () => goToPreviousFormPage(),
                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => {
                                        showConfirmDialog(
                                            context,
                                            'Are you sure you want to submit?',
                                            "Submit Application",
                                            "Yes",
                                            "No",
                                            submitApplication)
                                      },
                                      tooltip: 'Submit',
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                    )),

              ],
            ),
          )
        ],
      ),
    );
  }

  //Pages for Corporate account type
  Widget registerCorporateAccount(){
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child:Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 16),
        getAccountTypeBar('Create Corporate Account'),
        Expanded(
          child: PageView(
            pageSnapping: true,
            onPageChanged: (index) {
              setState(() {
                corporatePageViewPage = index;
              });
              print('The current page: ${corporatePageController.page}');
              print('The page index: ${index}');
            },
            controller: corporatePageController,
            children: <Widget>[
              ///Business details here
              getBusinessDetailsForm(title: 'Corporate Information'),

              ///Director 1. Personal Information
              getDirector1PersonalDetailsForm(),

              ///Residentiial dettails
              getResidentialDetailsForm(title: 'Director Residential details'),

              ///Files upload
              SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('User Photo',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showSelectionDialog(context),
                        child: _setPhotoFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Government ID',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showIDSelectionDialog(context),
                        child: _setGovernmentIDFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Company ID',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showCompanyIDSelectionDialog(context),
                        child: _setCompanyID(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Utility Bill',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showUtilityBillSelectionDialog(context),
                        child: _setUtilityBill(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Shop Photo',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showShopSelectionDialog(context),
                        child: _setShopFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Shop Receipt',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showShopReceiptSelectionDialog(context),
                        child: _setShopReceiptFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Shop Stocks',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showStockSelectionDialog(context),
                        child: _setStockPhotoFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Text('Signature',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      GestureDetector(
                        onTap: () => _showSignatureSelectionDialog(context),
                        child: _setSignatureFile(),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(32, 42, 32, 32),
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: FloatingActionButton(
                                  onPressed: () => salaryEarnerPageController.animateToPage(4,
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves.linear),
                                  tooltip: 'Previous page',
                                  child: Icon(Icons.chevron_left),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  onPressed: () => salaryEarnerPageController.animateToPage(6,
                                      duration: Duration(milliseconds: 400),
                                      curve: Curves.linear),
                                  tooltip: 'Next page',
                                  child: Icon(Icons.chevron_right),
                                ),
                              ),
                            ],
                          ))
                    ],
                  )),

              ///For the preview of information
              SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(24.0),
                    child: (Column(
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        Text(
                          "Preview Details",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                              height: 1.0, width: double.infinity, color: Colors.black),
                        ),
                        Text(
                          "Personal Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: <Widget>[
                                Row(children: <Widget>[
                                  ///First name
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                    child: Container(
                                        width: 150,
                                        child: Text('First name:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Text(clientFirstName)),
                                ]),
                                Row(
                                  children: <Widget>[
                                    ///Middle name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Middle name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientMiddleName)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Last name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Last name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(clientLastName)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Email
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Email:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientEmail)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Phone
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('Phone no:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(clientPhone)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Employment Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
                                          child: Text('Employment:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(employment.toString() ==
                                            "Employment.employed"
                                            ? "employed"
                                            : "unemployed")),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Employment sector
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Employment sector:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(_selectedEmploymentSector)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Employment type
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Employment type:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(_selectedEmploymentType)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Company name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Company name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientCompanyName)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Company Address
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Company address:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientCompanyAddress)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Company Phone
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Company phone:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientCompanyPhone)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Employment Date
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Employment date:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientEmploymentDate)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Net salary
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('Net monthly salary:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(clientNetMonthlySalary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Next of Kin Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
                                          child: Text('First name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokFirstName)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Middle name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Middle name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokMiddleName)),
                                  ],
                                ),
                                Row(children: <Widget>[
                                  ///Last name
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Container(
                                        width: 150,
                                        child: Text('Last name:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Text(nokLastName)),
                                ]),
                                Row(children: <Widget>[
                                  ///Address
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Container(
                                        width: 150,
                                        child: Text('Address:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Text(nokAddress)),
                                ]),
                                Row(
                                  children: <Widget>[
                                    ///Email
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Email:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokEmail)),
                                  ],
                                ),
                                Row(children: <Widget>[
                                  ///Phone
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Container(
                                        width: 150,
                                        child: Text('Phone no:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Text(nokPhone)),
                                ]),
                                Row(children: <Widget>[
                                  ///Relationship
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                    child: Container(
                                        width: 150,
                                        child: Text('Relationship:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Text(nokRelationship)),
                                ]),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Loan Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
                                          child: Text('Loan type:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(_selectedLoanType)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Loan amount
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Loan amount:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(loanAmount)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Loan tenure
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Loan tenure:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(loanTenure)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Loan purpose
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('Loan purpose:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(loanPurpose)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Bank Account Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                          child: SizedBox(
                            height: 150,
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
                                          child: Text('Bank:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(_selectedBank)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Account name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Account name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(accountName)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///Account number
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Account number:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(accountNumber)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    ///BVN
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('BVN:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(bvn)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 1.0,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),

                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FloatingActionButton(
                                    onPressed: () => salaryEarnerPageController.animateToPage(4,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.linear),
                                    tooltip: 'Previous page',
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    onPressed: () => {
                                      showConfirmDialog(
                                          context,
                                          'Are you sure you want to submit?',
                                          "Submit Application",
                                          "Yes",
                                          "No",
                                          submitApplication)
                                    },
                                    tooltip: 'Submit',
                                    child: Icon(Icons.chevron_right),
                                  ),
                                ),
                              ],
                            ))
                      ],
                    )),
                  )),

            ],
          ),
        )
      ],
    ));
  }

  //This is the search page for loans for existing users
  Widget getLoanSearchPage(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.purple,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 2),
                    color:  Colors.black12,
                    blurRadius: 5
                )
              ]
          ),
          child: Row(
              children: [
                InkWell(
                    onTap: (){
                      setState(() {
                        selectedLoanApplication = null;
                      });
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 30)),
                SizedBox(width: 20),
                Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              ]
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Stack(
            children: <Widget>[
              Column(children: <Widget>[
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: <Widget>[
                              Stack(children: <Widget>[
                                TextField(
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 16),
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0)),
                                    hintText: "Search by name, email, or phone number",
                                  ),
                                  onChanged: (value) => {collectionSearch = value},
                                  onSubmitted: (value) {
                                    searchForCollectionMatches(value);
                                  },
                                ),
                                GestureDetector(
                                    onTap: () =>
                                    {searchForCollectionMatches(collectionSearch)},
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 16.0),
                                        child: Align(
                                            heightFactor: 1,
                                            alignment: Alignment.bottomRight,
                                            child: Icon(Icons.search, size: 32))))
                              ]),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 32.0),
                                child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Card(
                                          child: ListTile(
                                            onTap: () {
                                              loanUserId = 1;
                                              loanUserFirstName = 'Offiong';
                                              loanUserLastName = 'Ekpenyong';
                                              setState((){
                                                selectedLoanApplication = LoanApplication.NEW_LOAN;
                                              });
                                            },
                                            leading: Icon(Icons.verified_user),

                                            title: Text(
                                                "Offiong Ekpenyong", style: TextStyle(color: Colors.black)
                                            ),
                                          )
                                      )
                                    ],
                                )
                                // child: ListView(
                                //     shrinkWrap: true,
                                //     children: _loanUsers.map((user) {
                                //       return Card(
                                //           child: ListTile(
                                //             onTap: () {
                                //               loanUserId = user['id'];
                                //               loanUserFirstName = user['first_name'];
                                //               loanUserLastName = user['last_name'];
                                //               setState((){
                                //                 selectedLoanApplication = LoanApplication.NEW_LOAN;
                                //               });
                                //             },
                                //             leading: CircleAvatar(
                                //               backgroundImage: NetworkImage(user['photo']
                                //                   .contains('http')
                                //                   ? user['photo']
                                //                   : "${Constants.SITE_ROUTE}${user['photo']}"),
                                //             ),
                                //             title: Text(
                                //                 "${user['first_name']} ${user['last_name']}"),
                                //             subtitle: Text(user['email'] != null
                                //                 ? "${user['email']}"
                                //                 : "${user['phone']}"),
                                //           )
                                //       );
                                //     }).toList()),
                              ),
                            ],
                          ),
                        ))),
              ]),
              Center(
                child: _loading ? CircularProgressIndicator() : null,
              )
            ],
          ),
        ),
      ],
    );
  }

  //This is the collections page
  Widget getCollectionsPage(){
    if(selectedCollectionType == CollectionType.SAVINGS){
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.purple,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 2),
                      color:  Colors.black12,
                      blurRadius: 5
                  )
                ]
            ),
            child: Row(
                children: [
                  InkWell(
                      onTap: (){
                        setState(() {
                          selectedCollectionType = null;
                        });
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 30)),
                  SizedBox(width: 20),
                  Text('Cooperative Savings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                ]
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: <Widget>[
                Column(children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  TextField(
                                    textInputAction: TextInputAction.search,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(fontSize: 16),
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0)),
                                      hintText: "Search by name, email, or phone number",
                                    ),
                                    onChanged: (value) => {collectionSearch = value},
                                    onSubmitted: (value) {
                                      searchForCollectionMatches(value);
                                    },
                                  ),
                                  GestureDetector(
                                      onTap: () =>
                                      {searchForCollectionMatches(collectionSearch)},
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 16.0),
                                          child: Align(
                                              heightFactor: 1,
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.search, size: 32))))
                                ]),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 32.0),
                                  child: ListView(
                                      shrinkWrap: true,
                                      children: _collectionUsers.map((user) {
                                        return Card(
                                            child: ListTile(
                                              onTap: () {
                                                collectionUserId = user['id'];
                                                collectionUserFirstName = user['first_name'];
                                                collectionUserLastName = user['last_name'];
                                                showModalBottomSheet(context: context, isScrollControlled:true, builder: (context) => Container(
                                                    height: 300,
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    child: Center(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                                padding: EdgeInsets.all(32.0),
                                                                child: Text(
                                                                    "Record a saving for ${user['first_name']} ${user['last_name']}",
                                                                    style: TextStyle(
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: Colors
                                                                            .blueGrey))),
                                                            Divider(),
                                                            Padding(
                                                              padding: EdgeInsets.all(16),
                                                              child: TextField(
                                                                controller: cooperativeSavingsController,
                                                                keyboardType:
                                                                TextInputType.number,
                                                                style:
                                                                TextStyle(fontSize: 16),
                                                                autofocus: false,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(30.0)
                                                                  ),
                                                                  hintText:
                                                                  "Enter the amount",
                                                                ),
                                                                onChanged: (value){
                                                                  //loanAmount = value;
                                                                  value = '${_formatNumber(value.replaceAll(',', ''))}';
                                                                  cooperativeSavingsController.value = TextEditingValue(
                                                                    text: value,
                                                                    selection: TextSelection.collapsed(offset: value.length),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: double.infinity,
                                                                height: 92.0,
                                                                child: Padding(
                                                                    padding:
                                                                    EdgeInsets.all(16.0),
                                                                    child: RaisedButton(
                                                                      textColor: Colors.white,
                                                                      child: Text("Submit"),
                                                                      color: Colors.purple,
                                                                      onPressed: () =>
                                                                          confirmSubmitCollection(),
                                                                    )))
                                                          ],
                                                        ))));
                                              },
                                              // leading: CircleAvatar(
                                              //   backgroundImage: NetworkImage(user['photo']
                                              //       .contains('http')
                                              //       ? user['photo']
                                              //       : "${Constants.SITE_ROUTE}${user['photo']}"),
                                              // ),
                                              leading: Icon(Icons.verified_user),
                                              title: Text(
                                                  "${user['first_name']} ${user['last_name']}"),
                                              subtitle: Text(user['email'] != null
                                                  ? "${user['email']}"
                                                  : "${user['phone']}"),
                                            ));
                                      }).toList()),
                                ),
                              ],
                            ),
                          ))),
                ]),
                Center(
                  child: _loading ? CircularProgressIndicator() : null,
                )
              ],
            ),
          ),
        ],
      );
    }else if(selectedCollectionType == CollectionType.LOAN_REPAYMENT){
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.purple,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 2),
                      color:  Colors.black12,
                      blurRadius: 5
                  )
                ]
            ),
            child: Row(
                children: [
                  InkWell(
                      onTap: (){
                        setState(() {
                          selectedCollectionType = null;
                        });
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 30)),
                  SizedBox(width: 20),
                  Text('Loan Repayment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                ]
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: <Widget>[
                Column(children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  TextField(
                                    textInputAction: TextInputAction.search,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(fontSize: 16),
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0)),
                                      hintText: "Search by name, email, or phone number",
                                    ),
                                    onChanged: (value) => {collectionSearch = value},
                                    onSubmitted: (value) {
                                      searchForCollectionMatches(value);
                                    },
                                  ),
                                  GestureDetector(
                                      onTap: () =>
                                      {searchForCollectionMatches(collectionSearch)},
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 16.0),
                                          child: Align(
                                              heightFactor: 1,
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.search, size: 32))))
                                ]),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 32.0),
                                  child: ListView(
                                      shrinkWrap: true,
                                      children: _collectionUsers.map((user) {
                                        return Card(
                                            child: ListTile(
                                              onTap: () {
                                                collectionUserId = user['id'];
                                                collectionUserFirstName = user['first_name'];
                                                collectionUserLastName = user['last_name'];
                                                showModalBottomSheet(context: context, isScrollControlled:true, builder: (context) => Container(
                                                    height: 300,
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    child: Center(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                                padding: EdgeInsets.all(32.0),
                                                                child: Text(
                                                                    "Record repayment for ${user['first_name']} ${user['last_name']}",
                                                                    style: TextStyle(
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: Colors
                                                                            .blueGrey))),
                                                            Divider(),
                                                            Padding(
                                                              padding: EdgeInsets.all(16),
                                                              child: TextField(
                                                                controller: loanSavingsController,
                                                                keyboardType:
                                                                TextInputType.number,
                                                                style:
                                                                TextStyle(fontSize: 16),
                                                                autofocus: false,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          30.0)),
                                                                  hintText:
                                                                  "Enter the amount",
                                                                ),

                                                                onChanged: (value){
                                                                  collectionAmount = value;
                                                                  value = '${_formatNumber(value.replaceAll(',', ''))}';
                                                                  loanSavingsController.value = TextEditingValue(
                                                                    text: value,
                                                                    selection: TextSelection.collapsed(offset: value.length),
                                                                  );
                                                                },

                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: double.infinity,
                                                                height: 92.0,
                                                                child: Padding(
                                                                    padding:
                                                                    EdgeInsets.all(16.0),
                                                                    child: RaisedButton(
                                                                      textColor: Colors.white,
                                                                      child: Text("Submit"),
                                                                      color: Colors.purple,
                                                                      onPressed: () =>
                                                                          confirmSubmitCollection(),
                                                                    )))
                                                          ],
                                                        ))));
                                              },
                                              // leading: CircleAvatar(
                                              //   backgroundImage: NetworkImage(user['photo']
                                              //       .contains('http')
                                              //       ? user['photo']
                                              //       : "${Constants.SITE_ROUTE}${user['photo']}"),
                                              // ),
                                              leading: Icon(Icons.verified_user),
                                              title: Text(
                                                  "${user['first_name']} ${user['last_name']}"),
                                              subtitle: Text(user['email'] != null
                                                  ? "${user['email']}"
                                                  : "${user['phone']}"),
                                            ));
                                      }).toList()),
                                ),
                              ],
                            ),
                          ))),
                ]),
                Center(
                  child: _loading ? CircularProgressIndicator() : null,
                )
              ],
            ),
          ),
        ],
      );
    }else{
      return getDifferentTypesOfCollectionsPages();
    }

  }

  //This is for the reports page
  Widget getReportsPage(){
    return getDifferentTypesOfReportsPages();
  }

  Widget getDifferentTypesOfReportsPages(){
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Type of Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          InkWell(
              onTap: (){
                setState(() {
                  // selectedCollectionType = CollectionType.SAVINGS;
                });
                print('You just tapped SAVINGS');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Reports on Account Opening', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),

          SizedBox(height: 16),

          InkWell(
              onTap: (){
                setState(() {
                  // selectedCollectionType = CollectionType.LOAN_REPAYMENT;
                });

                print('You just tapped LOAN_REPAYMENT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Reports on Loans Booked', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),

          SizedBox(height: 16),

          InkWell(
              onTap: (){
                setState(() {
                  // selectedCollectionType = CollectionType.LOAN_REPAYMENT;
                });

                print('You just tapped LOAN_REPAYMENT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Reports on cash collections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),


        ]
    );
  }

  //Different types of collections pages
  Widget getDifferentTypesOfCollectionsPages(){
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Type of Collection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          InkWell(
              onTap: (){
                setState(() {
                  selectedCollectionType = CollectionType.SAVINGS;
                });
                print('You just tapped SAVINGS');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Cooperative Savings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),

          SizedBox(height: 16),

          InkWell(
              onTap: (){
                setState(() {
                  selectedCollectionType = CollectionType.LOAN_REPAYMENT;
                });

                print('You just tapped LOAN_REPAYMENT');

              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child:Text('Loan Repayment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                  )
              )
          ),


        ]
    );
  }

  //This is the Profile page
  Widget getProfilePage(){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Container(
            //              color: Colors.purpleAccent,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
              child: Center(
                  child: CircleAvatar(
                    radius: 92,
                    backgroundImage: NetworkImage(
                        currentUserImage.startsWith('http')
                            ? currentUserImage
                            : '${Constants.SITE_ROUTE}${currentUserImage}'),
                  )),
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
                      controller: TextEditingController()
                        ..text = currentUserFirstName,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: TextField(
                  controller: TextEditingController()
                    ..text = currentUserLastName,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: Text(currentUserEmail)
              )
          ),
          Padding(
              padding: EdgeInsets.all(16),
              child: Center(
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
    );
}

  //This is for the Calculator page
  Widget getCalculatorPage(){
    return Column(children: <Widget>[
      Expanded(
          flex: 1,
          child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Loan Details",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      style: TextStyle(fontSize: 16),
                      autofocus: false,
                      initialValue: principal,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        hintText: "Principal",
                      ),
                      onChanged: (value) => {principal = value},
                    ),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 0.0, vertical: 32.0),
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(),
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          hintText: "Interest",
                        ),
                        //                      onChanged: (value) => {
                        //                        interest = value
                        //                      },
                        readOnly: true,
                      ),
                    ),
                    Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
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
                                  style: TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      loanTypeValue = newValue;
                                      interest =
                                      loans[loanTypeValue].split(' ')[1];
                                      _controller.text = interest;
                                    });
                                  },
                                  items: loans.keys.map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ))),
                    Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
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
                                  style: TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                    });
                                  },
                                  items: _duration.map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ))),
                  ],
                ),
              ))),
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
              )))
    ]);
  }
  
  //Create makeshift appbar
  Widget getAccountTypeBar(String text){
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.purple,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                color:  Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      child: Row(
          children: [
            InkWell(
                onTap: (){
                  setState(() {
                    selectedAccountType = null;
                  });
                },
                child: Icon(Icons.arrow_back, color: Colors.white, size: 30)),
            SizedBox(width: 20),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          ]
      ),
    );
  }

  //The Personal details form
  Widget getPersonalDetailsForm(){
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text("Client Personal Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              //Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

              //First name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientFirstNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "First name",
                  ),
                  onChanged: (value) => {clientFirstName = value},
                ),
              ),
              //Middle name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientMiddleNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Middle name (Optional)",
                  ),
                  onChanged: (value) => {clientMiddleName = value},
                ),
              ),
              //Last name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientLastNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Last name",
                  ),
                  onChanged: (value) => {clientLastName = value},
                ),
              ),
              //Gender
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Gender'), // Not necessary for Option 1
                  value: _selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  items: _gender.map((gender) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(gender)
                      ),
                      value: gender,
                    );
                  }).toList(),
                ),
              ),
              //Marital Status
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Marital Status'), // Not necessary for Option 1
                  value: _maritalStatus,
                  onChanged: (newValue) {
                    setState(() {
                      _maritalStatus = newValue;
                    });
                  },
                  items: _maritalStatuses.map((marital) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(marital)
                      ),
                      value: marital,
                    );
                  }).toList(),
                ),
              ),

              //Email
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientEmailController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Email address",
                  ),
                  onChanged: (value) => {clientEmail = value},
                ),
              ),
              //Phone number
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientPhoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Phone no",
                  ),
                  onChanged: (value) => {clientPhone = value},
                ),
              ),

              //State of Origin
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('State of Origin'), // Not necessary for Option 1
                  value: _selectedState,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedState = newValue;
                    });
                  },
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(state)
                      ),
                      value: state,
                    );
                  }).toList(),
                ),
              ),

              //Date of Birth
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                 child: Row(
                   children: [
                     FlatButton(
                       onPressed: () async {
                         DateTime datePicked = await showDatePicker(
                           context: context,
                           initialDate: DateTime.now(),
                           firstDate: DateTime(1955),
                           lastDate: DateTime.now(),
                         );

                         if(datePicked != null){
                           setState((){
                             clientDOB = DateFormat('yyyy-MM-dd').format(datePicked);
                           });
                         }
                       },
                       child: Align(
                           alignment: Alignment.centerLeft,
                           child: Text(clientDOB, style: TextStyle(fontSize: 16), textAlign: TextAlign.left)
                       ),
                     ),
                     Spacer(),
                     Icon(Icons.calendar_today)
                   ]
                 ),

              ),
              Divider(height: 2),
              //Means of ID
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Means of Identification'), // Not necessary for Option 1
                  value: _selectedMeansOfID,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMeansOfID = newValue;
                    });
                  },
                  items: _meansOfIDs.map((means) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(means)
                      ),
                      value: means,
                    );
                  }).toList(),
                ),
              ),

              //ID card number
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientIDNumberController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "ID Number",
                  ),
                  onChanged: (value) => {clientIDNumber = value},
                ),
              ),

              //Next button
              Padding(
                padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () => goToNextFormPage(),
                    tooltip: 'Next Page',
                    child: Icon(Icons.chevron_right),
                  ),
                ),
              )
            ],
          )),
        ));
  }

  //The Personal details form
  Widget getResidentialDetailsForm({title}){
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text(title != null ? title : "Client Residential Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

              //Status of Resident
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Status'), // Not necessary for Option 1
                  value: _selectedResidentialStatus,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedResidentialStatus = newValue;
                    });
                  },
                  items: _residentialStatuses.map((status) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(status)
                      ),
                      value: status,
                    );
                  }).toList(),
                ),
              ),
              //Address
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientAddressController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Address",
                  ),
                  onChanged: (value) => {clientAddress = value},
                ),
              ),

              //State of residence
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint: Text('State of Residence'), // Not necessary for Option 1
                  value: _selectedStateOfResidence,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStateOfResidence = newValue;
                    });
                  },
                  items: _statesOfResidence.map((selectedState) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(selectedState)
                      ),
                      value: selectedState,
                    );
                  }).toList(),
                ),
              ),

              //Nearest Bus stop
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientNearestBusStopController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Nearest Bus stop",
                  ),
                  onChanged: (value) => {clientNearestBusStop = value},
                ),
              ),

              //Nearest Landmark
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientNearestLandmarkController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Nearest Landmark",
                  ),
                  onChanged: (value) => {clientNearestLandmark = value},
                ),
              ),

              //Annual rent amount
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientAnnualRentController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Annual Rent",
                  ),
                  onChanged: (value){
                    clientAnnualRent = value;
                    value = '${_formatNumber(value.replaceAll(',', ''))}';
                      clientAnnualRentController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                ),
              ),

              //Move in date
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Row(
                    children:  [
                      FlatButton(
                        onPressed: () async {
                          DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1955),
                            lastDate: DateTime.now(),
                          );

                          if(datePicked != null){
                            setState((){
                              clientMoveInDate = DateFormat('yyyy-MM-dd').format(datePicked);
                            });
                          }
                        },
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(clientMoveInDate, style: TextStyle(fontSize: 16), textAlign: TextAlign.left)
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today)
                    ],
                  ),


              ),
              Divider(height: 2),

              //Next button
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                          onPressed: () => goToPreviousFormPage(),
                          tooltip: 'Previous page',
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () => goToNextFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  )
              )
            ],
          )),
        ));
  }

  //The next of Kin details form
  Widget getNextOfKinDetailsForm(){
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text("Next of Kin Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              //Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: nokFirstNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "First name",
                  ),
                  onChanged: (value) => {nokFirstName = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Middle name (Optional)",
                  ),
                  onChanged: (value) => {nokMiddleName = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Last name",
                  ),
                  onChanged: (value) => {nokLastName = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Address",
                  ),
                  onChanged: (value) => {nokAddress = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Email address",
                  ),
                  onChanged: (value) => {nokEmail = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Phone no",
                  ),
                  onChanged: (value) => {nokPhone = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Relationship e.g. Brother",
                  ),
                  onChanged: (value) => {nokRelationship = value},
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: nokOccupationController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Occupation",
                  ),
                  onChanged: (value) => {nokOccupation = value},
                ),
              ),

              Padding(
                  padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                          onPressed: () => goToPreviousFormPage(),
                          tooltip: 'Previous page',
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () => goToNextFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  )
              )
            ],
          )),
        )
    );
  }

  //The Employment details form
  Widget getEmploymentDetailsForm(){
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text(
                "Employment Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    isExpanded: true,
                    //                                style: TextStyle(height: 42, fontSize: 16),
                    hint:
                    Text('Employment type'), // Not necessary for Option 1
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company name",
                  ),
                  onChanged: (value) => {clientCompanyName = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company Address",
                  ),
                  onChanged: (value) => {clientCompanyAddress = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company phone",
                  ),
                  onChanged: (value) => {clientCompanyPhone = value},
                ),
              ),

              //Get Employment date
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Row(
                    children: [
                      FlatButton(
                        onPressed: () async {
                          DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1955),
                            lastDate: DateTime.now(),
                          );

                          if(datePicked != null){
                            setState((){
                              clientEmploymentDate = DateFormat('yyyy-MM-dd').format(datePicked);
                            });
                          }
                        },
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(clientEmploymentDate, style: TextStyle(fontSize: 16), textAlign: TextAlign.left)
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today)
                    ]
                  ),

              ),
              Divider(height: 2),

              //Staff ID Number
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientStaffIDNumberController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Staff ID Number",
                  ),
                  onChanged: (value) => {clientStaffIDNumber = value},
                ),
              ),

              //Designation
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientDesignationController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Designation",
                  ),
                  onChanged: (value) => {clientDesignation = value},
                ),
              ),

              //Salary Pay day
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientPayDayController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Pay day. E.g. 25",
                  ),
                  onChanged: (value) => {clientPayDay = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Net monthly salary",
                  ),
                  onChanged: (value){
                    clientNetMonthlySalary = value;
                    value = '${_formatNumber(value.replaceAll(',', ''))}';
                    clientNetMonthlySalaryController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
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
                            onPressed: () => goToPreviousFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () => goToNextFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ))
            ],
          )),
        ));
  }

  //The Business details form
  Widget getBusinessDetailsForm({title}){
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text(
                title ?? "Business Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    isExpanded: true,
                    hint:
                    Text('Nature of business/industry'), // Not necessary for Option 1
                    value: _selectedIndustry,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedIndustry = newValue;
                      });
                    },
                    items: _industries.map((industry) {
                      return DropdownMenuItem(
                        child: new Text(industry),
                        value: industry,
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company name",
                  ),
                  onChanged: (value) => {clientCompanyName = value},
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientCompanyRCNumberController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "RC Number",
                  ),
                  onChanged: (value) => {clientCompanyRCNumber = value},
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientCompanyTINNumberController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "TIN Number",
                  ),
                  onChanged: (value) => {clientCompanyTINNumber = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company Address",
                  ),
                  onChanged: (value) => {clientCompanyAddress = value},
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
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Company phone",
                  ),
                  onChanged: (value) => {clientCompanyPhone = value},
                ),
              ),


              //Average Monthly turnover
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientMonthlyTurnoverController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Monthly turnover",
                  ),
                  onChanged: (value){
                    clientMonthlyTurnover = value;
                    value = '${_formatNumber(value.replaceAll(',', ''))}';
                    clientMonthlyTurnoverController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },

                ),
              ),

              //Number of Employees
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: clientNumberOfEmployeesController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Number of Employees",
                  ),
                  onChanged: (value) => {clientNumberOfEmployees = value},
                ),
              ),


              Padding(
                  padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                  child: Stack(
                    children: <Widget>[
                      title != null ?
                          Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton(
                            onPressed: () => goToPreviousFormPage(),
                            tooltip: 'Next page',
                            child: Icon(Icons.chevron_left),
                          ),
                        )
                      :
                        Spacer()
                      ,
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () => goToNextFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ))
            ],
          )),
        ));
  }

  //Get directors personal details
  Widget getDirector1PersonalDetailsForm(){

    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: (Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Text("Director Personal Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              //Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

              //First name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1FirstNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "First name",
                  ),
                  onChanged: (value) => {director1FirstName = value},
                ),
              ),
              //Middle name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1MiddleNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Middle name (Optional)",
                  ),
                  onChanged: (value) => {director1MiddleName = value},
                ),
              ),
              //Last name
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1LastNameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Last name",
                  ),
                  onChanged: (value) => {director1LastName = value},
                ),
              ),
              //Gender
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Gender'), // Not necessary for Option 1
                  value: _selectedDirector1Gender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDirector1Gender = newValue;
                    });
                  },
                  items: _gender.map((gender) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(gender)
                      ),
                      value: gender,
                    );
                  }).toList(),
                ),
              ),
              //Marital Status
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Marital Status'), // Not necessary for Option 1
                  value: _maritalDirector1Status,
                  onChanged: (newValue) {
                    setState(() {
                      _maritalDirector1Status = newValue;
                    });
                  },
                  items: _maritalStatuses.map((marital) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(marital)
                      ),
                      value: marital,
                    );
                  }).toList(),
                ),
              ),

              //Email
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1EmailController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Email address",
                  ),
                  onChanged: (value) => {director1Email = value},
                ),
              ),
              //Phone number
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1PhoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "Phone no",
                  ),
                  onChanged: (value) => {director1Phone = value},
                ),
              ),

              //State of Origin
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('State of Origin'), // Not necessary for Option 1
                  value: _selectedDirector1State,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDirector1State = newValue;
                    });
                  },
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(state)
                      ),
                      value: state,
                    );
                  }).toList(),
                ),
              ),

              //Date of Birth
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Row(
                    children:  [
                      FlatButton(
                        onPressed: () async {
                          DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1955),
                            lastDate: DateTime.now(),
                          );

                          if(datePicked != null){
                            setState((){
                              director1DOB = DateFormat('yyyy-MM-dd').format(datePicked);
                            });
                          }
                        },
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(director1DOB, style: TextStyle(fontSize: 16), textAlign: TextAlign.left)
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today)
                    ],

                  )
              ),
              Divider(height: 2),
              //Means of ID
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child:  DropdownButton(
                  itemHeight: 70.0,
                  isExpanded: true,
                  //                                style: TextStyle(height: 42, fontSize: 16),
                  hint:
                  Text('Means of Identification'), // Not necessary for Option 1
                  value: _selectedDirector1MeansOfID,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDirector1MeansOfID = newValue;
                    });
                  },
                  items: _meansOfIDs.map((means) {
                    return DropdownMenuItem(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(means)
                      ),
                      value: means,
                    );
                  }).toList(),
                ),
              ),

              //ID card number
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1IDNumberController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "ID Number",
                  ),
                  onChanged: (value) => {director1IDNumber = value},
                ),
              ),

              //BVN
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: TextField(
                  controller: director1BVNController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    hintText: "BVN",
                  ),
                  onChanged: (value) => {director1BVN = value},
                ),
              ),

              //Next button
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                          onPressed: () => goToPreviousFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_left),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () => goToNextFormPage(),
                          tooltip: 'Next page',
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ))
            ],
          )),
        ));
  }

  //Got to next form page
  goToNextFormPage(){
    if(selectedAccountType == AccountType.SALARY_EARNER){
      salaryEarnerPageController.animateToPage(++salaryEarnerPageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedAccountType == AccountType.BUSINESS_OWNER){
      businessOwnerPageController.animateToPage(++businessOwnerPageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedAccountType == AccountType.CORPORATE_ACCOUNT){
      corporatePageController.animateToPage(++corporatePageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedLoanApplication == LoanApplication.NEW_LOAN){
      loanPageController.animateToPage(++loanPageViewPage,
            duration: Duration(milliseconds: 400),
            curve: Curves.linear);
    }
  }

  //Got to previous form page
  goToPreviousFormPage(){
    if(selectedAccountType == AccountType.SALARY_EARNER){
      salaryEarnerPageController.animateToPage(--salaryEarnerPageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedAccountType == AccountType.BUSINESS_OWNER){
      businessOwnerPageController.animateToPage(--businessOwnerPageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedAccountType == AccountType.CORPORATE_ACCOUNT){
      corporatePageController.animateToPage(--corporatePageViewPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.linear);
    }else if(selectedLoanApplication == LoanApplication.NEW_LOAN){
      if(loanPageViewPage == 0){
        setState((){
          selectedLoanApplication = null;
        });
      }else{
        loanPageController.animateToPage(--loanPageViewPage,
            duration: Duration(milliseconds: 400),
            curve: Curves.linear);
      }

    }
  }

  //This is just holing this thing for now
  Widget getLoanApplicationPages(){

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: 16),
          getAccountTypeBar('Apply for Loan'),
          Expanded(
            child: PageView(
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() {
                  loanPageViewPage = index;
                });
                print('The current page: ${loanPageController.page}');
                print('The page index: ${index}');
              },
              controller: loanPageController,
              children: <Widget>[
                ///The loan details here
                SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      child: (Column(
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
                                      value: value, child: Text(value));
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "Amount",
                              ),
                              onChanged: (value){
                                loanAmount = value;
                                value = '${_formatNumber(value.replaceAll(',', ''))}';
                                loanAmountController.value = TextEditingValue(
                                  text: value,
                                  selection: TextSelection.collapsed(offset: value.length),
                                );
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "Purpose",
                              ),
                              onChanged: (value) => {loanPurpose = value},
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "Loan Tenure",
                              ),
                              onChanged: (value) => {loanTenure = value},
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () => goToPreviousFormPage(),
                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => goToNextFormPage(),
                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                    )),

                ///The bank details
                SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      child: (Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text(
                            "Bank Account Details",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "Account name",
                              ),
                              onChanged: (value) => {accountName = value},
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "Account number",
                              ),
                              onChanged: (value) => {accountNumber = value},
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
                                    borderRadius: BorderRadius.circular(30.0)),
                                hintText: "BVN",
                              ),
                              onChanged: (value) => {bvn = value},
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () => goToPreviousFormPage(),
                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => goToNextFormPage(),
                                      tooltip: 'Next page',
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                    )),

                ///Files upload
                SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('User Photo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showSelectionDialog(context),
                          child: _setPhotoFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Government ID',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showIDSelectionDialog(context),
                          child: _setGovernmentIDFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Company ID',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showCompanyIDSelectionDialog(context),
                          child: _setCompanyID(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Utility Bill',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showUtilityBillSelectionDialog(context),
                          child: _setUtilityBill(),
                        ),

                        Padding(
                            padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                            child: Text('Signature',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        GestureDetector(
                          onTap: () => _showSignatureSelectionDialog(context),
                          child: _setSignatureFile(),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(32, 42, 32, 32),
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FloatingActionButton(
                                    onPressed: () => goToPreviousFormPage(),
                                    tooltip: 'Previous page',
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    onPressed: () => goToNextFormPage(),
                                    tooltip: 'Next page',
                                    child: Icon(Icons.chevron_right),
                                  ),
                                ),
                              ],
                            ))
                      ],
                    )),

                ///For the preview of information
                SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      child: (Column(
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          Text(
                            "Preview Details",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          //                    Text("Client personal details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                                height: 1.0, width: double.infinity, color: Colors.black),
                          ),
                          Text(
                            "Personal Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    ///First name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('First name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Text(clientFirstName)),
                                  ]),
                                  Row(
                                    children: <Widget>[
                                      ///Middle name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Middle name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientMiddleName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Last name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Last name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(clientLastName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Email:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmail)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Phone
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Phone no:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(clientPhone)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Employment Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('Employment:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(employment.toString() ==
                                              "Employment.employed"
                                              ? "employed"
                                              : "unemployed")),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment sector
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment sector:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentSector)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment type
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment type:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedEmploymentType)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company Address
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company address:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyAddress)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Company Phone
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Company phone:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientCompanyPhone)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Employment Date
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Employment date:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(clientEmploymentDate)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Net salary
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Net monthly salary:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(clientNetMonthlySalary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Next of Kin Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('First name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokFirstName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Middle name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Middle name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokMiddleName)),
                                    ],
                                  ),
                                  Row(children: <Widget>[
                                    ///Last name
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Last name:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokLastName)),
                                  ]),
                                  Row(children: <Widget>[
                                    ///Address
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Address:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokAddress)),
                                  ]),
                                  Row(
                                    children: <Widget>[
                                      ///Email
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Email:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                          child: Text(nokEmail)),
                                    ],
                                  ),
                                  Row(children: <Widget>[
                                    ///Phone
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Container(
                                          width: 150,
                                          child: Text('Phone no:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(nokPhone)),
                                  ]),
                                  Row(children: <Widget>[
                                    ///Relationship
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      child: Container(
                                          width: 150,
                                          child: Text('Relationship:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Text(nokRelationship)),
                                  ]),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Loan Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                                            child: Text('Loan type:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedLoanType)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan amount
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan amount:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanAmount)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan tenure
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan tenure:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(loanTenure)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Loan purpose
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('Loan purpose:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(loanPurpose)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Bank Account Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: SizedBox(
                              height: 150,
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
                                            child: Text('Bank:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(_selectedBank)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Account name
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Account name:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountName)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///Account number
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: Container(
                                            width: 150,
                                            child: Text('Account number:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                          child: Text(accountNumber)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ///BVN
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Container(
                                            width: 150,
                                            child: Text('BVN:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                          child: Text(bvn)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                          ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 42, 0, 0),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: FloatingActionButton(
                                      onPressed: () => goToPreviousFormPage(),
                                      tooltip: 'Previous page',
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton(
                                      onPressed: () => {
                                        showConfirmDialog(
                                            context,
                                            'Are you sure you want to submit?',
                                            "Submit Application",
                                            "Yes",
                                            "No",
                                            submitApplication)
                                      },
                                      tooltip: 'Submit',
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                    )),

              ],
            ),
          ),
        ],
      ),
    );

  }

}
