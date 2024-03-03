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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/WashingMachine.png'
                                          : 'assets/icons/WashingMachineWhite.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Laundary'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/FurnishedBlack.png'
                                          : 'assets/icons/Furnished.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems
                                      .contains('Furnished'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/KitchenBlack.png'
                                          : 'assets/icons/Kitchen.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Kitchen'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/WifiBlack.png'
                                          : 'assets/icons/Wifi.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('FreeWifi'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Parking'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
          SizedBox(
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/LiftDark.png'
                                          : 'assets/icons/Lift.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('Lift'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                            if (widget.selectedItems.contains('GYM')) {
                              widget.selectedItems.remove('GYM');
                              print(widget.selectedItems);
                            } else {
                              widget.selectedItems.add('GYM');
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
                                          ? 'assets/icons/GYMDark.png'
                                          : 'assets/icons/GYM.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems.contains('GYM'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/icons/SwimmingDark.png'
                                          : 'assets/icons/SwimmingPool.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedItems
                                      .contains('SwimmingPool'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.purple, size: 30),
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
