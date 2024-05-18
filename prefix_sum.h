#include <stdint.h>
#include <stdio.h>

void prefix_by_cpu(int32_t* input, ssize_t n, int32_t* output);
void prefix_by_cuda(int32_t* input, ssize_t n, int32_t* output);
void prefix_by_cuda_unified(int32_t* input, ssize_t n, int32_t* output);