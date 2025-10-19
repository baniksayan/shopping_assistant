class Country {
  final String name;
  final String code;
  final String flagAsset;

  const Country({
    required this.name,
    required this.code,
    required this.flagAsset,
  });
}

class Countries {
  static const List<Country> all = [
    Country(
      name: 'India',
      code: 'IN',
      flagAsset: 'assets/icons/flags/indiaflag.png',
    ),
    Country(
      name: 'Bangladesh',
      code: 'BD',
      flagAsset: 'assets/icons/flags/bangladeshflag.png',
    ),
    Country(
      name: 'Nepal',
      code: 'NP',
      flagAsset: 'assets/icons/flags/nepalflag.png',
    ),
    Country(
      name: 'Bhutan',
      code: 'BT',
      flagAsset: 'assets/icons/flags/bhutanflag.png',
    ),
    Country(
      name: 'Singapore',
      code: 'SG',
      flagAsset: 'assets/icons/flags/singaporeflag.png',
    ),
    Country(
      name: 'Sri Lanka',
      code: 'LK',
      flagAsset: 'assets/icons/flags/srilankaflag.png',
    ),
  ];

  static Country getByName(String name) {
    return all.firstWhere(
      (country) => country.name == name,
      orElse: () => all.first,
    );
  }

  static Country getByCode(String code) {
    return all.firstWhere(
      (country) => country.code == code,
      orElse: () => all.first,
    );
  }
}
