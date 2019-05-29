#include <stdio.h>
#include <stdlib.h>
#include "bmp.h"

BMPFile* read_bmp(FILE* fp){
	BMPFile *bmp_file; 
	
	bmp_file = (BMPFile *)malloc(sizeof(BMPFile));	
	bmp_file->data = (unsigned char *)malloc(sizeof(fp) - sizeof(bmp_file->header)); 
	fread(&bmp_file->header, sizeof(bmp_file->header), 1, fp);
       	
	while (1){
		if(fread(&bmp_file->data, sizeof(bmp_file->data), 1, fp) < 1) break; 
	}	
	return bmp_file; 
}

int write_bmp(BMPFile* bmp_file, FILE* fp){
	rewind(fp); 
	fwrite(&bmp_file->header, sizeof(bmp_file->header), 1, fp); 
	fwrite(&bmp_file->data, sizeof(bmp_file->data), 1, fp); 
}

void free_bmp(BMPFile* bmp_file){
	free(bmp_file);
}
