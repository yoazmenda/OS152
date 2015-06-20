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
#define CMDLINE 300
#define CWD 400
#define EXE 500
#define FDINFO 600
#define STATUS 700
ushort procfs_proc_nums[7] = {0,1,2,3,4,5,6};
char *procfs_proc_names[7] = { ".", "..", "cmdline", "cwd", "exe", "fdinfo", "status"};
ushort procfs_proc_names_lengths[7] = {1,2,7, 3,3,6,6};


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
	if (/*(ip->inum % 1000) == FDINFO ||*/ dp->inum == namei("proc")->inum)
		ip->minor = T_DIR;
	else
		ip->minor = T_FILE;
	ip->ref = 1;

}

int
procfsread(struct inode *ip, char *dst, int off, int n) {
	struct proc *p;
	struct dirent proc_entries[NPROC+2];
	struct dirent procPid[7];

	//struct dirent dot, dotdot;
	if (ip == namei("proc")){
		int currentIndex=2;
			 proc_entries[0].inum = ip->inum;
			  strncpy(proc_entries[0].name, ".", 1);
			  proc_entries[0].name[1]='\0';
			  proc_entries[1].inum = 1;
			  strncpy(proc_entries[1].name, "..", 2);
			  proc_entries[1].name[2]='\0';
		acquire(&ptable.lock);
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if(p->state != UNUSED && p->state != ZOMBIE){
				itoa(p->pid, proc_entries[currentIndex].name);
				//cprintf("THE DE AME IS %s    ",proc_entries[currentIndex].name);
				proc_entries[currentIndex].inum = p->pid * 1000;
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
	///proc/PID

	if(ip->inum % 1000 == 0){
		int i;
		for(i=0 ;i<7;i++){
			procPid[i].inum=ip->inum + (i+1)*100;
			memmove(procPid[i].name,procfs_proc_names[i],procfs_proc_names_lengths[i]+1);
		}
		if (off >= 7*sizeof(struct dirent)){
			return 0;
		}
		memmove(dst, (char *)((uint)procPid+(uint)off), n);
		return n;
	}

	int pid = ip->inum / 1000;
	cprintf("pid: %d\n", pid);
	int type = ip->inum % 1000;
	struct proc *myproc;
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
		if (p->pid == pid){
			myproc = p;
			break;
		}
	}
	release(&ptable.lock);

	if (type == CMDLINE){
		memmove(dst, myproc->cmdline, strlen(myproc->cmdline));
		return n;
	}
	else if (type == CWD){
		ilock(myproc->cwd);
		int bytes_read = readi(myproc->cwd, dst, off, n);
		iunlock(myproc->cwd);
		return bytes_read;
	}
	else if (type == EXE){
		struct inode* exe = dirlookup(myproc->cwd, p->name, 0);
		ilock(exe);
		int bytes_read = readi(exe, dst, off, n);
		iunlock(exe);
		return bytes_read;
	}
	else if (type == STATUS){
		int p_state = myproc->state;
		char proc_size[10];
		if (p_state == RUNNABLE){
			memmove(dst, "Status: Runnable, size: ", strlen("Status: Runnable, size: "));
			itoa(myproc->sz, proc_size);
			memmove(dst + strlen("Status: Runnable, size: "), proc_size, strlen(proc_size)+1);
			return n;
		}
		else{ //running
			memmove(dst, "Status: Running, size: ", strlen("Status: Running, size: "));
			itoa(myproc->sz, proc_size);
			memmove(dst + strlen("Status: Running, size: "), proc_size, strlen(proc_size)+1);
			return n;
		}
	}

	else if (type == FDINFO){
		cprintf("FDINFO requested!\n");
	}
	else{
		cprintf("wtf\n");
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
