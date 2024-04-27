import 'package:flutter/material.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class FoundersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeData == 'dark';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Founders Page'),
      ),
      body: ListView(
        children: [
          _buildFounderCard(
            name: 'Szymon Kajak',
            description: 'Co-Founder / Backend Developer / 🛶 /',
            photoUrl: 'assets/founders_images/IMG_0158_-selected_-removebg-cropped-removebg-preview.png',
            backgroundColor: isDarkMode
                ? Colors.black
                : Colors.white,
            context: context,
          ),
          _buildFounderCard(
            name: 'Wiktor Żabka',
            description: 'Co-Founder / Frontend Developer / 🐸 /',
            photoUrl: '',
            backgroundColor: isDarkMode
                ? Colors.black
                : Colors.white,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildFounderCard({
    required String name,
    required String description,
    required String photoUrl,
    required Color backgroundColor,
    required BuildContext context,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeData == 'dark';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(photoUrl),
                radius: 60,
              ),
              ListTile(
                title: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// create founders page look using Provider.of<ThemeProvider> as a color scheme. add a placeholder for photo and make it round. there are 2 co-founders. also add description to each of the co-founder 