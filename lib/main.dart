import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/services/chat_bot_service.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/all_messages_vm.dart';

import 'package:flutter_app/theme.dart'; 
import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';


Future<void> main() async {
   //WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Defer the first frame until `FlutterNativeSplash.remove()` is called
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Make sure you have your Firebase options configured
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const materialTheme = MaterialTheme(TextTheme()); 

    return MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
        ChangeNotifierProvider<ChatBot>(
          create: (_) => ChatBot(),
        ),
        ChangeNotifierProxyProvider0<AllMessagesViewModel>(
          create: (BuildContext context) => AllMessagesViewModel(chatService: Provider.of<ChatBot>(context, listen: false)),
          update: (BuildContext context, A) => AllMessagesViewModel(chatService: Provider.of<ChatBot>(context, listen: false)),
        ),
      ],
      child: MaterialApp.router(
        theme: materialTheme.light(), //Apply the light theme
        // darkTheme: materialTheme.dark(), //Apply the dark theme
        routerConfig: routerConfig,
        restorationScopeId: 'app',
      ),
    );
  }
}
