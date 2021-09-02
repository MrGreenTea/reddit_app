import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'client.dart';

void launchURL(String url) async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

final pageControllerProvider =
    Provider.family<PagingController<String?, Link>, String>((ref, sub) {
  final client = ref.watch(restClientProvider);
  final controller = PagingController<String?, Link>(
      firstPageKey: null, invisibleItemsThreshold: 25);
  controller.addPageRequestListener((after) async {
    try {
      final posts = await client.getHot(sub, after);
      if (posts.data.after == null) {
        controller.appendLastPage(posts.data.children);
      } else {
        controller.appendPage(posts.data.children, posts.data.after);
      }
    } catch (error) {
      controller.error = error;
    }
  });
  ref.onDispose(() => controller.dispose());
  return controller;
});

final restClientProvider = Provider<RestClient>((_) {
  final options = BaseOptions(
    headers: {
      HttpHeaders.userAgentHeader:
          "android:dev.bulik.redditapp:v0.0.1 (by /u/mrgreentea)"
    },
    queryParameters: {"raw_json": 1},
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  final dio = Dio(options);
  final client = RestClient(dio);
  return client;
});

final beamerDelegateProvider = Provider<BeamerDelegate>((_) {
  final routerDelegate = BeamerDelegate(
    locationBuilder: SimpleLocationBuilder(
      routes: {
        '/': (context, state) => MyHomePage(),
        '/r/:sub': (context, state) {
          // Take the parameter of interest from BeamState
          final sub = state.pathParameters['sub']!;
          // Return a Widget or wrap it in a BeamPage for more flexibility
          return BeamPage(
            key: ValueKey('book-$sub'),
            title: 'A Book #$sub',
            popToNamed: '/',
            type: BeamPageType.scaleTransition,
            child: SubRedditPage(sub: sub),
          );
        },
        '/r/:sub/comments/:postID/:postTitle': (context, state) {
          final sub = state.pathParameters['sub']!;
          return Text(sub);
        },
      },
    ),
  );
  return routerDelegate;
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beamerDelegate = ref.watch(beamerDelegateProvider);
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: beamerDelegate,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to ze`xro; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
    );
  }
}

const semiTransparentGrey = Color.fromARGB(200, 66, 66, 66);

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("sweet for reddit"),
      ),
      body: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(controller: _controller),
          ),
          ElevatedButton(
            onPressed: () =>
                Beamer.of(context).beamToNamed("/r/${_controller.text}"),
            child: const Text("Navigate to"),
          ),
        ],
      ),
    );
  }
}

class SubRedditPage extends HookConsumerWidget {
  const SubRedditPage({
    Key? key,
    required this.sub,
  }) : super(key: key);

  final String sub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(pageControllerProvider(this.sub));

    return Scaffold(
      appBar: AppBar(
        title: Text(this.sub),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: RefreshIndicator(
          onRefresh: () => Future.sync(() => controller.refresh()),
          child: PagedListView<String?, Link>(
            pagingController: controller,
            builderDelegate: PagedChildBuilderDelegate<Link>(
              itemBuilder: (context, item, index) {
                final thumbnail = item.data.preview;
                return Card(
                  child: Container(
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => launchURL(item.data.url),
                          child: Container(
                            decoration: BoxDecoration(
                                image: thumbnail != null
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(thumbnail
                                            .images[0].resolutions.last.url))
                                    : null),
                            height: 200,
                            width: double.infinity,
                            alignment: AlignmentDirectional.bottomStart,
                            child: DecoratedBox(
                                decoration: const BoxDecoration(
                                    color: semiTransparentGrey),
                                child: Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.data.domain,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => Beamer.of(context)
                                .beamToNamed(item.data.permalink),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.data.title,
                                maxLines: 2,
                                textScaleFactor: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [Text("↑ comments"), Text("↑ ↓ ⋮")],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SamplePlayer extends StatefulWidget {
  SamplePlayer({Key? key}) : super(key: key);

  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<SamplePlayer> {
  late final FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
          "https://v.redd.it/t7qlbs9uoxk71/DASHPlaylist.mpd"),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlickVideoPlayer(flickManager: flickManager),
    );
  }
}
