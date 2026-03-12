extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
  
  String toTitleCase() {
    if (isEmpty) return this;
    if (length <= 2) return toUpperCase(); // For HR
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
