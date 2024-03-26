import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactWidget extends StatelessWidget {
  ContactWidget({Key? key}) : super(key: key);

  final double fontSize = 12;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            key: GlobalKey(),
            text: TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: fontSize),
              children: <TextSpan>[
                TextSpan(text: 'Liên hệ Tác Giả: '),
                TextSpan(
                    text: '0913013489',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launch("tel:+84913013489");
                      }),
                TextSpan(text: ' - '),
                TextSpan(
                    text: '0934131468',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launch("tel:+84934131468");
                      }),
              ],
            ),
          ),
          SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: fontSize),
              children: <TextSpan>[
                TextSpan(text: 'Email: '),
                TextSpan(
                    text: 'thaithanh87@gmail.com',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launch("mailto:thaithanh87@gmail.com");
                      }),
              ],
            ),
          ),
          SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: fontSize),
              children: <TextSpan>[
                TextSpan(text: 'Ngân Hàng: '),
                TextSpan(
                  text: 'NamABank - 0913013489',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
