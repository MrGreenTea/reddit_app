// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return Comment(
    name: json['name'] as String,
    author: json['author'] as String,
    body: json['body'] as String,
  );
}

Listing<T> _$ListingFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) {
  return Listing<T>(
    kind: json['kind'] as String,
    data: ListingData.fromJson(
        json['data'] as Map<String, dynamic>, (value) => fromJsonT(value)),
  );
}

ListingData<T> _$ListingDataFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) {
  return ListingData<T>(
    after: json['after'] as String?,
    before: json['before'] as String?,
    dist: json['dist'] as int?,
    modhash: json['modhash'] as String,
    children: (json['children'] as List<dynamic>)
        .map((e) => ListingItem.fromJson(
            e as Map<String, dynamic>, (value) => fromJsonT(value)))
        .toList(),
  );
}

Preview _$PreviewFromJson(Map<String, dynamic> json) {
  return Preview(
    images: (json['images'] as List<dynamic>)
        .map((e) => PreviewImage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

PreviewImage _$PreviewImageFromJson(Map<String, dynamic> json) {
  return PreviewImage(
    id: json['id'] as String,
    resolutions: (json['resolutions'] as List<dynamic>)
        .map((e) => PreviewResolution.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

PreviewResolution _$PreviewResolutionFromJson(Map<String, dynamic> json) {
  return PreviewResolution(
    url: json['url'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
  );
}

Link _$LinkFromJson(Map<String, dynamic> json) {
  return Link(
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

LinkData _$LinkDataFromJson(Map<String, dynamic> json) {
  return LinkData(
    data: Link.fromJson(json['data'] as Map<String, dynamic>),
    kind: json['kind'] as String,
  );
}

ListingItem<T> _$ListingItemFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) {
  return ListingItem<T>(
    kind: json['kind'] as String,
    data: fromJsonT(json['data']),
  );
}

HotPosts _$HotPostsFromJson(Map<String, dynamic> json) {
  return HotPosts(
    kind: json['kind'] as String,
    data: ListingData.fromJson(json['data'] as Map<String, dynamic>,
        (value) => Link.fromJson(value as Map<String, dynamic>)),
  );
}
