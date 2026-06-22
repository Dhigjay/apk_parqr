import 'package:flutter/material.dart';

enum ConfirmationDialogType { approve, reject }

class ConfirmationDialog extends StatelessWidget {
  final ConfirmationDialogType type;
  final String title;
  final String message;
  final TextEditingController? reasonController;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.reasonController,
  });

  static Future<bool?> showApprove(BuildContext context, {required String businessName}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        type: ConfirmationDialogType.approve,
        title: 'Setujui Pengajuan',
        message: 'Anda akan menyetujui pengajuan dari "$businessName". Akun operator akan dibuat dan email dikirimkan. Lanjutkan?',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  static Future<String?> showReject(BuildContext context, {required String businessName}) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        type: ConfirmationDialogType.reject,
        title: 'Tolak Pengajuan',
        message: 'Anda akan menolak pengajuan dari "$businessName". Wajib mengisi alasan penolakan.',
        reasonController: reasonCtrl,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed == true && reasonCtrl.text.trim().isNotEmpty) {
      return reasonCtrl.text.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isReject = type == ConfirmationDialogType.reject;
    final confirmColor = isReject ? Colors.redAccent : const Color(0xFF00D68F);
    final confirmLabel = isReject ? 'Tolak' : 'Setujui';

    return AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF8B949E))),
          if (isReject && reasonController != null) ...[
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                filled: true,
                fillColor: const Color(0xFF1C232C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2A3441)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2A3441)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal', style: TextStyle(color: Color(0xFF8B949E))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onConfirm,
          child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
