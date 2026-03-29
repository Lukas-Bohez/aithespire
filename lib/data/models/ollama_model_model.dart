import 'package:drift/drift.dart';

@DataClassName('OllamaModelModel')
class OllamaModels extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 255)();

  TextColumn get tag => text().withLength(min: 1, max: 255)();

  IntColumn get size => integer()();

  DateTimeColumn get installedAt => dateTime()();

  DateTimeColumn get lastUsedAt => dateTime()();
}
