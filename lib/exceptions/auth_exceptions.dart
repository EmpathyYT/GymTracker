class UserNotFoundAuthException implements Exception {
  final String message = 'User not found';
}

class WrongPasswordAuthException implements Exception {
  final String message = 'Wrong password';
}

class WeakPasswordAuthException implements Exception {
  final String message = 'Weak password';
}

class EmailAlreadyInUseAuthException implements Exception {
  final String message = 'Email already in use';
}

class InvalidEmailAuthException implements Exception {
  final String message = 'Invalid email';
}

class GenericAuthException implements Exception {
  final String message = 'An error occurred';
}

class UserNotLoggedInException implements Exception {
  final String message = 'User not logged in';
}

class EmptyCredentialsAuthException implements Exception {
  final String message = 'Please fill in the fields';
}

class EmailNotConfirmedAuthException implements Exception {
  final String message = 'Email not confirmed';
}

class CantResetWithSamePassword implements Exception {
  final String message = 'You can\'t reset your password with the same password';
}
