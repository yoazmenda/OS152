
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	83 ec 0c             	sub    $0xc,%esp
   a:	ff 75 08             	pushl  0x8(%ebp)
   d:	e8 f3 04 00 00       	call   505 <strlen>
  12:	83 c4 10             	add    $0x10,%esp
  15:	89 c2                	mov    %eax,%edx
  17:	8b 45 08             	mov    0x8(%ebp),%eax
  1a:	01 d0                	add    %edx,%eax
  1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1f:	eb 04                	jmp    25 <fmtname+0x25>
  21:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  28:	3b 45 08             	cmp    0x8(%ebp),%eax
  2b:	72 0a                	jb     37 <fmtname+0x37>
  2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  30:	0f b6 00             	movzbl (%eax),%eax
  33:	3c 2f                	cmp    $0x2f,%al
  35:	75 ea                	jne    21 <fmtname+0x21>
    ;
  p++;
  37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3b:	83 ec 0c             	sub    $0xc,%esp
  3e:	ff 75 f4             	pushl  -0xc(%ebp)
  41:	e8 bf 04 00 00       	call   505 <strlen>
  46:	83 c4 10             	add    $0x10,%esp
  49:	83 f8 0d             	cmp    $0xd,%eax
  4c:	76 05                	jbe    53 <fmtname+0x53>
    return p;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	eb 60                	jmp    b3 <fmtname+0xb3>
  memmove(buf, p, strlen(p));
  53:	83 ec 0c             	sub    $0xc,%esp
  56:	ff 75 f4             	pushl  -0xc(%ebp)
  59:	e8 a7 04 00 00       	call   505 <strlen>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	83 ec 04             	sub    $0x4,%esp
  64:	50                   	push   %eax
  65:	ff 75 f4             	pushl  -0xc(%ebp)
  68:	68 f4 0e 00 00       	push   $0xef4
  6d:	e8 0f 06 00 00       	call   681 <memmove>
  72:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  75:	83 ec 0c             	sub    $0xc,%esp
  78:	ff 75 f4             	pushl  -0xc(%ebp)
  7b:	e8 85 04 00 00       	call   505 <strlen>
  80:	83 c4 10             	add    $0x10,%esp
  83:	ba 0e 00 00 00       	mov    $0xe,%edx
  88:	89 d3                	mov    %edx,%ebx
  8a:	29 c3                	sub    %eax,%ebx
  8c:	83 ec 0c             	sub    $0xc,%esp
  8f:	ff 75 f4             	pushl  -0xc(%ebp)
  92:	e8 6e 04 00 00       	call   505 <strlen>
  97:	83 c4 10             	add    $0x10,%esp
  9a:	05 f4 0e 00 00       	add    $0xef4,%eax
  9f:	83 ec 04             	sub    $0x4,%esp
  a2:	53                   	push   %ebx
  a3:	6a 20                	push   $0x20
  a5:	50                   	push   %eax
  a6:	e8 81 04 00 00       	call   52c <memset>
  ab:	83 c4 10             	add    $0x10,%esp
  return buf;
  ae:	b8 f4 0e 00 00       	mov    $0xef4,%eax
}
  b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <ls>:

