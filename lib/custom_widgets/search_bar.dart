import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function()? onClear;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    this.onChanged,
    this.onTap,
    this.onClear,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.searchController,
      focusNode: _focusNode,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.grey,
      cursorWidth: 2,
      cursorHeight: 22,
      onChanged: (value) {
        setState(() {});
        if (widget.onChanged != null) widget.onChanged!(value);
      },
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        _focusNode.unfocus();
      },
      onTap: () {
        if (widget.onTap != null) widget.onTap!();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 24),
        suffixIcon: widget.searchController.text.isNotEmpty
            ? IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.searchController.clear();
                  if (widget.onClear != null) widget.onClear!();
                },
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 22),
              )
            : null,
      ),
    );
  }
}
