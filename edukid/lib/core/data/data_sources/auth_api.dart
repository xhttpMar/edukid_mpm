import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthAPI {

  String getSignedInUserUID();

  bool isSignedInUserNull();

}

class AuthAPIImpl implements AuthAPI {

  final _firebaseAuth = FirebaseAuth.instance;

  @override
  String getSignedInUserUID() {
    return _firebaseAuth.currentUser!.uid;
  }

  @override
  bool isSignedInUserNull() {
    return _firebaseAuth.currentUser == null;
  }

}