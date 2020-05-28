import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/rtc_peerconnection.dart';
import 'package:flutter_webrtc/webrtc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter WebRTC Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


final Map<String, dynamic> loopbackConstraints = {
  "mandatory": {},
  "optional": [
    {"DtlsSrtpKeyAgreement": true},
  ],
};

final Map<String, dynamic> defaultSdpConstraints = {
  "mandatory": {
    "OfferToReceiveAudio": true,
    "OfferToReceiveVideo": true,
  },
  "optional": [],
};

final Map<String, dynamic> rtcConfiguration = {
  'iceServers': [
    {
      'credential': 'XXX',
      'urls': ['XXX'],
      'username': 'XXX'
    }
  ]
};

class _MyHomePageState extends State<MyHomePage> {
  final FileDescriptorHandler fileDescriptorHandler = FileDescriptorHandler();

  String _number = '';
  RTCPeerConnection _peer;
  List<RTCPeerConnection> _remotes = [];

  @override
  void initState() {
    super.initState();

    fileDescriptorHandler.state.listen((String data) {
      setState(() { _number = data; });
    });

    createPeerConnection(rtcConfiguration, loopbackConstraints)
        .then((peer) => _peer = peer);
  }

  _addPeer() async {
    RTCPeerConnection remote = await createPeerConnection(rtcConfiguration, loopbackConstraints);

    final offer = await _peer.createOffer(defaultSdpConstraints);
    await _peer.setLocalDescription(offer);
    await remote.setRemoteDescription(offer);

    final answer = await remote.createAnswer(defaultSdpConstraints);
    await remote.setLocalDescription(answer);
    await _peer.setRemoteDescription(answer);

    setState(() { _remotes = _remotes + [remote]; });
  }

  _removePeer(int index) {
    _remotes[index].close();
    _remotes.removeAt(index);
    setState(() { _remotes = _remotes; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Text('$_number open file descriptors', style: TextStyle(fontSize: 20)),

              ..._remotes.asMap().keys.map((index) =>
                Row(
                  children: [
                    Text('Remote $index', style: TextStyle(fontSize: 15)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () { _removePeer(index); },
                    )
                  ]
                )
              )
            ]
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _addPeer(); },
        tooltip: 'Add a peer',
        child: Icon(Icons.add),
      ),
    );
  }
}

class FileDescriptorHandler {
  static const stream = const EventChannel('com.quentinsanchez.test/events');

  StreamController<String> _stateController = StreamController();
  Stream<String> get state => _stateController.stream;
  Sink<String> get stateSink => _stateController.sink;

  FileDescriptorHandler () {
    stream.receiveBroadcastStream().listen((d) {
      _onRedirected(d);
    });
  }

  _onRedirected(String uri) {
    stateSink.add(uri);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}