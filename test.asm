
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
  int pid,fd;
  char path[16];
  pid = getpid();
  c5:	e8 30 03 00 00       	call   3fa <getpid>
  ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  strcpy(path, "/proc/");
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	68 a3 08 00 00       	push   $0x8a3
  d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  d8:	50                   	push   %eax
  d9:	e8 6c 00 00 00       	call   14a <strcpy>
  de:	83 c4 10             	add    $0x10,%esp
  itoa(pid, path+6);
  e1:	83 ec 08             	sub    $0x8,%esp
  e4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  e7:	83 c0 06             	add    $0x6,%eax
  ea:	50                   	push   %eax
  eb:	ff 75 f4             	pushl  -0xc(%ebp)
  ee:	e8 0d ff ff ff       	call   0 <itoa>
  f3:	83 c4 10             	add    $0x10,%esp
  fd = open("asdf", O_RDONLY);
  f6:	83 ec 08             	sub    $0x8,%esp
  f9:	6a 00                	push   $0x0
  fb:	68 aa 08 00 00       	push   $0x8aa
 100:	e8 b5 02 00 00       	call   3ba <open>
 105:	83 c4 10             	add    $0x10,%esp
 108:	89 45 f0             	mov    %eax,-0x10(%ebp)

  printf(1, "fd: %d\n", fd);
 10b:	83 ec 04             	sub    $0x4,%esp
 10e:	ff 75 f0             	pushl  -0x10(%ebp)
 111:	68 af 08 00 00       	push   $0x8af
 116:	6a 01                	push   $0x1
 118:	e8 d2 03 00 00       	call   4ef <printf>
 11d:	83 c4 10             	add    $0x10,%esp


  exit();
 120:	e8 55 02 00 00       	call   37a <exit>

00000125 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 125:	55                   	push   %ebp
 126:	89 e5                	mov    %esp,%ebp
 128:	57                   	push   %edi
 129:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 12a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12d:	8b 55 10             	mov    0x10(%ebp),%edx
 130:	8b 45 0c             	mov    0xc(%ebp),%eax
 133:	89 cb                	mov    %ecx,%ebx
 135:	89 df                	mov    %ebx,%edi
 137:	89 d1                	mov    %edx,%ecx
 139:	fc                   	cld    
 13a:	f3 aa                	rep stos %al,%es:(%edi)
 13c:	89 ca                	mov    %ecx,%edx
 13e:	89 fb                	mov    %edi,%ebx
 140:	89 5d 08             	mov    %ebx,0x8(%ebp)
 143:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 146:	5b                   	pop    %ebx
 147:	5f                   	pop    %edi
 148:	5d                   	pop    %ebp
 149:	c3                   	ret    

0000014a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 156:	90                   	nop
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	8d 50 01             	lea    0x1(%eax),%edx
 15d:	89 55 08             	mov    %edx,0x8(%ebp)
 160:	8b 55 0c             	mov    0xc(%ebp),%edx
 163:	8d 4a 01             	lea    0x1(%edx),%ecx
 166:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 169:	0f b6 12             	movzbl (%edx),%edx
 16c:	88 10                	mov    %dl,(%eax)
 16e:	0f b6 00             	movzbl (%eax),%eax
 171:	84 c0                	test   %al,%al
 173:	75 e2                	jne    157 <strcpy+0xd>
    ;
  return os;
 175:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 178:	c9                   	leave  
 179:	c3                   	ret    

0000017a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17d:	eb 08                	jmp    187 <strcmp+0xd>
    p++, q++;
 17f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 183:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	0f b6 00             	movzbl (%eax),%eax
 18d:	84 c0                	test   %al,%al
 18f:	74 10                	je     1a1 <strcmp+0x27>
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	0f b6 10             	movzbl (%eax),%edx
 197:	8b 45 0c             	mov    0xc(%ebp),%eax
 19a:	0f b6 00             	movzbl (%eax),%eax
 19d:	38 c2                	cmp    %al,%dl
 19f:	74 de                	je     17f <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	0f b6 d0             	movzbl %al,%edx
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	0f b6 00             	movzbl (%eax),%eax
 1b0:	0f b6 c0             	movzbl %al,%eax
 1b3:	29 c2                	sub    %eax,%edx
 1b5:	89 d0                	mov    %edx,%eax
}
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <strlen>:

