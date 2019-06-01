#include <stdio.h>

extern "C"{
#include "bmp.h"
}

BMPFile* bmp_img; 
unsigned char* host_img_in_data;
unsigned char* host_img_out_data; 
unsigned char* host_test_data;
unsigned char* host_test_data2;  
int blockSize;
int size = 1024 * 1024 * sizeof(char); 

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
	host_test_data = (unsigned char*)malloc(size); 
	host_test_data2 = (unsigned char*)malloc(size);
	host_test_data = bmp_img->data;  
	cudaMalloc((void**)&host_img_in_data, size); 
	cudaMemcpy(host_img_in_data, host_test_data,size, cudaMemcpyHostToDevice);	
	
	cudaError_t err; 
	cudaMalloc((void**)&host_img_out_data, size); 
	cudaMemcpy(host_img_out_data, bmp_img->data, size, cudaMemcpyHostToDevice);	
	err = cudaGetLastError();
	if (cudaSuccess != err)
	{
		printf("Prologue failed\n"); 
		exit(1);
	} 	
}

void epilogue()
{
	cudaMemcpy(host_test_data2, host_img_in_data, size, cudaMemcpyDeviceToHost); 
	cudaMemcpy(host_test_data, host_img_out_data, size, cudaMemcpyDeviceToHost); 
	cudaError_t err; 
	err = cudaGetLastError();
	if (cudaSuccess != err)
	{
		printf("Epilogue failed\n"); 
		exit(1);
	} 	
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
	int i = blockIdx.y * blockDim.y + threadIdx.y; 
	int j = blockIdx.x * blockDim.x + threadIdx.x; 

	unsigned char mask[9]; 
	
	if((i == 0) || (j == 0) || (i == width - 1) || (j == height - 1))
	{
		host_img_out_data[j * width + i] =  0; 
	}
	else 
	{
		_getMask(mask, host_img_in_data, width, i, j);
		_sort(mask);
		host_img_out_data[i * width + j] = mask[4]; 	
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

	dim3 threadsPerBlock(32, 32);
	dim3 dimGrid((int)ceil((float)bmp_img->header.width_px / (float)32),(int)ceil((float)bmp_img->header.height_px / (float)32)); 
	prologue(); 
	_applyFilter<<<dimGrid, threadsPerBlock>>>(host_img_in_data, host_img_out_data, bmp_img->header.width_px, bmp_img->header.height_px);	
	cudaThreadSynchronize();
	

	epilogue(); 
	_printPixelVals(bmp_img->data, bmp_img->header.width_px, bmp_img->header.height_px); 
	bmp_img->data = host_test_data; 
	write_bmp(bmp_img, fOut); 
	fclose(fOut); 
	free_bmp(bmp_img); 
	return 0; 
}
