import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project2/src/auth/domain/entities/user.dart';
import 'package:project2/src/auth/domain/repos/auth_repo.dart';
import 'package:project2/src/auth/domain/use_cases/sign_in.dart';

import 'mock_auth_repo.dart';

void main() {
  late SignIn signIn;
  late AuthRepo authRepo;

  setUp(() {
    authRepo = MockAuthRepo();
    signIn = SignIn(authRepo);
  });
  const tUser = LocalUser.empty();

  test('should return localUser from the  auth repo ', () async {
    when(() => authRepo.signIn(
            email: any(named: 'email'), password: any(named: 'password'),),)
        .thenAnswer((_) async => const Right(tUser));
    final result = await signIn(const SignInParams.empty());
    expect(result, const Right<dynamic, LocalUser>(tUser));
    verify(
      () => authRepo.signIn(
        email: const SignInParams.empty().email,
        password: const SignInParams.empty().password,
      ),
    ).called(1);
    verifyNoMoreInteractions(authRepo);
  });
}
