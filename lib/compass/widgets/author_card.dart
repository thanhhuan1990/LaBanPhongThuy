import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xpromo/xpromo.dart';

import '../../ui/palette.dart';

/// Thông tin tác giả la bàn (thay cho ContactWidget cũ): thẻ gọn trên màn hình chính,
/// chạm để mở bảng chi tiết (điện thoại, email, ngân hàng) kèm ứng dụng khác.
/// App tâm linh cùng nhà phát triển: đã cài → nút "Mở", chưa cài → "Cài".
const List<String> kSpiritualApps = [
  'com.huanhuynh.lichvannien',
  'com.huanhuynh.vankhan',
  'com.huanhuynh.xinxam',
  'com.huanhuynh.numerology',
];

/// Các app khác (chỉ gợi ý khi chưa cài).
const List<String> kOtherApps = [
  'com.huanhuynh.sochitieu',
  'com.huanhuynh.waterreminder',
  'com.huanhuynh.cyclecare',
  'com.huanhuynh.freshnest',
  'com.huanhuynh.spin_the_wheel',
];

XPromoStyle _promoStyle(ElementTheme accent) => XPromoStyle(
      cardColor: Palette.card,
      borderColor: Palette.line,
      textColor: Palette.ink,
      mutedColor: Palette.muted,
      accentColor: accent.primary,
      onAccentColor: Colors.white,
    );

const TextStyle _sectionTitle = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Palette.muted, letterSpacing: 0.6);

class Author {
  Author._();

  static const String name = 'Nguyễn Nhan Thái Thạnh';
  static const String brand = 'Lý Số Việt Nam';
  static const String phone1 = '0913013489';
  static const String phone2 = '0934131468';
  static const String email = 'thaithanh87@gmail.com';
  static const String bank = 'NamABank';
  static const String bankAccount = '0913013489';
}

Future<void> _open(String url) async {
  try {
    await launchUrl(Uri.parse(url));
  } catch (_) {}
}

class AuthorCard extends StatelessWidget {
  const AuthorCard({super.key, required this.accent});

  final ElementTheme accent;

  @override
  Widget build(BuildContext context) {
    void copyAccount() {
      Clipboard.setData(const ClipboardData(text: Author.bankAccount));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép số tài khoản')));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Palette.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showAuthorSheet(context, accent),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Seal(height: 62),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('TÁC GIẢ LA BÀN',
                                style: TextStyle(
                                    fontSize: 10.5, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: accent.primary)),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.muted),
                        ],
                      ),
                      const Text(Author.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Palette.ink, fontFamily: 'serif')),
                      const SizedBox(height: 4),
                      _InfoLine(
                        icon: Icons.call_rounded,
                        accent: accent,
                        parts: [
                          _Link(Author.phone1, () => _open('tel:+84913013489')),
                          _Link(Author.phone2, () => _open('tel:+84934131468')),
                        ],
                      ),
                      _InfoLine(
                        icon: Icons.mail_outline_rounded,
                        accent: accent,
                        parts: [_Link(Author.email, () => _open('mailto:${Author.email}'))],
                      ),
                      _InfoLine(
                        icon: Icons.account_balance_outlined,
                        accent: accent,
                        prefix: '${Author.bank} – ',
                        parts: [_Link(Author.bankAccount, copyAccount)],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Link {
  const _Link(this.text, this.onTap);

  final String text;
  final VoidCallback onTap;
}

/// Một dòng liên hệ: icon + các giá trị chạm được (gọi, email, sao chép).
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.accent, required this.parts, this.prefix});

  final IconData icon;
  final ElementTheme accent;
  final List<_Link> parts;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final TextStyle link = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accent.primary);
    final List<Widget> items = [];
    for (int i = 0; i < parts.length; i++) {
      if (i > 0) items.add(const Text('  ·  ', style: TextStyle(fontSize: 13, color: Palette.muted)));
      items.add(GestureDetector(onTap: parts[i].onTap, child: Text(parts[i].text, style: link)));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Palette.muted),
          const SizedBox(width: 6),
          if (prefix != null) Text(prefix!, style: const TextStyle(fontSize: 13, color: Palette.ink)),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: items),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ấn triện "Lý Số Việt Nam" (assets/Signature.png).