void
ls(char *path)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	56                   	push   %esi
  bd:	53                   	push   %ebx
  be:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  c4:	83 ec 08             	sub    $0x8,%esp
  c7:	6a 00                	push   $0x0
  c9:	ff 75 08             	pushl  0x8(%ebp)
  cc:	e8 35 06 00 00       	call   706 <open>
  d1:	83 c4 10             	add    $0x10,%esp
  d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  db:	79 1a                	jns    f7 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	ff 75 08             	pushl  0x8(%ebp)
  e3:	68 ef 0b 00 00       	push   $0xbef
  e8:	6a 02                	push   $0x2
  ea:	e8 4c 07 00 00       	call   83b <printf>
  ef:	83 c4 10             	add    $0x10,%esp
    return;
  f2:	e9 0e 03 00 00       	jmp    405 <ls+0x34d>
  }
  
  if(fstat(fd, &st) < 0){
  f7:	83 ec 08             	sub    $0x8,%esp
  fa:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 100:	50                   	push   %eax
 101:	ff 75 e4             	pushl  -0x1c(%ebp)
 104:	e8 15 06 00 00       	call   71e <fstat>
 109:	83 c4 10             	add    $0x10,%esp
 10c:	85 c0                	test   %eax,%eax
 10e:	79 28                	jns    138 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 110:	83 ec 04             	sub    $0x4,%esp
 113:	ff 75 08             	pushl  0x8(%ebp)
 116:	68 03 0c 00 00       	push   $0xc03
 11b:	6a 02                	push   $0x2
 11d:	e8 19 07 00 00       	call   83b <printf>
 122:	83 c4 10             	add    $0x10,%esp
    close(fd);
 125:	83 ec 0c             	sub    $0xc,%esp
 128:	ff 75 e4             	pushl  -0x1c(%ebp)
 12b:	e8 be 05 00 00       	call   6ee <close>
 130:	83 c4 10             	add    $0x10,%esp
    return;
 133:	e9 cd 02 00 00       	jmp    405 <ls+0x34d>
  }
  
  switch(st.type){
 138:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 13f:	98                   	cwtl   
 140:	83 f8 02             	cmp    $0x2,%eax
 143:	74 13                	je     158 <ls+0xa0>
 145:	83 f8 03             	cmp    $0x3,%eax
 148:	0f 84 8c 01 00 00    	je     2da <ls+0x222>
 14e:	83 f8 01             	cmp    $0x1,%eax
 151:	74 44                	je     197 <ls+0xdf>
 153:	e9 9f 02 00 00       	jmp    3f7 <ls+0x33f>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 158:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 15e:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 164:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 16b:	0f bf d8             	movswl %ax,%ebx
 16e:	83 ec 0c             	sub    $0xc,%esp
 171:	ff 75 08             	pushl  0x8(%ebp)
 174:	e8 87 fe ff ff       	call   0 <fmtname>
 179:	83 c4 10             	add    $0x10,%esp
 17c:	83 ec 08             	sub    $0x8,%esp
 17f:	57                   	push   %edi
 180:	56                   	push   %esi
 181:	53                   	push   %ebx
 182:	50                   	push   %eax
 183:	68 17 0c 00 00       	push   $0xc17
 188:	6a 01                	push   $0x1
 18a:	e8 ac 06 00 00       	call   83b <printf>
 18f:	83 c4 20             	add    $0x20,%esp
    break;
 192:	e9 60 02 00 00       	jmp    3f7 <ls+0x33f>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 197:	83 ec 0c             	sub    $0xc,%esp
 19a:	ff 75 08             	pushl  0x8(%ebp)
 19d:	e8 63 03 00 00       	call   505 <strlen>
 1a2:	83 c4 10             	add    $0x10,%esp
 1a5:	83 c0 10             	add    $0x10,%eax
 1a8:	3d 00 02 00 00       	cmp    $0x200,%eax
 1ad:	76 17                	jbe    1c6 <ls+0x10e>
      printf(1, "ls: path too long\n");
 1af:	83 ec 08             	sub    $0x8,%esp
 1b2:	68 24 0c 00 00       	push   $0xc24
 1b7:	6a 01                	push   $0x1
 1b9:	e8 7d 06 00 00       	call   83b <printf>
 1be:	83 c4 10             	add    $0x10,%esp
      break;
 1c1:	e9 31 02 00 00       	jmp    3f7 <ls+0x33f>
    }
    strcpy(buf, path);
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	ff 75 08             	pushl  0x8(%ebp)
 1cc:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d2:	50                   	push   %eax
 1d3:	e8 be 02 00 00       	call   496 <strcpy>
 1d8:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1db:	83 ec 0c             	sub    $0xc,%esp
 1de:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e4:	50                   	push   %eax
 1e5:	e8 1b 03 00 00       	call   505 <strlen>
 1ea:	83 c4 10             	add    $0x10,%esp
 1ed:	89 c2                	mov    %eax,%edx
 1ef:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1f5:	01 d0                	add    %edx,%eax
 1f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1fd:	8d 50 01             	lea    0x1(%eax),%edx
 200:	89 55 e0             	mov    %edx,-0x20(%ebp)
 203:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 206:	e9 aa 00 00 00       	jmp    2b5 <ls+0x1fd>
      if(de.inum == 0)
 20b:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 212:	66 85 c0             	test   %ax,%ax
 215:	75 05                	jne    21c <ls+0x164>
        continue;
 217:	e9 99 00 00 00       	jmp    2b5 <ls+0x1fd>
      memmove(p, de.name, DIRSIZ);
 21c:	83 ec 04             	sub    $0x4,%esp
 21f:	6a 0e                	push   $0xe
 221:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 227:	83 c0 02             	add    $0x2,%eax
 22a:	50                   	push   %eax
 22b:	ff 75 e0             	pushl  -0x20(%ebp)
 22e:	e8 4e 04 00 00       	call   681 <memmove>
 233:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 236:	8b 45 e0             	mov    -0x20(%ebp),%eax
 239:	83 c0 0e             	add    $0xe,%eax
 23c:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23f:	83 ec 08             	sub    $0x8,%esp
 242:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 248:	50                   	push   %eax
 249:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24f:	50                   	push   %eax
 250:	e8 92 03 00 00       	call   5e7 <stat>
 255:	83 c4 10             	add    $0x10,%esp
 258:	85 c0                	test   %eax,%eax
 25a:	79 1b                	jns    277 <ls+0x1bf>
        printf(1, "ls: cannot stat %s\n", buf);
 25c:	83 ec 04             	sub    $0x4,%esp
 25f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 265:	50                   	push   %eax
 266:	68 03 0c 00 00       	push   $0xc03
 26b:	6a 01                	push   $0x1
 26d:	e8 c9 05 00 00       	call   83b <printf>
 272:	83 c4 10             	add    $0x10,%esp
        continue;
 275:	eb 3e                	jmp    2b5 <ls+0x1fd>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 277:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 27d:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 283:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 28a:	0f bf d8             	movswl %ax,%ebx
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 296:	50                   	push   %eax
 297:	e8 64 fd ff ff       	call   0 <fmtname>
 29c:	83 c4 10             	add    $0x10,%esp
 29f:	83 ec 08             	sub    $0x8,%esp
 2a2:	57                   	push   %edi
 2a3:	56                   	push   %esi
 2a4:	53                   	push   %ebx
 2a5:	50                   	push   %eax
 2a6:	68 17 0c 00 00       	push   $0xc17
 2ab:	6a 01                	push   $0x1
 2ad:	e8 89 05 00 00       	call   83b <printf>
 2b2:	83 c4 20             	add    $0x20,%esp
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2b5:	83 ec 04             	sub    $0x4,%esp
 2b8:	6a 10                	push   $0x10
 2ba:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2c0:	50                   	push   %eax
 2c1:	ff 75 e4             	pushl  -0x1c(%ebp)
 2c4:	e8 15 04 00 00       	call   6de <read>
 2c9:	83 c4 10             	add    $0x10,%esp
 2cc:	83 f8 10             	cmp    $0x10,%eax
 2cf:	0f 84 36 ff ff ff    	je     20b <ls+0x153>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2d5:	e9 1d 01 00 00       	jmp    3f7 <ls+0x33f>

  // CHANGED
  case T_DEV:
      if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 2da:	83 ec 0c             	sub    $0xc,%esp
 2dd:	ff 75 08             	pushl  0x8(%ebp)
 2e0:	e8 20 02 00 00       	call   505 <strlen>
 2e5:	83 c4 10             	add    $0x10,%esp
 2e8:	83 c0 10             	add    $0x10,%eax
 2eb:	3d 00 02 00 00       	cmp    $0x200,%eax
 2f0:	76 17                	jbe    309 <ls+0x251>
        printf(1, "ls: path too long\n");
 2f2:	83 ec 08             	sub    $0x8,%esp
 2f5:	68 24 0c 00 00       	push   $0xc24
 2fa:	6a 01                	push   $0x1
 2fc:	e8 3a 05 00 00       	call   83b <printf>
 301:	83 c4 10             	add    $0x10,%esp
        break;
 304:	e9 ee 00 00 00       	jmp    3f7 <ls+0x33f>
      }
      strcpy(buf, path);
 309:	83 ec 08             	sub    $0x8,%esp
 30c:	ff 75 08             	pushl  0x8(%ebp)
 30f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 315:	50                   	push   %eax
 316:	e8 7b 01 00 00       	call   496 <strcpy>
 31b:	83 c4 10             	add    $0x10,%esp
      p = buf+strlen(buf);
 31e:	83 ec 0c             	sub    $0xc,%esp
 321:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 327:	50                   	push   %eax
 328:	e8 d8 01 00 00       	call   505 <strlen>
 32d:	83 c4 10             	add    $0x10,%esp
 330:	89 c2                	mov    %eax,%edx
 332:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 338:	01 d0                	add    %edx,%eax
 33a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *p++ = '/';
 33d:	8b 45 e0             	mov    -0x20(%ebp),%eax
 340:	8d 50 01             	lea    0x1(%eax),%edx
 343:	89 55 e0             	mov    %edx,-0x20(%ebp)
 346:	c6 00 2f             	movb   $0x2f,(%eax)
      while(read(fd, &de, sizeof(de)) == sizeof(de)){
 349:	e9 88 00 00 00       	jmp    3d6 <ls+0x31e>
        if(de.inum == 0)
 34e:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 355:	66 85 c0             	test   %ax,%ax
 358:	75 02                	jne    35c <ls+0x2a4>
          continue;
 35a:	eb 7a                	jmp    3d6 <ls+0x31e>
        memmove(p, de.name, DIRSIZ);
 35c:	83 ec 04             	sub    $0x4,%esp
 35f:	6a 0e                	push   $0xe
 361:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 367:	83 c0 02             	add    $0x2,%eax
 36a:	50                   	push   %eax
 36b:	ff 75 e0             	pushl  -0x20(%ebp)
 36e:	e8 0e 03 00 00       	call   681 <memmove>
 373:	83 c4 10             	add    $0x10,%esp
        p[DIRSIZ] = 0;
 376:	8b 45 e0             	mov    -0x20(%ebp),%eax
 379:	83 c0 0e             	add    $0xe,%eax
 37c:	c6 00 00             	movb   $0x0,(%eax)
        if(stat(buf, &st) < 0 && 0){
 37f:	83 ec 08             	sub    $0x8,%esp
 382:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 388:	50                   	push   %eax
 389:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 38f:	50                   	push   %eax
 390:	e8 52 02 00 00       	call   5e7 <stat>
 395:	83 c4 10             	add    $0x10,%esp
          printf(1, "ls: cannot stat %s\n", buf);
          continue;
        }
        printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 398:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 39e:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 3a4:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 3ab:	0f bf d8             	movswl %ax,%ebx
 3ae:	83 ec 0c             	sub    $0xc,%esp
 3b1:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 3b7:	50                   	push   %eax
 3b8:	e8 43 fc ff ff       	call   0 <fmtname>
 3bd:	83 c4 10             	add    $0x10,%esp
 3c0:	83 ec 08             	sub    $0x8,%esp
 3c3:	57                   	push   %edi
 3c4:	56                   	push   %esi
 3c5:	53                   	push   %ebx
 3c6:	50                   	push   %eax
 3c7:	68 17 0c 00 00       	push   $0xc17
 3cc:	6a 01                	push   $0x1
 3ce:	e8 68 04 00 00       	call   83b <printf>
 3d3:	83 c4 20             	add    $0x20,%esp
        break;
      }
      strcpy(buf, path);
      p = buf+strlen(buf);
      *p++ = '/';
      while(read(fd, &de, sizeof(de)) == sizeof(de)){
 3d6:	83 ec 04             	sub    $0x4,%esp
 3d9:	6a 10                	push   $0x10
 3db:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 3e1:	50                   	push   %eax
 3e2:	ff 75 e4             	pushl  -0x1c(%ebp)
 3e5:	e8 f4 02 00 00       	call   6de <read>
 3ea:	83 c4 10             	add    $0x10,%esp
 3ed:	83 f8 10             	cmp    $0x10,%eax
 3f0:	0f 84 58 ff ff ff    	je     34e <ls+0x296>
          printf(1, "ls: cannot stat %s\n", buf);
          continue;
        }
        printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
      }
      break;
 3f6:	90                   	nop

  }
  close(fd);
 3f7:	83 ec 0c             	sub    $0xc,%esp
 3fa:	ff 75 e4             	pushl  -0x1c(%ebp)
 3fd:	e8 ec 02 00 00       	call   6ee <close>
 402:	83 c4 10             	add    $0x10,%esp
}
 405:	8d 65 f4             	lea    -0xc(%ebp),%esp
 408:	5b                   	pop    %ebx
 409:	5e                   	pop    %esi
 40a:	5f                   	pop    %edi
 40b:	5d                   	pop    %ebp
 40c:	c3                   	ret    

