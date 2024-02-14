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
    return 
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(widget.title),
      content: TextFormField(
        autofocus: true,
        cursorColor: Colors.blue,
        controller: controller,
        onFieldSubmitted: widget.onEntered,
        decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          child: const Text(
            'キャンセル',
            style: TextStyle(color: Colors.blue)
            ),
        ),
        TextButton(
          onPressed: () => widget.onEntered(controller.text),
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.blue)
            ),
        ),
      ],
    );
  }
}