/// Created by Huan.Huynh on 24/Apr/2021
///
/// Copyright © 2021 by Huan.Huynh All rights reserved.

final List<String> canList = List.from(['Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu', 'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý']);
final List<String> chiList =
    List.from(['Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ', 'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi']);
final List<String> menhList = List.from([
  'Tích Lịch Hoả',
  'Tùng Bách Mộc',
  'Trường Lưu Thủy',
  'Sa Trung Kim',
  'Sơn Hạ Hoả',
  'Bình Địa Mộc',
  'Bích Thượng Thổ',
  'Kim Bạch Kim',
  'Hú Đăng Hoả',
  'Thiên Hà Thủy',
  'Đại Dịch Thổ',
  'Thoa Xuyến Kim',
  'Tang Đố Mộc',
  'Đại Khê Thủy',
  'Sa Trung Thổ',
  'Thiên Thượng Hoả',
  'Thạch Lựu Mộc',
  'Đại Hải Thủy',
  'Hải Trung Kim',
  'Lộ Trung Hoả',
  'Đại Lâm Mộc',
  'Lộ Bàng Thổ',
  'Kiếm Phong Kim',
  'Sơn Đầu Hoả',
  'Giản Hạ Thủy',
  'Thành Đầu Thổ',
  'Bạch Lạp Kim',
  'Dương Liễu Mộc',
  'Tuyền Trung Thủy',
  'Ốc Thượng Thổ',
]);

final List<String> namMenhList = List.from(['Tốn', 'Chấn', 'Khôn', 'Khảm', 'Ly', 'Cấn', 'Đoài', 'Kiền', 'Khôn']);
final List<String> namMenhImagesList = List.from([
  '1_Ton.jpg',
  '2_Chan.jpg',
  '3_Khon.jpg',
  '4_Kham.jpg',
  '5_Ly.jpg',
  '6_Can.jpg',
  '7_Đoai.jpg',
  '8_Can.jpg',
  '3_Khon.jpg'
]);
final List<String> nuMenhList = List.from(['Khôn', 'Chấn', 'Tốn', 'Cấn', 'Kiền', 'Đoài', 'Cấn', 'Ly', 'Khảm']);
final List<String> nuMenhImagesList = List.from([
  '3_Khon.jpg',
  '2_Chan.jpg',
  '1_Ton.jpg',
  '6_Can.jpg',
  '8_Can.jpg',
  '7_Đoai.jpg',
  '6_Can.jpg',
  '5_Ly.jpg',
  '4_Kham.jpg'
]);

String getCanChi(DateTime dateTime) {
  int year = dateTime.year - 4;
  return "${canList.elementAt(year % 10)} ${chiList.elementAt(year % 12)}";
}

String getNguHanh(DateTime dateTime) {
  int year = dateTime.year;
  return menhList.elementAt(((year - 28) / 2).floor() % 30);
}

String getMenh(String gender, DateTime dateTime) {
  int year = dateTime.year;
  if (gender == 'Nam') {
    return namMenhList.elementAt(year % 1924 % 9);
  } else {
    return nuMenhList.elementAt(year % 1924 % 9);
  }
}

String getMenhImages(String gender, DateTime dateTime) {
  int year = dateTime.year;
  if (gender == 'Nam') {
    return namMenhImagesList.elementAt(year % 1924 % 9);
  } else {
    return nuMenhImagesList.elementAt(year % 1924 % 9);
  }
}

String getDirection(double heading) {
  if (heading <= 22.5 || heading >= 337.5) {
    return " : ${heading.round()}° Bắc";
  } else if (heading < 337.5 && heading > 292.5) {
    return " : ${heading.round()}° Tây Bắc";
  } else if (heading <= 292.5 && heading >= 247.5) {
    return " : ${heading.round()}° Tây";
  } else if (heading < 247.5 && heading > 202.5) {
    return " : ${heading.round()}° Tây Nam";
  } else if (heading <= 202.5 && heading > 157.5) {
    return " : ${heading.round()}° Nam";
  } else if (heading <= 157.5 && heading > 112.5) {
    return " : ${heading.round()}° Đông Nam";
  } else if (heading <= 112.5 && heading > 67.5) {
    return " : ${heading.round()}° Đông";
  } else if (heading <= 67.5 && heading > 22.5) {
    return " : ${heading.round()}° Đông Bắc";
  }
  return "Invalid value";
}
