import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key, required this.hintLabel, required this.onSubmitted});

  final String hintLabel;
  final Function(String) onSubmitted;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  FocusNode _focusNode = FocusNode();

  String searchVal = '';

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // to get the focus point
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The size of the screen
    MediaQueryData queryData = MediaQuery.of(context);
    return Container(
      width: queryData.size.width * 0.8,
      height: 40,
      padding: const EdgeInsets.only(left: 20),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: TextField(
        controller: _controller,
        // to get the focus point
        focusNode: _focusNode,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: widget.hintLabel,
          hintStyle: const TextStyle(color: Colors.grey),
          // cancel the border line
          border: InputBorder.none,
          icon: Padding(
            padding: const EdgeInsets.only(left: 0, top: 0),
            child: Icon(
              Icons.search,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          // only appear when there are words, click to clear the value
          suffixIcon: searchVal.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      searchVal = '';
                      _controller.clear();
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            searchVal = value;
          });
        },
        onSubmitted: (value) {
          widget.onSubmitted(value);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
