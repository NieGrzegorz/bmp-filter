#include <stdio.h>
#include <stdlib.h>
#include "bmp.h"

BMPFile* read_bmp(FILE* fp){
	BMPFile *bmp_file  = malloc(sizeof(*bmp_file));	

	rewind(fp); 
	fread(&bmp_file->header, sizeof(bmp_file->header), 1, fp);
	bmp_file->data = (unsigned char*)malloc(bmp_file->header.image_size_bytes);
	printf("Bits: %d\n", bmp_file->header.bits_per_pixel); 	
	fread(bmp_file->data, bmp_file->header.image_size_bytes, 1, fp);
	return bmp_file; 
}

int write_bmp(BMPFile* bmp_file, FILE* fp){
	rewind(fp); 
	fwrite(&bmp_file->header, sizeof(bmp_file->header), 1, fp); 
	fwrite(bmp_file->data, bmp_file->header.image_size_bytes, 1, fp);	 
}

void free_bmp(BMPFile* bmp_file){
	free(bmp_file);
}
