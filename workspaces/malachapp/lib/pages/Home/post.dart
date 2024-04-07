import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Post3 extends StatefulWidget {
  const Post3({Key? key}) : super(key: key);

  @override
  State<Post3> createState() => _Post3();
}

class _Post3 extends State<Post3> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Ustal kolory na podstawie motywu
    final color = themeProvider.currentThemeKey == 'light'
        ? Colors.grey.shade300
        : Colors.grey.shade900;
    final color2 = themeProvider.currentThemeKey == 'light'
        ? Color.fromARGB(255, 133, 196, 255)
        : Colors.grey.shade900;

    final isDarkMode = themeProvider.currentThemeKey == 'dark';
    return Scaffold(
      appBar: AppBar(title: const Text('Event Name'), actions: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // share the event
            },
          ),
        ),
      ]),
      body: Container(
        child: Column(
          children: [
            // SizedBox(
            //   height: 140,
            //   width: double.infinity,
            //   child: Container(
            //     decoration: const BoxDecoration(
            //       color: Colors.grey,
            //       image: DecorationImage(
            //         image: NetworkImage(
            //           'https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g',
            //         ),
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         gradient: LinearGradient(
            //           colors: [
            //             Colors.transparent, // start with transparent color
            //             color // end with a specific color
            //           ],
            //           begin: Alignment.topCenter,
            //           end: Alignment.bottomCenter,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Container(
            //   height: 300,
            //   child: SingleChildScrollView(
            //     child: Padding(
            //       padding: EdgeInsets.all(8.0),
            // child: Column(
            //   children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     MyText1(
            //       text: "Event Name",
            //       rozmiar: 34,
            //     ),
            //     Container(
            //       decoration: BoxDecoration(
            //           color: Colors.green.withOpacity(0.2),
            //           borderRadius: BorderRadius.circular(30)),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             vertical: 4, horizontal: 8),
            //         child: Text(
            //           "11.05.2024", // replace with the event date
            //           style: TextStyle(
            //               color: Colors.green,
            //               fontWeight: FontWeight.w800,
            //               fontSize: 16),
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            // SizedBox(height: 10),
            // MyText2(
            //   text:
            //       'Event DescriptionEvent DescriptionE vent Desc riptio nEvent De scriptionEvent Descript ionEvent Descri ption Event Descr iptionEvent DescriptionEv ent Descriptio nEvent Description',
            //   rozmiar: 16,
            // ),
            // SizedBox(height: 10),
            // SizedBox(height: 10),
            // // MasonryGridView.builder(
            // //   itemCount: 6,
            // //   gridDelegate:
            // //       SliverSimpleGridDelegateWithFixedCrossAxisCount(
            // //           crossAxisCount: 2),
            // //   itemBuilder: (context, index) => Padding(
            // //     padding: EdgeInsets.all(8.0),
            // //     child: ClipRRect(
            // //       borderRadius: BorderRadius.circular(12),
            // //       child: Image.network(
            // //         "https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g",
            // //       ),
            // //     ),
            // //   ),
            // // ),
            // SizedBox(height: 100),
            Expanded(
              child: MasonryGridView.builder(
                itemCount: 6,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                // mainAxisSpacing: 4,
                // crossAxisSpacing: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('assets/zd1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // SingleChildScrollView(
            //   child: MasonryGridView(
            //       gridDelegate:
            //           SliverSimpleGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 10)),
            // )
            // // MasonryGridView.count(
            //   crossAxisCount: 4,
            //   mainAxisSpacing: 4,
            //   crossAxisSpacing: 4,
            //   itemBuilder: (context, index) {
            //     return Container(
            //       color: Colors.orange,
            //     );
            //   },
            // )
            // ],
            // ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  // https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g
}
