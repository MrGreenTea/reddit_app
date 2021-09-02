// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotData _$HotDataFromJson(Map<String, dynamic> json) {
  return HotData(
    after: json['after'] as String?,
    before: json['before'] as String?,
    dist: json['dist'] as int,
    modhash: json['modhash'] as String,
    children: (json['children'] as List<dynamic>)
        .map((e) => Link.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$HotDataToJson(HotData instance) => <String, dynamic>{
      'after': instance.after,
      'before': instance.before,
      'dist': instance.dist,
      'modhash': instance.modhash,
      'children': instance.children,
    };

Preview _$PreviewFromJson(Map<String, dynamic> json) {
  return Preview(
    images: (json['images'] as List<dynamic>)
        .map((e) => PreviewImage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PreviewToJson(Preview instance) => <String, dynamic>{
      'images': instance.images,
    };

PreviewImage _$PreviewImageFromJson(Map<String, dynamic> json) {
  return PreviewImage(
    id: json['id'] as String,
    resolutions: (json['resolutions'] as List<dynamic>)
        .map((e) => PreviewResolution.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PreviewImageToJson(PreviewImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resolutions': instance.resolutions,
    };

PreviewResolution _$PreviewResolutionFromJson(Map<String, dynamic> json) {
  return PreviewResolution(
    url: json['url'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
  );
}

Map<String, dynamic> _$PreviewResolutionToJson(PreviewResolution instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

LinkData _$LinkDataFromJson(Map<String, dynamic> json) {
  return LinkData(
    subreddit: json['subreddit'] as String,
    title: json['title'] as String,
    name: json['name'] as String,
    thumbnail: json['thumbnail'] as String,
    domain: json['domain'] as String,
    url: json['url'] as String,
    permalink: json['permalink'] as String,
    preview: json['preview'] == null
        ? null
        : Preview.fromJson(json['preview'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LinkDataToJson(LinkData instance) => <String, dynamic>{
      'subreddit': instance.subreddit,
      'title': instance.title,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'preview': instance.preview,
      'domain': instance.domain,
      'url': instance.url,
      'permalink': instance.permalink,
    };

Link _$LinkFromJson(Map<String, dynamic> json) {
  return Link(
    data: LinkData.fromJson(json['data'] as Map<String, dynamic>),
    kind: json['kind'] as String,
  );
}

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'kind': instance.kind,
      'data': instance.data,
    };

HotPosts _$HotPostsFromJson(Map<String, dynamic> json) {
  return HotPosts(
    kind: json['kind'] as String,
    data: HotData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$HotPostsToJson(HotPosts instance) => <String, dynamic>{
      'kind': instance.kind,
      'data': instance.data,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://www.reddit.com/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<HotPosts> getHot(sub, after, {limit = 25}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'after': after, r'limit': limit};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<HotPosts>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/r/$sub/hot.json',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = HotPosts.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
