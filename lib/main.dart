import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  bool bloothstatustype = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen(true);
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
/////////
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white),
            ),
            ElevatedButton(
              child: const Text('TURN ON'),
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOn()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
///////
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///

class FindDevicesScreen extends StatefulWidget {
  bool bloothstatustype;
  FindDevicesScreen(this.bloothstatustype);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  Stream generateNumbers = (() async* {
    List data = [];
    await Future<void>.delayed(Duration(seconds: 2));

    for (int i = 1; i <= 10; i++) {
      await Future<void>.delayed(Duration(seconds: 1));
      data.add(i);
      yield data;
    }
  })();
  Startscanning_devices() {
    FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    var subscription = FlutterBluePlus.instance.scanResults.listen((results) {
      // do something with scan results
      print("results : $results");
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

// Stop scanning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            child: const Text('TURN OFF'),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            onPressed: Platform.isAndroid
                ? () => FlutterBluePlus.instance.turnOff()
                : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Startscanning_devices(),
        //  FlutterBluePlus.instance
        //     .startScan(timeout: const Duration(seconds: 0)),
        child: SingleChildScrollView(
          child: Container(
            // height: MediaQuery.of(context).size.height * 1,
            // width: MediaQuery.of(context).size.width * 1,
            // color: Colors.red,
            child: Column(
              children: <Widget>[
                if (widget.bloothstatustype)
                  Container(
                    // color: Colors.red,
                    child: StreamBuilder(
                      stream: generateNumbers,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((d) => Container(
                                  margin: EdgeInsets.all(5),
                                  color: Color.fromARGB(255, 207, 207, 207),
                                  child: InkWell(
                                    onTap: () {
                                      d.device.connect();
                                    },
                                    child: ListTile(
                                      title: Text(d.toString()),
                                      //strailing: Text("data"),
                                      // subtitle: Text(d.device),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                // StreamBuilder<int>(
                //   stream: generateNumbers,
                //   builder: (
                //     BuildContext context,
                //     AsyncSnapshot<int> snapshot,
                //   ) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator();
                //     } else if (snapshot.connectionState ==
                //             ConnectionState.active ||
                //         snapshot.connectionState == ConnectionState.done) {
                //       if (snapshot.hasError) {
                //         return const Text('Error');
                //       } else if (snapshot.hasData) {
                //         return Text(snapshot.data.toString(),
                //             style: const TextStyle(
                //                 color: Colors.red, fontSize: 40));
                //       } else {
                //         return const Text('Empty data');
                //       }
                //     } else {
                //       return Text('State: ${snapshot.connectionState}');
                //     }
                //   },
                // ),
                ///
                ///
                ///
                ///
                ///
                ///
                ///
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 2)).asyncMap(
                      (_) => FlutterBluePlus.instance.connectedDevices),
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name),
                              subtitle: Text(d.id.toString()),
                              trailing: StreamBuilder<BluetoothDeviceState>(
                                stream: d.state,
                                initialData: BluetoothDeviceState.disconnected,
                                builder: (c, snapshot) {
                                  if (snapshot.data ==
                                      BluetoothDeviceState.connected) {
                                    return ElevatedButton(
                                      child: const Text('OPEN'),
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  DeviceScreen(device: d))),
                                    );
                                  }
                                  return Text(snapshot.data.toString());
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Container(
                  // color: Colors.red,
                  child: StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map((d) => Container(
                                margin: EdgeInsets.all(5),
                                color: Color.fromARGB(255, 207, 207, 207),
                                child: InkWell(
                                  onTap: () {
                                    d.device.connect();
                                  },
                                  child: ListTile(
                                    title: Text(d.device.name.toString()),
                                    subtitle: Text(d.device.id.toString()),
                                    //strailing: Text("data"),
                                    // subtitle: Text(d.device),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                // StreamBuilder<List<ScanResult>>(
                //   stream: FlutterBluePlus.instance.,
                //   initialData: [],
                //   builder: (c, snapshot) => Column(
                //     children: snapshot.data!
                //         .map((r) => Container(
                //               child: Text(r.device.name),
                //             ))
                //         .toList(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  // List<Widget> _buildServiceTiles(List<BluetoothService>? services) {
  //   return ListView();
  // }

  // List<Widget> _buildServiceTiles(List<BluetoothService>? services) {
  //   return services
  //       .map(
  //         (s) => ServiceTile(
  //           service: s,
  //           characteristicTiles: s.characteristics
  //               .map(
  //                 (c) => CharacteristicTile(
  //                   characteristic: c,
  //                   onReadPressed: () => c.read(),
  //                   onWritePressed: () async {
  //                     await c.write(_getRandomBytes(), withoutResponse: true);
  //                     await c.read();
  //                   },
  //                   onNotificationPressed: () async {
  //                     await c.setNotifyValue(!c.isNotifying);
  //                     await c.read();
  //                   },
  //                   descriptorTiles: c.descriptors
  //                       .map(
  //                         (d) => DescriptorTile(
  //                           descriptor: d,
  //                           onReadPressed: () => d.read(),
  //                           onWritePressed: () => d.write(_getRandomBytes()),
  //                         ),
  //                       )
  //                       .toList(),
  //                 ),
  //               )
  //               .toList(),
  //         ),
  //       )
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data == BluetoothDeviceState.connected
                        ? const Icon(Icons.bluetooth_connected)
                        : const Icon(Icons.bluetooth_disabled),
                    snapshot.data == BluetoothDeviceState.connected
                        ? StreamBuilder<int>(
                            stream: rssiStream(),
                            builder: (context, snapshot) {
                              return Text(
                                  snapshot.hasData ? '${snapshot.data}dBm' : '',
                                  style: Theme.of(context).textTheme.caption);
                            })
                        : Text('', style: Theme.of(context).textTheme.caption),
                  ],
                ),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                print("object : ${device.name}");
                return Column(
                  children: [Text(device.name)],
                  // children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
