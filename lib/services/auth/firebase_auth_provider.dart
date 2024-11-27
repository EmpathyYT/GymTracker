import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:gymtracker/services/auth/auth_provider.dart';
import '../../exceptions/auth_exceptions.dart';
import '../../firebase_options.dart';
import 'auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUser.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return AuthUser.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return currentUser!;
    } on FirebaseAuthException catch (e) {


      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == "channel-error") {
        throw EmptyCredentialsAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    if (currentUser == null) {
      throw UserNotLoggedInException();
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInException();
    }
    await user.sendEmailVerification();
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }


}
