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

int procfs_proc_nums[7] = {50000,50001,50002,50003,500004,50005,50006};
char *procfs_proc_names[7] = {"cmdline", "cwd", "exe", "fdinfo", "status", ".", ".."};
ushort procfs_proc_names_lengths[7] = {7, 3,3,6,6,1,2};


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



	struct proc *p;
	struct dirent proc_entries[NPROC+2];
	struct dirent procPid[7];


	//struct dirent dot, dotdot;
	if (namei("proc")==ip){

		int currentIndex=2;
			 proc_entries[0].inum = ip->inum;
			  strncpy(proc_entries[0].name, ".", 1);
			  proc_entries[0].name[1]='\0';
			  proc_entries[1].inum = 1;
			  strncpy(proc_entries[1].name, "..", 2);
			  proc_entries[1].name[2]='\0';
		//cprintf("FFFFFF\n");
		//dot.inum = 0;
		//dot.name=""
		acquire(&ptable.lock);
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if(p->state != UNUSED && p->state != ZOMBIE){
				itoa(p->pid, proc_entries[currentIndex].name);
				//cprintf("THE DE AME IS %s    ",proc_entries[currentIndex].name);
				proc_entries[currentIndex].inum = p->pid + 60000;
				//cprintf("THE DE INUM IS %d\n",proc_entries[currentIndex].inum);
				currentIndex++;


			}
		}



		release(&ptable.lock);


		if (off >= currentIndex*sizeof(struct dirent))
						return 0;


		memmove(dst, (char *)((uint)proc_entries+(uint)off), n);
		return n;
	}
	//case: /proc/pid example: /proc/5
	//else if(){
//
	//}

	if(ip->inum >= 60000){
		int i;
		for(i=0 ;i<7;i++){
			procPid[i].inum=procfs_proc_nums[i];
			memmove(procPid[i].name,procfs_proc_names[i],procfs_proc_names_lengths[i]+1);


		}

		if (off >= 7*sizeof(struct dirent)){
					return 0;
				}

		memmove(dst, (char *)((uint)procPid+(uint)off), n);
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
