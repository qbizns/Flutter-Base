import 'package:equatable/equatable.dart';

/// Welcome message entity.
/// Represents the welcome screen content in the domain layer.
class WelcomeMessage extends Equatable {
  const WelcomeMessage({
    required this.title,
    required this.tagline,
    required this.description,
    required this.primaryButtonText,
    required this.secondaryButtonText,
  });

  final String title;
  final String tagline;
  final String description;
  final String primaryButtonText;
  final String secondaryButtonText;

  @override
  List<Object?> get props => [
        title,
        tagline,
        description,
        primaryButtonText,
        secondaryButtonText,
      ];

  WelcomeMessage copyWith({
    String? title,
    String? tagline,
    String? description,
    String? primaryButtonText,
    String? secondaryButtonText,
  }) {
    return WelcomeMessage(
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      primaryButtonText: primaryButtonText ?? this.primaryButtonText,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
    );
  }

  @override
  String toString() {
    return 'WelcomeMessage(title: $title, tagline: $tagline, '
        'description: $description, primaryButton: $primaryButtonText, '
        'secondaryButton: $secondaryButtonText)';
  }
}
