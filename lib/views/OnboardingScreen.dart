import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/OnboardingScreens/GenreCapture.dart';
import 'package:jammerz/views/OnboardingScreens/InstrumentCapture.dart';
import 'package:jammerz/views/OnboardingScreens/QuestionsCapture.dart';
import 'package:jammerz/views/UI/IntroButton.dart';
import 'package:jammerz/views/UI/PageViewModels.dart';
import 'package:line_icons/line_icons.dart';
import './OnboardingScreens/ImageCapture.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import './UI/IntroPage.dart';
import 'dart:async';
import 'dart:math';
import 'package:jammerz/Utils.dart';
import '../models/user.dart';
import 'HomeScreen.dart';

final GlobalKey<FormBuilderState> genreKey = GlobalKey<FormBuilderState>();
final GlobalKey<FormBuilderState> instrumentKey = GlobalKey<FormBuilderState>();
final GlobalKey<FormBuilderState> personalKey = GlobalKey<FormBuilderState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Map<String, dynamic> _userData;

  int _currentPage;

  PageController _controller;
  bool _isScrolling = false;

  List<PageViewModels> _listPagesViewModel;
  @override
  void initState() {
    super.initState();

    _userData = {
      'name': "",
      'bio': "",
      'birthday': null,
      'transportation': false,
      'practice': false,
      'genres': [],
      'instruments': []
    };
    _currentPage = 0;

    _controller = PageController(initialPage: _currentPage, keepPage: true);

    _listPagesViewModel = [
      PageViewModels(
          bodyWidget: Text("Welcome to BandMates!!"),
          footer: null,
          title: "Welcome to your Bandmates!",
          scroll: false),
      PageViewModels(
          bodyWidget: QuestionsCapture(
            fbKey: personalKey,
            getInfo: getUserData,
          ),
          footer: null,
          title: "Your Profile",
          scroll: false),
      PageViewModels(
          bodyWidget: InstrumentCapture(
              getInstruments: getInstrumentsData, fbKey: instrumentKey),
          footer: null,
          title: "Your Intruments",
          scroll: true),
      PageViewModels(
          bodyWidget: GenreCapture(
            getGenres: getGenresData,
            fbKey: genreKey,
          ),
          footer: null,
          title: "You Genres",
          scroll: true),
    ];
  }

  getGenresData(List<dynamic> genres) {
    print('In OnboardingScreen' + genres.toString());
    setState(() {
      _userData['genres'] = genres;
    });
  }

  getInstrumentsData(List<dynamic> instruments) {
    print("In OnBoarding Screen: " + instruments.toString());
    setState(() {
      _userData['instruments'] = instruments;
    });
  }

  getUserData(String name, DateTime birthday, String bio, String gender,
      bool hasTransportation, bool hasPracticeSpace) {
    setState(() {
      _userData['name'] = name;
      _userData['birthday'] = birthday;
      _userData['bio'] = bio;
      _userData['gender'] = gender;
      _userData['transportation'] =
          hasTransportation == null ? false : hasTransportation;
      _userData['practice'] =
          hasPracticeSpace == null ? false : hasPracticeSpace;
      _userData['timestamp'] = null;
    });
  }

  void _onNext() {
    switch (_currentPage) {
      case 1:
        if (personalKey.currentState.validate()) {
          animateScroll(min(_currentPage + 1, _listPagesViewModel.length - 1));
        }
        break;
      case 2:
        if (instrumentKey.currentState.validate()) {
          animateScroll(min(_currentPage + 1, _listPagesViewModel.length - 1));
        }
        break;
      case 3:
        if (genreKey.currentState.validate()) {
          animateScroll(min(_currentPage + 1, _listPagesViewModel.length - 1));
        }
        break;
      default:
        animateScroll(min(_currentPage + 1, _listPagesViewModel.length - 1));
    }
  }

  void _onBack() {
    animateScroll(max(0, _currentPage - 1));
  }

  Future<void> animateScroll(int page) async {
    setState(() => _isScrolling = true);
    await _controller.animateToPage(
      page,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
    setState(() => _isScrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = (_currentPage == _listPagesViewModel.length - 1);
    final isFirstPage = (_currentPage == 0);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: _listPagesViewModel
                .map((p) => IntroPage(
                      page: p,
                      scroll: p.scroll,
                    ))
                .toList(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: isFirstPage
                        ? Opacity(
                            opacity: 0.0,
                            child: IntroButton(
                              child: Icon(LineIcons.arrow_left),
                              onPressed: () {},
                            ),
                          )
                        : IntroButton(
                            child: Icon(LineIcons.arrow_left),
                            onPressed: _onBack,
                          ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: DotsIndicator(
                        dotsCount: _listPagesViewModel.length,
                        position: _currentPage,
                        decorator: DotsDecorator(
                          activeColor: const Color(0xff53172c),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: isLastPage
                          ? IntroButton(
                              child: Icon(LineIcons.check),
                              onPressed: () {
                                User user = new User(
                                  uid: Utils.getUid(),
                                  email: Utils.getEmail(),
                                  birthday: _userData['birthday'],
                                  bio: _userData['bio'],
                                  name: _userData['name'],
                                  instruments: _userData['instruments'],
                                  gender: _userData['gender'],
                                  genres: _userData['genres'],
                                  transportation: _userData['transportation'],
                                  practiceSpace: _userData['practice'],
                                  created: DateTime.now(),
                                );
                                Utils.uploadUser(context, user);
                                var name = _userData['name'];
                                SnackBar snackBar = SnackBar(
                                  content: Text("Welcome $name!!"),
                                );
                                _scaffoldKey.currentState.showSnackBar(
                                  snackBar,
                                );
                                Timer(Duration(seconds: 2), () {
                                  Navigator.popAndPushNamed(
                                      context, HomeScreen.routeName);
                                });
                              },
                            )
                          : IntroButton(
                              child: Icon(LineIcons.arrow_right),
                              onPressed: !_isScrolling ? _onNext : null,
                            ))
                ],
              ),
            ),
          )
        ],
      ),
    );

/*
    Container(
      child: IntroductionScreen(
          onChange: (val) => {},
          pages: _listPagesViewModel,
          onDone: () {
            User user = new User(
                name: name,
                practiceSpace: hasPracticeSpace,
                transportation: hasTransportation,
                genres: genres,
                instruments: instruments,
                gender: gender,
                birthday: birthday,
                bio: bio);

            Utils.uploadUser(context, user);
            Navigator.popAndPushNamed(context, HomeScreen.routeName);
          },
          onSkip: () {
            // You can also override onSkip callback
          },
          showSkipButton: true,
          skip: const Text(
            "Skip",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          next: Icon(
            LineIcons.arrow_right,
          ),
          done: const Icon(
            LineIcons.check,
            color: const Color(0xff53172c),
          )),
    );
    */
  }
}
