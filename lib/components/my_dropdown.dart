import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final String title; // The main label of the dropdown menu (e.g., "Breakfast")
  final String subtitle; // The subtitle of the dropdown menu (e.g., "373 kcal")
  final String? selectedValue; // Currently selected item in the dropdown
  final List<Map<String, String>> items; // List of items to show in the dropdown with name and description
  final ValueChanged<String?> onChanged; // Callback for when an item is selected
  final ValueChanged<String?> onRemove; // Callback for the minus button
  final VoidCallback onAdd; // Callback for the "add" button

  const MyDropdown({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical spacing between rows
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dropdown container with specified width and padding
          Container(
            width: 220, // Adjust the width of the dropdown container here
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0, // Horizontal padding inside the dropdown container
              vertical: 5.0, // Vertical padding inside the dropdown container (affects height)
            ),
            decoration: BoxDecoration(
              color: Colors.grey[850], // Background color of the dropdown
              borderRadius: BorderRadius.circular(30.0), // Rounded corners of the dropdown
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // Removes divider lines between items
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero, // Removes padding around the dropdown tile
                childrenPadding: EdgeInsets.zero, // Removes padding around dropdown items

                // Dropdown menu's title and subtitle
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18), // Title text style
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14), // Subtitle text style
                ),
                iconColor: Colors.white, // Icon color when expanded
                collapsedIconColor: Colors.white, // Icon color when collapsed
                collapsedBackgroundColor: Colors.grey[850], // Background color when collapsed
                backgroundColor: Colors.grey[850], // Background color when expanded

                // Dropdown items
                children: items.map((item) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800], // Background color for each item
                                borderRadius: BorderRadius.circular(15.0), // Circular border for each item
                              ),
                              child: ListTile(
                                title: Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(color: Colors.white), // Text color for item name
                                ),
                                subtitle: Text(
                                  item['description'] ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12), // Text color for item description
                                ),
                                onTap: () => onChanged(item['name']), // Call onChanged with selected item name
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Spacing between item and minus button
                          // Minus icon with circular outline
                          Container(
                            width: 23, // Set smaller width for the container
                            height: 23, // Set smaller height for the container
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Keep the container circular
                              border: Border.all(color: Colors.white, width: 1.0), // Border thickness
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white, size: 17), // Set icon size smaller
                              onPressed: () => onRemove(item['name']), // Callback when the icon is pressed
                              padding: EdgeInsets.zero, // Remove extra padding around the icon
                              constraints: const BoxConstraints(
                                minWidth: 24, // Matches container width for a snug fit
                                minHeight: 24, // Matches container height for a snug fit
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item != items.last) // Add divider only between items, not after the last item
                        const Divider(
                          color: Colors.grey, // Color of the divider
                          thickness: 1.0, // Thickness of the divider line
                          height: 16.0, // Space around the divider
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 25), // Spacing between dropdown and the add icon

          // Add icon with circular outline
          Container(
            width: 30, // Set smaller width for the container
            height: 30, // Set smaller height for the container
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Keep the container circular
              border: Border.all(color: Colors.white, width: 1.0), // Border thickness
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 24), // Set icon size smaller
              onPressed: onAdd, // Callback when the icon is pressed
              padding: EdgeInsets.zero, // Remove extra padding around the icon
              constraints: const BoxConstraints(
                minWidth: 24, // Matches container width for a snug fit
                minHeight: 24, // Matches container height for a snug fit
              ),
            ),
          ),
        ],
      ),
    );
  }
}
