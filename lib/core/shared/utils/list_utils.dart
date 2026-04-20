/// Applies a reorder operation on [items] and returns the reordered list.
/// Use with [ReorderableListView]'s onReorder callback.
List<T> applyReorder<T>(List<T> items, int oldIndex, int newIndex) {
  if (oldIndex < newIndex) newIndex -= 1;
  final reordered = List<T>.from(items);
  final moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);
  return reordered;
}
