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
  int fd = open("proc/2/cmdline",O_RDONLY);
  if (fd == 0){
	  printf(1, "Failed to open path\n test 0 failed.\n");
  }
  else{
	  printf(1, "fd: %d\n",fd);
	  char buf[50];
	  read(fd, buf,50);
	  printf(1 ,"cmdline: %s\n", buf);
  }



  exit();
}
