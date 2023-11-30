import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shipit/interfaces/receiver.dart';

class TcpReceiver implements Receiver {
  late ServerSocket socketInstance;
  late ServerSocket searchInstance;
  Socket? _selectedClient;
  static const _port = 2345;
  static const _searchPort = 23456;
  Future downloadsDir = getDownloadsDirectory();
  bool _isSearchServerActive = false;
  

  @override
  Future<void> listen() async {
    try {
      final info = NetworkInfo();
      var hostAddressStr = await info.getWifiIP();

      // Start main server
      socketInstance = await ServerSocket.bind(hostAddressStr, _port);
      debugPrint('Server started at $hostAddressStr:$_port');

      // Start search server
      searchInstance = await ServerSocket.bind(hostAddressStr, _searchPort);
      debugPrint('Search server started at $hostAddressStr:$_searchPort');

      // Listen main server
      socketInstance.listen((Socket client) async {
        if (_selectedClient == null) {
          // Show the dialog to accept or reject the client connection
          //bool acceptClient = await _getAcceptClient(context);
          bool acceptClient = true;

          if (acceptClient) {
            // Allow the client to connect
            _selectedClient = client;
            debugPrint('Client accepted from Address:${client.remoteAddress.address},Port:${client.remotePort}');
            _isSearchServerActive = true;
            searchInstance.close();
            receiveFile(_selectedClient!, downloadsDir.toString());
            //handleClientConnection(client);
          } else {
            // Reject the client
            debugPrint('Rejecting client from Address:${client.remoteAddress.address},Port:${client.remotePort}');
            client.close();
          }
        } else {
          // Reject the client if a client is already selected
          debugPrint('Rejecting client from Address:${client.remoteAddress.address},Port:${client.remotePort}');
          client.close();
        }
      });
    } catch (e) {
      debugPrint('Error starting server: $e');
    } 
  }

  @override
  disconnectConnection() {
    try {
      _selectedClient?.close();
      _selectedClient = null;
      debugPrint("Removed Clients");
    } catch (e) {
      debugPrint("Can't remove the clients");
    }
  }

  @override
  stopListening() {
    try {
      socketInstance.close();
      if (!_isSearchServerActive) {
        searchInstance.close();
      }
      debugPrint("Stopped Server");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> receiveFile(Socket socket, String filePath) async {
  //   final file = File(filePath);
  //   IOSink sink = file.openWrite();

  //   await socket.forEach((chunk) {
  //     sink.add(chunk);
  //   });

  //   await sink.flush();
  //   await sink.close();
  // }
  
  Future<void> receiveFile(Socket socket, String filePath) async {
    final file = File(filePath);

    try {
      // Read the file size from the sender
      final sizeData = await _readLine(socket);
      final fileSize = int.parse(sizeData.trim());

      // Receive and write the file data
      final fileSink = file.openWrite();
      int bytesReceived = 0;

      await for (List<int> chunk in socket) {
        fileSink.add(chunk);
        bytesReceived += chunk.length;
        debugPrint('Receiving file');

        // Break loop if all file data has been received
        if (bytesReceived >= fileSize) {
          break;
        }
      }
      await fileSink.flush();
      await fileSink.close();

      debugPrint('File received successfully');
    } catch (e) {
      debugPrint('Error receiving file: $e');
    }
  }

  Future<String> _readLine(Socket socket) async {
    final completer = Completer<String>();
    final buffer = StringBuffer();

    await for (List<int> data in socket) {
      final text = String.fromCharCodes(data);
      buffer.write(text);

      while (true) {
        final index = buffer.toString().indexOf('\n');
        if (index == -1) {
          break;
        }

        final line = buffer.toString().substring(0, index);
        buffer.clear();

        completer.complete(line);
        buffer.write(text.substring(index + 1));
      }
    }
    return completer.future;
  }

}
    