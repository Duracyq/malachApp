import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText.dart';

class EventDesignPage extends StatefulWidget {
  const EventDesignPage({Key? key}) : super(key: key);

  @override
  State<EventDesignPage> createState() => _EventDesignPageState();
}

class _EventDesignPageState extends State<EventDesignPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Name'), actions: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(30)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                "Category", // replace with the event category
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ),
      ]),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent, // start with transparent color
                        Colors.grey.shade300 // end with a specific color
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Expanded(
                      //   child: GFShimmer(
                      //     child: const MyText(
                      //         text: "Event Name",
                      //         rozmiar: 24,
                      //         waga: FontWeight.bold),
                      //     showGradient: true,
                      //     gradient: LinearGradient(
                      //       begin: Alignment.bottomRight,
                      //       end: Alignment.centerLeft,
                      //       stops: const <double>[
                      //         0,
                      //         0.3,
                      //         0.6,
                      //         0.9,
                      //         1,
                      //       ],
                      //       colors: [
                      //         Colors.teal.withOpacity(0.1),
                      //         Colors.teal.withOpacity(0.3),
                      //         Colors.teal.withOpacity(0.5),
                      //         Colors.teal.withOpacity(0.7),
                      //         Colors.teal.withOpacity(0.9),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const MyText(
                          text: "Event Name",
                          rozmiar: 24,
                          waga: FontWeight.bold),
                      // Expanded(
                      //   child: Text(
                      //     'Event Name',
                      //     textAlign: TextAlign.center, // center the text
                      //     style: TextStyle(
                      //       fontSize: 24,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
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
                  const SizedBox(height: 10),
                  const Text(
                    'Event DescriptionEvent DescriptionE vent Desc riptio nEvent De scriptionEvent Descript ionEvent Descri ption Event Descr iptionEvent DescriptionEv ent Descriptio nEvent Description',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jakies dane',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Jakies dane',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jakies dane',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Jakies dane',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g
}
