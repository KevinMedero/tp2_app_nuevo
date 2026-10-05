import 'package:flutter/material.dart';
import 'models/profile.dart';
import 'ui/home_page.dart';

/// Punto de entrada principal de la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Instancia y carga los datos del perfil guardados en SharedPreferences antes de lanzar la UI
  final profile = Profile();
  await profile.load();
  runApp(App(profile));
}

/// Widget raíz de la aplicación que administra el tema global y la navegación
class App extends StatelessWidget {
  const App(this.profile, {super.key});
  final Profile profile;

  // Genera el esquema de colores dinámico basado en Material 3 según el modo claro u oscuro
  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: b),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        // Escucha cambios en el perfil para conmutar dinámicamente entre tema claro y oscuro
        listenable: profile,
        builder: (_, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Atrapa Gemas',
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: profile.dark ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(profile),
        ),
      );
}