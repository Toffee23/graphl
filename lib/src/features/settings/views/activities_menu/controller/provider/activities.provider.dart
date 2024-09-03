import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/controller/repo/activities.repo.dart';

// Provider for the ActivityRepository, which is responsible for fetching activities data.
final acivitiesProvider = Provider<ActivityRepository>((ref) => ActivitiesRepository());

// AsyncNotifierProvider to manage the state and logic for asynchronously loading activities data.
final getActivities = AsyncNotifierProvider.autoDispose<ActivitiesAsyncNotifierProvider, List<dynamic>>(ActivitiesAsyncNotifierProvider.new);

// AsyncNotifier class that handles the fetching and management of activities data.
class ActivitiesAsyncNotifierProvider extends AutoDisposeAsyncNotifier<List<dynamic>> {  
  // State variables to manage pagination and data.
  int _pageCount = 30;  // Number of items to fetch per page.
  int _currentPage = 10;  // Current page number being fetched.
  int _totalItems = 0;  // Total number of items available on the server.

  // This method is called when the provider is first initialized.
  // It fetches the first page of data.
  @override
  Future<List<dynamic>> build() async {
    _currentPage = 1;  // Reset to the first page.
    return await fetchData(pageNumber: _currentPage);  // Fetch data for the first page.
  }

  // Method to fetch data from the repository with optional parameters for search and pagination.
  // If 'addToState' is true, the fetched data is added to the existing state.
  Future<List<dynamic>> fetchData({required int pageNumber, String? search, bool addToState = true}) async {
    // Fetch activities data from the repository.
    final res = await ref.read(acivitiesProvider).getActivities(pageNumber: pageNumber, pageCount: _pageCount);

    // Handle the response.
    return res.fold((left) {
      // If an error occurs (left side of Either), log the error message.
      print('in AsyncBuild left is .............. ${left.message}');
      return [];  // Return an empty list on error.
    }, (right) {
      // If the request is successful (right side of Either), extract the data.
      
      // _totalItems = right['notificationsTotalNumber'] ?? 0; //TODO: Uncomment when the total number of items is available.
      final List newValue = right['userActivities'];  // Extract the activities list.

      logger.i("activities list: ${newValue}");  // Log the retrieved activities list.

      // Get the current state, or an empty list if the state is null.
      final currentState = state.valueOrNull ?? [];

      if (pageNumber > 1) {
        // If it's not the first page, append the new data to the existing state.
        state = AsyncData([...currentState, ...newValue]);
        return [];  // Return an empty list since the state is updated internally.
      } else {
        // For the first page, return the new data as the initial state.
        return newValue;
      }
    });
  }

  // Method to handle the fetching of additional data (pagination).
  Future<void> fetchMoreHandler() async {
    // Get the current number of items in the state.
    final currentItemsLength = state.valueOrNull?.length;

    // Determine if more items can be loaded based on the total items count.
    final canLoadMore = (currentItemsLength ?? 0) < _totalItems;

    if (canLoadMore) {
      // If more items can be loaded, fetch the next page of data.
      await fetchData(pageNumber: _currentPage + 1);
    }
  }

  // Method to check if more data can be loaded, based on the current state.
  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _totalItems;
  }
}
