#include <stdint.h>
#include <stdio.h>

#define BLOCK_SIZE 10
uint32_t power_of_2(uint32_t val)
{
	if ((val & (val - 1)) == 0) {
		return val;
	}
	uint32_t andv = 0x80000000;

	while ((andv & val) == 0) {
		andv >>= 1;
	}

	return andv << 1;
}

__device__ uint32_t power_of_2_d(uint32_t val)
{
	if ((val & (val - 1)) == 0) {
		return val;
	}
	uint32_t andv = 0x80000000;

	while ((andv & val) == 0) {
		andv >>= 1;
	}

	return andv << 1;
}

__global__ void work_efficient_scan_kernel(int32_t* X, ssize_t InputSize,
                                           int32_t* Y)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	for (ssize_t stride = 2; stride <= InputSize; stride *= 2) {
		__syncthreads();
		if (i > 0 && i % stride == (stride - 1) && i < InputSize) {
			X[i] += X[i - stride / 2];
		}
	}

	for (ssize_t stride = InputSize; stride >= 1; stride /= 2) {
		__syncthreads();

		if (i < InputSize && ((i + 1) % stride) == 0 &&
		    ((i + 1) % (stride * 2)) != 0 && power_of_2_d(i + 1) != i + 1) {

			int32_t sum = 0;
			ssize_t pos = 0;

			for (int x = InputSize; x > 0; x >>= 1) {
				if ((x & (i + 1)) != 0) {
					sum += X[x + pos - 1];
					pos += x;
				}
			}

			X[i] = sum;
		}
	}

	__syncthreads();
	if (i < InputSize) {
		Y[i] = X[threadIdx.x];
	}
}

void prefix_by_cuda(int32_t* input, ssize_t n, int32_t* output)
{

	int32_t *indev, *outdev;
	uint32_t power = power_of_2(n);

	printf("power=%u\n", power);
	cudaMalloc(&indev, sizeof(int32_t) * power);
	cudaMalloc(&outdev, sizeof(int32_t) * n);

	cudaMemcpy(indev, input, sizeof(int32_t) * n, cudaMemcpyHostToDevice);
	cudaMemset(indev + n, 0, power - n);

	work_efficient_scan_kernel<<<64, 64>>>(indev, power, outdev);

	cudaMemcpy(output, outdev, sizeof(int32_t) * n, cudaMemcpyDeviceToHost);

	cudaFree(indev);
	cudaFree(outdev);
}