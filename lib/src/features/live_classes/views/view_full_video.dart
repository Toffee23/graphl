import 'package:river_player/river_player.dart';
import 'package:vmodel/src/vmodel.dart';

class ViewFullVideoPage extends StatefulWidget {
  final String videoUrl;
  const ViewFullVideoPage(this.videoUrl, {Key? key}) : super(key: key);

  @override
  State<ViewFullVideoPage> createState() => _ViewFullVideoPageState();
}

class _ViewFullVideoPageState extends State<ViewFullVideoPage>
    with WidgetsBindingObserver {
  late BetterPlayerController _chewieController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chewieController.dispose();
    super.dispose();
  }

  void initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();
    // playerController = VideoPlayerController.networkUrl(Uri.parse("https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/0112(1).mp4"));

    _chewieController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
          "https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/0112(1).mp4"),
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: VWidgetsAppBar(
      //   backgroundColor: Colors.black,
      //   appbarTitle: '',
      //   leadingIcon: VWidgetsBackButton(
      //     buttonColor: Colors.white,
      //     onTap: () {
      //       playerController.dispose();
      //       _chewieController?.dispose();
      //       Navigator.of(context).pop(true);
      //     },
      //   ),
      // ),
      body: Stack(
        children: [
          isLoading
              ? Center(
                  child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator()))
              : Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: ((MediaQuery.of(context).size.width) * 9) / 16,
                      child: BetterPlayer(controller: _chewieController))),
          Positioned(
            top: 30,
            left: 0,
            child: VWidgetsBackButton(
              buttonColor: Colors.white,
              onTap: () {
                _chewieController.dispose();
                Navigator.of(context).pop(true);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle different app lifecycle states
    switch (state) {
      case AppLifecycleState.resumed:
        _chewieController.play();
        // App is in the foreground
        //print("App Resumed");
        break;
      case AppLifecycleState.inactive:
        _chewieController.pause();
        // App is in an inactive state (transitioning between foreground and background)
        //print("App Inactive");
        break;
      case AppLifecycleState.paused:
        _chewieController.pause();
        // App is in the background
        //print("App Paused");
        break;
      case AppLifecycleState.detached:
        // App is detached (not running)
        _chewieController.dispose();

      //print("App Detached");
      case AppLifecycleState.hidden:
        // App is detached (not running)
        //print("App Detached");
        break;
    }
  }
}