0000040d <main>:

int
main(int argc, char *argv[])
{
 40d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 411:	83 e4 f0             	and    $0xfffffff0,%esp
 414:	ff 71 fc             	pushl  -0x4(%ecx)
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	53                   	push   %ebx
 41b:	51                   	push   %ecx
 41c:	83 ec 10             	sub    $0x10,%esp
 41f:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 421:	83 3b 01             	cmpl   $0x1,(%ebx)
 424:	7f 15                	jg     43b <main+0x2e>
    ls(".");
 426:	83 ec 0c             	sub    $0xc,%esp
 429:	68 37 0c 00 00       	push   $0xc37
 42e:	e8 85 fc ff ff       	call   b8 <ls>
 433:	83 c4 10             	add    $0x10,%esp
    exit();
 436:	e8 8b 02 00 00       	call   6c6 <exit>
  }
  for(i=1; i<argc; i++)
 43b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 442:	eb 21                	jmp    465 <main+0x58>
    ls(argv[i]);
 444:	8b 45 f4             	mov    -0xc(%ebp),%eax
 447:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 44e:	8b 43 04             	mov    0x4(%ebx),%eax
 451:	01 d0                	add    %edx,%eax
 453:	8b 00                	mov    (%eax),%eax
 455:	83 ec 0c             	sub    $0xc,%esp
 458:	50                   	push   %eax
 459:	e8 5a fc ff ff       	call   b8 <ls>
 45e:	83 c4 10             	add    $0x10,%esp

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 461:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 465:	8b 45 f4             	mov    -0xc(%ebp),%eax
 468:	3b 03                	cmp    (%ebx),%eax
 46a:	7c d8                	jl     444 <main+0x37>
    ls(argv[i]);
  exit();
 46c:	e8 55 02 00 00       	call   6c6 <exit>

