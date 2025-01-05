part of 'main_page_cubit.dart';

abstract class MainPageState {
  final Exception? exception;
  final bool isLoading;
  final String loadingText;
  const MainPageState({this.exception, this.isLoading = false, this.loadingText = ""});
}

final class SquadSelector extends MainPageState {
  const SquadSelector({super.exception, super.isLoading = false, super.loadingText = ""});
}

final class AddWarrior extends MainPageState {
  const AddWarrior({super.exception, super.isLoading = false, super.loadingText = ""});
}

final class NewSquad extends MainPageState {
  const NewSquad({super.exception, super.isLoading = false, super.loadingText = ""});
}

final class Settings extends MainPageState {
  const Settings({super.exception, super.isLoading = false, super.loadingText = ""});
}
