import 'package:flutter/material.dart';

class DialogActionRow extends StatelessWidget {
  const DialogActionRow({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.isDestructive = false,
    super.key,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final confirmStyle = isDestructive
        ? FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          )
        : null;

    return SizedBox(
      width: 232,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onCancel,
              child: Text(cancelLabel),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              style: confirmStyle,
              onPressed: onConfirm,
              child: Text(
                confirmLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
