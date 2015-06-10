
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  mknod("proc", 2, 0);
  11:	83 ec 04             	sub    $0x4,%esp
  14:	6a 00                	push   $0x0
  16:	6a 02                	push   $0x2
  18:	68 94 08 00 00       	push   $0x894
  1d:	e8 8e 03 00 00       	call   3b0 <mknod>
  22:	83 c4 10             	add    $0x10,%esp

  if(open("console", O_RDWR) < 0){
  25:	83 ec 08             	sub    $0x8,%esp
  28:	6a 02                	push   $0x2
  2a:	68 99 08 00 00       	push   $0x899
  2f:	e8 74 03 00 00       	call   3a8 <open>
  34:	83 c4 10             	add    $0x10,%esp
  37:	85 c0                	test   %eax,%eax
  39:	79 26                	jns    61 <main+0x61>
    mknod("console", 1, 1);
  3b:	83 ec 04             	sub    $0x4,%esp
  3e:	6a 01                	push   $0x1
  40:	6a 01                	push   $0x1
  42:	68 99 08 00 00       	push   $0x899
  47:	e8 64 03 00 00       	call   3b0 <mknod>
  4c:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	6a 02                	push   $0x2
  54:	68 99 08 00 00       	push   $0x899
  59:	e8 4a 03 00 00       	call   3a8 <open>
  5e:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  61:	83 ec 0c             	sub    $0xc,%esp
  64:	6a 00                	push   $0x0
  66:	e8 75 03 00 00       	call   3e0 <dup>
  6b:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  6e:	83 ec 0c             	sub    $0xc,%esp
  71:	6a 00                	push   $0x0
  73:	e8 68 03 00 00       	call   3e0 <dup>
  78:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 a1 08 00 00       	push   $0x8a1
  83:	6a 01                	push   $0x1
  85:	e8 53 04 00 00       	call   4dd <printf>
  8a:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  8d:	e8 ce 02 00 00       	call   360 <fork>
  92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  99:	79 17                	jns    b2 <main+0xb2>
      printf(1, "init: fork failed\n");
  9b:	83 ec 08             	sub    $0x8,%esp
  9e:	68 b4 08 00 00       	push   $0x8b4
  a3:	6a 01                	push   $0x1
  a5:	e8 33 04 00 00       	call   4dd <printf>
  aa:	83 c4 10             	add    $0x10,%esp
      exit();
  ad:	e8 b6 02 00 00       	call   368 <exit>
    }
    if(pid == 0){
  b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  b6:	75 2c                	jne    e4 <main+0xe4>
      exec("sh", argv);
  b8:	83 ec 08             	sub    $0x8,%esp
  bb:	68 38 0b 00 00       	push   $0xb38
  c0:	68 91 08 00 00       	push   $0x891
  c5:	e8 d6 02 00 00       	call   3a0 <exec>
  ca:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	68 c7 08 00 00       	push   $0x8c7
  d5:	6a 01                	push   $0x1
  d7:	e8 01 04 00 00       	call   4dd <printf>
  dc:	83 c4 10             	add    $0x10,%esp
      exit();
  df:	e8 84 02 00 00       	call   368 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  e4:	eb 12                	jmp    f8 <main+0xf8>
      printf(1, "zombie!\n");
  e6:	83 ec 08             	sub    $0x8,%esp
  e9:	68 dd 08 00 00       	push   $0x8dd
  ee:	6a 01                	push   $0x1
  f0:	e8 e8 03 00 00       	call   4dd <printf>
  f5:	83 c4 10             	add    $0x10,%esp
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f8:	e8 73 02 00 00       	call   370 <wait>
  fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 100:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 104:	78 08                	js     10e <main+0x10e>
 106:	8b 45 f0             	mov    -0x10(%ebp),%eax
 109:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 10c:	75 d8                	jne    e6 <main+0xe6>
      printf(1, "zombie!\n");
  }
 10e:	e9 68 ff ff ff       	jmp    7b <main+0x7b>