uint
strlen(char *s)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c6:	eb 04                	jmp    1cc <strlen+0x13>
 1c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	01 d0                	add    %edx,%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	84 c0                	test   %al,%al
 1d9:	75 ed                	jne    1c8 <strlen+0xf>
    ;
  return n;
 1db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1de:	c9                   	leave  
 1df:	c3                   	ret    

000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1e3:	8b 45 10             	mov    0x10(%ebp),%eax
 1e6:	50                   	push   %eax
 1e7:	ff 75 0c             	pushl  0xc(%ebp)
 1ea:	ff 75 08             	pushl  0x8(%ebp)
 1ed:	e8 33 ff ff ff       	call   125 <stosb>
 1f2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f8:	c9                   	leave  
 1f9:	c3                   	ret    

000001fa <strchr>:

char*
strchr(const char *s, char c)
{
 1fa:	55                   	push   %ebp
 1fb:	89 e5                	mov    %esp,%ebp
 1fd:	83 ec 04             	sub    $0x4,%esp
 200:	8b 45 0c             	mov    0xc(%ebp),%eax
 203:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 206:	eb 14                	jmp    21c <strchr+0x22>
    if(*s == c)
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	0f b6 00             	movzbl (%eax),%eax
 20e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 211:	75 05                	jne    218 <strchr+0x1e>
      return (char*)s;
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	eb 13                	jmp    22b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 218:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	0f b6 00             	movzbl (%eax),%eax
 222:	84 c0                	test   %al,%al
 224:	75 e2                	jne    208 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 226:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22b:	c9                   	leave  
 22c:	c3                   	ret    

0000022d <gets>:

char*
gets(char *buf, int max)
{
 22d:	55                   	push   %ebp
 22e:	89 e5                	mov    %esp,%ebp
 230:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 233:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23a:	eb 44                	jmp    280 <gets+0x53>
    cc = read(0, &c, 1);
 23c:	83 ec 04             	sub    $0x4,%esp
 23f:	6a 01                	push   $0x1
 241:	8d 45 ef             	lea    -0x11(%ebp),%eax
 244:	50                   	push   %eax
 245:	6a 00                	push   $0x0
 247:	e8 46 01 00 00       	call   392 <read>
 24c:	83 c4 10             	add    $0x10,%esp
 24f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 252:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 256:	7f 02                	jg     25a <gets+0x2d>
      break;
 258:	eb 31                	jmp    28b <gets+0x5e>
    buf[i++] = c;
 25a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25d:	8d 50 01             	lea    0x1(%eax),%edx
 260:	89 55 f4             	mov    %edx,-0xc(%ebp)
 263:	89 c2                	mov    %eax,%edx
 265:	8b 45 08             	mov    0x8(%ebp),%eax
 268:	01 c2                	add    %eax,%edx
 26a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 270:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 274:	3c 0a                	cmp    $0xa,%al
 276:	74 13                	je     28b <gets+0x5e>
 278:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27c:	3c 0d                	cmp    $0xd,%al
 27e:	74 0b                	je     28b <gets+0x5e>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 280:	8b 45 f4             	mov    -0xc(%ebp),%eax
 283:	83 c0 01             	add    $0x1,%eax
 286:	3b 45 0c             	cmp    0xc(%ebp),%eax
 289:	7c b1                	jl     23c <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	01 d0                	add    %edx,%eax
 293:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 296:	8b 45 08             	mov    0x8(%ebp),%eax
}
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <stat>:

int
stat(char *n, struct stat *st)
{
 29b:	55                   	push   %ebp
 29c:	89 e5                	mov    %esp,%ebp
 29e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a1:	83 ec 08             	sub    $0x8,%esp
 2a4:	6a 00                	push   $0x0
 2a6:	ff 75 08             	pushl  0x8(%ebp)
 2a9:	e8 0c 01 00 00       	call   3ba <open>
 2ae:	83 c4 10             	add    $0x10,%esp
 2b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b8:	79 07                	jns    2c1 <stat+0x26>
    return -1;
 2ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bf:	eb 25                	jmp    2e6 <stat+0x4b>
  r = fstat(fd, st);
 2c1:	83 ec 08             	sub    $0x8,%esp
 2c4:	ff 75 0c             	pushl  0xc(%ebp)
 2c7:	ff 75 f4             	pushl  -0xc(%ebp)
 2ca:	e8 03 01 00 00       	call   3d2 <fstat>
 2cf:	83 c4 10             	add    $0x10,%esp
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	83 ec 0c             	sub    $0xc,%esp
 2d8:	ff 75 f4             	pushl  -0xc(%ebp)
 2db:	e8 c2 00 00 00       	call   3a2 <close>
 2e0:	83 c4 10             	add    $0x10,%esp
  return r;
 2e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e6:	c9                   	leave  
 2e7:	c3                   	ret    

000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f5:	eb 25                	jmp    31c <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fa:	89 d0                	mov    %edx,%eax
 2fc:	c1 e0 02             	shl    $0x2,%eax
 2ff:	01 d0                	add    %edx,%eax
 301:	01 c0                	add    %eax,%eax
 303:	89 c1                	mov    %eax,%ecx
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	8d 50 01             	lea    0x1(%eax),%edx
 30b:	89 55 08             	mov    %edx,0x8(%ebp)
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	0f be c0             	movsbl %al,%eax
 314:	01 c8                	add    %ecx,%eax
 316:	83 e8 30             	sub    $0x30,%eax
 319:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 00             	movzbl (%eax),%eax
 322:	3c 2f                	cmp    $0x2f,%al
 324:	7e 0a                	jle    330 <atoi+0x48>
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	3c 39                	cmp    $0x39,%al
 32e:	7e c7                	jle    2f7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 330:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 341:	8b 45 0c             	mov    0xc(%ebp),%eax
 344:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 347:	eb 17                	jmp    360 <memmove+0x2b>
    *dst++ = *src++;
 349:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34c:	8d 50 01             	lea    0x1(%eax),%edx
 34f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 352:	8b 55 f8             	mov    -0x8(%ebp),%edx
 355:	8d 4a 01             	lea    0x1(%edx),%ecx
 358:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 35b:	0f b6 12             	movzbl (%edx),%edx
 35e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 360:	8b 45 10             	mov    0x10(%ebp),%eax
 363:	8d 50 ff             	lea    -0x1(%eax),%edx
 366:	89 55 10             	mov    %edx,0x10(%ebp)
 369:	85 c0                	test   %eax,%eax
 36b:	7f dc                	jg     349 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 370:	c9                   	leave  
 371:	c3                   	ret    

00000372 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 372:	b8 01 00 00 00       	mov    $0x1,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <exit>:
SYSCALL(exit)
 37a:	b8 02 00 00 00       	mov    $0x2,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <wait>:
SYSCALL(wait)
 382:	b8 03 00 00 00       	mov    $0x3,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <pipe>:
SYSCALL(pipe)
 38a:	b8 04 00 00 00       	mov    $0x4,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <read>:
SYSCALL(read)
 392:	b8 05 00 00 00       	mov    $0x5,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <write>:
SYSCALL(write)
 39a:	b8 10 00 00 00       	mov    $0x10,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <close>:
SYSCALL(close)
 3a2:	b8 15 00 00 00       	mov    $0x15,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <kill>:
SYSCALL(kill)
 3aa:	b8 06 00 00 00       	mov    $0x6,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <exec>:
SYSCALL(exec)
 3b2:	b8 07 00 00 00       	mov    $0x7,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <open>:
SYSCALL(open)
 3ba:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <mknod>:
SYSCALL(mknod)
 3c2:	b8 11 00 00 00       	mov    $0x11,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <unlink>:
SYSCALL(unlink)
 3ca:	b8 12 00 00 00       	mov    $0x12,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <fstat>:
SYSCALL(fstat)
 3d2:	b8 08 00 00 00       	mov    $0x8,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <link>:
SYSCALL(link)
 3da:	b8 13 00 00 00       	mov    $0x13,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <mkdir>:
SYSCALL(mkdir)
 3e2:	b8 14 00 00 00       	mov    $0x14,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <chdir>:
SYSCALL(chdir)
 3ea:	b8 09 00 00 00       	mov    $0x9,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <dup>:
SYSCALL(dup)
 3f2:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <getpid>:
SYSCALL(getpid)
 3fa:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <sbrk>:
SYSCALL(sbrk)
 402:	b8 0c 00 00 00       	mov    $0xc,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <sleep>:
SYSCALL(sleep)
 40a:	b8 0d 00 00 00       	mov    $0xd,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <uptime>:
SYSCALL(uptime)
 412:	b8 0e 00 00 00       	mov    $0xe,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41a:	55                   	push   %ebp
 41b:	89 e5                	mov    %esp,%ebp
 41d:	83 ec 18             	sub    $0x18,%esp
 420:	8b 45 0c             	mov    0xc(%ebp),%eax
 423:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 426:	83 ec 04             	sub    $0x4,%esp
 429:	6a 01                	push   $0x1
 42b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42e:	50                   	push   %eax
 42f:	ff 75 08             	pushl  0x8(%ebp)
 432:	e8 63 ff ff ff       	call   39a <write>
 437:	83 c4 10             	add    $0x10,%esp
}
 43a:	c9                   	leave  
 43b:	c3                   	ret    

0000043c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43c:	55                   	push   %ebp
 43d:	89 e5                	mov    %esp,%ebp
 43f:	53                   	push   %ebx
 440:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 443:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 44a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 44e:	74 17                	je     467 <printint+0x2b>
 450:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 454:	79 11                	jns    467 <printint+0x2b>
    neg = 1;
 456:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 45d:	8b 45 0c             	mov    0xc(%ebp),%eax
 460:	f7 d8                	neg    %eax
 462:	89 45 ec             	mov    %eax,-0x14(%ebp)
 465:	eb 06                	jmp    46d <printint+0x31>
  } else {
    x = xx;
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 46d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 474:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 477:	8d 41 01             	lea    0x1(%ecx),%eax
 47a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 47d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 480:	8b 45 ec             	mov    -0x14(%ebp),%eax
 483:	ba 00 00 00 00       	mov    $0x0,%edx
 488:	f7 f3                	div    %ebx
 48a:	89 d0                	mov    %edx,%eax
 48c:	0f b6 80 2c 0b 00 00 	movzbl 0xb2c(%eax),%eax
 493:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 497:	8b 5d 10             	mov    0x10(%ebp),%ebx
 49a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49d:	ba 00 00 00 00       	mov    $0x0,%edx
 4a2:	f7 f3                	div    %ebx
 4a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ab:	75 c7                	jne    474 <printint+0x38>
  if(neg)
 4ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b1:	74 0e                	je     4c1 <printint+0x85>
    buf[i++] = '-';
 4b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b6:	8d 50 01             	lea    0x1(%eax),%edx
 4b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4bc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4c1:	eb 1d                	jmp    4e0 <printint+0xa4>
    putc(fd, buf[i]);
 4c3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c9:	01 d0                	add    %edx,%eax
 4cb:	0f b6 00             	movzbl (%eax),%eax
 4ce:	0f be c0             	movsbl %al,%eax
 4d1:	83 ec 08             	sub    $0x8,%esp
 4d4:	50                   	push   %eax
 4d5:	ff 75 08             	pushl  0x8(%ebp)
 4d8:	e8 3d ff ff ff       	call   41a <putc>
 4dd:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e8:	79 d9                	jns    4c3 <printint+0x87>
    putc(fd, buf[i]);
}
 4ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4ed:	c9                   	leave  
 4ee:	c3                   	ret    

