#include "prefix_sum.h"

void show(int32_t* line, ssize_t n)
{
	for (ssize_t i = 0; i < n; i++) {
		printf("%3d", line[i]);
	}
	printf("\n");
}

int main(int argc, char** argv)
{
	int32_t input[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	int32_t output[10] = {0};

	memset(output, 0, sizeof(output));
	prefix_by_cpu(input, 10, output);
	show(input, 10);
	show(output, 10);

	printf("----------------------------------------\n");

	memset(output, 0, sizeof(output));
	prefix_by_cuda(input, 10, output);
	show(input, 10);
	show(output, 10);

	printf("----------------------------------------\n");

	memset(output, 0, sizeof(output));
	prefix_by_cuda_unified(input, 10, output);
	show(input, 10);
	show(output, 10);
	return 0;
}
