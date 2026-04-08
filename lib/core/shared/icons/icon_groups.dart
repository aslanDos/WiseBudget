class IconGroup {
  final String name;
  final List<String> icons;

  const IconGroup({required this.name, required this.icons});
}

const kIconGroups = [
  IconGroup(
    name: 'Finance',
    icons: [
      'wallet', 'briefCase', 'receipt', 'shoppingBag', 'shoppingCart',
      'gift', 'piggyBank', 'creditCard', 'coins', 'banknote', 'trendingUp',
    ],
  ),
  IconGroup(
    name: 'Transport',
    icons: ['car', 'bus', 'plane', 'bike', 'train', 'ship', 'truck', 'fuel'],
  ),
  IconGroup(
    name: 'Home & Places',
    icons: ['home', 'building', 'globe', 'sofa', 'wrench', 'tree', 'lamp'],
  ),
  IconGroup(
    name: 'Food & Drink',
    icons: ['utensils', 'coffee', 'pizza', 'wine', 'beer', 'cake', 'salad'],
  ),
  IconGroup(
    name: 'Health & Sports',
    icons: ['dumbbell', 'stethoscope', 'heart', 'activity', 'pill', 'syringe', 'apple', 'bike'],
  ),
  IconGroup(
    name: 'Education & Work',
    icons: ['laptop', 'graduationCap', 'book', 'phone', 'monitor', 'code', 'presentation', 'pen'],
  ),
  IconGroup(
    name: 'Entertainment',
    icons: ['gamepad', 'music', 'star', 'zap', 'tv', 'film', 'headphones', 'camera', 'palette', 'ticket', 'clapperboard'],
  ),
];
