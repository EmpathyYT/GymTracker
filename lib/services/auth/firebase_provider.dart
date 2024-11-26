import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:gymtracker/Exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/auth/auth_user.dart';
import 'package:gymtracker/services/auth/firebase_auth_user.dart';
import '../../firebase_options.dart';
import 'auth_provider.dart';

class FirebaseProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return FirebaseAuthUser.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthWeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw AuthEmailAlreadyInUseException();
      } else if (e.code == 'invalid-email') {
        throw AuthInvalidEmailException();
      } else {
        throw GenericAuthException();
      }
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return FirebaseAuthUser.fromFirebaseUser(user);
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return currentUser!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
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
      throw UserNotFoundAuthException();
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotFoundAuthException();
    }
    await user.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    try {
      return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'invalid-email':
          throw AuthInvalidEmailException();
        default:
          throw GenericAuthException();
      }
    } on Exception {
      throw GenericAuthException();
    }
  }
}
