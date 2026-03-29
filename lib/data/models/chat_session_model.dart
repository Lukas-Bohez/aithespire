import 'package:drift/drift.dart';

@DataClassName('ChatSessionModel')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 255)();

  TextColumn get model => text().withLength(min: 1, max: 255)();

  TextColumn get systemPrompt => text().withLength(min: 0, max: 1000)();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get lastUpdatedAt => dateTime()();

  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  IntColumn get messageCount => integer().withDefault(const Constant(0))();
}
