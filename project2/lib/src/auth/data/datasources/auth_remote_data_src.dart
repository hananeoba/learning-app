import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:project2/core/enums/update_user.dart';
import 'package:project2/core/errors/exceptions.dart';
import 'package:project2/core/utils/constants.dart';
import 'package:project2/core/utils/typedefs.dart';
import 'package:project2/src/auth/data/models/local_user_model.dart';

abstract class AuthRemoteDataSrc {
  const AuthRemoteDataSrc();

  Future<LocalUserModel> signIn({
    required String email,
    required String password,
  });
  Future<void> updateUser({
    required updateUserAction action,
    dynamic data,
  });
  Future<LocalUserModel> signUp({
    required String email,
    required String fullName,
    required String password,
  });
  Future<void> forgetPassword(String email);
}

class AuthRemoteDataSrcImpl extends AuthRemoteDataSrc {
  const AuthRemoteDataSrcImpl({
    required FirebaseFirestore cloudStoreClient,
    required FirebaseAuth authClient,
    required FirebaseStorage datebase,
  })  : _authClient = authClient,
        _cloudStoreClient = cloudStoreClient,
        _dbClient = datebase;

  final FirebaseAuth _authClient;
  final FirebaseFirestore _cloudStoreClient;
  final FirebaseStorage _dbClient;

  @override
  Future<void> forgetPassword(String email) async {
    try {
      await _authClient.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error occured ',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ServerException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<LocalUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authClient.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) {
        throw const ServerException(
          message: 'Please try again later',
          statusCode: 'Unknown error',
        );
      }
      var userData = await _getUserData(user.uid);
      if (userData.exists) {
        return LocalUserModel.fromMap(userData.data()!);
      }
      await _setUserData(user, email);
      userData = await _getUserData(user.uid);
      return LocalUserModel.fromMap(userData.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error occured ',
        statusCode: e.code,
      );
    } on ServerException catch (_) {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ServerException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<LocalUserModel> signUp({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final userCred = await _authClient.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user?.updateDisplayName(fullName);
      await userCred.user?.updatePhotoURL(kDefaultAvatar);

      await _setUserData(_authClient.currentUser!, email);
      return LocalUserModel(
        uid: userCred.user!.uid,
        email: email,
        fullName: fullName,
        points: 0,
        profilePic: kDefaultAvatar,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error occured ',
        statusCode: e.code,
      );
    } on ServerException catch (_) {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ServerException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> updateUser({
    required updateUserAction action,
    dynamic data,
  }) async {
    try {
      switch (action) {
        case updateUserAction.email:
          await _authClient.currentUser?.updateEmail(data as String);
          await _updateUserData({'email': data});
        case updateUserAction.fullName:
          await _authClient.currentUser?.updateDisplayName(data as String);
          await _updateUserData({'fullName': data});
        case updateUserAction.profilePic:
          final ref = _dbClient
              .ref()
              .child('profile_pics/${_authClient.currentUser?.uid}');
          await ref.putFile(data as File);
          final url = await ref.getDownloadURL();
          await _authClient.currentUser?.updatePhotoURL(url);
          await _updateUserData({'profilePic': url});

        case updateUserAction.password:
          if (_authClient.currentUser?.email == null) {
            throw const ServerException(
              message: 'User does not exist',
              statusCode: 'insuffitiant permission',
            );
          }
          final newData = jsonDecode(data as String) as DataMap;

          await _authClient.currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: _authClient.currentUser!.email!,
              password: newData['oldPassword'] as String,
            ),
          );

          await _authClient.currentUser?.updatePassword(
            newData['newPassword'] as String,
          );
        case updateUserAction.bio:
          await _updateUserData({'bio': data as String});
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error occured ',
        statusCode: e.code,
      );
    } on ServerException catch (_) {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ServerException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  Future<DocumentSnapshot<DataMap>> _getUserData(String uid) async {
    return _cloudStoreClient.collection('users').doc(uid).get();
  }

  Future<void> _setUserData(User user, String fallbackEmail) async {
    await _cloudStoreClient.collection('users').doc().set(
          LocalUserModel(
            uid: user.uid,
            email: user.email ?? fallbackEmail,
            fullName: user.displayName ?? '',
            points: 0,
            profilePic: user.photoURL ?? '',
          ).toMap(),
        );
  }

  Future<void> _updateUserData(DataMap data) async {
    await _cloudStoreClient
        .collection('users')
        .doc(_authClient.currentUser?.uid)
        .update(
          data,
        );
  }
}
