import 'package:flutter/material.dart';
import 'package:shipit/businesslogic/tcp_receiver.dart';
import 'businesslogic/tcp_sender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TcpSender ts = TcpSender();
  TcpReceiver tr = TcpReceiver();
  late List<String> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                onPressed: () async{
                  //First button
                  tr.listen();
                  // final info = NetworkInfo();
                  // var hostAddressStr = await info.getWifiIP();
                  // debugPrint(hostAddressStr);
                },
                child: const Icon(Icons.add),
                ),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                  onPressed: () async{
                    //Second button
                    tr.disconnectConnection();
                    tr.stopListening();
                  },
                  child: const Icon(Icons.remove),
                ),               
              ],
            ),
            const SizedBox(
                  width: 15,
                ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () async{
                    //First button
                    list = await ts.viewPeersInNetwork();
                    debugPrint("List of receiversIp:${list.toString()}");
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                  onPressed: () async{
                    //Second button
                    // ts.disconnectConnection();
                    ts.establishConnection(list[0]);
                  },
                  child: const Icon(Icons.circle_outlined),
                ),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                  onPressed: () async{
                    //Third button
                    ts.disconnectConnection();
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ],
        )
      )
    );
  }
}