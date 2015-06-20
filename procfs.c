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

int itoa(int n, char *str){
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
	return len-1;
}

//procfs stuff
char buf[(NPROC+2) * sizeof(struct dirent)];
int procfs_proc_nums[7] = {50000,50001,50002,50003,500004,50005,50006};
char *procfs_proc_names[7] = {"cmdline", "cwd", "exe", "fdinfo", "status", ".", ".."};
ushort procfs_proc_names_lengths[7] = {7, 3,3,6,6,1,2};


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
	int i;
	char pid_name[4];
	int len;
	struct proc *p;
	struct dirent *de = (struct dirent *)buf;
	char * prev = buf;
	//case /proc/
	if (namei("proc")==ip){
	acquire(&ptable.lock);
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if(p->state != UNUSED && p->state != ZOMBIE){
				//PID
				len = itoa(p->pid, pid_name);
				memmove(de->name, pid_name, len+1);
				//inode number
				de->inum = p->pid + 60000;
				de  = (struct dirent *)prev+len+1+(sizeof (ushort));
				prev = (char *)de;
			}
		}
		memmove(dst, buf+off, n);

		//test : print result:
//		de = (struct dirent *)dst;
//		char * prev = buf;
//		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
//			if(p->state != UNUSED && p->state != ZOMBIE){
//				cprintf("de->name: %s.\n", de->name);
//				cprintf("de->num: %d.\n", de->inum);
//				de  = (struct dirent *)prev+len+1+2;
//				prev = (char *)de;
//			}
//		}
		release(&ptable.lock);
		return n;
	}

	//case: ip = "/proc/PID"
	else if (ip->inum >= 60000){
		cprintf("in case: proc/PID\n");
		for(i=0;i<5;i++){
			memmove(de->name, procfs_proc_names[i] ,procfs_proc_names_lengths[i]+1); //+null terminate
			//inode number
			de->inum = procfs_proc_nums[i];
			de  = (struct dirent *)prev+procfs_proc_names_lengths[i]+1+(sizeof (ushort));
			prev = (char *)de;
		}
		memmove(dst, buf+off, n);


		//test : print result:
		de = (struct dirent *)dst;
		char * prev = buf;
		for(i=0;i<5;i++){
			cprintf("de->name: %s.\n", de->name);
			cprintf("de->num: %d.\n", de->inum);
			de  = (struct dirent *)prev+procfs_proc_names_lengths[i]+1+2;
			prev = (char *)de;
		}
		return n;
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
