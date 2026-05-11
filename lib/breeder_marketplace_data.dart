class Breeder {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final bool isVerified;
  final double rating;
  final int reviews;
  final int successfulMatches;
  final String bio;
  final List<String> specialtyBreeds;
  final bool isPremium;

  Breeder({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    this.isVerified = true,
    this.rating = 4.8,
    this.reviews = 120,
    this.successfulMatches = 45,
    this.bio = "Dedicated breeder with over 10 years of experience in raising healthy and socialized pets.",
    required this.specialtyBreeds,
    this.isPremium = false,
  });
}

class MarketplacePet {
  final String id;
  final String name;
  final String breed;
  final double price;
  final String age;
  final String gender;
  final String imageUrl;
  final String breederId;
  final bool isVaccinated;
  final String type; // 'For Sale', 'Stud'
  final String healthRecordUrl;

  MarketplacePet({
    required this.id,
    required this.name,
    required this.breed,
    required this.price,
    required this.age,
    required this.gender,
    required this.imageUrl,
    required this.breederId,
    this.isVaccinated = true,
    this.type = 'For Sale',
    this.healthRecordUrl = 'https://example.com/health.pdf',
  });
}

final List<Breeder> mockBreeders = [
  Breeder(
    id: 'b1',
    name: 'Royal Paws Kennel',
    location: 'Panabo City',
    imageUrl: 'https://images.pexels.com/photos/8413300/pexels-photo-8413300.jpeg?auto=compress&cs=tinysrgb&w=800',
    specialtyBreeds: ['Shih Tzu', 'Golden Retriever'],
    isPremium: true,
    bio: "Top-rated kennel in Panabo specialized in champion-line Shih Tzus and Golden Retrievers.",
  ),
  Breeder(
    id: 'b2',
    name: 'Heritage Cat Cattery',
    location: 'Davao City',
    imageUrl: 'https://images.pexels.com/photos/8373517/pexels-photo-8373517.jpeg?auto=compress&cs=tinysrgb&w=800',
    specialtyBreeds: ['Persian Cat', 'Siamese'],
    rating: 4.9,
    reviews: 85,
    bio: "Exotic and Persian cat specialist. We focus on health, temperament, and beauty.",
  ),
  Breeder(
    id: 'b3',
    name: 'Elite Labradors',
    location: 'Tagum City',
    imageUrl: 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=800',
    specialtyBreeds: ['Labrador', 'Beagle'],
    rating: 4.7,
    reviews: 54,
    bio: "Producing high-quality working and companion Labradors for over 15 years.",
  ),
];

final List<MarketplacePet> mockMarketplacePets = [
  MarketplacePet(
    id: 'p1',
    name: 'Cooper',
    breed: 'Golden Retriever',
    price: 15000.0,
    age: '3 months',
    gender: 'Male',
    imageUrl: 'https://images.pexels.com/photos/2253275/pexels-photo-2253275.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b1',
    type: 'For Sale',
  ),
  MarketplacePet(
    id: 'p3',
    name: 'Simba',
    breed: 'Persian Cat',
    price: 8000.0,
    age: '4 months',
    gender: 'Male',
    imageUrl: 'https://images.pexels.com/photos/177809/pexels-photo-177809.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b2',
    type: 'For Sale',
  ),
  MarketplacePet(
    id: 'p4',
    name: 'Thunder',
    breed: 'Labrador',
    price: 5000.0, // Stud fee
    age: '3 years',
    gender: 'Male',
    imageUrl: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b1',
    type: 'Stud',
  ),
  MarketplacePet(
    id: 'p5',
    name: 'Ace',
    breed: 'Beagle',
    price: 4500.0,
    age: '2.5 years',
    gender: 'Male',
    imageUrl: 'https://images.pexels.com/photos/333083/pexels-photo-333083.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b3',
    type: 'Stud',
  ),
  MarketplacePet(
    id: 'p6',
    name: 'Rocky',
    breed: 'German Shepherd',
    price: 6000.0,
    age: '4 years',
    gender: 'Male',
    imageUrl: 'https://images.pexels.com/photos/3361739/pexels-photo-3361739.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b1',
    type: 'Stud',
  ),
  MarketplacePet(
    id: 'p7',
    name: 'Bella',
    breed: 'Shih Tzu',
    price: 12000.0,
    age: '5 months',
    gender: 'Female',
    imageUrl: 'https://images.pexels.com/photos/3663082/pexels-photo-3663082.jpeg?auto=compress&cs=tinysrgb&w=800',
    breederId: 'b1',
    type: 'For Sale',
  ),
];
