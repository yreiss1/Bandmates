import 'package:flutter/material.dart';
import 'PageViewModels.dart';

class IntroPage extends StatelessWidget {
  final PageViewModels page;
  final bool scroll;

  const IntroPage({Key key, @required this.page, this.scroll})
      : super(key: key);

  Widget _buildWidget(Widget widget, String text, TextStyle style) {
    return widget ?? Text(text, style: style, textAlign: TextAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: SingleChildScrollView(
                  physics: this.scroll
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 48.0),
                        _buildWidget(
                          null,
                          page.title,
                          TextStyle(
                              fontFamily: "Montserrat-Bold",
                              fontSize: 20,
                              color: Color(0xFF404040)),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        const SizedBox(height: 24.0),
                        _buildWidget(
                          page.bodyWidget,
                          null,
                          TextStyle(),
                        ),
                        if (page.footer != null) const SizedBox(height: 24.0),
                        if (page.footer != null) page.footer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
