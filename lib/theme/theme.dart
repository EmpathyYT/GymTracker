import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4283128978),
      surfaceTint: Color(4283128978),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292600319),
      onPrimaryContainer: Color(4278196043),
      secondary: Color(4283981426),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292731385),
      onSecondaryContainer: Color(4279638828),
      tertiary: Color(4285813872),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294956792),
      onTertiaryContainer: Color(4281012779),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294637823),
      onBackground: Color(4279900961),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      surfaceVariant: Color(4293059308),
      onSurfaceVariant: Color(4282730063),
      outline: Color(4285888128),
      outlineVariant: Color(4291151568),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294045943),
      inversePrimary: Color(4290037247),
      primaryFixed: Color(4292600319),
      onPrimaryFixed: Color(4278196043),
      primaryFixedDim: Color(4290037247),
      onPrimaryFixedVariant: Color(4281484408),
      secondaryFixed: Color(4292731385),
      onSecondaryFixed: Color(4279638828),
      secondaryFixedDim: Color(4290889437),
      onSecondaryFixedVariant: Color(4282467929),
      tertiaryFixed: Color(4294956792),
      onTertiaryFixed: Color(4281012779),
      tertiaryFixedDim: Color(4293049308),
      onTertiaryFixedVariant: Color(4284104024),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4281221236),
      surfaceTint: Color(4283128978),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284576682),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282204757),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285494408),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283840852),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287326855),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294637823),
      onBackground: Color(4279900961),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      surfaceVariant: Color(4293059308),
      onSurfaceVariant: Color(4282466891),
      outline: Color(4284309351),
      outlineVariant: Color(4286151299),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294045943),
      inversePrimary: Color(4290037247),
      primaryFixed: Color(4284576682),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282931855),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285494408),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283849583),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287326855),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285616750),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278722386),
      surfaceTint: Color(4283128978),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281221236),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280033843),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282204757),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281538866),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283840852),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294637823),
      onBackground: Color(4279900961),
      surface: Color(4294637823),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4293059308),
      onSurfaceVariant: Color(4280427563),
      outline: Color(4282466891),
      outlineVariant: Color(4282466891),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4293454847),
      primaryFixed: Color(4281221236),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279642717),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282204757),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280757310),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283840852),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282262333),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4290037247),
      surfaceTint: Color(4290037247),
      onPrimary: Color(0xff1a2e60),
      primaryContainer: Color(0xff324478),
      onPrimaryContainer: Color(4292600319),
      secondary: Color(4290889437),
      onSecondary: Color(0xff2a3042),
      secondaryContainer: Color(4282467929),
      onSecondaryContainer: Color(4292731385),
      tertiary: Color(4293049308),
      onTertiary: Color(4282525505),
      tertiaryContainer: Color(4284104024),
      onTertiaryContainer: Color(4294956792),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279374616),
      onBackground: Color(4293124841),
      surface: Color(4279374616),
      onSurface: Color(4293124841),
      surfaceVariant: Color(4282730063),
      onSurfaceVariant: Color(4291151568),
      outline: Color(4287598746),
      outlineVariant: Color(4282730063),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inverseOnSurface: Color(4281282614),
      inversePrimary: Color(4283128978),
      primaryFixed: Color(4292600319),
      onPrimaryFixed: Color(4278196043),
      primaryFixedDim: Color(4290037247),
      onPrimaryFixedVariant: Color(4281484408),
      secondaryFixed: Color(4292731385),
      onSecondaryFixed: Color(4279638828),
      secondaryFixedDim: Color(4290889437),
      onSecondaryFixedVariant: Color(4282467929),
      tertiaryFixed: Color(4294956792),
      onTertiaryFixed: Color(4281012779),
      tertiaryFixedDim: Color(4293049308),
      onTertiaryFixedVariant: Color(4284104024),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4290431487),
      surfaceTint: Color(4290037247),
      onPrimary: Color(4278195007),
      primaryContainer: Color(4286418888),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291152609),
      onSecondary: Color(4279244326),
      secondaryContainer: Color(4287336613),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293312480),
      onTertiary: Color(4280618277),
      tertiaryContainer: Color(4289300132),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293124841),
      surface: Color(4279374616),
      onSurface: Color(4294769407),
      surfaceVariant: Color(4282730063),
      onSurfaceVariant: Color(4291480276),
      outline: Color(4288783020),
      outlineVariant: Color(4286743180),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inverseOnSurface: Color(4280887855),
      inversePrimary: Color(4281615994),
      primaryFixed: Color(4292600319),
      onPrimaryFixed: Color(4278193716),
      primaryFixedDim: Color(4290037247),
      onPrimaryFixedVariant: Color(4280365927),
      secondaryFixed: Color(4292731385),
      onSecondaryFixed: Color(4278915105),
      secondaryFixedDim: Color(4290889437),
      onSecondaryFixedVariant: Color(4281349704),
      tertiaryFixed: Color(4294956792),
      onTertiaryFixed: Color(4280223776),
      tertiaryFixedDim: Color(4293049308),
      onTertiaryFixedVariant: Color(4282920263),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294769407),
      surfaceTint: Color(4290037247),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290431487),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294769407),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291152609),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4293312480),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293124841),
      surface: Color(4279374616),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282730063),
      onSurfaceVariant: Color(4294769407),
      outline: Color(4291480276),
      outlineVariant: Color(4291480276),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4279379802),
      primaryFixed: Color(4292994815),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290431487),
      onPrimaryFixedVariant: Color(4278195007),
      secondaryFixed: Color(4292994814),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291152609),
      onSecondaryFixedVariant: Color(4279244326),
      tertiaryFixed: Color(4294958584),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4293312480),
      onTertiaryFixedVariant: Color(4280618277),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