00000471 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 471:	55                   	push   %ebp
 472:	89 e5                	mov    %esp,%ebp
 474:	57                   	push   %edi
 475:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 476:	8b 4d 08             	mov    0x8(%ebp),%ecx
 479:	8b 55 10             	mov    0x10(%ebp),%edx
 47c:	8b 45 0c             	mov    0xc(%ebp),%eax
 47f:	89 cb                	mov    %ecx,%ebx
 481:	89 df                	mov    %ebx,%edi
 483:	89 d1                	mov    %edx,%ecx
 485:	fc                   	cld    
 486:	f3 aa                	rep stos %al,%es:(%edi)
 488:	89 ca                	mov    %ecx,%edx
 48a:	89 fb                	mov    %edi,%ebx
 48c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 48f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 492:	5b                   	pop    %ebx
 493:	5f                   	pop    %edi
 494:	5d                   	pop    %ebp
 495:	c3                   	ret    

00000496 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 496:	55                   	push   %ebp
 497:	89 e5                	mov    %esp,%ebp
 499:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4a2:	90                   	nop
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	8d 50 01             	lea    0x1(%eax),%edx
 4a9:	89 55 08             	mov    %edx,0x8(%ebp)
 4ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 4af:	8d 4a 01             	lea    0x1(%edx),%ecx
 4b2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 4b5:	0f b6 12             	movzbl (%edx),%edx
 4b8:	88 10                	mov    %dl,(%eax)
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	84 c0                	test   %al,%al
 4bf:	75 e2                	jne    4a3 <strcpy+0xd>
    ;
  return os;
 4c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c4:	c9                   	leave  
 4c5:	c3                   	ret    

000004c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4c6:	55                   	push   %ebp
 4c7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4c9:	eb 08                	jmp    4d3 <strcmp+0xd>
    p++, q++;
 4cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4cf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	0f b6 00             	movzbl (%eax),%eax
 4d9:	84 c0                	test   %al,%al
 4db:	74 10                	je     4ed <strcmp+0x27>
 4dd:	8b 45 08             	mov    0x8(%ebp),%eax
 4e0:	0f b6 10             	movzbl (%eax),%edx
 4e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e6:	0f b6 00             	movzbl (%eax),%eax
 4e9:	38 c2                	cmp    %al,%dl
 4eb:	74 de                	je     4cb <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
 4f0:	0f b6 00             	movzbl (%eax),%eax
 4f3:	0f b6 d0             	movzbl %al,%edx
 4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f9:	0f b6 00             	movzbl (%eax),%eax
 4fc:	0f b6 c0             	movzbl %al,%eax
 4ff:	29 c2                	sub    %eax,%edx
 501:	89 d0                	mov    %edx,%eax
}
 503:	5d                   	pop    %ebp
 504:	c3                   	ret    

00000505 <strlen>:

uint
strlen(char *s)
{
 505:	55                   	push   %ebp
 506:	89 e5                	mov    %esp,%ebp
 508:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 50b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 512:	eb 04                	jmp    518 <strlen+0x13>
 514:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 518:	8b 55 fc             	mov    -0x4(%ebp),%edx
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	01 d0                	add    %edx,%eax
 520:	0f b6 00             	movzbl (%eax),%eax
 523:	84 c0                	test   %al,%al
 525:	75 ed                	jne    514 <strlen+0xf>
    ;
  return n;
 527:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 52a:	c9                   	leave  
 52b:	c3                   	ret    

0000052c <memset>:

void*
memset(void *dst, int c, uint n)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 52f:	8b 45 10             	mov    0x10(%ebp),%eax
 532:	50                   	push   %eax
 533:	ff 75 0c             	pushl  0xc(%ebp)
 536:	ff 75 08             	pushl  0x8(%ebp)
 539:	e8 33 ff ff ff       	call   471 <stosb>
 53e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 541:	8b 45 08             	mov    0x8(%ebp),%eax
}
 544:	c9                   	leave  
 545:	c3                   	ret    

00000546 <strchr>:

char*
strchr(const char *s, char c)
{
 546:	55                   	push   %ebp
 547:	89 e5                	mov    %esp,%ebp
 549:	83 ec 04             	sub    $0x4,%esp
 54c:	8b 45 0c             	mov    0xc(%ebp),%eax
 54f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 552:	eb 14                	jmp    568 <strchr+0x22>
    if(*s == c)
 554:	8b 45 08             	mov    0x8(%ebp),%eax
 557:	0f b6 00             	movzbl (%eax),%eax
 55a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 55d:	75 05                	jne    564 <strchr+0x1e>
      return (char*)s;
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	eb 13                	jmp    577 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 564:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	0f b6 00             	movzbl (%eax),%eax
 56e:	84 c0                	test   %al,%al
 570:	75 e2                	jne    554 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 572:	b8 00 00 00 00       	mov    $0x0,%eax
}
 577:	c9                   	leave  
 578:	c3                   	ret    

00000579 <gets>:

