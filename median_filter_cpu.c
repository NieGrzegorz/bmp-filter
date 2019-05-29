#include <stdio.h>
#include "bmp.h"


int main(int argc, char **argv){
	FILE *fIn;
	FILE *fOut; 
	fIn = fopen("100.bmp", "rb");
	
	BMPFile *bmp_file; 
	bmp_file = read_bmp(fIn);

	fclose(fIn);

	fOut = fopen("out.bmp", "wb"); 
	write_bmp(bmp_file, fOut); 
	fclose(fOut); 
	free_bmp(bmp_file); 	
}
