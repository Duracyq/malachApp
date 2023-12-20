import 'package:flutter/material.dart';
import 'package:malachapp/components/text.dart';

class MyButton extends StatelessWidget {
  final MyText myText;
  final void Function()? onTap;

  const MyButton({Key? key, required this.myText, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(15),
        child: Center(
          child: MyText(
            text: myText.text,
            fontSize: myText.fontSize,
            textColor: myText.textColor,
            underline: myText.underline,
          ),
        ),
      ),
    );
  }
}
