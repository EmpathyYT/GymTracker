part of 'main_page_cubit.dart';

abstract class MainPageState {
  final Exception? exception;
  final bool isLoading;
  final String loadingText;
  final bool success;
  final Map<String, List<String>>? notifications;

  MainPageState copyWith({Map<String, List<String>>? notifications});

  const MainPageState(
      {
        this.exception,
        this.isLoading = false,
        this.loadingText = "",
        this.success = false,
        this.notifications
      });


}

final class SquadSelector extends MainPageState {
  const SquadSelector(
      {
        super.exception,
        super.isLoading = false,
        super.loadingText = "",
        super.success = false,
        super.notifications,
      });

  @override
  SquadSelector copyWith({Map<String, List<String>>? notifications}) {
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
        super.notifications,
      });

  @override
  AddWarrior copyWith({Map<String, List<String>>? notifications}) {
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
        super.notifications,
      });

  @override
  NewSquad copyWith({Map<String, List<String>>? notifications}) {
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
        super.notifications,
      });

  @override
  Settings copyWith({Map<String, List<String>>? notifications}) {
    return Settings(
      exception: exception,
      isLoading: isLoading,
      loadingText: loadingText,
      success: success,
      notifications: notifications,
    );
  }

}
