// Abstract contract — swap fake/real by changing one line in main.dart
import '../domain/display_data.dart';

abstract class DataService {
  Stream<DisplayData> get stream;
  void start();
  void dispose();
}
