import 'package:flutter/material.dart';

class homeAmanities extends StatefulWidget {
  const homeAmanities({
    super.key,
    required this.selectedItems,
  });

  final List<String> selectedItems;

  @override
  State<homeAmanities> createState() => _homeAmanitiesState();
}

class _homeAmanitiesState extends State<homeAmanities> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.3),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Home Aminities"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Laundary')) {
                              widget.selectedItems.remove("Laundary");
                            } else {
                              widget.selectedItems.add("Laundary");
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.local_laundry_service_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Laundary'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Laundary',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Furnished')) {
                              widget.selectedItems.remove('Furnished');
                              print(widget.selectedItems);
                            } else {
                              widget.selectedItems.add('Furnished');
                              print(widget.selectedItems);
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.chair_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems
                                      .contains('Furnished'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Furnished',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Kitchen')) {
                              widget.selectedItems.remove('Kitchen');
                            } else {
                              widget.selectedItems.add('Kitchen');
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.soup_kitchen_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Kitchen'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Kitchen',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //SECOND ROW
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('FreeWifi')) {
                              widget.selectedItems.remove("FreeWifi");
                            } else {
                              widget.selectedItems.add("FreeWifi");
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.network_wifi_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('FreeWifi'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Free Wifi',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('CCTV')) {
                              widget.selectedItems.remove('CCTV');
                              print(widget.selectedItems);
                            } else {
                              widget.selectedItems.add('CCTV');
                              print(widget.selectedItems);
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/CCTVBlack.png'
                                          : 'assets/icons/CCTV.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('CCTV'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'CCTV',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Parking')) {
                              widget.selectedItems.remove('Parking');
                            } else {
                              widget.selectedItems.add('Parking');
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/ParkingBlack.png'
                                          : 'assets/icons/Parking.png',
                                      scale: 7,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Parking'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                ' Parking',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.3),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Facilities"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Lift')) {
                              widget.selectedItems.remove("Lift");
                            } else {
                              widget.selectedItems.add("Lift");
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.elevator_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Lift'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Lift',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('Gym')) {
                              widget.selectedItems.remove('Gym');
                            } else {
                              widget.selectedItems.add('Gym');
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.fitness_center_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Gym'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Gym',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedItems.contains('SwimmingPool')) {
                              widget.selectedItems.remove('SwimmingPool');
                            } else {
                              widget.selectedItems.add('SwimmingPool');
                            }
                          });
                        },
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.pool_rounded,
                                      size: 75,
                                    ),
                                  ),
                                  if (widget.selectedItems
                                      .contains('SwimmingPool'))
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'SwimmingPool',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
