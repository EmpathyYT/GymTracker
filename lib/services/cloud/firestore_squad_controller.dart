import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';

import '../../exceptions/cloud_exceptions.dart';
import '../../constants/cloud_contraints.dart';

class FirestoreSquadController {
  final squads = FirebaseFirestore.instance.collection('squads');

  static final FirestoreSquadController _instance =
      FirestoreSquadController._internal();

  FirestoreSquadController._internal();

  factory FirestoreSquadController() => _instance;

  Future<void> createSquad({
    required String name,
    required String creatorId,
    required String description,
  }) async {
    try {
      if (await reachedSquadLimit(userId: creatorId)) {
        throw ReachedSquadLimitException();
      }

      if (!validSquadEntries(name: name, description: description)) {
        throw InvalidSquadEntriesException();
      }

      final squadSnapshot = await squads.add({
        squadNameFieldName: name,
        ownerUserFieldId: creatorId,
        membersFieldName: [],
        timeCreatedFieldName: Timestamp.now(),
        squadDescriptionFieldName: description,
      });
      final squad = CloudSquad.fromSnapshot(await squadSnapshot.get());

      await addUserToSquad(squadId: squad.documentId, memberId: squad.ownerId);
    } on ReachedSquadLimitException {
      throw ReachedSquadLimitException();
    } on InvalidSquadEntriesException {
      throw InvalidSquadEntriesException();
    } catch (e) {
      throw CouldNotCreateSquadException();
    }
  }

  Future<void> updateSquad({
    required String fieldName,
    required String squadId,
    required dynamic value,
  }) async {
    try {
      switch (fieldName) {
        case squadNameFieldName:
          await squads.doc(squadId).update({
            squadNameFieldName: value as String,
          });
          break;

        case ownerUserFieldId:
          await squads.doc(squadId).update({
            ownerUserFieldId: value as String,
          });
          break;

        case membersFieldName:
          await squads.doc(squadId).update({
            membersFieldName: value as List<String>,
          });
          break;
      }
    } catch (e) {
      log(e.toString());
      throw CouldNotUpdateSquadException();
    }
  }

  Future<void> addUserToSquad({
    required String squadId,
    required String memberId,
  }) async {
    try {
      if (await isUserInSquad(squadId: squadId, userId: memberId)) {
        throw UserAlreadyInSquadException();
      }

      if (await reachedSquadLimit(userId: memberId)) {
        throw ReachedSquadLimitException();
      }

      final squad = await squads.doc(squadId).get();
      final members = (squad.get(membersFieldName) as List<dynamic>?)
              ?.map((e) => e as String).toList() ??
          [];
      members.add(memberId);
      await updateSquad(
        fieldName: membersFieldName,
        squadId: squadId,
        value: members,
      );

      final userController = FirestoreUserController();
      userController.addSquad(memberId, squadId);
    } catch (e) {
      log(e.toString());
      throw CouldNotAddMemberToSquadException();
    }
  }

  Future<void> removeMemberFromSquad({
    required String squadId,
    required String memberId,
  }) async {
    try {
      final squad = await squads.doc(squadId).get();
      final members = squad.get(membersFieldName) as List<String>;
      members.remove(memberId);
      await updateSquad(
        fieldName: membersFieldName,
        squadId: squadId,
        value: members,
      );

      final userController = FirestoreUserController();
      await userController.removeSquad(memberId, squadId);
    } catch (e) {
      throw CouldNotRemoveMemberFromSquadException();
    }
  }

  Future<void> deleteSquadAndMembers({
    required String squadId,
  }) async {
    try {
      final squad = await squads.doc(squadId).get();
      final members = squad.get(membersFieldName) as List<String>;
      for (final member in members) {
        await removeMemberFromSquad(squadId: squadId, memberId: member);
      }
      await squads.doc(squadId).delete();
    } catch (e) {
      throw CouldNotDeleteSquadException();
    }
  }

  Future<CloudSquad> fetchSquad({
    required String squadId,
  }) async {
    try {
      final squad = await squads.doc(squadId).get();
      return CloudSquad.fromSnapshot(squad);
    } catch (e) {
      throw CouldNotFetchSquadException();
    }
  }

  Future<bool> isUserInSquad({
    required String squadId,
    required String userId,
  }) async {
    try {
      final squad = await squads.doc(squadId).get();
      final members = (squad.get(membersFieldName) as List<dynamic>?)
              ?.map((e) => e as String).toList() ??
          [];
      return members.contains(userId);
    } catch (e) {
      throw GenericCloudException();
    }
  }

  Future<bool> reachedSquadLimit({
    required String userId,
  }) async {
    try {
      final userController = FirestoreUserController();
      final user = await userController.fetchUser(userId, isPersonal: true);
      return !(user.squadLimit >= user.squads!.length);
    } catch (e) {
      throw GenericCloudException();
    }
  }

  bool validSquadEntries({required String name, required String description}) {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        name.length <= 20 &&
        description.split(" ").length <= 100;
  }

}
