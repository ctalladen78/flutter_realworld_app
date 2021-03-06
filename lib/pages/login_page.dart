import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_realworld_app/actions.dart';
import 'package:flutter_realworld_app/generated/i18n.dart';
import 'package:flutter_realworld_app/models/app_state.dart';
import 'package:flutter_realworld_app/pages/main_page.dart';
import 'package:flutter_realworld_app/util.dart' as util;
import 'package:flutter_redurx/flutter_redurx.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    final _emailFocus = FocusNode();
    final _pwFocus = FocusNode();
    
    final logo = Container(
      alignment: Alignment.center,
      child: Text(
        "conduit",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 48),
      ),
    );

    final email = TextFormField(
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: false,
      decoration: InputDecoration(
          hintText: S.of(context).email,
          hintStyle: TextStyle(color: Colors.black45),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white),
      onSaved: (value) {
        _email = value;
      },
      onFieldSubmitted: (term) {
        _fieldFocusChange(context, _emailFocus, _pwFocus);
      },
    );

    final password = TextFormField(
        focusNode: _pwFocus, 
        autofocus: true,
        obscureText: true,
        decoration: InputDecoration(
            hintText: S.of(context).password,
            hintStyle: TextStyle(color: Colors.black45),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white),
        onSaved: (value) {
          _password = value;
        },
        onFieldSubmitted: (value) {
          _pwFocus.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });

    final loginButton = RaisedButton(
      color: Theme.of(context).accentColor,
      child: Text(S.of(context).login),
      onPressed: () {
        _formKey.currentState.save();
        if (util.isNullEmpty(_email) || util.isNullEmpty(_password)) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                    title: Text(S.of(context).notEmpty),
                    content:
                        Text(S.of(context).emailAndPasswordShouldNotBeEmpty),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(S.of(context).ok),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ));
        } else {
          util.startLoading(context);
          Provider.dispatch<AppState>(
              context,
              AuthLogin(_email, _password, successCallback: () {
                util.finishLoading(context);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            MainPage(MainPageType.GLOBAL_FEED)),
                    ModalRoute.withName('/'));
                util.flushbar(context, S.of(context).loginSuccessfulTitle,
                    S.of(context).loginSuccessful);
              }, errorHandler: (err) {
                util.finishLoading(context);
                util.errorHandle(err, context);
              }));
        }
      },
    );

    final newUserButton = FlatButton(
      child: Text(
        S.of(context).createANewUser,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed("/register");
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(S.of(context).login),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: logo,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: email,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: password,
              ),
              loginButton,
              newUserButton
            ],
          ),
        ),
      ),
    );
  }

   _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
