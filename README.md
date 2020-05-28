#### iOS - Too many open files

Hello,

I am developping a video conference application using Flutter and WebRTC.

Recently, I have been facing a problem regarding `RTCPeerConnection`. It turns out `RTCPeerConnection` uses file descriptors (aka FD) as soon as a negotiation is done, sometimes about 10 FDs, but it can also be up to 50 of them.

Therefore, once a peer connection is successfully negotiated, it will hold onto a certain amount of file descriptors, and when this `RTCPeerConnection` is closed, it will release them. 

The problem is : the application must handle conferences calls with 5-10 people. Currently, as for my application, each peer connection takes about 50 FDs and my device has only 256 available, so it will run out of them really fast. Eventually the following error will be thrown: `Runner[2517:1106461] dnssd_clientstub deliver_request: socketpair failed 24 (Too many open files)`, causing the application to crash or freeze. 

Am I using the library correctly ? Or is just WebRTC / my device that is unable to support so many `RTCPeerConnection` ?

#### Way to reproduce

As an example, I've made another application, as a test, printing and updating the amount of used file descriptors every seconds. If you click the `+` button, a new `RTCPeerConnection` will be created and will establish a negotiation with an other
* `git clone git@github.com:QuentinSanchez98/flutter_webrtc_test.git`
* Edit `rtcConfiguration` at `lib/main.dart l:52` with you configuration
* `flutter run`
* Click on `+` to add more RTCPeerConnection
* See the amount of file descriptor increase