000004ef <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4fc:	8d 45 0c             	lea    0xc(%ebp),%eax
 4ff:	83 c0 04             	add    $0x4,%eax
 502:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 505:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 50c:	e9 59 01 00 00       	jmp    66a <printf+0x17b>
    c = fmt[i] & 0xff;
 511:	8b 55 0c             	mov    0xc(%ebp),%edx
 514:	8b 45 f0             	mov    -0x10(%ebp),%eax
 517:	01 d0                	add    %edx,%eax
 519:	0f b6 00             	movzbl (%eax),%eax
 51c:	0f be c0             	movsbl %al,%eax
 51f:	25 ff 00 00 00       	and    $0xff,%eax
 524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 527:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52b:	75 2c                	jne    559 <printf+0x6a>
      if(c == '%'){
 52d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 531:	75 0c                	jne    53f <printf+0x50>
        state = '%';
 533:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 53a:	e9 27 01 00 00       	jmp    666 <printf+0x177>
      } else {
        putc(fd, c);
 53f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 542:	0f be c0             	movsbl %al,%eax
 545:	83 ec 08             	sub    $0x8,%esp
 548:	50                   	push   %eax
 549:	ff 75 08             	pushl  0x8(%ebp)
 54c:	e8 c9 fe ff ff       	call   41a <putc>
 551:	83 c4 10             	add    $0x10,%esp
 554:	e9 0d 01 00 00       	jmp    666 <printf+0x177>
      }
    } else if(state == '%'){
 559:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 55d:	0f 85 03 01 00 00    	jne    666 <printf+0x177>
      if(c == 'd'){
 563:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 567:	75 1e                	jne    587 <printf+0x98>
        printint(fd, *ap, 10, 1);
 569:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56c:	8b 00                	mov    (%eax),%eax
 56e:	6a 01                	push   $0x1
 570:	6a 0a                	push   $0xa
 572:	50                   	push   %eax
 573:	ff 75 08             	pushl  0x8(%ebp)
 576:	e8 c1 fe ff ff       	call   43c <printint>
 57b:	83 c4 10             	add    $0x10,%esp
        ap++;
 57e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 582:	e9 d8 00 00 00       	jmp    65f <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 587:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 58b:	74 06                	je     593 <printf+0xa4>
 58d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 591:	75 1e                	jne    5b1 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 593:	8b 45 e8             	mov    -0x18(%ebp),%eax
 596:	8b 00                	mov    (%eax),%eax
 598:	6a 00                	push   $0x0
 59a:	6a 10                	push   $0x10
 59c:	50                   	push   %eax
 59d:	ff 75 08             	pushl  0x8(%ebp)
 5a0:	e8 97 fe ff ff       	call   43c <printint>
 5a5:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ac:	e9 ae 00 00 00       	jmp    65f <printf+0x170>
      } else if(c == 's'){
 5b1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b5:	75 43                	jne    5fa <printf+0x10b>
        s = (char*)*ap;
 5b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ba:	8b 00                	mov    (%eax),%eax
 5bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c7:	75 07                	jne    5d0 <printf+0xe1>
          s = "(null)";
 5c9:	c7 45 f4 b7 08 00 00 	movl   $0x8b7,-0xc(%ebp)
        while(*s != 0){
 5d0:	eb 1c                	jmp    5ee <printf+0xff>
          putc(fd, *s);
 5d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d5:	0f b6 00             	movzbl (%eax),%eax
 5d8:	0f be c0             	movsbl %al,%eax
 5db:	83 ec 08             	sub    $0x8,%esp
 5de:	50                   	push   %eax
 5df:	ff 75 08             	pushl  0x8(%ebp)
 5e2:	e8 33 fe ff ff       	call   41a <putc>
 5e7:	83 c4 10             	add    $0x10,%esp
          s++;
 5ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f1:	0f b6 00             	movzbl (%eax),%eax
 5f4:	84 c0                	test   %al,%al
 5f6:	75 da                	jne    5d2 <printf+0xe3>
 5f8:	eb 65                	jmp    65f <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5fa:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5fe:	75 1d                	jne    61d <printf+0x12e>
        putc(fd, *ap);
 600:	8b 45 e8             	mov    -0x18(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	0f be c0             	movsbl %al,%eax
 608:	83 ec 08             	sub    $0x8,%esp
 60b:	50                   	push   %eax
 60c:	ff 75 08             	pushl  0x8(%ebp)
 60f:	e8 06 fe ff ff       	call   41a <putc>
 614:	83 c4 10             	add    $0x10,%esp
        ap++;
 617:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61b:	eb 42                	jmp    65f <printf+0x170>
      } else if(c == '%'){
 61d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 621:	75 17                	jne    63a <printf+0x14b>
        putc(fd, c);
 623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 626:	0f be c0             	movsbl %al,%eax
 629:	83 ec 08             	sub    $0x8,%esp
 62c:	50                   	push   %eax
 62d:	ff 75 08             	pushl  0x8(%ebp)
 630:	e8 e5 fd ff ff       	call   41a <putc>
 635:	83 c4 10             	add    $0x10,%esp
 638:	eb 25                	jmp    65f <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 63a:	83 ec 08             	sub    $0x8,%esp
 63d:	6a 25                	push   $0x25
 63f:	ff 75 08             	pushl  0x8(%ebp)
 642:	e8 d3 fd ff ff       	call   41a <putc>
 647:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	83 ec 08             	sub    $0x8,%esp
 653:	50                   	push   %eax
 654:	ff 75 08             	pushl  0x8(%ebp)
 657:	e8 be fd ff ff       	call   41a <putc>
 65c:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 65f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 666:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 66a:	8b 55 0c             	mov    0xc(%ebp),%edx
 66d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 670:	01 d0                	add    %edx,%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	84 c0                	test   %al,%al
 677:	0f 85 94 fe ff ff    	jne    511 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 67d:	c9                   	leave  
 67e:	c3                   	ret    

0000067f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67f:	55                   	push   %ebp
 680:	89 e5                	mov    %esp,%ebp
 682:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	83 e8 08             	sub    $0x8,%eax
 68b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68e:	a1 48 0b 00 00       	mov    0xb48,%eax
 693:	89 45 fc             	mov    %eax,-0x4(%ebp)
 696:	eb 24                	jmp    6bc <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	8b 00                	mov    (%eax),%eax
 69d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a0:	77 12                	ja     6b4 <free+0x35>
 6a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a8:	77 24                	ja     6ce <free+0x4f>
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	8b 00                	mov    (%eax),%eax
 6af:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b2:	77 1a                	ja     6ce <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c2:	76 d4                	jbe    698 <free+0x19>
 6c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c7:	8b 00                	mov    (%eax),%eax
 6c9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cc:	76 ca                	jbe    698 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d1:	8b 40 04             	mov    0x4(%eax),%eax
 6d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	01 c2                	add    %eax,%edx
 6e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e3:	8b 00                	mov    (%eax),%eax
 6e5:	39 c2                	cmp    %eax,%edx
 6e7:	75 24                	jne    70d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	8b 50 04             	mov    0x4(%eax),%edx
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	8b 00                	mov    (%eax),%eax
 6f4:	8b 40 04             	mov    0x4(%eax),%eax
 6f7:	01 c2                	add    %eax,%edx
 6f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fc:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	8b 10                	mov    (%eax),%edx
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	89 10                	mov    %edx,(%eax)
 70b:	eb 0a                	jmp    717 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 10                	mov    (%eax),%edx
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	8b 40 04             	mov    0x4(%eax),%eax
 71d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	01 d0                	add    %edx,%eax
 729:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72c:	75 20                	jne    74e <free+0xcf>
    p->s.size += bp->s.size;
 72e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 731:	8b 50 04             	mov    0x4(%eax),%edx
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	8b 40 04             	mov    0x4(%eax),%eax
 73a:	01 c2                	add    %eax,%edx
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	8b 10                	mov    (%eax),%edx
 747:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74a:	89 10                	mov    %edx,(%eax)
 74c:	eb 08                	jmp    756 <free+0xd7>
  } else
    p->s.ptr = bp;
 74e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 751:	8b 55 f8             	mov    -0x8(%ebp),%edx
 754:	89 10                	mov    %edx,(%eax)
  freep = p;
 756:	8b 45 fc             	mov    -0x4(%ebp),%eax
 759:	a3 48 0b 00 00       	mov    %eax,0xb48
}
 75e:	c9                   	leave  
 75f:	c3                   	ret    

00000760 <morecore>:

static Header*
morecore(uint nu)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 766:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 76d:	77 07                	ja     776 <morecore+0x16>
    nu = 4096;
 76f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 776:	8b 45 08             	mov    0x8(%ebp),%eax
 779:	c1 e0 03             	shl    $0x3,%eax
 77c:	83 ec 0c             	sub    $0xc,%esp
 77f:	50                   	push   %eax
 780:	e8 7d fc ff ff       	call   402 <sbrk>
 785:	83 c4 10             	add    $0x10,%esp
 788:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 78b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 78f:	75 07                	jne    798 <morecore+0x38>
    return 0;
 791:	b8 00 00 00 00       	mov    $0x0,%eax
 796:	eb 26                	jmp    7be <morecore+0x5e>
  hp = (Header*)p;
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 79e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a1:	8b 55 08             	mov    0x8(%ebp),%edx
 7a4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	83 c0 08             	add    $0x8,%eax
 7ad:	83 ec 0c             	sub    $0xc,%esp
 7b0:	50                   	push   %eax
 7b1:	e8 c9 fe ff ff       	call   67f <free>
 7b6:	83 c4 10             	add    $0x10,%esp
  return freep;
 7b9:	a1 48 0b 00 00       	mov    0xb48,%eax
}
 7be:	c9                   	leave  
 7bf:	c3                   	ret    

000007c0 <malloc>:

void*
malloc(uint nbytes)
{
 7c0:	55                   	push   %ebp
 7c1:	89 e5                	mov    %esp,%ebp
 7c3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c6:	8b 45 08             	mov    0x8(%ebp),%eax
 7c9:	83 c0 07             	add    $0x7,%eax
 7cc:	c1 e8 03             	shr    $0x3,%eax
 7cf:	83 c0 01             	add    $0x1,%eax
 7d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d5:	a1 48 0b 00 00       	mov    0xb48,%eax
 7da:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e1:	75 23                	jne    806 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7e3:	c7 45 f0 40 0b 00 00 	movl   $0xb40,-0x10(%ebp)
 7ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ed:	a3 48 0b 00 00       	mov    %eax,0xb48
 7f2:	a1 48 0b 00 00       	mov    0xb48,%eax
 7f7:	a3 40 0b 00 00       	mov    %eax,0xb40
    base.s.size = 0;
 7fc:	c7 05 44 0b 00 00 00 	movl   $0x0,0xb44
 803:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 806:	8b 45 f0             	mov    -0x10(%ebp),%eax
 809:	8b 00                	mov    (%eax),%eax
 80b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 817:	72 4d                	jb     866 <malloc+0xa6>
      if(p->s.size == nunits)
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8b 40 04             	mov    0x4(%eax),%eax
 81f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 822:	75 0c                	jne    830 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 824:	8b 45 f4             	mov    -0xc(%ebp),%eax
 827:	8b 10                	mov    (%eax),%edx
 829:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82c:	89 10                	mov    %edx,(%eax)
 82e:	eb 26                	jmp    856 <malloc+0x96>
      else {
        p->s.size -= nunits;
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	2b 45 ec             	sub    -0x14(%ebp),%eax
 839:	89 c2                	mov    %eax,%edx
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	8b 40 04             	mov    0x4(%eax),%eax
 847:	c1 e0 03             	shl    $0x3,%eax
 84a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	8b 55 ec             	mov    -0x14(%ebp),%edx
 853:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 856:	8b 45 f0             	mov    -0x10(%ebp),%eax
 859:	a3 48 0b 00 00       	mov    %eax,0xb48
      return (void*)(p + 1);
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	83 c0 08             	add    $0x8,%eax
 864:	eb 3b                	jmp    8a1 <malloc+0xe1>
    }
    if(p == freep)
 866:	a1 48 0b 00 00       	mov    0xb48,%eax
 86b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 86e:	75 1e                	jne    88e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 870:	83 ec 0c             	sub    $0xc,%esp
 873:	ff 75 ec             	pushl  -0x14(%ebp)
 876:	e8 e5 fe ff ff       	call   760 <morecore>
 87b:	83 c4 10             	add    $0x10,%esp
 87e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 885:	75 07                	jne    88e <malloc+0xce>
        return 0;
 887:	b8 00 00 00 00       	mov    $0x0,%eax
 88c:	eb 13                	jmp    8a1 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 45 f0             	mov    %eax,-0x10(%ebp)
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 00                	mov    (%eax),%eax
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 89c:	e9 6d ff ff ff       	jmp    80e <malloc+0x4e>
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    
