import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';

void launchURL(String url) async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

final pageControllerProvider =
    Provider.family<PagingController<String?, Link>, String>((ref, sub) {
  final client = ref.watch(restClientProvider);
  final controller = PagingController<String?, Link>(
      firstPageKey: null, invisibleItemsThreshold: 10);
  controller.addPageRequestListener((after) async {
    try {
      // TODO: add count to comply more with reddit API suggestions
      // should just be controller.itemList.length
      final posts =
          await client.getHot(sub, after, count: controller.itemList?.length);
      final newItems = posts.data.children.map((e) => e.data).toList();
      if (posts.data.after == null) {
        controller.appendLastPage(newItems);
      } else {
        controller.appendPage(newItems, posts.data.after);
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
    baseUrl: "https://reddit.com",
    headers: {
      HttpHeaders.userAgentHeader:
          "android:dev.bulik.suggarforredditapp:v0.0.1 (by /u/mrgreentea)"
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
            key: ValueKey('r/$sub'),
            title: 'r/$sub',
            popToNamed: '/',
            child: SubRedditPage(sub: sub),
          );
        },
        '/r/:sub/comments/:postID/:postTitle': (context, state) {
          final sub = state.pathParameters['sub']!;
          final postID = state.pathParameters['postID']!;
          return BeamPage(
              key: ValueKey('r/$sub/commments/$postID'),
              child: PostComments(post: state.uri),
              title: 'r/$sub/comments/$postID',
              popToNamed: 'r/$sub');
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
      title: 'Sweet Candy for reddit',
      theme: ThemeData(
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
                final thumbnail = item.preview;
                return Card(
                  child: Container(
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => launchURL(item.url),
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
                                      item.domain,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                Beamer.of(context).beamToNamed(item.permalink),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.title,
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

class PostComments extends HookConsumerWidget {
  final Uri post;

  const PostComments({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(restClientProvider);
    return Scaffold(
        appBar: AppBar(title: const Text("Comments")),
        body: FutureBuilder(
          future: client.getComments(this.post),
          builder: (context, AsyncSnapshot<Comments> snapshot) {
            List<Widget> children;
            final data = snapshot.data;
            if (data != null) {
              return ListView.builder(
                  itemCount: data.comments.data.children.length,
                  itemBuilder: (context, index) => Card(
                        child: ListTile(
                            title: MarkdownBody(
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    return launchURL(href);
                                  }
                                },
                                data: data
                                    .comments.data.children[index].data.body)),
                      ));
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = const <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          },
        ));
  }
}
