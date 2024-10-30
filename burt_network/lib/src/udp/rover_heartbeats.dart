
import "package:meta/meta.dart";
import "package:burt_network/generated.dart";

import "burt_protocol.dart";
import "socket_info.dart";

/// A mixin that automatically handles rover-side heartbeats.
mixin RoverHeartbeats on BurtUdpProtocol {
  /// Whether this socket received a heartbeat since the last call to [checkHeartbeats].
  bool didReceivedHeartbeat = false;

  @override
  bool get isConnected => destination != null;

  @override
  Duration get heartbeatInterval => const Duration(seconds: 2);

  /// Handles incoming heartbeats.
  /// 
  /// 1. If the heartbeat was meant for another device, log it and ignore it.
  /// 2. If it came from our dashboard, respond to it with [sendHeartbeatResponse].
  /// 3. If it came from another dashboard, log it and ignore it.
  /// 4. If we are not connected to any dashboard, call [onConnect] and respond to it.
  @override
  void onHeartbeat(Connect heartbeat, SocketInfo source) {
    if (heartbeat.receiver != device) {  // (1)
      logger.warning("Received a misaddressed heartbeat for ${heartbeat.receiver}");
    } else if (isConnected) {
      if (destination == source) {  // (2)
        sendHeartbeatResponse();
      } else {  // (3)
        logger.warning("Port $port is connected to $destination but received a heartbeat from $source");
      }
    } else {  // (4)
      onConnect(source);
      sendHeartbeatResponse();
    }
  }

  /// Checks if a heartbeat has been received. If not, calls [onDisconnect].
  /// 
  /// This function runs every [heartbeatInterval] seconds via [heartbeatTimer].
  @override
  Future<void> checkHeartbeats() async {
    if (didReceivedHeartbeat) {
      didReceivedHeartbeat = false;
    } else if (isConnected) {
      logger.warning("Heartbeat not received. Assuming the dashboard has disconnected");
      onDisconnect();
    }
  }

  /// Responds to an incoming heartbeat.
  void sendHeartbeatResponse() {
    final response = Connect(sender: device, receiver: Device.DASHBOARD);
    sendMessage(response);
    didReceivedHeartbeat = true;
  }
  
  /// Sets [destination] to the incoming [source].
  /// 
  /// Override this function to run custom code when the dashboard connects, but be sure to call
  /// `super.onConnect(source)` as well.
  @mustCallSuper
  void onConnect(SocketInfo source) { 
    destination = source;
    logger.info("Port $port is connected to $destination");
  }

  /// Sends a [Disconnect] message to the dashboard and sets [destination] to `null`.
  /// 
  /// Override this function to run custom code when the dashboard disconnects, but be sure to call
  /// `super.onDisconnect()` as well. For example, put code to stop the rover from driving in here
  /// to prevent it from crashing when connection is lost.
  @mustCallSuper
  void onDisconnect() { 
    logger.info("Port $port is disconnected from $destination");
    sendMessage(Disconnect(sender: device));
    destination = null; 
  }
}
