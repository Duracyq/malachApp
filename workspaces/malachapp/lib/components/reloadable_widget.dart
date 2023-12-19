import 'package:flutter/material.dart';

class ReloadableWidget extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const ReloadableWidget({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  _ReloadableWidgetState createState() => _ReloadableWidgetState();
}

class _ReloadableWidgetState extends State<ReloadableWidget> {
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  Future<void> _handleRefresh() async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });

      await widget.onRefresh();

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : widget.child,
    );
  }
}
