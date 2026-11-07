class PricingPlanModel {
  final String id;
  final String title;
  final String target;
  final String price;
  final String period;
  final String description;
  final String highlight;
  final List<String> features;
  final bool isPopular;
  final String buttonText;

  const PricingPlanModel({
    required this.id,
    required this.title,
    required this.target,
    required this.price,
    required this.period,
    required this.description,
    required this.highlight,
    required this.features,
    required this.isPopular,
    required this.buttonText,
  });
}
