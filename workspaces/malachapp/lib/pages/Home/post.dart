import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class Post3 extends StatefulWidget {
  const Post3({Key? key}) : super(key: key);

  @override
  State<Post3> createState() => _Post3();
}

class _Post3 extends State<Post3> {
  @override
  Widget build(BuildContext context) {
    // final content = Expanded(
    //   child: MasonryGridView.builder(
    //     mainAxisSpacing: 4,
    //     crossAxisSpacing: 4,
    //     gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2,
    //     ),
    //     itemBuilder: (BuildContext context, int index) {
    //       return ClipRRect(
    //         borderRadius: BorderRadius.circular(10), // Zaokrąglenie rogów
    //         child: Image.asset(
    //           'assets/zd${index + 1}.jpg',
    //           fit: BoxFit.cover,
    //         ),
    //       );
    //     },
    //     itemCount: 6, // Number of images
    //   ),
    // );
    // final sheet = ScrollableSheet(
    //   Widget buildSheetBackground(BuildContext context, Widget content) {
    //     // Define the implementation of the 'buildSheetBackground' method here
    //     // ...
    //   },

    //   child: buildSheetBackground(context, content),

    //   minExtent: const Extent.proportional(0.2),
    //   physics: StretchingSheetPhysics(
    //     parent: SnappingSheetPhysics(
    //       snappingBehavior: SnapToNearest(
    //         snapTo: [
    //           const Extent.proportional(0.2),
    //           const Extent.proportional(0.5),
    //           const Extent.proportional(1),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    final themeProvider = Provider.of<ThemeProvider>(context);

    // Ustal kolory na podstawie motywu
    final color = themeProvider.currentThemeKey == 'light'
        ? Color.fromARGB(255, 133, 196, 255)
        : Colors.blueGrey;
    final color2 = themeProvider.currentThemeKey == 'light'
        ? Color.fromARGB(255, 133, 196, 255)
        : Colors.grey.shade900;

    final isDarkMode = themeProvider.currentThemeKey == 'dark';

    return Scaffold(
        appBar: AppBar(
          title: const Text('Event Name'),
          actions: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: color.withOpacity(0.5), // Kolor obramowania
                            width: 3, // Grubość obramowania
                          ),
                          left: BorderSide(
                            color: color.withOpacity(0.5), // Kolor obramowania
                            width: 3, // Grubość obramowania
                          ),
                          right: BorderSide(
                            color: color.withOpacity(0.5), // Kolor obramowania
                            width: 3, // Grubość obramowania
                          ),
                          bottom: BorderSide.none, // Brak obramowania na dole
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              28), // Zaokrąglenie lewego górnego rogu
                          topRight: Radius.circular(
                              28), // Zaokrąglenie prawego górnego rogu
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: MasonryGridView.builder(
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 4,
                            gridDelegate:
                                SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Stack(
                                        children: [
                                          // Rozmycie i przyciemnienie tła
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Zamknij dialog po kliknięciu na tło
                                            },
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 5, sigmaY: 5),
                                              child: Container(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          // Dialog z obrazem
                                          Dialog(
                                            backgroundColor: Colors
                                                .transparent, // Ustaw tło na przezroczyste
                                            insetPadding: EdgeInsets.all(
                                                10), // Dodaj padding do Dialog
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(24),
                                                    topRight:
                                                        Radius.circular(24),
                                                  ),

                                                  /// Zaokrąglenie rogu
                                                  child: FittedBox(
                                                    child: Image.asset(
                                                      'assets/zd${index + 1}.jpg',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.download,
                                                    color: Colors.white,
                                                  ), // Ikona do pobrania
                                                  onPressed: () async {
                                                    final String url =
                                                        'assets/zd${index + 1}.jpg'; // URL do zdjęcia
                                                    final String savePath =
                                                        '/path/to/save/image.jpg'; // Ścieżka, gdzie chcesz zapisać zdjęcie

                                                    await FlutterDownloader
                                                        .enqueue(
                                                      url: url,
                                                      savedDir: savePath,
                                                      showNotification:
                                                          true, // pokazuje powiadomienie, gdy pobieranie jest zakończone
                                                      openFileFromNotification:
                                                          true, // otwiera plik po zakończeniu pobierania
                                                    );

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Zdjęcie zostało pobrane'),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/zd${index + 1}.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            itemCount: 12, // Number of images
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0, bottom: 14, left: 8),
                child: SizedBox(
                  width: 70.0,
                  height: 70.0,
                  child: Shimmer.fromColors(
                    period: Duration(milliseconds: 1000),
                    baseColor: color.withOpacity(0.9),
                    highlightColor: color.withOpacity(0.3),
                    child: MyText1(
                      text: 'Zdjęcia',
                      rozmiar: 20,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // share the event
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent, // start with transparent color
                        color // end with a specific color
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyText1(
                          text: "Event Name",
                          rozmiar: 34,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Text(
                              "11.05.2024", // replace with the event date
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    MyText2(
                      text:
                          'Event DescriptionEvent DescriptionE vent Desc riptio nEvent De scriptionEvent Descript ionEvent Descri ption Event Descr iptionEvent DescriptionEv ent Descriptio nEvent Description',
                      rozmiar: 16,
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey,
                      indent: 5,
                      endIndent: 5,
                      thickness: 4,
                    ),
                    // Padding(
                    //   padding: EdgeInsets.all(8.0),
                    //   child: MyText1(
                    //     text: "Zdjęcia",
                    //     rozmiar: 24,
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 200.0,
                    //   height: 100.0,
                    //   child: Shimmer.fromColors(
                    //     period: Duration(milliseconds: 1000),
                    //     baseColor: Colors.teal.withOpacity(0.9),
                    //     highlightColor: Colors.teal.withOpacity(0.3),
                    //     child: MyText1(
                    //       text: 'Zdjęcia',
                    //       rozmiar: 40,
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
          ],
        ));
  }
}
  // https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g

