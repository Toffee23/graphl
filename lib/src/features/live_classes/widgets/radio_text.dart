import 'package:vmodel/src/vmodel.dart';

class TextRadio<T> extends StatelessWidget {
  const TextRadio({
    super.key,
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });
  final String text;
  final T value;
  final T groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Radio(
                visualDensity: VisualDensity.compact,
                activeColor: Theme.of(context).iconTheme.color,
                value: value,
                groupValue: groupValue,
                onChanged: (val) {
                  onTap();
                }),
          ],
        ),
      ),
    );
  }
}
