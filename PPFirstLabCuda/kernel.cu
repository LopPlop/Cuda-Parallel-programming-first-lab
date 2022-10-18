#include <device_launch_parameters.h>
#include <cuda_runtime.h>

#include <cstdio>
#include<omp.h>

#define _CRT_SECURE_NO_WARNINGS

// Функция возведения в степень
__device__ long long Pow(long long num, int degree) {

    if (degree < 0)                // Ф-ция не предусматривает возведения в отрицательную степень
        return 1;

    if (degree == 0)
        return 1;

    long long tmp = num;
    for (int i = 0; i < degree - 1; i++)
        tmp *= num;
    return tmp;
}

// Функция нахождения произведения десятичных разрядов числа
__device__ long long GetMultiplicationOfDigit(long long num) {
    long long tmp = num;
    long long _tmp = num;
    int cnt = 0;
    long long multiplication = 1;

    while (tmp > 1) {
        tmp /= 10;
        cnt++;
    }

    while (cnt > -1) {
        tmp = _tmp;
        _tmp = tmp / Pow(10, cnt);

        if (_tmp != 0)
            multiplication *= _tmp;
        _tmp = tmp % Pow(10, cnt);
        cnt--;
    }

    return multiplication;
}

// Занимается поиском степени, если не найдена, возвращается 0
__device__ int FindDegree(float num) {
    int tmp;
    for (int i = 2; i < 9; i++) {
        float a = 1.0 / (float)i;
        tmp = (int)powf(num, a);
        if (num == powf(tmp, (float)i)) return i;
    }
    return 0;
}

__global__ void CudaCalculations(long long N_) {
    long long N = N_ + threadIdx.x + 1;
    int tmp = 0;
        tmp = FindDegree(GetMultiplicationOfDigit(N));
        if (tmp != 0) {
            printf("Decision: degree - %d\nnumber - %lld; ", tmp, N);
            return;
        }
}

__global__ void CudaCalculations1(long long N) {
    long long _num = N + 1;

    while (1) {
        _num++;
        if (FindDegree(GetMultiplicationOfDigit(_num)) != 0) {
            printf("Decision: degree - %d, number - %d; ", FindDegree(GetMultiplicationOfDigit(_num)), _num);
            return;
        }
    }
}


int main(int args, const char* argv[]) {
    cudaEvent_t start, stop;
    float gpuTime = 0.0;
    long long N;
    printf("Enter N: ");
    scanf("%lld", &N);

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    //CudaCalculations <<<1, 1>>> (N);
    CudaCalculations1 << <1, 1 >> > (N);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&gpuTime, start, stop);

    printf("Time: %f; ", gpuTime);

    return 0;
}
