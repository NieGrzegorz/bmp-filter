filter_gpu: bmp.o median_filter_gpu.cu
	nvcc -o filter_gpu bmp.o median_filter_gpu.cu

filter_cpu: bmp.o median_filter_cpu.o 
	gcc -o filter_cpu bmp.o median_filter_cpu.o

median_filter_cpu.o: median_filter_cpu.c
	gcc -c median_filter_cpu.c

bmp.o: bmp.c
	nvcc -c bmp.c
