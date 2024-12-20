import 'dart:ui';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location/location.dart';

final themeProvider = StateProvider<Brightness>((ref) => Brightness.light);

final cachedTileProviderFamily =
    Provider.family<CachedTileProvider, String>((ref, urlTemplate) {
  final theme = ref.watch(themeProvider);
  final cacheBox =
      Hive.box(theme == Brightness.dark ? 'darkTileCache' : 'lightTileCache');
  final locationData = ref.watch(locationNotifierProvider);
  return CachedTileProvider(
      urlTemplate: urlTemplate, cacheBox: cacheBox, locationData: locationData);
});

class CachedTileProvider extends TileProvider {
  final String urlTemplate;
  final Box cacheBox;
  final LocationData? locationData;

  CachedTileProvider(
      {required this.urlTemplate, required this.cacheBox, this.locationData});

  @override
  ImageProvider getImage(coordinates, options) {
    final tileKey = '${coordinates.z}-${coordinates.x}-${coordinates.y}';
    final cachedTile = cacheBox.get(tileKey);

    if (cachedTile != null) {
      return MemoryImage(cachedTile);
    } else {
      final url = urlTemplate
          .replaceAll('{z}', coordinates.z.toString())
          .replaceAll('{x}', coordinates.x.toString())
          .replaceAll('{y}', coordinates.y.toString());

      return CachedNetworkImageProvider(
        url,
        headers: options.additionalOptions['headers'] as Map<String, String>?,
      )..resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) async {
            final byteData =
                await image.image.toByteData(format: ImageByteFormat.png);
            final buffer = byteData!.buffer.asUint8List();
            await cacheBox.put(tileKey, buffer);
          }),
        );
    }
  }
}
