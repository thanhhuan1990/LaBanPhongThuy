import 'package:flutter_test/flutter_test.dart';
import 'package:la_ban_phong_thuy/utils/CanChiUtils.dart';

void main() {
  test('directionName chia 8 hướng', () {
    expect(directionName(0), 'Bắc');
    expect(directionName(350), 'Bắc');
    expect(directionName(45), 'Đông Bắc');
    expect(directionName(90), 'Đông');
    expect(directionName(135), 'Đông Nam');
    expect(directionName(180), 'Nam');
    expect(directionName(225), 'Tây Nam');
    expect(directionName(270), 'Tây');
    expect(directionName(315), 'Tây Bắc');
  });

  test('Can Chi, mệnh', () {
    expect(getCanChi(DateTime(1990)), 'Canh Ngọ');
    expect(getCanChi(DateTime(2024)), 'Giáp Thìn');
  });
}
