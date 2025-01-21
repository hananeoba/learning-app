import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project2/core/enums/update_user.dart';
import 'package:project2/core/errors/exceptions.dart';
import 'package:project2/core/errors/failure.dart';
import 'package:project2/src/auth/data/datasources/auth_remote_data_src.dart';
import 'package:project2/src/auth/data/models/local_user_model.dart';
import 'package:project2/src/auth/data/repos/auth_repo_impl.dart';
import 'package:project2/src/auth/domain/entities/user.dart';

class MockAuthRemoteDataSrc extends Mock implements AuthRemoteDataSrc {}

void main() {
  late AuthRepoImpl authRepoImpl;
  late AuthRemoteDataSrc datasrc;

  setUp(() {
    datasrc = MockAuthRemoteDataSrc();
    authRepoImpl = AuthRepoImpl(datasrc);
    registerFallbackValue(updateUserAction.bio);
  });

  group('forgotPassword', () {
    const tEmail = 'test@example.com';

    test('should return void when the call to remote data source is successful',
        () async {
      // arrange
      when(() => datasrc.forgetPassword(any()))
          .thenAnswer((_) async => const Right(null));
      // act
      final result = await authRepoImpl.forgotPassword(tEmail);
      // assert
      expect(result, const Right(null));
      verify(() => datasrc.forgetPassword(tEmail)).called(1);
      verifyNoMoreInteractions(datasrc);
    });

    test(
        'should return ServerFailure when the call to remote data '
        'source is unsuccessful', () async {
      // arrange
      when(() => datasrc.forgetPassword(any())).thenThrow(
        const ServerException(message: 'Error', statusCode: '500'),
      );
      // act
      final result = await authRepoImpl.forgotPassword(tEmail);
      // assert
      expect(
        result,
        Left<Failure, void>(
          ServerFailure(message: 'Error', statusCode: '500'),
        ),
      );
      verify(() => datasrc.forgetPassword(tEmail)).called(1);
      verifyNoMoreInteractions(datasrc);
    });
  });

  group('signIn', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tUser = LocalUserModel(
        uid: '1', email: tEmail, fullName: 'Test User', points: 0,);

    test('should return user when the call to remote data source is successful',
        () async {
      // arrange
      when(() => datasrc.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),),).thenAnswer((_) async => tUser);
      // act
      final result =
          await authRepoImpl.signIn(email: tEmail, password: tPassword);
      // assert
      expect(result, const Right(tUser));
      verify(() => datasrc.signIn(email: tEmail, password: tPassword))
          .called(1);
      verifyNoMoreInteractions(datasrc);
    });

    test(
        'should return ServerFailure when the call to remote data source is unsuccessful',
        () async {
      // arrange
      when(() => datasrc.signIn(
              email: any(named: 'email'), password: any(named: 'password'),),)
          .thenThrow(
              const ServerException(message: 'Error', statusCode: '500'),);
      // act
      final result =
          await authRepoImpl.signIn(email: tEmail, password: tPassword);
      // assert
      expect(
          result,
          Left<Failure, LocalUser>(
              ServerFailure(message: 'Error', statusCode: '500'),),);
      verify(() => datasrc.signIn(email: tEmail, password: tPassword))
          .called(1);
      verifyNoMoreInteractions(datasrc);
    });
  });

  group('signUp', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tFullName = 'Test User';
    const tUser =
        LocalUserModel(uid: '1', email: tEmail, fullName: tFullName, points: 0);

    test('should return user when the call to remote data source is successful',
        () async {
      // arrange
      when(() => datasrc.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),),).thenAnswer((_) async => tUser);
      // act
      final result = await authRepoImpl.signUp(
          email: tEmail, password: tPassword, fullName: tFullName,);
      // assert
      expect(result, const Right(tUser));
      verify(() => datasrc.signUp(
          email: tEmail, password: tPassword, fullName: tFullName,),).called(1);
      verifyNoMoreInteractions(datasrc);
    });

    test(
        'should return ServerFailure when the call to remote data source is unsuccessful',
        () async {
      // arrange
      when(() => datasrc.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),),)
          .thenThrow(
              const ServerException(message: 'Error', statusCode: '500'),);
      // act
      final result = await authRepoImpl.signUp(
          email: tEmail, password: tPassword, fullName: tFullName,);
      // assert
      expect(
          result,
          Left<Failure, LocalUser>(
              ServerFailure(message: 'Error', statusCode: '500'),),);
      verify(() => datasrc.signUp(
          email: tEmail, password: tPassword, fullName: tFullName,),).called(1);
      verifyNoMoreInteractions(datasrc);
    });
  });

  group('updateUserData', () {
    const tAction = updateUserAction.bio;
    const tUserData = 'newemail@example.com';

    test('should return void when the call to remote data source is successful',
        () async {
      // arrange
      when(() => datasrc.updateUser(
          action: any(named: 'action'),
          data: any(named: 'data'),),).thenAnswer((_) async => Future.value());
      // act
      final result = await authRepoImpl.updateUserData(
          action: tAction, userData: tUserData,);
      // assert
      expect(result, const Right(null));
      verify(() => datasrc.updateUser(action: tAction, data: tUserData))
          .called(1);
      verifyNoMoreInteractions(datasrc);
    });

    test(
        'should return ServerFailure when the call to remote data source is unsuccessful',
        () async {
      // arrange
      when(() => datasrc.updateUser(
              action: any(named: 'action'), data: any(named: 'data'),),)
          .thenThrow(
              const ServerException(message: 'Error', statusCode: '500'),);
      // act
      final result = await authRepoImpl.updateUserData(
          action: tAction, userData: tUserData,);
      // assert
      expect(
          result,
          Left<Failure, void>(
          ServerFailure(message: 'Error', statusCode: '500'),
        ),
      );
      verify(() => datasrc.updateUser(action: tAction, data: tUserData))
          .called(1);
      verifyNoMoreInteractions(datasrc);
    });
  });
}
