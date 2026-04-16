import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google 登入已取消');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook 登入失敗: ${result.message}');
    }

    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return currentUser?.getIdToken();
  }

  bool get isAppleSignInAvailable =>
      defaultTargetPlatform == TargetPlatform.iOS || kIsWeb;
}
