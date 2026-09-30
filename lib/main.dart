import 'package:flutter/material.dart';
import 'models/profile.dart';
import 'ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profile = Profile();
  await profile.load();
  runApp(App(profile));
}

class App extends StatelessWidget {
  const App(this.profile, {super.key});
  final Profile profile;

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: b),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: profile,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Atrapa Gemas',
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: profile.dark ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(profile),
        ),
      );
}