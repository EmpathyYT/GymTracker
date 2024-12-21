import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';

import '../../exceptions/cloud_exceptions.dart';
import 'cloud_contraints.dart';

class FirestoreSquadController {
  final squads = FirebaseFirestore.instance.collection('squads');

  static final FirestoreSquadController _instance =
      FirestoreSquadController._internal();

  FirestoreSquadController._internal();

  factory FirestoreSquadController() => _instance;

  Future<void> createSquad({
    required String name,
    required String creatorId,
  }) async {
    try {
      await squads.doc().set({
        squadNameFieldName: name,
        ownerUserFieldId: creatorId,
        membersFieldName: [],
        timeCreatedFieldName: DateTime.now(),
      });
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
      throw CouldNotUpdateSquadException();
    }
  }

  Future<void> deleteSquad({
    required String squadId,
  }) async {
    try {
      await squads.doc(squadId).delete();

    } catch (e) {
      throw CouldNotDeleteSquadException();
    }
  }

  Future<void> addMemberToSquad({
    required String squadId,
    required String memberId,
  }) async {
    try {
      final squad = await squads.doc(squadId).get();
      final members = squad.get(membersFieldName) as List<String>;
      members.add(memberId);
      await updateSquad(
        fieldName: membersFieldName,
        squadId: squadId,
        value: members,
      );

      final userController = FirestoreUserController();
      await userController.updateUser(
        fieldName: squadFieldName,
        userId: memberId,
        value: [...(await userController.fetchUser(memberId)).squads, squadId],
      );

    } catch (e) {
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
      await userController.updateUser(
        fieldName: squadFieldName,
        userId: memberId,
        value: (await userController.fetchUser(memberId)).squads
            .where((element) => element != squadId)
            .toList(),
      );

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
      await deleteSquad(squadId: squadId);
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
      throw CouldNotDeleteSquadException();
    }
  }

}
