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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Add New Address', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppTheme.textMain)),
              const SizedBox(height: 24),
              TextField(
                controller: labelCtrl,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Label (Home, Work...)',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lineCtrl,
                maxLines: 3,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Full address *',
                  alignLabelWithHint: true,
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isDefault,
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setModalState(() => isDefault = v ?? false),
                  title: const Text('Set as default address', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (lineCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete address?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('This address will be removed from your saved list.', style: TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
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
        backgroundColor: AppTheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Addresses', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _busy ? null : _refreshProfile, icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMain)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _showAddDialog,
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
      ),
      body: _busy && _profile.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3))
          : RefreshIndicator(
              color: AppTheme.primaryDark,
              onRefresh: _refreshProfile,
              child: _profile.addresses.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120, height: 120,
                                decoration: const BoxDecoration(color: AppTheme.surfaceMuted, shape: BoxShape.circle),
                                child: const Icon(Icons.location_off_outlined, size: 56, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 24),
                              const Text('No saved addresses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppTheme.textMain)),
                              const SizedBox(height: 8),
                              const Text('Add one now to speed up checkout', style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: _profile.addresses.length,
                      itemBuilder: (_, i) {
                        final address = _profile.addresses[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: address.isDefault ? AppTheme.primaryLight.withOpacity(0.3) : AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: address.isDefault ? AppTheme.primary : AppTheme.border.withOpacity(0.5),
                              width: address.isDefault ? 2 : 1,
                            ),
                            boxShadow: [AppTheme.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: address.isDefault ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceMuted,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      address.label.toLowerCase() == 'home' ? Icons.home_rounded : 
                                      address.label.toLowerCase() == 'work' ? Icons.work_rounded : Icons.location_on_rounded,
                                      color: address.isDefault ? AppTheme.primaryDark : AppTheme.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(address.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textMain)),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('Default', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                                    ),
                                  ],
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted),
                                    onSelected: (value) {
                                      if (value == 'default') _setDefault(address.id);
                                      if (value == 'delete') _delete(address.id);
                                    },
                                    itemBuilder: (_) => [
                                      if (!address.isDefault)
                                        const PopupMenuItem(value: 'default', child: Text('Set as default', style: TextStyle(fontWeight: FontWeight.w600))),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(address.line, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.textMuted, height: 1.5)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