char*
gets(char *buf, int max)
{
 579:	55                   	push   %ebp
 57a:	89 e5                	mov    %esp,%ebp
 57c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 57f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 586:	eb 44                	jmp    5cc <gets+0x53>
    cc = read(0, &c, 1);
 588:	83 ec 04             	sub    $0x4,%esp
 58b:	6a 01                	push   $0x1
 58d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 590:	50                   	push   %eax
 591:	6a 00                	push   $0x0
 593:	e8 46 01 00 00       	call   6de <read>
 598:	83 c4 10             	add    $0x10,%esp
 59b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 59e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a2:	7f 02                	jg     5a6 <gets+0x2d>
      break;
 5a4:	eb 31                	jmp    5d7 <gets+0x5e>
    buf[i++] = c;
 5a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a9:	8d 50 01             	lea    0x1(%eax),%edx
 5ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5af:	89 c2                	mov    %eax,%edx
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	01 c2                	add    %eax,%edx
 5b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c0:	3c 0a                	cmp    $0xa,%al
 5c2:	74 13                	je     5d7 <gets+0x5e>
 5c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c8:	3c 0d                	cmp    $0xd,%al
 5ca:	74 0b                	je     5d7 <gets+0x5e>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cf:	83 c0 01             	add    $0x1,%eax
 5d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5d5:	7c b1                	jl     588 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5da:	8b 45 08             	mov    0x8(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5e5:	c9                   	leave  
 5e6:	c3                   	ret    

000005e7 <stat>:

int
stat(char *n, struct stat *st)
{
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
 5ea:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5ed:	83 ec 08             	sub    $0x8,%esp
 5f0:	6a 00                	push   $0x0
 5f2:	ff 75 08             	pushl  0x8(%ebp)
 5f5:	e8 0c 01 00 00       	call   706 <open>
 5fa:	83 c4 10             	add    $0x10,%esp
 5fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 604:	79 07                	jns    60d <stat+0x26>
    return -1;
 606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 60b:	eb 25                	jmp    632 <stat+0x4b>
  r = fstat(fd, st);
 60d:	83 ec 08             	sub    $0x8,%esp
 610:	ff 75 0c             	pushl  0xc(%ebp)
 613:	ff 75 f4             	pushl  -0xc(%ebp)
 616:	e8 03 01 00 00       	call   71e <fstat>
 61b:	83 c4 10             	add    $0x10,%esp
 61e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 621:	83 ec 0c             	sub    $0xc,%esp
 624:	ff 75 f4             	pushl  -0xc(%ebp)
 627:	e8 c2 00 00 00       	call   6ee <close>
 62c:	83 c4 10             	add    $0x10,%esp
  return r;
 62f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 632:	c9                   	leave  
 633:	c3                   	ret    

00000634 <atoi>:

int
atoi(const char *s)
{
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
 637:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 63a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 641:	eb 25                	jmp    668 <atoi+0x34>
    n = n*10 + *s++ - '0';
 643:	8b 55 fc             	mov    -0x4(%ebp),%edx
 646:	89 d0                	mov    %edx,%eax
 648:	c1 e0 02             	shl    $0x2,%eax
 64b:	01 d0                	add    %edx,%eax
 64d:	01 c0                	add    %eax,%eax
 64f:	89 c1                	mov    %eax,%ecx
 651:	8b 45 08             	mov    0x8(%ebp),%eax
 654:	8d 50 01             	lea    0x1(%eax),%edx
 657:	89 55 08             	mov    %edx,0x8(%ebp)
 65a:	0f b6 00             	movzbl (%eax),%eax
 65d:	0f be c0             	movsbl %al,%eax
 660:	01 c8                	add    %ecx,%eax
 662:	83 e8 30             	sub    $0x30,%eax
 665:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	0f b6 00             	movzbl (%eax),%eax
 66e:	3c 2f                	cmp    $0x2f,%al
 670:	7e 0a                	jle    67c <atoi+0x48>
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	0f b6 00             	movzbl (%eax),%eax
 678:	3c 39                	cmp    $0x39,%al
 67a:	7e c7                	jle    643 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 67f:	c9                   	leave  
 680:	c3                   	ret    

00000681 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 681:	55                   	push   %ebp
 682:	89 e5                	mov    %esp,%ebp
 684:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 687:	8b 45 08             	mov    0x8(%ebp),%eax
 68a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 68d:	8b 45 0c             	mov    0xc(%ebp),%eax
 690:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 693:	eb 17                	jmp    6ac <memmove+0x2b>
    *dst++ = *src++;
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8d 50 01             	lea    0x1(%eax),%edx
 69b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 69e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6a1:	8d 4a 01             	lea    0x1(%edx),%ecx
 6a4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 6a7:	0f b6 12             	movzbl (%edx),%edx
 6aa:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6ac:	8b 45 10             	mov    0x10(%ebp),%eax
 6af:	8d 50 ff             	lea    -0x1(%eax),%edx
 6b2:	89 55 10             	mov    %edx,0x10(%ebp)
 6b5:	85 c0                	test   %eax,%eax
 6b7:	7f dc                	jg     695 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6bc:	c9                   	leave  
 6bd:	c3                   	ret    

000006be <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6be:	b8 01 00 00 00       	mov    $0x1,%eax
 6c3:	cd 40                	int    $0x40
 6c5:	c3                   	ret    

000006c6 <exit>:
SYSCALL(exit)
 6c6:	b8 02 00 00 00       	mov    $0x2,%eax
 6cb:	cd 40                	int    $0x40
 6cd:	c3                   	ret    

000006ce <wait>:
SYSCALL(wait)
 6ce:	b8 03 00 00 00       	mov    $0x3,%eax
 6d3:	cd 40                	int    $0x40
 6d5:	c3                   	ret    

000006d6 <pipe>:
SYSCALL(pipe)
 6d6:	b8 04 00 00 00       	mov    $0x4,%eax
 6db:	cd 40                	int    $0x40
 6dd:	c3                   	ret    

000006de <read>:
SYSCALL(read)
 6de:	b8 05 00 00 00       	mov    $0x5,%eax
 6e3:	cd 40                	int    $0x40
 6e5:	c3                   	ret    

000006e6 <write>:
SYSCALL(write)
 6e6:	b8 10 00 00 00       	mov    $0x10,%eax
 6eb:	cd 40                	int    $0x40
 6ed:	c3                   	ret    

000006ee <close>:
SYSCALL(close)
 6ee:	b8 15 00 00 00       	mov    $0x15,%eax
 6f3:	cd 40                	int    $0x40
 6f5:	c3                   	ret    

000006f6 <kill>:
SYSCALL(kill)
 6f6:	b8 06 00 00 00       	mov    $0x6,%eax
 6fb:	cd 40                	int    $0x40
 6fd:	c3                   	ret    

000006fe <exec>:
SYSCALL(exec)
 6fe:	b8 07 00 00 00       	mov    $0x7,%eax
 703:	cd 40                	int    $0x40
 705:	c3                   	ret    

00000706 <open>:
SYSCALL(open)
 706:	b8 0f 00 00 00       	mov    $0xf,%eax
 70b:	cd 40                	int    $0x40
 70d:	c3                   	ret    

0000070e <mknod>:
SYSCALL(mknod)
 70e:	b8 11 00 00 00       	mov    $0x11,%eax
 713:	cd 40                	int    $0x40
 715:	c3                   	ret    

00000716 <unlink>:
SYSCALL(unlink)
 716:	b8 12 00 00 00       	mov    $0x12,%eax
 71b:	cd 40                	int    $0x40
 71d:	c3                   	ret    

0000071e <fstat>:
SYSCALL(fstat)
 71e:	b8 08 00 00 00       	mov    $0x8,%eax
 723:	cd 40                	int    $0x40
 725:	c3                   	ret    

00000726 <link>:
SYSCALL(link)
 726:	b8 13 00 00 00       	mov    $0x13,%eax
 72b:	cd 40                	int    $0x40
 72d:	c3                   	ret    

0000072e <mkdir>:
SYSCALL(mkdir)
 72e:	b8 14 00 00 00       	mov    $0x14,%eax
 733:	cd 40                	int    $0x40
 735:	c3                   	ret    

00000736 <chdir>:
SYSCALL(chdir)
 736:	b8 09 00 00 00       	mov    $0x9,%eax
 73b:	cd 40                	int    $0x40
 73d:	c3                   	ret    

0000073e <dup>:
SYSCALL(dup)
 73e:	b8 0a 00 00 00       	mov    $0xa,%eax
 743:	cd 40                	int    $0x40
 745:	c3                   	ret    

00000746 <getpid>:
SYSCALL(getpid)
 746:	b8 0b 00 00 00       	mov    $0xb,%eax
 74b:	cd 40                	int    $0x40
 74d:	c3                   	ret    

0000074e <sbrk>:
SYSCALL(sbrk)
 74e:	b8 0c 00 00 00       	mov    $0xc,%eax
 753:	cd 40                	int    $0x40
 755:	c3                   	ret    

00000756 <sleep>:
SYSCALL(sleep)
 756:	b8 0d 00 00 00       	mov    $0xd,%eax
 75b:	cd 40                	int    $0x40
 75d:	c3                   	ret    

0000075e <uptime>:
SYSCALL(uptime)
 75e:	b8 0e 00 00 00       	mov    $0xe,%eax
 763:	cd 40                	int    $0x40
 765:	c3                   	ret    

00000766 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 766:	55                   	push   %ebp
 767:	89 e5                	mov    %esp,%ebp
 769:	83 ec 18             	sub    $0x18,%esp
 76c:	8b 45 0c             	mov    0xc(%ebp),%eax
 76f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 772:	83 ec 04             	sub    $0x4,%esp
 775:	6a 01                	push   $0x1
 777:	8d 45 f4             	lea    -0xc(%ebp),%eax
 77a:	50                   	push   %eax
 77b:	ff 75 08             	pushl  0x8(%ebp)
 77e:	e8 63 ff ff ff       	call   6e6 <write>
 783:	83 c4 10             	add    $0x10,%esp
}
 786:	c9                   	leave  
 787:	c3                   	ret    

00000788 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	53                   	push   %ebx
 78c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 78f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 796:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 79a:	74 17                	je     7b3 <printint+0x2b>
 79c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7a0:	79 11                	jns    7b3 <printint+0x2b>
    neg = 1;
 7a2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ac:	f7 d8                	neg    %eax
 7ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7b1:	eb 06                	jmp    7b9 <printint+0x31>
  } else {
    x = xx;
 7b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7c0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 7c3:	8d 41 01             	lea    0x1(%ecx),%eax
 7c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7cf:	ba 00 00 00 00       	mov    $0x0,%edx
 7d4:	f7 f3                	div    %ebx
 7d6:	89 d0                	mov    %edx,%eax
 7d8:	0f b6 80 e0 0e 00 00 	movzbl 0xee0(%eax),%eax
 7df:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 7e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 7e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7e9:	ba 00 00 00 00       	mov    $0x0,%edx
 7ee:	f7 f3                	div    %ebx
 7f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7f7:	75 c7                	jne    7c0 <printint+0x38>
  if(neg)
 7f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7fd:	74 0e                	je     80d <printint+0x85>
    buf[i++] = '-';
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	8d 50 01             	lea    0x1(%eax),%edx
 805:	89 55 f4             	mov    %edx,-0xc(%ebp)
 808:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 80d:	eb 1d                	jmp    82c <printint+0xa4>
    putc(fd, buf[i]);
 80f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	01 d0                	add    %edx,%eax
 817:	0f b6 00             	movzbl (%eax),%eax
 81a:	0f be c0             	movsbl %al,%eax
 81d:	83 ec 08             	sub    $0x8,%esp
 820:	50                   	push   %eax
 821:	ff 75 08             	pushl  0x8(%ebp)
 824:	e8 3d ff ff ff       	call   766 <putc>
 829:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 82c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 830:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 834:	79 d9                	jns    80f <printint+0x87>
    putc(fd, buf[i]);
}
 836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 839:	c9                   	leave  
 83a:	c3                   	ret    

0000083b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 83b:	55                   	push   %ebp
 83c:	89 e5                	mov    %esp,%ebp
 83e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 841:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 848:	8d 45 0c             	lea    0xc(%ebp),%eax
 84b:	83 c0 04             	add    $0x4,%eax
 84e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 851:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 858:	e9 59 01 00 00       	jmp    9b6 <printf+0x17b>
    c = fmt[i] & 0xff;
 85d:	8b 55 0c             	mov    0xc(%ebp),%edx
 860:	8b 45 f0             	mov    -0x10(%ebp),%eax
 863:	01 d0                	add    %edx,%eax
 865:	0f b6 00             	movzbl (%eax),%eax
 868:	0f be c0             	movsbl %al,%eax
 86b:	25 ff 00 00 00       	and    $0xff,%eax
 870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 873:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 877:	75 2c                	jne    8a5 <printf+0x6a>
      if(c == '%'){
 879:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 87d:	75 0c                	jne    88b <printf+0x50>
        state = '%';
 87f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 886:	e9 27 01 00 00       	jmp    9b2 <printf+0x177>
      } else {
        putc(fd, c);
 88b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 88e:	0f be c0             	movsbl %al,%eax
 891:	83 ec 08             	sub    $0x8,%esp
 894:	50                   	push   %eax
 895:	ff 75 08             	pushl  0x8(%ebp)
 898:	e8 c9 fe ff ff       	call   766 <putc>
 89d:	83 c4 10             	add    $0x10,%esp
 8a0:	e9 0d 01 00 00       	jmp    9b2 <printf+0x177>
      }
    } else if(state == '%'){
 8a5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8a9:	0f 85 03 01 00 00    	jne    9b2 <printf+0x177>
      if(c == 'd'){
 8af:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8b3:	75 1e                	jne    8d3 <printf+0x98>
        printint(fd, *ap, 10, 1);
 8b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b8:	8b 00                	mov    (%eax),%eax
 8ba:	6a 01                	push   $0x1
 8bc:	6a 0a                	push   $0xa
 8be:	50                   	push   %eax
 8bf:	ff 75 08             	pushl  0x8(%ebp)
 8c2:	e8 c1 fe ff ff       	call   788 <printint>
 8c7:	83 c4 10             	add    $0x10,%esp
        ap++;
 8ca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8ce:	e9 d8 00 00 00       	jmp    9ab <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8d3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8d7:	74 06                	je     8df <printf+0xa4>
 8d9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8dd:	75 1e                	jne    8fd <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	6a 00                	push   $0x0
 8e6:	6a 10                	push   $0x10
 8e8:	50                   	push   %eax
 8e9:	ff 75 08             	pushl  0x8(%ebp)
 8ec:	e8 97 fe ff ff       	call   788 <printint>
 8f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 8f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8f8:	e9 ae 00 00 00       	jmp    9ab <printf+0x170>
      } else if(c == 's'){
 8fd:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 901:	75 43                	jne    946 <printf+0x10b>
        s = (char*)*ap;
 903:	8b 45 e8             	mov    -0x18(%ebp),%eax
 906:	8b 00                	mov    (%eax),%eax
 908:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 90b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 90f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 913:	75 07                	jne    91c <printf+0xe1>
          s = "(null)";
 915:	c7 45 f4 39 0c 00 00 	movl   $0xc39,-0xc(%ebp)
        while(*s != 0){
 91c:	eb 1c                	jmp    93a <printf+0xff>
          putc(fd, *s);
 91e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 921:	0f b6 00             	movzbl (%eax),%eax
 924:	0f be c0             	movsbl %al,%eax
 927:	83 ec 08             	sub    $0x8,%esp
 92a:	50                   	push   %eax
 92b:	ff 75 08             	pushl  0x8(%ebp)
 92e:	e8 33 fe ff ff       	call   766 <putc>
 933:	83 c4 10             	add    $0x10,%esp
          s++;
 936:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	0f b6 00             	movzbl (%eax),%eax
 940:	84 c0                	test   %al,%al
 942:	75 da                	jne    91e <printf+0xe3>
 944:	eb 65                	jmp    9ab <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 946:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 94a:	75 1d                	jne    969 <printf+0x12e>
        putc(fd, *ap);
 94c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	0f be c0             	movsbl %al,%eax
 954:	83 ec 08             	sub    $0x8,%esp
 957:	50                   	push   %eax
 958:	ff 75 08             	pushl  0x8(%ebp)
 95b:	e8 06 fe ff ff       	call   766 <putc>
 960:	83 c4 10             	add    $0x10,%esp
        ap++;
 963:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 967:	eb 42                	jmp    9ab <printf+0x170>
      } else if(c == '%'){
 969:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 96d:	75 17                	jne    986 <printf+0x14b>
        putc(fd, c);
 96f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 972:	0f be c0             	movsbl %al,%eax
 975:	83 ec 08             	sub    $0x8,%esp
 978:	50                   	push   %eax
 979:	ff 75 08             	pushl  0x8(%ebp)
 97c:	e8 e5 fd ff ff       	call   766 <putc>
 981:	83 c4 10             	add    $0x10,%esp
 984:	eb 25                	jmp    9ab <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 986:	83 ec 08             	sub    $0x8,%esp
 989:	6a 25                	push   $0x25
 98b:	ff 75 08             	pushl  0x8(%ebp)
 98e:	e8 d3 fd ff ff       	call   766 <putc>
 993:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 996:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 999:	0f be c0             	movsbl %al,%eax
 99c:	83 ec 08             	sub    $0x8,%esp
 99f:	50                   	push   %eax
 9a0:	ff 75 08             	pushl  0x8(%ebp)
 9a3:	e8 be fd ff ff       	call   766 <putc>
 9a8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 9b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bc:	01 d0                	add    %edx,%eax
 9be:	0f b6 00             	movzbl (%eax),%eax
 9c1:	84 c0                	test   %al,%al
 9c3:	0f 85 94 fe ff ff    	jne    85d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    

000009cb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9cb:	55                   	push   %ebp
 9cc:	89 e5                	mov    %esp,%ebp
 9ce:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d1:	8b 45 08             	mov    0x8(%ebp),%eax
 9d4:	83 e8 08             	sub    $0x8,%eax
 9d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9da:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 9df:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9e2:	eb 24                	jmp    a08 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e7:	8b 00                	mov    (%eax),%eax
 9e9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9ec:	77 12                	ja     a00 <free+0x35>
 9ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9f4:	77 24                	ja     a1a <free+0x4f>
 9f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f9:	8b 00                	mov    (%eax),%eax
 9fb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9fe:	77 1a                	ja     a1a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a03:	8b 00                	mov    (%eax),%eax
 a05:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a08:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a0e:	76 d4                	jbe    9e4 <free+0x19>
 a10:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a13:	8b 00                	mov    (%eax),%eax
 a15:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a18:	76 ca                	jbe    9e4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1d:	8b 40 04             	mov    0x4(%eax),%eax
 a20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a27:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a2a:	01 c2                	add    %eax,%edx
 a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2f:	8b 00                	mov    (%eax),%eax
 a31:	39 c2                	cmp    %eax,%edx
 a33:	75 24                	jne    a59 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a35:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a38:	8b 50 04             	mov    0x4(%eax),%edx
 a3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3e:	8b 00                	mov    (%eax),%eax
 a40:	8b 40 04             	mov    0x4(%eax),%eax
 a43:	01 c2                	add    %eax,%edx
 a45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a48:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4e:	8b 00                	mov    (%eax),%eax
 a50:	8b 10                	mov    (%eax),%edx
 a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a55:	89 10                	mov    %edx,(%eax)
 a57:	eb 0a                	jmp    a63 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5c:	8b 10                	mov    (%eax),%edx
 a5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a61:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a66:	8b 40 04             	mov    0x4(%eax),%eax
 a69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a73:	01 d0                	add    %edx,%eax
 a75:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a78:	75 20                	jne    a9a <free+0xcf>
    p->s.size += bp->s.size;
 a7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7d:	8b 50 04             	mov    0x4(%eax),%edx
 a80:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a83:	8b 40 04             	mov    0x4(%eax),%eax
 a86:	01 c2                	add    %eax,%edx
 a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a91:	8b 10                	mov    (%eax),%edx
 a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a96:	89 10                	mov    %edx,(%eax)
 a98:	eb 08                	jmp    aa2 <free+0xd7>
  } else
    p->s.ptr = bp;
 a9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 aa0:	89 10                	mov    %edx,(%eax)
  freep = p;
 aa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa5:	a3 0c 0f 00 00       	mov    %eax,0xf0c
}
 aaa:	c9                   	leave  
 aab:	c3                   	ret    

00000aac <morecore>:

static Header*
morecore(uint nu)
{
 aac:	55                   	push   %ebp
 aad:	89 e5                	mov    %esp,%ebp
 aaf:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ab2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 ab9:	77 07                	ja     ac2 <morecore+0x16>
    nu = 4096;
 abb:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ac2:	8b 45 08             	mov    0x8(%ebp),%eax
 ac5:	c1 e0 03             	shl    $0x3,%eax
 ac8:	83 ec 0c             	sub    $0xc,%esp
 acb:	50                   	push   %eax
 acc:	e8 7d fc ff ff       	call   74e <sbrk>
 ad1:	83 c4 10             	add    $0x10,%esp
 ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ad7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 adb:	75 07                	jne    ae4 <morecore+0x38>
    return 0;
 add:	b8 00 00 00 00       	mov    $0x0,%eax
 ae2:	eb 26                	jmp    b0a <morecore+0x5e>
  hp = (Header*)p;
 ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aed:	8b 55 08             	mov    0x8(%ebp),%edx
 af0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af6:	83 c0 08             	add    $0x8,%eax
 af9:	83 ec 0c             	sub    $0xc,%esp
 afc:	50                   	push   %eax
 afd:	e8 c9 fe ff ff       	call   9cb <free>
 b02:	83 c4 10             	add    $0x10,%esp
  return freep;
 b05:	a1 0c 0f 00 00       	mov    0xf0c,%eax
}
 b0a:	c9                   	leave  
 b0b:	c3                   	ret    

00000b0c <malloc>:

void*
malloc(uint nbytes)
{
 b0c:	55                   	push   %ebp
 b0d:	89 e5                	mov    %esp,%ebp
 b0f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b12:	8b 45 08             	mov    0x8(%ebp),%eax
 b15:	83 c0 07             	add    $0x7,%eax
 b18:	c1 e8 03             	shr    $0x3,%eax
 b1b:	83 c0 01             	add    $0x1,%eax
 b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b21:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b2d:	75 23                	jne    b52 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b2f:	c7 45 f0 04 0f 00 00 	movl   $0xf04,-0x10(%ebp)
 b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b39:	a3 0c 0f 00 00       	mov    %eax,0xf0c
 b3e:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 b43:	a3 04 0f 00 00       	mov    %eax,0xf04
    base.s.size = 0;
 b48:	c7 05 08 0f 00 00 00 	movl   $0x0,0xf08
 b4f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b55:	8b 00                	mov    (%eax),%eax
 b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5d:	8b 40 04             	mov    0x4(%eax),%eax
 b60:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b63:	72 4d                	jb     bb2 <malloc+0xa6>
      if(p->s.size == nunits)
 b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b68:	8b 40 04             	mov    0x4(%eax),%eax
 b6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b6e:	75 0c                	jne    b7c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b73:	8b 10                	mov    (%eax),%edx
 b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b78:	89 10                	mov    %edx,(%eax)
 b7a:	eb 26                	jmp    ba2 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b7f:	8b 40 04             	mov    0x4(%eax),%eax
 b82:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b85:	89 c2                	mov    %eax,%edx
 b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b8a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b90:	8b 40 04             	mov    0x4(%eax),%eax
 b93:	c1 e0 03             	shl    $0x3,%eax
 b96:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b9f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba5:	a3 0c 0f 00 00       	mov    %eax,0xf0c
      return (void*)(p + 1);
 baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bad:	83 c0 08             	add    $0x8,%eax
 bb0:	eb 3b                	jmp    bed <malloc+0xe1>
    }
    if(p == freep)
 bb2:	a1 0c 0f 00 00       	mov    0xf0c,%eax
 bb7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 bba:	75 1e                	jne    bda <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 bbc:	83 ec 0c             	sub    $0xc,%esp
 bbf:	ff 75 ec             	pushl  -0x14(%ebp)
 bc2:	e8 e5 fe ff ff       	call   aac <morecore>
 bc7:	83 c4 10             	add    $0x10,%esp
 bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bd1:	75 07                	jne    bda <malloc+0xce>
        return 0;
 bd3:	b8 00 00 00 00       	mov    $0x0,%eax
 bd8:	eb 13                	jmp    bed <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be3:	8b 00                	mov    (%eax),%eax
 be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 be8:	e9 6d ff ff ff       	jmp    b5a <malloc+0x4e>
}
 bed:	c9                   	leave  
 bee:	c3                   	ret    
