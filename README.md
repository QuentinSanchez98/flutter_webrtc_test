### iOS - Too many open files

Hello,

I am developping a video conference application using Flutter and WebRTC.

Recently, I have been facing a problem regarding `RTCPeerConnection`. It turns out `RTCPeerConnection` uses file descriptors (aka FD) as soon as a negotiation is done, sometimes about 10 FDs, but it can also be up to 50 of them.

Therefore, once a peer connection is successfully negotiated, it will hold onto a certain amount of file descriptors, and when this `RTCPeerConnection` is closed, it will release them. 

The problem is : the application must handle conferences calls with 5-10 people. Currently, as for my application, each peer connection takes about 50 FDs and my device has only 256 available, so it will run out of them really fast. Eventually the following error will be thrown: `Runner[2517:1106461] dnssd_clientstub deliver_request: socketpair failed 24 (Too many open files)`, causing the application to crash or freeze. 

Am I using the library correctly ? Or is just WebRTC / my device that is unable to support so many `RTCPeerConnection` ?

#### Reproduce

As an example, I've made another application, as a test, printing and updating the amount of used file descriptors every seconds. If you click the `+` button, a new `RTCPeerConnection` will be created and will establish a negotiation with an other
* `git clone git@github.com:QuentinSanchez98/flutter_webrtc_test.git`
* Edit `rtcConfiguration` at `lib/main.dart l:52` with you configuration
* `flutter packages get`
* `flutter run`
* Click on `+` to add more RTCPeerConnection
* See the amount of file descriptor increase

#### Environment

> flutter doctor -v

```
[✓] Flutter (Channel beta, 1.18.0-11.1.pre, on Mac OS X 10.15.5 19F96, locale fr-FR)
    • Flutter version 1.18.0-11.1.pre at /Users/quentin/Library/Flutter
    • Framework revision 2738a1148b (2 weeks ago), 2020-05-13 15:24:36 -0700
    • Engine revision ef9215ceb2
    • Dart version 2.9.0 (build 2.9.0-8.2.beta)

✓] Xcode - develop for iOS and macOS (Xcode 11.5)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Xcode 11.5, Build version 11E608c
    • CocoaPods version 1.8.4

[✓] IntelliJ IDEA Ultimate Edition (version 2019.3.4)
    • IntelliJ at /Applications/IntelliJ IDEA.app
    • Flutter plugin version 44.0.3
    • Dart plugin version 193.6911.31

[✓] Connected device (1 available)
    • Quentin S • 00008030-000C193426E8802E • ios • iOS 13.5
```
