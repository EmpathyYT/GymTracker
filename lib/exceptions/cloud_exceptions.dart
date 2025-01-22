class GenericCloudException implements Exception {
  final String message = 'An error occurred';
}

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

class ReachedSquadLimitException implements Exception {
  final String message = 'Reached squad limit';
}

class CouldNotFetchSquadException implements Exception {
  final String message = 'Could not fetch squad';
}

class CouldNotFetchUserException implements Exception {
  final String message = 'Could not fetch user';
}

class InvalidSquadEntriesException implements Exception {
  final String message = 'Invalid squad entries';
}

class CouldNotAddFriendException implements Exception {
  final String message = 'Could not add friend';
}

class UserAlreadyFriendException implements Exception {
  final String message = 'User already a friend';
}

class AlreadySentFriendRequestException implements Exception {
  final String message = 'Already sent friend request';
}

class CouldNotDeleteFriendRequestException implements Exception {
  final String message = 'Could not delete friend request';
}