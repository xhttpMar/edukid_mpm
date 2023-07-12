import 'package:edukid/features/trivia/data/bloc/auth_bloc.dart';
import 'package:edukid/features/trivia/presentation/screens/login/login.dart';
import 'package:edukid/features/trivia/presentation/widgets/card.dart';
import 'package:edukid/features/trivia/presentation/widgets/clickableImg.dart';
import 'package:edukid/features/trivia/presentation/widgets/dialog/dialog_factory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../config/colors.dart' as app_colors;


final user = FirebaseAuth.instance.currentUser!;
final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
String name = '';

class GetStartedPage extends StatefulWidget {
  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  int points = 0;
  DatabaseReference pointsRef = ref.child('points');

  @override
  void initState() {
    super.initState();
    pointsRef = ref.child('points');
    // Listen for changes to the "points" field in real-time
    pointsRef.onValue.listen((event) {
      var dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        setState(() {
          points = dataSnapshot.value as int;
        });
      }
    });
  }

  @override
  void dispose() {
    pointsRef.onValue.listen((event) {}).cancel(); // Cancel the listener when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'EduKid',
            style: TextStyle(fontSize: 2.5.h),
          ),
          actions: [
          IconButton(
            icon: Icon(Icons.account_box_rounded),
            onPressed: () {
              // Perform action when the icon is pressed
              Navigator.of(context).pushNamed('profile');
            },
          ),
        ],
          backgroundColor: app_colors.orange,
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnAuthenticated) {
              // Navigate to the sign in screen when the user Signs Out
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/doodle.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(6.w, 6.w, 6.w, 15.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/coin.png',
                            height: 6.h,
                          ),
                          Text(
                            '$points',
                              style: TextStyle(
                                  fontSize: 3.h, fontWeight: FontWeight.bold))
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Hello there! What would you like to revise today?',
                              style: TextStyle(
                                  fontSize: 3.2.h, fontWeight: FontWeight.bold),
                              softWrap: true,
                            ),
                          ),
                          Expanded(flex: 1, child: ClickableImage()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CardWidget(
                              text: 'Maths',
                              imagePath: 'images/numbers.png',
                              borderColor: app_colors.fucsia,
                              goTo: 'math'),
                          SizedBox(width: 10.w),
                          const CardWidget(
                              text: 'Geography',
                              imagePath: 'images/geo.png',
                              borderColor: app_colors.blue,
                              goTo: 'geo'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CardWidget(
                              text: 'History',
                              imagePath: 'images/storia.png',
                              borderColor: app_colors.green,
                              goTo: 'storia'),
                          SizedBox(width: 10.w),
                          const CardWidget(
                              text: 'Science',
                              imagePath: 'images/scienze.png',
                              borderColor: app_colors.orange,
                              goTo: 'scienze'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void showdialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Tutorial',
              description: 'Ciao io sono Monky!');
        });
  }
}