class _Seal extends StatelessWidget {
  const _Seal({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.line),
      ),
      child: Image.asset('assets/Signature.png', height: height, fit: BoxFit.contain),
    );
  }
}

Future<void> showAuthorSheet(BuildContext context, ElementTheme accent) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Palette.paper,
    builder: (ctx) {
      void copyAccount() {
        Clipboard.setData(const ClipboardData(text: Author.bankAccount));
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Đã sao chép số tài khoản')));
      }

      Widget tile(IconData icon, String title, String value, VoidCallback onTap, {IconData? trailing}) => ListTile(
            leading: CircleAvatar(backgroundColor: accent.light, child: Icon(icon, color: accent.primary, size: 20)),
            title: Text(title, style: const TextStyle(fontSize: 12.5, color: Palette.muted)),
            subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Palette.ink)),
            trailing: trailing == null ? null : Icon(trailing, color: Palette.muted, size: 20),
            onTap: onTap,
          );

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const _Seal(height: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TÁC GIẢ LA BÀN',
                            style: TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w600, color: accent.primary)),
                        const SizedBox(height: 4),
                        const Text(Author.name,
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Palette.ink, fontFamily: 'serif')),
                        const Text(Author.brand, style: TextStyle(fontSize: 13, color: Palette.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Palette.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.line),
                ),
                child: Column(
                  children: [
                    tile(Icons.call_rounded, 'Điện thoại', Author.phone1, () => _open('tel:+84913013489'), trailing: Icons.chevron_right),
                    const Divider(height: 1, color: Palette.line),
                    tile(Icons.call_rounded, 'Điện thoại', Author.phone2, () => _open('tel:+84934131468'), trailing: Icons.chevron_right),
                    const Divider(height: 1, color: Palette.line),
                    tile(Icons.mail_outline_rounded, 'Email', Author.email, () => _open('mailto:${Author.email}'),
                        trailing: Icons.chevron_right),
                    const Divider(height: 1, color: Palette.line),
                    tile(Icons.account_balance_outlined, 'Ngân hàng ${Author.bank}', Author.bankAccount, copyAccount,
                        trailing: Icons.copy_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MoreAppsSection(
                placement: 'author_sheet',
                title: 'ỨNG DỤNG TÂM LINH CỦA CHÚNG TÔI',
                titleStyle: _sectionTitle,
                ids: kSpiritualApps,
                showInstalled: true,
                style: _promoStyle(accent),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Bảng "Ứng dụng khác" mở từ nút trên thanh tiêu đề.
Future<void> showMoreAppsSheet(BuildContext context, ElementTheme accent) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Palette.paper,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ứng dụng khác của chúng tôi',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Palette.ink)),
            const SizedBox(height: 4),
            const Text('Lịch âm, văn khấn, xin xăm, thần số học… miễn phí từ cùng nhà phát triển.',
                style: TextStyle(fontSize: 13, color: Palette.muted)),
            const SizedBox(height: 14),
            MoreAppsSection(
              placement: 'appbar_tamlinh',
              title: 'ỨNG DỤNG TÂM LINH',
              titleStyle: _sectionTitle,
              ids: kSpiritualApps,
              showInstalled: true,
              style: _promoStyle(accent),
            ),
            const SizedBox(height: 16),
            MoreAppsSection(
              placement: 'appbar',
              title: 'ỨNG DỤNG KHÁC',
              titleStyle: _sectionTitle,
              ids: kOtherApps,
              max: 5,
              style: _promoStyle(accent),
            ),
          ],
        ),
      ),
    ),
  );
}
