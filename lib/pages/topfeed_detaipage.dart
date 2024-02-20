import 'package:e_estates/service/image_post.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopFeedDetail extends StatelessWidget {
  final ImagePost detailpagepost;

  const TopFeedDetail({super.key, required this.detailpagepost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SingleChildScrollView(
        child: BottomAppBar(
          elevation: 0,
          height: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price'),
              Text(
                'Rs. ${detailpagepost.title}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
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
                  child: Stack(
                    children: [
                      Image.network(detailpagepost.imageUrl),
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
                              ])),
                        ),
                      )),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Text(
                          detailpagepost.title,
                          style: const TextStyle(
                              //  fontFamily: GoogleFonts.raleway().fontFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {},
                            child: Image.asset('assets/icons/IC_Bookmark.png'),
                          )),
                      Positioned(
                          top: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/homepage");
                            },
                            child: Image.asset('assets/icons/IC_Back.png'),
                          ))
                      // Add more widgets to display other details about the post
                    ],
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
              )
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
        //  icon: Icon(Icons.home),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        /*   materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap, */ // Minimizes the padding
        isExtended: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
