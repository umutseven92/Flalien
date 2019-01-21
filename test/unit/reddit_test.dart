import 'dart:convert';
import 'dart:io';

import 'package:flalien/reddit/comment/comment.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;


void main() {
  test('Can parse post with all child comments', () {

    // https://www.reddit.com/r/baduk/comments/ag6j2k/which_is_more_popular_in_japan_shogi_or_go/
    String filePath = p.join(Directory.current.path, 'unit', 'testPost.json');
    File testPost = File(filePath);

    String postJson = testPost.readAsStringSync();

    var jsonComments = jsonDecode(postJson);

    Reddit reddit = Reddit();

    List<Comment> comments = reddit.parseComments(jsonComments);

    expect(comments.length, 9);
    expect(comments[0].childComments.length, 1);
    expect(comments[0].childComments[0].childComments.length, 1);
    expect(comments[0].childComments[0].childComments[0].childComments.length, 1);
    expect(comments[0].childComments[0].childComments[0].childComments[0].childComments.length, 1);

    expect(comments[1].childComments.length, 0);
    expect(comments[2].childComments.length, 0);

    expect(comments[3].childComments.length, 2);
    expect(comments[3].childComments[0].childComments.length, 1);
    expect(comments[3].childComments[1].childComments.length, 1);

    expect(comments[4].childComments.length, 0);
    expect(comments[5].childComments.length, 0);
    expect(comments[6].childComments.length, 0);
    expect(comments[7].childComments.length, 0);
    expect(comments[8].childComments.length, 0);
  });
}
