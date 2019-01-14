import 'package:cached_network_image/cached_network_image.dart';
import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  final String url;

  ImagePage(this.url);

  @override
  State<StatefulWidget> createState() {
    return ImagePageState(this.url);
  }
}

class ImagePageState extends State<ImagePage> {
  String cleanMediaUrl;

  ImagePageState(String mediaUrl) {
    if (mediaUrl.contains('imgur')) {
      var cleaned = mediaUrl.replaceFirst('imgur', '0imgur');
      this.cleanMediaUrl = cleaned;
    } else {
      cleanMediaUrl = mediaUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(Uri.parse(cleanMediaUrl).host)),
        body: Container(
            child: Center(
                child: CachedNetworkImage(
          imageUrl: this.cleanMediaUrl,
          placeholder: LoadingWidget(),
          fit: BoxFit.contain,
          errorWidget: Icon(
            Icons.error,
            color: Colors.red,
          ),
        ))));
  }
}