00000113 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 113:	55                   	push   %ebp
 114:	89 e5                	mov    %esp,%ebp
 116:	57                   	push   %edi
 117:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 118:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11b:	8b 55 10             	mov    0x10(%ebp),%edx
 11e:	8b 45 0c             	mov    0xc(%ebp),%eax
 121:	89 cb                	mov    %ecx,%ebx
 123:	89 df                	mov    %ebx,%edi
 125:	89 d1                	mov    %edx,%ecx
 127:	fc                   	cld    
 128:	f3 aa                	rep stos %al,%es:(%edi)
 12a:	89 ca                	mov    %ecx,%edx
 12c:	89 fb                	mov    %edi,%ebx
 12e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 131:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 134:	5b                   	pop    %ebx
 135:	5f                   	pop    %edi
 136:	5d                   	pop    %ebp
 137:	c3                   	ret    

00000138 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
 13b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13e:	8b 45 08             	mov    0x8(%ebp),%eax
 141:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 144:	90                   	nop
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	8d 50 01             	lea    0x1(%eax),%edx
 14b:	89 55 08             	mov    %edx,0x8(%ebp)
 14e:	8b 55 0c             	mov    0xc(%ebp),%edx
 151:	8d 4a 01             	lea    0x1(%edx),%ecx
 154:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 157:	0f b6 12             	movzbl (%edx),%edx
 15a:	88 10                	mov    %dl,(%eax)
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	84 c0                	test   %al,%al
 161:	75 e2                	jne    145 <strcpy+0xd>
    ;
  return os;
 163:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 166:	c9                   	leave  
 167:	c3                   	ret    

00000168 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 168:	55                   	push   %ebp
 169:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16b:	eb 08                	jmp    175 <strcmp+0xd>
    p++, q++;
 16d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 171:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	84 c0                	test   %al,%al
 17d:	74 10                	je     18f <strcmp+0x27>
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 10             	movzbl (%eax),%edx
 185:	8b 45 0c             	mov    0xc(%ebp),%eax
 188:	0f b6 00             	movzbl (%eax),%eax
 18b:	38 c2                	cmp    %al,%dl
 18d:	74 de                	je     16d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	0f b6 00             	movzbl (%eax),%eax
 195:	0f b6 d0             	movzbl %al,%edx
 198:	8b 45 0c             	mov    0xc(%ebp),%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	0f b6 c0             	movzbl %al,%eax
 1a1:	29 c2                	sub    %eax,%edx
 1a3:	89 d0                	mov    %edx,%eax
}
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    

000001a7 <strlen>:

uint
strlen(char *s)
{
 1a7:	55                   	push   %ebp
 1a8:	89 e5                	mov    %esp,%ebp
 1aa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b4:	eb 04                	jmp    1ba <strlen+0x13>
 1b6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	01 d0                	add    %edx,%eax
 1c2:	0f b6 00             	movzbl (%eax),%eax
 1c5:	84 c0                	test   %al,%al
 1c7:	75 ed                	jne    1b6 <strlen+0xf>
    ;
  return n;
 1c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1cc:	c9                   	leave  
 1cd:	c3                   	ret    

000001ce <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1d1:	8b 45 10             	mov    0x10(%ebp),%eax
 1d4:	50                   	push   %eax
 1d5:	ff 75 0c             	pushl  0xc(%ebp)
 1d8:	ff 75 08             	pushl  0x8(%ebp)
 1db:	e8 33 ff ff ff       	call   113 <stosb>
 1e0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e6:	c9                   	leave  
 1e7:	c3                   	ret    

000001e8 <strchr>:

char*
strchr(const char *s, char c)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 04             	sub    $0x4,%esp
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f4:	eb 14                	jmp    20a <strchr+0x22>
    if(*s == c)
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	0f b6 00             	movzbl (%eax),%eax
 1fc:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ff:	75 05                	jne    206 <strchr+0x1e>
      return (char*)s;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	eb 13                	jmp    219 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 206:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	0f b6 00             	movzbl (%eax),%eax
 210:	84 c0                	test   %al,%al
 212:	75 e2                	jne    1f6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 214:	b8 00 00 00 00       	mov    $0x0,%eax
}
 219:	c9                   	leave  
 21a:	c3                   	ret    

