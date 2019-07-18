import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polygon_clipper/polygon_border.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.yellow, primaryColor: Color(0XFFffdd00)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final double topPolygonSize = 270;
  final double curvedBackgroundRadius = 100;
  final double curvedBackgroundTopPosition = 80;
  final double curvedBackgroundAngle = 31;
  double curvedBackgroundLeftPosition;
  bool isLogin = true;

  AnimationController _logoController;
  AnimationController _formController;
  AnimationController _formButtonController;

  Animation _logoSlideAnimation;
  Animation _formOpacityAnimation;
  Animation _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();
    curvedBackgroundLeftPosition =  (math.sqrt(math.pow(100, 2) + math.pow(100, 2))) -
        curvedBackgroundRadius;

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _formController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _formButtonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _logoSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _logoController,
            curve: Interval(0, 1.0, curve: Curves.easeIn)));

    _formOpacityAnimation =
        CurvedAnimation(parent: _formController, curve: Curves.easeIn);

    _buttonSlideAnimation = Tween<double>(begin: 1.5, end: 0.0).animate(
        CurvedAnimation(
            parent: _formButtonController,
            curve: Interval(0, 1.0, curve: Curves.easeIn)));

    _logoController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _formController.forward();
        }
      })..forward();

    _formController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
       _formButtonController.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _logoController.dispose();
    _formController.dispose();
    _formButtonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: Color(0XFF313131),
      body: Form(
        child: Stack(
          children: <Widget>[
            _curvedBackContainer(Color(0XFF2a2a2a), curvedBackgroundTopPosition - 10, curvedBackgroundLeftPosition - 2),
            _curvedBackContainer(Color(0XFF232323), curvedBackgroundTopPosition, curvedBackgroundLeftPosition),
            _backgroundContainer(),
            _buildTopPolygon(),
            _buildLogoText(),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 200, left: 40, right: 40),
                child: _buildFormContent(),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTopPolygon() {
    return Positioned(
      top: -1 * (25 / 100 * topPolygonSize),
      right: -1 * (23 / 100 * topPolygonSize),
      child: Container(
        height: topPolygonSize,
        width: topPolygonSize,
        child: ClipPolygon(
          sides: 6,
          borderRadius: 10,
          child: Container(
            color: Color(0XFFFFDD00),
          ),
        ),
      ),
    );
  }

  _buildLogoText() {
    return Positioned(
      top: 30 / 100 * topPolygonSize,
      right: 22 / 100 * topPolygonSize,
      child: AnimatedBuilder(
              animation: _logoSlideAnimation,
              builder: (context, child){
                return Transform(
                   transform:
          Matrix4.translationValues(0, _logoSlideAnimation.value * 100, 0),
                  child: Text(
            'LOGO',
            style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
          ),
        );
              },
      ),
    );
  }

  _curvedBackContainer(Color color, double topPosition, double leftPosition) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: Transform.rotate(
        angle: _degreesToRadian(curvedBackgroundAngle),
        alignment: FractionalOffset.topLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(curvedBackgroundRadius)),
            color: color,
          ),
          width: deviceWidth / math.cos(_degreesToRadian(curvedBackgroundAngle)),
          //width:  MediaQuery.of(context).size.width,
          height:
              math.sqrt(math.pow(deviceWidth, 2) + math.pow(deviceWidth, 2)),
        ),
      ),
    );
  }

  _backgroundContainer() {
    double deviceWidth = MediaQuery.of(context).size.width;
    double backgroundTopMargin = curvedBackgroundTopPosition + (deviceWidth * math.tan(_degreesToRadian(curvedBackgroundAngle)));
    return Padding(
      padding: EdgeInsets.only(top: backgroundTopMargin),
      child: Container(
        color: Color(0XFF232323),
      ),
    );
  }

  _buildFormContent() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildAuthNavigation(),
          SizedBox(
            height: 50,
          ),
          _buildFormFields(),
          SizedBox(
            height: 40,
          ),
          _buildFormButton()
        ],
      ),
    );
  }

  _buildFormFields() {
    return FadeTransition(
      opacity: _formOpacityAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isLogin)
            Column(
              children: <Widget>[
                _buildTextField(labelText: 'Fullname'),
                _buildTextField(labelText: 'Username'),
              ],
            ),
          _buildTextField(labelText: 'Email or Username'),
          _buildTextField(
              labelText: 'Password',
              obscureText: true,
              suffixIcon: Icon(
                Icons.remove_red_eye,
                color: Colors.white,
                size: 17,
              )),
          SizedBox(
            height: 10,
          ),
          if (isLogin)
            Text(
              'Forget pass',
              style: TextStyle(color: Color(0XFFFFDD00)),
            ),
        ],
      ),
    );
  }

  _buildAuthNavigation() {
    return Row(
      children: <Widget>[
        Text(
          (isLogin) ? 'LOGIN' : 'Sign up',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4.0),
          child: Text(
            '/',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        GestureDetector(
          child: Text(
            (isLogin) ? 'Sign up' : 'LOGIN',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onTap: () {
            _formController.reset();
            _formButtonController.reset();
            _formController.forward();
            setState(() {
              isLogin = !isLogin;
            });
          },
        ),
      ],
    );
  }

  _buildTextField(
      {String labelText, bool obscureText = false, Icon suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Color(0XFF9a9a9a)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            suffixIcon: suffixIcon),
        obscureText: obscureText,
      ),
    );
  }

  _buildFormButton() {
    double buttonWidth = 100;
    return AnimatedBuilder(
          animation: _buttonSlideAnimation,
          builder: (context, child){
            return Transform(
        transform:
            Matrix4.translationValues(_buttonSlideAnimation.value * 100.0, 0, 0),
        child: Container(
          height: buttonWidth,
          width: buttonWidth,
          child: FittedBox(
            fit: BoxFit.cover,
            child: FloatingActionButton(
              backgroundColor: Color(0XFFFFDD00),
              shape: PolygonBorder(
                sides: 6,
                borderRadius: 10.0,
              ),
              child: Icon(Icons.arrow_forward),
              onPressed: () {},
            ),
          ),
        ),
      );
          },
    );
  }

  double _degreesToRadian(double degrees){
    return degrees * math.pi / 180;
  }
}
