import 'package:demo_biometric/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool? _hasBioSensor;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  LocalAuthentication authentication = LocalAuthentication();

  Future<void> _checkBiometric() async {
    try {
      _hasBioSensor = await authentication.canCheckBiometrics;
      print(_hasBioSensor);
      if (_hasBioSensor!) {
        _getBioAuth();
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _getBioAuth() async {
    bool isAuth = false;
    try {
      isAuth = await authentication.authenticate(
        localizedReason: 'Scan your finger print to access the app.',
        biometricOnly: true,
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (isAuth) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
      print(isAuth);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  ///Authentication all method
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await authentication.authenticate(
        localizedReason: 'Let OS determine authentication method',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        if (e.code == 'NotAvailable') {
          _authorized =
              'Kata sandi / Biometric belum disetel pada perangkat anda.';
        } else {
          _authorized = "Error - ${e.code}";
        }
      });
      return;
    }
    if (!mounted) return;

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Page'),
      ),
      body: Container(
        child: Center(
          child: _isAuthenticating
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_authorized',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _authenticate();
                      },
                      child: Text('Autentifikasi Ulang'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
