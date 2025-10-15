// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      firstName: fields[0] as String,
      lastName: fields[1] as String,
      gender: fields[2] as String,
      phoneNumber: fields[3] as String,
      email: fields[4] as String,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
      address: fields[7] as String?,
      selectedCountry: fields[8] as String,
      createdAt: fields[9] as DateTime,
      isLoggedIn: fields[10] as bool,
      profileImagePath: fields[11] as String?,
      pinCode: fields[12] as String?,
      city: fields[13] as String?,
      district: fields[14] as String?,
      state: fields[15] as String?,
      country: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.selectedCountry)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isLoggedIn)
      ..writeByte(11)
      ..write(obj.profileImagePath)
      ..writeByte(12)
      ..write(obj.pinCode)
      ..writeByte(13)
      ..write(obj.city)
      ..writeByte(14)
      ..write(obj.district)
      ..writeByte(15)
      ..write(obj.state)
      ..writeByte(16)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
