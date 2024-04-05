// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return _Category.fromJson(json);
}

/// @nodoc
mixin _$Category {
  String get name => throw _privateConstructorUsedError;
  String get japaneseName => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isFormal => throw _privateConstructorUsedError;
  bool? get isDeleting => throw _privateConstructorUsedError;
  bool? get isAdded => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call(
      {String name,
      String japaneseName,
      String emoji,
      bool isDefault,
      bool isFormal,
      bool? isDeleting,
      bool? isAdded});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? japaneseName = null,
    Object? emoji = null,
    Object? isDefault = null,
    Object? isFormal = null,
    Object? isDeleting = freezed,
    Object? isAdded = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      japaneseName: null == japaneseName
          ? _value.japaneseName
          : japaneseName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isFormal: null == isFormal
          ? _value.isFormal
          : isFormal // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleting: freezed == isDeleting
          ? _value.isDeleting
          : isDeleting // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAdded: freezed == isAdded
          ? _value.isAdded
          : isAdded // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
          _$CategoryImpl value, $Res Function(_$CategoryImpl) then) =
      __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String japaneseName,
      String emoji,
      bool isDefault,
      bool isFormal,
      bool? isDeleting,
      bool? isAdded});
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
      _$CategoryImpl _value, $Res Function(_$CategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? japaneseName = null,
    Object? emoji = null,
    Object? isDefault = null,
    Object? isFormal = null,
    Object? isDeleting = freezed,
    Object? isAdded = freezed,
  }) {
    return _then(_$CategoryImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      japaneseName: null == japaneseName
          ? _value.japaneseName
          : japaneseName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isFormal: null == isFormal
          ? _value.isFormal
          : isFormal // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleting: freezed == isDeleting
          ? _value.isDeleting
          : isDeleting // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAdded: freezed == isAdded
          ? _value.isAdded
          : isAdded // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryImpl with DiagnosticableTreeMixin implements _Category {
  const _$CategoryImpl(
      {required this.name,
      required this.japaneseName,
      required this.emoji,
      required this.isDefault,
      required this.isFormal,
      this.isDeleting,
      this.isAdded});

  factory _$CategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryImplFromJson(json);

  @override
  final String name;
  @override
  final String japaneseName;
  @override
  final String emoji;
  @override
  final bool isDefault;
  @override
  final bool isFormal;
  @override
  final bool? isDeleting;
  @override
  final bool? isAdded;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Category(name: $name, japaneseName: $japaneseName, emoji: $emoji, isDefault: $isDefault, isFormal: $isFormal, isDeleting: $isDeleting, isAdded: $isAdded)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Category'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('japaneseName', japaneseName))
      ..add(DiagnosticsProperty('emoji', emoji))
      ..add(DiagnosticsProperty('isDefault', isDefault))
      ..add(DiagnosticsProperty('isFormal', isFormal))
      ..add(DiagnosticsProperty('isDeleting', isDeleting))
      ..add(DiagnosticsProperty('isAdded', isAdded));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.japaneseName, japaneseName) ||
                other.japaneseName == japaneseName) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isFormal, isFormal) ||
                other.isFormal == isFormal) &&
            (identical(other.isDeleting, isDeleting) ||
                other.isDeleting == isDeleting) &&
            (identical(other.isAdded, isAdded) || other.isAdded == isAdded));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, japaneseName, emoji,
      isDefault, isFormal, isDeleting, isAdded);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryImplToJson(
      this,
    );
  }
}

abstract class _Category implements Category {
  const factory _Category(
      {required final String name,
      required final String japaneseName,
      required final String emoji,
      required final bool isDefault,
      required final bool isFormal,
      final bool? isDeleting,
      final bool? isAdded}) = _$CategoryImpl;

  factory _Category.fromJson(Map<String, dynamic> json) =
      _$CategoryImpl.fromJson;

  @override
  String get name;
  @override
  String get japaneseName;
  @override
  String get emoji;
  @override
  bool get isDefault;
  @override
  bool get isFormal;
  @override
  bool? get isDeleting;
  @override
  bool? get isAdded;
  @override
  @JsonKey(ignore: true)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
