import 'package:e_estates/service/image_post.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopFeedDetail extends StatelessWidget {
  final String distance;
  final ImagePost detailpagepost;

  const TopFeedDetail(
      {super.key, required this.detailpagepost, required this.distance});

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
                  'Rs. ${detailpagepost.title}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                    child: PageView.builder(
                      itemCount: detailpagepost.imageUrls
                          .length, // Assuming detailpagepost.imageUrls is a List<String>
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Image.network(
                              detailpagepost.imageUrls[
                                  index], // Load the image at the current index
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
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Text(
                                detailpagepost.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () {},
                                child:
                                    Image.asset('assets/icons/IC_Bookmark.png'),
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
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(detailpagepost.description),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text("$distance km"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Your action here
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
