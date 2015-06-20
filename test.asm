
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <itoa>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"

void itoa(int n, char *str){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
	int temp, len;
	temp = n;
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	len = 1;
   d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while (temp/10!=0){
  14:	eb 1f                	jmp    35 <itoa+0x35>
		len++;
  16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		temp /= 10;
  1a:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  1d:	ba 67 66 66 66       	mov    $0x66666667,%edx
  22:	89 c8                	mov    %ecx,%eax
  24:	f7 ea                	imul   %edx
  26:	c1 fa 02             	sar    $0x2,%edx
  29:	89 c8                	mov    %ecx,%eax
  2b:	c1 f8 1f             	sar    $0x1f,%eax
  2e:	29 c2                	sub    %eax,%edx
  30:	89 d0                	mov    %edx,%eax
  32:	89 45 f8             	mov    %eax,-0x8(%ebp)

void itoa(int n, char *str){
	int temp, len;
	temp = n;
	len = 1;
	while (temp/10!=0){
  35:	8b 45 f8             	mov    -0x8(%ebp),%eax
  38:	83 c0 09             	add    $0x9,%eax
  3b:	83 f8 12             	cmp    $0x12,%eax
  3e:	77 d6                	ja     16 <itoa+0x16>
		len++;
		temp /= 10;
	}
	for (temp = len; temp > 0; temp--){
  40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  43:	89 45 f8             	mov    %eax,-0x8(%ebp)
  46:	eb 55                	jmp    9d <itoa+0x9d>
		str[temp-1] = (n%10)+48;
  48:	8b 45 f8             	mov    -0x8(%ebp),%eax
  4b:	8d 50 ff             	lea    -0x1(%eax),%edx
  4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  51:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  57:	ba 67 66 66 66       	mov    $0x66666667,%edx
  5c:	89 c8                	mov    %ecx,%eax
  5e:	f7 ea                	imul   %edx
  60:	c1 fa 02             	sar    $0x2,%edx
  63:	89 c8                	mov    %ecx,%eax
  65:	c1 f8 1f             	sar    $0x1f,%eax
  68:	29 c2                	sub    %eax,%edx
  6a:	89 d0                	mov    %edx,%eax
  6c:	c1 e0 02             	shl    $0x2,%eax
  6f:	01 d0                	add    %edx,%eax
  71:	01 c0                	add    %eax,%eax
  73:	29 c1                	sub    %eax,%ecx
  75:	89 ca                	mov    %ecx,%edx
  77:	89 d0                	mov    %edx,%eax
  79:	83 c0 30             	add    $0x30,%eax
  7c:	88 03                	mov    %al,(%ebx)
		n/=10;
  7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  81:	ba 67 66 66 66       	mov    $0x66666667,%edx
  86:	89 c8                	mov    %ecx,%eax
  88:	f7 ea                	imul   %edx
  8a:	c1 fa 02             	sar    $0x2,%edx
  8d:	89 c8                	mov    %ecx,%eax
  8f:	c1 f8 1f             	sar    $0x1f,%eax
  92:	29 c2                	sub    %eax,%edx
  94:	89 d0                	mov    %edx,%eax
  96:	89 45 08             	mov    %eax,0x8(%ebp)
	len = 1;
	while (temp/10!=0){
		len++;
		temp /= 10;
	}
	for (temp = len; temp > 0; temp--){
  99:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
  9d:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  a1:	7f a5                	jg     48 <itoa+0x48>
		str[temp-1] = (n%10)+48;
		n/=10;
	}
	str[len]='\0';
  a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  a9:	01 d0                	add    %edx,%eax
  ab:	c6 00 00             	movb   $0x0,(%eax)
}
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	5b                   	pop    %ebx
  b2:	5d                   	pop    %ebp
  b3:	c3                   	ret    

000000b4 <main>:

int
main(void)
{
  b4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  b8:	83 e4 f0             	and    $0xfffffff0,%esp
  bb:	ff 71 fc             	pushl  -0x4(%ecx)
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	51                   	push   %ecx
  c2:	83 ec 24             	sub    $0x24,%esp

  //test0: /proc/
  int fd = open("/proc/",O_RDONLY);
  c5:	83 ec 08             	sub    $0x8,%esp
  c8:	6a 00                	push   $0x0
  ca:	68 e8 08 00 00       	push   $0x8e8
  cf:	e8 28 03 00 00       	call   3fc <open>
  d4:	83 c4 10             	add    $0x10,%esp
  d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (fd == 0){
  da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  de:	75 12                	jne    f2 <main+0x3e>
	  printf(1, "Failed to open path\n test 0 failed.\n");
  e0:	83 ec 08             	sub    $0x8,%esp
  e3:	68 f0 08 00 00       	push   $0x8f0
  e8:	6a 01                	push   $0x1
  ea:	e8 42 04 00 00       	call   531 <printf>
  ef:	83 c4 10             	add    $0x10,%esp


  //test1: /proc/pid
  int pid;
  char path[16];
  pid = getpid();
  f2:	e8 45 03 00 00       	call   43c <getpid>
  f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  strcpy(path, "/proc/");
  fa:	83 ec 08             	sub    $0x8,%esp
  fd:	68 e8 08 00 00       	push   $0x8e8
 102:	8d 45 e0             	lea    -0x20(%ebp),%eax
 105:	50                   	push   %eax
 106:	e8 81 00 00 00       	call   18c <strcpy>
 10b:	83 c4 10             	add    $0x10,%esp
  itoa(pid, path+6);
 10e:	83 ec 08             	sub    $0x8,%esp
 111:	8d 45 e0             	lea    -0x20(%ebp),%eax
 114:	83 c0 06             	add    $0x6,%eax
 117:	50                   	push   %eax
 118:	ff 75 f0             	pushl  -0x10(%ebp)
 11b:	e8 e0 fe ff ff       	call   0 <itoa>
 120:	83 c4 10             	add    $0x10,%esp
  printf(1, "user tries to open path: %s\n", path);
 123:	83 ec 04             	sub    $0x4,%esp
 126:	8d 45 e0             	lea    -0x20(%ebp),%eax
 129:	50                   	push   %eax
 12a:	68 15 09 00 00       	push   $0x915
 12f:	6a 01                	push   $0x1
 131:	e8 fb 03 00 00       	call   531 <printf>
 136:	83 c4 10             	add    $0x10,%esp
  fd = open(path, O_RDONLY);
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	6a 00                	push   $0x0
 13e:	8d 45 e0             	lea    -0x20(%ebp),%eax
 141:	50                   	push   %eax
 142:	e8 b5 02 00 00       	call   3fc <open>
 147:	83 c4 10             	add    $0x10,%esp
 14a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "fd: %d\n",fd);
 14d:	83 ec 04             	sub    $0x4,%esp
 150:	ff 75 f4             	pushl  -0xc(%ebp)
 153:	68 32 09 00 00       	push   $0x932
 158:	6a 01                	push   $0x1
 15a:	e8 d2 03 00 00       	call   531 <printf>
 15f:	83 c4 10             	add    $0x10,%esp




  exit();
 162:	e8 55 02 00 00       	call   3bc <exit>

00000167 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	57                   	push   %edi
 16b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 16c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 16f:	8b 55 10             	mov    0x10(%ebp),%edx
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	89 cb                	mov    %ecx,%ebx
 177:	89 df                	mov    %ebx,%edi
 179:	89 d1                	mov    %edx,%ecx
 17b:	fc                   	cld    
 17c:	f3 aa                	rep stos %al,%es:(%edi)
 17e:	89 ca                	mov    %ecx,%edx
 180:	89 fb                	mov    %edi,%ebx
 182:	89 5d 08             	mov    %ebx,0x8(%ebp)
 185:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 188:	5b                   	pop    %ebx
 189:	5f                   	pop    %edi
 18a:	5d                   	pop    %ebp
 18b:	c3                   	ret    

0000018c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 192:	8b 45 08             	mov    0x8(%ebp),%eax
 195:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 198:	90                   	nop
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	8d 50 01             	lea    0x1(%eax),%edx
 19f:	89 55 08             	mov    %edx,0x8(%ebp)
 1a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 1a5:	8d 4a 01             	lea    0x1(%edx),%ecx
 1a8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1ab:	0f b6 12             	movzbl (%edx),%edx
 1ae:	88 10                	mov    %dl,(%eax)
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	84 c0                	test   %al,%al
 1b5:	75 e2                	jne    199 <strcpy+0xd>
    ;
  return os;
 1b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ba:	c9                   	leave  
 1bb:	c3                   	ret    

000001bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1bf:	eb 08                	jmp    1c9 <strcmp+0xd>
    p++, q++;
 1c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1c9:	8b 45 08             	mov    0x8(%ebp),%eax
 1cc:	0f b6 00             	movzbl (%eax),%eax
 1cf:	84 c0                	test   %al,%al
 1d1:	74 10                	je     1e3 <strcmp+0x27>
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 10             	movzbl (%eax),%edx
 1d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dc:	0f b6 00             	movzbl (%eax),%eax
 1df:	38 c2                	cmp    %al,%dl
 1e1:	74 de                	je     1c1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	0f b6 00             	movzbl (%eax),%eax
 1e9:	0f b6 d0             	movzbl %al,%edx
 1ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ef:	0f b6 00             	movzbl (%eax),%eax
 1f2:	0f b6 c0             	movzbl %al,%eax
 1f5:	29 c2                	sub    %eax,%edx
 1f7:	89 d0                	mov    %edx,%eax
}
 1f9:	5d                   	pop    %ebp
 1fa:	c3                   	ret    

000001fb <strlen>:

uint
strlen(char *s)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 201:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 208:	eb 04                	jmp    20e <strlen+0x13>
 20a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 20e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 211:	8b 45 08             	mov    0x8(%ebp),%eax
 214:	01 d0                	add    %edx,%eax
 216:	0f b6 00             	movzbl (%eax),%eax
 219:	84 c0                	test   %al,%al
 21b:	75 ed                	jne    20a <strlen+0xf>
    ;
  return n;
 21d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 220:	c9                   	leave  
 221:	c3                   	ret    

00000222 <memset>:

void*
memset(void *dst, int c, uint n)
{
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 225:	8b 45 10             	mov    0x10(%ebp),%eax
 228:	50                   	push   %eax
 229:	ff 75 0c             	pushl  0xc(%ebp)
 22c:	ff 75 08             	pushl  0x8(%ebp)
 22f:	e8 33 ff ff ff       	call   167 <stosb>
 234:	83 c4 0c             	add    $0xc,%esp
  return dst;
 237:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23a:	c9                   	leave  
 23b:	c3                   	ret    

0000023c <strchr>:

char*
strchr(const char *s, char c)
{
 23c:	55                   	push   %ebp
 23d:	89 e5                	mov    %esp,%ebp
 23f:	83 ec 04             	sub    $0x4,%esp
 242:	8b 45 0c             	mov    0xc(%ebp),%eax
 245:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 248:	eb 14                	jmp    25e <strchr+0x22>
    if(*s == c)
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	0f b6 00             	movzbl (%eax),%eax
 250:	3a 45 fc             	cmp    -0x4(%ebp),%al
 253:	75 05                	jne    25a <strchr+0x1e>
      return (char*)s;
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	eb 13                	jmp    26d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 25a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	0f b6 00             	movzbl (%eax),%eax
 264:	84 c0                	test   %al,%al
 266:	75 e2                	jne    24a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 268:	b8 00 00 00 00       	mov    $0x0,%eax
}
 26d:	c9                   	leave  
 26e:	c3                   	ret    

0000026f <gets>:

char*
gets(char *buf, int max)
{
 26f:	55                   	push   %ebp
 270:	89 e5                	mov    %esp,%ebp
 272:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 27c:	eb 44                	jmp    2c2 <gets+0x53>
    cc = read(0, &c, 1);
 27e:	83 ec 04             	sub    $0x4,%esp
 281:	6a 01                	push   $0x1
 283:	8d 45 ef             	lea    -0x11(%ebp),%eax
 286:	50                   	push   %eax
 287:	6a 00                	push   $0x0
 289:	e8 46 01 00 00       	call   3d4 <read>
 28e:	83 c4 10             	add    $0x10,%esp
 291:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 294:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 298:	7f 02                	jg     29c <gets+0x2d>
      break;
 29a:	eb 31                	jmp    2cd <gets+0x5e>
    buf[i++] = c;
 29c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29f:	8d 50 01             	lea    0x1(%eax),%edx
 2a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2a5:	89 c2                	mov    %eax,%edx
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	01 c2                	add    %eax,%edx
 2ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b6:	3c 0a                	cmp    $0xa,%al
 2b8:	74 13                	je     2cd <gets+0x5e>
 2ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2be:	3c 0d                	cmp    $0xd,%al
 2c0:	74 0b                	je     2cd <gets+0x5e>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	83 c0 01             	add    $0x1,%eax
 2c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2cb:	7c b1                	jl     27e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	01 d0                	add    %edx,%eax
 2d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2db:	c9                   	leave  
 2dc:	c3                   	ret    

000002dd <stat>:

int
stat(char *n, struct stat *st)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e3:	83 ec 08             	sub    $0x8,%esp
 2e6:	6a 00                	push   $0x0
 2e8:	ff 75 08             	pushl  0x8(%ebp)
 2eb:	e8 0c 01 00 00       	call   3fc <open>
 2f0:	83 c4 10             	add    $0x10,%esp
 2f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2fa:	79 07                	jns    303 <stat+0x26>
    return -1;
 2fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 301:	eb 25                	jmp    328 <stat+0x4b>
  r = fstat(fd, st);
 303:	83 ec 08             	sub    $0x8,%esp
 306:	ff 75 0c             	pushl  0xc(%ebp)
 309:	ff 75 f4             	pushl  -0xc(%ebp)
 30c:	e8 03 01 00 00       	call   414 <fstat>
 311:	83 c4 10             	add    $0x10,%esp
 314:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 317:	83 ec 0c             	sub    $0xc,%esp
 31a:	ff 75 f4             	pushl  -0xc(%ebp)
 31d:	e8 c2 00 00 00       	call   3e4 <close>
 322:	83 c4 10             	add    $0x10,%esp
  return r;
 325:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 328:	c9                   	leave  
 329:	c3                   	ret    

0000032a <atoi>:

int
atoi(const char *s)
{
 32a:	55                   	push   %ebp
 32b:	89 e5                	mov    %esp,%ebp
 32d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 330:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 337:	eb 25                	jmp    35e <atoi+0x34>
    n = n*10 + *s++ - '0';
 339:	8b 55 fc             	mov    -0x4(%ebp),%edx
 33c:	89 d0                	mov    %edx,%eax
 33e:	c1 e0 02             	shl    $0x2,%eax
 341:	01 d0                	add    %edx,%eax
 343:	01 c0                	add    %eax,%eax
 345:	89 c1                	mov    %eax,%ecx
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	8d 50 01             	lea    0x1(%eax),%edx
 34d:	89 55 08             	mov    %edx,0x8(%ebp)
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	0f be c0             	movsbl %al,%eax
 356:	01 c8                	add    %ecx,%eax
 358:	83 e8 30             	sub    $0x30,%eax
 35b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	3c 2f                	cmp    $0x2f,%al
 366:	7e 0a                	jle    372 <atoi+0x48>
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	3c 39                	cmp    $0x39,%al
 370:	7e c7                	jle    339 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 372:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 375:	c9                   	leave  
 376:	c3                   	ret    

00000377 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 377:	55                   	push   %ebp
 378:	89 e5                	mov    %esp,%ebp
 37a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 383:	8b 45 0c             	mov    0xc(%ebp),%eax
 386:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 389:	eb 17                	jmp    3a2 <memmove+0x2b>
    *dst++ = *src++;
 38b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 38e:	8d 50 01             	lea    0x1(%eax),%edx
 391:	89 55 fc             	mov    %edx,-0x4(%ebp)
 394:	8b 55 f8             	mov    -0x8(%ebp),%edx
 397:	8d 4a 01             	lea    0x1(%edx),%ecx
 39a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 39d:	0f b6 12             	movzbl (%edx),%edx
 3a0:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3a2:	8b 45 10             	mov    0x10(%ebp),%eax
 3a5:	8d 50 ff             	lea    -0x1(%eax),%edx
 3a8:	89 55 10             	mov    %edx,0x10(%ebp)
 3ab:	85 c0                	test   %eax,%eax
 3ad:	7f dc                	jg     38b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3b2:	c9                   	leave  
 3b3:	c3                   	ret    

000003b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3b4:	b8 01 00 00 00       	mov    $0x1,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <exit>:
SYSCALL(exit)
 3bc:	b8 02 00 00 00       	mov    $0x2,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <wait>:
SYSCALL(wait)
 3c4:	b8 03 00 00 00       	mov    $0x3,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <pipe>:
SYSCALL(pipe)
 3cc:	b8 04 00 00 00       	mov    $0x4,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <read>:
SYSCALL(read)
 3d4:	b8 05 00 00 00       	mov    $0x5,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <write>:
SYSCALL(write)
 3dc:	b8 10 00 00 00       	mov    $0x10,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <close>:
SYSCALL(close)
 3e4:	b8 15 00 00 00       	mov    $0x15,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <kill>:
SYSCALL(kill)
 3ec:	b8 06 00 00 00       	mov    $0x6,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <exec>:
SYSCALL(exec)
 3f4:	b8 07 00 00 00       	mov    $0x7,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <open>:
SYSCALL(open)
 3fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <mknod>:
SYSCALL(mknod)
 404:	b8 11 00 00 00       	mov    $0x11,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <unlink>:
SYSCALL(unlink)
 40c:	b8 12 00 00 00       	mov    $0x12,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <fstat>:
SYSCALL(fstat)
 414:	b8 08 00 00 00       	mov    $0x8,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <link>:
SYSCALL(link)
 41c:	b8 13 00 00 00       	mov    $0x13,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <mkdir>:
SYSCALL(mkdir)
 424:	b8 14 00 00 00       	mov    $0x14,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <chdir>:
SYSCALL(chdir)
 42c:	b8 09 00 00 00       	mov    $0x9,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <dup>:
SYSCALL(dup)
 434:	b8 0a 00 00 00       	mov    $0xa,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <getpid>:
SYSCALL(getpid)
 43c:	b8 0b 00 00 00       	mov    $0xb,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <sbrk>:
SYSCALL(sbrk)
 444:	b8 0c 00 00 00       	mov    $0xc,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <sleep>:
SYSCALL(sleep)
 44c:	b8 0d 00 00 00       	mov    $0xd,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <uptime>:
SYSCALL(uptime)
 454:	b8 0e 00 00 00       	mov    $0xe,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 45c:	55                   	push   %ebp
 45d:	89 e5                	mov    %esp,%ebp
 45f:	83 ec 18             	sub    $0x18,%esp
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 468:	83 ec 04             	sub    $0x4,%esp
 46b:	6a 01                	push   $0x1
 46d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 470:	50                   	push   %eax
 471:	ff 75 08             	pushl  0x8(%ebp)
 474:	e8 63 ff ff ff       	call   3dc <write>
 479:	83 c4 10             	add    $0x10,%esp
}
 47c:	c9                   	leave  
 47d:	c3                   	ret    

0000047e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47e:	55                   	push   %ebp
 47f:	89 e5                	mov    %esp,%ebp
 481:	53                   	push   %ebx
 482:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 490:	74 17                	je     4a9 <printint+0x2b>
 492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 496:	79 11                	jns    4a9 <printint+0x2b>
    neg = 1;
 498:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49f:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a2:	f7 d8                	neg    %eax
 4a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a7:	eb 06                	jmp    4af <printint+0x31>
  } else {
    x = xx;
 4a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b9:	8d 41 01             	lea    0x1(%ecx),%eax
 4bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ca:	f7 f3                	div    %ebx
 4cc:	89 d0                	mov    %edx,%eax
 4ce:	0f b6 80 b0 0b 00 00 	movzbl 0xbb0(%eax),%eax
 4d5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4df:	ba 00 00 00 00       	mov    $0x0,%edx
 4e4:	f7 f3                	div    %ebx
 4e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ed:	75 c7                	jne    4b6 <printint+0x38>
  if(neg)
 4ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f3:	74 0e                	je     503 <printint+0x85>
    buf[i++] = '-';
 4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f8:	8d 50 01             	lea    0x1(%eax),%edx
 4fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fe:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 503:	eb 1d                	jmp    522 <printint+0xa4>
    putc(fd, buf[i]);
 505:	8d 55 dc             	lea    -0x24(%ebp),%edx
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	01 d0                	add    %edx,%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	0f be c0             	movsbl %al,%eax
 513:	83 ec 08             	sub    $0x8,%esp
 516:	50                   	push   %eax
 517:	ff 75 08             	pushl  0x8(%ebp)
 51a:	e8 3d ff ff ff       	call   45c <putc>
 51f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 522:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 526:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52a:	79 d9                	jns    505 <printint+0x87>
    putc(fd, buf[i]);
}
 52c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 52f:	c9                   	leave  
 530:	c3                   	ret    

00000531 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 531:	55                   	push   %ebp
 532:	89 e5                	mov    %esp,%ebp
 534:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 537:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 53e:	8d 45 0c             	lea    0xc(%ebp),%eax
 541:	83 c0 04             	add    $0x4,%eax
 544:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 547:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 54e:	e9 59 01 00 00       	jmp    6ac <printf+0x17b>
    c = fmt[i] & 0xff;
 553:	8b 55 0c             	mov    0xc(%ebp),%edx
 556:	8b 45 f0             	mov    -0x10(%ebp),%eax
 559:	01 d0                	add    %edx,%eax
 55b:	0f b6 00             	movzbl (%eax),%eax
 55e:	0f be c0             	movsbl %al,%eax
 561:	25 ff 00 00 00       	and    $0xff,%eax
 566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56d:	75 2c                	jne    59b <printf+0x6a>
      if(c == '%'){
 56f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 573:	75 0c                	jne    581 <printf+0x50>
        state = '%';
 575:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 57c:	e9 27 01 00 00       	jmp    6a8 <printf+0x177>
      } else {
        putc(fd, c);
 581:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 584:	0f be c0             	movsbl %al,%eax
 587:	83 ec 08             	sub    $0x8,%esp
 58a:	50                   	push   %eax
 58b:	ff 75 08             	pushl  0x8(%ebp)
 58e:	e8 c9 fe ff ff       	call   45c <putc>
 593:	83 c4 10             	add    $0x10,%esp
 596:	e9 0d 01 00 00       	jmp    6a8 <printf+0x177>
      }
    } else if(state == '%'){
 59b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59f:	0f 85 03 01 00 00    	jne    6a8 <printf+0x177>
      if(c == 'd'){
 5a5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a9:	75 1e                	jne    5c9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ae:	8b 00                	mov    (%eax),%eax
 5b0:	6a 01                	push   $0x1
 5b2:	6a 0a                	push   $0xa
 5b4:	50                   	push   %eax
 5b5:	ff 75 08             	pushl  0x8(%ebp)
 5b8:	e8 c1 fe ff ff       	call   47e <printint>
 5bd:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c4:	e9 d8 00 00 00       	jmp    6a1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5c9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5cd:	74 06                	je     5d5 <printf+0xa4>
 5cf:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d3:	75 1e                	jne    5f3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	6a 00                	push   $0x0
 5dc:	6a 10                	push   $0x10
 5de:	50                   	push   %eax
 5df:	ff 75 08             	pushl  0x8(%ebp)
 5e2:	e8 97 fe ff ff       	call   47e <printint>
 5e7:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ee:	e9 ae 00 00 00       	jmp    6a1 <printf+0x170>
      } else if(c == 's'){
 5f3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f7:	75 43                	jne    63c <printf+0x10b>
        s = (char*)*ap;
 5f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fc:	8b 00                	mov    (%eax),%eax
 5fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 601:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 605:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 609:	75 07                	jne    612 <printf+0xe1>
          s = "(null)";
 60b:	c7 45 f4 3a 09 00 00 	movl   $0x93a,-0xc(%ebp)
        while(*s != 0){
 612:	eb 1c                	jmp    630 <printf+0xff>
          putc(fd, *s);
 614:	8b 45 f4             	mov    -0xc(%ebp),%eax
 617:	0f b6 00             	movzbl (%eax),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	83 ec 08             	sub    $0x8,%esp
 620:	50                   	push   %eax
 621:	ff 75 08             	pushl  0x8(%ebp)
 624:	e8 33 fe ff ff       	call   45c <putc>
 629:	83 c4 10             	add    $0x10,%esp
          s++;
 62c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 630:	8b 45 f4             	mov    -0xc(%ebp),%eax
 633:	0f b6 00             	movzbl (%eax),%eax
 636:	84 c0                	test   %al,%al
 638:	75 da                	jne    614 <printf+0xe3>
 63a:	eb 65                	jmp    6a1 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 63c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 640:	75 1d                	jne    65f <printf+0x12e>
        putc(fd, *ap);
 642:	8b 45 e8             	mov    -0x18(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	83 ec 08             	sub    $0x8,%esp
 64d:	50                   	push   %eax
 64e:	ff 75 08             	pushl  0x8(%ebp)
 651:	e8 06 fe ff ff       	call   45c <putc>
 656:	83 c4 10             	add    $0x10,%esp
        ap++;
 659:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65d:	eb 42                	jmp    6a1 <printf+0x170>
      } else if(c == '%'){
 65f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 663:	75 17                	jne    67c <printf+0x14b>
        putc(fd, c);
 665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 668:	0f be c0             	movsbl %al,%eax
 66b:	83 ec 08             	sub    $0x8,%esp
 66e:	50                   	push   %eax
 66f:	ff 75 08             	pushl  0x8(%ebp)
 672:	e8 e5 fd ff ff       	call   45c <putc>
 677:	83 c4 10             	add    $0x10,%esp
 67a:	eb 25                	jmp    6a1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 67c:	83 ec 08             	sub    $0x8,%esp
 67f:	6a 25                	push   $0x25
 681:	ff 75 08             	pushl  0x8(%ebp)
 684:	e8 d3 fd ff ff       	call   45c <putc>
 689:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 68c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	83 ec 08             	sub    $0x8,%esp
 695:	50                   	push   %eax
 696:	ff 75 08             	pushl  0x8(%ebp)
 699:	e8 be fd ff ff       	call   45c <putc>
 69e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 6af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b2:	01 d0                	add    %edx,%eax
 6b4:	0f b6 00             	movzbl (%eax),%eax
 6b7:	84 c0                	test   %al,%al
 6b9:	0f 85 94 fe ff ff    	jne    553 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6bf:	c9                   	leave  
 6c0:	c3                   	ret    

000006c1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c1:	55                   	push   %ebp
 6c2:	89 e5                	mov    %esp,%ebp
 6c4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	83 e8 08             	sub    $0x8,%eax
 6cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d0:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 6d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d8:	eb 24                	jmp    6fe <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	8b 00                	mov    (%eax),%eax
 6df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e2:	77 12                	ja     6f6 <free+0x35>
 6e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ea:	77 24                	ja     710 <free+0x4f>
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f4:	77 1a                	ja     710 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 704:	76 d4                	jbe    6da <free+0x19>
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	8b 00                	mov    (%eax),%eax
 70b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70e:	76 ca                	jbe    6da <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	8b 40 04             	mov    0x4(%eax),%eax
 716:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 720:	01 c2                	add    %eax,%edx
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	39 c2                	cmp    %eax,%edx
 729:	75 24                	jne    74f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 50 04             	mov    0x4(%eax),%edx
 731:	8b 45 fc             	mov    -0x4(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	8b 40 04             	mov    0x4(%eax),%eax
 739:	01 c2                	add    %eax,%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	8b 10                	mov    (%eax),%edx
 748:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74b:	89 10                	mov    %edx,(%eax)
 74d:	eb 0a                	jmp    759 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 10                	mov    (%eax),%edx
 754:	8b 45 f8             	mov    -0x8(%ebp),%eax
 757:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	01 d0                	add    %edx,%eax
 76b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 76e:	75 20                	jne    790 <free+0xcf>
    p->s.size += bp->s.size;
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 50 04             	mov    0x4(%eax),%edx
 776:	8b 45 f8             	mov    -0x8(%ebp),%eax
 779:	8b 40 04             	mov    0x4(%eax),%eax
 77c:	01 c2                	add    %eax,%edx
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 784:	8b 45 f8             	mov    -0x8(%ebp),%eax
 787:	8b 10                	mov    (%eax),%edx
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	89 10                	mov    %edx,(%eax)
 78e:	eb 08                	jmp    798 <free+0xd7>
  } else
    p->s.ptr = bp;
 790:	8b 45 fc             	mov    -0x4(%ebp),%eax
 793:	8b 55 f8             	mov    -0x8(%ebp),%edx
 796:	89 10                	mov    %edx,(%eax)
  freep = p;
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	a3 cc 0b 00 00       	mov    %eax,0xbcc
}
 7a0:	c9                   	leave  
 7a1:	c3                   	ret    

000007a2 <morecore>:

static Header*
morecore(uint nu)
{
 7a2:	55                   	push   %ebp
 7a3:	89 e5                	mov    %esp,%ebp
 7a5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7af:	77 07                	ja     7b8 <morecore+0x16>
    nu = 4096;
 7b1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b8:	8b 45 08             	mov    0x8(%ebp),%eax
 7bb:	c1 e0 03             	shl    $0x3,%eax
 7be:	83 ec 0c             	sub    $0xc,%esp
 7c1:	50                   	push   %eax
 7c2:	e8 7d fc ff ff       	call   444 <sbrk>
 7c7:	83 c4 10             	add    $0x10,%esp
 7ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7cd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d1:	75 07                	jne    7da <morecore+0x38>
    return 0;
 7d3:	b8 00 00 00 00       	mov    $0x0,%eax
 7d8:	eb 26                	jmp    800 <morecore+0x5e>
  hp = (Header*)p;
 7da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e3:	8b 55 08             	mov    0x8(%ebp),%edx
 7e6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	83 c0 08             	add    $0x8,%eax
 7ef:	83 ec 0c             	sub    $0xc,%esp
 7f2:	50                   	push   %eax
 7f3:	e8 c9 fe ff ff       	call   6c1 <free>
 7f8:	83 c4 10             	add    $0x10,%esp
  return freep;
 7fb:	a1 cc 0b 00 00       	mov    0xbcc,%eax
}
 800:	c9                   	leave  
 801:	c3                   	ret    

00000802 <malloc>:

void*
malloc(uint nbytes)
{
 802:	55                   	push   %ebp
 803:	89 e5                	mov    %esp,%ebp
 805:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 808:	8b 45 08             	mov    0x8(%ebp),%eax
 80b:	83 c0 07             	add    $0x7,%eax
 80e:	c1 e8 03             	shr    $0x3,%eax
 811:	83 c0 01             	add    $0x1,%eax
 814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 817:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 81c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 823:	75 23                	jne    848 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 825:	c7 45 f0 c4 0b 00 00 	movl   $0xbc4,-0x10(%ebp)
 82c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82f:	a3 cc 0b 00 00       	mov    %eax,0xbcc
 834:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 839:	a3 c4 0b 00 00       	mov    %eax,0xbc4
    base.s.size = 0;
 83e:	c7 05 c8 0b 00 00 00 	movl   $0x0,0xbc8
 845:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 859:	72 4d                	jb     8a8 <malloc+0xa6>
      if(p->s.size == nunits)
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	8b 40 04             	mov    0x4(%eax),%eax
 861:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 864:	75 0c                	jne    872 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	8b 10                	mov    (%eax),%edx
 86b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86e:	89 10                	mov    %edx,(%eax)
 870:	eb 26                	jmp    898 <malloc+0x96>
      else {
        p->s.size -= nunits;
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	8b 40 04             	mov    0x4(%eax),%eax
 878:	2b 45 ec             	sub    -0x14(%ebp),%eax
 87b:	89 c2                	mov    %eax,%edx
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	c1 e0 03             	shl    $0x3,%eax
 88c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	8b 55 ec             	mov    -0x14(%ebp),%edx
 895:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 898:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89b:	a3 cc 0b 00 00       	mov    %eax,0xbcc
      return (void*)(p + 1);
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	83 c0 08             	add    $0x8,%eax
 8a6:	eb 3b                	jmp    8e3 <malloc+0xe1>
    }
    if(p == freep)
 8a8:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 8ad:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b0:	75 1e                	jne    8d0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8b2:	83 ec 0c             	sub    $0xc,%esp
 8b5:	ff 75 ec             	pushl  -0x14(%ebp)
 8b8:	e8 e5 fe ff ff       	call   7a2 <morecore>
 8bd:	83 c4 10             	add    $0x10,%esp
 8c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c7:	75 07                	jne    8d0 <malloc+0xce>
        return 0;
 8c9:	b8 00 00 00 00       	mov    $0x0,%eax
 8ce:	eb 13                	jmp    8e3 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d9:	8b 00                	mov    (%eax),%eax
 8db:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8de:	e9 6d ff ff ff       	jmp    850 <malloc+0x4e>
}
 8e3:	c9                   	leave  
 8e4:	c3                   	ret    