0000021b <gets>:

char*
gets(char *buf, int max)
{
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 228:	eb 44                	jmp    26e <gets+0x53>
    cc = read(0, &c, 1);
 22a:	83 ec 04             	sub    $0x4,%esp
 22d:	6a 01                	push   $0x1
 22f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 232:	50                   	push   %eax
 233:	6a 00                	push   $0x0
 235:	e8 46 01 00 00       	call   380 <read>
 23a:	83 c4 10             	add    $0x10,%esp
 23d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 240:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 244:	7f 02                	jg     248 <gets+0x2d>
      break;
 246:	eb 31                	jmp    279 <gets+0x5e>
    buf[i++] = c;
 248:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24b:	8d 50 01             	lea    0x1(%eax),%edx
 24e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 251:	89 c2                	mov    %eax,%edx
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	01 c2                	add    %eax,%edx
 258:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 25e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 262:	3c 0a                	cmp    $0xa,%al
 264:	74 13                	je     279 <gets+0x5e>
 266:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26a:	3c 0d                	cmp    $0xd,%al
 26c:	74 0b                	je     279 <gets+0x5e>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 271:	83 c0 01             	add    $0x1,%eax
 274:	3b 45 0c             	cmp    0xc(%ebp),%eax
 277:	7c b1                	jl     22a <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 279:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <stat>:

int
stat(char *n, struct stat *st)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28f:	83 ec 08             	sub    $0x8,%esp
 292:	6a 00                	push   $0x0
 294:	ff 75 08             	pushl  0x8(%ebp)
 297:	e8 0c 01 00 00       	call   3a8 <open>
 29c:	83 c4 10             	add    $0x10,%esp
 29f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a6:	79 07                	jns    2af <stat+0x26>
    return -1;
 2a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ad:	eb 25                	jmp    2d4 <stat+0x4b>
  r = fstat(fd, st);
 2af:	83 ec 08             	sub    $0x8,%esp
 2b2:	ff 75 0c             	pushl  0xc(%ebp)
 2b5:	ff 75 f4             	pushl  -0xc(%ebp)
 2b8:	e8 03 01 00 00       	call   3c0 <fstat>
 2bd:	83 c4 10             	add    $0x10,%esp
 2c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c3:	83 ec 0c             	sub    $0xc,%esp
 2c6:	ff 75 f4             	pushl  -0xc(%ebp)
 2c9:	e8 c2 00 00 00       	call   390 <close>
 2ce:	83 c4 10             	add    $0x10,%esp
  return r;
 2d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <atoi>:

int
atoi(const char *s)
{
 2d6:	55                   	push   %ebp
 2d7:	89 e5                	mov    %esp,%ebp
 2d9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e3:	eb 25                	jmp    30a <atoi+0x34>
    n = n*10 + *s++ - '0';
 2e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e8:	89 d0                	mov    %edx,%eax
 2ea:	c1 e0 02             	shl    $0x2,%eax
 2ed:	01 d0                	add    %edx,%eax
 2ef:	01 c0                	add    %eax,%eax
 2f1:	89 c1                	mov    %eax,%ecx
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	8d 50 01             	lea    0x1(%eax),%edx
 2f9:	89 55 08             	mov    %edx,0x8(%ebp)
 2fc:	0f b6 00             	movzbl (%eax),%eax
 2ff:	0f be c0             	movsbl %al,%eax
 302:	01 c8                	add    %ecx,%eax
 304:	83 e8 30             	sub    $0x30,%eax
 307:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	3c 2f                	cmp    $0x2f,%al
 312:	7e 0a                	jle    31e <atoi+0x48>
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	3c 39                	cmp    $0x39,%al
 31c:	7e c7                	jle    2e5 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 31e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 321:	c9                   	leave  
 322:	c3                   	ret    

00000323 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
 326:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32f:	8b 45 0c             	mov    0xc(%ebp),%eax
 332:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 335:	eb 17                	jmp    34e <memmove+0x2b>
    *dst++ = *src++;
 337:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33a:	8d 50 01             	lea    0x1(%eax),%edx
 33d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 340:	8b 55 f8             	mov    -0x8(%ebp),%edx
 343:	8d 4a 01             	lea    0x1(%edx),%ecx
 346:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 349:	0f b6 12             	movzbl (%edx),%edx
 34c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 34e:	8b 45 10             	mov    0x10(%ebp),%eax
 351:	8d 50 ff             	lea    -0x1(%eax),%edx
 354:	89 55 10             	mov    %edx,0x10(%ebp)
 357:	85 c0                	test   %eax,%eax
 359:	7f dc                	jg     337 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 35b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35e:	c9                   	leave  
 35f:	c3                   	ret    

00000360 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 360:	b8 01 00 00 00       	mov    $0x1,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <exit>:
SYSCALL(exit)
 368:	b8 02 00 00 00       	mov    $0x2,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <wait>:
SYSCALL(wait)
 370:	b8 03 00 00 00       	mov    $0x3,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <pipe>:
SYSCALL(pipe)
 378:	b8 04 00 00 00       	mov    $0x4,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <read>:
SYSCALL(read)
 380:	b8 05 00 00 00       	mov    $0x5,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <write>:
SYSCALL(write)
 388:	b8 10 00 00 00       	mov    $0x10,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <close>:
SYSCALL(close)
 390:	b8 15 00 00 00       	mov    $0x15,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <kill>:
SYSCALL(kill)
 398:	b8 06 00 00 00       	mov    $0x6,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <exec>:
SYSCALL(exec)
 3a0:	b8 07 00 00 00       	mov    $0x7,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <open>:
SYSCALL(open)
 3a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <mknod>:
SYSCALL(mknod)
 3b0:	b8 11 00 00 00       	mov    $0x11,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <unlink>:
SYSCALL(unlink)
 3b8:	b8 12 00 00 00       	mov    $0x12,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <fstat>:
SYSCALL(fstat)
 3c0:	b8 08 00 00 00       	mov    $0x8,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <link>:
SYSCALL(link)
 3c8:	b8 13 00 00 00       	mov    $0x13,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <mkdir>:
SYSCALL(mkdir)
 3d0:	b8 14 00 00 00       	mov    $0x14,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <chdir>:
SYSCALL(chdir)
 3d8:	b8 09 00 00 00       	mov    $0x9,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <dup>:
SYSCALL(dup)
 3e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <getpid>:
SYSCALL(getpid)
 3e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <sbrk>:
SYSCALL(sbrk)
 3f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <sleep>:
SYSCALL(sleep)
 3f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <uptime>:
SYSCALL(uptime)
 400:	b8 0e 00 00 00       	mov    $0xe,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	83 ec 18             	sub    $0x18,%esp
 40e:	8b 45 0c             	mov    0xc(%ebp),%eax
 411:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 414:	83 ec 04             	sub    $0x4,%esp
 417:	6a 01                	push   $0x1
 419:	8d 45 f4             	lea    -0xc(%ebp),%eax
 41c:	50                   	push   %eax
 41d:	ff 75 08             	pushl  0x8(%ebp)
 420:	e8 63 ff ff ff       	call   388 <write>
 425:	83 c4 10             	add    $0x10,%esp
}
 428:	c9                   	leave  
 429:	c3                   	ret    

0000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	55                   	push   %ebp
 42b:	89 e5                	mov    %esp,%ebp
 42d:	53                   	push   %ebx
 42e:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 431:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 438:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 43c:	74 17                	je     455 <printint+0x2b>
 43e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 442:	79 11                	jns    455 <printint+0x2b>
    neg = 1;
 444:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 44b:	8b 45 0c             	mov    0xc(%ebp),%eax
 44e:	f7 d8                	neg    %eax
 450:	89 45 ec             	mov    %eax,-0x14(%ebp)
 453:	eb 06                	jmp    45b <printint+0x31>
  } else {
    x = xx;
 455:	8b 45 0c             	mov    0xc(%ebp),%eax
 458:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 45b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 462:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 465:	8d 41 01             	lea    0x1(%ecx),%eax
 468:	89 45 f4             	mov    %eax,-0xc(%ebp)
 46b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 46e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 471:	ba 00 00 00 00       	mov    $0x0,%edx
 476:	f7 f3                	div    %ebx
 478:	89 d0                	mov    %edx,%eax
 47a:	0f b6 80 40 0b 00 00 	movzbl 0xb40(%eax),%eax
 481:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 485:	8b 5d 10             	mov    0x10(%ebp),%ebx
 488:	8b 45 ec             	mov    -0x14(%ebp),%eax
 48b:	ba 00 00 00 00       	mov    $0x0,%edx
 490:	f7 f3                	div    %ebx
 492:	89 45 ec             	mov    %eax,-0x14(%ebp)
 495:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 499:	75 c7                	jne    462 <printint+0x38>
  if(neg)
 49b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49f:	74 0e                	je     4af <printint+0x85>
    buf[i++] = '-';
 4a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a4:	8d 50 01             	lea    0x1(%eax),%edx
 4a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4aa:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4af:	eb 1d                	jmp    4ce <printint+0xa4>
    putc(fd, buf[i]);
 4b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b7:	01 d0                	add    %edx,%eax
 4b9:	0f b6 00             	movzbl (%eax),%eax
 4bc:	0f be c0             	movsbl %al,%eax
 4bf:	83 ec 08             	sub    $0x8,%esp
 4c2:	50                   	push   %eax
 4c3:	ff 75 08             	pushl  0x8(%ebp)
 4c6:	e8 3d ff ff ff       	call   408 <putc>
 4cb:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d6:	79 d9                	jns    4b1 <printint+0x87>
    putc(fd, buf[i]);
}
 4d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4db:	c9                   	leave  
 4dc:	c3                   	ret    

