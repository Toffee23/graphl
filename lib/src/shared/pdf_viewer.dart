import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewer extends StatelessWidget {
  const PDFViewer({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: 'Brief Document',
      ),
      body: PDF().cachedFromUrl(
        url,
        placeholder: (progress) => Center(
            child: CircularProgressIndicator(
          value: progress / 100,
        )),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
