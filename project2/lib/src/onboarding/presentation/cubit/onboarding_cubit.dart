import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:project2/src/onboarding/domain/use_cases/cache_first_timer.dart';
import 'package:project2/src/onboarding/domain/use_cases/is_first_time.dart';

part 'onboarding_cubit_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(
      {required CacheFirstTimer cacheFirstTimer,
      required IsFirstTime isFirstTime,})
      : _cacheFirstTimer = cacheFirstTimer,
        _isFirstTime = isFirstTime,
        super(const OnBoardingInitial());

  final CacheFirstTimer _cacheFirstTimer;
  final IsFirstTime _isFirstTime;

  Future<void> cacheFirstTimer() async {
    final result = await _cacheFirstTimer();
    emit(const CachingFirstTimer());
    result.fold(
      (failure) => emit(OnboardingError(message: failure.message)),
      (_) => emit(const UserCached()),
    );
  }

  Future<void> isFirstTime() async {
    emit(const CheckingIsFirstTimer());
    final result = await _isFirstTime();
    result.fold(
      (failure) => emit(const OnBoardingStatus(isFirstTime: true)),
      (status) => emit(OnBoardingStatus(isFirstTime: status)),
    );
  }
}
