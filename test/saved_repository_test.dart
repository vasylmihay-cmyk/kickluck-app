import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kickluck_mvp/features/fixtures/data/mock_fixtures.dart';
import 'package:kickluck_mvp/features/generator/domain/generated_pick.dart';
import 'package:kickluck_mvp/features/generator/domain/generation_mode.dart';
import 'package:kickluck_mvp/features/saved/data/saved_repository.dart';
import 'package:kickluck_mvp/features/saved/domain/saved_combination.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saved combination survives repository reload', () async {
    final repo = SavedRepository();
    final item = SavedCombination(
      id: 'saved_test',
      createdAt: DateTime(2026, 8, 8, 9),
      picks: [
        GeneratedPick(
          fixture: mockFixtures.first,
          mode: GenerationMode.oneXTwo,
          outcome: '1',
        ),
      ],
    );

    await repo.save(item);

    final reloadedRepo = SavedRepository();
    final items = await reloadedRepo.getAll();

    expect(items, hasLength(1));
    expect(items.single.id, 'saved_test');
    expect(items.single.picks.single.outcome, '1');
  });

  test('clear removes all saved combinations', () async {
    final repo = SavedRepository();
    final item = SavedCombination(
      id: 'saved_clear_test',
      createdAt: DateTime(2026, 8, 9, 9),
      picks: [
        GeneratedPick(
          fixture: mockFixtures.first,
          mode: GenerationMode.oneXTwo,
          outcome: '1',
        ),
      ],
    );

    await repo.save(item);
    expect(await repo.getAll(), hasLength(1));

    await repo.clear();

    expect(await repo.getAll(), isEmpty);
  });

}
