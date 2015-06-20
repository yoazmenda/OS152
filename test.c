#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"

void itoa(int n, char *str){
	int temp, len;
	temp = n;
	len = 1;
	while (temp/10!=0){
		len++;
		temp /= 10;
	}
	for (temp = len; temp > 0; temp--){
		str[temp-1] = (n%10)+48;
		n/=10;
	}
	str[len]='\0';
}

int
main(void)
{

  //test0: /proc/
  int fd = open("/proc/",O_RDONLY);
  if (fd == 0){
	  printf(1, "Failed to open path\n test 0 failed.\n");
  }


  //test1: /proc/pid
  int pid;
  char path[16];
  pid = getpid();
  strcpy(path, "/proc/");
  itoa(pid, path+6);
  printf(1, "user tries to open path: %s\n", path);
  fd = open(path, O_RDONLY);
  printf(1, "fd: %d\n",fd);




  exit();
}
