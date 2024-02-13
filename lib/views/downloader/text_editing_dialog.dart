import 'package:flutter/material.dart';
class TextEditingDialog extends StatefulWidget {
  final String title;
  final String name;
  final Function(String) onEntered;
  const TextEditingDialog({
    Key? key, 
    required this.name, 
    required this.title, 
    required this.onEntered,
  }) : super(key: key);


  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // TextFormFieldに初期値を代入する
    controller.text = widget.name ?? '';
    focusNode.addListener(() {
        // フォーカスが当たったときに文字列が選択された状態にする
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextFormField(
        autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる
        focusNode: focusNode,
        controller: controller,
        onFieldSubmitted: widget.onEntered,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => widget.onEntered(controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}