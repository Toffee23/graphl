import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/live_class_type.dart';
import '../repository/live_classes.dart';


final liveCategoryProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

final upComingProvider = AsyncNotifierProvider.autoDispose.family<UpcomingLiveClassNotifier,List<LiveClassesInput>,String?>(
UpcomingLiveClassNotifier.new);


class UpcomingLiveClassNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<LiveClassesInput>, String?> {
  final repo = LiveClassRepository.instance;
  int _allLiveClassesTotalNumber = 0;
  int _pageCount = 20;
  int _currentPage = 1;

  @override
  Future<List<LiveClassesInput>> build(String? arg) async {
    state = const AsyncLoading();
    _currentPage = 1;
    await getUpcomingLives(liveType:arg??'LIVE_CLASS', search:'', category:'', duration:'', upcoming:true, pageCount:_pageCount, pageNumber:_currentPage);
    return state.value!;
  }

  Future getUpcomingLives({required String? liveType, required String search, required String category, required String duration, required bool upcoming, required int pageCount, required int pageNumber})async{

    final response = await repo.getUpcomingLives(liveType:liveType, search:'',category:'',duration:'',upcoming:upcoming,pageCount:_pageCount,pageNumber:pageNumber);

    return response.fold((left) {
      state = AsyncData([]);
      return [];
    },
            (right) async{
              _allLiveClassesTotalNumber = right['allLiveClassesTotalNumber'];
              final lclass = (right['allLiveClasses'] as List);

              if (lclass.isNotEmpty) {
                final currentState = state.valueOrNull ?? [];
                var newState;
                try {
                   newState = lclass.map((e) =>
                      LiveClassesInput.fromJson(e)).toList();
                }catch(e){}

                if (pageNumber == 1) {
              state = AsyncData(newState);
              return newState;
            } else {
              if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
                state = AsyncData([]);
                return [];
              }

              state = AsyncData([...currentState, ...newState]);
            }
            _currentPage=pageNumber;
          }
              state = AsyncData([]);
          return [];
        });
  }

  Future<void> fetchMoreData(String? arg) async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _allLiveClassesTotalNumber;

    if (canLoadMore) {
      await getUpcomingLives(liveType:arg??'LIVE_CLASS', search:'',category:'',duration:'',upcoming:true,pageCount:_pageCount,pageNumber:_currentPage);
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _allLiveClassesTotalNumber;
  }

}



final myLiveClassProvider = AsyncNotifierProvider.autoDispose<MYLiveClassNotifier,List<LiveClassesInput>>(
    MYLiveClassNotifier.new);


class MYLiveClassNotifier
    extends AutoDisposeAsyncNotifier<List<LiveClassesInput>> {
  final repo = LiveClassRepository.instance;
  int _myLiveClassesTotalNumber = 0;
  int _pageCount = 20;
  int _currentPage = 1;

  @override
  Future<List<LiveClassesInput>> build() async {
    state = const AsyncLoading();
    _currentPage = 1;
    await myLiveClasses(search:'',category:'',duration:'',upcoming:true,pageCount:_pageCount,pageNumber:_currentPage);
    return state.value!;
  }

  Future myLiveClasses({required String search, required String category, required String duration, required bool upcoming, required int pageCount, required int pageNumber})async{

    final response = await repo.myLiveClasses(search:'',category:'',duration:'',upcoming:upcoming,pageCount:_pageCount,pageNumber:pageNumber);

    return response.fold((left) {
      state = AsyncData([]);
      return [];
    },
            (right) async{
              _myLiveClassesTotalNumber = right['myLiveClassesTotalNumber'];
          final lclass = (right['myLiveClasses'] as List);

          if (lclass.isNotEmpty) {
            final currentState = state.valueOrNull ?? [];
            var newState;
            try {
              newState = lclass.map((e) =>
                  LiveClassesInput.fromJson(e)).toList();
            }catch(e){}

            if (pageNumber == 1) {
              state = AsyncData(newState);
              return newState;
            } else {
              if (currentState.isNotEmpty && newState.any((element) => currentState.last.id == element.id)) {
                state = AsyncData([]);
                return [];
              }

              state = AsyncData([...currentState, ...newState]);
            }
            _currentPage=pageNumber;
          }
          state = AsyncData([]);
          return [];
        });
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _myLiveClassesTotalNumber;

    if (canLoadMore) {
      await myLiveClasses(search:'',category:'',duration:'',upcoming:true,pageCount:_pageCount,pageNumber:_currentPage);
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _myLiveClassesTotalNumber;
  }

}
