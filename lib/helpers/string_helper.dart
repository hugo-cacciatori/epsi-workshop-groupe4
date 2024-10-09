String capitalize(String name) {
  if (name.isEmpty) {
    return name; // Return empty if the name is empty
  }
  return name[0].toUpperCase() +
      name
          .substring(1)
          .toLowerCase(); // Capitalize the first letter and make the rest lowercase
}
