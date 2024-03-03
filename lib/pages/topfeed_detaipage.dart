import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_estates/service/image_post.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

class TopFeedDetail extends StatefulWidget {
  final String distance;
  final ImagePost detailpagepost;

  const TopFeedDetail(
      {super.key, required this.detailpagepost, required this.distance});

  @override
  State<TopFeedDetail> createState() => _TopFeedDetailState();
}

class _TopFeedDetailState extends State<TopFeedDetail> {
  final currentIndexNotifier = ValueNotifier<int>(0);
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SingleChildScrollView(
        child: BottomAppBar(
          elevation: 0,
          child: SizedBox(
            height: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price'),
                Text(
                  'Rs. ${widget.detailpagepost.price} / ${widget.detailpagepost.paymentfrequency}',
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width *
                        (9 / 16), // Adjust the height as needed
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: widget.detailpagepost.imageUrls.length,
                          onPageChanged: (int index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                currentIndexNotifier.value = index;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      body: Stack(
                                        children: [
                                          PageView.builder(
                                            itemCount: widget.detailpagepost
                                                .imageUrls.length,
                                            controller: PageController(
                                                initialPage: index),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return PhotoView(
                                                imageProvider: NetworkImage(
                                                    widget.detailpagepost
                                                        .imageUrls[index]),
                                              );
                                            },
                                            onPageChanged: (int index) {
                                              setState(() {
                                                currentIndexNotifier.value =
                                                    index;
                                              });
                                            },
                                          ),
                                          Align(
                                            alignment: Alignment(0, 0.7),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child:
                                                  ValueListenableBuilder<int>(
                                                valueListenable:
                                                    currentIndexNotifier,
                                                builder:
                                                    (context, currentIndex, _) {
                                                  return DotsIndicator(
                                                    dotsCount: widget
                                                        .detailpagepost
                                                        .imageUrls
                                                        .length,
                                                    position: currentIndex,
                                                    decorator:
                                                        const DotsDecorator(
                                                      activeColor: Colors.white,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Image.network(
                                    widget.detailpagepost.imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {},
                            child: Image.asset('assets/icons/IC_Bookmark.png'),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/homepage");
                            },
                            child: Image.asset('assets/icons/IC_Back.png'),
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: DotsIndicator(
                                dotsCount:
                                    widget.detailpagepost.imageUrls.length,
                                position: currentIndex,
                                decorator: const DotsDecorator(
                                  activeColor: Colors.white,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.detailpagepost.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.detailpagepost.location,
                ),
              ),
              (widget.distance.isNotEmpty)
                  ? Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Text(widget.distance),
                        ),
                        const Icon(Icons.location_pin),
                      ],
                    )
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  widget.detailpagepost.description,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Facilities",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: widget.detailpagepost.homeAminities != null
                      ? widget.detailpagepost.homeAminities!.map((String tag) {
                          IconData iconData;
                          switch (tag) {
                            case 'Furnished':
                              iconData = Icons.chair;
                              break;
                            case 'CCTV':
                              iconData = Icons.videocam;
                              break;
                            case 'SwimmingPool':
                              iconData = Icons.pool;
                              break;
                            case 'Laundary':
                              iconData = Icons.local_laundry_service;
                              break;
                            case 'Parking':
                              iconData = Icons.local_parking;
                              break;
                            case 'FreeWifi':
                              iconData = Icons.wifi;
                              break;
                            case 'Lift':
                              iconData = Icons.elevator;
                              break;
                            case 'GYM':
                              iconData = Icons.fitness_center;
                              break;

                            default:
                              iconData = Icons.home;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(iconData, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(tag),
                              ],
                            ),
                          );
                        }).toList()
                      : [],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.detailpagepost.uploaderProfilePicture),
                      radius: 25,
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: '${widget.detailpagepost.uploaderName}\n',
                              style: Theme.of(context).textTheme.bodyLarge),
                          TextSpan(
                              text: 'Owner',
                              style: GoogleFonts.raleway(
                                color: Colors.grey,
                              ))
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.phone),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.message),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
        },
        label: Text('Rent Now',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontFamily: GoogleFonts.raleway().fontFamily)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        isExtended: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
