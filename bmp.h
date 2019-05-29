#ifndef _BMP_H
#define _BMP_H

#include <stdint.h>

#pragma pack(push)
#pragma pack(1)
typedef struct {
	uint16_t type;
	uint32_t size; 
	uint16_t reserved1;
	uint16_t reserved2;
	uint32_t offset; 
	uint32_t dib_header_size;
	int32_t  width_px;
	int32_t  height_px; 
	uint16_t num_planes; 
	uint16_t bits_per_pixel;
        uint32_t compression; 
	uint32_t image_size_bytes; 
	int32_t  x_resolution_ppm;
	int32_t  y_resolution_ppm; 
	uint32_t num_colors; 
	uint32_t important_colors; 	
} BMPHeader;

#pragma pack(pop)

typedef struct {
	BMPHeader header;
	unsigned char* data;
} BMPFile;

BMPFile* read_bmp(FILE* fp); 
int check_bmp_header(BMPHeader bmp_header, FILE* fp); 
int write_bmp(BMPFile* bmp_file, FILE* fp); 
void free_bmp(BMPFile* bmp_file);

#endif // _BMP_H
