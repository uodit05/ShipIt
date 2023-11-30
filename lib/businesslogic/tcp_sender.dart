import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_discovery/network_discovery.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shipit/interfaces/sender.dart';

class TcpSender implements Sender {
  late Socket socketInstance;
  late List<String> _peersInNetwork = [];
  static const _port = 2345;
  static const _searchPort = 23456;

  //View the devices in the network on a constant port
  @override
  Future<List<String>> viewPeersInNetwork() async {
    final info = NetworkInfo();
    var hostAddressStr = await info.getWifiIP();
    var subnetMaskStr = hostAddressStr!.substring(0, hostAddressStr.lastIndexOf('.'));

    try {
      final stream = NetworkDiscovery.discover(subnetMaskStr, _searchPort);
      await for (NetworkAddress addr in stream) {
        _peersInNetwork.add(addr.ip);
      }
    } catch (e) {
      debugPrint('Error discovering peers: $e');
    }
    return _peersInNetwork;
  }

  //Connect to a TCP server on a constant port
  @override
  establishConnection(receiver_ipaddress) async{
    try {
      socketInstance = await Socket.connect(receiver_ipaddress, _port);
      debugPrint('Connected to server');
    } catch (e) {
      debugPrint('Error connecting to server: $e');
    }
  }
  
  // @override
  // Future<void> sendFile(Socket socket, String filePath) async {
  //   const chunkSize = 1024; // Choose an appropriate chunk size
  //   await for (List<int> chunk in _readFileChunks(filePath, chunkSize)) {
  //     socket.add(chunk);
  //   }
  // }

  @override
  Future<void> sendFile(Socket socket, String filePath) async {
    final file = File(filePath);

    try {
      final fileSize = await file.length();

      // Send the file size to the receiver
      socket.write('$fileSize\n');

      // Open the file for reading
      final fileStream = file.openRead();

      // Send the file in chunks
      await for (List<int> chunk in fileStream) {
        socket.add(chunk);
      }

      // Close the socket after sending
      socket.close();

      debugPrint('File sent successfully');
    } catch (e) {
      debugPrint('Error sending file: $e');
    }
  }

  
  //Disconnect from the connected server
  @override
  disconnectConnection() {
    try {
      socketInstance.destroy();
      debugPrint("Connection diconnected");      
    } catch (e) {
      debugPrint("Not Connected to Server");
    }

  }
  
  @override
  stopSending(file) {
    // TODO: implement stopSending
    throw UnimplementedError();
  }

  Stream<List<int>> _readFileChunks(String filePath, int chunkSize) async* {
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();

    int bytesSent = 0;

    while (bytesSent < fileBytes.length) {
      int chunkEnd = bytesSent + chunkSize;
      if (chunkEnd > fileBytes.length) {
        chunkEnd = fileBytes.length;
      }

      yield fileBytes.sublist(bytesSent, chunkEnd);

      bytesSent = chunkEnd;
    }
  }

  // _subnetMaskStr(host) {
  //   var hostList = host!.split(".");
  //   if(hostList[0] == "192"){
  //     return hostList.sublist(0,2).join(".");
  //   }

  // String _getStartingIP(String hostAddressStr, String subnetMaskStr) {
  //   List<int> hostAddress = _parseIP(hostAddressStr);
  //   List<int> subnetMask = _parseIP(subnetMaskStr);

  //   List<int> networkAddress = _calculateNetworkAddress(hostAddress, subnetMask);

  //   return _formatIP(networkAddress);
  // }

  // List<int> _parseIP(String ipString) {
  //   List<String> parts = ipString.split('.');
  //   if (parts.length != 4) {
  //     throw FormatException('Invalid IP address: $ipString');
  //   }

  //   return parts.map((part) {
  //     int? value = int.tryParse(part);
  //     if (value == null || value < 0 || value > 255) {
  //       throw FormatException('Invalid IP address: $ipString');
  //     }
  //     return value;
  //   }).toList();
  // }

  // List<int> _calculateNetworkAddress(List<int> hostAddress, List<int> subnetMask) {
  //   return List.generate(4, (i) => hostAddress[i] & subnetMask[i]);
  // }

  // List<int> _calculateBroadcastAddress(List<int> networkAddress, List<int> subnetMask) {
  //   List<int> complementedSubnetMask = subnetMask.map((value) => 255 - value).toList();
  //   return List.generate(4, (i) => networkAddress[i] | complementedSubnetMask[i]);
  // }

  // String _formatIP(List<int> ipAddress) {
  //   return ipAddress.sublist(0, 3).join('.');
  // } 
}