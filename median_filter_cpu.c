#include <stdio.h>
#include "bmp.h"

void _getMask(unsigned char* mask, unsigned char* image_data, int width,  int x, int y){
	int mask_index = 0; 
	for(int i = x - 1; i < x + 2; i++ ){
		for(int j = y - 1; j < y + 2; j++){
			printf("Mask for (%d, %d): %02x\n", x, y, image_data[i * width + j]); 
			mask[mask_index++] = image_data[i * width + j]; 
		}
	}
}

void  _sort(unsigned char* mask){
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

void _applyFilter(unsigned char* image_data, unsigned char* filtered_data, int width, int height){
	printf("Apply filter vars: width - %d; height - %d\n", width, height);
	for(int i = 1; i < height - 1; i++ ){
		for(int j = 1; j < width - 1; j++){
			unsigned char mask[9]; 
			_getMask(mask, image_data, width, i, j); 
			_sort(mask); 
			filtered_data[(i - 1) * width + (j - 1)] = mask[4]; 	
		}
	}
}

void _printPixelVals(unsigned char* image_data, int width, int height)
{
	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			printf("Img(%d, %d): %02x\n", i, j, image_data[i * height  +j]);
		}
	}
}

int main(int argc, char **argv){
	FILE *fIn;
	FILE *fOut; 
	fIn = fopen("100.bmp", "rb");
	
	BMPFile *bmp_file; 
	bmp_file = read_bmp(fIn);

	fclose(fIn);

	fOut = fopen("out.bmp", "wb");
	_applyFilter(bmp_file->data, bmp_file->data, bmp_file->header.width_px, bmp_file->header.height_px); 
//	_printPixelVals(bmp_file->data, bmp_file->header.width_px, bmp_file->header.height_px);
	write_bmp(bmp_file, fOut); 
	fclose(fOut); 
	free_bmp(bmp_file); 	
}
