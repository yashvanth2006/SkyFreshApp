import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';

class MyAddressesScreen extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileUpdated;

  const MyAddressesScreen({super.key, required this.profile, this.onProfileUpdated});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  late UserProfile _profile;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  Future<void> _refreshProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      setState(() => _profile = profile);
      widget.onProfileUpdated?.call(profile);
    }
  }

  Future<void> _showAddDialog() async {
    final labelCtrl = TextEditingController(text: 'Home');
    final lineCtrl = TextEditingController();
    var isDefault = _profile.addresses.isEmpty;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Add New Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Label (Home, Work...)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lineCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Full address *', alignLabelWithHint: true),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setModalState) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isDefault,
                  onChanged: (v) => setModalState(() => isDefault = v ?? false),
                  title: const Text('Set as default', style: TextStyle(fontWeight: FontWeight.w600)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (lineCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved != true || !mounted) return;

    setState(() => _busy = true);
    final res = await ApiService.addAddress(
      label: labelCtrl.text.trim(),
      line: lineCtrl.text.trim(),
      isDefault: isDefault,
    );
    if (!mounted) return;

    if (res['success'] == true && res['user'] != null) {
      setState(() {
        _profile = UserProfile.fromJson(Map<String, dynamic>.from(res['user']));
        _busy = false;
      });
      widget.onProfileUpdated?.call(_profile);
    } else {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Could not save address')),
      );
    }
  }

  Future<void> _setDefault(String addressId) async {
    setState(() => _busy = true);
    final res = await ApiService.setDefaultAddress(addressId);
    if (!mounted) return;
    if (res['success'] == true && res['user'] != null) {
      setState(() {
        _profile = UserProfile.fromJson(Map<String, dynamic>.from(res['user']));
        _busy = false;
      });
      widget.onProfileUpdated?.call(_profile);
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _delete(String addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address?'),
        content: const Text('This address will be removed from your saved list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _busy = true);
    final res = await ApiService.deleteAddress(addressId);
    if (!mounted) return;
    if (res['success'] == true && res['user'] != null) {
      setState(() {
        _profile = UserProfile.fromJson(Map<String, dynamic>.from(res['user']));
        _busy = false;
      });
      widget.onProfileUpdated?.call(_profile);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Addresses'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _busy ? null : _refreshProfile, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _showAddDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _busy && _profile.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refreshProfile,
              child: _profile.addresses.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.location_off_outlined, size: 56, color: AppTheme.textMuted),
                              SizedBox(height: 14),
                              Text('No saved addresses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              SizedBox(height: 6),
                              Text('Add one now or save during checkout', style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _profile.addresses.length,
                      itemBuilder: (_, i) {
                        final address = _profile.addresses[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: address.isDefault ? AppTheme.primary : AppTheme.border,
                              width: address.isDefault ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(address.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                                  ),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('Default', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                                    ),
                                  ],
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'default') _setDefault(address.id);
                                      if (value == 'delete') _delete(address.id);
                                    },
                                    itemBuilder: (_) => [
                                      if (!address.isDefault)
                                        const PopupMenuItem(value: 'default', child: Text('Set as default')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(address.line, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
