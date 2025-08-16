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

class UserNotInSquadException implements Exception {
  final String message = 'Could not remove member that does not exist';
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

class AlreadySentSquadRequestException implements Exception {
  final String message = 'Already sent squad request';
}

class CouldNotFetchAchievementsException implements Exception {
  final String message = 'Could not fetch achievements';
}

class CouldNotDeleteFriendRequestException implements Exception {
  final String message = 'Could not delete friend request';
}

class CouldNotAddYourselfAsFriendException implements Exception {
  final String message = 'Could not add yourself as a friend';

}

class InvalidUserNameFormatException implements Exception {
  final String message = 'Invalid username format';
}

class InvalidSquadNameFormatException implements Exception {
  final String message = 'Invalid squad name format';
}

class InvalidBioFormatException implements Exception {
  final String message = 'Invalid biography format';
}

class InvalidSquadBioFormatException implements Exception {
  final String message = 'Invalid squad biography format';
}

class SquadDescriptionTooLongException implements Exception {
  final String message = 'Squad description too long';
}

class NoChangesMadeException implements Exception {
  final String message = 'No changes made';
}

class BioTooLongException implements Exception {
  final String message = 'Biography too long';
}

class UsernameAlreadyUsedException implements Exception {
  final String message = 'Username already used';
}

class UserAlreadyInSquadException implements Exception {
  final String message = 'User already in squad';
}
class AlreadyFinishedWorkoutException implements Exception {
  final String message = 'Already finished workout';
}
class CouldNotSchedulePrException implements Exception {
  final String message = 'Could not schedule PR';
}

class CouldNotFetchPrsException implements Exception {
  final String message = 'Could not fetch PRs';
}