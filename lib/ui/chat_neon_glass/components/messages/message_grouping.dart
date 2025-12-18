import 'package:intl/intl.dart';

import '../../adapters/ui_message.dart';

/// Groups messages by date (year-month-day) preserving input order.
class MessageGrouping {
  const MessageGrouping();

  Map<String, List<UIMessage>> groupByDate(List<UIMessage> messages) {
    final Map<String, List<UIMessage>> grouped = <String, List<UIMessage>>{};
    for (final UIMessage m in messages) {
      final DateTime ts = m.timestamp;
      final String key = DateFormat('yyyy-MM-dd').format(ts);
      grouped.putIfAbsent(key, () => <UIMessage>[]).add(m);
    }
    return grouped;
  }
}
