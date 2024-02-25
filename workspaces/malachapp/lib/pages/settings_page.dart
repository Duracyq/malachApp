// import 'package:flutter/material.dart';
// import 'package:malachapp/components/my_button.dart';
// import 'package:provider/provider.dart';
// import 'package:malachapp/themes/dark_mode.dart';
// import 'package:malachapp/themes/light_mode.dart';
// import 'package:malachapp/components/my_button.dart';
// import 'package:malachapp/themes/theme_provider.dart';
// import 'package:provider/provider.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ustawienia'),
//       ),
//       body: Center(
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child:
//             // MyButton(
//             //     text: "Motyw",
//             //     onTap: () {
//             //       Provider.of<ThemeProvider>(context, listen: false)
//             //           .toggleTheme();
//             //     }),
//             Switch(
//           value: themeProvider.isDarkMode,
//           activeColor: Colors.red,
//           onChanged: (value) {
//             themeProvider.toggleTheme();
//           },
//             )
//           ),
//         ]),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:malachapp/components/my_button.dart';
// import 'package:provider/provider.dart';
// import 'package:malachapp/themes/theme_provider.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ustawienia'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Switch(
//                 value: Provider.of<ThemeProvider>(context).isDarkMode,
//                 activeColor: Colors.red,
//                 onChanged: (value) {
//                   Provider.of<ThemeProvider>(context, listen: false)
//                       .toggleTheme();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Switch(
                    value: Provider.of<ThemeProvider>(context).themeData ==
                        darkMode,
                    activeColor: const Color.fromARGB(255, 139, 139, 139),
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ),
                Text(
                  'Motyw',
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontStyle: FontStyle.normal,
                      // color: Color.fromRGBO(131, 116, 116, 1.0),
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
            ListTile(
              title: Text('Notifications'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: ((context) => NotificationsSubscriptionPage()))
              ),
            )
          ],
        ),
      ),
    );
  }
}
