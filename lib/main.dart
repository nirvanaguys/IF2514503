import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gqdwwgbtadvujqfidobf.supabase.co/rest/v1/',
    publishableKey: 'sb_publishable_UlXcwDH27IkEJ0cv4qqkLw_Odigwc2a',
  );

  runApp(const DaunKuApp());
}