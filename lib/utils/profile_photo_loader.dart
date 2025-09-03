import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

ImageProvider<Object>? loadProfileImage(String? url) {
  if (url == null || url.isEmpty) return null;
  return CachedNetworkImageProvider(url);
}
