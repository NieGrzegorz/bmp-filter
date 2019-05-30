#include <stdio.h>
#include <stdlib.h>
#include "bmp.h"
#include <endian.h>

BMPFile* read_bmp(FILE* fp){
	BMPFile *bmp_file  = malloc(sizeof(BMPFile));	
	
	rewind(fp); 
	fread(&bmp_file->header, sizeof(bmp_file->header), 1, fp);
	size_t img_size = (bmp_file->header.width_px * bmp_file->header.height_px); 
	bmp_file->data = malloc(sizeof(*bmp_file->data) * (bmp_file->header.width_px * bmp_file->header.height_px));
	printf("Bits: %d, Size of file: %d \n", bmp_file->header.bits_per_pixel, img_size); 	
	
	fread(bmp_file->data, img_size, 1, fp);
	return bmp_file; 
}

int write_bmp(BMPFile* bmp_file, FILE* fp){
	
	size_t img_size = (bmp_file->header.width_px * bmp_file->header.height_px); 
	rewind(fp); 
	fwrite(&bmp_file->header, sizeof(bmp_file->header), 1, fp); 
	fwrite(bmp_file->data, img_size, 1, fp);	 
}

void free_bmp(BMPFile* bmp_file){
	free(bmp_file);
}
