import 'dart:io';

abstract class Sender {
  //generateId() {}
  viewPeersInNetwork() {}
  establishConnection(receiver_ipaddress) {}
  Future<void> sendFile(Socket socket, String filePath) async {}
  /*send(Text) {}*/
  disconnectConnection() {}
  stopSending(file) {}
}