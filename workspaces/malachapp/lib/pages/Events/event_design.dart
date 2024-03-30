import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/pages/Events/add_event.dart';
import 'package:malachapp/pages/Events/event_design_page.dart';

class EventList extends StatefulWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  bool isChecked = false; // add this line
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Widget _buildEventCard(BuildContext context, int i) {
    return Material(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => EventDesignPage(),
                ),
              );
              print("Event $i tapped");
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        'https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g',
                        fit: BoxFit
                            .cover, // this is to make sure the image covers the container
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                "Category", // replace with the event category
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                "Date", // replace with the event date
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "Event name", // replace with the event name
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "Event descriptionEvent descriptionEvent descriptionEvent descriptionEvent desc", // replace with the event description
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),

                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     GFCheckbox(
                //       activeBgColor: const Color.fromRGBO(16, 220, 96, 1),
                //       size: GFSize.SMALL,
                //       type: GFCheckboxType.circle,
                //       onChanged: (value) {
                //         setState(() {
                //           isChecked = value;
                //         });
                //       },
                //       value: isChecked,
                //       inactiveIcon: null,
                //     ),
                //     SizedBox(
                //       width: 3,
                //     ),
                //     Text(
                //       "Zapisz się!", // replace with the event price
                //       style: TextStyle(
                //           fontSize: 16,
                //           color: Colors.black,
                //           fontWeight: FontWeight.w700),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 0,
                // )
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isChecked =
                            !isChecked; // toggle isChecked when the button is pressed
                      });
                    },
                    child: Text(
                      "Zapisz się!",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) ||
                              isChecked)
                            return Colors
                                .transparent; // the color when button is pressed or isChecked is true
                          return Colors.blue; // the default color
                        },
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        const Size(118, 25),
                      ),
                      shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              13.0), // round the corners
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3)
              ],
            ),
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Events"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => AddEvent(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.add)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // number of columns
            crossAxisSpacing: 10, // spacing between the columns
            mainAxisSpacing: 10, // spacing between the rows
            childAspectRatio: 0.6),
        itemCount: 10, // replace with the number of events

        itemBuilder: (context, int i) {
          return _buildEventCard(context, i);
        }
        ),
      ),
    );
  }
}
