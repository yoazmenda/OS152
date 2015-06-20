#include "types.h"
#include "stat.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "fs.h"
#include "file.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"

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



//procfs stuff
char buf[(NPROC+2) * sizeof(struct dirent)];
int procfs_proc_nums[7] = {50000,50001,50002,50003,500004,50005,50006};
char *procfs_proc_names[7] = {"cmdline", "cwd", "exe", "fdinfo", "status", ".", ".."};


extern struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

int 
procfsisdir(struct inode *ip) {
	return ip->minor == T_DIR;
}



void
procfsiread(struct inode* dp, struct inode *ip) {
	ip->flags |= I_VALID;
	ip->type = T_DEV;
	ip->major = 2;
	//if ((ip->inum % 1000) == FDINFO || dp->inum == PROC_INUM)
	//	ip->minor = T_DIR;
	//else
		ip->minor = T_FILE;
	ip->ref = 1;

}

int
procfsread(struct inode *ip, char *dst, int off, int n) {
	struct dirent *de=0;
	struct dirent *buffer;
	struct proc *p;

	//case: ip = "/proc/"
	if (namei("proc")==ip){
		buffer = (struct dirent *)buf;
		acquire(&ptable.lock);
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if(p->state != UNUSED && p->state != ZOMBIE){
				itoa(p->pid, de->name);
				de->inum = p->pid + 60000;
				memmove(buffer, de, sizeof(struct dirent));
				memset(de, 0, sizeof(struct dirent));
				buffer++;
			}
		}
		release(&ptable.lock);
		memmove(dst, buf+off, n);
		return n;
	}

	else if (ip->inum >= 60000){
		cprintf("case /proc/5");
	}
	return 0;
}

int
procfswrite(struct inode *ip, char *buf, int n)
{
  return 0;
}

void
procfsinit(void)
{
  devsw[PROCFS].isdir = procfsisdir;
  devsw[PROCFS].iread = procfsiread;
  devsw[PROCFS].write = procfswrite;
  devsw[PROCFS].read = procfsread;
}
