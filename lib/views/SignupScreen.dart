import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../AuthService.dart';
import '../Utils.dart';

class SignupScreen extends StatelessWidget {
  static final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>(debugLabel: "SignupScreen");

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _pass1FocusNode = FocusNode();
  FocusNode _pass2FocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 26,
            ),
            Container(
              margin: EdgeInsets.only(left: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "Hey, get on board",
                    style: TextStyle(
                      fontFamily: 'Montserrat-Medium',
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Sign up to continue",
                    style: TextStyle(
                        fontFamily: 'Montserrat', color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.only(bottom: 20, top: 20, left: 26, right: 26),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: ListView(
                  children: <Widget>[
                    FormBuilder(
                      key: _fbKey,
                      initialValue: {},
                      autovalidate: false,
                      child: Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            focusNode: _emailFocusNode,
                            onFieldSubmitted: (val) {
                              FocusScope.of(context)
                                  .requestFocus(_pass1FocusNode);
                            },
                            attribute: 'email',
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                labelText: "Email",
                                hintText: 'you@example.com'),
                            validators: [
                              FormBuilderValidators.email(),
                              FormBuilderValidators.required()
                            ],
                          ),
                          FormBuilderTextField(
                            focusNode: _pass1FocusNode,
                            onFieldSubmitted: (val) {
                              FocusScope.of(context)
                                  .requestFocus(_pass2FocusNode);
                            },
                            attribute: 'password',
                            maxLines: 1,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                            ),
                            validators: [
                              FormBuilderValidators.minLength(6),
                              FormBuilderValidators.required()
                            ],
                          ),
                          FormBuilderTextField(
                            focusNode: _pass2FocusNode,
                            maxLines: 1,
                            onFieldSubmitted: (_) =>
                                Focus.of(context).unfocus(),
                            attribute: 'confirm-password',
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              labelText: "Confirm Password",
                            ),
                            validators: [
                              FormBuilderValidators.required(),
                              (val) {
                                if (_fbKey.currentState.fields['password']
                                        .currentState.value !=
                                    val) {
                                  return "Passwords must be identical";
                                }
                              }
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  print("They forgot their passwords!!");
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      fontFamily: "Montserrat-Medium",
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                          FormBuilderCheckbox(
                            leadingInput: true,
                            activeColor: Theme.of(context).primaryColor,
                            attribute: 'logged_in',
                            label: Text(
                                "By signing up you agree to our Terms & Conditions and privacy policy"),
                            validators: [FormBuilderValidators.required()],
                          ),
                          SizedBox(
                            height: 34,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FlatButton(
                                splashColor: Colors.white,
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                child: Text("SIGN UP"),
                                onPressed: () async {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    print(_fbKey.currentState.value);
                                    try {
                                      FirebaseUser result =
                                          await Provider.of<AuthService>(
                                                  context,
                                                  listen: false)
                                              .signUp(
                                                  email: _fbKey.currentState
                                                      .value["email"],
                                                  password: _fbKey.currentState
                                                      .value["password"],
                                                  context: context);

                                      print(result);
                                    } on AuthException catch (error) {
                                      Utils.buildErrorDialog(
                                          context, error.message);
                                    } on Exception catch (error) {
                                      Utils.buildErrorDialog(
                                          context, error.toString());
                                    }
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                          Padding(
                            child: Text("- Or you can also -"),
                            padding: EdgeInsets.all(20),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlineButton(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  new Image.asset('assets/icons/facebook.png',
                                      height: 20, width: 20),
                                  Text("SIGN UP WITH FACEBOOK"),
                                ],
                              ),
                              textColor: Colors.black87,
                              onPressed: () {
                                print("Sign up with Facebook!");
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
