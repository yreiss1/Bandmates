import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class InfoSelection extends StatelessWidget {
  final SwiperController swiperController;
  final Map<dynamic, dynamic> userData;

  final TextEditingController _nametextEditingController =
      TextEditingController();
  final TextEditingController _bioEditingController = TextEditingController();

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  InfoSelection({this.swiperController, this.userData});

  @override
  Widget build(BuildContext context) {
    FocusNode _descFocus = new FocusNode();

    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Who are you?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _nametextEditingController,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocus),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: new InputDecoration(
                          labelText: "Your Name",
                          focusColor: Theme.of(context).primaryColor,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          hintText: "Enter your Name",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Name cannot be empty';
                          }

                          if (value.length <= 3) {
                            return 'Name must be longer than 3 characters';
                          }

                          userData['name'] = value;

                          return null;
                        },
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: _bioEditingController,
                        focusNode: _descFocus,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        decoration: new InputDecoration(
                          labelText: "Your Bio",
                          focusColor: Theme.of(context).primaryColor,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          hintText: "Who are you? What are you looking for?",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Your bio cannot be empty';
                          }

                          if (value.length <= 6) {
                            return 'Bio must be longer than 6 characters';
                          }

                          userData['bio'] = value;

                          return null;
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton.icon(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.keyboard_arrow_down),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(50)),
                  label: Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  onPressed: () {
                    if (_bioEditingController.text.isEmpty &&
                        !_descFocus.hasFocus) {
                      FocusScope.of(context).requestFocus(_descFocus);
                      return;
                    }
                    FocusScope.of(context).unfocus();

                    if (_formKey.currentState.validate()) {
                      swiperController.next();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
