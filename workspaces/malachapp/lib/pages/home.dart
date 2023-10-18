import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: const Column(children: [
        TopBarFb2(title: 'title', upperTitle: 'upperTitle')
      ]),
    );
  }
}