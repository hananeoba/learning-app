import 'package:dartz/dartz.dart';
import 'package:project2/core/enums/update_user.dart';
import 'package:project2/core/errors/exceptions.dart';
import 'package:project2/core/errors/failure.dart';
import 'package:project2/core/utils/typedefs.dart';
import 'package:project2/src/auth/data/datasources/auth_remote_data_src.dart';
import 'package:project2/src/auth/domain/entities/user.dart';
import 'package:project2/src/auth/domain/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  const AuthRepoImpl(this._remoteDataSrc);
  final AuthRemoteDataSrc _remoteDataSrc;

  @override
  ResultFuture<void> forgotPassword(String email) async {
    try {
      await _remoteDataSrc.forgetPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSrc.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<LocalUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await _remoteDataSrc.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateUserData(
      {required updateUserAction action, dynamic userData,}) async {
    try {
      final user = await _remoteDataSrc.updateUser(
        action: action,
        data: userData,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
