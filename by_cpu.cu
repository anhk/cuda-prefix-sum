void prefix_by_cpu(int32_t* input, ssize_t n, int32_t* output)
{
	int32_t sum = 0;

	for (ssize_t i = 0; i < n; i++) {
		sum += input[i];
		output[i] = sum;
	}
}
