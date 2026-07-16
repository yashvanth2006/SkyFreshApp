import 'package:url_launcher/url_launcher.dart';

class ShopInfo {
  static const name = 'SKY PAZHAMUDHIR NILAYAM';
  static const primaryPhone = '8870682988';
  static const secondaryPhone = '9894325988';
  static const whatsAppPhone = primaryPhone;
  static const email = 'yashvanth2006k@gmail.com';
  static const openingHours = 'Open daily · 8:30 AM To 10:00 PM';
  static const googleMapsUrl =
      'https://www.google.com/maps/place/SKY+PAZHAMUDHIR+NILAYAM/@11.0427426,76.9243548,21z/data=!4m6!3m5!1s0x3ba859c28e3e7561:0x3124c49cd088be1c!8m2!3d11.0427535!4d76.9241488!16s%2Fg%2F11vfb3hjlr?entry=ttu';
  static const latitude = 11.0427535;
  static const longitude = 76.9241488;

  static String formatPhone(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  static String get primaryPhoneDisplay => formatPhone(primaryPhone);
  static String get secondaryPhoneDisplay => formatPhone(secondaryPhone);

  static Future<bool> callPrimary() => _launch(Uri(scheme: 'tel', path: '+91$primaryPhone'));

  static Future<bool> callSecondary() => _launch(Uri(scheme: 'tel', path: '+91$secondaryPhone'));

  static Future<bool> openWhatsApp() =>
      _launch(Uri.parse('https://wa.me/91$whatsAppPhone'));

  static Future<bool> sendEmail() => _launch(Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'SKYfresh Support'},
      ));

  static Future<bool> openMaps() => _launch(Uri.parse(googleMapsUrl));

  static Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
