// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImagePostAdapter extends TypeAdapter<ImagePost> {
  @override
  final int typeId = 1;

  @override
  ImagePost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImagePost(
      title: fields[0] as String,
      imageUrl: fields[1] as String,
      description: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      distance: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ImagePost obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.distance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagePostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
