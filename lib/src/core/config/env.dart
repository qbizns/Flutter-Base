/// Environment configuration for the application.
enum Environment {
  dev,
  staging,
  prod;

  bool get isDev => this == Environment.dev;
  bool get isStaging => this == Environment.staging;
  bool get isProd => this == Environment.prod;
}

/// Global environment instance.
/// Can be set during app initialization.
Environment currentEnvironment = Environment.dev;
