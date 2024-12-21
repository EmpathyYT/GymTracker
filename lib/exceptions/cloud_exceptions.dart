class CouldNotCreateUserException implements Exception {
  final String message = 'Could not create user';
}

class CouldNotUpdateUserException implements Exception {
  final String message = 'Could not update user';
}

class CouldNotDeleteUserException implements Exception {
  final String message = 'Could not delete user';
}

class CouldNotCreateSquadException implements Exception {
  final String message = 'Could not create squad';
}

class CouldNotUpdateSquadException implements Exception {
  final String message = 'Could not update squad';
}

class CouldNotDeleteSquadException implements Exception {
  final String message = 'Could not delete squad';
}

class CouldNotAddMemberToSquadException implements Exception {
  final String message = 'Could not add member to squad';
}

class CouldNotRemoveMemberFromSquadException implements Exception {
  final String message = 'Could not remove member from squad';
}