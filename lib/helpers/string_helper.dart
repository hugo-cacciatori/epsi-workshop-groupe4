import 'package:intl/intl.dart';

String capitalize(String name) {
  if (name.isEmpty) {
    return name; // Return empty if the name is empty
  }
  return name[0].toUpperCase() +
      name
          .substring(1)
          .toLowerCase(); // Capitalize the first letter and make the rest lowercase
}

String formatTimestamp(DateTime timestamp) {
  return DateFormat('MMMM d, yyyy at h:mm:ss a')
      .format(timestamp); // Example: October 9, 2024 at 1:34:06 PM
}
