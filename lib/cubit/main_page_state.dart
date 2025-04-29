part of 'main_page_cubit.dart';

abstract class MainPageState {
  final Exception? exception;
  final bool isLoading;
  final String loadingText;
  final bool success;
  final RequestsSortingType? notifications;

  MainPageState copyWith({RequestsSortingType? notifications});

  const MainPageState(
      {this.exception,
      this.isLoading = false,
      this.loadingText = "",
      this.success = false,
      this.notifications});
}

final class ProfileViewer extends MainPageState {
  const ProfileViewer({
    super.exception,
    super.isLoading = false,
    super.loadingText = "",
    super.success = false,
    super.notifications,
  });

  @override
  MainPageState copyWith({RequestsSortingType? notifications}) {
    return ProfileViewer(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }
}

final class WorkoutPlanner extends MainPageState {
  const WorkoutPlanner({
    super.exception,
    super.isLoading = false,
    super.loadingText = "",
    super.success = false,
    super.notifications,
  });

  @override
  WorkoutPlanner copyWith({RequestsSortingType? notifications}) {
    return WorkoutPlanner(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }
}

final class SquadSelector extends MainPageState {
  final CloudSquad? squad;

  const SquadSelector(
      {super.exception,
      super.isLoading = false,
      super.loadingText = "",
      super.success = false,
      super.notifications,
      this.squad});

  @override
  SquadSelector copyWith({RequestsSortingType? notifications}) {
    return SquadSelector(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }
}

final class KinViewer extends MainPageState {
  const KinViewer({
    super.exception,
    super.isLoading = false,
    super.loadingText = "",
    super.success = false,
    super.notifications,
  });

  @override
  KinViewer copyWith({RequestsSortingType? notifications}) {
    return KinViewer(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }
}

// final class NewSquad extends MainPageState {
//   const NewSquad(
//       {
//         super.exception,
//         super.isLoading = false,
//         super.loadingText = "",
//         super.success = false,
//         super.notifications,
//       });
//
//   @override
//   NewSquad copyWith({RequestsSortingType? notifications}) {
//     return NewSquad(
//       exception: exception,
//       isLoading: isLoading,
//       loadingText: loadingText,
//       success: success,
//       notifications: notifications,
//     );
//   }
//
// }

final class Settings extends MainPageState {
  const Settings({
    super.exception,
    super.isLoading = false,
    super.loadingText = "",
    super.success = false,
    super.notifications,
  });

  @override
  Settings copyWith({RequestsSortingType? notifications}) {
    return Settings(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }
}
