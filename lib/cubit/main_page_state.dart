part of 'main_page_cubit.dart';

abstract class MainPageState {
  final Exception? exception;
  const MainPageState({this.exception});
}

final class SquadSelector extends MainPageState {
  const SquadSelector({super.exception});
}

final class AddWarrior extends MainPageState {
  const AddWarrior({super.exception});
}

final class NewSquad extends MainPageState {
  const NewSquad({super.exception});
}

final class Settings extends MainPageState {
  const Settings({super.exception});
}
