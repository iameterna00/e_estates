import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_estates/models/image_post.dart';
import 'package:e_estates/service/commentmodel.dart';
import 'package:e_estates/widgets/comment_widget.dart';
import 'package:e_estates/widgets/topfeed_detail_maps.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_view/photo_view.dart';

class TopFeedDetail extends StatefulWidget {
  final String distance;
  final dynamic curentUserid;
  final ImagePost detailpagepost;
  final String postID;

  const TopFeedDetail(
      {super.key,
      required this.detailpagepost,
      required this.distance,
      required this.postID,
      this.curentUserid});

  @override
  State<TopFeedDetail> createState() => _TopFeedDetailState();
}

class _TopFeedDetailState extends State<TopFeedDetail> {
  late ImagePost detailpagepost;
  double boxHeight = 200;
  final currentIndexNotifier = ValueNotifier<int>(0);
  int currentIndex = 0;
  bool _longPressed = false;
  late ScrollController _scrollController;
  bool _showAppBar = false;

  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    detailpagepost = widget.detailpagepost;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showAppBar = _scrollController.offset > 200;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 20, top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width *
                                  (9 / 16), // Adjust the height as needed
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    itemCount: detailpagepost.imageUrls.length,
                                    onPageChanged: (int index) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
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
                                                      itemCount: widget
                                                          .detailpagepost
                                                          .imageUrls
                                                          .length,
                                                      controller:
                                                          PageController(
                                                              initialPage:
                                                                  index),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return PhotoView(
                                                          imageProvider:
                                                              CachedNetworkImageProvider(widget
                                                                  .detailpagepost
                                                                  .imageUrls[index]),
                                                        );
                                                      },
                                                      onPageChanged:
                                                          (int index) {
                                                        setState(() {
                                                          currentIndexNotifier
                                                              .value = index;
                                                        });
                                                      },
                                                    ),
                                                    Align(
                                                      alignment:
                                                          const Alignment(
                                                              0, 0.7),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child:
                                                            ValueListenableBuilder<
                                                                int>(
                                                          valueListenable:
                                                              currentIndexNotifier,
                                                          builder: (context,
                                                              currentIndex, _) {
                                                            return DotsIndicator(
                                                              dotsCount: widget
                                                                  .detailpagepost
                                                                  .imageUrls
                                                                  .length,
                                                              position:
                                                                  currentIndex,
                                                              decorator:
                                                                  const DotsDecorator(
                                                                activeColor:
                                                                    Colors
                                                                        .white,
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
                                            CachedNetworkImage(
                                              imageUrl: detailpagepost
                                                  .imageUrls[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                            Positioned.fill(
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.8),
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
                                      child: Image.asset(
                                          'assets/icons/IC_Bookmark.png'),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, "/homepage");
                                      },
                                      child: Image.asset(
                                          'assets/icons/IC_Back.png'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: DotsIndicator(
                            dotsCount: detailpagepost.imageUrls.length,
                            position: currentIndex,
                            decorator: DotsDecorator(
                              activeColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 27, 122, 200)
                                  : Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, bottom: 2, right: 8, top: 8),
                            child: Text(
                              detailpagepost.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black),
                                    text: detailpagepost.location,
                                  ),
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.location_pin,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Text(
                              detailpagepost.description,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Text(
                            "Facilities",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 15, left: 8, right: 8),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: detailpagepost.homeAminities != null
                                ? detailpagepost.homeAminities!
                                    .map((String tag) {
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
                                      case 'Kitchen':
                                        iconData = Icons.soup_kitchen_rounded;
                                        break;

                                      default:
                                        iconData = Icons.home;
                                    }

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Text(
                              "Owner Preferences",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 15, left: 8, right: 8),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: detailpagepost.ownerPreferences != null
                                  ? detailpagepost.ownerPreferences!
                                      .map((String tag) {
                                      String imagePath;
                                      switch (tag) {
                                        case 'Family':
                                          imagePath = "assets/icons/family.png";
                                          break;
                                        case 'Female Student':
                                          imagePath =
                                              "assets/icons/studentfemaleblack.png";
                                          break;
                                        case 'Male Student':
                                          imagePath =
                                              "assets/icons/studentmale.png";
                                          break;
                                        case 'Male Worker':
                                          imagePath =
                                              "assets/icons/businessman.png";
                                          break;
                                        case 'Female Worker':
                                          imagePath =
                                              "assets/icons/businesswoman.png";
                                          break;
                                        case 'Night Shift':
                                          imagePath =
                                              "assets/icons/nonightshift.png";
                                        case 'Pets':
                                          imagePath = "assets/icons/nopets.png";

                                          break;
                                        case 'Any':
                                          imagePath = "assets/icons/all.png";
                                          break;
                                        case 'No Smooking':
                                          imagePath =
                                              "assets/icons/no-smoking.png";
                                          break;
                                        default:
                                          imagePath = "assets/icons/all.png";
                                      }

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Image.asset(imagePath, scale: 20.0),
                                            const SizedBox(width: 8.0),
                                            Text(tag),
                                          ],
                                        ),
                                      );
                                    }).toList()
                                  : [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              detailpagepost.uploaderProfilePicture),
                          radius: 25,
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: '${detailpagepost.uploaderName}\n',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          _longPressed = !_longPressed;
                          boxHeight = boxHeight == 200 ? 400 : 200;
                        });
                      },
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: MediaQuery.of(context).size.width,
                          height: boxHeight,
                          child: TopFeedMaps(
                            longPressed: _longPressed,
                            singleHomeLocation: LatLng(detailpagepost.latitude,
                                detailpagepost.longitude),
                            singleHome: widget.detailpagepost,
                          )),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Comments",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (commentController.text.trim().isEmpty) {
                            return;
                          }
                          submitComment(widget.postID,
                              commentController.text.trim(), context);
                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                  CommentsWidget(
                    postId: widget.postID,
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ])),
            _showAppBar
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.back_hand))
                : Container()
          ],
        ),
      ),
      floatingActionButton: isKeyboardVisible
          ? const SizedBox()
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent]),
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {});
                },
                label: Text('Rent Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        fontFamily: GoogleFonts.raleway().fontFamily)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: SizedBox(
          height: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price'),
              Text(
                "Rs ${NumberFormat('#,##,###.##', 'en_IN').format(detailpagepost.price)}/ ${detailpagepost.paymentfrequency}",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 27, 122, 200)
                      : Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
