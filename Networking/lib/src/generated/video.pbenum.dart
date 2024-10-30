//
//  Generated code. Do not modify.
//  source: video.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CameraStatus extends $pb.ProtobufEnum {
  static const CameraStatus CAMERA_STATUS_UNDEFINED = CameraStatus._(0, _omitEnumNames ? '' : 'CAMERA_STATUS_UNDEFINED');
  static const CameraStatus CAMERA_DISCONNECTED = CameraStatus._(1, _omitEnumNames ? '' : 'CAMERA_DISCONNECTED');
  static const CameraStatus CAMERA_ENABLED = CameraStatus._(2, _omitEnumNames ? '' : 'CAMERA_ENABLED');
  static const CameraStatus CAMERA_DISABLED = CameraStatus._(3, _omitEnumNames ? '' : 'CAMERA_DISABLED');
  static const CameraStatus CAMERA_NOT_RESPONDING = CameraStatus._(4, _omitEnumNames ? '' : 'CAMERA_NOT_RESPONDING');
  static const CameraStatus CAMERA_LOADING = CameraStatus._(5, _omitEnumNames ? '' : 'CAMERA_LOADING');
  static const CameraStatus FRAME_TOO_LARGE = CameraStatus._(6, _omitEnumNames ? '' : 'FRAME_TOO_LARGE');
  static const CameraStatus CAMERA_HAS_NO_NAME = CameraStatus._(7, _omitEnumNames ? '' : 'CAMERA_HAS_NO_NAME');

  static const $core.List<CameraStatus> values = <CameraStatus> [
    CAMERA_STATUS_UNDEFINED,
    CAMERA_DISCONNECTED,
    CAMERA_ENABLED,
    CAMERA_DISABLED,
    CAMERA_NOT_RESPONDING,
    CAMERA_LOADING,
    FRAME_TOO_LARGE,
    CAMERA_HAS_NO_NAME,
  ];

  static final $core.Map<$core.int, CameraStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CameraStatus? valueOf($core.int value) => _byValue[value];

  const CameraStatus._($core.int v, $core.String n) : super(v, n);
}

class CameraName extends $pb.ProtobufEnum {
  static const CameraName CAMERA_NAME_UNDEFINED = CameraName._(0, _omitEnumNames ? '' : 'CAMERA_NAME_UNDEFINED');
  static const CameraName ROVER_FRONT = CameraName._(1, _omitEnumNames ? '' : 'ROVER_FRONT');
  static const CameraName ROVER_REAR = CameraName._(2, _omitEnumNames ? '' : 'ROVER_REAR');
  static const CameraName AUTONOMY_DEPTH = CameraName._(3, _omitEnumNames ? '' : 'AUTONOMY_DEPTH');
  static const CameraName SUBSYSTEM1 = CameraName._(4, _omitEnumNames ? '' : 'SUBSYSTEM1');
  static const CameraName SUBSYSTEM2 = CameraName._(5, _omitEnumNames ? '' : 'SUBSYSTEM2');
  static const CameraName SUBSYSTEM3 = CameraName._(6, _omitEnumNames ? '' : 'SUBSYSTEM3');

  static const $core.List<CameraName> values = <CameraName> [
    CAMERA_NAME_UNDEFINED,
    ROVER_FRONT,
    ROVER_REAR,
    AUTONOMY_DEPTH,
    SUBSYSTEM1,
    SUBSYSTEM2,
    SUBSYSTEM3,
  ];

  static final $core.Map<$core.int, CameraName> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CameraName? valueOf($core.int value) => _byValue[value];

  const CameraName._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
