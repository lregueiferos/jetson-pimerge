import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:collection/collection.dart";

import "package:burt_network/burt_network.dart";
import "package:subsystems/subsystems.dart";

import "service.dart";

/// Maps command names to [Device]s. 
final nameToDevice = <String, Device>{
  ArmCommand().messageName: Device.ARM,
  GripperCommand().messageName: Device.GRIPPER,
  DriveCommand().messageName: Device.DRIVE,
  ScienceCommand().messageName: Device.SCIENCE,
};

/// A service to send and receive messages to the firmware over serial.
class SerialService extends MessageService {
  /// Gets all the names of all the ports.
  static Future<List<String>> getPortNames() async {
    final allPorts = DelegateSerialPort.allPorts;
    if (!Platform.isLinux) return allPorts;
    final imuCommand = await Process.run("realpath", ["/dev/rover-imu"]);
    final imuPort = imuCommand.stdout.trim();
    logger.trace("IMU is on: $imuPort");
    final gpsCommand = await Process.run("realpath", ["/dev/rover-gps"]);
    final gpsPort = gpsCommand.stdout.trim();
	const piPort = "/dev/ttyAMA0";
    logger.trace("GPS is on: $gpsPort");
	logger.trace("All ports: $allPorts");
    final forbiddenPorts = {imuPort, gpsPort, piPort};
	return [
      for (final port in allPorts)
	if (!forbiddenPorts.contains(port))
          port,
    ];
  }
  
  /// Gets all firmware devices attached to the device, ignoring the GPS and IMU ports.
  static Future<List<BurtFirmwareSerial>> getFirmware() async => [
    for (final port in await getPortNames())
      BurtFirmwareSerial(port: port, logger: logger),
  ];

  final List<StreamSubscription<Uint8List>> _subscriptions = [];
  
  /// All the connected devices.
  List<BurtFirmwareSerial> devices = [];

  @override
  Future<bool> init() async {
    devices = await getFirmware();    
    for (final device in devices) {
	logger.debug("Initializing device: ${device.port}");
      await device.init();
      if (!device.isReady) continue;
      final subscription = device.stream?.listen((data) => _onMessage(data, device));
      if (subscription == null) continue;
      _subscriptions.add(subscription);
    }
    // This service is a backup service for [CanService]
    // If something went wrong here, the messages will be sent over CAN instead.
    // In addition, 1 or 2 subsystems may be connected at a time, not all 3.
    // Therefore, it is not as useful to return false here on an error condition.
    return true;  
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    for (final device in devices) {
      await device.dispose();
    }
  }

  void _onMessage(Uint8List data, BurtFirmwareSerial serial) {
    final name = switch (serial.device) {
      Device.ARM => ArmData().messageName,
      Device.DRIVE => DriveData().messageName,
      Device.GRIPPER => GripperData().messageName,
      Device.SCIENCE => ScienceData().messageName,
      _ => null,
    };
    if (name == null) {
      logger.warning("Unrecognized Serial device", body: "Port: ${serial.port}, name: ${serial.device}");
      return;
    }
    collection.server.sendWrapper(WrappedMessage(data: data, name: name));
  }

  @override
  bool sendWrapper(WrappedMessage wrapper) {
    final device = nameToDevice[wrapper.name];
    if (device == null) return false;
    final serial = devices.firstWhereOrNull((s) => s.device == device);
    if (serial == null) return false;
    serial.sendBytes(wrapper.data);
    return true;
  }
}
