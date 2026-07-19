class UserAddress {
  final String id;
  final String label;
  final String line;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.label,
    required this.line,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      label: json['label'] as String? ?? 'Home',
      line: json['line'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime joinedAt;
  final List<UserAddress> addresses;
  final int orderCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.joinedAt,
    this.addresses = const [],
    this.orderCount = 0,
  });

  String? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address.line;
    }
    return addresses.isNotEmpty ? addresses.first.line : null;
  }

  String get formattedJoinDate {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[joinedAt.month - 1]} ${joinedAt.day}, ${joinedAt.year}';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final addressesJson = json['addresses'];
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      addresses: addressesJson is List
          ? addressesJson
              .map((a) => UserAddress.fromJson(Map<String, dynamic>.from(a)))
              .toList()
          : const [],
      orderCount: json['orderCount'] as int? ?? 0,
    );
  }
}

String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${diff.inDays ~/ 7 == 1 ? '' : 's'} ago';
  return UserProfile(
    id: '',
    name: '',
    phone: '',
    joinedAt: dateTime,
  ).formattedJoinDate;
}

String formatOrderStatus(String status) {
  switch (status) {
    case 'placed':
      return 'Placed';
    case 'confirmed':
      return 'Confirmed';
    case 'out_for_delivery':
      return 'Out for delivery';
    case 'delivered':
      return 'Delivered';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status;
  }
}
