import 'dart:ui';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location/location.dart';

final cachedTileProviderFamily =
    Provider.family<CachedTileProvider, String>((ref, urlTemplate) {
  final cacheBox = Hive.box('tileCache');
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
  ImageProvider getImage(coords, options) {
    final tileKey = '${coords.z}-${coords.x}-${coords.y}';
    final cachedTile = cacheBox.get(tileKey);

    if (cachedTile != null) {
      return MemoryImage(cachedTile);
    } else {
      final url = urlTemplate
          .replaceAll('{z}', coords.z.toString())
          .replaceAll('{x}', coords.x.toString())
          .replaceAll('{y}', coords.y.toString());
      print("Fetching tile from network: $url");

      return CachedNetworkImageProvider(
        url,
        headers: options.additionalOptions['headers'] as Map<String, String>?,
      )..resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) async {
            final byteData =
                await image.image.toByteData(format: ImageByteFormat.png);
            final buffer = byteData!.buffer.asUint8List();
            print("Saving tile to cache: $tileKey");
            await cacheBox.put(tileKey, buffer);
          }),
        );
    }
  }
}
