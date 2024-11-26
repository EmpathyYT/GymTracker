class GenericAuthException implements Exception {
  final String message;

  GenericAuthException({this.message='An error occurred'});
}

class AuthEmailAlreadyInUseException extends GenericAuthException {
  AuthEmailAlreadyInUseException() : super(message: 'Email is already in use');
}

class AuthInvalidEmailException extends GenericAuthException {
  AuthInvalidEmailException() : super(message: 'Invalid email');
}

class AuthWeakPasswordException extends GenericAuthException {
  AuthWeakPasswordException() : super(message: 'Weak password');
}

class UserNotFoundAuthException extends GenericAuthException {
  UserNotFoundAuthException() : super(message: 'User not found');
}

class WrongPasswordAuthException extends GenericAuthException {
  WrongPasswordAuthException() : super(message: 'Wrong password');
}
