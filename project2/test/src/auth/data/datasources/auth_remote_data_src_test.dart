import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project2/src/auth/data/datasources/auth_remote_data_src.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFireStore extends Mock implements FirebaseFirestore {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late FirebaseAuth authClient;
  late FirebaseFirestore cloudStoreClient;
  late FirebaseStorage dbClient;
  late UserCredential userCredential;
  late AuthRemoteDataSrc dataSrc;

  setUp(() {
    authClient = MockFirebaseAuth();
    cloudStoreClient = MockFirebaseFireStore();
    dbClient = MockFirebaseStorage();
    dataSrc = AuthRemoteDataSrcImpl(
      authClient: authClient,
      cloudStoreClient: cloudStoreClient,
      datebase: dbClient,
    );
    userCredential = MockUserCredential();
  });
  group('SignIn', () {
    test('should complete successfully when call to server is successful ',
        () async {
      // arrange
      when(
        () => authClient.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => userCredential);
      // act
      final result = await dataSrc.signIn(
        email: 'email',
        password: 'password',
      );
      // assert
      expect(result.email, equals('email'));
    });
    test('', () {});
  });
}
