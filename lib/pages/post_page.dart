import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> postData;
  final List<Map<String, dynamic>> allPosts;

  const PostDetailPage(
      {super.key, required this.postData, required this.allPosts});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int _currentIndex = 0;
  Map<String, int> currentIndexMap = {};

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(widget.postData['urls']);
    String profilePicture = widget.postData['ProfilePicture'] as String;
    String name = widget.postData['Name'] as String;
    List<Map<String, dynamic>> otherPosts = widget.allPosts.where((post) {
      return post['Title'] != widget.postData['Title'] ||
          post['urls'][0] != widget.postData['urls'][0];
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePicture),
                      radius: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(name)
                  ],
                ),
              ),
              CarouselSlider(
                items: imageUrls
                    .map((url) => Container(
                          margin: EdgeInsets.zero,
                          height: 200,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Center(
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ))
                    .toList(),
                options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: DotsIndicator(
                    dotsCount: imageUrls.length,
                    position: _currentIndex,
                    decorator: const DotsDecorator(
                      activeColor: Colors.blue,
                      size: Size(6.0, 6.0),
                      activeSize: Size(8.0, 8.0),
                      spacing: EdgeInsets.symmetric(horizontal: 2.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.postData['Title'] ?? ''),
              const SizedBox(height: 20),
              ...otherPosts
                  .where((post) => post != widget.postData)
                  .map((post) {
                List<String> postImageUrls = List<String>.from(post['urls']);
                String postKey = postImageUrls.join(",");

                currentIndexMap.putIfAbsent(postKey, () => 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profilePicture),
                            radius: 24,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(name)
                        ],
                      ),
                    ),
                    CarouselSlider(
                      items: postImageUrls
                          .map((url) => Container(
                                margin: EdgeInsets.zero,
                                height: 200,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error),
                                    );
                                  },
                                ),
                              ))
                          .toList(),
                      options: CarouselOptions(
                        autoPlay: false,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndexMap[postKey] = index;
                          });
                        },
                      ),
                    ),
                    Center(
                      child: DotsIndicator(
                        dotsCount: postImageUrls.length,
                        position: currentIndexMap[postKey] ?? 0,
                        decorator: const DotsDecorator(
                          activeColor: Colors.blue,
                          size: Size(6.0, 6.0),
                          activeSize: Size(8.0, 8.0),
                          spacing: EdgeInsets.symmetric(horizontal: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(post['Title'] ?? '',
                        style: const TextStyle(
                            height: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
