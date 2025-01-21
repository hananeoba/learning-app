import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project2/core/errors/exceptions.dart';
import 'package:project2/src/onboarding/data/datasource/onboarding_local_datasrc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SharedPreferences prefs;
  late OnboardingLocalDataSrcImpl localDatasrcImpl;

  setUp(() {
    prefs = MockSharedPreferences();
    localDatasrcImpl = OnboardingLocalDataSrcImpl(prefs);
  });

  group('cacheFirstTimer', () {
    test('should call [SharedPreferences] to cache the data', () async {
      when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);

      await localDatasrcImpl.cacheFirstTimer();

      verify(() => prefs.setBool(kFirstTimerKey, false)).called(1);

      verifyNoMoreInteractions(prefs);
    });

    test('should throw a cache exception when an error in caching data',
        () async {
      when(() => prefs.setBool(any(), any())).thenThrow(Exception());

      final methodCall = localDatasrcImpl.cacheFirstTimer;
      expect(
        methodCall,
        throwsA(
          isA<CacheExceptions>(),
        ),
      );

      verify(() => prefs.setBool(kFirstTimerKey, false)).called(1);

      verifyNoMoreInteractions(prefs);
    });
  });

  group('isFirstTime ', () {
    test(
        'should call [SharedPreferences] to check user is FirstTime '
        'and return the right response from storage when data exists',
        () async {
      when(() => prefs.getBool(any())).thenReturn(false);

      final result = await localDatasrcImpl.isFirstTime();
      expect(result, false);
      verify(() => prefs.getBool(kFirstTimerKey)).called(1);

      verifyNoMoreInteractions(prefs);
    });

    test('should return true if there is no data cached in storage', () async {
      when(() => prefs.get(any())).thenReturn(null);

      final result = await localDatasrcImpl.isFirstTime();
      expect(result, true);
      verify(() => prefs.getBool(kFirstTimerKey)).called(1);

      verifyNoMoreInteractions(prefs);
    });

    test('should throw a cache exception when an error in caching data',
        () async {
      when(() => prefs.getBool(any())).thenThrow(Exception());

      final methodCall = localDatasrcImpl.isFirstTime;
      expect(
        methodCall,
        throwsA(
          isA<CacheExceptions>(),
        ),
      );

      verify(() => prefs.getBool(kFirstTimerKey)).called(1);

      verifyNoMoreInteractions(prefs);
    });
  });
}
