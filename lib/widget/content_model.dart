class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent(
      {required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents = [
  UnboardingContent(
      description:
          "The app designed to simplify your journey in finding and booking the perfect short-term rental.",
      image: "images/image3.jpg",
      title: 'Discover a new way to experience travel with EaseEstate'),
];
