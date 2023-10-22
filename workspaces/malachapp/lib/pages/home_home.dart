import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHome extends StatefulWidget {
  const HomeHome({super.key});

  @override
  State<HomeHome> createState() => _HomeHomeState();
}

class _HomeHomeState extends State<HomeHome> {
  //! Z A K L A D K I
  List<String> items = [
    "Wydarzenia",
    "Posty",
  ];
  List<IconData> icons = [
    Icons.home,
    Icons.explore,
  ];
  int current = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(5),
      child: Column(children: [
        /// Tab Bar
        SizedBox(
          width: double.infinity,
          height: 80,
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          current = index;
                        });
                        pageController.animateToPage(
                          current,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(5),
                        width: 100,
                        height: 55,
                        decoration: BoxDecoration(
                          color: current == index
                              ? Colors.white70
                              : Colors.white54,
                          borderRadius: current == index
                              ? BorderRadius.circular(12)
                              : BorderRadius.circular(7),
                          border: current == index
                              ? Border.all(
                                  color: Colors.deepPurpleAccent, width: 2.5)
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[index],
                                size: current == index ? 23 : 20,
                                color: current == index
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                              Text(
                                items[index],
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                  color: current == index
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: current == index,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            shape: BoxShape.circle),
                      ),
                    )
                  ],
                );
              }),
        ),

        /// MAIN BODY
        Container(
          margin: const EdgeInsets.only(top: 30),
          width: double.infinity,
          height: 550,
          child: PageView.builder(
            itemCount: icons.length,
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[current],
                    size: 200,
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${items[current]} Tab Content",
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                        color: Colors.deepPurpleAccent),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}
