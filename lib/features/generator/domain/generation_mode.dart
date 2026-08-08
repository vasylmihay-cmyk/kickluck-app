enum GenerationMode {
  oneXTwo,
  doubleChance,
  totalGoals,
  exactTotal,
  firstHalf,
  secondHalf,
  btts,
  teamToScore,
  randomMix,
}

extension GenerationModeLabel on GenerationMode {
  String get label {
    switch (this) {
      case GenerationMode.oneXTwo:
        return '1X2';
      case GenerationMode.doubleChance:
        return 'Double Chance';
      case GenerationMode.totalGoals:
        return 'Total';
      case GenerationMode.exactTotal:
        return 'Exact Total';
      case GenerationMode.firstHalf:
        return '1st Half';
      case GenerationMode.secondHalf:
        return '2nd Half';
      case GenerationMode.btts:
        return 'BTTS';
      case GenerationMode.teamToScore:
        return 'Team to Score';
      case GenerationMode.randomMix:
        return 'Random Mix';
    }
  }
}
