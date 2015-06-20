#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"

void itoa(char* arr,int num){
	int i,len = (int)(num/10) + 1;
	for(i=0;i<len;i++){
		arr[len-i-1]=num%10+'0';
	}
	arr[len]= 0;
}

int
main(int argc, char *argv[])
{
	int fd;
	char path[20] = {'/','p','r','o','c','/'};
	char buffer[100];

//	fork();
	itoa(path+6, getpid());

	/**************** 1: open /proc/PID/cmdline ****************/
	memmove(path+7, "/cmdline", 8);
	path[15] = 0;
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);

	/***************** 2: open /proc/PID/cwd *****************/
	memmove(path+7, "/cwd", 4);
	path[11] = 0;
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);

	/***************** 3: open /proc/PID/exe *****************/
	memmove(path+7, "/exe", 4);
	path[11] = 0;
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);


	/***************** 4: open /proc/PID/fdinfo *****************/
	memmove(path+7, "/fdinfo", 7);
	path[14] = 0;
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);

	/*************** 4.1: open /proc/PID/fdinfo/0 ***************/
	memmove(path+7, "/fdinfo/0", 9);
	path[16] = 0;
	printf(1, "Opening: %s...\n", path);
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);

	/***************** 5: open /proc/PID/status *****************/
	memmove(path+7, "/status", 7);
	path[14] = 0;
	if ((fd = open(path, O_RDONLY)) > 0){
		printf(1, "Open succeeded: %s, fd = %d\n", path, fd);
		read(fd, buffer, 100);
		printf(1, "read from file: %s\n", buffer);
		close(fd);
	}
	else
		printf(1, "Open failed: %s\n", path);

	exit();
}
