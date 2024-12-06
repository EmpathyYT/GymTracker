import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'main_page_state.dart';

class MainPageCubit extends Cubit<MainPageState> {
  MainPageCubit() : super(const SquadSelector());

  void changePage(int index) {
    switch (index) {
      case 0:
        emit(const SquadSelector());
        break;
      case 1:
        emit(const AddWarrior());
        break;
      case 2:
        emit(const NewSquad());
        break;
      case 3:
        emit(const Settings());
        break;
      default:
        emit(const SquadSelector());
    }
  }
}
