import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

class RestClient {
  Dio dio;

  RestClient(this.dio);

  Future<HotPosts> getHot(String sub, String? after,
      {int limit = 25, int? count, CancelToken? cancelToken}) async {
    final queryParameters = {r'after': after, r'limit': limit, r'count': count};
    queryParameters.removeWhere((k, v) => v == null);
    final _result = await dio.get<Map<String, dynamic>>('/r/$sub/hot.json',
        cancelToken: cancelToken);
    final value = HotPosts.fromJson(_result.data!);
    return value;
  }

  Future<Comments> getComments(Uri permalink,
      {CancelToken? cancelToken}) async {
    final _result = await dio.get<List<dynamic>>('$permalink.json');

    final value = Comments.fromJson(_result.data!);
    return value;
  }
}

class Comments {
  Listing<Link> post;
  Listing<Comment> comments;

  Comments({required this.post, required this.comments});

  factory Comments.fromJson(List<dynamic> json) {
    if (json is List) {
      if (json.length != 2) {
        throw ArgumentError.value(
          json,
          'json',
          'Can only convert list with 2 elements.',
        );
      }
      final post = json.first;
      final comments = json.last;

      return Comments(
        post: Listing<Link>.fromJson(
            post, (j) => Link.fromJson(j as Map<String, dynamic>)),
        // TODO if there are many comments the last one might be of kind: "more"
        // that causes a crash here
        // see for example https://www.reddit.com/r/funny/comments/pg6cy2/outstanding_move.json
        comments: Listing<Comment>.fromJson(
            comments, (j) => Comment.fromJson(j as Map<String, dynamic>)),
      );
    }
    throw ArgumentError.value(
      json,
      'json',
      'Can only convert list.',
    );
  }
}

@JsonSerializable(createToJson: false)
class Comment {
  String name;
  String author;
  String body;

  Comment({required this.name, required this.author, required this.body});

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class Listing<T> {
  String kind;
  ListingData<T> data;

  Listing({required this.kind, required this.data});

  factory Listing.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ListingFromJson(json, fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class ListingData<T> {
  String? after;
  String? before;
  int? dist;
  String modhash;
  List<ListingItem<T>> children;

  ListingData(
      {this.after,
      this.before,
      this.dist,
      required this.modhash,
      required this.children});

  factory ListingData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ListingDataFromJson(json, fromJsonT);
}

@JsonSerializable(createToJson: false)
class Preview {
  List<PreviewImage> images;
  Preview({required this.images});

  factory Preview.fromJson(Map<String, dynamic> json) =>
      _$PreviewFromJson(json);
}

@JsonSerializable(createToJson: false)
class PreviewImage {
  String id;
  List<PreviewResolution> resolutions;

  PreviewImage({required this.id, required this.resolutions});

  factory PreviewImage.fromJson(Map<String, dynamic> json) =>
      _$PreviewImageFromJson(json);
}

@JsonSerializable(createToJson: false)
class PreviewResolution {
  String url;
  int width;
  int height;

  PreviewResolution(
      {required this.url, required this.width, required this.height});

  factory PreviewResolution.fromJson(Map<String, dynamic> json) =>
      _$PreviewResolutionFromJson(json);
}

@JsonSerializable(createToJson: false)
class Link {
  String subreddit;
  String title;
  String? selftext;
  String name;
  String thumbnail;
  Preview? preview;
  String domain;
  String url;

  String permalink;

  Link(
      {required this.subreddit,
      required this.title,
      required this.selftext,
      required this.name,
      required this.thumbnail,
      required this.domain,
      required this.url,
      required this.permalink,
      this.preview});

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
}

@JsonSerializable(createToJson: false)
class LinkData {
  String kind;
  Link data;

  LinkData({required this.data, required this.kind});

  factory LinkData.fromJson(Map<String, dynamic> json) =>
      _$LinkDataFromJson(json);
}

@JsonSerializable(createToJson: false, genericArgumentFactories: true)
class ListingItem<T> {
  String kind;
  T data;

  ListingItem({required this.kind, required this.data});

  factory ListingItem.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ListingItemFromJson(json, fromJsonT);
}

@JsonSerializable(createToJson: false)
class HotPosts {
  final String kind;
  final ListingData<Link> data;

  HotPosts({required this.kind, required this.data});

  factory HotPosts.fromJson(Map<String, dynamic> json) =>
      _$HotPostsFromJson(json);
}
