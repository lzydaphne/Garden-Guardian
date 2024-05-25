// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_app/models/user.dart';
// import 'package:flutter_app/repositories/user_repo.dart';

// class MeViewModel with ChangeNotifier {
//   final UserRepository _userRepository;
//   late StreamSubscription<User?> _meSubscription;

//   User? _me;
//   User? get me => _me;
//   bool _isInitializing = true;
//   bool get isInitializing => _isInitializing;
//   bool _isModeratorStatusChanged = false;
//   bool get isModeratorStatusChanged => _isModeratorStatusChanged;

//   MeViewModel(String userId, {UserRepository? userRepository})
//       : _userRepository = userRepository ?? UserRepository() {
//     _meSubscription = _userRepository.streamUser(userId).listen((me) {
//       if (me == null) {
//         return;
//       }

//       if (_me != null) {
//         _isModeratorStatusChanged = _me!.isModerator != me.isModerator;
//       }

//       _isInitializing = false;
//       _me = me;
//       notifyListeners();
//     });
//   }

//   @override
//   void dispose() {
//     _meSubscription.cancel();
//     super.dispose();
//   }

//   Future<void> addMe(User me) async {
//     await _userRepository.createOrUpdateUser(me);
//   }
// }