000004dd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4dd:	55                   	push   %ebp
 4de:	89 e5                	mov    %esp,%ebp
 4e0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4ea:	8d 45 0c             	lea    0xc(%ebp),%eax
 4ed:	83 c0 04             	add    $0x4,%eax
 4f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4fa:	e9 59 01 00 00       	jmp    658 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 502:	8b 45 f0             	mov    -0x10(%ebp),%eax
 505:	01 d0                	add    %edx,%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	0f be c0             	movsbl %al,%eax
 50d:	25 ff 00 00 00       	and    $0xff,%eax
 512:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 515:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 519:	75 2c                	jne    547 <printf+0x6a>
      if(c == '%'){
 51b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 51f:	75 0c                	jne    52d <printf+0x50>
        state = '%';
 521:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 528:	e9 27 01 00 00       	jmp    654 <printf+0x177>
      } else {
        putc(fd, c);
 52d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	83 ec 08             	sub    $0x8,%esp
 536:	50                   	push   %eax
 537:	ff 75 08             	pushl  0x8(%ebp)
 53a:	e8 c9 fe ff ff       	call   408 <putc>
 53f:	83 c4 10             	add    $0x10,%esp
 542:	e9 0d 01 00 00       	jmp    654 <printf+0x177>
      }
    } else if(state == '%'){
 547:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 54b:	0f 85 03 01 00 00    	jne    654 <printf+0x177>
      if(c == 'd'){
 551:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 555:	75 1e                	jne    575 <printf+0x98>
        printint(fd, *ap, 10, 1);
 557:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55a:	8b 00                	mov    (%eax),%eax
 55c:	6a 01                	push   $0x1
 55e:	6a 0a                	push   $0xa
 560:	50                   	push   %eax
 561:	ff 75 08             	pushl  0x8(%ebp)
 564:	e8 c1 fe ff ff       	call   42a <printint>
 569:	83 c4 10             	add    $0x10,%esp
        ap++;
 56c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 570:	e9 d8 00 00 00       	jmp    64d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 575:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 579:	74 06                	je     581 <printf+0xa4>
 57b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 57f:	75 1e                	jne    59f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 581:	8b 45 e8             	mov    -0x18(%ebp),%eax
 584:	8b 00                	mov    (%eax),%eax
 586:	6a 00                	push   $0x0
 588:	6a 10                	push   $0x10
 58a:	50                   	push   %eax
 58b:	ff 75 08             	pushl  0x8(%ebp)
 58e:	e8 97 fe ff ff       	call   42a <printint>
 593:	83 c4 10             	add    $0x10,%esp
        ap++;
 596:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59a:	e9 ae 00 00 00       	jmp    64d <printf+0x170>
      } else if(c == 's'){
 59f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5a3:	75 43                	jne    5e8 <printf+0x10b>
        s = (char*)*ap;
 5a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a8:	8b 00                	mov    (%eax),%eax
 5aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5b5:	75 07                	jne    5be <printf+0xe1>
          s = "(null)";
 5b7:	c7 45 f4 e6 08 00 00 	movl   $0x8e6,-0xc(%ebp)
        while(*s != 0){
 5be:	eb 1c                	jmp    5dc <printf+0xff>
          putc(fd, *s);
 5c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c3:	0f b6 00             	movzbl (%eax),%eax
 5c6:	0f be c0             	movsbl %al,%eax
 5c9:	83 ec 08             	sub    $0x8,%esp
 5cc:	50                   	push   %eax
 5cd:	ff 75 08             	pushl  0x8(%ebp)
 5d0:	e8 33 fe ff ff       	call   408 <putc>
 5d5:	83 c4 10             	add    $0x10,%esp
          s++;
 5d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	84 c0                	test   %al,%al
 5e4:	75 da                	jne    5c0 <printf+0xe3>
 5e6:	eb 65                	jmp    64d <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5ec:	75 1d                	jne    60b <printf+0x12e>
        putc(fd, *ap);
 5ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	0f be c0             	movsbl %al,%eax
 5f6:	83 ec 08             	sub    $0x8,%esp
 5f9:	50                   	push   %eax
 5fa:	ff 75 08             	pushl  0x8(%ebp)
 5fd:	e8 06 fe ff ff       	call   408 <putc>
 602:	83 c4 10             	add    $0x10,%esp
        ap++;
 605:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 609:	eb 42                	jmp    64d <printf+0x170>
      } else if(c == '%'){
 60b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 60f:	75 17                	jne    628 <printf+0x14b>
        putc(fd, c);
 611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 614:	0f be c0             	movsbl %al,%eax
 617:	83 ec 08             	sub    $0x8,%esp
 61a:	50                   	push   %eax
 61b:	ff 75 08             	pushl  0x8(%ebp)
 61e:	e8 e5 fd ff ff       	call   408 <putc>
 623:	83 c4 10             	add    $0x10,%esp
 626:	eb 25                	jmp    64d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 628:	83 ec 08             	sub    $0x8,%esp
 62b:	6a 25                	push   $0x25
 62d:	ff 75 08             	pushl  0x8(%ebp)
 630:	e8 d3 fd ff ff       	call   408 <putc>
 635:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63b:	0f be c0             	movsbl %al,%eax
 63e:	83 ec 08             	sub    $0x8,%esp
 641:	50                   	push   %eax
 642:	ff 75 08             	pushl  0x8(%ebp)
 645:	e8 be fd ff ff       	call   408 <putc>
 64a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 64d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 654:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 658:	8b 55 0c             	mov    0xc(%ebp),%edx
 65b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 65e:	01 d0                	add    %edx,%eax
 660:	0f b6 00             	movzbl (%eax),%eax
 663:	84 c0                	test   %al,%al
 665:	0f 85 94 fe ff ff    	jne    4ff <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 66b:	c9                   	leave  
 66c:	c3                   	ret    

0000066d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66d:	55                   	push   %ebp
 66e:	89 e5                	mov    %esp,%ebp
 670:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	83 e8 08             	sub    $0x8,%eax
 679:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67c:	a1 5c 0b 00 00       	mov    0xb5c,%eax
 681:	89 45 fc             	mov    %eax,-0x4(%ebp)
 684:	eb 24                	jmp    6aa <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 686:	8b 45 fc             	mov    -0x4(%ebp),%eax
 689:	8b 00                	mov    (%eax),%eax
 68b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68e:	77 12                	ja     6a2 <free+0x35>
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 696:	77 24                	ja     6bc <free+0x4f>
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	8b 00                	mov    (%eax),%eax
 69d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a0:	77 1a                	ja     6bc <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b0:	76 d4                	jbe    686 <free+0x19>
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ba:	76 ca                	jbe    686 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bf:	8b 40 04             	mov    0x4(%eax),%eax
 6c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	01 c2                	add    %eax,%edx
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8b 00                	mov    (%eax),%eax
 6d3:	39 c2                	cmp    %eax,%edx
 6d5:	75 24                	jne    6fb <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	8b 50 04             	mov    0x4(%eax),%edx
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	8b 40 04             	mov    0x4(%eax),%eax
 6e5:	01 c2                	add    %eax,%edx
 6e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ea:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	8b 10                	mov    (%eax),%edx
 6f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f7:	89 10                	mov    %edx,(%eax)
 6f9:	eb 0a                	jmp    705 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	8b 10                	mov    (%eax),%edx
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 40 04             	mov    0x4(%eax),%eax
 70b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	01 d0                	add    %edx,%eax
 717:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71a:	75 20                	jne    73c <free+0xcf>
    p->s.size += bp->s.size;
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 50 04             	mov    0x4(%eax),%edx
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	8b 40 04             	mov    0x4(%eax),%eax
 728:	01 c2                	add    %eax,%edx
 72a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 730:	8b 45 f8             	mov    -0x8(%ebp),%eax
 733:	8b 10                	mov    (%eax),%edx
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	89 10                	mov    %edx,(%eax)
 73a:	eb 08                	jmp    744 <free+0xd7>
  } else
    p->s.ptr = bp;
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 742:	89 10                	mov    %edx,(%eax)
  freep = p;
 744:	8b 45 fc             	mov    -0x4(%ebp),%eax
 747:	a3 5c 0b 00 00       	mov    %eax,0xb5c
}
 74c:	c9                   	leave  
 74d:	c3                   	ret    

0000074e <morecore>:

static Header*
morecore(uint nu)
{
 74e:	55                   	push   %ebp
 74f:	89 e5                	mov    %esp,%ebp
 751:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 754:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 75b:	77 07                	ja     764 <morecore+0x16>
    nu = 4096;
 75d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 764:	8b 45 08             	mov    0x8(%ebp),%eax
 767:	c1 e0 03             	shl    $0x3,%eax
 76a:	83 ec 0c             	sub    $0xc,%esp
 76d:	50                   	push   %eax
 76e:	e8 7d fc ff ff       	call   3f0 <sbrk>
 773:	83 c4 10             	add    $0x10,%esp
 776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 779:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 77d:	75 07                	jne    786 <morecore+0x38>
    return 0;
 77f:	b8 00 00 00 00       	mov    $0x0,%eax
 784:	eb 26                	jmp    7ac <morecore+0x5e>
  hp = (Header*)p;
 786:	8b 45 f4             	mov    -0xc(%ebp),%eax
 789:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 78c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78f:	8b 55 08             	mov    0x8(%ebp),%edx
 792:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	83 c0 08             	add    $0x8,%eax
 79b:	83 ec 0c             	sub    $0xc,%esp
 79e:	50                   	push   %eax
 79f:	e8 c9 fe ff ff       	call   66d <free>
 7a4:	83 c4 10             	add    $0x10,%esp
  return freep;
 7a7:	a1 5c 0b 00 00       	mov    0xb5c,%eax
}
 7ac:	c9                   	leave  
 7ad:	c3                   	ret    

000007ae <malloc>:

void*
malloc(uint nbytes)
{
 7ae:	55                   	push   %ebp
 7af:	89 e5                	mov    %esp,%ebp
 7b1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b4:	8b 45 08             	mov    0x8(%ebp),%eax
 7b7:	83 c0 07             	add    $0x7,%eax
 7ba:	c1 e8 03             	shr    $0x3,%eax
 7bd:	83 c0 01             	add    $0x1,%eax
 7c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7c3:	a1 5c 0b 00 00       	mov    0xb5c,%eax
 7c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7cf:	75 23                	jne    7f4 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7d1:	c7 45 f0 54 0b 00 00 	movl   $0xb54,-0x10(%ebp)
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	a3 5c 0b 00 00       	mov    %eax,0xb5c
 7e0:	a1 5c 0b 00 00       	mov    0xb5c,%eax
 7e5:	a3 54 0b 00 00       	mov    %eax,0xb54
    base.s.size = 0;
 7ea:	c7 05 58 0b 00 00 00 	movl   $0x0,0xb58
 7f1:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f7:	8b 00                	mov    (%eax),%eax
 7f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 805:	72 4d                	jb     854 <malloc+0xa6>
      if(p->s.size == nunits)
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 810:	75 0c                	jne    81e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	8b 10                	mov    (%eax),%edx
 817:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81a:	89 10                	mov    %edx,(%eax)
 81c:	eb 26                	jmp    844 <malloc+0x96>
      else {
        p->s.size -= nunits;
 81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 821:	8b 40 04             	mov    0x4(%eax),%eax
 824:	2b 45 ec             	sub    -0x14(%ebp),%eax
 827:	89 c2                	mov    %eax,%edx
 829:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 832:	8b 40 04             	mov    0x4(%eax),%eax
 835:	c1 e0 03             	shl    $0x3,%eax
 838:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 841:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 844:	8b 45 f0             	mov    -0x10(%ebp),%eax
 847:	a3 5c 0b 00 00       	mov    %eax,0xb5c
      return (void*)(p + 1);
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	83 c0 08             	add    $0x8,%eax
 852:	eb 3b                	jmp    88f <malloc+0xe1>
    }
    if(p == freep)
 854:	a1 5c 0b 00 00       	mov    0xb5c,%eax
 859:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 85c:	75 1e                	jne    87c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 85e:	83 ec 0c             	sub    $0xc,%esp
 861:	ff 75 ec             	pushl  -0x14(%ebp)
 864:	e8 e5 fe ff ff       	call   74e <morecore>
 869:	83 c4 10             	add    $0x10,%esp
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 86f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 873:	75 07                	jne    87c <malloc+0xce>
        return 0;
 875:	b8 00 00 00 00       	mov    $0x0,%eax
 87a:	eb 13                	jmp    88f <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	8b 00                	mov    (%eax),%eax
 887:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 88a:	e9 6d ff ff ff       	jmp    7fc <malloc+0x4e>
}
 88f:	c9                   	leave  
 890:	c3                   	ret    
