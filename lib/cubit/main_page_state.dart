part of 'main_page_cubit.dart';



abstract class MainPageState {
  final Exception? exception;
  final bool isLoading;
  final String loadingText;
  final bool success;
  final NotificationsType? notifications;

  MainPageState copyWith({NotificationsType? notifications});

  const MainPageState(
      {
        this.exception,
        this.isLoading = false,
        this.loadingText = "",
        this.success = false,
        this.notifications = const {}
      });


}

final class SquadSelector extends MainPageState {
  const SquadSelector(
      {
        super.exception,
        super.isLoading = false,
        super.loadingText = "",
        super.success = false,
        super.notifications = const {},
      });

  @override
  SquadSelector copyWith({NotificationsType? notifications}) {
    return SquadSelector(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }


}

final class AddWarrior extends MainPageState {
  const AddWarrior(
      {
        super.exception,
        super.isLoading = false,
        super.loadingText = "",
        super.success = false,
        super.notifications = const {},
      });

  @override
  AddWarrior copyWith({NotificationsType? notifications}) {
    return AddWarrior(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }

}

final class NewSquad extends MainPageState {
  const NewSquad(
      {
        super.exception,
        super.isLoading = false,
        super.loadingText = "",
        super.success = false,
        super.notifications = const {},
      });

  @override
  NewSquad copyWith({NotificationsType? notifications}) {
    return NewSquad(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }

}

final class Settings extends MainPageState {
  const Settings(
      {
        super.exception,
        super.isLoading = false,
        super.loadingText = "",
        super.success = false,
        super.notifications = const {},
      });

  @override
  Settings copyWith({NotificationsType? notifications}) {
    return Settings(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }

}
