import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search products across all platforms...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          _buildActionButton(
            icon: Icons.camera_alt,
            onPressed: onCameraPressed,
            tooltip: 'Search by Camera',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          _buildActionButton(
            icon: Icons.photo_library,
            onPressed: onGalleryPressed,
            tooltip: 'Search by Gallery',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          _buildActionButton(
            icon: Icons.search,
            onPressed: onSearch,
            tooltip: 'Search',
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isPrimary ? Colors.deepPurple : Colors.grey.shade600,
            size: 22,
          ),
        ),
      ),
    );
  }
}