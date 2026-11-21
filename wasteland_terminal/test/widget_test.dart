import 'package:flutter_test/flutter_test.dart';
import 'package:wasteland_terminal/ui/theme.dart';

void main() {
  test('theme index is clamped', () {
    T.setTheme(999);
    expect(T.current, termThemes.last);
    T.setTheme(0);
    expect(T.current, termThemes.first);
  });
}
