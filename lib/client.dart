import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'client.g.dart';

@RestApi(baseUrl: "https://www.reddit.com/")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/r/{sub}/hot.json")
  Future<HotPosts> getHot(
      @Path("sub") String sub, @Query("after") String? after,
      {@Query("limit") int limit = 25});
}

@JsonSerializable()
class HotData {
  String? after;
  String? before;
  int dist;
  String modhash;
  List<Link> children;

  HotData(
      {this.after,
      this.before,
      required this.dist,
      required this.modhash,
      required this.children});

  factory HotData.fromJson(Map<String, dynamic> json) =>
      _$HotDataFromJson(json);
  Map<String, dynamic> toJson() => _$HotDataToJson(this);
}

@JsonSerializable()
class Preview {
  List<PreviewImage> images;
  Preview({required this.images});

  factory Preview.fromJson(Map<String, dynamic> json) =>
      _$PreviewFromJson(json);
  Map<String, dynamic> toJson() => _$PreviewToJson(this);
}

@JsonSerializable()
class PreviewImage {
  String id;
  List<PreviewResolution> resolutions;

  PreviewImage({required this.id, required this.resolutions});

  factory PreviewImage.fromJson(Map<String, dynamic> json) =>
      _$PreviewImageFromJson(json);
  Map<String, dynamic> toJson() => _$PreviewImageToJson(this);
}

@JsonSerializable()
class PreviewResolution {
  String url;
  int width;
  int height;

  PreviewResolution(
      {required this.url, required this.width, required this.height});

  factory PreviewResolution.fromJson(Map<String, dynamic> json) =>
      _$PreviewResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$PreviewResolutionToJson(this);
}

@JsonSerializable()
class LinkData {
  String subreddit;
  String title;
  String name;
  String thumbnail;
  Preview? preview;
  String domain;
  String url;

  String permalink;

  LinkData(
      {required this.subreddit,
      required this.title,
      required this.name,
      required this.thumbnail,
      required this.domain,
      required this.url,
      required this.permalink,
      this.preview});

  factory LinkData.fromJson(Map<String, dynamic> json) =>
      _$LinkDataFromJson(json);
  Map<String, dynamic> toJson() => _$LinkDataToJson(this);
}

@JsonSerializable()
class Link {
  String kind;
  LinkData data;

  Link({required this.data, required this.kind});

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class HotPosts {
  final String kind;
  final HotData data;
  HotPosts({required this.kind, required this.data});

  factory HotPosts.fromJson(Map<String, dynamic> json) =>
      _$HotPostsFromJson(json);
  Map<String, dynamic> toJson() => _$HotPostsToJson(this);
}
