import 'package:drift/drift.dart';

@DataClassName('ChatMessageModel')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get sessionId => text().withLength(min: 1, max: 255)();

  TextColumn get role => text().withLength(min: 1, max: 50)();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isStreaming => boolean().withDefault(const Constant(false))();
}
