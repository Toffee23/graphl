import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/places_model.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';

import '../network/urls.dart';

final placeSearchQueryProvider = StateProvider<String?>((ref) {
  return null;
});

final suggestedPlacesProvider = AsyncNotifierProvider.autoDispose<SuggestedPlacesNotifier, List<AutocompletePrediction>>(SuggestedPlacesNotifier.new);

class SuggestedPlacesNotifier extends AutoDisposeAsyncNotifier<List<AutocompletePrediction>> {
  @override
  FutureOr<List<AutocompletePrediction>> build() async {
    final query = ref.watch(placeSearchQueryProvider);
    if (query.isEmptyOrNull) return [];
    return await _getLocationResults(query!) ?? [];
  }

  Future<List<AutocompletePrediction>?> _getLocationResults(String query) async {
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
      "input": query,
      // "input": "-33.873138,151.211276",
      "key": VUrls.mapsApiKey,
    });
    String? response = await getPlaces(uri);

    if (response == null) {
      return null;
    }
    PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);

    return result.predictions;
  }

  Future<dynamic> getPlacesDetail(String placeId) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=${VUrls.mapsApiKey}');

    final timeout = const Duration(milliseconds: 3000);

    try {
      final response = await http.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          final location = data['result'];
          return location;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPlaces(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {}
    return null;
  }
}
