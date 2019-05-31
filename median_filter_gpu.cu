#include <stdio.h>
extern "C"{
#include "bmp.h"
}
BMPFile* bmp_img; 
unsigned char* host_img_in_data;
unsigned char* host_img_out_data; 
unsigned char* host_test_data; 
int blockSize;

__device__ void _getMask(unsigned char* mask, unsigned char* image_data, int width, int x, int y)
{
	int mask_index = 0; 
	for(int i = x - 1; i < x + 2; i++)
	{
		for(int j = y - 1; j < y + 2; j++)
		{
			mask[mask_index++] = image_data[i * width + j];
		}
	}
}

__device__ void _sort(unsigned char* mask){
	unsigned char temp;
	for(int i = 0; i < sizeof(mask); i++){
		for(int j = 0; j < sizeof(mask); j++){
			if(mask[j] > mask[j+1]){
				temp = mask[j+1]; 
				mask[j+1] = mask[i];
				mask[j] = temp; 
			}
		}
	}
}

void prologue()
{
	host_test_data = (unsigned char*)malloc(sizeof(bmp_img->data)); 
	cudaMalloc((void**)&host_img_in_data, sizeof(bmp_img->data)); 
	cudaMemcpy(host_img_in_data, bmp_img->data, sizeof(bmp_img->data), cudaMemcpyHostToDevice);	
	
	cudaMalloc((void**)&host_img_out_data, sizeof(bmp_img->data)); 
	//cudaMemcpy(host_img_out_data, bmp_img->data, sizeof(bmp_img->data), cudaMemcpyHostToDevice);	
}

void epilogue()
{
	//cudaMemcpy(bmp_img->data, host_img_out_data, sizeof(bmp_img->data), cudaMemcpyDeviceToHost); 
	cudaMemcpy(host_test_data, host_img_out_data, sizeof(bmp_img->data), cudaMemcpyDeviceToHost); 
	cudaFree(host_img_out_data);
	cudaFree(host_img_in_data);
}

void _printPixelVals(unsigned char* image_data, int width, int height)
{
	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			printf("Img(%d, %d): %02x\n", i, j, image_data[i * height  +j]);
		}
	}
}

__global__ void _applyFilter(unsigned char* host_img_in_data, unsigned char* host_img_out_data, int width, int height)
{
	int i = blockIdx.x * blockDim.x +threadIdx.x; 
	int j = blockIdx.y * blockDim.y + threadIdx.y; 

	unsigned char mask[9]; 
	
	if((i != 0) && (j != 0) && (i != width - 1) && (j != height - 1))
	{
		_getMask(mask, host_img_in_data, width, i, j);
		_sort(mask);
		host_img_out_data[i * width + j] = mask[4]; 	
	}
	else 
	{
		host_img_out_data[j * width + i] =  0; 
	}
}

int main(int argc, char **argv)
{
	FILE *fIn, *fOut; 
	struct cudaDeviceProp prop;
	cudaError_t res; 

	res = cudaGetDeviceProperties(&prop, 0); 
	if(cudaSuccess != res)
	{
		printf("Loading device properties failed \n");
		exit(1); 
	}

	blockSize = prop.maxThreadsPerBlock; 

	fIn = fopen("indeks.bmp", "rb");
	bmp_img = read_bmp(fIn); 
	fclose(fIn); 
	
	fOut = fopen("out_gpu.bmp", "wb");

	dim3 threadsPerBlock(1024, 1024); 
	prologue(); 
	_applyFilter<<<1, threadsPerBlock>>>(host_img_in_data, host_img_out_data, bmp_img->header.width_px, bmp_img->header.height_px);	
	cudaThreadSynchronize();
	

	epilogue(); 
	//_printPixelVals(bmp_img->data, bmp_img->header.width_px, bmp_img->header.height_px); 
	bmp_img->data = host_test_data; 
	write_bmp(bmp_img, fOut); 
	fclose(fOut); 
	free_bmp(bmp_img); 
	return 0; 
}
