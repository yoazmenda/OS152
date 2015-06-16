
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c8 38 10 80       	mov    $0x801038c8,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 e0 85 10 80       	push   $0x801085e0
80100042:	68 80 c6 10 80       	push   $0x8010c680
80100047:	e8 fa 4f 00 00       	call   80105046 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 05 11 80 84 	movl   $0x80110584,0x80110590
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 05 11 80 84 	movl   $0x80110584,0x80110594
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 05 11 80       	mov    0x80110594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 05 11 80       	mov    %eax,0x80110594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801000ad:	72 bd                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000af:	c9                   	leave  
801000b0:	c3                   	ret    

801000b1 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b1:	55                   	push   %ebp
801000b2:	89 e5                	mov    %esp,%ebp
801000b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b7:	83 ec 0c             	sub    $0xc,%esp
801000ba:	68 80 c6 10 80       	push   $0x8010c680
801000bf:	e8 a3 4f 00 00       	call   80105067 <acquire>
801000c4:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c7:	a1 94 05 11 80       	mov    0x80110594,%eax
801000cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000cf:	eb 67                	jmp    80100138 <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d4:	8b 40 04             	mov    0x4(%eax),%eax
801000d7:	3b 45 08             	cmp    0x8(%ebp),%eax
801000da:	75 53                	jne    8010012f <bget+0x7e>
801000dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000df:	8b 40 08             	mov    0x8(%eax),%eax
801000e2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e5:	75 48                	jne    8010012f <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ea:	8b 00                	mov    (%eax),%eax
801000ec:	83 e0 01             	and    $0x1,%eax
801000ef:	85 c0                	test   %eax,%eax
801000f1:	75 27                	jne    8010011a <bget+0x69>
        b->flags |= B_BUSY;
801000f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f6:	8b 00                	mov    (%eax),%eax
801000f8:	83 c8 01             	or     $0x1,%eax
801000fb:	89 c2                	mov    %eax,%edx
801000fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100100:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100102:	83 ec 0c             	sub    $0xc,%esp
80100105:	68 80 c6 10 80       	push   $0x8010c680
8010010a:	e8 be 4f 00 00       	call   801050cd <release>
8010010f:	83 c4 10             	add    $0x10,%esp
        return b;
80100112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100115:	e9 98 00 00 00       	jmp    801001b2 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011a:	83 ec 08             	sub    $0x8,%esp
8010011d:	68 80 c6 10 80       	push   $0x8010c680
80100122:	ff 75 f4             	pushl  -0xc(%ebp)
80100125:	e8 fd 4b 00 00       	call   80104d27 <sleep>
8010012a:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012d:	eb 98                	jmp    801000c7 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100132:	8b 40 10             	mov    0x10(%eax),%eax
80100135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100138:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
8010013f:	75 90                	jne    801000d1 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 90 05 11 80       	mov    0x80110590,%eax
80100146:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100149:	eb 51                	jmp    8010019c <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014e:	8b 00                	mov    (%eax),%eax
80100150:	83 e0 01             	and    $0x1,%eax
80100153:	85 c0                	test   %eax,%eax
80100155:	75 3c                	jne    80100193 <bget+0xe2>
80100157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015a:	8b 00                	mov    (%eax),%eax
8010015c:	83 e0 04             	and    $0x4,%eax
8010015f:	85 c0                	test   %eax,%eax
80100161:	75 30                	jne    80100193 <bget+0xe2>
      b->dev = dev;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 08             	mov    0x8(%ebp),%edx
80100169:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	8b 55 0c             	mov    0xc(%ebp),%edx
80100172:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100178:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
8010017e:	83 ec 0c             	sub    $0xc,%esp
80100181:	68 80 c6 10 80       	push   $0x8010c680
80100186:	e8 42 4f 00 00       	call   801050cd <release>
8010018b:	83 c4 10             	add    $0x10,%esp
      return b;
8010018e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100191:	eb 1f                	jmp    801001b2 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100196:	8b 40 0c             	mov    0xc(%eax),%eax
80100199:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019c:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801001a3:	75 a6                	jne    8010014b <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	68 e7 85 10 80       	push   $0x801085e7
801001ad:	e8 aa 03 00 00       	call   8010055c <panic>
}
801001b2:	c9                   	leave  
801001b3:	c3                   	ret    

801001b4 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b4:	55                   	push   %ebp
801001b5:	89 e5                	mov    %esp,%ebp
801001b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ba:	83 ec 08             	sub    $0x8,%esp
801001bd:	ff 75 0c             	pushl  0xc(%ebp)
801001c0:	ff 75 08             	pushl  0x8(%ebp)
801001c3:	e8 e9 fe ff ff       	call   801000b1 <bget>
801001c8:	83 c4 10             	add    $0x10,%esp
801001cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d1:	8b 00                	mov    (%eax),%eax
801001d3:	83 e0 02             	and    $0x2,%eax
801001d6:	85 c0                	test   %eax,%eax
801001d8:	75 0e                	jne    801001e8 <bread+0x34>
    iderw(b);
801001da:	83 ec 0c             	sub    $0xc,%esp
801001dd:	ff 75 f4             	pushl  -0xc(%ebp)
801001e0:	e8 73 27 00 00       	call   80102958 <iderw>
801001e5:	83 c4 10             	add    $0x10,%esp
  return b;
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001eb:	c9                   	leave  
801001ec:	c3                   	ret    

801001ed <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ed:	55                   	push   %ebp
801001ee:	89 e5                	mov    %esp,%ebp
801001f0:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f3:	8b 45 08             	mov    0x8(%ebp),%eax
801001f6:	8b 00                	mov    (%eax),%eax
801001f8:	83 e0 01             	and    $0x1,%eax
801001fb:	85 c0                	test   %eax,%eax
801001fd:	75 0d                	jne    8010020c <bwrite+0x1f>
    panic("bwrite");
801001ff:	83 ec 0c             	sub    $0xc,%esp
80100202:	68 f8 85 10 80       	push   $0x801085f8
80100207:	e8 50 03 00 00       	call   8010055c <panic>
  b->flags |= B_DIRTY;
8010020c:	8b 45 08             	mov    0x8(%ebp),%eax
8010020f:	8b 00                	mov    (%eax),%eax
80100211:	83 c8 04             	or     $0x4,%eax
80100214:	89 c2                	mov    %eax,%edx
80100216:	8b 45 08             	mov    0x8(%ebp),%eax
80100219:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021b:	83 ec 0c             	sub    $0xc,%esp
8010021e:	ff 75 08             	pushl  0x8(%ebp)
80100221:	e8 32 27 00 00       	call   80102958 <iderw>
80100226:	83 c4 10             	add    $0x10,%esp
}
80100229:	c9                   	leave  
8010022a:	c3                   	ret    

8010022b <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022b:	55                   	push   %ebp
8010022c:	89 e5                	mov    %esp,%ebp
8010022e:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 e0 01             	and    $0x1,%eax
80100239:	85 c0                	test   %eax,%eax
8010023b:	75 0d                	jne    8010024a <brelse+0x1f>
    panic("brelse");
8010023d:	83 ec 0c             	sub    $0xc,%esp
80100240:	68 ff 85 10 80       	push   $0x801085ff
80100245:	e8 12 03 00 00       	call   8010055c <panic>

  acquire(&bcache.lock);
8010024a:	83 ec 0c             	sub    $0xc,%esp
8010024d:	68 80 c6 10 80       	push   $0x8010c680
80100252:	e8 10 4e 00 00       	call   80105067 <acquire>
80100257:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025a:	8b 45 08             	mov    0x8(%ebp),%eax
8010025d:	8b 40 10             	mov    0x10(%eax),%eax
80100260:	8b 55 08             	mov    0x8(%ebp),%edx
80100263:	8b 52 0c             	mov    0xc(%edx),%edx
80100266:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100269:	8b 45 08             	mov    0x8(%ebp),%eax
8010026c:	8b 40 0c             	mov    0xc(%eax),%eax
8010026f:	8b 55 08             	mov    0x8(%ebp),%edx
80100272:	8b 52 10             	mov    0x10(%edx),%edx
80100275:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
80100278:	8b 15 94 05 11 80    	mov    0x80110594,%edx
8010027e:	8b 45 08             	mov    0x8(%ebp),%eax
80100281:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100284:	8b 45 08             	mov    0x8(%ebp),%eax
80100287:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
  bcache.head.next->prev = b;
8010028e:	a1 94 05 11 80       	mov    0x80110594,%eax
80100293:	8b 55 08             	mov    0x8(%ebp),%edx
80100296:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100299:	8b 45 08             	mov    0x8(%ebp),%eax
8010029c:	a3 94 05 11 80       	mov    %eax,0x80110594

  b->flags &= ~B_BUSY;
801002a1:	8b 45 08             	mov    0x8(%ebp),%eax
801002a4:	8b 00                	mov    (%eax),%eax
801002a6:	83 e0 fe             	and    $0xfffffffe,%eax
801002a9:	89 c2                	mov    %eax,%edx
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b0:	83 ec 0c             	sub    $0xc,%esp
801002b3:	ff 75 08             	pushl  0x8(%ebp)
801002b6:	e8 55 4b 00 00       	call   80104e10 <wakeup>
801002bb:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 80 c6 10 80       	push   $0x8010c680
801002c6:	e8 02 4e 00 00       	call   801050cd <release>
801002cb:	83 c4 10             	add    $0x10,%esp
}
801002ce:	c9                   	leave  
801002cf:	c3                   	ret    

801002d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d0:	55                   	push   %ebp
801002d1:	89 e5                	mov    %esp,%ebp
801002d3:	83 ec 14             	sub    $0x14,%esp
801002d6:	8b 45 08             	mov    0x8(%ebp),%eax
801002d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e1:	89 c2                	mov    %eax,%edx
801002e3:	ec                   	in     (%dx),%al
801002e4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002e7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002eb:	c9                   	leave  
801002ec:	c3                   	ret    

801002ed <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002ed:	55                   	push   %ebp
801002ee:	89 e5                	mov    %esp,%ebp
801002f0:	83 ec 08             	sub    $0x8,%esp
801002f3:	8b 55 08             	mov    0x8(%ebp),%edx
801002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002f9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002fd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100300:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100304:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100308:	ee                   	out    %al,(%dx)
}
80100309:	c9                   	leave  
8010030a:	c3                   	ret    

8010030b <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030b:	55                   	push   %ebp
8010030c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010030e:	fa                   	cli    
}
8010030f:	5d                   	pop    %ebp
80100310:	c3                   	ret    

80100311 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100311:	55                   	push   %ebp
80100312:	89 e5                	mov    %esp,%ebp
80100314:	53                   	push   %ebx
80100315:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100318:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010031c:	74 1c                	je     8010033a <printint+0x29>
8010031e:	8b 45 08             	mov    0x8(%ebp),%eax
80100321:	c1 e8 1f             	shr    $0x1f,%eax
80100324:	0f b6 c0             	movzbl %al,%eax
80100327:	89 45 10             	mov    %eax,0x10(%ebp)
8010032a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010032e:	74 0a                	je     8010033a <printint+0x29>
    x = -xx;
80100330:	8b 45 08             	mov    0x8(%ebp),%eax
80100333:	f7 d8                	neg    %eax
80100335:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100338:	eb 06                	jmp    80100340 <printint+0x2f>
  else
    x = xx;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100340:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100347:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034a:	8d 41 01             	lea    0x1(%ecx),%eax
8010034d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100353:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100356:	ba 00 00 00 00       	mov    $0x0,%edx
8010035b:	f7 f3                	div    %ebx
8010035d:	89 d0                	mov    %edx,%eax
8010035f:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100366:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010036d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100370:	ba 00 00 00 00       	mov    $0x0,%edx
80100375:	f7 f3                	div    %ebx
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010037e:	75 c7                	jne    80100347 <printint+0x36>

  if(sign)
80100380:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100384:	74 0e                	je     80100394 <printint+0x83>
    buf[i++] = '-';
80100386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100389:	8d 50 01             	lea    0x1(%eax),%edx
8010038c:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010038f:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100394:	eb 1a                	jmp    801003b0 <printint+0x9f>
    consputc(buf[i]);
80100396:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039c:	01 d0                	add    %edx,%eax
8010039e:	0f b6 00             	movzbl (%eax),%eax
801003a1:	0f be c0             	movsbl %al,%eax
801003a4:	83 ec 0c             	sub    $0xc,%esp
801003a7:	50                   	push   %eax
801003a8:	e8 be 03 00 00       	call   8010076b <consputc>
801003ad:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 dc                	jns    80100396 <printint+0x85>
    consputc(buf[i]);
}
801003ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003bd:	c9                   	leave  
801003be:	c3                   	ret    

801003bf <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003bf:	55                   	push   %ebp
801003c0:	89 e5                	mov    %esp,%ebp
801003c2:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c5:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d1:	74 10                	je     801003e3 <cprintf+0x24>
    acquire(&cons.lock);
801003d3:	83 ec 0c             	sub    $0xc,%esp
801003d6:	68 e0 b5 10 80       	push   $0x8010b5e0
801003db:	e8 87 4c 00 00       	call   80105067 <acquire>
801003e0:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e3:	8b 45 08             	mov    0x8(%ebp),%eax
801003e6:	85 c0                	test   %eax,%eax
801003e8:	75 0d                	jne    801003f7 <cprintf+0x38>
    panic("null fmt");
801003ea:	83 ec 0c             	sub    $0xc,%esp
801003ed:	68 06 86 10 80       	push   $0x80108606
801003f2:	e8 65 01 00 00       	call   8010055c <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f7:	8d 45 0c             	lea    0xc(%ebp),%eax
801003fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100404:	e9 1b 01 00 00       	jmp    80100524 <cprintf+0x165>
    if(c != '%'){
80100409:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040d:	74 13                	je     80100422 <cprintf+0x63>
      consputc(c);
8010040f:	83 ec 0c             	sub    $0xc,%esp
80100412:	ff 75 e4             	pushl  -0x1c(%ebp)
80100415:	e8 51 03 00 00       	call   8010076b <consputc>
8010041a:	83 c4 10             	add    $0x10,%esp
      continue;
8010041d:	e9 fe 00 00 00       	jmp    80100520 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
80100422:	8b 55 08             	mov    0x8(%ebp),%edx
80100425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010042c:	01 d0                	add    %edx,%eax
8010042e:	0f b6 00             	movzbl (%eax),%eax
80100431:	0f be c0             	movsbl %al,%eax
80100434:	25 ff 00 00 00       	and    $0xff,%eax
80100439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010043c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100440:	75 05                	jne    80100447 <cprintf+0x88>
      break;
80100442:	e9 fd 00 00 00       	jmp    80100544 <cprintf+0x185>
    switch(c){
80100447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010044a:	83 f8 70             	cmp    $0x70,%eax
8010044d:	74 47                	je     80100496 <cprintf+0xd7>
8010044f:	83 f8 70             	cmp    $0x70,%eax
80100452:	7f 13                	jg     80100467 <cprintf+0xa8>
80100454:	83 f8 25             	cmp    $0x25,%eax
80100457:	0f 84 98 00 00 00    	je     801004f5 <cprintf+0x136>
8010045d:	83 f8 64             	cmp    $0x64,%eax
80100460:	74 14                	je     80100476 <cprintf+0xb7>
80100462:	e9 9d 00 00 00       	jmp    80100504 <cprintf+0x145>
80100467:	83 f8 73             	cmp    $0x73,%eax
8010046a:	74 47                	je     801004b3 <cprintf+0xf4>
8010046c:	83 f8 78             	cmp    $0x78,%eax
8010046f:	74 25                	je     80100496 <cprintf+0xd7>
80100471:	e9 8e 00 00 00       	jmp    80100504 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
80100476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100479:	8d 50 04             	lea    0x4(%eax),%edx
8010047c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010047f:	8b 00                	mov    (%eax),%eax
80100481:	83 ec 04             	sub    $0x4,%esp
80100484:	6a 01                	push   $0x1
80100486:	6a 0a                	push   $0xa
80100488:	50                   	push   %eax
80100489:	e8 83 fe ff ff       	call   80100311 <printint>
8010048e:	83 c4 10             	add    $0x10,%esp
      break;
80100491:	e9 8a 00 00 00       	jmp    80100520 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	83 ec 04             	sub    $0x4,%esp
801004a4:	6a 00                	push   $0x0
801004a6:	6a 10                	push   $0x10
801004a8:	50                   	push   %eax
801004a9:	e8 63 fe ff ff       	call   80100311 <printint>
801004ae:	83 c4 10             	add    $0x10,%esp
      break;
801004b1:	eb 6d                	jmp    80100520 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b6:	8d 50 04             	lea    0x4(%eax),%edx
801004b9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004bc:	8b 00                	mov    (%eax),%eax
801004be:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004c5:	75 07                	jne    801004ce <cprintf+0x10f>
        s = "(null)";
801004c7:	c7 45 ec 0f 86 10 80 	movl   $0x8010860f,-0x14(%ebp)
      for(; *s; s++)
801004ce:	eb 19                	jmp    801004e9 <cprintf+0x12a>
        consputc(*s);
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	0f be c0             	movsbl %al,%eax
801004d9:	83 ec 0c             	sub    $0xc,%esp
801004dc:	50                   	push   %eax
801004dd:	e8 89 02 00 00       	call   8010076b <consputc>
801004e2:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004e5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ec:	0f b6 00             	movzbl (%eax),%eax
801004ef:	84 c0                	test   %al,%al
801004f1:	75 dd                	jne    801004d0 <cprintf+0x111>
        consputc(*s);
      break;
801004f3:	eb 2b                	jmp    80100520 <cprintf+0x161>
    case '%':
      consputc('%');
801004f5:	83 ec 0c             	sub    $0xc,%esp
801004f8:	6a 25                	push   $0x25
801004fa:	e8 6c 02 00 00       	call   8010076b <consputc>
801004ff:	83 c4 10             	add    $0x10,%esp
      break;
80100502:	eb 1c                	jmp    80100520 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100504:	83 ec 0c             	sub    $0xc,%esp
80100507:	6a 25                	push   $0x25
80100509:	e8 5d 02 00 00       	call   8010076b <consputc>
8010050e:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100511:	83 ec 0c             	sub    $0xc,%esp
80100514:	ff 75 e4             	pushl  -0x1c(%ebp)
80100517:	e8 4f 02 00 00       	call   8010076b <consputc>
8010051c:	83 c4 10             	add    $0x10,%esp
      break;
8010051f:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100524:	8b 55 08             	mov    0x8(%ebp),%edx
80100527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010052a:	01 d0                	add    %edx,%eax
8010052c:	0f b6 00             	movzbl (%eax),%eax
8010052f:	0f be c0             	movsbl %al,%eax
80100532:	25 ff 00 00 00       	and    $0xff,%eax
80100537:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010053a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053e:	0f 85 c5 fe ff ff    	jne    80100409 <cprintf+0x4a>
      consputc(c);
      break;
    }
  }

  if(locking)
80100544:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100548:	74 10                	je     8010055a <cprintf+0x19b>
    release(&cons.lock);
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	68 e0 b5 10 80       	push   $0x8010b5e0
80100552:	e8 76 4b 00 00       	call   801050cd <release>
80100557:	83 c4 10             	add    $0x10,%esp
}
8010055a:	c9                   	leave  
8010055b:	c3                   	ret    

8010055c <panic>:

void
panic(char *s)
{
8010055c:	55                   	push   %ebp
8010055d:	89 e5                	mov    %esp,%ebp
8010055f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
80100562:	e8 a4 fd ff ff       	call   8010030b <cli>
  cons.locking = 0;
80100567:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010056e:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100571:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100577:	0f b6 00             	movzbl (%eax),%eax
8010057a:	0f b6 c0             	movzbl %al,%eax
8010057d:	83 ec 08             	sub    $0x8,%esp
80100580:	50                   	push   %eax
80100581:	68 16 86 10 80       	push   $0x80108616
80100586:	e8 34 fe ff ff       	call   801003bf <cprintf>
8010058b:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
8010058e:	8b 45 08             	mov    0x8(%ebp),%eax
80100591:	83 ec 0c             	sub    $0xc,%esp
80100594:	50                   	push   %eax
80100595:	e8 25 fe ff ff       	call   801003bf <cprintf>
8010059a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	68 25 86 10 80       	push   $0x80108625
801005a5:	e8 15 fe ff ff       	call   801003bf <cprintf>
801005aa:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ad:	83 ec 08             	sub    $0x8,%esp
801005b0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005b3:	50                   	push   %eax
801005b4:	8d 45 08             	lea    0x8(%ebp),%eax
801005b7:	50                   	push   %eax
801005b8:	e8 61 4b 00 00       	call   8010511e <getcallerpcs>
801005bd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005c7:	eb 1c                	jmp    801005e5 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005cc:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005d0:	83 ec 08             	sub    $0x8,%esp
801005d3:	50                   	push   %eax
801005d4:	68 27 86 10 80       	push   $0x80108627
801005d9:	e8 e1 fd ff ff       	call   801003bf <cprintf>
801005de:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005e5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005e9:	7e de                	jle    801005c9 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005eb:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005f2:	00 00 00 
  for(;;)
    ;
801005f5:	eb fe                	jmp    801005f5 <panic+0x99>

801005f7 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005f7:	55                   	push   %ebp
801005f8:	89 e5                	mov    %esp,%ebp
801005fa:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005fd:	6a 0e                	push   $0xe
801005ff:	68 d4 03 00 00       	push   $0x3d4
80100604:	e8 e4 fc ff ff       	call   801002ed <outb>
80100609:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010060c:	68 d5 03 00 00       	push   $0x3d5
80100611:	e8 ba fc ff ff       	call   801002d0 <inb>
80100616:	83 c4 04             	add    $0x4,%esp
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	c1 e0 08             	shl    $0x8,%eax
8010061f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100622:	6a 0f                	push   $0xf
80100624:	68 d4 03 00 00       	push   $0x3d4
80100629:	e8 bf fc ff ff       	call   801002ed <outb>
8010062e:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100631:	68 d5 03 00 00       	push   $0x3d5
80100636:	e8 95 fc ff ff       	call   801002d0 <inb>
8010063b:	83 c4 04             	add    $0x4,%esp
8010063e:	0f b6 c0             	movzbl %al,%eax
80100641:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 30                	jne    8010067a <cgaputc+0x83>
    pos += 80 - pos%80;
8010064a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010064d:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100652:	89 c8                	mov    %ecx,%eax
80100654:	f7 ea                	imul   %edx
80100656:	c1 fa 05             	sar    $0x5,%edx
80100659:	89 c8                	mov    %ecx,%eax
8010065b:	c1 f8 1f             	sar    $0x1f,%eax
8010065e:	29 c2                	sub    %eax,%edx
80100660:	89 d0                	mov    %edx,%eax
80100662:	c1 e0 02             	shl    $0x2,%eax
80100665:	01 d0                	add    %edx,%eax
80100667:	c1 e0 04             	shl    $0x4,%eax
8010066a:	29 c1                	sub    %eax,%ecx
8010066c:	89 ca                	mov    %ecx,%edx
8010066e:	b8 50 00 00 00       	mov    $0x50,%eax
80100673:	29 d0                	sub    %edx,%eax
80100675:	01 45 f4             	add    %eax,-0xc(%ebp)
80100678:	eb 34                	jmp    801006ae <cgaputc+0xb7>
  else if(c == BACKSPACE){
8010067a:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100681:	75 0c                	jne    8010068f <cgaputc+0x98>
    if(pos > 0) --pos;
80100683:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100687:	7e 25                	jle    801006ae <cgaputc+0xb7>
80100689:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010068d:	eb 1f                	jmp    801006ae <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010068f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100698:	8d 50 01             	lea    0x1(%eax),%edx
8010069b:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010069e:	01 c0                	add    %eax,%eax
801006a0:	01 c8                	add    %ecx,%eax
801006a2:	8b 55 08             	mov    0x8(%ebp),%edx
801006a5:	0f b6 d2             	movzbl %dl,%edx
801006a8:	80 ce 07             	or     $0x7,%dh
801006ab:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006ae:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006b5:	7e 4c                	jle    80100703 <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b7:	a1 00 90 10 80       	mov    0x80109000,%eax
801006bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006c2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c7:	83 ec 04             	sub    $0x4,%esp
801006ca:	68 60 0e 00 00       	push   $0xe60
801006cf:	52                   	push   %edx
801006d0:	50                   	push   %eax
801006d1:	e8 ac 4c 00 00       	call   80105382 <memmove>
801006d6:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006d9:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006dd:	b8 80 07 00 00       	mov    $0x780,%eax
801006e2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e5:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ed:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006f0:	01 c9                	add    %ecx,%ecx
801006f2:	01 c8                	add    %ecx,%eax
801006f4:	83 ec 04             	sub    $0x4,%esp
801006f7:	52                   	push   %edx
801006f8:	6a 00                	push   $0x0
801006fa:	50                   	push   %eax
801006fb:	e8 c3 4b 00 00       	call   801052c3 <memset>
80100700:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100703:	83 ec 08             	sub    $0x8,%esp
80100706:	6a 0e                	push   $0xe
80100708:	68 d4 03 00 00       	push   $0x3d4
8010070d:	e8 db fb ff ff       	call   801002ed <outb>
80100712:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	83 ec 08             	sub    $0x8,%esp
80100721:	50                   	push   %eax
80100722:	68 d5 03 00 00       	push   $0x3d5
80100727:	e8 c1 fb ff ff       	call   801002ed <outb>
8010072c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010072f:	83 ec 08             	sub    $0x8,%esp
80100732:	6a 0f                	push   $0xf
80100734:	68 d4 03 00 00       	push   $0x3d4
80100739:	e8 af fb ff ff       	call   801002ed <outb>
8010073e:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100744:	0f b6 c0             	movzbl %al,%eax
80100747:	83 ec 08             	sub    $0x8,%esp
8010074a:	50                   	push   %eax
8010074b:	68 d5 03 00 00       	push   $0x3d5
80100750:	e8 98 fb ff ff       	call   801002ed <outb>
80100755:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100771:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 8c fb ff ff       	call   8010030b <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 29                	jne    801007b3 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	83 ec 0c             	sub    $0xc,%esp
8010078d:	6a 08                	push   $0x8
8010078f:	e8 e0 64 00 00       	call   80106c74 <uartputc>
80100794:	83 c4 10             	add    $0x10,%esp
80100797:	83 ec 0c             	sub    $0xc,%esp
8010079a:	6a 20                	push   $0x20
8010079c:	e8 d3 64 00 00       	call   80106c74 <uartputc>
801007a1:	83 c4 10             	add    $0x10,%esp
801007a4:	83 ec 0c             	sub    $0xc,%esp
801007a7:	6a 08                	push   $0x8
801007a9:	e8 c6 64 00 00       	call   80106c74 <uartputc>
801007ae:	83 c4 10             	add    $0x10,%esp
801007b1:	eb 0e                	jmp    801007c1 <consputc+0x56>
  } else
    uartputc(c);
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	ff 75 08             	pushl  0x8(%ebp)
801007b9:	e8 b6 64 00 00       	call   80106c74 <uartputc>
801007be:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007c1:	83 ec 0c             	sub    $0xc,%esp
801007c4:	ff 75 08             	pushl  0x8(%ebp)
801007c7:	e8 2b fe ff ff       	call   801005f7 <cgaputc>
801007cc:	83 c4 10             	add    $0x10,%esp
}
801007cf:	c9                   	leave  
801007d0:	c3                   	ret    

801007d1 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d1:	55                   	push   %ebp
801007d2:	89 e5                	mov    %esp,%ebp
801007d4:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007d7:	83 ec 0c             	sub    $0xc,%esp
801007da:	68 c0 07 11 80       	push   $0x801107c0
801007df:	e8 83 48 00 00       	call   80105067 <acquire>
801007e4:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007e7:	e9 3a 01 00 00       	jmp    80100926 <consoleintr+0x155>
    switch(c){
801007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007ef:	83 f8 10             	cmp    $0x10,%eax
801007f2:	74 1e                	je     80100812 <consoleintr+0x41>
801007f4:	83 f8 10             	cmp    $0x10,%eax
801007f7:	7f 0a                	jg     80100803 <consoleintr+0x32>
801007f9:	83 f8 08             	cmp    $0x8,%eax
801007fc:	74 65                	je     80100863 <consoleintr+0x92>
801007fe:	e9 91 00 00 00       	jmp    80100894 <consoleintr+0xc3>
80100803:	83 f8 15             	cmp    $0x15,%eax
80100806:	74 31                	je     80100839 <consoleintr+0x68>
80100808:	83 f8 7f             	cmp    $0x7f,%eax
8010080b:	74 56                	je     80100863 <consoleintr+0x92>
8010080d:	e9 82 00 00 00       	jmp    80100894 <consoleintr+0xc3>
    case C('P'):  // Process listing.
      procdump();
80100812:	e8 b3 46 00 00       	call   80104eca <procdump>
      break;
80100817:	e9 0a 01 00 00       	jmp    80100926 <consoleintr+0x155>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010081c:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100821:	83 e8 01             	sub    $0x1,%eax
80100824:	a3 7c 08 11 80       	mov    %eax,0x8011087c
        consputc(BACKSPACE);
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	68 00 01 00 00       	push   $0x100
80100831:	e8 35 ff ff ff       	call   8010076b <consputc>
80100836:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100839:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
8010083f:	a1 78 08 11 80       	mov    0x80110878,%eax
80100844:	39 c2                	cmp    %eax,%edx
80100846:	74 16                	je     8010085e <consoleintr+0x8d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100848:	a1 7c 08 11 80       	mov    0x8011087c,%eax
8010084d:	83 e8 01             	sub    $0x1,%eax
80100850:	83 e0 7f             	and    $0x7f,%eax
80100853:	0f b6 80 f4 07 11 80 	movzbl -0x7feef80c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010085a:	3c 0a                	cmp    $0xa,%al
8010085c:	75 be                	jne    8010081c <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010085e:	e9 c3 00 00 00       	jmp    80100926 <consoleintr+0x155>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100863:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
80100869:	a1 78 08 11 80       	mov    0x80110878,%eax
8010086e:	39 c2                	cmp    %eax,%edx
80100870:	74 1d                	je     8010088f <consoleintr+0xbe>
        input.e--;
80100872:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100877:	83 e8 01             	sub    $0x1,%eax
8010087a:	a3 7c 08 11 80       	mov    %eax,0x8011087c
        consputc(BACKSPACE);
8010087f:	83 ec 0c             	sub    $0xc,%esp
80100882:	68 00 01 00 00       	push   $0x100
80100887:	e8 df fe ff ff       	call   8010076b <consputc>
8010088c:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010088f:	e9 92 00 00 00       	jmp    80100926 <consoleintr+0x155>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100894:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100898:	0f 84 87 00 00 00    	je     80100925 <consoleintr+0x154>
8010089e:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
801008a4:	a1 74 08 11 80       	mov    0x80110874,%eax
801008a9:	29 c2                	sub    %eax,%edx
801008ab:	89 d0                	mov    %edx,%eax
801008ad:	83 f8 7f             	cmp    $0x7f,%eax
801008b0:	77 73                	ja     80100925 <consoleintr+0x154>
        c = (c == '\r') ? '\n' : c;
801008b2:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008b6:	74 05                	je     801008bd <consoleintr+0xec>
801008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bb:	eb 05                	jmp    801008c2 <consoleintr+0xf1>
801008bd:	b8 0a 00 00 00       	mov    $0xa,%eax
801008c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c5:	a1 7c 08 11 80       	mov    0x8011087c,%eax
801008ca:	8d 50 01             	lea    0x1(%eax),%edx
801008cd:	89 15 7c 08 11 80    	mov    %edx,0x8011087c
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008d9:	88 90 f4 07 11 80    	mov    %dl,-0x7feef80c(%eax)
        consputc(c);
801008df:	83 ec 0c             	sub    $0xc,%esp
801008e2:	ff 75 f4             	pushl  -0xc(%ebp)
801008e5:	e8 81 fe ff ff       	call   8010076b <consputc>
801008ea:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008ed:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008f1:	74 18                	je     8010090b <consoleintr+0x13a>
801008f3:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008f7:	74 12                	je     8010090b <consoleintr+0x13a>
801008f9:	a1 7c 08 11 80       	mov    0x8011087c,%eax
801008fe:	8b 15 74 08 11 80    	mov    0x80110874,%edx
80100904:	83 ea 80             	sub    $0xffffff80,%edx
80100907:	39 d0                	cmp    %edx,%eax
80100909:	75 1a                	jne    80100925 <consoleintr+0x154>
          input.w = input.e;
8010090b:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100910:	a3 78 08 11 80       	mov    %eax,0x80110878
          wakeup(&input.r);
80100915:	83 ec 0c             	sub    $0xc,%esp
80100918:	68 74 08 11 80       	push   $0x80110874
8010091d:	e8 ee 44 00 00       	call   80104e10 <wakeup>
80100922:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100925:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100926:	8b 45 08             	mov    0x8(%ebp),%eax
80100929:	ff d0                	call   *%eax
8010092b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010092e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100932:	0f 89 b4 fe ff ff    	jns    801007ec <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100938:	83 ec 0c             	sub    $0xc,%esp
8010093b:	68 c0 07 11 80       	push   $0x801107c0
80100940:	e8 88 47 00 00       	call   801050cd <release>
80100945:	83 c4 10             	add    $0x10,%esp
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int off, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	83 ec 0c             	sub    $0xc,%esp
80100953:	ff 75 08             	pushl  0x8(%ebp)
80100956:	e8 d8 10 00 00       	call   80101a33 <iunlock>
8010095b:	83 c4 10             	add    $0x10,%esp
  target = n;
8010095e:	8b 45 14             	mov    0x14(%ebp),%eax
80100961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100964:	83 ec 0c             	sub    $0xc,%esp
80100967:	68 c0 07 11 80       	push   $0x801107c0
8010096c:	e8 f6 46 00 00       	call   80105067 <acquire>
80100971:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100974:	e9 b2 00 00 00       	jmp    80100a2b <consoleread+0xe1>
    while(input.r == input.w){
80100979:	eb 4a                	jmp    801009c5 <consoleread+0x7b>
      if(proc->killed){
8010097b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100981:	8b 40 24             	mov    0x24(%eax),%eax
80100984:	85 c0                	test   %eax,%eax
80100986:	74 28                	je     801009b0 <consoleread+0x66>
        release(&input.lock);
80100988:	83 ec 0c             	sub    $0xc,%esp
8010098b:	68 c0 07 11 80       	push   $0x801107c0
80100990:	e8 38 47 00 00       	call   801050cd <release>
80100995:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100998:	83 ec 0c             	sub    $0xc,%esp
8010099b:	ff 75 08             	pushl  0x8(%ebp)
8010099e:	e8 39 0f 00 00       	call   801018dc <ilock>
801009a3:	83 c4 10             	add    $0x10,%esp
        return -1;
801009a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ab:	e9 ad 00 00 00       	jmp    80100a5d <consoleread+0x113>
      }
      sleep(&input.r, &input.lock);
801009b0:	83 ec 08             	sub    $0x8,%esp
801009b3:	68 c0 07 11 80       	push   $0x801107c0
801009b8:	68 74 08 11 80       	push   $0x80110874
801009bd:	e8 65 43 00 00       	call   80104d27 <sleep>
801009c2:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009c5:	8b 15 74 08 11 80    	mov    0x80110874,%edx
801009cb:	a1 78 08 11 80       	mov    0x80110878,%eax
801009d0:	39 c2                	cmp    %eax,%edx
801009d2:	74 a7                	je     8010097b <consoleread+0x31>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009d4:	a1 74 08 11 80       	mov    0x80110874,%eax
801009d9:	8d 50 01             	lea    0x1(%eax),%edx
801009dc:	89 15 74 08 11 80    	mov    %edx,0x80110874
801009e2:	83 e0 7f             	and    $0x7f,%eax
801009e5:	0f b6 80 f4 07 11 80 	movzbl -0x7feef80c(%eax),%eax
801009ec:	0f be c0             	movsbl %al,%eax
801009ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009f2:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f6:	75 19                	jne    80100a11 <consoleread+0xc7>
      if(n < target){
801009f8:	8b 45 14             	mov    0x14(%ebp),%eax
801009fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009fe:	73 0f                	jae    80100a0f <consoleread+0xc5>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a00:	a1 74 08 11 80       	mov    0x80110874,%eax
80100a05:	83 e8 01             	sub    $0x1,%eax
80100a08:	a3 74 08 11 80       	mov    %eax,0x80110874
      }
      break;
80100a0d:	eb 26                	jmp    80100a35 <consoleread+0xeb>
80100a0f:	eb 24                	jmp    80100a35 <consoleread+0xeb>
    }
    *dst++ = c;
80100a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a14:	8d 50 01             	lea    0x1(%eax),%edx
80100a17:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a1d:	88 10                	mov    %dl,(%eax)
    --n;
80100a1f:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
    if(c == '\n')
80100a23:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a27:	75 02                	jne    80100a2b <consoleread+0xe1>
      break;
80100a29:	eb 0a                	jmp    80100a35 <consoleread+0xeb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a2b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80100a2f:	0f 8f 44 ff ff ff    	jg     80100979 <consoleread+0x2f>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
80100a35:	83 ec 0c             	sub    $0xc,%esp
80100a38:	68 c0 07 11 80       	push   $0x801107c0
80100a3d:	e8 8b 46 00 00       	call   801050cd <release>
80100a42:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a45:	83 ec 0c             	sub    $0xc,%esp
80100a48:	ff 75 08             	pushl  0x8(%ebp)
80100a4b:	e8 8c 0e 00 00       	call   801018dc <ilock>
80100a50:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a53:	8b 45 14             	mov    0x14(%ebp),%eax
80100a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a59:	29 c2                	sub    %eax,%edx
80100a5b:	89 d0                	mov    %edx,%eax
}
80100a5d:	c9                   	leave  
80100a5e:	c3                   	ret    

80100a5f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a5f:	55                   	push   %ebp
80100a60:	89 e5                	mov    %esp,%ebp
80100a62:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a65:	83 ec 0c             	sub    $0xc,%esp
80100a68:	ff 75 08             	pushl  0x8(%ebp)
80100a6b:	e8 c3 0f 00 00       	call   80101a33 <iunlock>
80100a70:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a73:	83 ec 0c             	sub    $0xc,%esp
80100a76:	68 e0 b5 10 80       	push   $0x8010b5e0
80100a7b:	e8 e7 45 00 00       	call   80105067 <acquire>
80100a80:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a8a:	eb 21                	jmp    80100aad <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a92:	01 d0                	add    %edx,%eax
80100a94:	0f b6 00             	movzbl (%eax),%eax
80100a97:	0f be c0             	movsbl %al,%eax
80100a9a:	0f b6 c0             	movzbl %al,%eax
80100a9d:	83 ec 0c             	sub    $0xc,%esp
80100aa0:	50                   	push   %eax
80100aa1:	e8 c5 fc ff ff       	call   8010076b <consputc>
80100aa6:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aa9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ab0:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ab3:	7c d7                	jl     80100a8c <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ab5:	83 ec 0c             	sub    $0xc,%esp
80100ab8:	68 e0 b5 10 80       	push   $0x8010b5e0
80100abd:	e8 0b 46 00 00       	call   801050cd <release>
80100ac2:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ac5:	83 ec 0c             	sub    $0xc,%esp
80100ac8:	ff 75 08             	pushl  0x8(%ebp)
80100acb:	e8 0c 0e 00 00       	call   801018dc <ilock>
80100ad0:	83 c4 10             	add    $0x10,%esp

  return n;
80100ad3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ad6:	c9                   	leave  
80100ad7:	c3                   	ret    

80100ad8 <consoleinit>:

void
consoleinit(void)
{
80100ad8:	55                   	push   %ebp
80100ad9:	89 e5                	mov    %esp,%ebp
80100adb:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100ade:	83 ec 08             	sub    $0x8,%esp
80100ae1:	68 2b 86 10 80       	push   $0x8010862b
80100ae6:	68 e0 b5 10 80       	push   $0x8010b5e0
80100aeb:	e8 56 45 00 00       	call   80105046 <initlock>
80100af0:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100af3:	83 ec 08             	sub    $0x8,%esp
80100af6:	68 33 86 10 80       	push   $0x80108633
80100afb:	68 c0 07 11 80       	push   $0x801107c0
80100b00:	e8 41 45 00 00       	call   80105046 <initlock>
80100b05:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b08:	c7 05 5c 12 11 80 5f 	movl   $0x80100a5f,0x8011125c
80100b0f:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b12:	c7 05 58 12 11 80 4a 	movl   $0x8010094a,0x80111258
80100b19:	09 10 80 
  cons.locking = 1;
80100b1c:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100b23:	00 00 00 

  picenable(IRQ_KBD);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	6a 01                	push   $0x1
80100b2b:	e8 37 34 00 00       	call   80103f67 <picenable>
80100b30:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b33:	83 ec 08             	sub    $0x8,%esp
80100b36:	6a 00                	push   $0x0
80100b38:	6a 01                	push   $0x1
80100b3a:	e8 e2 1f 00 00       	call   80102b21 <ioapicenable>
80100b3f:	83 c4 10             	add    $0x10,%esp
}
80100b42:	c9                   	leave  
80100b43:	c3                   	ret    

80100b44 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b44:	55                   	push   %ebp
80100b45:	89 e5                	mov    %esp,%ebp
80100b47:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b4d:	e8 37 2a 00 00       	call   80103589 <begin_op>
  if((ip = namei(path)) == 0){
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	ff 75 08             	pushl  0x8(%ebp)
80100b58:	e8 57 1a 00 00       	call   801025b4 <namei>
80100b5d:	83 c4 10             	add    $0x10,%esp
80100b60:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b63:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b67:	75 0f                	jne    80100b78 <exec+0x34>
    end_op();
80100b69:	e8 a9 2a 00 00       	call   80103617 <end_op>
    return -1;
80100b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b73:	e9 b9 03 00 00       	jmp    80100f31 <exec+0x3ed>
  }
  ilock(ip);
80100b78:	83 ec 0c             	sub    $0xc,%esp
80100b7b:	ff 75 d8             	pushl  -0x28(%ebp)
80100b7e:	e8 59 0d 00 00       	call   801018dc <ilock>
80100b83:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b86:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b8d:	6a 34                	push   $0x34
80100b8f:	6a 00                	push   $0x0
80100b91:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b97:	50                   	push   %eax
80100b98:	ff 75 d8             	pushl  -0x28(%ebp)
80100b9b:	e8 9e 12 00 00       	call   80101e3e <readi>
80100ba0:	83 c4 10             	add    $0x10,%esp
80100ba3:	83 f8 33             	cmp    $0x33,%eax
80100ba6:	77 05                	ja     80100bad <exec+0x69>
    goto bad;
80100ba8:	e9 52 03 00 00       	jmp    80100eff <exec+0x3bb>
  if(elf.magic != ELF_MAGIC)
80100bad:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bb3:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bb8:	74 05                	je     80100bbf <exec+0x7b>
    goto bad;
80100bba:	e9 40 03 00 00       	jmp    80100eff <exec+0x3bb>

  if((pgdir = setupkvm()) == 0)
80100bbf:	e8 00 72 00 00       	call   80107dc4 <setupkvm>
80100bc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bc7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bcb:	75 05                	jne    80100bd2 <exec+0x8e>
    goto bad;
80100bcd:	e9 2d 03 00 00       	jmp    80100eff <exec+0x3bb>

  // Load program into memory.
  sz = 0;
80100bd2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bd9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100be0:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100be6:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100be9:	e9 ae 00 00 00       	jmp    80100c9c <exec+0x158>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bf1:	6a 20                	push   $0x20
80100bf3:	50                   	push   %eax
80100bf4:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bfa:	50                   	push   %eax
80100bfb:	ff 75 d8             	pushl  -0x28(%ebp)
80100bfe:	e8 3b 12 00 00       	call   80101e3e <readi>
80100c03:	83 c4 10             	add    $0x10,%esp
80100c06:	83 f8 20             	cmp    $0x20,%eax
80100c09:	74 05                	je     80100c10 <exec+0xcc>
      goto bad;
80100c0b:	e9 ef 02 00 00       	jmp    80100eff <exec+0x3bb>
    if(ph.type != ELF_PROG_LOAD)
80100c10:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c16:	83 f8 01             	cmp    $0x1,%eax
80100c19:	74 02                	je     80100c1d <exec+0xd9>
      continue;
80100c1b:	eb 72                	jmp    80100c8f <exec+0x14b>
    if(ph.memsz < ph.filesz)
80100c1d:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c23:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c29:	39 c2                	cmp    %eax,%edx
80100c2b:	73 05                	jae    80100c32 <exec+0xee>
      goto bad;
80100c2d:	e9 cd 02 00 00       	jmp    80100eff <exec+0x3bb>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c32:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c38:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c3e:	01 d0                	add    %edx,%eax
80100c40:	83 ec 04             	sub    $0x4,%esp
80100c43:	50                   	push   %eax
80100c44:	ff 75 e0             	pushl  -0x20(%ebp)
80100c47:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c4a:	e8 18 75 00 00       	call   80108167 <allocuvm>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c55:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c59:	75 05                	jne    80100c60 <exec+0x11c>
      goto bad;
80100c5b:	e9 9f 02 00 00       	jmp    80100eff <exec+0x3bb>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c60:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c66:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c6c:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c72:	83 ec 0c             	sub    $0xc,%esp
80100c75:	52                   	push   %edx
80100c76:	50                   	push   %eax
80100c77:	ff 75 d8             	pushl  -0x28(%ebp)
80100c7a:	51                   	push   %ecx
80100c7b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7e:	e8 0d 74 00 00       	call   80108090 <loaduvm>
80100c83:	83 c4 20             	add    $0x20,%esp
80100c86:	85 c0                	test   %eax,%eax
80100c88:	79 05                	jns    80100c8f <exec+0x14b>
      goto bad;
80100c8a:	e9 70 02 00 00       	jmp    80100eff <exec+0x3bb>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c8f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c96:	83 c0 20             	add    $0x20,%eax
80100c99:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c9c:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100ca3:	0f b7 c0             	movzwl %ax,%eax
80100ca6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100ca9:	0f 8f 3f ff ff ff    	jg     80100bee <exec+0xaa>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100caf:	83 ec 0c             	sub    $0xc,%esp
80100cb2:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb5:	e8 d9 0e 00 00       	call   80101b93 <iunlockput>
80100cba:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cbd:	e8 55 29 00 00       	call   80103617 <end_op>
  ip = 0;
80100cc2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ccc:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cdc:	05 00 20 00 00       	add    $0x2000,%eax
80100ce1:	83 ec 04             	sub    $0x4,%esp
80100ce4:	50                   	push   %eax
80100ce5:	ff 75 e0             	pushl  -0x20(%ebp)
80100ce8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ceb:	e8 77 74 00 00       	call   80108167 <allocuvm>
80100cf0:	83 c4 10             	add    $0x10,%esp
80100cf3:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cfa:	75 05                	jne    80100d01 <exec+0x1bd>
    goto bad;
80100cfc:	e9 fe 01 00 00       	jmp    80100eff <exec+0x3bb>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d04:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d09:	83 ec 08             	sub    $0x8,%esp
80100d0c:	50                   	push   %eax
80100d0d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d10:	e8 77 76 00 00       	call   8010838c <clearpteu>
80100d15:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d1b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d25:	e9 98 00 00 00       	jmp    80100dc2 <exec+0x27e>
    if(argc >= MAXARG)
80100d2a:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d2e:	76 05                	jbe    80100d35 <exec+0x1f1>
      goto bad;
80100d30:	e9 ca 01 00 00       	jmp    80100eff <exec+0x3bb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d42:	01 d0                	add    %edx,%eax
80100d44:	8b 00                	mov    (%eax),%eax
80100d46:	83 ec 0c             	sub    $0xc,%esp
80100d49:	50                   	push   %eax
80100d4a:	e8 c3 47 00 00       	call   80105512 <strlen>
80100d4f:	83 c4 10             	add    $0x10,%esp
80100d52:	89 c2                	mov    %eax,%edx
80100d54:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d57:	29 d0                	sub    %edx,%eax
80100d59:	83 e8 01             	sub    $0x1,%eax
80100d5c:	83 e0 fc             	and    $0xfffffffc,%eax
80100d5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6f:	01 d0                	add    %edx,%eax
80100d71:	8b 00                	mov    (%eax),%eax
80100d73:	83 ec 0c             	sub    $0xc,%esp
80100d76:	50                   	push   %eax
80100d77:	e8 96 47 00 00       	call   80105512 <strlen>
80100d7c:	83 c4 10             	add    $0x10,%esp
80100d7f:	83 c0 01             	add    $0x1,%eax
80100d82:	89 c1                	mov    %eax,%ecx
80100d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d91:	01 d0                	add    %edx,%eax
80100d93:	8b 00                	mov    (%eax),%eax
80100d95:	51                   	push   %ecx
80100d96:	50                   	push   %eax
80100d97:	ff 75 dc             	pushl  -0x24(%ebp)
80100d9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d9d:	e8 a0 77 00 00       	call   80108542 <copyout>
80100da2:	83 c4 10             	add    $0x10,%esp
80100da5:	85 c0                	test   %eax,%eax
80100da7:	79 05                	jns    80100dae <exec+0x26a>
      goto bad;
80100da9:	e9 51 01 00 00       	jmp    80100eff <exec+0x3bb>
    ustack[3+argc] = sp;
80100dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db1:	8d 50 03             	lea    0x3(%eax),%edx
80100db4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100db7:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dbe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcf:	01 d0                	add    %edx,%eax
80100dd1:	8b 00                	mov    (%eax),%eax
80100dd3:	85 c0                	test   %eax,%eax
80100dd5:	0f 85 4f ff ff ff    	jne    80100d2a <exec+0x1e6>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dde:	83 c0 03             	add    $0x3,%eax
80100de1:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100de8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dec:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100df3:	ff ff ff 
  ustack[1] = argc;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 01             	add    $0x1,%eax
80100e05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0f:	29 d0                	sub    %edx,%eax
80100e11:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1a:	83 c0 04             	add    $0x4,%eax
80100e1d:	c1 e0 02             	shl    $0x2,%eax
80100e20:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 04             	add    $0x4,%eax
80100e29:	c1 e0 02             	shl    $0x2,%eax
80100e2c:	50                   	push   %eax
80100e2d:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e33:	50                   	push   %eax
80100e34:	ff 75 dc             	pushl  -0x24(%ebp)
80100e37:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e3a:	e8 03 77 00 00       	call   80108542 <copyout>
80100e3f:	83 c4 10             	add    $0x10,%esp
80100e42:	85 c0                	test   %eax,%eax
80100e44:	79 05                	jns    80100e4b <exec+0x307>
    goto bad;
80100e46:	e9 b4 00 00 00       	jmp    80100eff <exec+0x3bb>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e57:	eb 17                	jmp    80100e70 <exec+0x32c>
    if(*s == '/')
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	0f b6 00             	movzbl (%eax),%eax
80100e5f:	3c 2f                	cmp    $0x2f,%al
80100e61:	75 09                	jne    80100e6c <exec+0x328>
      last = s+1;
80100e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e66:	83 c0 01             	add    $0x1,%eax
80100e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e73:	0f b6 00             	movzbl (%eax),%eax
80100e76:	84 c0                	test   %al,%al
80100e78:	75 df                	jne    80100e59 <exec+0x315>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e80:	83 c0 6c             	add    $0x6c,%eax
80100e83:	83 ec 04             	sub    $0x4,%esp
80100e86:	6a 10                	push   $0x10
80100e88:	ff 75 f0             	pushl  -0x10(%ebp)
80100e8b:	50                   	push   %eax
80100e8c:	e8 37 46 00 00       	call   801054c8 <safestrcpy>
80100e91:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9a:	8b 40 04             	mov    0x4(%eax),%eax
80100e9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb5:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 18             	mov    0x18(%eax),%eax
80100ec0:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec6:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	8b 40 18             	mov    0x18(%eax),%eax
80100ed2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed5:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	50                   	push   %eax
80100ee2:	e8 c2 6f 00 00       	call   80107ea9 <switchuvm>
80100ee7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100eea:	83 ec 0c             	sub    $0xc,%esp
80100eed:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef0:	e8 f8 73 00 00       	call   801082ed <freevm>
80100ef5:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ef8:	b8 00 00 00 00       	mov    $0x0,%eax
80100efd:	eb 32                	jmp    80100f31 <exec+0x3ed>

 bad:
  if(pgdir)
80100eff:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f03:	74 0e                	je     80100f13 <exec+0x3cf>
    freevm(pgdir);
80100f05:	83 ec 0c             	sub    $0xc,%esp
80100f08:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f0b:	e8 dd 73 00 00       	call   801082ed <freevm>
80100f10:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f17:	74 13                	je     80100f2c <exec+0x3e8>
    iunlockput(ip);
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	ff 75 d8             	pushl  -0x28(%ebp)
80100f1f:	e8 6f 0c 00 00       	call   80101b93 <iunlockput>
80100f24:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f27:	e8 eb 26 00 00       	call   80103617 <end_op>
  }
  return -1;
80100f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f31:	c9                   	leave  
80100f32:	c3                   	ret    

80100f33 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f33:	55                   	push   %ebp
80100f34:	89 e5                	mov    %esp,%ebp
80100f36:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f39:	83 ec 08             	sub    $0x8,%esp
80100f3c:	68 39 86 10 80       	push   $0x80108639
80100f41:	68 80 08 11 80       	push   $0x80110880
80100f46:	e8 fb 40 00 00       	call   80105046 <initlock>
80100f4b:	83 c4 10             	add    $0x10,%esp
}
80100f4e:	c9                   	leave  
80100f4f:	c3                   	ret    

80100f50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f50:	55                   	push   %ebp
80100f51:	89 e5                	mov    %esp,%ebp
80100f53:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f56:	83 ec 0c             	sub    $0xc,%esp
80100f59:	68 80 08 11 80       	push   $0x80110880
80100f5e:	e8 04 41 00 00       	call   80105067 <acquire>
80100f63:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	c7 45 f4 b4 08 11 80 	movl   $0x801108b4,-0xc(%ebp)
80100f6d:	eb 2d                	jmp    80100f9c <filealloc+0x4c>
    if(f->ref == 0){
80100f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f72:	8b 40 04             	mov    0x4(%eax),%eax
80100f75:	85 c0                	test   %eax,%eax
80100f77:	75 1f                	jne    80100f98 <filealloc+0x48>
      f->ref = 1;
80100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f83:	83 ec 0c             	sub    $0xc,%esp
80100f86:	68 80 08 11 80       	push   $0x80110880
80100f8b:	e8 3d 41 00 00       	call   801050cd <release>
80100f90:	83 c4 10             	add    $0x10,%esp
      return f;
80100f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f96:	eb 22                	jmp    80100fba <filealloc+0x6a>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f98:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f9c:	81 7d f4 14 12 11 80 	cmpl   $0x80111214,-0xc(%ebp)
80100fa3:	72 ca                	jb     80100f6f <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	68 80 08 11 80       	push   $0x80110880
80100fad:	e8 1b 41 00 00       	call   801050cd <release>
80100fb2:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fba:	c9                   	leave  
80100fbb:	c3                   	ret    

80100fbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fbc:	55                   	push   %ebp
80100fbd:	89 e5                	mov    %esp,%ebp
80100fbf:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100fc2:	83 ec 0c             	sub    $0xc,%esp
80100fc5:	68 80 08 11 80       	push   $0x80110880
80100fca:	e8 98 40 00 00       	call   80105067 <acquire>
80100fcf:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	8b 40 04             	mov    0x4(%eax),%eax
80100fd8:	85 c0                	test   %eax,%eax
80100fda:	7f 0d                	jg     80100fe9 <filedup+0x2d>
    panic("filedup");
80100fdc:	83 ec 0c             	sub    $0xc,%esp
80100fdf:	68 40 86 10 80       	push   $0x80108640
80100fe4:	e8 73 f5 ff ff       	call   8010055c <panic>
  f->ref++;
80100fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fec:	8b 40 04             	mov    0x4(%eax),%eax
80100fef:	8d 50 01             	lea    0x1(%eax),%edx
80100ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 80 08 11 80       	push   $0x80110880
80101000:	e8 c8 40 00 00       	call   801050cd <release>
80101005:	83 c4 10             	add    $0x10,%esp
  return f;
80101008:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010100b:	c9                   	leave  
8010100c:	c3                   	ret    

8010100d <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010100d:	55                   	push   %ebp
8010100e:	89 e5                	mov    %esp,%ebp
80101010:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101013:	83 ec 0c             	sub    $0xc,%esp
80101016:	68 80 08 11 80       	push   $0x80110880
8010101b:	e8 47 40 00 00       	call   80105067 <acquire>
80101020:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101023:	8b 45 08             	mov    0x8(%ebp),%eax
80101026:	8b 40 04             	mov    0x4(%eax),%eax
80101029:	85 c0                	test   %eax,%eax
8010102b:	7f 0d                	jg     8010103a <fileclose+0x2d>
    panic("fileclose");
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 48 86 10 80       	push   $0x80108648
80101035:	e8 22 f5 ff ff       	call   8010055c <panic>
  if(--f->ref > 0){
8010103a:	8b 45 08             	mov    0x8(%ebp),%eax
8010103d:	8b 40 04             	mov    0x4(%eax),%eax
80101040:	8d 50 ff             	lea    -0x1(%eax),%edx
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	89 50 04             	mov    %edx,0x4(%eax)
80101049:	8b 45 08             	mov    0x8(%ebp),%eax
8010104c:	8b 40 04             	mov    0x4(%eax),%eax
8010104f:	85 c0                	test   %eax,%eax
80101051:	7e 15                	jle    80101068 <fileclose+0x5b>
    release(&ftable.lock);
80101053:	83 ec 0c             	sub    $0xc,%esp
80101056:	68 80 08 11 80       	push   $0x80110880
8010105b:	e8 6d 40 00 00       	call   801050cd <release>
80101060:	83 c4 10             	add    $0x10,%esp
80101063:	e9 8b 00 00 00       	jmp    801010f3 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	8b 10                	mov    (%eax),%edx
8010106d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101070:	8b 50 04             	mov    0x4(%eax),%edx
80101073:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101076:	8b 50 08             	mov    0x8(%eax),%edx
80101079:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010107c:	8b 50 0c             	mov    0xc(%eax),%edx
8010107f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101082:	8b 50 10             	mov    0x10(%eax),%edx
80101085:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101088:	8b 40 14             	mov    0x14(%eax),%eax
8010108b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 80 08 11 80       	push   $0x80110880
801010a9:	e8 1f 40 00 00       	call   801050cd <release>
801010ae:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010b4:	83 f8 01             	cmp    $0x1,%eax
801010b7:	75 19                	jne    801010d2 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010b9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010bd:	0f be d0             	movsbl %al,%edx
801010c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010c3:	83 ec 08             	sub    $0x8,%esp
801010c6:	52                   	push   %edx
801010c7:	50                   	push   %eax
801010c8:	e8 01 31 00 00       	call   801041ce <pipeclose>
801010cd:	83 c4 10             	add    $0x10,%esp
801010d0:	eb 21                	jmp    801010f3 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d5:	83 f8 02             	cmp    $0x2,%eax
801010d8:	75 19                	jne    801010f3 <fileclose+0xe6>
    begin_op();
801010da:	e8 aa 24 00 00       	call   80103589 <begin_op>
    iput(ff.ip);
801010df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010e2:	83 ec 0c             	sub    $0xc,%esp
801010e5:	50                   	push   %eax
801010e6:	e8 b9 09 00 00       	call   80101aa4 <iput>
801010eb:	83 c4 10             	add    $0x10,%esp
    end_op();
801010ee:	e8 24 25 00 00       	call   80103617 <end_op>
  }
}
801010f3:	c9                   	leave  
801010f4:	c3                   	ret    

801010f5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801010fb:	8b 45 08             	mov    0x8(%ebp),%eax
801010fe:	8b 00                	mov    (%eax),%eax
80101100:	83 f8 02             	cmp    $0x2,%eax
80101103:	75 40                	jne    80101145 <filestat+0x50>
    ilock(f->ip);
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 10             	mov    0x10(%eax),%eax
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	50                   	push   %eax
8010110f:	e8 c8 07 00 00       	call   801018dc <ilock>
80101114:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	8b 40 10             	mov    0x10(%eax),%eax
8010111d:	83 ec 08             	sub    $0x8,%esp
80101120:	ff 75 0c             	pushl  0xc(%ebp)
80101123:	50                   	push   %eax
80101124:	e8 d0 0c 00 00       	call   80101df9 <stati>
80101129:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	83 ec 0c             	sub    $0xc,%esp
80101135:	50                   	push   %eax
80101136:	e8 f8 08 00 00       	call   80101a33 <iunlock>
8010113b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010113e:	b8 00 00 00 00       	mov    $0x0,%eax
80101143:	eb 05                	jmp    8010114a <filestat+0x55>
  }
  return -1;
80101145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010114a:	c9                   	leave  
8010114b:	c3                   	ret    

8010114c <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010114c:	55                   	push   %ebp
8010114d:	89 e5                	mov    %esp,%ebp
8010114f:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101152:	8b 45 08             	mov    0x8(%ebp),%eax
80101155:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101159:	84 c0                	test   %al,%al
8010115b:	75 0a                	jne    80101167 <fileread+0x1b>
    return -1;
8010115d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101162:	e9 9b 00 00 00       	jmp    80101202 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	8b 00                	mov    (%eax),%eax
8010116c:	83 f8 01             	cmp    $0x1,%eax
8010116f:	75 1a                	jne    8010118b <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 0c             	mov    0xc(%eax),%eax
80101177:	83 ec 04             	sub    $0x4,%esp
8010117a:	ff 75 10             	pushl  0x10(%ebp)
8010117d:	ff 75 0c             	pushl  0xc(%ebp)
80101180:	50                   	push   %eax
80101181:	e8 f5 31 00 00       	call   8010437b <piperead>
80101186:	83 c4 10             	add    $0x10,%esp
80101189:	eb 77                	jmp    80101202 <fileread+0xb6>
  if(f->type == FD_INODE){
8010118b:	8b 45 08             	mov    0x8(%ebp),%eax
8010118e:	8b 00                	mov    (%eax),%eax
80101190:	83 f8 02             	cmp    $0x2,%eax
80101193:	75 60                	jne    801011f5 <fileread+0xa9>
    ilock(f->ip);
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	8b 40 10             	mov    0x10(%eax),%eax
8010119b:	83 ec 0c             	sub    $0xc,%esp
8010119e:	50                   	push   %eax
8010119f:	e8 38 07 00 00       	call   801018dc <ilock>
801011a4:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	8b 50 14             	mov    0x14(%eax),%edx
801011b0:	8b 45 08             	mov    0x8(%ebp),%eax
801011b3:	8b 40 10             	mov    0x10(%eax),%eax
801011b6:	51                   	push   %ecx
801011b7:	52                   	push   %edx
801011b8:	ff 75 0c             	pushl  0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 7d 0c 00 00       	call   80101e3e <readi>
801011c1:	83 c4 10             	add    $0x10,%esp
801011c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011cb:	7e 11                	jle    801011de <fileread+0x92>
      f->off += r;
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 50 14             	mov    0x14(%eax),%edx
801011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011d6:	01 c2                	add    %eax,%edx
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	8b 40 10             	mov    0x10(%eax),%eax
801011e4:	83 ec 0c             	sub    $0xc,%esp
801011e7:	50                   	push   %eax
801011e8:	e8 46 08 00 00       	call   80101a33 <iunlock>
801011ed:	83 c4 10             	add    $0x10,%esp
    return r;
801011f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011f3:	eb 0d                	jmp    80101202 <fileread+0xb6>
  }
  panic("fileread");
801011f5:	83 ec 0c             	sub    $0xc,%esp
801011f8:	68 52 86 10 80       	push   $0x80108652
801011fd:	e8 5a f3 ff ff       	call   8010055c <panic>
}
80101202:	c9                   	leave  
80101203:	c3                   	ret    

80101204 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101204:	55                   	push   %ebp
80101205:	89 e5                	mov    %esp,%ebp
80101207:	53                   	push   %ebx
80101208:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101212:	84 c0                	test   %al,%al
80101214:	75 0a                	jne    80101220 <filewrite+0x1c>
    return -1;
80101216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010121b:	e9 1a 01 00 00       	jmp    8010133a <filewrite+0x136>
  if(f->type == FD_PIPE)
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 00                	mov    (%eax),%eax
80101225:	83 f8 01             	cmp    $0x1,%eax
80101228:	75 1d                	jne    80101247 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 40 0c             	mov    0xc(%eax),%eax
80101230:	83 ec 04             	sub    $0x4,%esp
80101233:	ff 75 10             	pushl  0x10(%ebp)
80101236:	ff 75 0c             	pushl  0xc(%ebp)
80101239:	50                   	push   %eax
8010123a:	e8 38 30 00 00       	call   80104277 <pipewrite>
8010123f:	83 c4 10             	add    $0x10,%esp
80101242:	e9 f3 00 00 00       	jmp    8010133a <filewrite+0x136>
  if(f->type == FD_INODE){
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	8b 00                	mov    (%eax),%eax
8010124c:	83 f8 02             	cmp    $0x2,%eax
8010124f:	0f 85 d8 00 00 00    	jne    8010132d <filewrite+0x129>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101255:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010125c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101263:	e9 a5 00 00 00       	jmp    8010130d <filewrite+0x109>
      int n1 = n - i;
80101268:	8b 45 10             	mov    0x10(%ebp),%eax
8010126b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010126e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101274:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101277:	7e 06                	jle    8010127f <filewrite+0x7b>
        n1 = max;
80101279:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010127c:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010127f:	e8 05 23 00 00       	call   80103589 <begin_op>
      ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	83 ec 0c             	sub    $0xc,%esp
8010128d:	50                   	push   %eax
8010128e:	e8 49 06 00 00       	call   801018dc <ilock>
80101293:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101296:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	8b 50 14             	mov    0x14(%eax),%edx
8010129f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801012a5:	01 c3                	add    %eax,%ebx
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	51                   	push   %ecx
801012ae:	52                   	push   %edx
801012af:	53                   	push   %ebx
801012b0:	50                   	push   %eax
801012b1:	e8 eb 0c 00 00       	call   80101fa1 <writei>
801012b6:	83 c4 10             	add    $0x10,%esp
801012b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c0:	7e 11                	jle    801012d3 <filewrite+0xcf>
        f->off += r;
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012cb:	01 c2                	add    %eax,%edx
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	83 ec 0c             	sub    $0xc,%esp
801012dc:	50                   	push   %eax
801012dd:	e8 51 07 00 00       	call   80101a33 <iunlock>
801012e2:	83 c4 10             	add    $0x10,%esp
      end_op();
801012e5:	e8 2d 23 00 00       	call   80103617 <end_op>

      if(r < 0)
801012ea:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012ee:	79 02                	jns    801012f2 <filewrite+0xee>
        break;
801012f0:	eb 27                	jmp    80101319 <filewrite+0x115>
      if(r != n1)
801012f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012f8:	74 0d                	je     80101307 <filewrite+0x103>
        panic("short filewrite");
801012fa:	83 ec 0c             	sub    $0xc,%esp
801012fd:	68 5b 86 10 80       	push   $0x8010865b
80101302:	e8 55 f2 ff ff       	call   8010055c <panic>
      i += r;
80101307:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	3b 45 10             	cmp    0x10(%ebp),%eax
80101313:	0f 8c 4f ff ff ff    	jl     80101268 <filewrite+0x64>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010131f:	75 05                	jne    80101326 <filewrite+0x122>
80101321:	8b 45 10             	mov    0x10(%ebp),%eax
80101324:	eb 14                	jmp    8010133a <filewrite+0x136>
80101326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010132b:	eb 0d                	jmp    8010133a <filewrite+0x136>
  }
  panic("filewrite");
8010132d:	83 ec 0c             	sub    $0xc,%esp
80101330:	68 6b 86 10 80       	push   $0x8010866b
80101335:	e8 22 f2 ff ff       	call   8010055c <panic>
}
8010133a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010133d:	c9                   	leave  
8010133e:	c3                   	ret    

8010133f <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010133f:	55                   	push   %ebp
80101340:	89 e5                	mov    %esp,%ebp
80101342:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101345:	8b 45 08             	mov    0x8(%ebp),%eax
80101348:	83 ec 08             	sub    $0x8,%esp
8010134b:	6a 01                	push   $0x1
8010134d:	50                   	push   %eax
8010134e:	e8 61 ee ff ff       	call   801001b4 <bread>
80101353:	83 c4 10             	add    $0x10,%esp
80101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135c:	83 c0 18             	add    $0x18,%eax
8010135f:	83 ec 04             	sub    $0x4,%esp
80101362:	6a 10                	push   $0x10
80101364:	50                   	push   %eax
80101365:	ff 75 0c             	pushl  0xc(%ebp)
80101368:	e8 15 40 00 00       	call   80105382 <memmove>
8010136d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101370:	83 ec 0c             	sub    $0xc,%esp
80101373:	ff 75 f4             	pushl  -0xc(%ebp)
80101376:	e8 b0 ee ff ff       	call   8010022b <brelse>
8010137b:	83 c4 10             	add    $0x10,%esp
}
8010137e:	c9                   	leave  
8010137f:	c3                   	ret    

80101380 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101380:	55                   	push   %ebp
80101381:	89 e5                	mov    %esp,%ebp
80101383:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101386:	8b 55 0c             	mov    0xc(%ebp),%edx
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	83 ec 08             	sub    $0x8,%esp
8010138f:	52                   	push   %edx
80101390:	50                   	push   %eax
80101391:	e8 1e ee ff ff       	call   801001b4 <bread>
80101396:	83 c4 10             	add    $0x10,%esp
80101399:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139f:	83 c0 18             	add    $0x18,%eax
801013a2:	83 ec 04             	sub    $0x4,%esp
801013a5:	68 00 02 00 00       	push   $0x200
801013aa:	6a 00                	push   $0x0
801013ac:	50                   	push   %eax
801013ad:	e8 11 3f 00 00       	call   801052c3 <memset>
801013b2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 00 24 00 00       	call   801037c0 <log_write>
801013c0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013c3:	83 ec 0c             	sub    $0xc,%esp
801013c6:	ff 75 f4             	pushl  -0xc(%ebp)
801013c9:	e8 5d ee ff ff       	call   8010022b <brelse>
801013ce:	83 c4 10             	add    $0x10,%esp
}
801013d1:	c9                   	leave  
801013d2:	c3                   	ret    

801013d3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013d3:	55                   	push   %ebp
801013d4:	89 e5                	mov    %esp,%ebp
801013d6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	83 ec 08             	sub    $0x8,%esp
801013e6:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013e9:	52                   	push   %edx
801013ea:	50                   	push   %eax
801013eb:	e8 4f ff ff ff       	call   8010133f <readsb>
801013f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801013f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013fa:	e9 15 01 00 00       	jmp    80101514 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101402:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101408:	85 c0                	test   %eax,%eax
8010140a:	0f 48 c2             	cmovs  %edx,%eax
8010140d:	c1 f8 0c             	sar    $0xc,%eax
80101410:	89 c2                	mov    %eax,%edx
80101412:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101415:	c1 e8 03             	shr    $0x3,%eax
80101418:	01 d0                	add    %edx,%eax
8010141a:	83 c0 03             	add    $0x3,%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	50                   	push   %eax
80101421:	ff 75 08             	pushl  0x8(%ebp)
80101424:	e8 8b ed ff ff       	call   801001b4 <bread>
80101429:	83 c4 10             	add    $0x10,%esp
8010142c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010142f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101436:	e9 a6 00 00 00       	jmp    801014e1 <balloc+0x10e>
      m = 1 << (bi % 8);
8010143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143e:	99                   	cltd   
8010143f:	c1 ea 1d             	shr    $0x1d,%edx
80101442:	01 d0                	add    %edx,%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	29 d0                	sub    %edx,%eax
80101449:	ba 01 00 00 00       	mov    $0x1,%edx
8010144e:	89 c1                	mov    %eax,%ecx
80101450:	d3 e2                	shl    %cl,%edx
80101452:	89 d0                	mov    %edx,%eax
80101454:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010145a:	8d 50 07             	lea    0x7(%eax),%edx
8010145d:	85 c0                	test   %eax,%eax
8010145f:	0f 48 c2             	cmovs  %edx,%eax
80101462:	c1 f8 03             	sar    $0x3,%eax
80101465:	89 c2                	mov    %eax,%edx
80101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010146f:	0f b6 c0             	movzbl %al,%eax
80101472:	23 45 e8             	and    -0x18(%ebp),%eax
80101475:	85 c0                	test   %eax,%eax
80101477:	75 64                	jne    801014dd <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147c:	8d 50 07             	lea    0x7(%eax),%edx
8010147f:	85 c0                	test   %eax,%eax
80101481:	0f 48 c2             	cmovs  %edx,%eax
80101484:	c1 f8 03             	sar    $0x3,%eax
80101487:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010148a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010148f:	89 d1                	mov    %edx,%ecx
80101491:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101494:	09 ca                	or     %ecx,%edx
80101496:	89 d1                	mov    %edx,%ecx
80101498:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010149b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010149f:	83 ec 0c             	sub    $0xc,%esp
801014a2:	ff 75 ec             	pushl  -0x14(%ebp)
801014a5:	e8 16 23 00 00       	call   801037c0 <log_write>
801014aa:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014ad:	83 ec 0c             	sub    $0xc,%esp
801014b0:	ff 75 ec             	pushl  -0x14(%ebp)
801014b3:	e8 73 ed ff ff       	call   8010022b <brelse>
801014b8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c1:	01 c2                	add    %eax,%edx
801014c3:	8b 45 08             	mov    0x8(%ebp),%eax
801014c6:	83 ec 08             	sub    $0x8,%esp
801014c9:	52                   	push   %edx
801014ca:	50                   	push   %eax
801014cb:	e8 b0 fe ff ff       	call   80101380 <bzero>
801014d0:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d9:	01 d0                	add    %edx,%eax
801014db:	eb 52                	jmp    8010152f <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014dd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014e1:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014e8:	7f 15                	jg     801014ff <balloc+0x12c>
801014ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f0:	01 d0                	add    %edx,%eax
801014f2:	89 c2                	mov    %eax,%edx
801014f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014f7:	39 c2                	cmp    %eax,%edx
801014f9:	0f 82 3c ff ff ff    	jb     8010143b <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ff:	83 ec 0c             	sub    $0xc,%esp
80101502:	ff 75 ec             	pushl  -0x14(%ebp)
80101505:	e8 21 ed ff ff       	call   8010022b <brelse>
8010150a:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010150d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101517:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010151a:	39 c2                	cmp    %eax,%edx
8010151c:	0f 82 dd fe ff ff    	jb     801013ff <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101522:	83 ec 0c             	sub    $0xc,%esp
80101525:	68 75 86 10 80       	push   $0x80108675
8010152a:	e8 2d f0 ff ff       	call   8010055c <panic>
}
8010152f:	c9                   	leave  
80101530:	c3                   	ret    

80101531 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101531:	55                   	push   %ebp
80101532:	89 e5                	mov    %esp,%ebp
80101534:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101537:	83 ec 08             	sub    $0x8,%esp
8010153a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010153d:	50                   	push   %eax
8010153e:	ff 75 08             	pushl  0x8(%ebp)
80101541:	e8 f9 fd ff ff       	call   8010133f <readsb>
80101546:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010154c:	c1 e8 0c             	shr    $0xc,%eax
8010154f:	89 c2                	mov    %eax,%edx
80101551:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101554:	c1 e8 03             	shr    $0x3,%eax
80101557:	01 d0                	add    %edx,%eax
80101559:	8d 50 03             	lea    0x3(%eax),%edx
8010155c:	8b 45 08             	mov    0x8(%ebp),%eax
8010155f:	83 ec 08             	sub    $0x8,%esp
80101562:	52                   	push   %edx
80101563:	50                   	push   %eax
80101564:	e8 4b ec ff ff       	call   801001b4 <bread>
80101569:	83 c4 10             	add    $0x10,%esp
8010156c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010156f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101572:	25 ff 0f 00 00       	and    $0xfff,%eax
80101577:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157d:	99                   	cltd   
8010157e:	c1 ea 1d             	shr    $0x1d,%edx
80101581:	01 d0                	add    %edx,%eax
80101583:	83 e0 07             	and    $0x7,%eax
80101586:	29 d0                	sub    %edx,%eax
80101588:	ba 01 00 00 00       	mov    $0x1,%edx
8010158d:	89 c1                	mov    %eax,%ecx
8010158f:	d3 e2                	shl    %cl,%edx
80101591:	89 d0                	mov    %edx,%eax
80101593:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101599:	8d 50 07             	lea    0x7(%eax),%edx
8010159c:	85 c0                	test   %eax,%eax
8010159e:	0f 48 c2             	cmovs  %edx,%eax
801015a1:	c1 f8 03             	sar    $0x3,%eax
801015a4:	89 c2                	mov    %eax,%edx
801015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a9:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015ae:	0f b6 c0             	movzbl %al,%eax
801015b1:	23 45 ec             	and    -0x14(%ebp),%eax
801015b4:	85 c0                	test   %eax,%eax
801015b6:	75 0d                	jne    801015c5 <bfree+0x94>
    panic("freeing free block");
801015b8:	83 ec 0c             	sub    $0xc,%esp
801015bb:	68 8b 86 10 80       	push   $0x8010868b
801015c0:	e8 97 ef ff ff       	call   8010055c <panic>
  bp->data[bi/8] &= ~m;
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	8d 50 07             	lea    0x7(%eax),%edx
801015cb:	85 c0                	test   %eax,%eax
801015cd:	0f 48 c2             	cmovs  %edx,%eax
801015d0:	c1 f8 03             	sar    $0x3,%eax
801015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015db:	89 d1                	mov    %edx,%ecx
801015dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015e0:	f7 d2                	not    %edx
801015e2:	21 ca                	and    %ecx,%edx
801015e4:	89 d1                	mov    %edx,%ecx
801015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e9:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015ed:	83 ec 0c             	sub    $0xc,%esp
801015f0:	ff 75 f4             	pushl  -0xc(%ebp)
801015f3:	e8 c8 21 00 00       	call   801037c0 <log_write>
801015f8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015fb:	83 ec 0c             	sub    $0xc,%esp
801015fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101601:	e8 25 ec ff ff       	call   8010022b <brelse>
80101606:	83 c4 10             	add    $0x10,%esp
}
80101609:	c9                   	leave  
8010160a:	c3                   	ret    

8010160b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010160b:	55                   	push   %ebp
8010160c:	89 e5                	mov    %esp,%ebp
8010160e:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
80101611:	83 ec 08             	sub    $0x8,%esp
80101614:	68 9e 86 10 80       	push   $0x8010869e
80101619:	68 00 13 11 80       	push   $0x80111300
8010161e:	e8 23 3a 00 00       	call   80105046 <initlock>
80101623:	83 c4 10             	add    $0x10,%esp
}
80101626:	c9                   	leave  
80101627:	c3                   	ret    

80101628 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101628:	55                   	push   %ebp
80101629:	89 e5                	mov    %esp,%ebp
8010162b:	83 ec 38             	sub    $0x38,%esp
8010162e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101631:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101635:	8b 45 08             	mov    0x8(%ebp),%eax
80101638:	83 ec 08             	sub    $0x8,%esp
8010163b:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010163e:	52                   	push   %edx
8010163f:	50                   	push   %eax
80101640:	e8 fa fc ff ff       	call   8010133f <readsb>
80101645:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101648:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010164f:	e9 98 00 00 00       	jmp    801016ec <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
80101654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101657:	c1 e8 03             	shr    $0x3,%eax
8010165a:	83 c0 02             	add    $0x2,%eax
8010165d:	83 ec 08             	sub    $0x8,%esp
80101660:	50                   	push   %eax
80101661:	ff 75 08             	pushl  0x8(%ebp)
80101664:	e8 4b eb ff ff       	call   801001b4 <bread>
80101669:	83 c4 10             	add    $0x10,%esp
8010166c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101672:	8d 50 18             	lea    0x18(%eax),%edx
80101675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101678:	83 e0 07             	and    $0x7,%eax
8010167b:	c1 e0 06             	shl    $0x6,%eax
8010167e:	01 d0                	add    %edx,%eax
80101680:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101683:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101686:	0f b7 00             	movzwl (%eax),%eax
80101689:	66 85 c0             	test   %ax,%ax
8010168c:	75 4c                	jne    801016da <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
8010168e:	83 ec 04             	sub    $0x4,%esp
80101691:	6a 40                	push   $0x40
80101693:	6a 00                	push   $0x0
80101695:	ff 75 ec             	pushl  -0x14(%ebp)
80101698:	e8 26 3c 00 00       	call   801052c3 <memset>
8010169d:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a3:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016a7:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016aa:	83 ec 0c             	sub    $0xc,%esp
801016ad:	ff 75 f0             	pushl  -0x10(%ebp)
801016b0:	e8 0b 21 00 00       	call   801037c0 <log_write>
801016b5:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016b8:	83 ec 0c             	sub    $0xc,%esp
801016bb:	ff 75 f0             	pushl  -0x10(%ebp)
801016be:	e8 68 eb ff ff       	call   8010022b <brelse>
801016c3:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c9:	83 ec 08             	sub    $0x8,%esp
801016cc:	50                   	push   %eax
801016cd:	ff 75 08             	pushl  0x8(%ebp)
801016d0:	e8 ee 00 00 00       	call   801017c3 <iget>
801016d5:	83 c4 10             	add    $0x10,%esp
801016d8:	eb 2d                	jmp    80101707 <ialloc+0xdf>
    }
    brelse(bp);
801016da:	83 ec 0c             	sub    $0xc,%esp
801016dd:	ff 75 f0             	pushl  -0x10(%ebp)
801016e0:	e8 46 eb ff ff       	call   8010022b <brelse>
801016e5:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016f2:	39 c2                	cmp    %eax,%edx
801016f4:	0f 82 5a ff ff ff    	jb     80101654 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016fa:	83 ec 0c             	sub    $0xc,%esp
801016fd:	68 a5 86 10 80       	push   $0x801086a5
80101702:	e8 55 ee ff ff       	call   8010055c <panic>
}
80101707:	c9                   	leave  
80101708:	c3                   	ret    

80101709 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101709:	55                   	push   %ebp
8010170a:	89 e5                	mov    %esp,%ebp
8010170c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010170f:	8b 45 08             	mov    0x8(%ebp),%eax
80101712:	8b 40 04             	mov    0x4(%eax),%eax
80101715:	c1 e8 03             	shr    $0x3,%eax
80101718:	8d 50 02             	lea    0x2(%eax),%edx
8010171b:	8b 45 08             	mov    0x8(%ebp),%eax
8010171e:	8b 00                	mov    (%eax),%eax
80101720:	83 ec 08             	sub    $0x8,%esp
80101723:	52                   	push   %edx
80101724:	50                   	push   %eax
80101725:	e8 8a ea ff ff       	call   801001b4 <bread>
8010172a:	83 c4 10             	add    $0x10,%esp
8010172d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101733:	8d 50 18             	lea    0x18(%eax),%edx
80101736:	8b 45 08             	mov    0x8(%ebp),%eax
80101739:	8b 40 04             	mov    0x4(%eax),%eax
8010173c:	83 e0 07             	and    $0x7,%eax
8010173f:	c1 e0 06             	shl    $0x6,%eax
80101742:	01 d0                	add    %edx,%eax
80101744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101747:	8b 45 08             	mov    0x8(%ebp),%eax
8010174a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101751:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101754:	8b 45 08             	mov    0x8(%ebp),%eax
80101757:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101762:	8b 45 08             	mov    0x8(%ebp),%eax
80101765:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176c:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101770:	8b 45 08             	mov    0x8(%ebp),%eax
80101773:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010177e:	8b 45 08             	mov    0x8(%ebp),%eax
80101781:	8b 50 18             	mov    0x18(%eax),%edx
80101784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101787:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	8d 50 1c             	lea    0x1c(%eax),%edx
80101790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101793:	83 c0 0c             	add    $0xc,%eax
80101796:	83 ec 04             	sub    $0x4,%esp
80101799:	6a 34                	push   $0x34
8010179b:	52                   	push   %edx
8010179c:	50                   	push   %eax
8010179d:	e8 e0 3b 00 00       	call   80105382 <memmove>
801017a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017a5:	83 ec 0c             	sub    $0xc,%esp
801017a8:	ff 75 f4             	pushl  -0xc(%ebp)
801017ab:	e8 10 20 00 00       	call   801037c0 <log_write>
801017b0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017b3:	83 ec 0c             	sub    $0xc,%esp
801017b6:	ff 75 f4             	pushl  -0xc(%ebp)
801017b9:	e8 6d ea ff ff       	call   8010022b <brelse>
801017be:	83 c4 10             	add    $0x10,%esp
}
801017c1:	c9                   	leave  
801017c2:	c3                   	ret    

801017c3 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017c3:	55                   	push   %ebp
801017c4:	89 e5                	mov    %esp,%ebp
801017c6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017c9:	83 ec 0c             	sub    $0xc,%esp
801017cc:	68 00 13 11 80       	push   $0x80111300
801017d1:	e8 91 38 00 00       	call   80105067 <acquire>
801017d6:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801017d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e0:	c7 45 f4 34 13 11 80 	movl   $0x80111334,-0xc(%ebp)
801017e7:	eb 5d                	jmp    80101846 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ec:	8b 40 08             	mov    0x8(%eax),%eax
801017ef:	85 c0                	test   %eax,%eax
801017f1:	7e 39                	jle    8010182c <iget+0x69>
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 00                	mov    (%eax),%eax
801017f8:	3b 45 08             	cmp    0x8(%ebp),%eax
801017fb:	75 2f                	jne    8010182c <iget+0x69>
801017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101800:	8b 40 04             	mov    0x4(%eax),%eax
80101803:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101806:	75 24                	jne    8010182c <iget+0x69>
      ip->ref++;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 40 08             	mov    0x8(%eax),%eax
8010180e:	8d 50 01             	lea    0x1(%eax),%edx
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101817:	83 ec 0c             	sub    $0xc,%esp
8010181a:	68 00 13 11 80       	push   $0x80111300
8010181f:	e8 a9 38 00 00       	call   801050cd <release>
80101824:	83 c4 10             	add    $0x10,%esp
      return ip;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	eb 74                	jmp    801018a0 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010182c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101830:	75 10                	jne    80101842 <iget+0x7f>
80101832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101835:	8b 40 08             	mov    0x8(%eax),%eax
80101838:	85 c0                	test   %eax,%eax
8010183a:	75 06                	jne    80101842 <iget+0x7f>
      empty = ip;
8010183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101842:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101846:	81 7d f4 d4 22 11 80 	cmpl   $0x801122d4,-0xc(%ebp)
8010184d:	72 9a                	jb     801017e9 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010184f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101853:	75 0d                	jne    80101862 <iget+0x9f>
    panic("iget: no inodes");
80101855:	83 ec 0c             	sub    $0xc,%esp
80101858:	68 b7 86 10 80       	push   $0x801086b7
8010185d:	e8 fa ec ff ff       	call   8010055c <panic>

  ip = empty;
80101862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186b:	8b 55 08             	mov    0x8(%ebp),%edx
8010186e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 55 0c             	mov    0xc(%ebp),%edx
80101876:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010188d:	83 ec 0c             	sub    $0xc,%esp
80101890:	68 00 13 11 80       	push   $0x80111300
80101895:	e8 33 38 00 00       	call   801050cd <release>
8010189a:	83 c4 10             	add    $0x10,%esp

  return ip;
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a0:	c9                   	leave  
801018a1:	c3                   	ret    

801018a2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a2:	55                   	push   %ebp
801018a3:	89 e5                	mov    %esp,%ebp
801018a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018a8:	83 ec 0c             	sub    $0xc,%esp
801018ab:	68 00 13 11 80       	push   $0x80111300
801018b0:	e8 b2 37 00 00       	call   80105067 <acquire>
801018b5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 08             	mov    0x8(%eax),%eax
801018be:	8d 50 01             	lea    0x1(%eax),%edx
801018c1:	8b 45 08             	mov    0x8(%ebp),%eax
801018c4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c7:	83 ec 0c             	sub    $0xc,%esp
801018ca:	68 00 13 11 80       	push   $0x80111300
801018cf:	e8 f9 37 00 00       	call   801050cd <release>
801018d4:	83 c4 10             	add    $0x10,%esp
  return ip;
801018d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018da:	c9                   	leave  
801018db:	c3                   	ret    

801018dc <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018dc:	55                   	push   %ebp
801018dd:	89 e5                	mov    %esp,%ebp
801018df:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018e6:	74 0a                	je     801018f2 <ilock+0x16>
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	8b 40 08             	mov    0x8(%eax),%eax
801018ee:	85 c0                	test   %eax,%eax
801018f0:	7f 0d                	jg     801018ff <ilock+0x23>
    panic("ilock");
801018f2:	83 ec 0c             	sub    $0xc,%esp
801018f5:	68 c7 86 10 80       	push   $0x801086c7
801018fa:	e8 5d ec ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
801018ff:	83 ec 0c             	sub    $0xc,%esp
80101902:	68 00 13 11 80       	push   $0x80111300
80101907:	e8 5b 37 00 00       	call   80105067 <acquire>
8010190c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010190f:	eb 13                	jmp    80101924 <ilock+0x48>
    sleep(ip, &icache.lock);
80101911:	83 ec 08             	sub    $0x8,%esp
80101914:	68 00 13 11 80       	push   $0x80111300
80101919:	ff 75 08             	pushl  0x8(%ebp)
8010191c:	e8 06 34 00 00       	call   80104d27 <sleep>
80101921:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 40 0c             	mov    0xc(%eax),%eax
8010192a:	83 e0 01             	and    $0x1,%eax
8010192d:	85 c0                	test   %eax,%eax
8010192f:	75 e0                	jne    80101911 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	8b 40 0c             	mov    0xc(%eax),%eax
80101937:	83 c8 01             	or     $0x1,%eax
8010193a:	89 c2                	mov    %eax,%edx
8010193c:	8b 45 08             	mov    0x8(%ebp),%eax
8010193f:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101942:	83 ec 0c             	sub    $0xc,%esp
80101945:	68 00 13 11 80       	push   $0x80111300
8010194a:	e8 7e 37 00 00       	call   801050cd <release>
8010194f:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	8b 40 0c             	mov    0xc(%eax),%eax
80101958:	83 e0 02             	and    $0x2,%eax
8010195b:	85 c0                	test   %eax,%eax
8010195d:	0f 85 ce 00 00 00    	jne    80101a31 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	8b 40 04             	mov    0x4(%eax),%eax
80101969:	c1 e8 03             	shr    $0x3,%eax
8010196c:	8d 50 02             	lea    0x2(%eax),%edx
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	8b 00                	mov    (%eax),%eax
80101974:	83 ec 08             	sub    $0x8,%esp
80101977:	52                   	push   %edx
80101978:	50                   	push   %eax
80101979:	e8 36 e8 ff ff       	call   801001b4 <bread>
8010197e:	83 c4 10             	add    $0x10,%esp
80101981:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	8d 50 18             	lea    0x18(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	8b 40 04             	mov    0x4(%eax),%eax
80101990:	83 e0 07             	and    $0x7,%eax
80101993:	c1 e0 06             	shl    $0x6,%eax
80101996:	01 d0                	add    %edx,%eax
80101998:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199e:	0f b7 10             	movzwl (%eax),%edx
801019a1:	8b 45 08             	mov    0x8(%ebp),%eax
801019a4:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ab:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019bd:	8b 45 08             	mov    0x8(%ebp),%eax
801019c0:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019cb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ce:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	8b 50 08             	mov    0x8(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e1:	8d 50 0c             	lea    0xc(%eax),%edx
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	83 c0 1c             	add    $0x1c,%eax
801019ea:	83 ec 04             	sub    $0x4,%esp
801019ed:	6a 34                	push   $0x34
801019ef:	52                   	push   %edx
801019f0:	50                   	push   %eax
801019f1:	e8 8c 39 00 00       	call   80105382 <memmove>
801019f6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801019f9:	83 ec 0c             	sub    $0xc,%esp
801019fc:	ff 75 f4             	pushl  -0xc(%ebp)
801019ff:	e8 27 e8 ff ff       	call   8010022b <brelse>
80101a04:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a0d:	83 c8 02             	or     $0x2,%eax
80101a10:	89 c2                	mov    %eax,%edx
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a18:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a1f:	66 85 c0             	test   %ax,%ax
80101a22:	75 0d                	jne    80101a31 <ilock+0x155>
      panic("ilock: no type");
80101a24:	83 ec 0c             	sub    $0xc,%esp
80101a27:	68 cd 86 10 80       	push   $0x801086cd
80101a2c:	e8 2b eb ff ff       	call   8010055c <panic>
  }
}
80101a31:	c9                   	leave  
80101a32:	c3                   	ret    

80101a33 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a33:	55                   	push   %ebp
80101a34:	89 e5                	mov    %esp,%ebp
80101a36:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a39:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a3d:	74 17                	je     80101a56 <iunlock+0x23>
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 40 0c             	mov    0xc(%eax),%eax
80101a45:	83 e0 01             	and    $0x1,%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	74 0a                	je     80101a56 <iunlock+0x23>
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 08             	mov    0x8(%eax),%eax
80101a52:	85 c0                	test   %eax,%eax
80101a54:	7f 0d                	jg     80101a63 <iunlock+0x30>
    panic("iunlock");
80101a56:	83 ec 0c             	sub    $0xc,%esp
80101a59:	68 dc 86 10 80       	push   $0x801086dc
80101a5e:	e8 f9 ea ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
80101a63:	83 ec 0c             	sub    $0xc,%esp
80101a66:	68 00 13 11 80       	push   $0x80111300
80101a6b:	e8 f7 35 00 00       	call   80105067 <acquire>
80101a70:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101a73:	8b 45 08             	mov    0x8(%ebp),%eax
80101a76:	8b 40 0c             	mov    0xc(%eax),%eax
80101a79:	83 e0 fe             	and    $0xfffffffe,%eax
80101a7c:	89 c2                	mov    %eax,%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	ff 75 08             	pushl  0x8(%ebp)
80101a8a:	e8 81 33 00 00       	call   80104e10 <wakeup>
80101a8f:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101a92:	83 ec 0c             	sub    $0xc,%esp
80101a95:	68 00 13 11 80       	push   $0x80111300
80101a9a:	e8 2e 36 00 00       	call   801050cd <release>
80101a9f:	83 c4 10             	add    $0x10,%esp
}
80101aa2:	c9                   	leave  
80101aa3:	c3                   	ret    

80101aa4 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101aa4:	55                   	push   %ebp
80101aa5:	89 e5                	mov    %esp,%ebp
80101aa7:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aaa:	83 ec 0c             	sub    $0xc,%esp
80101aad:	68 00 13 11 80       	push   $0x80111300
80101ab2:	e8 b0 35 00 00       	call   80105067 <acquire>
80101ab7:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 08             	mov    0x8(%eax),%eax
80101ac0:	83 f8 01             	cmp    $0x1,%eax
80101ac3:	0f 85 a9 00 00 00    	jne    80101b72 <iput+0xce>
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 40 0c             	mov    0xc(%eax),%eax
80101acf:	83 e0 02             	and    $0x2,%eax
80101ad2:	85 c0                	test   %eax,%eax
80101ad4:	0f 84 98 00 00 00    	je     80101b72 <iput+0xce>
80101ada:	8b 45 08             	mov    0x8(%ebp),%eax
80101add:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ae1:	66 85 c0             	test   %ax,%ax
80101ae4:	0f 85 88 00 00 00    	jne    80101b72 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	8b 40 0c             	mov    0xc(%eax),%eax
80101af0:	83 e0 01             	and    $0x1,%eax
80101af3:	85 c0                	test   %eax,%eax
80101af5:	74 0d                	je     80101b04 <iput+0x60>
      panic("iput busy");
80101af7:	83 ec 0c             	sub    $0xc,%esp
80101afa:	68 e4 86 10 80       	push   $0x801086e4
80101aff:	e8 58 ea ff ff       	call   8010055c <panic>
    ip->flags |= I_BUSY;
80101b04:	8b 45 08             	mov    0x8(%ebp),%eax
80101b07:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0a:	83 c8 01             	or     $0x1,%eax
80101b0d:	89 c2                	mov    %eax,%edx
80101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b12:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b15:	83 ec 0c             	sub    $0xc,%esp
80101b18:	68 00 13 11 80       	push   $0x80111300
80101b1d:	e8 ab 35 00 00       	call   801050cd <release>
80101b22:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	ff 75 08             	pushl  0x8(%ebp)
80101b2b:	e8 a6 01 00 00       	call   80101cd6 <itrunc>
80101b30:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	ff 75 08             	pushl  0x8(%ebp)
80101b42:	e8 c2 fb ff ff       	call   80101709 <iupdate>
80101b47:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b4a:	83 ec 0c             	sub    $0xc,%esp
80101b4d:	68 00 13 11 80       	push   $0x80111300
80101b52:	e8 10 35 00 00       	call   80105067 <acquire>
80101b57:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b64:	83 ec 0c             	sub    $0xc,%esp
80101b67:	ff 75 08             	pushl  0x8(%ebp)
80101b6a:	e8 a1 32 00 00       	call   80104e10 <wakeup>
80101b6f:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 40 08             	mov    0x8(%eax),%eax
80101b78:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 00 13 11 80       	push   $0x80111300
80101b89:	e8 3f 35 00 00       	call   801050cd <release>
80101b8e:	83 c4 10             	add    $0x10,%esp
}
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b93:	55                   	push   %ebp
80101b94:	89 e5                	mov    %esp,%ebp
80101b96:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101b99:	83 ec 0c             	sub    $0xc,%esp
80101b9c:	ff 75 08             	pushl  0x8(%ebp)
80101b9f:	e8 8f fe ff ff       	call   80101a33 <iunlock>
80101ba4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	ff 75 08             	pushl  0x8(%ebp)
80101bad:	e8 f2 fe ff ff       	call   80101aa4 <iput>
80101bb2:	83 c4 10             	add    $0x10,%esp
}
80101bb5:	c9                   	leave  
80101bb6:	c3                   	ret    

80101bb7 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bb7:	55                   	push   %ebp
80101bb8:	89 e5                	mov    %esp,%ebp
80101bba:	53                   	push   %ebx
80101bbb:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bbe:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101bc2:	77 42                	ja     80101c06 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bca:	83 c2 04             	add    $0x4,%edx
80101bcd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd8:	75 24                	jne    80101bfe <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101bda:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdd:	8b 00                	mov    (%eax),%eax
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	50                   	push   %eax
80101be3:	e8 eb f7 ff ff       	call   801013d3 <balloc>
80101be8:	83 c4 10             	add    $0x10,%esp
80101beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bf4:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfa:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c01:	e9 cb 00 00 00       	jmp    80101cd1 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c06:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c0a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c0e:	0f 87 b0 00 00 00    	ja     80101cc4 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c21:	75 1d                	jne    80101c40 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	8b 00                	mov    (%eax),%eax
80101c28:	83 ec 0c             	sub    $0xc,%esp
80101c2b:	50                   	push   %eax
80101c2c:	e8 a2 f7 ff ff       	call   801013d3 <balloc>
80101c31:	83 c4 10             	add    $0x10,%esp
80101c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3d:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	8b 00                	mov    (%eax),%eax
80101c45:	83 ec 08             	sub    $0x8,%esp
80101c48:	ff 75 f4             	pushl  -0xc(%ebp)
80101c4b:	50                   	push   %eax
80101c4c:	e8 63 e5 ff ff       	call   801001b4 <bread>
80101c51:	83 c4 10             	add    $0x10,%esp
80101c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5a:	83 c0 18             	add    $0x18,%eax
80101c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c6d:	01 d0                	add    %edx,%eax
80101c6f:	8b 00                	mov    (%eax),%eax
80101c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c78:	75 37                	jne    80101cb1 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c7d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c87:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 00                	mov    (%eax),%eax
80101c8f:	83 ec 0c             	sub    $0xc,%esp
80101c92:	50                   	push   %eax
80101c93:	e8 3b f7 ff ff       	call   801013d3 <balloc>
80101c98:	83 c4 10             	add    $0x10,%esp
80101c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca1:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	ff 75 f0             	pushl  -0x10(%ebp)
80101ca9:	e8 12 1b 00 00       	call   801037c0 <log_write>
80101cae:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cb1:	83 ec 0c             	sub    $0xc,%esp
80101cb4:	ff 75 f0             	pushl  -0x10(%ebp)
80101cb7:	e8 6f e5 ff ff       	call   8010022b <brelse>
80101cbc:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc2:	eb 0d                	jmp    80101cd1 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 ee 86 10 80       	push   $0x801086ee
80101ccc:	e8 8b e8 ff ff       	call   8010055c <panic>
}
80101cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101cd4:	c9                   	leave  
80101cd5:	c3                   	ret    

80101cd6 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101cd6:	55                   	push   %ebp
80101cd7:	89 e5                	mov    %esp,%ebp
80101cd9:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ce3:	eb 45                	jmp    80101d2a <itrunc+0x54>
    if(ip->addrs[i]){
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ceb:	83 c2 04             	add    $0x4,%edx
80101cee:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf2:	85 c0                	test   %eax,%eax
80101cf4:	74 30                	je     80101d26 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cfc:	83 c2 04             	add    $0x4,%edx
80101cff:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d03:	8b 55 08             	mov    0x8(%ebp),%edx
80101d06:	8b 12                	mov    (%edx),%edx
80101d08:	83 ec 08             	sub    $0x8,%esp
80101d0b:	50                   	push   %eax
80101d0c:	52                   	push   %edx
80101d0d:	e8 1f f8 ff ff       	call   80101531 <bfree>
80101d12:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1b:	83 c2 04             	add    $0x4,%edx
80101d1e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d25:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d2a:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d2e:	7e b5                	jle    80101ce5 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d36:	85 c0                	test   %eax,%eax
80101d38:	0f 84 a1 00 00 00    	je     80101ddf <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d41:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 00                	mov    (%eax),%eax
80101d49:	83 ec 08             	sub    $0x8,%esp
80101d4c:	52                   	push   %edx
80101d4d:	50                   	push   %eax
80101d4e:	e8 61 e4 ff ff       	call   801001b4 <bread>
80101d53:	83 c4 10             	add    $0x10,%esp
80101d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d5c:	83 c0 18             	add    $0x18,%eax
80101d5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d62:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d69:	eb 3c                	jmp    80101da7 <itrunc+0xd1>
      if(a[j])
80101d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d78:	01 d0                	add    %edx,%eax
80101d7a:	8b 00                	mov    (%eax),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 23                	je     80101da3 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d8d:	01 d0                	add    %edx,%eax
80101d8f:	8b 00                	mov    (%eax),%eax
80101d91:	8b 55 08             	mov    0x8(%ebp),%edx
80101d94:	8b 12                	mov    (%edx),%edx
80101d96:	83 ec 08             	sub    $0x8,%esp
80101d99:	50                   	push   %eax
80101d9a:	52                   	push   %edx
80101d9b:	e8 91 f7 ff ff       	call   80101531 <bfree>
80101da0:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101da3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101daa:	83 f8 7f             	cmp    $0x7f,%eax
80101dad:	76 bc                	jbe    80101d6b <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101daf:	83 ec 0c             	sub    $0xc,%esp
80101db2:	ff 75 ec             	pushl  -0x14(%ebp)
80101db5:	e8 71 e4 ff ff       	call   8010022b <brelse>
80101dba:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dc3:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc6:	8b 12                	mov    (%edx),%edx
80101dc8:	83 ec 08             	sub    $0x8,%esp
80101dcb:	50                   	push   %eax
80101dcc:	52                   	push   %edx
80101dcd:	e8 5f f7 ff ff       	call   80101531 <bfree>
80101dd2:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101de9:	83 ec 0c             	sub    $0xc,%esp
80101dec:	ff 75 08             	pushl  0x8(%ebp)
80101def:	e8 15 f9 ff ff       	call   80101709 <iupdate>
80101df4:	83 c4 10             	add    $0x10,%esp
}
80101df7:	c9                   	leave  
80101df8:	c3                   	ret    

80101df9 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101df9:	55                   	push   %ebp
80101dfa:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 00                	mov    (%eax),%eax
80101e01:	89 c2                	mov    %eax,%edx
80101e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e06:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	8b 50 04             	mov    0x4(%eax),%edx
80101e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e12:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e1f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e29:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 50 18             	mov    0x18(%eax),%edx
80101e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e39:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e3c:	5d                   	pop    %ebp
80101e3d:	c3                   	ret    

80101e3e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e3e:	55                   	push   %ebp
80101e3f:	89 e5                	mov    %esp,%ebp
80101e41:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e4b:	66 83 f8 03          	cmp    $0x3,%ax
80101e4f:	75 65                	jne    80101eb6 <readi+0x78>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e58:	66 85 c0             	test   %ax,%ax
80101e5b:	78 24                	js     80101e81 <readi+0x43>
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e64:	66 83 f8 09          	cmp    $0x9,%ax
80101e68:	7f 17                	jg     80101e81 <readi+0x43>
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e71:	98                   	cwtl   
80101e72:	c1 e0 04             	shl    $0x4,%eax
80101e75:	05 40 12 11 80       	add    $0x80111240,%eax
80101e7a:	8b 40 08             	mov    0x8(%eax),%eax
80101e7d:	85 c0                	test   %eax,%eax
80101e7f:	75 0a                	jne    80101e8b <readi+0x4d>
      return -1;
80101e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e86:	e9 14 01 00 00       	jmp    80101f9f <readi+0x161>
    return devsw[ip->major].read(ip, dst, off, n);
80101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e92:	98                   	cwtl   
80101e93:	c1 e0 04             	shl    $0x4,%eax
80101e96:	05 40 12 11 80       	add    $0x80111240,%eax
80101e9b:	8b 40 08             	mov    0x8(%eax),%eax
80101e9e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ea1:	8b 55 10             	mov    0x10(%ebp),%edx
80101ea4:	51                   	push   %ecx
80101ea5:	52                   	push   %edx
80101ea6:	ff 75 0c             	pushl  0xc(%ebp)
80101ea9:	ff 75 08             	pushl  0x8(%ebp)
80101eac:	ff d0                	call   *%eax
80101eae:	83 c4 10             	add    $0x10,%esp
80101eb1:	e9 e9 00 00 00       	jmp    80101f9f <readi+0x161>
  }

  if(off > ip->size || off + n < off)
80101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb9:	8b 40 18             	mov    0x18(%eax),%eax
80101ebc:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ebf:	72 0d                	jb     80101ece <readi+0x90>
80101ec1:	8b 55 10             	mov    0x10(%ebp),%edx
80101ec4:	8b 45 14             	mov    0x14(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ecc:	73 0a                	jae    80101ed8 <readi+0x9a>
    return -1;
80101ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ed3:	e9 c7 00 00 00       	jmp    80101f9f <readi+0x161>
  if(off + n > ip->size)
80101ed8:	8b 55 10             	mov    0x10(%ebp),%edx
80101edb:	8b 45 14             	mov    0x14(%ebp),%eax
80101ede:	01 c2                	add    %eax,%edx
80101ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee3:	8b 40 18             	mov    0x18(%eax),%eax
80101ee6:	39 c2                	cmp    %eax,%edx
80101ee8:	76 0c                	jbe    80101ef6 <readi+0xb8>
    n = ip->size - off;
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	8b 40 18             	mov    0x18(%eax),%eax
80101ef0:	2b 45 10             	sub    0x10(%ebp),%eax
80101ef3:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101efd:	e9 8e 00 00 00       	jmp    80101f90 <readi+0x152>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f02:	8b 45 10             	mov    0x10(%ebp),%eax
80101f05:	c1 e8 09             	shr    $0x9,%eax
80101f08:	83 ec 08             	sub    $0x8,%esp
80101f0b:	50                   	push   %eax
80101f0c:	ff 75 08             	pushl  0x8(%ebp)
80101f0f:	e8 a3 fc ff ff       	call   80101bb7 <bmap>
80101f14:	83 c4 10             	add    $0x10,%esp
80101f17:	89 c2                	mov    %eax,%edx
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	8b 00                	mov    (%eax),%eax
80101f1e:	83 ec 08             	sub    $0x8,%esp
80101f21:	52                   	push   %edx
80101f22:	50                   	push   %eax
80101f23:	e8 8c e2 ff ff       	call   801001b4 <bread>
80101f28:	83 c4 10             	add    $0x10,%esp
80101f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f2e:	8b 45 10             	mov    0x10(%ebp),%eax
80101f31:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f36:	ba 00 02 00 00       	mov    $0x200,%edx
80101f3b:	29 c2                	sub    %eax,%edx
80101f3d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f40:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f43:	39 c2                	cmp    %eax,%edx
80101f45:	0f 46 c2             	cmovbe %edx,%eax
80101f48:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f4b:	8b 45 10             	mov    0x10(%ebp),%eax
80101f4e:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f53:	8d 50 10             	lea    0x10(%eax),%edx
80101f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f59:	01 d0                	add    %edx,%eax
80101f5b:	83 c0 08             	add    $0x8,%eax
80101f5e:	83 ec 04             	sub    $0x4,%esp
80101f61:	ff 75 ec             	pushl  -0x14(%ebp)
80101f64:	50                   	push   %eax
80101f65:	ff 75 0c             	pushl  0xc(%ebp)
80101f68:	e8 15 34 00 00       	call   80105382 <memmove>
80101f6d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f70:	83 ec 0c             	sub    $0xc,%esp
80101f73:	ff 75 f0             	pushl  -0x10(%ebp)
80101f76:	e8 b0 e2 ff ff       	call   8010022b <brelse>
80101f7b:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f81:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f87:	01 45 10             	add    %eax,0x10(%ebp)
80101f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f8d:	01 45 0c             	add    %eax,0xc(%ebp)
80101f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f93:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f96:	0f 82 66 ff ff ff    	jb     80101f02 <readi+0xc4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f9c:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f9f:	c9                   	leave  
80101fa0:	c3                   	ret    

80101fa1 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fa1:	55                   	push   %ebp
80101fa2:	89 e5                	mov    %esp,%ebp
80101fa4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fae:	66 83 f8 03          	cmp    $0x3,%ax
80101fb2:	75 64                	jne    80102018 <writei+0x77>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fbb:	66 85 c0             	test   %ax,%ax
80101fbe:	78 24                	js     80101fe4 <writei+0x43>
80101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc7:	66 83 f8 09          	cmp    $0x9,%ax
80101fcb:	7f 17                	jg     80101fe4 <writei+0x43>
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd4:	98                   	cwtl   
80101fd5:	c1 e0 04             	shl    $0x4,%eax
80101fd8:	05 40 12 11 80       	add    $0x80111240,%eax
80101fdd:	8b 40 0c             	mov    0xc(%eax),%eax
80101fe0:	85 c0                	test   %eax,%eax
80101fe2:	75 0a                	jne    80101fee <writei+0x4d>
      return -1;
80101fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fe9:	e9 44 01 00 00       	jmp    80102132 <writei+0x191>
    return devsw[ip->major].write(ip, src, n);
80101fee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ff5:	98                   	cwtl   
80101ff6:	c1 e0 04             	shl    $0x4,%eax
80101ff9:	05 40 12 11 80       	add    $0x80111240,%eax
80101ffe:	8b 40 0c             	mov    0xc(%eax),%eax
80102001:	8b 55 14             	mov    0x14(%ebp),%edx
80102004:	83 ec 04             	sub    $0x4,%esp
80102007:	52                   	push   %edx
80102008:	ff 75 0c             	pushl  0xc(%ebp)
8010200b:	ff 75 08             	pushl  0x8(%ebp)
8010200e:	ff d0                	call   *%eax
80102010:	83 c4 10             	add    $0x10,%esp
80102013:	e9 1a 01 00 00       	jmp    80102132 <writei+0x191>
  }

  if(off > ip->size || off + n < off)
80102018:	8b 45 08             	mov    0x8(%ebp),%eax
8010201b:	8b 40 18             	mov    0x18(%eax),%eax
8010201e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102021:	72 0d                	jb     80102030 <writei+0x8f>
80102023:	8b 55 10             	mov    0x10(%ebp),%edx
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
80102029:	01 d0                	add    %edx,%eax
8010202b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202e:	73 0a                	jae    8010203a <writei+0x99>
    return -1;
80102030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102035:	e9 f8 00 00 00       	jmp    80102132 <writei+0x191>
  if(off + n > MAXFILE*BSIZE)
8010203a:	8b 55 10             	mov    0x10(%ebp),%edx
8010203d:	8b 45 14             	mov    0x14(%ebp),%eax
80102040:	01 d0                	add    %edx,%eax
80102042:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102047:	76 0a                	jbe    80102053 <writei+0xb2>
    return -1;
80102049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010204e:	e9 df 00 00 00       	jmp    80102132 <writei+0x191>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102053:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010205a:	e9 9c 00 00 00       	jmp    801020fb <writei+0x15a>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010205f:	8b 45 10             	mov    0x10(%ebp),%eax
80102062:	c1 e8 09             	shr    $0x9,%eax
80102065:	83 ec 08             	sub    $0x8,%esp
80102068:	50                   	push   %eax
80102069:	ff 75 08             	pushl  0x8(%ebp)
8010206c:	e8 46 fb ff ff       	call   80101bb7 <bmap>
80102071:	83 c4 10             	add    $0x10,%esp
80102074:	89 c2                	mov    %eax,%edx
80102076:	8b 45 08             	mov    0x8(%ebp),%eax
80102079:	8b 00                	mov    (%eax),%eax
8010207b:	83 ec 08             	sub    $0x8,%esp
8010207e:	52                   	push   %edx
8010207f:	50                   	push   %eax
80102080:	e8 2f e1 ff ff       	call   801001b4 <bread>
80102085:	83 c4 10             	add    $0x10,%esp
80102088:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010208b:	8b 45 10             	mov    0x10(%ebp),%eax
8010208e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102093:	ba 00 02 00 00       	mov    $0x200,%edx
80102098:	29 c2                	sub    %eax,%edx
8010209a:	8b 45 14             	mov    0x14(%ebp),%eax
8010209d:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020a0:	39 c2                	cmp    %eax,%edx
801020a2:	0f 46 c2             	cmovbe %edx,%eax
801020a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020a8:	8b 45 10             	mov    0x10(%ebp),%eax
801020ab:	25 ff 01 00 00       	and    $0x1ff,%eax
801020b0:	8d 50 10             	lea    0x10(%eax),%edx
801020b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020b6:	01 d0                	add    %edx,%eax
801020b8:	83 c0 08             	add    $0x8,%eax
801020bb:	83 ec 04             	sub    $0x4,%esp
801020be:	ff 75 ec             	pushl  -0x14(%ebp)
801020c1:	ff 75 0c             	pushl  0xc(%ebp)
801020c4:	50                   	push   %eax
801020c5:	e8 b8 32 00 00       	call   80105382 <memmove>
801020ca:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020cd:	83 ec 0c             	sub    $0xc,%esp
801020d0:	ff 75 f0             	pushl  -0x10(%ebp)
801020d3:	e8 e8 16 00 00       	call   801037c0 <log_write>
801020d8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020db:	83 ec 0c             	sub    $0xc,%esp
801020de:	ff 75 f0             	pushl  -0x10(%ebp)
801020e1:	e8 45 e1 ff ff       	call   8010022b <brelse>
801020e6:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ec:	01 45 f4             	add    %eax,-0xc(%ebp)
801020ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f2:	01 45 10             	add    %eax,0x10(%ebp)
801020f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f8:	01 45 0c             	add    %eax,0xc(%ebp)
801020fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020fe:	3b 45 14             	cmp    0x14(%ebp),%eax
80102101:	0f 82 58 ff ff ff    	jb     8010205f <writei+0xbe>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102107:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010210b:	74 22                	je     8010212f <writei+0x18e>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	8b 40 18             	mov    0x18(%eax),%eax
80102113:	3b 45 10             	cmp    0x10(%ebp),%eax
80102116:	73 17                	jae    8010212f <writei+0x18e>
    ip->size = off;
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	8b 55 10             	mov    0x10(%ebp),%edx
8010211e:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102121:	83 ec 0c             	sub    $0xc,%esp
80102124:	ff 75 08             	pushl  0x8(%ebp)
80102127:	e8 dd f5 ff ff       	call   80101709 <iupdate>
8010212c:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010212f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102132:	c9                   	leave  
80102133:	c3                   	ret    

80102134 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102134:	55                   	push   %ebp
80102135:	89 e5                	mov    %esp,%ebp
80102137:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010213a:	83 ec 04             	sub    $0x4,%esp
8010213d:	6a 0e                	push   $0xe
8010213f:	ff 75 0c             	pushl  0xc(%ebp)
80102142:	ff 75 08             	pushl  0x8(%ebp)
80102145:	e8 d0 32 00 00       	call   8010541a <strncmp>
8010214a:	83 c4 10             	add    $0x10,%esp
}
8010214d:	c9                   	leave  
8010214e:	c3                   	ret    

8010214f <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010214f:	55                   	push   %ebp
80102150:	89 e5                	mov    %esp,%ebp
80102152:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;
  struct inode *ip;

  if(dp->type != T_DIR && !IS_DEV_DIR(dp))
80102155:	8b 45 08             	mov    0x8(%ebp),%eax
80102158:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010215c:	66 83 f8 01          	cmp    $0x1,%ax
80102160:	74 51                	je     801021b3 <dirlookup+0x64>
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102169:	66 83 f8 03          	cmp    $0x3,%ax
8010216d:	75 37                	jne    801021a6 <dirlookup+0x57>
8010216f:	8b 45 08             	mov    0x8(%ebp),%eax
80102172:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102176:	98                   	cwtl   
80102177:	c1 e0 04             	shl    $0x4,%eax
8010217a:	05 40 12 11 80       	add    $0x80111240,%eax
8010217f:	8b 00                	mov    (%eax),%eax
80102181:	85 c0                	test   %eax,%eax
80102183:	74 21                	je     801021a6 <dirlookup+0x57>
80102185:	8b 45 08             	mov    0x8(%ebp),%eax
80102188:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010218c:	98                   	cwtl   
8010218d:	c1 e0 04             	shl    $0x4,%eax
80102190:	05 40 12 11 80       	add    $0x80111240,%eax
80102195:	8b 00                	mov    (%eax),%eax
80102197:	83 ec 0c             	sub    $0xc,%esp
8010219a:	ff 75 08             	pushl  0x8(%ebp)
8010219d:	ff d0                	call   *%eax
8010219f:	83 c4 10             	add    $0x10,%esp
801021a2:	85 c0                	test   %eax,%eax
801021a4:	75 0d                	jne    801021b3 <dirlookup+0x64>
    panic("dirlookup not DIR");
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	68 01 87 10 80       	push   $0x80108701
801021ae:	e8 a9 e3 ff ff       	call   8010055c <panic>

  for(off = 0; off < dp->size || dp->type == T_DEV; off += sizeof(de)){
801021b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ba:	e9 f2 00 00 00       	jmp    801022b1 <dirlookup+0x162>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de)) {
801021bf:	6a 10                	push   $0x10
801021c1:	ff 75 f4             	pushl  -0xc(%ebp)
801021c4:	8d 45 dc             	lea    -0x24(%ebp),%eax
801021c7:	50                   	push   %eax
801021c8:	ff 75 08             	pushl  0x8(%ebp)
801021cb:	e8 6e fc ff ff       	call   80101e3e <readi>
801021d0:	83 c4 10             	add    $0x10,%esp
801021d3:	83 f8 10             	cmp    $0x10,%eax
801021d6:	74 24                	je     801021fc <dirlookup+0xad>
      if (dp->type == T_DEV)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 03          	cmp    $0x3,%ax
801021e3:	75 0a                	jne    801021ef <dirlookup+0xa0>
        return 0;
801021e5:	b8 00 00 00 00       	mov    $0x0,%eax
801021ea:	e9 e7 00 00 00       	jmp    801022d6 <dirlookup+0x187>
      else
        panic("dirlink read");
801021ef:	83 ec 0c             	sub    $0xc,%esp
801021f2:	68 13 87 10 80       	push   $0x80108713
801021f7:	e8 60 e3 ff ff       	call   8010055c <panic>
    }
    if(de.inum == 0)
801021fc:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
80102200:	66 85 c0             	test   %ax,%ax
80102203:	75 05                	jne    8010220a <dirlookup+0xbb>
      continue;
80102205:	e9 a3 00 00 00       	jmp    801022ad <dirlookup+0x15e>
    if(namecmp(name, de.name) == 0){
8010220a:	83 ec 08             	sub    $0x8,%esp
8010220d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102210:	83 c0 02             	add    $0x2,%eax
80102213:	50                   	push   %eax
80102214:	ff 75 0c             	pushl  0xc(%ebp)
80102217:	e8 18 ff ff ff       	call   80102134 <namecmp>
8010221c:	83 c4 10             	add    $0x10,%esp
8010221f:	85 c0                	test   %eax,%eax
80102221:	0f 85 86 00 00 00    	jne    801022ad <dirlookup+0x15e>
      // entry matches path element
      if(poff)
80102227:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010222b:	74 08                	je     80102235 <dirlookup+0xe6>
        *poff = off;
8010222d:	8b 45 10             	mov    0x10(%ebp),%eax
80102230:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102233:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102235:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
80102239:	0f b7 c0             	movzwl %ax,%eax
8010223c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      ip = iget(dp->dev, inum);
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
80102242:	8b 00                	mov    (%eax),%eax
80102244:	83 ec 08             	sub    $0x8,%esp
80102247:	ff 75 f0             	pushl  -0x10(%ebp)
8010224a:	50                   	push   %eax
8010224b:	e8 73 f5 ff ff       	call   801017c3 <iget>
80102250:	83 c4 10             	add    $0x10,%esp
80102253:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (!(ip->flags & I_VALID) && dp->type == T_DEV && devsw[dp->major].iread) {
80102256:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102259:	8b 40 0c             	mov    0xc(%eax),%eax
8010225c:	83 e0 02             	and    $0x2,%eax
8010225f:	85 c0                	test   %eax,%eax
80102261:	75 45                	jne    801022a8 <dirlookup+0x159>
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010226a:	66 83 f8 03          	cmp    $0x3,%ax
8010226e:	75 38                	jne    801022a8 <dirlookup+0x159>
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102277:	98                   	cwtl   
80102278:	c1 e0 04             	shl    $0x4,%eax
8010227b:	05 40 12 11 80       	add    $0x80111240,%eax
80102280:	8b 40 04             	mov    0x4(%eax),%eax
80102283:	85 c0                	test   %eax,%eax
80102285:	74 21                	je     801022a8 <dirlookup+0x159>
        devsw[dp->major].iread(dp, ip);
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010228e:	98                   	cwtl   
8010228f:	c1 e0 04             	shl    $0x4,%eax
80102292:	05 40 12 11 80       	add    $0x80111240,%eax
80102297:	8b 40 04             	mov    0x4(%eax),%eax
8010229a:	83 ec 08             	sub    $0x8,%esp
8010229d:	ff 75 ec             	pushl  -0x14(%ebp)
801022a0:	ff 75 08             	pushl  0x8(%ebp)
801022a3:	ff d0                	call   *%eax
801022a5:	83 c4 10             	add    $0x10,%esp
      }
      return ip;
801022a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022ab:	eb 29                	jmp    801022d6 <dirlookup+0x187>
  struct inode *ip;

  if(dp->type != T_DIR && !IS_DEV_DIR(dp))
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size || dp->type == T_DEV; off += sizeof(de)){
801022ad:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022b1:	8b 45 08             	mov    0x8(%ebp),%eax
801022b4:	8b 40 18             	mov    0x18(%eax),%eax
801022b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022ba:	0f 87 ff fe ff ff    	ja     801021bf <dirlookup+0x70>
801022c0:	8b 45 08             	mov    0x8(%ebp),%eax
801022c3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801022c7:	66 83 f8 03          	cmp    $0x3,%ax
801022cb:	0f 84 ee fe ff ff    	je     801021bf <dirlookup+0x70>
      }
      return ip;
    }
  }

  return 0;
801022d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022d6:	c9                   	leave  
801022d7:	c3                   	ret    

801022d8 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022d8:	55                   	push   %ebp
801022d9:	89 e5                	mov    %esp,%ebp
801022db:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022de:	83 ec 04             	sub    $0x4,%esp
801022e1:	6a 00                	push   $0x0
801022e3:	ff 75 0c             	pushl  0xc(%ebp)
801022e6:	ff 75 08             	pushl  0x8(%ebp)
801022e9:	e8 61 fe ff ff       	call   8010214f <dirlookup>
801022ee:	83 c4 10             	add    $0x10,%esp
801022f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022f8:	74 18                	je     80102312 <dirlink+0x3a>
    iput(ip);
801022fa:	83 ec 0c             	sub    $0xc,%esp
801022fd:	ff 75 f0             	pushl  -0x10(%ebp)
80102300:	e8 9f f7 ff ff       	call   80101aa4 <iput>
80102305:	83 c4 10             	add    $0x10,%esp
    return -1;
80102308:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010230d:	e9 9b 00 00 00       	jmp    801023ad <dirlink+0xd5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102312:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102319:	eb 3b                	jmp    80102356 <dirlink+0x7e>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231e:	6a 10                	push   $0x10
80102320:	50                   	push   %eax
80102321:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102324:	50                   	push   %eax
80102325:	ff 75 08             	pushl  0x8(%ebp)
80102328:	e8 11 fb ff ff       	call   80101e3e <readi>
8010232d:	83 c4 10             	add    $0x10,%esp
80102330:	83 f8 10             	cmp    $0x10,%eax
80102333:	74 0d                	je     80102342 <dirlink+0x6a>
      panic("dirlink read");
80102335:	83 ec 0c             	sub    $0xc,%esp
80102338:	68 13 87 10 80       	push   $0x80108713
8010233d:	e8 1a e2 ff ff       	call   8010055c <panic>
    if(de.inum == 0)
80102342:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102346:	66 85 c0             	test   %ax,%ax
80102349:	75 02                	jne    8010234d <dirlink+0x75>
      break;
8010234b:	eb 16                	jmp    80102363 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010234d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102350:	83 c0 10             	add    $0x10,%eax
80102353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102356:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102359:	8b 45 08             	mov    0x8(%ebp),%eax
8010235c:	8b 40 18             	mov    0x18(%eax),%eax
8010235f:	39 c2                	cmp    %eax,%edx
80102361:	72 b8                	jb     8010231b <dirlink+0x43>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102363:	83 ec 04             	sub    $0x4,%esp
80102366:	6a 0e                	push   $0xe
80102368:	ff 75 0c             	pushl  0xc(%ebp)
8010236b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010236e:	83 c0 02             	add    $0x2,%eax
80102371:	50                   	push   %eax
80102372:	e8 f9 30 00 00       	call   80105470 <strncpy>
80102377:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010237a:	8b 45 10             	mov    0x10(%ebp),%eax
8010237d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102384:	6a 10                	push   $0x10
80102386:	50                   	push   %eax
80102387:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238a:	50                   	push   %eax
8010238b:	ff 75 08             	pushl  0x8(%ebp)
8010238e:	e8 0e fc ff ff       	call   80101fa1 <writei>
80102393:	83 c4 10             	add    $0x10,%esp
80102396:	83 f8 10             	cmp    $0x10,%eax
80102399:	74 0d                	je     801023a8 <dirlink+0xd0>
    panic("dirlink");
8010239b:	83 ec 0c             	sub    $0xc,%esp
8010239e:	68 20 87 10 80       	push   $0x80108720
801023a3:	e8 b4 e1 ff ff       	call   8010055c <panic>
  
  return 0;
801023a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023ad:	c9                   	leave  
801023ae:	c3                   	ret    

801023af <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023af:	55                   	push   %ebp
801023b0:	89 e5                	mov    %esp,%ebp
801023b2:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023b5:	eb 04                	jmp    801023bb <skipelem+0xc>
    path++;
801023b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023bb:	8b 45 08             	mov    0x8(%ebp),%eax
801023be:	0f b6 00             	movzbl (%eax),%eax
801023c1:	3c 2f                	cmp    $0x2f,%al
801023c3:	74 f2                	je     801023b7 <skipelem+0x8>
    path++;
  if(*path == 0)
801023c5:	8b 45 08             	mov    0x8(%ebp),%eax
801023c8:	0f b6 00             	movzbl (%eax),%eax
801023cb:	84 c0                	test   %al,%al
801023cd:	75 07                	jne    801023d6 <skipelem+0x27>
    return 0;
801023cf:	b8 00 00 00 00       	mov    $0x0,%eax
801023d4:	eb 7b                	jmp    80102451 <skipelem+0xa2>
  s = path;
801023d6:	8b 45 08             	mov    0x8(%ebp),%eax
801023d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023dc:	eb 04                	jmp    801023e2 <skipelem+0x33>
    path++;
801023de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023e2:	8b 45 08             	mov    0x8(%ebp),%eax
801023e5:	0f b6 00             	movzbl (%eax),%eax
801023e8:	3c 2f                	cmp    $0x2f,%al
801023ea:	74 0a                	je     801023f6 <skipelem+0x47>
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
801023ef:	0f b6 00             	movzbl (%eax),%eax
801023f2:	84 c0                	test   %al,%al
801023f4:	75 e8                	jne    801023de <skipelem+0x2f>
    path++;
  len = path - s;
801023f6:	8b 55 08             	mov    0x8(%ebp),%edx
801023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fc:	29 c2                	sub    %eax,%edx
801023fe:	89 d0                	mov    %edx,%eax
80102400:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102403:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102407:	7e 15                	jle    8010241e <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102409:	83 ec 04             	sub    $0x4,%esp
8010240c:	6a 0e                	push   $0xe
8010240e:	ff 75 f4             	pushl  -0xc(%ebp)
80102411:	ff 75 0c             	pushl  0xc(%ebp)
80102414:	e8 69 2f 00 00       	call   80105382 <memmove>
80102419:	83 c4 10             	add    $0x10,%esp
8010241c:	eb 20                	jmp    8010243e <skipelem+0x8f>
  else {
    memmove(name, s, len);
8010241e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102421:	83 ec 04             	sub    $0x4,%esp
80102424:	50                   	push   %eax
80102425:	ff 75 f4             	pushl  -0xc(%ebp)
80102428:	ff 75 0c             	pushl  0xc(%ebp)
8010242b:	e8 52 2f 00 00       	call   80105382 <memmove>
80102430:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102433:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102436:	8b 45 0c             	mov    0xc(%ebp),%eax
80102439:	01 d0                	add    %edx,%eax
8010243b:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010243e:	eb 04                	jmp    80102444 <skipelem+0x95>
    path++;
80102440:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102444:	8b 45 08             	mov    0x8(%ebp),%eax
80102447:	0f b6 00             	movzbl (%eax),%eax
8010244a:	3c 2f                	cmp    $0x2f,%al
8010244c:	74 f2                	je     80102440 <skipelem+0x91>
    path++;
  return path;
8010244e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102451:	c9                   	leave  
80102452:	c3                   	ret    

80102453 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
80102456:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102459:	8b 45 08             	mov    0x8(%ebp),%eax
8010245c:	0f b6 00             	movzbl (%eax),%eax
8010245f:	3c 2f                	cmp    $0x2f,%al
80102461:	75 14                	jne    80102477 <namex+0x24>
    ip = iget(ROOTDEV, ROOTINO);
80102463:	83 ec 08             	sub    $0x8,%esp
80102466:	6a 01                	push   $0x1
80102468:	6a 01                	push   $0x1
8010246a:	e8 54 f3 ff ff       	call   801017c3 <iget>
8010246f:	83 c4 10             	add    $0x10,%esp
80102472:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102475:	eb 18                	jmp    8010248f <namex+0x3c>
  else
    ip = idup(proc->cwd);
80102477:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010247d:	8b 40 68             	mov    0x68(%eax),%eax
80102480:	83 ec 0c             	sub    $0xc,%esp
80102483:	50                   	push   %eax
80102484:	e8 19 f4 ff ff       	call   801018a2 <idup>
80102489:	83 c4 10             	add    $0x10,%esp
8010248c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010248f:	e9 e2 00 00 00       	jmp    80102576 <namex+0x123>
    ilock(ip);
80102494:	83 ec 0c             	sub    $0xc,%esp
80102497:	ff 75 f4             	pushl  -0xc(%ebp)
8010249a:	e8 3d f4 ff ff       	call   801018dc <ilock>
8010249f:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR && !IS_DEV_DIR(ip)){
801024a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024a9:	66 83 f8 01          	cmp    $0x1,%ax
801024ad:	74 5c                	je     8010250b <namex+0xb8>
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024b6:	66 83 f8 03          	cmp    $0x3,%ax
801024ba:	75 37                	jne    801024f3 <namex+0xa0>
801024bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024bf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024c3:	98                   	cwtl   
801024c4:	c1 e0 04             	shl    $0x4,%eax
801024c7:	05 40 12 11 80       	add    $0x80111240,%eax
801024cc:	8b 00                	mov    (%eax),%eax
801024ce:	85 c0                	test   %eax,%eax
801024d0:	74 21                	je     801024f3 <namex+0xa0>
801024d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024d9:	98                   	cwtl   
801024da:	c1 e0 04             	shl    $0x4,%eax
801024dd:	05 40 12 11 80       	add    $0x80111240,%eax
801024e2:	8b 00                	mov    (%eax),%eax
801024e4:	83 ec 0c             	sub    $0xc,%esp
801024e7:	ff 75 f4             	pushl  -0xc(%ebp)
801024ea:	ff d0                	call   *%eax
801024ec:	83 c4 10             	add    $0x10,%esp
801024ef:	85 c0                	test   %eax,%eax
801024f1:	75 18                	jne    8010250b <namex+0xb8>
      iunlockput(ip);
801024f3:	83 ec 0c             	sub    $0xc,%esp
801024f6:	ff 75 f4             	pushl  -0xc(%ebp)
801024f9:	e8 95 f6 ff ff       	call   80101b93 <iunlockput>
801024fe:	83 c4 10             	add    $0x10,%esp
      return 0;
80102501:	b8 00 00 00 00       	mov    $0x0,%eax
80102506:	e9 a7 00 00 00       	jmp    801025b2 <namex+0x15f>
    }
    if(nameiparent && *path == '\0'){
8010250b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250f:	74 20                	je     80102531 <namex+0xde>
80102511:	8b 45 08             	mov    0x8(%ebp),%eax
80102514:	0f b6 00             	movzbl (%eax),%eax
80102517:	84 c0                	test   %al,%al
80102519:	75 16                	jne    80102531 <namex+0xde>
      // Stop one level early.
      iunlock(ip);
8010251b:	83 ec 0c             	sub    $0xc,%esp
8010251e:	ff 75 f4             	pushl  -0xc(%ebp)
80102521:	e8 0d f5 ff ff       	call   80101a33 <iunlock>
80102526:	83 c4 10             	add    $0x10,%esp
      return ip;
80102529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252c:	e9 81 00 00 00       	jmp    801025b2 <namex+0x15f>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102531:	83 ec 04             	sub    $0x4,%esp
80102534:	6a 00                	push   $0x0
80102536:	ff 75 10             	pushl  0x10(%ebp)
80102539:	ff 75 f4             	pushl  -0xc(%ebp)
8010253c:	e8 0e fc ff ff       	call   8010214f <dirlookup>
80102541:	83 c4 10             	add    $0x10,%esp
80102544:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102547:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010254b:	75 15                	jne    80102562 <namex+0x10f>
      iunlockput(ip);
8010254d:	83 ec 0c             	sub    $0xc,%esp
80102550:	ff 75 f4             	pushl  -0xc(%ebp)
80102553:	e8 3b f6 ff ff       	call   80101b93 <iunlockput>
80102558:	83 c4 10             	add    $0x10,%esp
      return 0;
8010255b:	b8 00 00 00 00       	mov    $0x0,%eax
80102560:	eb 50                	jmp    801025b2 <namex+0x15f>
    }
    iunlockput(ip);
80102562:	83 ec 0c             	sub    $0xc,%esp
80102565:	ff 75 f4             	pushl  -0xc(%ebp)
80102568:	e8 26 f6 ff ff       	call   80101b93 <iunlockput>
8010256d:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102573:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102576:	83 ec 08             	sub    $0x8,%esp
80102579:	ff 75 10             	pushl  0x10(%ebp)
8010257c:	ff 75 08             	pushl  0x8(%ebp)
8010257f:	e8 2b fe ff ff       	call   801023af <skipelem>
80102584:	83 c4 10             	add    $0x10,%esp
80102587:	89 45 08             	mov    %eax,0x8(%ebp)
8010258a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010258e:	0f 85 00 ff ff ff    	jne    80102494 <namex+0x41>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102594:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102598:	74 15                	je     801025af <namex+0x15c>
    iput(ip);
8010259a:	83 ec 0c             	sub    $0xc,%esp
8010259d:	ff 75 f4             	pushl  -0xc(%ebp)
801025a0:	e8 ff f4 ff ff       	call   80101aa4 <iput>
801025a5:	83 c4 10             	add    $0x10,%esp
    return 0;
801025a8:	b8 00 00 00 00       	mov    $0x0,%eax
801025ad:	eb 03                	jmp    801025b2 <namex+0x15f>
  }
  return ip;
801025af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025b2:	c9                   	leave  
801025b3:	c3                   	ret    

801025b4 <namei>:

struct inode*
namei(char *path)
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
801025b7:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025ba:	83 ec 04             	sub    $0x4,%esp
801025bd:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025c0:	50                   	push   %eax
801025c1:	6a 00                	push   $0x0
801025c3:	ff 75 08             	pushl  0x8(%ebp)
801025c6:	e8 88 fe ff ff       	call   80102453 <namex>
801025cb:	83 c4 10             	add    $0x10,%esp
}
801025ce:	c9                   	leave  
801025cf:	c3                   	ret    

801025d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025d6:	83 ec 04             	sub    $0x4,%esp
801025d9:	ff 75 0c             	pushl  0xc(%ebp)
801025dc:	6a 01                	push   $0x1
801025de:	ff 75 08             	pushl  0x8(%ebp)
801025e1:	e8 6d fe ff ff       	call   80102453 <namex>
801025e6:	83 c4 10             	add    $0x10,%esp
}
801025e9:	c9                   	leave  
801025ea:	c3                   	ret    

801025eb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 14             	sub    $0x14,%esp
801025f1:	8b 45 08             	mov    0x8(%ebp),%eax
801025f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801025fc:	89 c2                	mov    %eax,%edx
801025fe:	ec                   	in     (%dx),%al
801025ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102602:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102606:	c9                   	leave  
80102607:	c3                   	ret    

80102608 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102608:	55                   	push   %ebp
80102609:	89 e5                	mov    %esp,%ebp
8010260b:	57                   	push   %edi
8010260c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010260d:	8b 55 08             	mov    0x8(%ebp),%edx
80102610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102613:	8b 45 10             	mov    0x10(%ebp),%eax
80102616:	89 cb                	mov    %ecx,%ebx
80102618:	89 df                	mov    %ebx,%edi
8010261a:	89 c1                	mov    %eax,%ecx
8010261c:	fc                   	cld    
8010261d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010261f:	89 c8                	mov    %ecx,%eax
80102621:	89 fb                	mov    %edi,%ebx
80102623:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102626:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102629:	5b                   	pop    %ebx
8010262a:	5f                   	pop    %edi
8010262b:	5d                   	pop    %ebp
8010262c:	c3                   	ret    

8010262d <outb>:

static inline void
outb(ushort port, uchar data)
{
8010262d:	55                   	push   %ebp
8010262e:	89 e5                	mov    %esp,%ebp
80102630:	83 ec 08             	sub    $0x8,%esp
80102633:	8b 55 08             	mov    0x8(%ebp),%edx
80102636:	8b 45 0c             	mov    0xc(%ebp),%eax
80102639:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010263d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102640:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102644:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102648:	ee                   	out    %al,(%dx)
}
80102649:	c9                   	leave  
8010264a:	c3                   	ret    

8010264b <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010264b:	55                   	push   %ebp
8010264c:	89 e5                	mov    %esp,%ebp
8010264e:	56                   	push   %esi
8010264f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102650:	8b 55 08             	mov    0x8(%ebp),%edx
80102653:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102656:	8b 45 10             	mov    0x10(%ebp),%eax
80102659:	89 cb                	mov    %ecx,%ebx
8010265b:	89 de                	mov    %ebx,%esi
8010265d:	89 c1                	mov    %eax,%ecx
8010265f:	fc                   	cld    
80102660:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102662:	89 c8                	mov    %ecx,%eax
80102664:	89 f3                	mov    %esi,%ebx
80102666:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102669:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010266c:	5b                   	pop    %ebx
8010266d:	5e                   	pop    %esi
8010266e:	5d                   	pop    %ebp
8010266f:	c3                   	ret    

80102670 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102670:	55                   	push   %ebp
80102671:	89 e5                	mov    %esp,%ebp
80102673:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102676:	90                   	nop
80102677:	68 f7 01 00 00       	push   $0x1f7
8010267c:	e8 6a ff ff ff       	call   801025eb <inb>
80102681:	83 c4 04             	add    $0x4,%esp
80102684:	0f b6 c0             	movzbl %al,%eax
80102687:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010268a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010268d:	25 c0 00 00 00       	and    $0xc0,%eax
80102692:	83 f8 40             	cmp    $0x40,%eax
80102695:	75 e0                	jne    80102677 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102697:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010269b:	74 11                	je     801026ae <idewait+0x3e>
8010269d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026a0:	83 e0 21             	and    $0x21,%eax
801026a3:	85 c0                	test   %eax,%eax
801026a5:	74 07                	je     801026ae <idewait+0x3e>
    return -1;
801026a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026ac:	eb 05                	jmp    801026b3 <idewait+0x43>
  return 0;
801026ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026b3:	c9                   	leave  
801026b4:	c3                   	ret    

801026b5 <ideinit>:

void
ideinit(void)
{
801026b5:	55                   	push   %ebp
801026b6:	89 e5                	mov    %esp,%ebp
801026b8:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026bb:	83 ec 08             	sub    $0x8,%esp
801026be:	68 28 87 10 80       	push   $0x80108728
801026c3:	68 20 b6 10 80       	push   $0x8010b620
801026c8:	e8 79 29 00 00       	call   80105046 <initlock>
801026cd:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	6a 0e                	push   $0xe
801026d5:	e8 8d 18 00 00       	call   80103f67 <picenable>
801026da:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026dd:	a1 60 2a 11 80       	mov    0x80112a60,%eax
801026e2:	83 e8 01             	sub    $0x1,%eax
801026e5:	83 ec 08             	sub    $0x8,%esp
801026e8:	50                   	push   %eax
801026e9:	6a 0e                	push   $0xe
801026eb:	e8 31 04 00 00       	call   80102b21 <ioapicenable>
801026f0:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026f3:	83 ec 0c             	sub    $0xc,%esp
801026f6:	6a 00                	push   $0x0
801026f8:	e8 73 ff ff ff       	call   80102670 <idewait>
801026fd:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102700:	83 ec 08             	sub    $0x8,%esp
80102703:	68 f0 00 00 00       	push   $0xf0
80102708:	68 f6 01 00 00       	push   $0x1f6
8010270d:	e8 1b ff ff ff       	call   8010262d <outb>
80102712:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010271c:	eb 24                	jmp    80102742 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010271e:	83 ec 0c             	sub    $0xc,%esp
80102721:	68 f7 01 00 00       	push   $0x1f7
80102726:	e8 c0 fe ff ff       	call   801025eb <inb>
8010272b:	83 c4 10             	add    $0x10,%esp
8010272e:	84 c0                	test   %al,%al
80102730:	74 0c                	je     8010273e <ideinit+0x89>
      havedisk1 = 1;
80102732:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102739:	00 00 00 
      break;
8010273c:	eb 0d                	jmp    8010274b <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010273e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102742:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102749:	7e d3                	jle    8010271e <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010274b:	83 ec 08             	sub    $0x8,%esp
8010274e:	68 e0 00 00 00       	push   $0xe0
80102753:	68 f6 01 00 00       	push   $0x1f6
80102758:	e8 d0 fe ff ff       	call   8010262d <outb>
8010275d:	83 c4 10             	add    $0x10,%esp
}
80102760:	c9                   	leave  
80102761:	c3                   	ret    

80102762 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102762:	55                   	push   %ebp
80102763:	89 e5                	mov    %esp,%ebp
80102765:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102768:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010276c:	75 0d                	jne    8010277b <idestart+0x19>
    panic("idestart");
8010276e:	83 ec 0c             	sub    $0xc,%esp
80102771:	68 2c 87 10 80       	push   $0x8010872c
80102776:	e8 e1 dd ff ff       	call   8010055c <panic>

  idewait(0);
8010277b:	83 ec 0c             	sub    $0xc,%esp
8010277e:	6a 00                	push   $0x0
80102780:	e8 eb fe ff ff       	call   80102670 <idewait>
80102785:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102788:	83 ec 08             	sub    $0x8,%esp
8010278b:	6a 00                	push   $0x0
8010278d:	68 f6 03 00 00       	push   $0x3f6
80102792:	e8 96 fe ff ff       	call   8010262d <outb>
80102797:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
8010279a:	83 ec 08             	sub    $0x8,%esp
8010279d:	6a 01                	push   $0x1
8010279f:	68 f2 01 00 00       	push   $0x1f2
801027a4:	e8 84 fe ff ff       	call   8010262d <outb>
801027a9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801027ac:	8b 45 08             	mov    0x8(%ebp),%eax
801027af:	8b 40 08             	mov    0x8(%eax),%eax
801027b2:	0f b6 c0             	movzbl %al,%eax
801027b5:	83 ec 08             	sub    $0x8,%esp
801027b8:	50                   	push   %eax
801027b9:	68 f3 01 00 00       	push   $0x1f3
801027be:	e8 6a fe ff ff       	call   8010262d <outb>
801027c3:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801027c6:	8b 45 08             	mov    0x8(%ebp),%eax
801027c9:	8b 40 08             	mov    0x8(%eax),%eax
801027cc:	c1 e8 08             	shr    $0x8,%eax
801027cf:	0f b6 c0             	movzbl %al,%eax
801027d2:	83 ec 08             	sub    $0x8,%esp
801027d5:	50                   	push   %eax
801027d6:	68 f4 01 00 00       	push   $0x1f4
801027db:	e8 4d fe ff ff       	call   8010262d <outb>
801027e0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801027e3:	8b 45 08             	mov    0x8(%ebp),%eax
801027e6:	8b 40 08             	mov    0x8(%eax),%eax
801027e9:	c1 e8 10             	shr    $0x10,%eax
801027ec:	0f b6 c0             	movzbl %al,%eax
801027ef:	83 ec 08             	sub    $0x8,%esp
801027f2:	50                   	push   %eax
801027f3:	68 f5 01 00 00       	push   $0x1f5
801027f8:	e8 30 fe ff ff       	call   8010262d <outb>
801027fd:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102800:	8b 45 08             	mov    0x8(%ebp),%eax
80102803:	8b 40 04             	mov    0x4(%eax),%eax
80102806:	83 e0 01             	and    $0x1,%eax
80102809:	c1 e0 04             	shl    $0x4,%eax
8010280c:	89 c2                	mov    %eax,%edx
8010280e:	8b 45 08             	mov    0x8(%ebp),%eax
80102811:	8b 40 08             	mov    0x8(%eax),%eax
80102814:	c1 e8 18             	shr    $0x18,%eax
80102817:	83 e0 0f             	and    $0xf,%eax
8010281a:	09 d0                	or     %edx,%eax
8010281c:	83 c8 e0             	or     $0xffffffe0,%eax
8010281f:	0f b6 c0             	movzbl %al,%eax
80102822:	83 ec 08             	sub    $0x8,%esp
80102825:	50                   	push   %eax
80102826:	68 f6 01 00 00       	push   $0x1f6
8010282b:	e8 fd fd ff ff       	call   8010262d <outb>
80102830:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102833:	8b 45 08             	mov    0x8(%ebp),%eax
80102836:	8b 00                	mov    (%eax),%eax
80102838:	83 e0 04             	and    $0x4,%eax
8010283b:	85 c0                	test   %eax,%eax
8010283d:	74 30                	je     8010286f <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010283f:	83 ec 08             	sub    $0x8,%esp
80102842:	6a 30                	push   $0x30
80102844:	68 f7 01 00 00       	push   $0x1f7
80102849:	e8 df fd ff ff       	call   8010262d <outb>
8010284e:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102851:	8b 45 08             	mov    0x8(%ebp),%eax
80102854:	83 c0 18             	add    $0x18,%eax
80102857:	83 ec 04             	sub    $0x4,%esp
8010285a:	68 80 00 00 00       	push   $0x80
8010285f:	50                   	push   %eax
80102860:	68 f0 01 00 00       	push   $0x1f0
80102865:	e8 e1 fd ff ff       	call   8010264b <outsl>
8010286a:	83 c4 10             	add    $0x10,%esp
8010286d:	eb 12                	jmp    80102881 <idestart+0x11f>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010286f:	83 ec 08             	sub    $0x8,%esp
80102872:	6a 20                	push   $0x20
80102874:	68 f7 01 00 00       	push   $0x1f7
80102879:	e8 af fd ff ff       	call   8010262d <outb>
8010287e:	83 c4 10             	add    $0x10,%esp
  }
}
80102881:	c9                   	leave  
80102882:	c3                   	ret    

80102883 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102883:	55                   	push   %ebp
80102884:	89 e5                	mov    %esp,%ebp
80102886:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102889:	83 ec 0c             	sub    $0xc,%esp
8010288c:	68 20 b6 10 80       	push   $0x8010b620
80102891:	e8 d1 27 00 00       	call   80105067 <acquire>
80102896:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102899:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010289e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028a5:	75 15                	jne    801028bc <ideintr+0x39>
    release(&idelock);
801028a7:	83 ec 0c             	sub    $0xc,%esp
801028aa:	68 20 b6 10 80       	push   $0x8010b620
801028af:	e8 19 28 00 00       	call   801050cd <release>
801028b4:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801028b7:	e9 9a 00 00 00       	jmp    80102956 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bf:	8b 40 14             	mov    0x14(%eax),%eax
801028c2:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 e0 04             	and    $0x4,%eax
801028cf:	85 c0                	test   %eax,%eax
801028d1:	75 2d                	jne    80102900 <ideintr+0x7d>
801028d3:	83 ec 0c             	sub    $0xc,%esp
801028d6:	6a 01                	push   $0x1
801028d8:	e8 93 fd ff ff       	call   80102670 <idewait>
801028dd:	83 c4 10             	add    $0x10,%esp
801028e0:	85 c0                	test   %eax,%eax
801028e2:	78 1c                	js     80102900 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801028e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e7:	83 c0 18             	add    $0x18,%eax
801028ea:	83 ec 04             	sub    $0x4,%esp
801028ed:	68 80 00 00 00       	push   $0x80
801028f2:	50                   	push   %eax
801028f3:	68 f0 01 00 00       	push   $0x1f0
801028f8:	e8 0b fd ff ff       	call   80102608 <insl>
801028fd:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102903:	8b 00                	mov    (%eax),%eax
80102905:	83 c8 02             	or     $0x2,%eax
80102908:	89 c2                	mov    %eax,%edx
8010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010290f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102912:	8b 00                	mov    (%eax),%eax
80102914:	83 e0 fb             	and    $0xfffffffb,%eax
80102917:	89 c2                	mov    %eax,%edx
80102919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010291e:	83 ec 0c             	sub    $0xc,%esp
80102921:	ff 75 f4             	pushl  -0xc(%ebp)
80102924:	e8 e7 24 00 00       	call   80104e10 <wakeup>
80102929:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010292c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 11                	je     80102946 <ideintr+0xc3>
    idestart(idequeue);
80102935:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010293a:	83 ec 0c             	sub    $0xc,%esp
8010293d:	50                   	push   %eax
8010293e:	e8 1f fe ff ff       	call   80102762 <idestart>
80102943:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102946:	83 ec 0c             	sub    $0xc,%esp
80102949:	68 20 b6 10 80       	push   $0x8010b620
8010294e:	e8 7a 27 00 00       	call   801050cd <release>
80102953:	83 c4 10             	add    $0x10,%esp
}
80102956:	c9                   	leave  
80102957:	c3                   	ret    

80102958 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102958:	55                   	push   %ebp
80102959:	89 e5                	mov    %esp,%ebp
8010295b:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010295e:	8b 45 08             	mov    0x8(%ebp),%eax
80102961:	8b 00                	mov    (%eax),%eax
80102963:	83 e0 01             	and    $0x1,%eax
80102966:	85 c0                	test   %eax,%eax
80102968:	75 0d                	jne    80102977 <iderw+0x1f>
    panic("iderw: buf not busy");
8010296a:	83 ec 0c             	sub    $0xc,%esp
8010296d:	68 35 87 10 80       	push   $0x80108735
80102972:	e8 e5 db ff ff       	call   8010055c <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102977:	8b 45 08             	mov    0x8(%ebp),%eax
8010297a:	8b 00                	mov    (%eax),%eax
8010297c:	83 e0 06             	and    $0x6,%eax
8010297f:	83 f8 02             	cmp    $0x2,%eax
80102982:	75 0d                	jne    80102991 <iderw+0x39>
    panic("iderw: nothing to do");
80102984:	83 ec 0c             	sub    $0xc,%esp
80102987:	68 49 87 10 80       	push   $0x80108749
8010298c:	e8 cb db ff ff       	call   8010055c <panic>
  if(b->dev != 0 && !havedisk1)
80102991:	8b 45 08             	mov    0x8(%ebp),%eax
80102994:	8b 40 04             	mov    0x4(%eax),%eax
80102997:	85 c0                	test   %eax,%eax
80102999:	74 16                	je     801029b1 <iderw+0x59>
8010299b:	a1 58 b6 10 80       	mov    0x8010b658,%eax
801029a0:	85 c0                	test   %eax,%eax
801029a2:	75 0d                	jne    801029b1 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029a4:	83 ec 0c             	sub    $0xc,%esp
801029a7:	68 5e 87 10 80       	push   $0x8010875e
801029ac:	e8 ab db ff ff       	call   8010055c <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029b1:	83 ec 0c             	sub    $0xc,%esp
801029b4:	68 20 b6 10 80       	push   $0x8010b620
801029b9:	e8 a9 26 00 00       	call   80105067 <acquire>
801029be:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029cb:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801029d2:	eb 0b                	jmp    801029df <iderw+0x87>
801029d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d7:	8b 00                	mov    (%eax),%eax
801029d9:	83 c0 14             	add    $0x14,%eax
801029dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e2:	8b 00                	mov    (%eax),%eax
801029e4:	85 c0                	test   %eax,%eax
801029e6:	75 ec                	jne    801029d4 <iderw+0x7c>
    ;
  *pp = b;
801029e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029eb:	8b 55 08             	mov    0x8(%ebp),%edx
801029ee:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029f0:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801029f5:	3b 45 08             	cmp    0x8(%ebp),%eax
801029f8:	75 0e                	jne    80102a08 <iderw+0xb0>
    idestart(b);
801029fa:	83 ec 0c             	sub    $0xc,%esp
801029fd:	ff 75 08             	pushl  0x8(%ebp)
80102a00:	e8 5d fd ff ff       	call   80102762 <idestart>
80102a05:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a08:	eb 13                	jmp    80102a1d <iderw+0xc5>
    sleep(b, &idelock);
80102a0a:	83 ec 08             	sub    $0x8,%esp
80102a0d:	68 20 b6 10 80       	push   $0x8010b620
80102a12:	ff 75 08             	pushl  0x8(%ebp)
80102a15:	e8 0d 23 00 00       	call   80104d27 <sleep>
80102a1a:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a20:	8b 00                	mov    (%eax),%eax
80102a22:	83 e0 06             	and    $0x6,%eax
80102a25:	83 f8 02             	cmp    $0x2,%eax
80102a28:	75 e0                	jne    80102a0a <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a2a:	83 ec 0c             	sub    $0xc,%esp
80102a2d:	68 20 b6 10 80       	push   $0x8010b620
80102a32:	e8 96 26 00 00       	call   801050cd <release>
80102a37:	83 c4 10             	add    $0x10,%esp
}
80102a3a:	c9                   	leave  
80102a3b:	c3                   	ret    

80102a3c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a3c:	55                   	push   %ebp
80102a3d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3f:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102a44:	8b 55 08             	mov    0x8(%ebp),%edx
80102a47:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a49:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102a4e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a51:	5d                   	pop    %ebp
80102a52:	c3                   	ret    

80102a53 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a53:	55                   	push   %ebp
80102a54:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a56:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102a5b:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a60:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102a65:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a68:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a6b:	5d                   	pop    %ebp
80102a6c:	c3                   	ret    

80102a6d <ioapicinit>:

void
ioapicinit(void)
{
80102a6d:	55                   	push   %ebp
80102a6e:	89 e5                	mov    %esp,%ebp
80102a70:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a73:	a1 44 24 11 80       	mov    0x80112444,%eax
80102a78:	85 c0                	test   %eax,%eax
80102a7a:	75 05                	jne    80102a81 <ioapicinit+0x14>
    return;
80102a7c:	e9 9e 00 00 00       	jmp    80102b1f <ioapicinit+0xb2>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a81:	c7 05 d4 22 11 80 00 	movl   $0xfec00000,0x801122d4
80102a88:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a8b:	6a 01                	push   $0x1
80102a8d:	e8 aa ff ff ff       	call   80102a3c <ioapicread>
80102a92:	83 c4 04             	add    $0x4,%esp
80102a95:	c1 e8 10             	shr    $0x10,%eax
80102a98:	25 ff 00 00 00       	and    $0xff,%eax
80102a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102aa0:	6a 00                	push   $0x0
80102aa2:	e8 95 ff ff ff       	call   80102a3c <ioapicread>
80102aa7:	83 c4 04             	add    $0x4,%esp
80102aaa:	c1 e8 18             	shr    $0x18,%eax
80102aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102ab0:	0f b6 05 40 24 11 80 	movzbl 0x80112440,%eax
80102ab7:	0f b6 c0             	movzbl %al,%eax
80102aba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102abd:	74 10                	je     80102acf <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102abf:	83 ec 0c             	sub    $0xc,%esp
80102ac2:	68 7c 87 10 80       	push   $0x8010877c
80102ac7:	e8 f3 d8 ff ff       	call   801003bf <cprintf>
80102acc:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ad6:	eb 3f                	jmp    80102b17 <ioapicinit+0xaa>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adb:	83 c0 20             	add    $0x20,%eax
80102ade:	0d 00 00 01 00       	or     $0x10000,%eax
80102ae3:	89 c2                	mov    %eax,%edx
80102ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae8:	83 c0 08             	add    $0x8,%eax
80102aeb:	01 c0                	add    %eax,%eax
80102aed:	83 ec 08             	sub    $0x8,%esp
80102af0:	52                   	push   %edx
80102af1:	50                   	push   %eax
80102af2:	e8 5c ff ff ff       	call   80102a53 <ioapicwrite>
80102af7:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afd:	83 c0 08             	add    $0x8,%eax
80102b00:	01 c0                	add    %eax,%eax
80102b02:	83 c0 01             	add    $0x1,%eax
80102b05:	83 ec 08             	sub    $0x8,%esp
80102b08:	6a 00                	push   $0x0
80102b0a:	50                   	push   %eax
80102b0b:	e8 43 ff ff ff       	call   80102a53 <ioapicwrite>
80102b10:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b1d:	7e b9                	jle    80102ad8 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b1f:	c9                   	leave  
80102b20:	c3                   	ret    

80102b21 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b21:	55                   	push   %ebp
80102b22:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b24:	a1 44 24 11 80       	mov    0x80112444,%eax
80102b29:	85 c0                	test   %eax,%eax
80102b2b:	75 02                	jne    80102b2f <ioapicenable+0xe>
    return;
80102b2d:	eb 37                	jmp    80102b66 <ioapicenable+0x45>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b32:	83 c0 20             	add    $0x20,%eax
80102b35:	89 c2                	mov    %eax,%edx
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	83 c0 08             	add    $0x8,%eax
80102b3d:	01 c0                	add    %eax,%eax
80102b3f:	52                   	push   %edx
80102b40:	50                   	push   %eax
80102b41:	e8 0d ff ff ff       	call   80102a53 <ioapicwrite>
80102b46:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b49:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b4c:	c1 e0 18             	shl    $0x18,%eax
80102b4f:	89 c2                	mov    %eax,%edx
80102b51:	8b 45 08             	mov    0x8(%ebp),%eax
80102b54:	83 c0 08             	add    $0x8,%eax
80102b57:	01 c0                	add    %eax,%eax
80102b59:	83 c0 01             	add    $0x1,%eax
80102b5c:	52                   	push   %edx
80102b5d:	50                   	push   %eax
80102b5e:	e8 f0 fe ff ff       	call   80102a53 <ioapicwrite>
80102b63:	83 c4 08             	add    $0x8,%esp
}
80102b66:	c9                   	leave  
80102b67:	c3                   	ret    

80102b68 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b68:	55                   	push   %ebp
80102b69:	89 e5                	mov    %esp,%ebp
80102b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6e:	05 00 00 00 80       	add    $0x80000000,%eax
80102b73:	5d                   	pop    %ebp
80102b74:	c3                   	ret    

80102b75 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b75:	55                   	push   %ebp
80102b76:	89 e5                	mov    %esp,%ebp
80102b78:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b7b:	83 ec 08             	sub    $0x8,%esp
80102b7e:	68 ae 87 10 80       	push   $0x801087ae
80102b83:	68 e0 22 11 80       	push   $0x801122e0
80102b88:	e8 b9 24 00 00       	call   80105046 <initlock>
80102b8d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b90:	c7 05 14 23 11 80 00 	movl   $0x0,0x80112314
80102b97:	00 00 00 
  freerange(vstart, vend);
80102b9a:	83 ec 08             	sub    $0x8,%esp
80102b9d:	ff 75 0c             	pushl  0xc(%ebp)
80102ba0:	ff 75 08             	pushl  0x8(%ebp)
80102ba3:	e8 28 00 00 00       	call   80102bd0 <freerange>
80102ba8:	83 c4 10             	add    $0x10,%esp
}
80102bab:	c9                   	leave  
80102bac:	c3                   	ret    

80102bad <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bad:	55                   	push   %ebp
80102bae:	89 e5                	mov    %esp,%ebp
80102bb0:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102bb3:	83 ec 08             	sub    $0x8,%esp
80102bb6:	ff 75 0c             	pushl  0xc(%ebp)
80102bb9:	ff 75 08             	pushl  0x8(%ebp)
80102bbc:	e8 0f 00 00 00       	call   80102bd0 <freerange>
80102bc1:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bc4:	c7 05 14 23 11 80 01 	movl   $0x1,0x80112314
80102bcb:	00 00 00 
}
80102bce:	c9                   	leave  
80102bcf:	c3                   	ret    

80102bd0 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bd0:	55                   	push   %ebp
80102bd1:	89 e5                	mov    %esp,%ebp
80102bd3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd9:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102be3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102be6:	eb 15                	jmp    80102bfd <freerange+0x2d>
    kfree(p);
80102be8:	83 ec 0c             	sub    $0xc,%esp
80102beb:	ff 75 f4             	pushl  -0xc(%ebp)
80102bee:	e8 19 00 00 00       	call   80102c0c <kfree>
80102bf3:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bf6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c00:	05 00 10 00 00       	add    $0x1000,%eax
80102c05:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c08:	76 de                	jbe    80102be8 <freerange+0x18>
    kfree(p);
}
80102c0a:	c9                   	leave  
80102c0b:	c3                   	ret    

80102c0c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c0c:	55                   	push   %ebp
80102c0d:	89 e5                	mov    %esp,%ebp
80102c0f:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c12:	8b 45 08             	mov    0x8(%ebp),%eax
80102c15:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c1a:	85 c0                	test   %eax,%eax
80102c1c:	75 1b                	jne    80102c39 <kfree+0x2d>
80102c1e:	81 7d 08 5c 52 11 80 	cmpl   $0x8011525c,0x8(%ebp)
80102c25:	72 12                	jb     80102c39 <kfree+0x2d>
80102c27:	ff 75 08             	pushl  0x8(%ebp)
80102c2a:	e8 39 ff ff ff       	call   80102b68 <v2p>
80102c2f:	83 c4 04             	add    $0x4,%esp
80102c32:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c37:	76 0d                	jbe    80102c46 <kfree+0x3a>
    panic("kfree");
80102c39:	83 ec 0c             	sub    $0xc,%esp
80102c3c:	68 b3 87 10 80       	push   $0x801087b3
80102c41:	e8 16 d9 ff ff       	call   8010055c <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c46:	83 ec 04             	sub    $0x4,%esp
80102c49:	68 00 10 00 00       	push   $0x1000
80102c4e:	6a 01                	push   $0x1
80102c50:	ff 75 08             	pushl  0x8(%ebp)
80102c53:	e8 6b 26 00 00       	call   801052c3 <memset>
80102c58:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c5b:	a1 14 23 11 80       	mov    0x80112314,%eax
80102c60:	85 c0                	test   %eax,%eax
80102c62:	74 10                	je     80102c74 <kfree+0x68>
    acquire(&kmem.lock);
80102c64:	83 ec 0c             	sub    $0xc,%esp
80102c67:	68 e0 22 11 80       	push   $0x801122e0
80102c6c:	e8 f6 23 00 00       	call   80105067 <acquire>
80102c71:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c74:	8b 45 08             	mov    0x8(%ebp),%eax
80102c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c7a:	8b 15 18 23 11 80    	mov    0x80112318,%edx
80102c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c83:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c88:	a3 18 23 11 80       	mov    %eax,0x80112318
  if(kmem.use_lock)
80102c8d:	a1 14 23 11 80       	mov    0x80112314,%eax
80102c92:	85 c0                	test   %eax,%eax
80102c94:	74 10                	je     80102ca6 <kfree+0x9a>
    release(&kmem.lock);
80102c96:	83 ec 0c             	sub    $0xc,%esp
80102c99:	68 e0 22 11 80       	push   $0x801122e0
80102c9e:	e8 2a 24 00 00       	call   801050cd <release>
80102ca3:	83 c4 10             	add    $0x10,%esp
}
80102ca6:	c9                   	leave  
80102ca7:	c3                   	ret    

80102ca8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ca8:	55                   	push   %ebp
80102ca9:	89 e5                	mov    %esp,%ebp
80102cab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102cae:	a1 14 23 11 80       	mov    0x80112314,%eax
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	74 10                	je     80102cc7 <kalloc+0x1f>
    acquire(&kmem.lock);
80102cb7:	83 ec 0c             	sub    $0xc,%esp
80102cba:	68 e0 22 11 80       	push   $0x801122e0
80102cbf:	e8 a3 23 00 00       	call   80105067 <acquire>
80102cc4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cc7:	a1 18 23 11 80       	mov    0x80112318,%eax
80102ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ccf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cd3:	74 0a                	je     80102cdf <kalloc+0x37>
    kmem.freelist = r->next;
80102cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd8:	8b 00                	mov    (%eax),%eax
80102cda:	a3 18 23 11 80       	mov    %eax,0x80112318
  if(kmem.use_lock)
80102cdf:	a1 14 23 11 80       	mov    0x80112314,%eax
80102ce4:	85 c0                	test   %eax,%eax
80102ce6:	74 10                	je     80102cf8 <kalloc+0x50>
    release(&kmem.lock);
80102ce8:	83 ec 0c             	sub    $0xc,%esp
80102ceb:	68 e0 22 11 80       	push   $0x801122e0
80102cf0:	e8 d8 23 00 00       	call   801050cd <release>
80102cf5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cfb:	c9                   	leave  
80102cfc:	c3                   	ret    

80102cfd <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cfd:	55                   	push   %ebp
80102cfe:	89 e5                	mov    %esp,%ebp
80102d00:	83 ec 14             	sub    $0x14,%esp
80102d03:	8b 45 08             	mov    0x8(%ebp),%eax
80102d06:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d0a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d0e:	89 c2                	mov    %eax,%edx
80102d10:	ec                   	in     (%dx),%al
80102d11:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d14:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d18:	c9                   	leave  
80102d19:	c3                   	ret    

80102d1a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d1a:	55                   	push   %ebp
80102d1b:	89 e5                	mov    %esp,%ebp
80102d1d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d20:	6a 64                	push   $0x64
80102d22:	e8 d6 ff ff ff       	call   80102cfd <inb>
80102d27:	83 c4 04             	add    $0x4,%esp
80102d2a:	0f b6 c0             	movzbl %al,%eax
80102d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d33:	83 e0 01             	and    $0x1,%eax
80102d36:	85 c0                	test   %eax,%eax
80102d38:	75 0a                	jne    80102d44 <kbdgetc+0x2a>
    return -1;
80102d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d3f:	e9 23 01 00 00       	jmp    80102e67 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d44:	6a 60                	push   $0x60
80102d46:	e8 b2 ff ff ff       	call   80102cfd <inb>
80102d4b:	83 c4 04             	add    $0x4,%esp
80102d4e:	0f b6 c0             	movzbl %al,%eax
80102d51:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d54:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d5b:	75 17                	jne    80102d74 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d5d:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d62:	83 c8 40             	or     $0x40,%eax
80102d65:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102d6a:	b8 00 00 00 00       	mov    $0x0,%eax
80102d6f:	e9 f3 00 00 00       	jmp    80102e67 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d77:	25 80 00 00 00       	and    $0x80,%eax
80102d7c:	85 c0                	test   %eax,%eax
80102d7e:	74 45                	je     80102dc5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d80:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d85:	83 e0 40             	and    $0x40,%eax
80102d88:	85 c0                	test   %eax,%eax
80102d8a:	75 08                	jne    80102d94 <kbdgetc+0x7a>
80102d8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8f:	83 e0 7f             	and    $0x7f,%eax
80102d92:	eb 03                	jmp    80102d97 <kbdgetc+0x7d>
80102d94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d97:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d9d:	05 40 90 10 80       	add    $0x80109040,%eax
80102da2:	0f b6 00             	movzbl (%eax),%eax
80102da5:	83 c8 40             	or     $0x40,%eax
80102da8:	0f b6 c0             	movzbl %al,%eax
80102dab:	f7 d0                	not    %eax
80102dad:	89 c2                	mov    %eax,%edx
80102daf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102db4:	21 d0                	and    %edx,%eax
80102db6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102dbb:	b8 00 00 00 00       	mov    $0x0,%eax
80102dc0:	e9 a2 00 00 00       	jmp    80102e67 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102dc5:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102dca:	83 e0 40             	and    $0x40,%eax
80102dcd:	85 c0                	test   %eax,%eax
80102dcf:	74 14                	je     80102de5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dd1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dd8:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ddd:	83 e0 bf             	and    $0xffffffbf,%eax
80102de0:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de8:	05 40 90 10 80       	add    $0x80109040,%eax
80102ded:	0f b6 00             	movzbl (%eax),%eax
80102df0:	0f b6 d0             	movzbl %al,%edx
80102df3:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102df8:	09 d0                	or     %edx,%eax
80102dfa:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102dff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e02:	05 40 91 10 80       	add    $0x80109140,%eax
80102e07:	0f b6 00             	movzbl (%eax),%eax
80102e0a:	0f b6 d0             	movzbl %al,%edx
80102e0d:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102e12:	31 d0                	xor    %edx,%eax
80102e14:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e19:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102e1e:	83 e0 03             	and    $0x3,%eax
80102e21:	8b 14 85 40 95 10 80 	mov    -0x7fef6ac0(,%eax,4),%edx
80102e28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e2b:	01 d0                	add    %edx,%eax
80102e2d:	0f b6 00             	movzbl (%eax),%eax
80102e30:	0f b6 c0             	movzbl %al,%eax
80102e33:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e36:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102e3b:	83 e0 08             	and    $0x8,%eax
80102e3e:	85 c0                	test   %eax,%eax
80102e40:	74 22                	je     80102e64 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e42:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e46:	76 0c                	jbe    80102e54 <kbdgetc+0x13a>
80102e48:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e4c:	77 06                	ja     80102e54 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e4e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e52:	eb 10                	jmp    80102e64 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e54:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e58:	76 0a                	jbe    80102e64 <kbdgetc+0x14a>
80102e5a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e5e:	77 04                	ja     80102e64 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e60:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e64:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e67:	c9                   	leave  
80102e68:	c3                   	ret    

80102e69 <kbdintr>:

void
kbdintr(void)
{
80102e69:	55                   	push   %ebp
80102e6a:	89 e5                	mov    %esp,%ebp
80102e6c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e6f:	83 ec 0c             	sub    $0xc,%esp
80102e72:	68 1a 2d 10 80       	push   $0x80102d1a
80102e77:	e8 55 d9 ff ff       	call   801007d1 <consoleintr>
80102e7c:	83 c4 10             	add    $0x10,%esp
}
80102e7f:	c9                   	leave  
80102e80:	c3                   	ret    

80102e81 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e81:	55                   	push   %ebp
80102e82:	89 e5                	mov    %esp,%ebp
80102e84:	83 ec 14             	sub    $0x14,%esp
80102e87:	8b 45 08             	mov    0x8(%ebp),%eax
80102e8a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e8e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e92:	89 c2                	mov    %eax,%edx
80102e94:	ec                   	in     (%dx),%al
80102e95:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e98:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e9c:	c9                   	leave  
80102e9d:	c3                   	ret    

80102e9e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e9e:	55                   	push   %ebp
80102e9f:	89 e5                	mov    %esp,%ebp
80102ea1:	83 ec 08             	sub    $0x8,%esp
80102ea4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eaa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102eae:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102eb1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102eb5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102eb9:	ee                   	out    %al,(%dx)
}
80102eba:	c9                   	leave  
80102ebb:	c3                   	ret    

80102ebc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102ebc:	55                   	push   %ebp
80102ebd:	89 e5                	mov    %esp,%ebp
80102ebf:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102ec2:	9c                   	pushf  
80102ec3:	58                   	pop    %eax
80102ec4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102eca:	c9                   	leave  
80102ecb:	c3                   	ret    

80102ecc <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ecc:	55                   	push   %ebp
80102ecd:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ecf:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80102ed4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ed7:	c1 e2 02             	shl    $0x2,%edx
80102eda:	01 c2                	add    %eax,%edx
80102edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102edf:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ee1:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80102ee6:	83 c0 20             	add    $0x20,%eax
80102ee9:	8b 00                	mov    (%eax),%eax
}
80102eeb:	5d                   	pop    %ebp
80102eec:	c3                   	ret    

80102eed <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eed:	55                   	push   %ebp
80102eee:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ef0:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80102ef5:	85 c0                	test   %eax,%eax
80102ef7:	75 05                	jne    80102efe <lapicinit+0x11>
    return;
80102ef9:	e9 09 01 00 00       	jmp    80103007 <lapicinit+0x11a>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102efe:	68 3f 01 00 00       	push   $0x13f
80102f03:	6a 3c                	push   $0x3c
80102f05:	e8 c2 ff ff ff       	call   80102ecc <lapicw>
80102f0a:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f0d:	6a 0b                	push   $0xb
80102f0f:	68 f8 00 00 00       	push   $0xf8
80102f14:	e8 b3 ff ff ff       	call   80102ecc <lapicw>
80102f19:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f1c:	68 20 00 02 00       	push   $0x20020
80102f21:	68 c8 00 00 00       	push   $0xc8
80102f26:	e8 a1 ff ff ff       	call   80102ecc <lapicw>
80102f2b:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f2e:	68 80 96 98 00       	push   $0x989680
80102f33:	68 e0 00 00 00       	push   $0xe0
80102f38:	e8 8f ff ff ff       	call   80102ecc <lapicw>
80102f3d:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f40:	68 00 00 01 00       	push   $0x10000
80102f45:	68 d4 00 00 00       	push   $0xd4
80102f4a:	e8 7d ff ff ff       	call   80102ecc <lapicw>
80102f4f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f52:	68 00 00 01 00       	push   $0x10000
80102f57:	68 d8 00 00 00       	push   $0xd8
80102f5c:	e8 6b ff ff ff       	call   80102ecc <lapicw>
80102f61:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f64:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80102f69:	83 c0 30             	add    $0x30,%eax
80102f6c:	8b 00                	mov    (%eax),%eax
80102f6e:	c1 e8 10             	shr    $0x10,%eax
80102f71:	0f b6 c0             	movzbl %al,%eax
80102f74:	83 f8 03             	cmp    $0x3,%eax
80102f77:	76 12                	jbe    80102f8b <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f79:	68 00 00 01 00       	push   $0x10000
80102f7e:	68 d0 00 00 00       	push   $0xd0
80102f83:	e8 44 ff ff ff       	call   80102ecc <lapicw>
80102f88:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f8b:	6a 33                	push   $0x33
80102f8d:	68 dc 00 00 00       	push   $0xdc
80102f92:	e8 35 ff ff ff       	call   80102ecc <lapicw>
80102f97:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f9a:	6a 00                	push   $0x0
80102f9c:	68 a0 00 00 00       	push   $0xa0
80102fa1:	e8 26 ff ff ff       	call   80102ecc <lapicw>
80102fa6:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102fa9:	6a 00                	push   $0x0
80102fab:	68 a0 00 00 00       	push   $0xa0
80102fb0:	e8 17 ff ff ff       	call   80102ecc <lapicw>
80102fb5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fb8:	6a 00                	push   $0x0
80102fba:	6a 2c                	push   $0x2c
80102fbc:	e8 0b ff ff ff       	call   80102ecc <lapicw>
80102fc1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fc4:	6a 00                	push   $0x0
80102fc6:	68 c4 00 00 00       	push   $0xc4
80102fcb:	e8 fc fe ff ff       	call   80102ecc <lapicw>
80102fd0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fd3:	68 00 85 08 00       	push   $0x88500
80102fd8:	68 c0 00 00 00       	push   $0xc0
80102fdd:	e8 ea fe ff ff       	call   80102ecc <lapicw>
80102fe2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fe5:	90                   	nop
80102fe6:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80102feb:	05 00 03 00 00       	add    $0x300,%eax
80102ff0:	8b 00                	mov    (%eax),%eax
80102ff2:	25 00 10 00 00       	and    $0x1000,%eax
80102ff7:	85 c0                	test   %eax,%eax
80102ff9:	75 eb                	jne    80102fe6 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ffb:	6a 00                	push   $0x0
80102ffd:	6a 20                	push   $0x20
80102fff:	e8 c8 fe ff ff       	call   80102ecc <lapicw>
80103004:	83 c4 08             	add    $0x8,%esp
}
80103007:	c9                   	leave  
80103008:	c3                   	ret    

80103009 <cpunum>:

int
cpunum(void)
{
80103009:	55                   	push   %ebp
8010300a:	89 e5                	mov    %esp,%ebp
8010300c:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010300f:	e8 a8 fe ff ff       	call   80102ebc <readeflags>
80103014:	25 00 02 00 00       	and    $0x200,%eax
80103019:	85 c0                	test   %eax,%eax
8010301b:	74 26                	je     80103043 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010301d:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80103022:	8d 50 01             	lea    0x1(%eax),%edx
80103025:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
8010302b:	85 c0                	test   %eax,%eax
8010302d:	75 14                	jne    80103043 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010302f:	8b 45 04             	mov    0x4(%ebp),%eax
80103032:	83 ec 08             	sub    $0x8,%esp
80103035:	50                   	push   %eax
80103036:	68 bc 87 10 80       	push   $0x801087bc
8010303b:	e8 7f d3 ff ff       	call   801003bf <cprintf>
80103040:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103043:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80103048:	85 c0                	test   %eax,%eax
8010304a:	74 0f                	je     8010305b <cpunum+0x52>
    return lapic[ID]>>24;
8010304c:	a1 1c 23 11 80       	mov    0x8011231c,%eax
80103051:	83 c0 20             	add    $0x20,%eax
80103054:	8b 00                	mov    (%eax),%eax
80103056:	c1 e8 18             	shr    $0x18,%eax
80103059:	eb 05                	jmp    80103060 <cpunum+0x57>
  return 0;
8010305b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103060:	c9                   	leave  
80103061:	c3                   	ret    

80103062 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103062:	55                   	push   %ebp
80103063:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103065:	a1 1c 23 11 80       	mov    0x8011231c,%eax
8010306a:	85 c0                	test   %eax,%eax
8010306c:	74 0c                	je     8010307a <lapiceoi+0x18>
    lapicw(EOI, 0);
8010306e:	6a 00                	push   $0x0
80103070:	6a 2c                	push   $0x2c
80103072:	e8 55 fe ff ff       	call   80102ecc <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
}
8010307a:	c9                   	leave  
8010307b:	c3                   	ret    

8010307c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010307c:	55                   	push   %ebp
8010307d:	89 e5                	mov    %esp,%ebp
}
8010307f:	5d                   	pop    %ebp
80103080:	c3                   	ret    

80103081 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103081:	55                   	push   %ebp
80103082:	89 e5                	mov    %esp,%ebp
80103084:	83 ec 14             	sub    $0x14,%esp
80103087:	8b 45 08             	mov    0x8(%ebp),%eax
8010308a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010308d:	6a 0f                	push   $0xf
8010308f:	6a 70                	push   $0x70
80103091:	e8 08 fe ff ff       	call   80102e9e <outb>
80103096:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103099:	6a 0a                	push   $0xa
8010309b:	6a 71                	push   $0x71
8010309d:	e8 fc fd ff ff       	call   80102e9e <outb>
801030a2:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030a5:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030af:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030b7:	83 c0 02             	add    $0x2,%eax
801030ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801030bd:	c1 ea 04             	shr    $0x4,%edx
801030c0:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030c3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c7:	c1 e0 18             	shl    $0x18,%eax
801030ca:	50                   	push   %eax
801030cb:	68 c4 00 00 00       	push   $0xc4
801030d0:	e8 f7 fd ff ff       	call   80102ecc <lapicw>
801030d5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030d8:	68 00 c5 00 00       	push   $0xc500
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 e5 fd ff ff       	call   80102ecc <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 88 ff ff ff       	call   8010307c <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030f7:	68 00 85 00 00       	push   $0x8500
801030fc:	68 c0 00 00 00       	push   $0xc0
80103101:	e8 c6 fd ff ff       	call   80102ecc <lapicw>
80103106:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103109:	6a 64                	push   $0x64
8010310b:	e8 6c ff ff ff       	call   8010307c <microdelay>
80103110:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103113:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010311a:	eb 3d                	jmp    80103159 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010311c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103120:	c1 e0 18             	shl    $0x18,%eax
80103123:	50                   	push   %eax
80103124:	68 c4 00 00 00       	push   $0xc4
80103129:	e8 9e fd ff ff       	call   80102ecc <lapicw>
8010312e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103131:	8b 45 0c             	mov    0xc(%ebp),%eax
80103134:	c1 e8 0c             	shr    $0xc,%eax
80103137:	80 cc 06             	or     $0x6,%ah
8010313a:	50                   	push   %eax
8010313b:	68 c0 00 00 00       	push   $0xc0
80103140:	e8 87 fd ff ff       	call   80102ecc <lapicw>
80103145:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103148:	68 c8 00 00 00       	push   $0xc8
8010314d:	e8 2a ff ff ff       	call   8010307c <microdelay>
80103152:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103155:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103159:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010315d:	7e bd                	jle    8010311c <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010315f:	c9                   	leave  
80103160:	c3                   	ret    

80103161 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103161:	55                   	push   %ebp
80103162:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103164:	8b 45 08             	mov    0x8(%ebp),%eax
80103167:	0f b6 c0             	movzbl %al,%eax
8010316a:	50                   	push   %eax
8010316b:	6a 70                	push   $0x70
8010316d:	e8 2c fd ff ff       	call   80102e9e <outb>
80103172:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103175:	68 c8 00 00 00       	push   $0xc8
8010317a:	e8 fd fe ff ff       	call   8010307c <microdelay>
8010317f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103182:	6a 71                	push   $0x71
80103184:	e8 f8 fc ff ff       	call   80102e81 <inb>
80103189:	83 c4 04             	add    $0x4,%esp
8010318c:	0f b6 c0             	movzbl %al,%eax
}
8010318f:	c9                   	leave  
80103190:	c3                   	ret    

80103191 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103191:	55                   	push   %ebp
80103192:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103194:	6a 00                	push   $0x0
80103196:	e8 c6 ff ff ff       	call   80103161 <cmos_read>
8010319b:	83 c4 04             	add    $0x4,%esp
8010319e:	89 c2                	mov    %eax,%edx
801031a0:	8b 45 08             	mov    0x8(%ebp),%eax
801031a3:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031a5:	6a 02                	push   $0x2
801031a7:	e8 b5 ff ff ff       	call   80103161 <cmos_read>
801031ac:	83 c4 04             	add    $0x4,%esp
801031af:	89 c2                	mov    %eax,%edx
801031b1:	8b 45 08             	mov    0x8(%ebp),%eax
801031b4:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801031b7:	6a 04                	push   $0x4
801031b9:	e8 a3 ff ff ff       	call   80103161 <cmos_read>
801031be:	83 c4 04             	add    $0x4,%esp
801031c1:	89 c2                	mov    %eax,%edx
801031c3:	8b 45 08             	mov    0x8(%ebp),%eax
801031c6:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801031c9:	6a 07                	push   $0x7
801031cb:	e8 91 ff ff ff       	call   80103161 <cmos_read>
801031d0:	83 c4 04             	add    $0x4,%esp
801031d3:	89 c2                	mov    %eax,%edx
801031d5:	8b 45 08             	mov    0x8(%ebp),%eax
801031d8:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031db:	6a 08                	push   $0x8
801031dd:	e8 7f ff ff ff       	call   80103161 <cmos_read>
801031e2:	83 c4 04             	add    $0x4,%esp
801031e5:	89 c2                	mov    %eax,%edx
801031e7:	8b 45 08             	mov    0x8(%ebp),%eax
801031ea:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031ed:	6a 09                	push   $0x9
801031ef:	e8 6d ff ff ff       	call   80103161 <cmos_read>
801031f4:	83 c4 04             	add    $0x4,%esp
801031f7:	89 c2                	mov    %eax,%edx
801031f9:	8b 45 08             	mov    0x8(%ebp),%eax
801031fc:	89 50 14             	mov    %edx,0x14(%eax)
}
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103201:	55                   	push   %ebp
80103202:	89 e5                	mov    %esp,%ebp
80103204:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103207:	6a 0b                	push   $0xb
80103209:	e8 53 ff ff ff       	call   80103161 <cmos_read>
8010320e:	83 c4 04             	add    $0x4,%esp
80103211:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103217:	83 e0 04             	and    $0x4,%eax
8010321a:	85 c0                	test   %eax,%eax
8010321c:	0f 94 c0             	sete   %al
8010321f:	0f b6 c0             	movzbl %al,%eax
80103222:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103225:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103228:	50                   	push   %eax
80103229:	e8 63 ff ff ff       	call   80103191 <fill_rtcdate>
8010322e:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103231:	6a 0a                	push   $0xa
80103233:	e8 29 ff ff ff       	call   80103161 <cmos_read>
80103238:	83 c4 04             	add    $0x4,%esp
8010323b:	25 80 00 00 00       	and    $0x80,%eax
80103240:	85 c0                	test   %eax,%eax
80103242:	74 02                	je     80103246 <cmostime+0x45>
        continue;
80103244:	eb 32                	jmp    80103278 <cmostime+0x77>
    fill_rtcdate(&t2);
80103246:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103249:	50                   	push   %eax
8010324a:	e8 42 ff ff ff       	call   80103191 <fill_rtcdate>
8010324f:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103252:	83 ec 04             	sub    $0x4,%esp
80103255:	6a 18                	push   $0x18
80103257:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010325a:	50                   	push   %eax
8010325b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010325e:	50                   	push   %eax
8010325f:	e8 c6 20 00 00       	call   8010532a <memcmp>
80103264:	83 c4 10             	add    $0x10,%esp
80103267:	85 c0                	test   %eax,%eax
80103269:	75 0d                	jne    80103278 <cmostime+0x77>
      break;
8010326b:	90                   	nop
  }

  // convert
  if (bcd) {
8010326c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103270:	0f 84 b8 00 00 00    	je     8010332e <cmostime+0x12d>
80103276:	eb 02                	jmp    8010327a <cmostime+0x79>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103278:	eb ab                	jmp    80103225 <cmostime+0x24>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010327a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010327d:	c1 e8 04             	shr    $0x4,%eax
80103280:	89 c2                	mov    %eax,%edx
80103282:	89 d0                	mov    %edx,%eax
80103284:	c1 e0 02             	shl    $0x2,%eax
80103287:	01 d0                	add    %edx,%eax
80103289:	01 c0                	add    %eax,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103290:	83 e0 0f             	and    $0xf,%eax
80103293:	01 d0                	add    %edx,%eax
80103295:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103298:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010329b:	c1 e8 04             	shr    $0x4,%eax
8010329e:	89 c2                	mov    %eax,%edx
801032a0:	89 d0                	mov    %edx,%eax
801032a2:	c1 e0 02             	shl    $0x2,%eax
801032a5:	01 d0                	add    %edx,%eax
801032a7:	01 c0                	add    %eax,%eax
801032a9:	89 c2                	mov    %eax,%edx
801032ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032ae:	83 e0 0f             	and    $0xf,%eax
801032b1:	01 d0                	add    %edx,%eax
801032b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032b9:	c1 e8 04             	shr    $0x4,%eax
801032bc:	89 c2                	mov    %eax,%edx
801032be:	89 d0                	mov    %edx,%eax
801032c0:	c1 e0 02             	shl    $0x2,%eax
801032c3:	01 d0                	add    %edx,%eax
801032c5:	01 c0                	add    %eax,%eax
801032c7:	89 c2                	mov    %eax,%edx
801032c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032cc:	83 e0 0f             	and    $0xf,%eax
801032cf:	01 d0                	add    %edx,%eax
801032d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d7:	c1 e8 04             	shr    $0x4,%eax
801032da:	89 c2                	mov    %eax,%edx
801032dc:	89 d0                	mov    %edx,%eax
801032de:	c1 e0 02             	shl    $0x2,%eax
801032e1:	01 d0                	add    %edx,%eax
801032e3:	01 c0                	add    %eax,%eax
801032e5:	89 c2                	mov    %eax,%edx
801032e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032ea:	83 e0 0f             	and    $0xf,%eax
801032ed:	01 d0                	add    %edx,%eax
801032ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032f5:	c1 e8 04             	shr    $0x4,%eax
801032f8:	89 c2                	mov    %eax,%edx
801032fa:	89 d0                	mov    %edx,%eax
801032fc:	c1 e0 02             	shl    $0x2,%eax
801032ff:	01 d0                	add    %edx,%eax
80103301:	01 c0                	add    %eax,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103308:	83 e0 0f             	and    $0xf,%eax
8010330b:	01 d0                	add    %edx,%eax
8010330d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103310:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103313:	c1 e8 04             	shr    $0x4,%eax
80103316:	89 c2                	mov    %eax,%edx
80103318:	89 d0                	mov    %edx,%eax
8010331a:	c1 e0 02             	shl    $0x2,%eax
8010331d:	01 d0                	add    %edx,%eax
8010331f:	01 c0                	add    %eax,%eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103326:	83 e0 0f             	and    $0xf,%eax
80103329:	01 d0                	add    %edx,%eax
8010332b:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010332e:	8b 45 08             	mov    0x8(%ebp),%eax
80103331:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103334:	89 10                	mov    %edx,(%eax)
80103336:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103339:	89 50 04             	mov    %edx,0x4(%eax)
8010333c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010333f:	89 50 08             	mov    %edx,0x8(%eax)
80103342:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103345:	89 50 0c             	mov    %edx,0xc(%eax)
80103348:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010334b:	89 50 10             	mov    %edx,0x10(%eax)
8010334e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103351:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103354:	8b 45 08             	mov    0x8(%ebp),%eax
80103357:	8b 40 14             	mov    0x14(%eax),%eax
8010335a:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103360:	8b 45 08             	mov    0x8(%ebp),%eax
80103363:	89 50 14             	mov    %edx,0x14(%eax)
}
80103366:	c9                   	leave  
80103367:	c3                   	ret    

80103368 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103368:	55                   	push   %ebp
80103369:	89 e5                	mov    %esp,%ebp
8010336b:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010336e:	83 ec 08             	sub    $0x8,%esp
80103371:	68 e8 87 10 80       	push   $0x801087e8
80103376:	68 40 23 11 80       	push   $0x80112340
8010337b:	e8 c6 1c 00 00       	call   80105046 <initlock>
80103380:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
80103383:	83 ec 08             	sub    $0x8,%esp
80103386:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103389:	50                   	push   %eax
8010338a:	6a 01                	push   $0x1
8010338c:	e8 ae df ff ff       	call   8010133f <readsb>
80103391:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
80103394:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339a:	29 c2                	sub    %eax,%edx
8010339c:	89 d0                	mov    %edx,%eax
8010339e:	a3 74 23 11 80       	mov    %eax,0x80112374
  log.size = sb.nlog;
801033a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a6:	a3 78 23 11 80       	mov    %eax,0x80112378
  log.dev = ROOTDEV;
801033ab:	c7 05 84 23 11 80 01 	movl   $0x1,0x80112384
801033b2:	00 00 00 
  recover_from_log();
801033b5:	e8 ae 01 00 00       	call   80103568 <recover_from_log>
}
801033ba:	c9                   	leave  
801033bb:	c3                   	ret    

801033bc <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033bc:	55                   	push   %ebp
801033bd:	89 e5                	mov    %esp,%ebp
801033bf:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033c9:	e9 95 00 00 00       	jmp    80103463 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033ce:	8b 15 74 23 11 80    	mov    0x80112374,%edx
801033d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d7:	01 d0                	add    %edx,%eax
801033d9:	83 c0 01             	add    $0x1,%eax
801033dc:	89 c2                	mov    %eax,%edx
801033de:	a1 84 23 11 80       	mov    0x80112384,%eax
801033e3:	83 ec 08             	sub    $0x8,%esp
801033e6:	52                   	push   %edx
801033e7:	50                   	push   %eax
801033e8:	e8 c7 cd ff ff       	call   801001b4 <bread>
801033ed:	83 c4 10             	add    $0x10,%esp
801033f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f6:	83 c0 10             	add    $0x10,%eax
801033f9:	8b 04 85 4c 23 11 80 	mov    -0x7feedcb4(,%eax,4),%eax
80103400:	89 c2                	mov    %eax,%edx
80103402:	a1 84 23 11 80       	mov    0x80112384,%eax
80103407:	83 ec 08             	sub    $0x8,%esp
8010340a:	52                   	push   %edx
8010340b:	50                   	push   %eax
8010340c:	e8 a3 cd ff ff       	call   801001b4 <bread>
80103411:	83 c4 10             	add    $0x10,%esp
80103414:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010341a:	8d 50 18             	lea    0x18(%eax),%edx
8010341d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103420:	83 c0 18             	add    $0x18,%eax
80103423:	83 ec 04             	sub    $0x4,%esp
80103426:	68 00 02 00 00       	push   $0x200
8010342b:	52                   	push   %edx
8010342c:	50                   	push   %eax
8010342d:	e8 50 1f 00 00       	call   80105382 <memmove>
80103432:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103435:	83 ec 0c             	sub    $0xc,%esp
80103438:	ff 75 ec             	pushl  -0x14(%ebp)
8010343b:	e8 ad cd ff ff       	call   801001ed <bwrite>
80103440:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103443:	83 ec 0c             	sub    $0xc,%esp
80103446:	ff 75 f0             	pushl  -0x10(%ebp)
80103449:	e8 dd cd ff ff       	call   8010022b <brelse>
8010344e:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103451:	83 ec 0c             	sub    $0xc,%esp
80103454:	ff 75 ec             	pushl  -0x14(%ebp)
80103457:	e8 cf cd ff ff       	call   8010022b <brelse>
8010345c:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010345f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103463:	a1 88 23 11 80       	mov    0x80112388,%eax
80103468:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010346b:	0f 8f 5d ff ff ff    	jg     801033ce <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103471:	c9                   	leave  
80103472:	c3                   	ret    

80103473 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103473:	55                   	push   %ebp
80103474:	89 e5                	mov    %esp,%ebp
80103476:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103479:	a1 74 23 11 80       	mov    0x80112374,%eax
8010347e:	89 c2                	mov    %eax,%edx
80103480:	a1 84 23 11 80       	mov    0x80112384,%eax
80103485:	83 ec 08             	sub    $0x8,%esp
80103488:	52                   	push   %edx
80103489:	50                   	push   %eax
8010348a:	e8 25 cd ff ff       	call   801001b4 <bread>
8010348f:	83 c4 10             	add    $0x10,%esp
80103492:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103498:	83 c0 18             	add    $0x18,%eax
8010349b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010349e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a1:	8b 00                	mov    (%eax),%eax
801034a3:	a3 88 23 11 80       	mov    %eax,0x80112388
  for (i = 0; i < log.lh.n; i++) {
801034a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034af:	eb 1b                	jmp    801034cc <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801034b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034b7:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034be:	83 c2 10             	add    $0x10,%edx
801034c1:	89 04 95 4c 23 11 80 	mov    %eax,-0x7feedcb4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034cc:	a1 88 23 11 80       	mov    0x80112388,%eax
801034d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034d4:	7f db                	jg     801034b1 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034d6:	83 ec 0c             	sub    $0xc,%esp
801034d9:	ff 75 f0             	pushl  -0x10(%ebp)
801034dc:	e8 4a cd ff ff       	call   8010022b <brelse>
801034e1:	83 c4 10             	add    $0x10,%esp
}
801034e4:	c9                   	leave  
801034e5:	c3                   	ret    

801034e6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034e6:	55                   	push   %ebp
801034e7:	89 e5                	mov    %esp,%ebp
801034e9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ec:	a1 74 23 11 80       	mov    0x80112374,%eax
801034f1:	89 c2                	mov    %eax,%edx
801034f3:	a1 84 23 11 80       	mov    0x80112384,%eax
801034f8:	83 ec 08             	sub    $0x8,%esp
801034fb:	52                   	push   %edx
801034fc:	50                   	push   %eax
801034fd:	e8 b2 cc ff ff       	call   801001b4 <bread>
80103502:	83 c4 10             	add    $0x10,%esp
80103505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350b:	83 c0 18             	add    $0x18,%eax
8010350e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103511:	8b 15 88 23 11 80    	mov    0x80112388,%edx
80103517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010351c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103523:	eb 1b                	jmp    80103540 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103528:	83 c0 10             	add    $0x10,%eax
8010352b:	8b 0c 85 4c 23 11 80 	mov    -0x7feedcb4(,%eax,4),%ecx
80103532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103538:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010353c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103540:	a1 88 23 11 80       	mov    0x80112388,%eax
80103545:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103548:	7f db                	jg     80103525 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010354a:	83 ec 0c             	sub    $0xc,%esp
8010354d:	ff 75 f0             	pushl  -0x10(%ebp)
80103550:	e8 98 cc ff ff       	call   801001ed <bwrite>
80103555:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103558:	83 ec 0c             	sub    $0xc,%esp
8010355b:	ff 75 f0             	pushl  -0x10(%ebp)
8010355e:	e8 c8 cc ff ff       	call   8010022b <brelse>
80103563:	83 c4 10             	add    $0x10,%esp
}
80103566:	c9                   	leave  
80103567:	c3                   	ret    

80103568 <recover_from_log>:

static void
recover_from_log(void)
{
80103568:	55                   	push   %ebp
80103569:	89 e5                	mov    %esp,%ebp
8010356b:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010356e:	e8 00 ff ff ff       	call   80103473 <read_head>
  install_trans(); // if committed, copy from log to disk
80103573:	e8 44 fe ff ff       	call   801033bc <install_trans>
  log.lh.n = 0;
80103578:	c7 05 88 23 11 80 00 	movl   $0x0,0x80112388
8010357f:	00 00 00 
  write_head(); // clear the log
80103582:	e8 5f ff ff ff       	call   801034e6 <write_head>
}
80103587:	c9                   	leave  
80103588:	c3                   	ret    

80103589 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103589:	55                   	push   %ebp
8010358a:	89 e5                	mov    %esp,%ebp
8010358c:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010358f:	83 ec 0c             	sub    $0xc,%esp
80103592:	68 40 23 11 80       	push   $0x80112340
80103597:	e8 cb 1a 00 00       	call   80105067 <acquire>
8010359c:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010359f:	a1 80 23 11 80       	mov    0x80112380,%eax
801035a4:	85 c0                	test   %eax,%eax
801035a6:	74 17                	je     801035bf <begin_op+0x36>
      sleep(&log, &log.lock);
801035a8:	83 ec 08             	sub    $0x8,%esp
801035ab:	68 40 23 11 80       	push   $0x80112340
801035b0:	68 40 23 11 80       	push   $0x80112340
801035b5:	e8 6d 17 00 00       	call   80104d27 <sleep>
801035ba:	83 c4 10             	add    $0x10,%esp
801035bd:	eb 54                	jmp    80103613 <begin_op+0x8a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035bf:	8b 0d 88 23 11 80    	mov    0x80112388,%ecx
801035c5:	a1 7c 23 11 80       	mov    0x8011237c,%eax
801035ca:	8d 50 01             	lea    0x1(%eax),%edx
801035cd:	89 d0                	mov    %edx,%eax
801035cf:	c1 e0 02             	shl    $0x2,%eax
801035d2:	01 d0                	add    %edx,%eax
801035d4:	01 c0                	add    %eax,%eax
801035d6:	01 c8                	add    %ecx,%eax
801035d8:	83 f8 1e             	cmp    $0x1e,%eax
801035db:	7e 17                	jle    801035f4 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035dd:	83 ec 08             	sub    $0x8,%esp
801035e0:	68 40 23 11 80       	push   $0x80112340
801035e5:	68 40 23 11 80       	push   $0x80112340
801035ea:	e8 38 17 00 00       	call   80104d27 <sleep>
801035ef:	83 c4 10             	add    $0x10,%esp
801035f2:	eb 1f                	jmp    80103613 <begin_op+0x8a>
    } else {
      log.outstanding += 1;
801035f4:	a1 7c 23 11 80       	mov    0x8011237c,%eax
801035f9:	83 c0 01             	add    $0x1,%eax
801035fc:	a3 7c 23 11 80       	mov    %eax,0x8011237c
      release(&log.lock);
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 40 23 11 80       	push   $0x80112340
80103609:	e8 bf 1a 00 00       	call   801050cd <release>
8010360e:	83 c4 10             	add    $0x10,%esp
      break;
80103611:	eb 02                	jmp    80103615 <begin_op+0x8c>
    }
  }
80103613:	eb 8a                	jmp    8010359f <begin_op+0x16>
}
80103615:	c9                   	leave  
80103616:	c3                   	ret    

80103617 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103617:	55                   	push   %ebp
80103618:	89 e5                	mov    %esp,%ebp
8010361a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010361d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	68 40 23 11 80       	push   $0x80112340
8010362c:	e8 36 1a 00 00       	call   80105067 <acquire>
80103631:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103634:	a1 7c 23 11 80       	mov    0x8011237c,%eax
80103639:	83 e8 01             	sub    $0x1,%eax
8010363c:	a3 7c 23 11 80       	mov    %eax,0x8011237c
  if(log.committing)
80103641:	a1 80 23 11 80       	mov    0x80112380,%eax
80103646:	85 c0                	test   %eax,%eax
80103648:	74 0d                	je     80103657 <end_op+0x40>
    panic("log.committing");
8010364a:	83 ec 0c             	sub    $0xc,%esp
8010364d:	68 ec 87 10 80       	push   $0x801087ec
80103652:	e8 05 cf ff ff       	call   8010055c <panic>
  if(log.outstanding == 0){
80103657:	a1 7c 23 11 80       	mov    0x8011237c,%eax
8010365c:	85 c0                	test   %eax,%eax
8010365e:	75 13                	jne    80103673 <end_op+0x5c>
    do_commit = 1;
80103660:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103667:	c7 05 80 23 11 80 01 	movl   $0x1,0x80112380
8010366e:	00 00 00 
80103671:	eb 10                	jmp    80103683 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103673:	83 ec 0c             	sub    $0xc,%esp
80103676:	68 40 23 11 80       	push   $0x80112340
8010367b:	e8 90 17 00 00       	call   80104e10 <wakeup>
80103680:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 40 23 11 80       	push   $0x80112340
8010368b:	e8 3d 1a 00 00       	call   801050cd <release>
80103690:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103693:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103697:	74 3f                	je     801036d8 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103699:	e8 f3 00 00 00       	call   80103791 <commit>
    acquire(&log.lock);
8010369e:	83 ec 0c             	sub    $0xc,%esp
801036a1:	68 40 23 11 80       	push   $0x80112340
801036a6:	e8 bc 19 00 00       	call   80105067 <acquire>
801036ab:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801036ae:	c7 05 80 23 11 80 00 	movl   $0x0,0x80112380
801036b5:	00 00 00 
    wakeup(&log);
801036b8:	83 ec 0c             	sub    $0xc,%esp
801036bb:	68 40 23 11 80       	push   $0x80112340
801036c0:	e8 4b 17 00 00       	call   80104e10 <wakeup>
801036c5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	68 40 23 11 80       	push   $0x80112340
801036d0:	e8 f8 19 00 00       	call   801050cd <release>
801036d5:	83 c4 10             	add    $0x10,%esp
  }
}
801036d8:	c9                   	leave  
801036d9:	c3                   	ret    

801036da <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036da:	55                   	push   %ebp
801036db:	89 e5                	mov    %esp,%ebp
801036dd:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036e7:	e9 95 00 00 00       	jmp    80103781 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036ec:	8b 15 74 23 11 80    	mov    0x80112374,%edx
801036f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036f5:	01 d0                	add    %edx,%eax
801036f7:	83 c0 01             	add    $0x1,%eax
801036fa:	89 c2                	mov    %eax,%edx
801036fc:	a1 84 23 11 80       	mov    0x80112384,%eax
80103701:	83 ec 08             	sub    $0x8,%esp
80103704:	52                   	push   %edx
80103705:	50                   	push   %eax
80103706:	e8 a9 ca ff ff       	call   801001b4 <bread>
8010370b:	83 c4 10             	add    $0x10,%esp
8010370e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103714:	83 c0 10             	add    $0x10,%eax
80103717:	8b 04 85 4c 23 11 80 	mov    -0x7feedcb4(,%eax,4),%eax
8010371e:	89 c2                	mov    %eax,%edx
80103720:	a1 84 23 11 80       	mov    0x80112384,%eax
80103725:	83 ec 08             	sub    $0x8,%esp
80103728:	52                   	push   %edx
80103729:	50                   	push   %eax
8010372a:	e8 85 ca ff ff       	call   801001b4 <bread>
8010372f:	83 c4 10             	add    $0x10,%esp
80103732:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103735:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103738:	8d 50 18             	lea    0x18(%eax),%edx
8010373b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373e:	83 c0 18             	add    $0x18,%eax
80103741:	83 ec 04             	sub    $0x4,%esp
80103744:	68 00 02 00 00       	push   $0x200
80103749:	52                   	push   %edx
8010374a:	50                   	push   %eax
8010374b:	e8 32 1c 00 00       	call   80105382 <memmove>
80103750:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103753:	83 ec 0c             	sub    $0xc,%esp
80103756:	ff 75 f0             	pushl  -0x10(%ebp)
80103759:	e8 8f ca ff ff       	call   801001ed <bwrite>
8010375e:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103761:	83 ec 0c             	sub    $0xc,%esp
80103764:	ff 75 ec             	pushl  -0x14(%ebp)
80103767:	e8 bf ca ff ff       	call   8010022b <brelse>
8010376c:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010376f:	83 ec 0c             	sub    $0xc,%esp
80103772:	ff 75 f0             	pushl  -0x10(%ebp)
80103775:	e8 b1 ca ff ff       	call   8010022b <brelse>
8010377a:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010377d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103781:	a1 88 23 11 80       	mov    0x80112388,%eax
80103786:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103789:	0f 8f 5d ff ff ff    	jg     801036ec <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010378f:	c9                   	leave  
80103790:	c3                   	ret    

80103791 <commit>:

static void
commit()
{
80103791:	55                   	push   %ebp
80103792:	89 e5                	mov    %esp,%ebp
80103794:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103797:	a1 88 23 11 80       	mov    0x80112388,%eax
8010379c:	85 c0                	test   %eax,%eax
8010379e:	7e 1e                	jle    801037be <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037a0:	e8 35 ff ff ff       	call   801036da <write_log>
    write_head();    // Write header to disk -- the real commit
801037a5:	e8 3c fd ff ff       	call   801034e6 <write_head>
    install_trans(); // Now install writes to home locations
801037aa:	e8 0d fc ff ff       	call   801033bc <install_trans>
    log.lh.n = 0; 
801037af:	c7 05 88 23 11 80 00 	movl   $0x0,0x80112388
801037b6:	00 00 00 
    write_head();    // Erase the transaction from the log
801037b9:	e8 28 fd ff ff       	call   801034e6 <write_head>
  }
}
801037be:	c9                   	leave  
801037bf:	c3                   	ret    

801037c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037c0:	55                   	push   %ebp
801037c1:	89 e5                	mov    %esp,%ebp
801037c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037c6:	a1 88 23 11 80       	mov    0x80112388,%eax
801037cb:	83 f8 1d             	cmp    $0x1d,%eax
801037ce:	7f 12                	jg     801037e2 <log_write+0x22>
801037d0:	a1 88 23 11 80       	mov    0x80112388,%eax
801037d5:	8b 15 78 23 11 80    	mov    0x80112378,%edx
801037db:	83 ea 01             	sub    $0x1,%edx
801037de:	39 d0                	cmp    %edx,%eax
801037e0:	7c 0d                	jl     801037ef <log_write+0x2f>
    panic("too big a transaction");
801037e2:	83 ec 0c             	sub    $0xc,%esp
801037e5:	68 fb 87 10 80       	push   $0x801087fb
801037ea:	e8 6d cd ff ff       	call   8010055c <panic>
  if (log.outstanding < 1)
801037ef:	a1 7c 23 11 80       	mov    0x8011237c,%eax
801037f4:	85 c0                	test   %eax,%eax
801037f6:	7f 0d                	jg     80103805 <log_write+0x45>
    panic("log_write outside of trans");
801037f8:	83 ec 0c             	sub    $0xc,%esp
801037fb:	68 11 88 10 80       	push   $0x80108811
80103800:	e8 57 cd ff ff       	call   8010055c <panic>

  acquire(&log.lock);
80103805:	83 ec 0c             	sub    $0xc,%esp
80103808:	68 40 23 11 80       	push   $0x80112340
8010380d:	e8 55 18 00 00       	call   80105067 <acquire>
80103812:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103815:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010381c:	eb 1f                	jmp    8010383d <log_write+0x7d>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
8010381e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103821:	83 c0 10             	add    $0x10,%eax
80103824:	8b 04 85 4c 23 11 80 	mov    -0x7feedcb4(,%eax,4),%eax
8010382b:	89 c2                	mov    %eax,%edx
8010382d:	8b 45 08             	mov    0x8(%ebp),%eax
80103830:	8b 40 08             	mov    0x8(%eax),%eax
80103833:	39 c2                	cmp    %eax,%edx
80103835:	75 02                	jne    80103839 <log_write+0x79>
      break;
80103837:	eb 0e                	jmp    80103847 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103839:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010383d:	a1 88 23 11 80       	mov    0x80112388,%eax
80103842:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103845:	7f d7                	jg     8010381e <log_write+0x5e>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
80103847:	8b 45 08             	mov    0x8(%ebp),%eax
8010384a:	8b 40 08             	mov    0x8(%eax),%eax
8010384d:	89 c2                	mov    %eax,%edx
8010384f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103852:	83 c0 10             	add    $0x10,%eax
80103855:	89 14 85 4c 23 11 80 	mov    %edx,-0x7feedcb4(,%eax,4)
  if (i == log.lh.n)
8010385c:	a1 88 23 11 80       	mov    0x80112388,%eax
80103861:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103864:	75 0d                	jne    80103873 <log_write+0xb3>
    log.lh.n++;
80103866:	a1 88 23 11 80       	mov    0x80112388,%eax
8010386b:	83 c0 01             	add    $0x1,%eax
8010386e:	a3 88 23 11 80       	mov    %eax,0x80112388
  b->flags |= B_DIRTY; // prevent eviction
80103873:	8b 45 08             	mov    0x8(%ebp),%eax
80103876:	8b 00                	mov    (%eax),%eax
80103878:	83 c8 04             	or     $0x4,%eax
8010387b:	89 c2                	mov    %eax,%edx
8010387d:	8b 45 08             	mov    0x8(%ebp),%eax
80103880:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103882:	83 ec 0c             	sub    $0xc,%esp
80103885:	68 40 23 11 80       	push   $0x80112340
8010388a:	e8 3e 18 00 00       	call   801050cd <release>
8010388f:	83 c4 10             	add    $0x10,%esp
}
80103892:	c9                   	leave  
80103893:	c3                   	ret    

80103894 <v2p>:
80103894:	55                   	push   %ebp
80103895:	89 e5                	mov    %esp,%ebp
80103897:	8b 45 08             	mov    0x8(%ebp),%eax
8010389a:	05 00 00 00 80       	add    $0x80000000,%eax
8010389f:	5d                   	pop    %ebp
801038a0:	c3                   	ret    

801038a1 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801038a1:	55                   	push   %ebp
801038a2:	89 e5                	mov    %esp,%ebp
801038a4:	8b 45 08             	mov    0x8(%ebp),%eax
801038a7:	05 00 00 00 80       	add    $0x80000000,%eax
801038ac:	5d                   	pop    %ebp
801038ad:	c3                   	ret    

801038ae <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038ae:	55                   	push   %ebp
801038af:	89 e5                	mov    %esp,%ebp
801038b1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038b4:	8b 55 08             	mov    0x8(%ebp),%edx
801038b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801038ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038bd:	f0 87 02             	lock xchg %eax,(%edx)
801038c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038c6:	c9                   	leave  
801038c7:	c3                   	ret    

801038c8 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038c8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038cc:	83 e4 f0             	and    $0xfffffff0,%esp
801038cf:	ff 71 fc             	pushl  -0x4(%ecx)
801038d2:	55                   	push   %ebp
801038d3:	89 e5                	mov    %esp,%ebp
801038d5:	51                   	push   %ecx
801038d6:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038d9:	83 ec 08             	sub    $0x8,%esp
801038dc:	68 00 00 40 80       	push   $0x80400000
801038e1:	68 5c 52 11 80       	push   $0x8011525c
801038e6:	e8 8a f2 ff ff       	call   80102b75 <kinit1>
801038eb:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038ee:	e8 83 45 00 00       	call   80107e76 <kvmalloc>
  mpinit();        // collect info about this machine
801038f3:	e8 4a 04 00 00       	call   80103d42 <mpinit>
  lapicinit();
801038f8:	e8 f0 f5 ff ff       	call   80102eed <lapicinit>
  seginit();       // set up segments
801038fd:	e8 1c 3f 00 00       	call   8010781e <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103902:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103908:	0f b6 00             	movzbl (%eax),%eax
8010390b:	0f b6 c0             	movzbl %al,%eax
8010390e:	83 ec 08             	sub    $0x8,%esp
80103911:	50                   	push   %eax
80103912:	68 2c 88 10 80       	push   $0x8010882c
80103917:	e8 a3 ca ff ff       	call   801003bf <cprintf>
8010391c:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010391f:	e8 6f 06 00 00       	call   80103f93 <picinit>
  ioapicinit();    // another interrupt controller
80103924:	e8 44 f1 ff ff       	call   80102a6d <ioapicinit>
  procfsinit();
80103929:	e8 b5 16 00 00       	call   80104fe3 <procfsinit>
  consoleinit();   // I/O devices & their interrupts
8010392e:	e8 a5 d1 ff ff       	call   80100ad8 <consoleinit>
  uartinit();      // serial port
80103933:	e8 49 32 00 00       	call   80106b81 <uartinit>
  pinit();         // process table
80103938:	e8 55 0b 00 00       	call   80104492 <pinit>
  tvinit();        // trap vectors
8010393d:	e8 0e 2e 00 00       	call   80106750 <tvinit>
  binit();         // buffer cache
80103942:	e8 ed c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103947:	e8 e7 d5 ff ff       	call   80100f33 <fileinit>
  iinit();         // inode cache
8010394c:	e8 ba dc ff ff       	call   8010160b <iinit>
  ideinit();       // disk
80103951:	e8 5f ed ff ff       	call   801026b5 <ideinit>
  if(!ismp)
80103956:	a1 44 24 11 80       	mov    0x80112444,%eax
8010395b:	85 c0                	test   %eax,%eax
8010395d:	75 05                	jne    80103964 <main+0x9c>
    timerinit();   // uniprocessor timer
8010395f:	e8 4b 2d 00 00       	call   801066af <timerinit>
  startothers();   // start other processors
80103964:	e8 7f 00 00 00       	call   801039e8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103969:	83 ec 08             	sub    $0x8,%esp
8010396c:	68 00 00 00 8e       	push   $0x8e000000
80103971:	68 00 00 40 80       	push   $0x80400000
80103976:	e8 32 f2 ff ff       	call   80102bad <kinit2>
8010397b:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010397e:	e8 31 0c 00 00       	call   801045b4 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103983:	e8 1a 00 00 00       	call   801039a2 <mpmain>

80103988 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103988:	55                   	push   %ebp
80103989:	89 e5                	mov    %esp,%ebp
8010398b:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010398e:	e8 fa 44 00 00       	call   80107e8d <switchkvm>
  seginit();
80103993:	e8 86 3e 00 00       	call   8010781e <seginit>
  lapicinit();
80103998:	e8 50 f5 ff ff       	call   80102eed <lapicinit>
  mpmain();
8010399d:	e8 00 00 00 00       	call   801039a2 <mpmain>

801039a2 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039a2:	55                   	push   %ebp
801039a3:	89 e5                	mov    %esp,%ebp
801039a5:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801039a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039ae:	0f b6 00             	movzbl (%eax),%eax
801039b1:	0f b6 c0             	movzbl %al,%eax
801039b4:	83 ec 08             	sub    $0x8,%esp
801039b7:	50                   	push   %eax
801039b8:	68 43 88 10 80       	push   $0x80108843
801039bd:	e8 fd c9 ff ff       	call   801003bf <cprintf>
801039c2:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039c5:	e8 fb 2e 00 00       	call   801068c5 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039d0:	05 a8 00 00 00       	add    $0xa8,%eax
801039d5:	83 ec 08             	sub    $0x8,%esp
801039d8:	6a 01                	push   $0x1
801039da:	50                   	push   %eax
801039db:	e8 ce fe ff ff       	call   801038ae <xchg>
801039e0:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039e3:	e8 76 11 00 00       	call   80104b5e <scheduler>

801039e8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039e8:	55                   	push   %ebp
801039e9:	89 e5                	mov    %esp,%ebp
801039eb:	53                   	push   %ebx
801039ec:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039ef:	68 00 70 00 00       	push   $0x7000
801039f4:	e8 a8 fe ff ff       	call   801038a1 <p2v>
801039f9:	83 c4 04             	add    $0x4,%esp
801039fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039ff:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a04:	83 ec 04             	sub    $0x4,%esp
80103a07:	50                   	push   %eax
80103a08:	68 2c b5 10 80       	push   $0x8010b52c
80103a0d:	ff 75 f0             	pushl  -0x10(%ebp)
80103a10:	e8 6d 19 00 00       	call   80105382 <memmove>
80103a15:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a18:	c7 45 f4 80 24 11 80 	movl   $0x80112480,-0xc(%ebp)
80103a1f:	e9 8f 00 00 00       	jmp    80103ab3 <startothers+0xcb>
    if(c == cpus+cpunum())  // We've started already.
80103a24:	e8 e0 f5 ff ff       	call   80103009 <cpunum>
80103a29:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a2f:	05 80 24 11 80       	add    $0x80112480,%eax
80103a34:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a37:	75 02                	jne    80103a3b <startothers+0x53>
      continue;
80103a39:	eb 71                	jmp    80103aac <startothers+0xc4>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a3b:	e8 68 f2 ff ff       	call   80102ca8 <kalloc>
80103a40:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a46:	83 e8 04             	sub    $0x4,%eax
80103a49:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a4c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a52:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a57:	83 e8 08             	sub    $0x8,%eax
80103a5a:	c7 00 88 39 10 80    	movl   $0x80103988,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a63:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a66:	83 ec 0c             	sub    $0xc,%esp
80103a69:	68 00 a0 10 80       	push   $0x8010a000
80103a6e:	e8 21 fe ff ff       	call   80103894 <v2p>
80103a73:	83 c4 10             	add    $0x10,%esp
80103a76:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a78:	83 ec 0c             	sub    $0xc,%esp
80103a7b:	ff 75 f0             	pushl  -0x10(%ebp)
80103a7e:	e8 11 fe ff ff       	call   80103894 <v2p>
80103a83:	83 c4 10             	add    $0x10,%esp
80103a86:	89 c2                	mov    %eax,%edx
80103a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8b:	0f b6 00             	movzbl (%eax),%eax
80103a8e:	0f b6 c0             	movzbl %al,%eax
80103a91:	83 ec 08             	sub    $0x8,%esp
80103a94:	52                   	push   %edx
80103a95:	50                   	push   %eax
80103a96:	e8 e6 f5 ff ff       	call   80103081 <lapicstartap>
80103a9b:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a9e:	90                   	nop
80103a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103aa8:	85 c0                	test   %eax,%eax
80103aaa:	74 f3                	je     80103a9f <startothers+0xb7>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103aac:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103ab3:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103ab8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103abe:	05 80 24 11 80       	add    $0x80112480,%eax
80103ac3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ac6:	0f 87 58 ff ff ff    	ja     80103a24 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103acc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103acf:	c9                   	leave  
80103ad0:	c3                   	ret    

80103ad1 <p2v>:
80103ad1:	55                   	push   %ebp
80103ad2:	89 e5                	mov    %esp,%ebp
80103ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad7:	05 00 00 00 80       	add    $0x80000000,%eax
80103adc:	5d                   	pop    %ebp
80103add:	c3                   	ret    

80103ade <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ade:	55                   	push   %ebp
80103adf:	89 e5                	mov    %esp,%ebp
80103ae1:	83 ec 14             	sub    $0x14,%esp
80103ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aeb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aef:	89 c2                	mov    %eax,%edx
80103af1:	ec                   	in     (%dx),%al
80103af2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103af5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103af9:	c9                   	leave  
80103afa:	c3                   	ret    

80103afb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103afb:	55                   	push   %ebp
80103afc:	89 e5                	mov    %esp,%ebp
80103afe:	83 ec 08             	sub    $0x8,%esp
80103b01:	8b 55 08             	mov    0x8(%ebp),%edx
80103b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b07:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b0b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b0e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b12:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b16:	ee                   	out    %al,(%dx)
}
80103b17:	c9                   	leave  
80103b18:	c3                   	ret    

80103b19 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b19:	55                   	push   %ebp
80103b1a:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b1c:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103b21:	89 c2                	mov    %eax,%edx
80103b23:	b8 80 24 11 80       	mov    $0x80112480,%eax
80103b28:	29 c2                	sub    %eax,%edx
80103b2a:	89 d0                	mov    %edx,%eax
80103b2c:	c1 f8 02             	sar    $0x2,%eax
80103b2f:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b35:	5d                   	pop    %ebp
80103b36:	c3                   	ret    

80103b37 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b37:	55                   	push   %ebp
80103b38:	89 e5                	mov    %esp,%ebp
80103b3a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b3d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b4b:	eb 15                	jmp    80103b62 <sum+0x2b>
    sum += addr[i];
80103b4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b50:	8b 45 08             	mov    0x8(%ebp),%eax
80103b53:	01 d0                	add    %edx,%eax
80103b55:	0f b6 00             	movzbl (%eax),%eax
80103b58:	0f b6 c0             	movzbl %al,%eax
80103b5b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b5e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b65:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b68:	7c e3                	jl     80103b4d <sum+0x16>
    sum += addr[i];
  return sum;
80103b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b6d:	c9                   	leave  
80103b6e:	c3                   	ret    

80103b6f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b6f:	55                   	push   %ebp
80103b70:	89 e5                	mov    %esp,%ebp
80103b72:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b75:	ff 75 08             	pushl  0x8(%ebp)
80103b78:	e8 54 ff ff ff       	call   80103ad1 <p2v>
80103b7d:	83 c4 04             	add    $0x4,%esp
80103b80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b83:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b89:	01 d0                	add    %edx,%eax
80103b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b94:	eb 36                	jmp    80103bcc <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b96:	83 ec 04             	sub    $0x4,%esp
80103b99:	6a 04                	push   $0x4
80103b9b:	68 54 88 10 80       	push   $0x80108854
80103ba0:	ff 75 f4             	pushl  -0xc(%ebp)
80103ba3:	e8 82 17 00 00       	call   8010532a <memcmp>
80103ba8:	83 c4 10             	add    $0x10,%esp
80103bab:	85 c0                	test   %eax,%eax
80103bad:	75 19                	jne    80103bc8 <mpsearch1+0x59>
80103baf:	83 ec 08             	sub    $0x8,%esp
80103bb2:	6a 10                	push   $0x10
80103bb4:	ff 75 f4             	pushl  -0xc(%ebp)
80103bb7:	e8 7b ff ff ff       	call   80103b37 <sum>
80103bbc:	83 c4 10             	add    $0x10,%esp
80103bbf:	84 c0                	test   %al,%al
80103bc1:	75 05                	jne    80103bc8 <mpsearch1+0x59>
      return (struct mp*)p;
80103bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc6:	eb 11                	jmp    80103bd9 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103bc8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bd2:	72 c2                	jb     80103b96 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bd9:	c9                   	leave  
80103bda:	c3                   	ret    

80103bdb <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bdb:	55                   	push   %ebp
80103bdc:	89 e5                	mov    %esp,%ebp
80103bde:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103be1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103beb:	83 c0 0f             	add    $0xf,%eax
80103bee:	0f b6 00             	movzbl (%eax),%eax
80103bf1:	0f b6 c0             	movzbl %al,%eax
80103bf4:	c1 e0 08             	shl    $0x8,%eax
80103bf7:	89 c2                	mov    %eax,%edx
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	83 c0 0e             	add    $0xe,%eax
80103bff:	0f b6 00             	movzbl (%eax),%eax
80103c02:	0f b6 c0             	movzbl %al,%eax
80103c05:	09 d0                	or     %edx,%eax
80103c07:	c1 e0 04             	shl    $0x4,%eax
80103c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c11:	74 21                	je     80103c34 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c13:	83 ec 08             	sub    $0x8,%esp
80103c16:	68 00 04 00 00       	push   $0x400
80103c1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103c1e:	e8 4c ff ff ff       	call   80103b6f <mpsearch1>
80103c23:	83 c4 10             	add    $0x10,%esp
80103c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c2d:	74 51                	je     80103c80 <mpsearch+0xa5>
      return mp;
80103c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c32:	eb 61                	jmp    80103c95 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c37:	83 c0 14             	add    $0x14,%eax
80103c3a:	0f b6 00             	movzbl (%eax),%eax
80103c3d:	0f b6 c0             	movzbl %al,%eax
80103c40:	c1 e0 08             	shl    $0x8,%eax
80103c43:	89 c2                	mov    %eax,%edx
80103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c48:	83 c0 13             	add    $0x13,%eax
80103c4b:	0f b6 00             	movzbl (%eax),%eax
80103c4e:	0f b6 c0             	movzbl %al,%eax
80103c51:	09 d0                	or     %edx,%eax
80103c53:	c1 e0 0a             	shl    $0xa,%eax
80103c56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c5c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c61:	83 ec 08             	sub    $0x8,%esp
80103c64:	68 00 04 00 00       	push   $0x400
80103c69:	50                   	push   %eax
80103c6a:	e8 00 ff ff ff       	call   80103b6f <mpsearch1>
80103c6f:	83 c4 10             	add    $0x10,%esp
80103c72:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c75:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c79:	74 05                	je     80103c80 <mpsearch+0xa5>
      return mp;
80103c7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c7e:	eb 15                	jmp    80103c95 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c80:	83 ec 08             	sub    $0x8,%esp
80103c83:	68 00 00 01 00       	push   $0x10000
80103c88:	68 00 00 0f 00       	push   $0xf0000
80103c8d:	e8 dd fe ff ff       	call   80103b6f <mpsearch1>
80103c92:	83 c4 10             	add    $0x10,%esp
}
80103c95:	c9                   	leave  
80103c96:	c3                   	ret    

80103c97 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c9d:	e8 39 ff ff ff       	call   80103bdb <mpsearch>
80103ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ca5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ca9:	74 0a                	je     80103cb5 <mpconfig+0x1e>
80103cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cae:	8b 40 04             	mov    0x4(%eax),%eax
80103cb1:	85 c0                	test   %eax,%eax
80103cb3:	75 0a                	jne    80103cbf <mpconfig+0x28>
    return 0;
80103cb5:	b8 00 00 00 00       	mov    $0x0,%eax
80103cba:	e9 81 00 00 00       	jmp    80103d40 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc2:	8b 40 04             	mov    0x4(%eax),%eax
80103cc5:	83 ec 0c             	sub    $0xc,%esp
80103cc8:	50                   	push   %eax
80103cc9:	e8 03 fe ff ff       	call   80103ad1 <p2v>
80103cce:	83 c4 10             	add    $0x10,%esp
80103cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cd4:	83 ec 04             	sub    $0x4,%esp
80103cd7:	6a 04                	push   $0x4
80103cd9:	68 59 88 10 80       	push   $0x80108859
80103cde:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce1:	e8 44 16 00 00       	call   8010532a <memcmp>
80103ce6:	83 c4 10             	add    $0x10,%esp
80103ce9:	85 c0                	test   %eax,%eax
80103ceb:	74 07                	je     80103cf4 <mpconfig+0x5d>
    return 0;
80103ced:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf2:	eb 4c                	jmp    80103d40 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cfb:	3c 01                	cmp    $0x1,%al
80103cfd:	74 12                	je     80103d11 <mpconfig+0x7a>
80103cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d02:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d06:	3c 04                	cmp    $0x4,%al
80103d08:	74 07                	je     80103d11 <mpconfig+0x7a>
    return 0;
80103d0a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0f:	eb 2f                	jmp    80103d40 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d14:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d18:	0f b7 c0             	movzwl %ax,%eax
80103d1b:	83 ec 08             	sub    $0x8,%esp
80103d1e:	50                   	push   %eax
80103d1f:	ff 75 f0             	pushl  -0x10(%ebp)
80103d22:	e8 10 fe ff ff       	call   80103b37 <sum>
80103d27:	83 c4 10             	add    $0x10,%esp
80103d2a:	84 c0                	test   %al,%al
80103d2c:	74 07                	je     80103d35 <mpconfig+0x9e>
    return 0;
80103d2e:	b8 00 00 00 00       	mov    $0x0,%eax
80103d33:	eb 0b                	jmp    80103d40 <mpconfig+0xa9>
  *pmp = mp;
80103d35:	8b 45 08             	mov    0x8(%ebp),%eax
80103d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d3b:	89 10                	mov    %edx,(%eax)
  return conf;
80103d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d40:	c9                   	leave  
80103d41:	c3                   	ret    

80103d42 <mpinit>:

void
mpinit(void)
{
80103d42:	55                   	push   %ebp
80103d43:	89 e5                	mov    %esp,%ebp
80103d45:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d48:	c7 05 64 b6 10 80 80 	movl   $0x80112480,0x8010b664
80103d4f:	24 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d52:	83 ec 0c             	sub    $0xc,%esp
80103d55:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d58:	50                   	push   %eax
80103d59:	e8 39 ff ff ff       	call   80103c97 <mpconfig>
80103d5e:	83 c4 10             	add    $0x10,%esp
80103d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d68:	75 05                	jne    80103d6f <mpinit+0x2d>
    return;
80103d6a:	e9 94 01 00 00       	jmp    80103f03 <mpinit+0x1c1>
  ismp = 1;
80103d6f:	c7 05 44 24 11 80 01 	movl   $0x1,0x80112444
80103d76:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7c:	8b 40 24             	mov    0x24(%eax),%eax
80103d7f:	a3 1c 23 11 80       	mov    %eax,0x8011231c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d87:	83 c0 2c             	add    $0x2c,%eax
80103d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d90:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d94:	0f b7 d0             	movzwl %ax,%edx
80103d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d9a:	01 d0                	add    %edx,%eax
80103d9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d9f:	e9 f2 00 00 00       	jmp    80103e96 <mpinit+0x154>
    switch(*p){
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	0f b6 00             	movzbl (%eax),%eax
80103daa:	0f b6 c0             	movzbl %al,%eax
80103dad:	83 f8 04             	cmp    $0x4,%eax
80103db0:	0f 87 bc 00 00 00    	ja     80103e72 <mpinit+0x130>
80103db6:	8b 04 85 9c 88 10 80 	mov    -0x7fef7764(,%eax,4),%eax
80103dbd:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dcc:	0f b6 d0             	movzbl %al,%edx
80103dcf:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103dd4:	39 c2                	cmp    %eax,%edx
80103dd6:	74 2b                	je     80103e03 <mpinit+0xc1>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103dd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ddb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ddf:	0f b6 d0             	movzbl %al,%edx
80103de2:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103de7:	83 ec 04             	sub    $0x4,%esp
80103dea:	52                   	push   %edx
80103deb:	50                   	push   %eax
80103dec:	68 5e 88 10 80       	push   $0x8010885e
80103df1:	e8 c9 c5 ff ff       	call   801003bf <cprintf>
80103df6:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103df9:	c7 05 44 24 11 80 00 	movl   $0x0,0x80112444
80103e00:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e06:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e0a:	0f b6 c0             	movzbl %al,%eax
80103e0d:	83 e0 02             	and    $0x2,%eax
80103e10:	85 c0                	test   %eax,%eax
80103e12:	74 15                	je     80103e29 <mpinit+0xe7>
        bcpu = &cpus[ncpu];
80103e14:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103e19:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e1f:	05 80 24 11 80       	add    $0x80112480,%eax
80103e24:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103e29:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103e2e:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
80103e34:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e3a:	05 80 24 11 80       	add    $0x80112480,%eax
80103e3f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e41:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80103e46:	83 c0 01             	add    $0x1,%eax
80103e49:	a3 60 2a 11 80       	mov    %eax,0x80112a60
      p += sizeof(struct mpproc);
80103e4e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e52:	eb 42                	jmp    80103e96 <mpinit+0x154>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e5d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e61:	a2 40 24 11 80       	mov    %al,0x80112440
      p += sizeof(struct mpioapic);
80103e66:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e6a:	eb 2a                	jmp    80103e96 <mpinit+0x154>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e6c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e70:	eb 24                	jmp    80103e96 <mpinit+0x154>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e75:	0f b6 00             	movzbl (%eax),%eax
80103e78:	0f b6 c0             	movzbl %al,%eax
80103e7b:	83 ec 08             	sub    $0x8,%esp
80103e7e:	50                   	push   %eax
80103e7f:	68 7c 88 10 80       	push   $0x8010887c
80103e84:	e8 36 c5 ff ff       	call   801003bf <cprintf>
80103e89:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e8c:	c7 05 44 24 11 80 00 	movl   $0x0,0x80112444
80103e93:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e99:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e9c:	0f 82 02 ff ff ff    	jb     80103da4 <mpinit+0x62>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103ea2:	a1 44 24 11 80       	mov    0x80112444,%eax
80103ea7:	85 c0                	test   %eax,%eax
80103ea9:	75 1d                	jne    80103ec8 <mpinit+0x186>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103eab:	c7 05 60 2a 11 80 01 	movl   $0x1,0x80112a60
80103eb2:	00 00 00 
    lapic = 0;
80103eb5:	c7 05 1c 23 11 80 00 	movl   $0x0,0x8011231c
80103ebc:	00 00 00 
    ioapicid = 0;
80103ebf:	c6 05 40 24 11 80 00 	movb   $0x0,0x80112440
    return;
80103ec6:	eb 3b                	jmp    80103f03 <mpinit+0x1c1>
  }

  if(mp->imcrp){
80103ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ecb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ecf:	84 c0                	test   %al,%al
80103ed1:	74 30                	je     80103f03 <mpinit+0x1c1>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ed3:	83 ec 08             	sub    $0x8,%esp
80103ed6:	6a 70                	push   $0x70
80103ed8:	6a 22                	push   $0x22
80103eda:	e8 1c fc ff ff       	call   80103afb <outb>
80103edf:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ee2:	83 ec 0c             	sub    $0xc,%esp
80103ee5:	6a 23                	push   $0x23
80103ee7:	e8 f2 fb ff ff       	call   80103ade <inb>
80103eec:	83 c4 10             	add    $0x10,%esp
80103eef:	83 c8 01             	or     $0x1,%eax
80103ef2:	0f b6 c0             	movzbl %al,%eax
80103ef5:	83 ec 08             	sub    $0x8,%esp
80103ef8:	50                   	push   %eax
80103ef9:	6a 23                	push   $0x23
80103efb:	e8 fb fb ff ff       	call   80103afb <outb>
80103f00:	83 c4 10             	add    $0x10,%esp
  }
}
80103f03:	c9                   	leave  
80103f04:	c3                   	ret    

80103f05 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	83 ec 08             	sub    $0x8,%esp
80103f0b:	8b 55 08             	mov    0x8(%ebp),%edx
80103f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f11:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f15:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f18:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f1c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f20:	ee                   	out    %al,(%dx)
}
80103f21:	c9                   	leave  
80103f22:	c3                   	ret    

80103f23 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f23:	55                   	push   %ebp
80103f24:	89 e5                	mov    %esp,%ebp
80103f26:	83 ec 04             	sub    $0x4,%esp
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f30:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f34:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f3e:	0f b6 c0             	movzbl %al,%eax
80103f41:	50                   	push   %eax
80103f42:	6a 21                	push   $0x21
80103f44:	e8 bc ff ff ff       	call   80103f05 <outb>
80103f49:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f4c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f50:	66 c1 e8 08          	shr    $0x8,%ax
80103f54:	0f b6 c0             	movzbl %al,%eax
80103f57:	50                   	push   %eax
80103f58:	68 a1 00 00 00       	push   $0xa1
80103f5d:	e8 a3 ff ff ff       	call   80103f05 <outb>
80103f62:	83 c4 08             	add    $0x8,%esp
}
80103f65:	c9                   	leave  
80103f66:	c3                   	ret    

80103f67 <picenable>:

void
picenable(int irq)
{
80103f67:	55                   	push   %ebp
80103f68:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6d:	ba 01 00 00 00       	mov    $0x1,%edx
80103f72:	89 c1                	mov    %eax,%ecx
80103f74:	d3 e2                	shl    %cl,%edx
80103f76:	89 d0                	mov    %edx,%eax
80103f78:	f7 d0                	not    %eax
80103f7a:	89 c2                	mov    %eax,%edx
80103f7c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f83:	21 d0                	and    %edx,%eax
80103f85:	0f b7 c0             	movzwl %ax,%eax
80103f88:	50                   	push   %eax
80103f89:	e8 95 ff ff ff       	call   80103f23 <picsetmask>
80103f8e:	83 c4 04             	add    $0x4,%esp
}
80103f91:	c9                   	leave  
80103f92:	c3                   	ret    

80103f93 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f93:	55                   	push   %ebp
80103f94:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f96:	68 ff 00 00 00       	push   $0xff
80103f9b:	6a 21                	push   $0x21
80103f9d:	e8 63 ff ff ff       	call   80103f05 <outb>
80103fa2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fa5:	68 ff 00 00 00       	push   $0xff
80103faa:	68 a1 00 00 00       	push   $0xa1
80103faf:	e8 51 ff ff ff       	call   80103f05 <outb>
80103fb4:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fb7:	6a 11                	push   $0x11
80103fb9:	6a 20                	push   $0x20
80103fbb:	e8 45 ff ff ff       	call   80103f05 <outb>
80103fc0:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc3:	6a 20                	push   $0x20
80103fc5:	6a 21                	push   $0x21
80103fc7:	e8 39 ff ff ff       	call   80103f05 <outb>
80103fcc:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fcf:	6a 04                	push   $0x4
80103fd1:	6a 21                	push   $0x21
80103fd3:	e8 2d ff ff ff       	call   80103f05 <outb>
80103fd8:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fdb:	6a 03                	push   $0x3
80103fdd:	6a 21                	push   $0x21
80103fdf:	e8 21 ff ff ff       	call   80103f05 <outb>
80103fe4:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fe7:	6a 11                	push   $0x11
80103fe9:	68 a0 00 00 00       	push   $0xa0
80103fee:	e8 12 ff ff ff       	call   80103f05 <outb>
80103ff3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ff6:	6a 28                	push   $0x28
80103ff8:	68 a1 00 00 00       	push   $0xa1
80103ffd:	e8 03 ff ff ff       	call   80103f05 <outb>
80104002:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104005:	6a 02                	push   $0x2
80104007:	68 a1 00 00 00       	push   $0xa1
8010400c:	e8 f4 fe ff ff       	call   80103f05 <outb>
80104011:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104014:	6a 03                	push   $0x3
80104016:	68 a1 00 00 00       	push   $0xa1
8010401b:	e8 e5 fe ff ff       	call   80103f05 <outb>
80104020:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104023:	6a 68                	push   $0x68
80104025:	6a 20                	push   $0x20
80104027:	e8 d9 fe ff ff       	call   80103f05 <outb>
8010402c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010402f:	6a 0a                	push   $0xa
80104031:	6a 20                	push   $0x20
80104033:	e8 cd fe ff ff       	call   80103f05 <outb>
80104038:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010403b:	6a 68                	push   $0x68
8010403d:	68 a0 00 00 00       	push   $0xa0
80104042:	e8 be fe ff ff       	call   80103f05 <outb>
80104047:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010404a:	6a 0a                	push   $0xa
8010404c:	68 a0 00 00 00       	push   $0xa0
80104051:	e8 af fe ff ff       	call   80103f05 <outb>
80104056:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104059:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104060:	66 83 f8 ff          	cmp    $0xffff,%ax
80104064:	74 13                	je     80104079 <picinit+0xe6>
    picsetmask(irqmask);
80104066:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010406d:	0f b7 c0             	movzwl %ax,%eax
80104070:	50                   	push   %eax
80104071:	e8 ad fe ff ff       	call   80103f23 <picsetmask>
80104076:	83 c4 04             	add    $0x4,%esp
}
80104079:	c9                   	leave  
8010407a:	c3                   	ret    

8010407b <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010407b:	55                   	push   %ebp
8010407c:	89 e5                	mov    %esp,%ebp
8010407e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104081:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104091:	8b 45 0c             	mov    0xc(%ebp),%eax
80104094:	8b 10                	mov    (%eax),%edx
80104096:	8b 45 08             	mov    0x8(%ebp),%eax
80104099:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010409b:	e8 b0 ce ff ff       	call   80100f50 <filealloc>
801040a0:	89 c2                	mov    %eax,%edx
801040a2:	8b 45 08             	mov    0x8(%ebp),%eax
801040a5:	89 10                	mov    %edx,(%eax)
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	8b 00                	mov    (%eax),%eax
801040ac:	85 c0                	test   %eax,%eax
801040ae:	0f 84 cb 00 00 00    	je     8010417f <pipealloc+0x104>
801040b4:	e8 97 ce ff ff       	call   80100f50 <filealloc>
801040b9:	89 c2                	mov    %eax,%edx
801040bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040be:	89 10                	mov    %edx,(%eax)
801040c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c3:	8b 00                	mov    (%eax),%eax
801040c5:	85 c0                	test   %eax,%eax
801040c7:	0f 84 b2 00 00 00    	je     8010417f <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040cd:	e8 d6 eb ff ff       	call   80102ca8 <kalloc>
801040d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040d9:	75 05                	jne    801040e0 <pipealloc+0x65>
    goto bad;
801040db:	e9 9f 00 00 00       	jmp    8010417f <pipealloc+0x104>
  p->readopen = 1;
801040e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040ea:	00 00 00 
  p->writeopen = 1;
801040ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040f7:	00 00 00 
  p->nwrite = 0;
801040fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104104:	00 00 00 
  p->nread = 0;
80104107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010410a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104111:	00 00 00 
  initlock(&p->lock, "pipe");
80104114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104117:	83 ec 08             	sub    $0x8,%esp
8010411a:	68 b0 88 10 80       	push   $0x801088b0
8010411f:	50                   	push   %eax
80104120:	e8 21 0f 00 00       	call   80105046 <initlock>
80104125:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	8b 00                	mov    (%eax),%eax
8010412d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 00                	mov    (%eax),%eax
80104138:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	8b 00                	mov    (%eax),%eax
80104141:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104145:	8b 45 08             	mov    0x8(%ebp),%eax
80104148:	8b 00                	mov    (%eax),%eax
8010414a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104150:	8b 45 0c             	mov    0xc(%ebp),%eax
80104153:	8b 00                	mov    (%eax),%eax
80104155:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010415b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415e:	8b 00                	mov    (%eax),%eax
80104160:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104164:	8b 45 0c             	mov    0xc(%ebp),%eax
80104167:	8b 00                	mov    (%eax),%eax
80104169:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010416d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104170:	8b 00                	mov    (%eax),%eax
80104172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104175:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104178:	b8 00 00 00 00       	mov    $0x0,%eax
8010417d:	eb 4d                	jmp    801041cc <pipealloc+0x151>

//PAGEBREAK: 20
 bad:
  if(p)
8010417f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104183:	74 0e                	je     80104193 <pipealloc+0x118>
    kfree((char*)p);
80104185:	83 ec 0c             	sub    $0xc,%esp
80104188:	ff 75 f4             	pushl  -0xc(%ebp)
8010418b:	e8 7c ea ff ff       	call   80102c0c <kfree>
80104190:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104193:	8b 45 08             	mov    0x8(%ebp),%eax
80104196:	8b 00                	mov    (%eax),%eax
80104198:	85 c0                	test   %eax,%eax
8010419a:	74 11                	je     801041ad <pipealloc+0x132>
    fileclose(*f0);
8010419c:	8b 45 08             	mov    0x8(%ebp),%eax
8010419f:	8b 00                	mov    (%eax),%eax
801041a1:	83 ec 0c             	sub    $0xc,%esp
801041a4:	50                   	push   %eax
801041a5:	e8 63 ce ff ff       	call   8010100d <fileclose>
801041aa:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b0:	8b 00                	mov    (%eax),%eax
801041b2:	85 c0                	test   %eax,%eax
801041b4:	74 11                	je     801041c7 <pipealloc+0x14c>
    fileclose(*f1);
801041b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b9:	8b 00                	mov    (%eax),%eax
801041bb:	83 ec 0c             	sub    $0xc,%esp
801041be:	50                   	push   %eax
801041bf:	e8 49 ce ff ff       	call   8010100d <fileclose>
801041c4:	83 c4 10             	add    $0x10,%esp
  return -1;
801041c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041cc:	c9                   	leave  
801041cd:	c3                   	ret    

801041ce <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041ce:	55                   	push   %ebp
801041cf:	89 e5                	mov    %esp,%ebp
801041d1:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041d4:	8b 45 08             	mov    0x8(%ebp),%eax
801041d7:	83 ec 0c             	sub    $0xc,%esp
801041da:	50                   	push   %eax
801041db:	e8 87 0e 00 00       	call   80105067 <acquire>
801041e0:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041e7:	74 23                	je     8010420c <pipeclose+0x3e>
    p->writeopen = 0;
801041e9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ec:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041f3:	00 00 00 
    wakeup(&p->nread);
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	05 34 02 00 00       	add    $0x234,%eax
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 09 0c 00 00       	call   80104e10 <wakeup>
80104207:	83 c4 10             	add    $0x10,%esp
8010420a:	eb 21                	jmp    8010422d <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104216:	00 00 00 
    wakeup(&p->nwrite);
80104219:	8b 45 08             	mov    0x8(%ebp),%eax
8010421c:	05 38 02 00 00       	add    $0x238,%eax
80104221:	83 ec 0c             	sub    $0xc,%esp
80104224:	50                   	push   %eax
80104225:	e8 e6 0b 00 00       	call   80104e10 <wakeup>
8010422a:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104236:	85 c0                	test   %eax,%eax
80104238:	75 2c                	jne    80104266 <pipeclose+0x98>
8010423a:	8b 45 08             	mov    0x8(%ebp),%eax
8010423d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104243:	85 c0                	test   %eax,%eax
80104245:	75 1f                	jne    80104266 <pipeclose+0x98>
    release(&p->lock);
80104247:	8b 45 08             	mov    0x8(%ebp),%eax
8010424a:	83 ec 0c             	sub    $0xc,%esp
8010424d:	50                   	push   %eax
8010424e:	e8 7a 0e 00 00       	call   801050cd <release>
80104253:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104256:	83 ec 0c             	sub    $0xc,%esp
80104259:	ff 75 08             	pushl  0x8(%ebp)
8010425c:	e8 ab e9 ff ff       	call   80102c0c <kfree>
80104261:	83 c4 10             	add    $0x10,%esp
80104264:	eb 0f                	jmp    80104275 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	83 ec 0c             	sub    $0xc,%esp
8010426c:	50                   	push   %eax
8010426d:	e8 5b 0e 00 00       	call   801050cd <release>
80104272:	83 c4 10             	add    $0x10,%esp
}
80104275:	c9                   	leave  
80104276:	c3                   	ret    

80104277 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104277:	55                   	push   %ebp
80104278:	89 e5                	mov    %esp,%ebp
8010427a:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	83 ec 0c             	sub    $0xc,%esp
80104283:	50                   	push   %eax
80104284:	e8 de 0d 00 00       	call   80105067 <acquire>
80104289:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010428c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104293:	e9 af 00 00 00       	jmp    80104347 <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104298:	eb 60                	jmp    801042fa <pipewrite+0x83>
      if(p->readopen == 0 || proc->killed){
8010429a:	8b 45 08             	mov    0x8(%ebp),%eax
8010429d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042a3:	85 c0                	test   %eax,%eax
801042a5:	74 0d                	je     801042b4 <pipewrite+0x3d>
801042a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ad:	8b 40 24             	mov    0x24(%eax),%eax
801042b0:	85 c0                	test   %eax,%eax
801042b2:	74 19                	je     801042cd <pipewrite+0x56>
        release(&p->lock);
801042b4:	8b 45 08             	mov    0x8(%ebp),%eax
801042b7:	83 ec 0c             	sub    $0xc,%esp
801042ba:	50                   	push   %eax
801042bb:	e8 0d 0e 00 00       	call   801050cd <release>
801042c0:	83 c4 10             	add    $0x10,%esp
        return -1;
801042c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c8:	e9 ac 00 00 00       	jmp    80104379 <pipewrite+0x102>
      }
      wakeup(&p->nread);
801042cd:	8b 45 08             	mov    0x8(%ebp),%eax
801042d0:	05 34 02 00 00       	add    $0x234,%eax
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	50                   	push   %eax
801042d9:	e8 32 0b 00 00       	call   80104e10 <wakeup>
801042de:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042e1:	8b 45 08             	mov    0x8(%ebp),%eax
801042e4:	8b 55 08             	mov    0x8(%ebp),%edx
801042e7:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ed:	83 ec 08             	sub    $0x8,%esp
801042f0:	50                   	push   %eax
801042f1:	52                   	push   %edx
801042f2:	e8 30 0a 00 00       	call   80104d27 <sleep>
801042f7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042fa:	8b 45 08             	mov    0x8(%ebp),%eax
801042fd:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430c:	05 00 02 00 00       	add    $0x200,%eax
80104311:	39 c2                	cmp    %eax,%edx
80104313:	74 85                	je     8010429a <pipewrite+0x23>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010431e:	8d 48 01             	lea    0x1(%eax),%ecx
80104321:	8b 55 08             	mov    0x8(%ebp),%edx
80104324:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010432a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010432f:	89 c1                	mov    %eax,%ecx
80104331:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104334:	8b 45 0c             	mov    0xc(%ebp),%eax
80104337:	01 d0                	add    %edx,%eax
80104339:	0f b6 10             	movzbl (%eax),%edx
8010433c:	8b 45 08             	mov    0x8(%ebp),%eax
8010433f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104343:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010434d:	0f 8c 45 ff ff ff    	jl     80104298 <pipewrite+0x21>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	05 34 02 00 00       	add    $0x234,%eax
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	50                   	push   %eax
8010435f:	e8 ac 0a 00 00       	call   80104e10 <wakeup>
80104364:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	50                   	push   %eax
8010436e:	e8 5a 0d 00 00       	call   801050cd <release>
80104373:	83 c4 10             	add    $0x10,%esp
  return n;
80104376:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104379:	c9                   	leave  
8010437a:	c3                   	ret    

8010437b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	53                   	push   %ebx
8010437f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104382:	8b 45 08             	mov    0x8(%ebp),%eax
80104385:	83 ec 0c             	sub    $0xc,%esp
80104388:	50                   	push   %eax
80104389:	e8 d9 0c 00 00       	call   80105067 <acquire>
8010438e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104391:	eb 3f                	jmp    801043d2 <piperead+0x57>
    if(proc->killed){
80104393:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104399:	8b 40 24             	mov    0x24(%eax),%eax
8010439c:	85 c0                	test   %eax,%eax
8010439e:	74 19                	je     801043b9 <piperead+0x3e>
      release(&p->lock);
801043a0:	8b 45 08             	mov    0x8(%ebp),%eax
801043a3:	83 ec 0c             	sub    $0xc,%esp
801043a6:	50                   	push   %eax
801043a7:	e8 21 0d 00 00       	call   801050cd <release>
801043ac:	83 c4 10             	add    $0x10,%esp
      return -1;
801043af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b4:	e9 be 00 00 00       	jmp    80104477 <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043b9:	8b 45 08             	mov    0x8(%ebp),%eax
801043bc:	8b 55 08             	mov    0x8(%ebp),%edx
801043bf:	81 c2 34 02 00 00    	add    $0x234,%edx
801043c5:	83 ec 08             	sub    $0x8,%esp
801043c8:	50                   	push   %eax
801043c9:	52                   	push   %edx
801043ca:	e8 58 09 00 00       	call   80104d27 <sleep>
801043cf:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043d2:	8b 45 08             	mov    0x8(%ebp),%eax
801043d5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043db:	8b 45 08             	mov    0x8(%ebp),%eax
801043de:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e4:	39 c2                	cmp    %eax,%edx
801043e6:	75 0d                	jne    801043f5 <piperead+0x7a>
801043e8:	8b 45 08             	mov    0x8(%ebp),%eax
801043eb:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043f1:	85 c0                	test   %eax,%eax
801043f3:	75 9e                	jne    80104393 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043fc:	eb 4b                	jmp    80104449 <piperead+0xce>
    if(p->nread == p->nwrite)
801043fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104401:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104407:	8b 45 08             	mov    0x8(%ebp),%eax
8010440a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104410:	39 c2                	cmp    %eax,%edx
80104412:	75 02                	jne    80104416 <piperead+0x9b>
      break;
80104414:	eb 3b                	jmp    80104451 <piperead+0xd6>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104416:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104419:	8b 45 0c             	mov    0xc(%ebp),%eax
8010441c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010441f:	8b 45 08             	mov    0x8(%ebp),%eax
80104422:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104428:	8d 48 01             	lea    0x1(%eax),%ecx
8010442b:	8b 55 08             	mov    0x8(%ebp),%edx
8010442e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104434:	25 ff 01 00 00       	and    $0x1ff,%eax
80104439:	89 c2                	mov    %eax,%edx
8010443b:	8b 45 08             	mov    0x8(%ebp),%eax
8010443e:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104443:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104445:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010444f:	7c ad                	jl     801043fe <piperead+0x83>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104451:	8b 45 08             	mov    0x8(%ebp),%eax
80104454:	05 38 02 00 00       	add    $0x238,%eax
80104459:	83 ec 0c             	sub    $0xc,%esp
8010445c:	50                   	push   %eax
8010445d:	e8 ae 09 00 00       	call   80104e10 <wakeup>
80104462:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104465:	8b 45 08             	mov    0x8(%ebp),%eax
80104468:	83 ec 0c             	sub    $0xc,%esp
8010446b:	50                   	push   %eax
8010446c:	e8 5c 0c 00 00       	call   801050cd <release>
80104471:	83 c4 10             	add    $0x10,%esp
  return i;
80104474:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010447a:	c9                   	leave  
8010447b:	c3                   	ret    

8010447c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010447c:	55                   	push   %ebp
8010447d:	89 e5                	mov    %esp,%ebp
8010447f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104482:	9c                   	pushf  
80104483:	58                   	pop    %eax
80104484:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104487:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010448a:	c9                   	leave  
8010448b:	c3                   	ret    

8010448c <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010448c:	55                   	push   %ebp
8010448d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010448f:	fb                   	sti    
}
80104490:	5d                   	pop    %ebp
80104491:	c3                   	ret    

80104492 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104492:	55                   	push   %ebp
80104493:	89 e5                	mov    %esp,%ebp
80104495:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104498:	83 ec 08             	sub    $0x8,%esp
8010449b:	68 b5 88 10 80       	push   $0x801088b5
801044a0:	68 80 2a 11 80       	push   $0x80112a80
801044a5:	e8 9c 0b 00 00       	call   80105046 <initlock>
801044aa:	83 c4 10             	add    $0x10,%esp
}
801044ad:	c9                   	leave  
801044ae:	c3                   	ret    

801044af <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044af:	55                   	push   %ebp
801044b0:	89 e5                	mov    %esp,%ebp
801044b2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044b5:	83 ec 0c             	sub    $0xc,%esp
801044b8:	68 80 2a 11 80       	push   $0x80112a80
801044bd:	e8 a5 0b 00 00       	call   80105067 <acquire>
801044c2:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c5:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
801044cc:	eb 56                	jmp    80104524 <allocproc+0x75>
    if(p->state == UNUSED)
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d1:	8b 40 0c             	mov    0xc(%eax),%eax
801044d4:	85 c0                	test   %eax,%eax
801044d6:	75 48                	jne    80104520 <allocproc+0x71>
      goto found;
801044d8:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044e3:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044e8:	8d 50 01             	lea    0x1(%eax),%edx
801044eb:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f4:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044f7:	83 ec 0c             	sub    $0xc,%esp
801044fa:	68 80 2a 11 80       	push   $0x80112a80
801044ff:	e8 c9 0b 00 00       	call   801050cd <release>
80104504:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104507:	e8 9c e7 ff ff       	call   80102ca8 <kalloc>
8010450c:	89 c2                	mov    %eax,%edx
8010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104511:	89 50 08             	mov    %edx,0x8(%eax)
80104514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104517:	8b 40 08             	mov    0x8(%eax),%eax
8010451a:	85 c0                	test   %eax,%eax
8010451c:	75 37                	jne    80104555 <allocproc+0xa6>
8010451e:	eb 24                	jmp    80104544 <allocproc+0x95>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104520:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104524:	81 7d f4 b4 49 11 80 	cmpl   $0x801149b4,-0xc(%ebp)
8010452b:	72 a1                	jb     801044ce <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010452d:	83 ec 0c             	sub    $0xc,%esp
80104530:	68 80 2a 11 80       	push   $0x80112a80
80104535:	e8 93 0b 00 00       	call   801050cd <release>
8010453a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010453d:	b8 00 00 00 00       	mov    $0x0,%eax
80104542:	eb 6e                	jmp    801045b2 <allocproc+0x103>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104547:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010454e:	b8 00 00 00 00       	mov    $0x0,%eax
80104553:	eb 5d                	jmp    801045b2 <allocproc+0x103>
  }
  sp = p->kstack + KSTACKSIZE;
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	8b 40 08             	mov    0x8(%eax),%eax
8010455b:	05 00 10 00 00       	add    $0x1000,%eax
80104560:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104563:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010456d:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104570:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104574:	ba 0b 67 10 80       	mov    $0x8010670b,%edx
80104579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010457c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010457e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104588:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010458b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104591:	83 ec 04             	sub    $0x4,%esp
80104594:	6a 14                	push   $0x14
80104596:	6a 00                	push   $0x0
80104598:	50                   	push   %eax
80104599:	e8 25 0d 00 00       	call   801052c3 <memset>
8010459e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a4:	8b 40 1c             	mov    0x1c(%eax),%eax
801045a7:	ba f7 4c 10 80       	mov    $0x80104cf7,%edx
801045ac:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045b2:	c9                   	leave  
801045b3:	c3                   	ret    

801045b4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045b4:	55                   	push   %ebp
801045b5:	89 e5                	mov    %esp,%ebp
801045b7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045ba:	e8 f0 fe ff ff       	call   801044af <allocproc>
801045bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801045ca:	e8 f5 37 00 00       	call   80107dc4 <setupkvm>
801045cf:	89 c2                	mov    %eax,%edx
801045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d4:	89 50 04             	mov    %edx,0x4(%eax)
801045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045da:	8b 40 04             	mov    0x4(%eax),%eax
801045dd:	85 c0                	test   %eax,%eax
801045df:	75 0d                	jne    801045ee <userinit+0x3a>
    panic("userinit: out of memory?");
801045e1:	83 ec 0c             	sub    $0xc,%esp
801045e4:	68 bc 88 10 80       	push   $0x801088bc
801045e9:	e8 6e bf ff ff       	call   8010055c <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045ee:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f6:	8b 40 04             	mov    0x4(%eax),%eax
801045f9:	83 ec 04             	sub    $0x4,%esp
801045fc:	52                   	push   %edx
801045fd:	68 00 b5 10 80       	push   $0x8010b500
80104602:	50                   	push   %eax
80104603:	e8 13 3a 00 00       	call   8010801b <inituvm>
80104608:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010460b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104617:	8b 40 18             	mov    0x18(%eax),%eax
8010461a:	83 ec 04             	sub    $0x4,%esp
8010461d:	6a 4c                	push   $0x4c
8010461f:	6a 00                	push   $0x0
80104621:	50                   	push   %eax
80104622:	e8 9c 0c 00 00       	call   801052c3 <memset>
80104627:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462d:	8b 40 18             	mov    0x18(%eax),%eax
80104630:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104639:	8b 40 18             	mov    0x18(%eax),%eax
8010463c:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104645:	8b 40 18             	mov    0x18(%eax),%eax
80104648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464b:	8b 52 18             	mov    0x18(%edx),%edx
8010464e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104652:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104659:	8b 40 18             	mov    0x18(%eax),%eax
8010465c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465f:	8b 52 18             	mov    0x18(%edx),%edx
80104662:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104666:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010466a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466d:	8b 40 18             	mov    0x18(%eax),%eax
80104670:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467a:	8b 40 18             	mov    0x18(%eax),%eax
8010467d:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104687:	8b 40 18             	mov    0x18(%eax),%eax
8010468a:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104694:	83 c0 6c             	add    $0x6c,%eax
80104697:	83 ec 04             	sub    $0x4,%esp
8010469a:	6a 10                	push   $0x10
8010469c:	68 d5 88 10 80       	push   $0x801088d5
801046a1:	50                   	push   %eax
801046a2:	e8 21 0e 00 00       	call   801054c8 <safestrcpy>
801046a7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046aa:	83 ec 0c             	sub    $0xc,%esp
801046ad:	68 de 88 10 80       	push   $0x801088de
801046b2:	e8 fd de ff ff       	call   801025b4 <namei>
801046b7:	83 c4 10             	add    $0x10,%esp
801046ba:	89 c2                	mov    %eax,%edx
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046cc:	c9                   	leave  
801046cd:	c3                   	ret    

801046ce <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046ce:	55                   	push   %ebp
801046cf:	89 e5                	mov    %esp,%ebp
801046d1:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046da:	8b 00                	mov    (%eax),%eax
801046dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046e3:	7e 31                	jle    80104716 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046e5:	8b 55 08             	mov    0x8(%ebp),%edx
801046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046eb:	01 c2                	add    %eax,%edx
801046ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f3:	8b 40 04             	mov    0x4(%eax),%eax
801046f6:	83 ec 04             	sub    $0x4,%esp
801046f9:	52                   	push   %edx
801046fa:	ff 75 f4             	pushl  -0xc(%ebp)
801046fd:	50                   	push   %eax
801046fe:	e8 64 3a 00 00       	call   80108167 <allocuvm>
80104703:	83 c4 10             	add    $0x10,%esp
80104706:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010470d:	75 3e                	jne    8010474d <growproc+0x7f>
      return -1;
8010470f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104714:	eb 59                	jmp    8010476f <growproc+0xa1>
  } else if(n < 0){
80104716:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010471a:	79 31                	jns    8010474d <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010471c:	8b 55 08             	mov    0x8(%ebp),%edx
8010471f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104722:	01 c2                	add    %eax,%edx
80104724:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472a:	8b 40 04             	mov    0x4(%eax),%eax
8010472d:	83 ec 04             	sub    $0x4,%esp
80104730:	52                   	push   %edx
80104731:	ff 75 f4             	pushl  -0xc(%ebp)
80104734:	50                   	push   %eax
80104735:	e8 f6 3a 00 00       	call   80108230 <deallocuvm>
8010473a:	83 c4 10             	add    $0x10,%esp
8010473d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104740:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104744:	75 07                	jne    8010474d <growproc+0x7f>
      return -1;
80104746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474b:	eb 22                	jmp    8010476f <growproc+0xa1>
  }
  proc->sz = sz;
8010474d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104753:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104756:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475e:	83 ec 0c             	sub    $0xc,%esp
80104761:	50                   	push   %eax
80104762:	e8 42 37 00 00       	call   80107ea9 <switchuvm>
80104767:	83 c4 10             	add    $0x10,%esp
  return 0;
8010476a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010476f:	c9                   	leave  
80104770:	c3                   	ret    

80104771 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104771:	55                   	push   %ebp
80104772:	89 e5                	mov    %esp,%ebp
80104774:	57                   	push   %edi
80104775:	56                   	push   %esi
80104776:	53                   	push   %ebx
80104777:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010477a:	e8 30 fd ff ff       	call   801044af <allocproc>
8010477f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104782:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104786:	75 0a                	jne    80104792 <fork+0x21>
    return -1;
80104788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010478d:	e9 68 01 00 00       	jmp    801048fa <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104792:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104798:	8b 10                	mov    (%eax),%edx
8010479a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a0:	8b 40 04             	mov    0x4(%eax),%eax
801047a3:	83 ec 08             	sub    $0x8,%esp
801047a6:	52                   	push   %edx
801047a7:	50                   	push   %eax
801047a8:	e8 1f 3c 00 00       	call   801083cc <copyuvm>
801047ad:	83 c4 10             	add    $0x10,%esp
801047b0:	89 c2                	mov    %eax,%edx
801047b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b5:	89 50 04             	mov    %edx,0x4(%eax)
801047b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bb:	8b 40 04             	mov    0x4(%eax),%eax
801047be:	85 c0                	test   %eax,%eax
801047c0:	75 30                	jne    801047f2 <fork+0x81>
    kfree(np->kstack);
801047c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c5:	8b 40 08             	mov    0x8(%eax),%eax
801047c8:	83 ec 0c             	sub    $0xc,%esp
801047cb:	50                   	push   %eax
801047cc:	e8 3b e4 ff ff       	call   80102c0c <kfree>
801047d1:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ed:	e9 08 01 00 00       	jmp    801048fa <fork+0x189>
  }
  np->sz = proc->sz;
801047f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f8:	8b 10                	mov    (%eax),%edx
801047fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fd:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104806:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104809:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010480c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480f:	8b 50 18             	mov    0x18(%eax),%edx
80104812:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104818:	8b 40 18             	mov    0x18(%eax),%eax
8010481b:	89 c3                	mov    %eax,%ebx
8010481d:	b8 13 00 00 00       	mov    $0x13,%eax
80104822:	89 d7                	mov    %edx,%edi
80104824:	89 de                	mov    %ebx,%esi
80104826:	89 c1                	mov    %eax,%ecx
80104828:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010482a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482d:	8b 40 18             	mov    0x18(%eax),%eax
80104830:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104837:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010483e:	eb 43                	jmp    80104883 <fork+0x112>
    if(proc->ofile[i])
80104840:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104846:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104849:	83 c2 08             	add    $0x8,%edx
8010484c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104850:	85 c0                	test   %eax,%eax
80104852:	74 2b                	je     8010487f <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485d:	83 c2 08             	add    $0x8,%edx
80104860:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104864:	83 ec 0c             	sub    $0xc,%esp
80104867:	50                   	push   %eax
80104868:	e8 4f c7 ff ff       	call   80100fbc <filedup>
8010486d:	83 c4 10             	add    $0x10,%esp
80104870:	89 c1                	mov    %eax,%ecx
80104872:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104875:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104878:	83 c2 08             	add    $0x8,%edx
8010487b:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010487f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104883:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104887:	7e b7                	jle    80104840 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104889:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488f:	8b 40 68             	mov    0x68(%eax),%eax
80104892:	83 ec 0c             	sub    $0xc,%esp
80104895:	50                   	push   %eax
80104896:	e8 07 d0 ff ff       	call   801018a2 <idup>
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	89 c2                	mov    %eax,%edx
801048a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a3:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ac:	8d 50 6c             	lea    0x6c(%eax),%edx
801048af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b2:	83 c0 6c             	add    $0x6c,%eax
801048b5:	83 ec 04             	sub    $0x4,%esp
801048b8:	6a 10                	push   $0x10
801048ba:	52                   	push   %edx
801048bb:	50                   	push   %eax
801048bc:	e8 07 0c 00 00       	call   801054c8 <safestrcpy>
801048c1:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c7:	8b 40 10             	mov    0x10(%eax),%eax
801048ca:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048cd:	83 ec 0c             	sub    $0xc,%esp
801048d0:	68 80 2a 11 80       	push   $0x80112a80
801048d5:	e8 8d 07 00 00       	call   80105067 <acquire>
801048da:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048e7:	83 ec 0c             	sub    $0xc,%esp
801048ea:	68 80 2a 11 80       	push   $0x80112a80
801048ef:	e8 d9 07 00 00       	call   801050cd <release>
801048f4:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048fd:	5b                   	pop    %ebx
801048fe:	5e                   	pop    %esi
801048ff:	5f                   	pop    %edi
80104900:	5d                   	pop    %ebp
80104901:	c3                   	ret    

80104902 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104902:	55                   	push   %ebp
80104903:	89 e5                	mov    %esp,%ebp
80104905:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104908:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010490f:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104914:	39 c2                	cmp    %eax,%edx
80104916:	75 0d                	jne    80104925 <exit+0x23>
    panic("init exiting");
80104918:	83 ec 0c             	sub    $0xc,%esp
8010491b:	68 e0 88 10 80       	push   $0x801088e0
80104920:	e8 37 bc ff ff       	call   8010055c <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104925:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010492c:	eb 48                	jmp    80104976 <exit+0x74>
    if(proc->ofile[fd]){
8010492e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104934:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104937:	83 c2 08             	add    $0x8,%edx
8010493a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010493e:	85 c0                	test   %eax,%eax
80104940:	74 30                	je     80104972 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104952:	83 ec 0c             	sub    $0xc,%esp
80104955:	50                   	push   %eax
80104956:	e8 b2 c6 ff ff       	call   8010100d <fileclose>
8010495b:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010495e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104964:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104967:	83 c2 08             	add    $0x8,%edx
8010496a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104971:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104972:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104976:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010497a:	7e b2                	jle    8010492e <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010497c:	e8 08 ec ff ff       	call   80103589 <begin_op>
  iput(proc->cwd);
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	8b 40 68             	mov    0x68(%eax),%eax
8010498a:	83 ec 0c             	sub    $0xc,%esp
8010498d:	50                   	push   %eax
8010498e:	e8 11 d1 ff ff       	call   80101aa4 <iput>
80104993:	83 c4 10             	add    $0x10,%esp
  end_op();
80104996:	e8 7c ec ff ff       	call   80103617 <end_op>
  proc->cwd = 0;
8010499b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 80 2a 11 80       	push   $0x80112a80
801049b0:	e8 b2 06 00 00       	call   80105067 <acquire>
801049b5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049be:	8b 40 14             	mov    0x14(%eax),%eax
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	50                   	push   %eax
801049c5:	e8 08 04 00 00       	call   80104dd2 <wakeup1>
801049ca:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049cd:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
801049d4:	eb 3c                	jmp    80104a12 <exit+0x110>
    if(p->parent == proc){
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 50 14             	mov    0x14(%eax),%edx
801049dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e2:	39 c2                	cmp    %eax,%edx
801049e4:	75 28                	jne    80104a0e <exit+0x10c>
      p->parent = initproc;
801049e6:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801049ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ef:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 40 0c             	mov    0xc(%eax),%eax
801049f8:	83 f8 05             	cmp    $0x5,%eax
801049fb:	75 11                	jne    80104a0e <exit+0x10c>
        wakeup1(initproc);
801049fd:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104a02:	83 ec 0c             	sub    $0xc,%esp
80104a05:	50                   	push   %eax
80104a06:	e8 c7 03 00 00       	call   80104dd2 <wakeup1>
80104a0b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a0e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a12:	81 7d f4 b4 49 11 80 	cmpl   $0x801149b4,-0xc(%ebp)
80104a19:	72 bb                	jb     801049d6 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a21:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a28:	e8 d5 01 00 00       	call   80104c02 <sched>
  panic("zombie exit");
80104a2d:	83 ec 0c             	sub    $0xc,%esp
80104a30:	68 ed 88 10 80       	push   $0x801088ed
80104a35:	e8 22 bb ff ff       	call   8010055c <panic>

80104a3a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a3a:	55                   	push   %ebp
80104a3b:	89 e5                	mov    %esp,%ebp
80104a3d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a40:	83 ec 0c             	sub    $0xc,%esp
80104a43:	68 80 2a 11 80       	push   $0x80112a80
80104a48:	e8 1a 06 00 00       	call   80105067 <acquire>
80104a4d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a57:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80104a5e:	e9 a6 00 00 00       	jmp    80104b09 <wait+0xcf>
      if(p->parent != proc)
80104a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a66:	8b 50 14             	mov    0x14(%eax),%edx
80104a69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6f:	39 c2                	cmp    %eax,%edx
80104a71:	74 05                	je     80104a78 <wait+0x3e>
        continue;
80104a73:	e9 8d 00 00 00       	jmp    80104b05 <wait+0xcb>
      havekids = 1;
80104a78:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a82:	8b 40 0c             	mov    0xc(%eax),%eax
80104a85:	83 f8 05             	cmp    $0x5,%eax
80104a88:	75 7b                	jne    80104b05 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8d:	8b 40 10             	mov    0x10(%eax),%eax
80104a90:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	8b 40 08             	mov    0x8(%eax),%eax
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	50                   	push   %eax
80104a9d:	e8 6a e1 ff ff       	call   80102c0c <kfree>
80104aa2:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab2:	8b 40 04             	mov    0x4(%eax),%eax
80104ab5:	83 ec 0c             	sub    $0xc,%esp
80104ab8:	50                   	push   %eax
80104ab9:	e8 2f 38 00 00       	call   801082ed <freevm>
80104abe:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ace:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104af0:	83 ec 0c             	sub    $0xc,%esp
80104af3:	68 80 2a 11 80       	push   $0x80112a80
80104af8:	e8 d0 05 00 00       	call   801050cd <release>
80104afd:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b03:	eb 57                	jmp    80104b5c <wait+0x122>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b05:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b09:	81 7d f4 b4 49 11 80 	cmpl   $0x801149b4,-0xc(%ebp)
80104b10:	0f 82 4d ff ff ff    	jb     80104a63 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b1a:	74 0d                	je     80104b29 <wait+0xef>
80104b1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b22:	8b 40 24             	mov    0x24(%eax),%eax
80104b25:	85 c0                	test   %eax,%eax
80104b27:	74 17                	je     80104b40 <wait+0x106>
      release(&ptable.lock);
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	68 80 2a 11 80       	push   $0x80112a80
80104b31:	e8 97 05 00 00       	call   801050cd <release>
80104b36:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3e:	eb 1c                	jmp    80104b5c <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b46:	83 ec 08             	sub    $0x8,%esp
80104b49:	68 80 2a 11 80       	push   $0x80112a80
80104b4e:	50                   	push   %eax
80104b4f:	e8 d3 01 00 00       	call   80104d27 <sleep>
80104b54:	83 c4 10             	add    $0x10,%esp
  }
80104b57:	e9 f4 fe ff ff       	jmp    80104a50 <wait+0x16>
}
80104b5c:	c9                   	leave  
80104b5d:	c3                   	ret    

80104b5e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b5e:	55                   	push   %ebp
80104b5f:	89 e5                	mov    %esp,%ebp
80104b61:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b64:	e8 23 f9 ff ff       	call   8010448c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	68 80 2a 11 80       	push   $0x80112a80
80104b71:	e8 f1 04 00 00       	call   80105067 <acquire>
80104b76:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b79:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80104b80:	eb 62                	jmp    80104be4 <scheduler+0x86>
      if(p->state != RUNNABLE)
80104b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b85:	8b 40 0c             	mov    0xc(%eax),%eax
80104b88:	83 f8 03             	cmp    $0x3,%eax
80104b8b:	74 02                	je     80104b8f <scheduler+0x31>
        continue;
80104b8d:	eb 51                	jmp    80104be0 <scheduler+0x82>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b92:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b98:	83 ec 0c             	sub    $0xc,%esp
80104b9b:	ff 75 f4             	pushl  -0xc(%ebp)
80104b9e:	e8 06 33 00 00       	call   80107ea9 <switchuvm>
80104ba3:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba9:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bb9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bc0:	83 c2 04             	add    $0x4,%edx
80104bc3:	83 ec 08             	sub    $0x8,%esp
80104bc6:	50                   	push   %eax
80104bc7:	52                   	push   %edx
80104bc8:	e8 6c 09 00 00       	call   80105539 <swtch>
80104bcd:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104bd0:	e8 b8 32 00 00       	call   80107e8d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104bd5:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bdc:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104be4:	81 7d f4 b4 49 11 80 	cmpl   $0x801149b4,-0xc(%ebp)
80104beb:	72 95                	jb     80104b82 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104bed:	83 ec 0c             	sub    $0xc,%esp
80104bf0:	68 80 2a 11 80       	push   $0x80112a80
80104bf5:	e8 d3 04 00 00       	call   801050cd <release>
80104bfa:	83 c4 10             	add    $0x10,%esp

  }
80104bfd:	e9 62 ff ff ff       	jmp    80104b64 <scheduler+0x6>

80104c02 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c02:	55                   	push   %ebp
80104c03:	89 e5                	mov    %esp,%ebp
80104c05:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c08:	83 ec 0c             	sub    $0xc,%esp
80104c0b:	68 80 2a 11 80       	push   $0x80112a80
80104c10:	e8 82 05 00 00       	call   80105197 <holding>
80104c15:	83 c4 10             	add    $0x10,%esp
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	75 0d                	jne    80104c29 <sched+0x27>
    panic("sched ptable.lock");
80104c1c:	83 ec 0c             	sub    $0xc,%esp
80104c1f:	68 f9 88 10 80       	push   $0x801088f9
80104c24:	e8 33 b9 ff ff       	call   8010055c <panic>
  if(cpu->ncli != 1)
80104c29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c2f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c35:	83 f8 01             	cmp    $0x1,%eax
80104c38:	74 0d                	je     80104c47 <sched+0x45>
    panic("sched locks");
80104c3a:	83 ec 0c             	sub    $0xc,%esp
80104c3d:	68 0b 89 10 80       	push   $0x8010890b
80104c42:	e8 15 b9 ff ff       	call   8010055c <panic>
  if(proc->state == RUNNING)
80104c47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c50:	83 f8 04             	cmp    $0x4,%eax
80104c53:	75 0d                	jne    80104c62 <sched+0x60>
    panic("sched running");
80104c55:	83 ec 0c             	sub    $0xc,%esp
80104c58:	68 17 89 10 80       	push   $0x80108917
80104c5d:	e8 fa b8 ff ff       	call   8010055c <panic>
  if(readeflags()&FL_IF)
80104c62:	e8 15 f8 ff ff       	call   8010447c <readeflags>
80104c67:	25 00 02 00 00       	and    $0x200,%eax
80104c6c:	85 c0                	test   %eax,%eax
80104c6e:	74 0d                	je     80104c7d <sched+0x7b>
    panic("sched interruptible");
80104c70:	83 ec 0c             	sub    $0xc,%esp
80104c73:	68 25 89 10 80       	push   $0x80108925
80104c78:	e8 df b8 ff ff       	call   8010055c <panic>
  intena = cpu->intena;
80104c7d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c83:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c8c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c92:	8b 40 04             	mov    0x4(%eax),%eax
80104c95:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c9c:	83 c2 1c             	add    $0x1c,%edx
80104c9f:	83 ec 08             	sub    $0x8,%esp
80104ca2:	50                   	push   %eax
80104ca3:	52                   	push   %edx
80104ca4:	e8 90 08 00 00       	call   80105539 <swtch>
80104ca9:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb5:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cbb:	c9                   	leave  
80104cbc:	c3                   	ret    

80104cbd <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cbd:	55                   	push   %ebp
80104cbe:	89 e5                	mov    %esp,%ebp
80104cc0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	68 80 2a 11 80       	push   $0x80112a80
80104ccb:	e8 97 03 00 00       	call   80105067 <acquire>
80104cd0:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104cd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ce0:	e8 1d ff ff ff       	call   80104c02 <sched>
  release(&ptable.lock);
80104ce5:	83 ec 0c             	sub    $0xc,%esp
80104ce8:	68 80 2a 11 80       	push   $0x80112a80
80104ced:	e8 db 03 00 00       	call   801050cd <release>
80104cf2:	83 c4 10             	add    $0x10,%esp
}
80104cf5:	c9                   	leave  
80104cf6:	c3                   	ret    

80104cf7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104cf7:	55                   	push   %ebp
80104cf8:	89 e5                	mov    %esp,%ebp
80104cfa:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104cfd:	83 ec 0c             	sub    $0xc,%esp
80104d00:	68 80 2a 11 80       	push   $0x80112a80
80104d05:	e8 c3 03 00 00       	call   801050cd <release>
80104d0a:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d0d:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d12:	85 c0                	test   %eax,%eax
80104d14:	74 0f                	je     80104d25 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d16:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d1d:	00 00 00 
    initlog();
80104d20:	e8 43 e6 ff ff       	call   80103368 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d25:	c9                   	leave  
80104d26:	c3                   	ret    

80104d27 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d33:	85 c0                	test   %eax,%eax
80104d35:	75 0d                	jne    80104d44 <sleep+0x1d>
    panic("sleep");
80104d37:	83 ec 0c             	sub    $0xc,%esp
80104d3a:	68 39 89 10 80       	push   $0x80108939
80104d3f:	e8 18 b8 ff ff       	call   8010055c <panic>

  if(lk == 0)
80104d44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d48:	75 0d                	jne    80104d57 <sleep+0x30>
    panic("sleep without lk");
80104d4a:	83 ec 0c             	sub    $0xc,%esp
80104d4d:	68 3f 89 10 80       	push   $0x8010893f
80104d52:	e8 05 b8 ff ff       	call   8010055c <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d57:	81 7d 0c 80 2a 11 80 	cmpl   $0x80112a80,0xc(%ebp)
80104d5e:	74 1e                	je     80104d7e <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d60:	83 ec 0c             	sub    $0xc,%esp
80104d63:	68 80 2a 11 80       	push   $0x80112a80
80104d68:	e8 fa 02 00 00       	call   80105067 <acquire>
80104d6d:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d70:	83 ec 0c             	sub    $0xc,%esp
80104d73:	ff 75 0c             	pushl  0xc(%ebp)
80104d76:	e8 52 03 00 00       	call   801050cd <release>
80104d7b:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104d7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d84:	8b 55 08             	mov    0x8(%ebp),%edx
80104d87:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d90:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d97:	e8 66 fe ff ff       	call   80104c02 <sched>

  // Tidy up.
  proc->chan = 0;
80104d9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104da9:	81 7d 0c 80 2a 11 80 	cmpl   $0x80112a80,0xc(%ebp)
80104db0:	74 1e                	je     80104dd0 <sleep+0xa9>
    release(&ptable.lock);
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	68 80 2a 11 80       	push   $0x80112a80
80104dba:	e8 0e 03 00 00       	call   801050cd <release>
80104dbf:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104dc2:	83 ec 0c             	sub    $0xc,%esp
80104dc5:	ff 75 0c             	pushl  0xc(%ebp)
80104dc8:	e8 9a 02 00 00       	call   80105067 <acquire>
80104dcd:	83 c4 10             	add    $0x10,%esp
  }
}
80104dd0:	c9                   	leave  
80104dd1:	c3                   	ret    

80104dd2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104dd2:	55                   	push   %ebp
80104dd3:	89 e5                	mov    %esp,%ebp
80104dd5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dd8:	c7 45 fc b4 2a 11 80 	movl   $0x80112ab4,-0x4(%ebp)
80104ddf:	eb 24                	jmp    80104e05 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104de1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de4:	8b 40 0c             	mov    0xc(%eax),%eax
80104de7:	83 f8 02             	cmp    $0x2,%eax
80104dea:	75 15                	jne    80104e01 <wakeup1+0x2f>
80104dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104def:	8b 40 20             	mov    0x20(%eax),%eax
80104df2:	3b 45 08             	cmp    0x8(%ebp),%eax
80104df5:	75 0a                	jne    80104e01 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104df7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e01:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e05:	81 7d fc b4 49 11 80 	cmpl   $0x801149b4,-0x4(%ebp)
80104e0c:	72 d3                	jb     80104de1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e0e:	c9                   	leave  
80104e0f:	c3                   	ret    

80104e10 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e16:	83 ec 0c             	sub    $0xc,%esp
80104e19:	68 80 2a 11 80       	push   $0x80112a80
80104e1e:	e8 44 02 00 00       	call   80105067 <acquire>
80104e23:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e26:	83 ec 0c             	sub    $0xc,%esp
80104e29:	ff 75 08             	pushl  0x8(%ebp)
80104e2c:	e8 a1 ff ff ff       	call   80104dd2 <wakeup1>
80104e31:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e34:	83 ec 0c             	sub    $0xc,%esp
80104e37:	68 80 2a 11 80       	push   $0x80112a80
80104e3c:	e8 8c 02 00 00       	call   801050cd <release>
80104e41:	83 c4 10             	add    $0x10,%esp
}
80104e44:	c9                   	leave  
80104e45:	c3                   	ret    

80104e46 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e46:	55                   	push   %ebp
80104e47:	89 e5                	mov    %esp,%ebp
80104e49:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	68 80 2a 11 80       	push   $0x80112a80
80104e54:	e8 0e 02 00 00       	call   80105067 <acquire>
80104e59:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e5c:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80104e63:	eb 45                	jmp    80104eaa <kill+0x64>
    if(p->pid == pid){
80104e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e68:	8b 40 10             	mov    0x10(%eax),%eax
80104e6b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e6e:	75 36                	jne    80104ea6 <kill+0x60>
      p->killed = 1;
80104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e73:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e80:	83 f8 02             	cmp    $0x2,%eax
80104e83:	75 0a                	jne    80104e8f <kill+0x49>
        p->state = RUNNABLE;
80104e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e88:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e8f:	83 ec 0c             	sub    $0xc,%esp
80104e92:	68 80 2a 11 80       	push   $0x80112a80
80104e97:	e8 31 02 00 00       	call   801050cd <release>
80104e9c:	83 c4 10             	add    $0x10,%esp
      return 0;
80104e9f:	b8 00 00 00 00       	mov    $0x0,%eax
80104ea4:	eb 22                	jmp    80104ec8 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea6:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104eaa:	81 7d f4 b4 49 11 80 	cmpl   $0x801149b4,-0xc(%ebp)
80104eb1:	72 b2                	jb     80104e65 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104eb3:	83 ec 0c             	sub    $0xc,%esp
80104eb6:	68 80 2a 11 80       	push   $0x80112a80
80104ebb:	e8 0d 02 00 00       	call   801050cd <release>
80104ec0:	83 c4 10             	add    $0x10,%esp
  return -1;
80104ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec8:	c9                   	leave  
80104ec9:	c3                   	ret    

80104eca <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104eca:	55                   	push   %ebp
80104ecb:	89 e5                	mov    %esp,%ebp
80104ecd:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed0:	c7 45 f0 b4 2a 11 80 	movl   $0x80112ab4,-0x10(%ebp)
80104ed7:	e9 d5 00 00 00       	jmp    80104fb1 <procdump+0xe7>
    if(p->state == UNUSED)
80104edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee2:	85 c0                	test   %eax,%eax
80104ee4:	75 05                	jne    80104eeb <procdump+0x21>
      continue;
80104ee6:	e9 c2 00 00 00       	jmp    80104fad <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eee:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef1:	83 f8 05             	cmp    $0x5,%eax
80104ef4:	77 23                	ja     80104f19 <procdump+0x4f>
80104ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef9:	8b 40 0c             	mov    0xc(%eax),%eax
80104efc:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f03:	85 c0                	test   %eax,%eax
80104f05:	74 12                	je     80104f19 <procdump+0x4f>
      state = states[p->state];
80104f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f0d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f14:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f17:	eb 07                	jmp    80104f20 <procdump+0x56>
    else
      state = "???";
80104f19:	c7 45 ec 50 89 10 80 	movl   $0x80108950,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f23:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f29:	8b 40 10             	mov    0x10(%eax),%eax
80104f2c:	52                   	push   %edx
80104f2d:	ff 75 ec             	pushl  -0x14(%ebp)
80104f30:	50                   	push   %eax
80104f31:	68 54 89 10 80       	push   $0x80108954
80104f36:	e8 84 b4 ff ff       	call   801003bf <cprintf>
80104f3b:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f41:	8b 40 0c             	mov    0xc(%eax),%eax
80104f44:	83 f8 02             	cmp    $0x2,%eax
80104f47:	75 54                	jne    80104f9d <procdump+0xd3>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f52:	83 c0 08             	add    $0x8,%eax
80104f55:	89 c2                	mov    %eax,%edx
80104f57:	83 ec 08             	sub    $0x8,%esp
80104f5a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f5d:	50                   	push   %eax
80104f5e:	52                   	push   %edx
80104f5f:	e8 ba 01 00 00       	call   8010511e <getcallerpcs>
80104f64:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f6e:	eb 1c                	jmp    80104f8c <procdump+0xc2>
        cprintf(" %p", pc[i]);
80104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f73:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f77:	83 ec 08             	sub    $0x8,%esp
80104f7a:	50                   	push   %eax
80104f7b:	68 5d 89 10 80       	push   $0x8010895d
80104f80:	e8 3a b4 ff ff       	call   801003bf <cprintf>
80104f85:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f8c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f90:	7f 0b                	jg     80104f9d <procdump+0xd3>
80104f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f95:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	75 d3                	jne    80104f70 <procdump+0xa6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f9d:	83 ec 0c             	sub    $0xc,%esp
80104fa0:	68 61 89 10 80       	push   $0x80108961
80104fa5:	e8 15 b4 ff ff       	call   801003bf <cprintf>
80104faa:	83 c4 10             	add    $0x10,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fad:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104fb1:	81 7d f0 b4 49 11 80 	cmpl   $0x801149b4,-0x10(%ebp)
80104fb8:	0f 82 1e ff ff ff    	jb     80104edc <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fbe:	c9                   	leave  
80104fbf:	c3                   	ret    

80104fc0 <procfsisdir>:
#include "mmu.h"
#include "proc.h"
#include "x86.h"

int 
procfsisdir(struct inode *ip) {
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
  return 0;
80104fc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fc8:	5d                   	pop    %ebp
80104fc9:	c3                   	ret    

80104fca <procfsiread>:

void 
procfsiread(struct inode* dp, struct inode *ip) {
80104fca:	55                   	push   %ebp
80104fcb:	89 e5                	mov    %esp,%ebp
}
80104fcd:	5d                   	pop    %ebp
80104fce:	c3                   	ret    

80104fcf <procfsread>:

int
procfsread(struct inode *ip, char *dst, int off, int n) {
80104fcf:	55                   	push   %ebp
80104fd0:	89 e5                	mov    %esp,%ebp
  return 0;
80104fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fd7:	5d                   	pop    %ebp
80104fd8:	c3                   	ret    

80104fd9 <procfswrite>:

int
procfswrite(struct inode *ip, char *buf, int n)
{
80104fd9:	55                   	push   %ebp
80104fda:	89 e5                	mov    %esp,%ebp
  return 0;
80104fdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fe1:	5d                   	pop    %ebp
80104fe2:	c3                   	ret    

80104fe3 <procfsinit>:

void
procfsinit(void)
{
80104fe3:	55                   	push   %ebp
80104fe4:	89 e5                	mov    %esp,%ebp
  devsw[PROCFS].isdir = procfsisdir;
80104fe6:	c7 05 60 12 11 80 c0 	movl   $0x80104fc0,0x80111260
80104fed:	4f 10 80 
  devsw[PROCFS].iread = procfsiread;
80104ff0:	c7 05 64 12 11 80 ca 	movl   $0x80104fca,0x80111264
80104ff7:	4f 10 80 
  devsw[PROCFS].write = procfswrite;
80104ffa:	c7 05 6c 12 11 80 d9 	movl   $0x80104fd9,0x8011126c
80105001:	4f 10 80 
  devsw[PROCFS].read = procfsread;
80105004:	c7 05 68 12 11 80 cf 	movl   $0x80104fcf,0x80111268
8010500b:	4f 10 80 
}
8010500e:	5d                   	pop    %ebp
8010500f:	c3                   	ret    

80105010 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105010:	55                   	push   %ebp
80105011:	89 e5                	mov    %esp,%ebp
80105013:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105016:	9c                   	pushf  
80105017:	58                   	pop    %eax
80105018:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010501b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010501e:	c9                   	leave  
8010501f:	c3                   	ret    

80105020 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105020:	55                   	push   %ebp
80105021:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105023:	fa                   	cli    
}
80105024:	5d                   	pop    %ebp
80105025:	c3                   	ret    

80105026 <sti>:

static inline void
sti(void)
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105029:	fb                   	sti    
}
8010502a:	5d                   	pop    %ebp
8010502b:	c3                   	ret    

8010502c <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010502c:	55                   	push   %ebp
8010502d:	89 e5                	mov    %esp,%ebp
8010502f:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105032:	8b 55 08             	mov    0x8(%ebp),%edx
80105035:	8b 45 0c             	mov    0xc(%ebp),%eax
80105038:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010503b:	f0 87 02             	lock xchg %eax,(%edx)
8010503e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105041:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105044:	c9                   	leave  
80105045:	c3                   	ret    

80105046 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105046:	55                   	push   %ebp
80105047:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105049:	8b 45 08             	mov    0x8(%ebp),%eax
8010504c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010504f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105052:	8b 45 08             	mov    0x8(%ebp),%eax
80105055:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010505b:	8b 45 08             	mov    0x8(%ebp),%eax
8010505e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105065:	5d                   	pop    %ebp
80105066:	c3                   	ret    

80105067 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010506d:	e8 4f 01 00 00       	call   801051c1 <pushcli>
  if(holding(lk))
80105072:	8b 45 08             	mov    0x8(%ebp),%eax
80105075:	83 ec 0c             	sub    $0xc,%esp
80105078:	50                   	push   %eax
80105079:	e8 19 01 00 00       	call   80105197 <holding>
8010507e:	83 c4 10             	add    $0x10,%esp
80105081:	85 c0                	test   %eax,%eax
80105083:	74 0d                	je     80105092 <acquire+0x2b>
    panic("acquire");
80105085:	83 ec 0c             	sub    $0xc,%esp
80105088:	68 8d 89 10 80       	push   $0x8010898d
8010508d:	e8 ca b4 ff ff       	call   8010055c <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105092:	90                   	nop
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	83 ec 08             	sub    $0x8,%esp
80105099:	6a 01                	push   $0x1
8010509b:	50                   	push   %eax
8010509c:	e8 8b ff ff ff       	call   8010502c <xchg>
801050a1:	83 c4 10             	add    $0x10,%esp
801050a4:	85 c0                	test   %eax,%eax
801050a6:	75 eb                	jne    80105093 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050a8:	8b 45 08             	mov    0x8(%ebp),%eax
801050ab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050b2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050b5:	8b 45 08             	mov    0x8(%ebp),%eax
801050b8:	83 c0 0c             	add    $0xc,%eax
801050bb:	83 ec 08             	sub    $0x8,%esp
801050be:	50                   	push   %eax
801050bf:	8d 45 08             	lea    0x8(%ebp),%eax
801050c2:	50                   	push   %eax
801050c3:	e8 56 00 00 00       	call   8010511e <getcallerpcs>
801050c8:	83 c4 10             	add    $0x10,%esp
}
801050cb:	c9                   	leave  
801050cc:	c3                   	ret    

801050cd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050cd:	55                   	push   %ebp
801050ce:	89 e5                	mov    %esp,%ebp
801050d0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050d3:	83 ec 0c             	sub    $0xc,%esp
801050d6:	ff 75 08             	pushl  0x8(%ebp)
801050d9:	e8 b9 00 00 00       	call   80105197 <holding>
801050de:	83 c4 10             	add    $0x10,%esp
801050e1:	85 c0                	test   %eax,%eax
801050e3:	75 0d                	jne    801050f2 <release+0x25>
    panic("release");
801050e5:	83 ec 0c             	sub    $0xc,%esp
801050e8:	68 95 89 10 80       	push   $0x80108995
801050ed:	e8 6a b4 ff ff       	call   8010055c <panic>

  lk->pcs[0] = 0;
801050f2:	8b 45 08             	mov    0x8(%ebp),%eax
801050f5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050fc:	8b 45 08             	mov    0x8(%ebp),%eax
801050ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	83 ec 08             	sub    $0x8,%esp
8010510c:	6a 00                	push   $0x0
8010510e:	50                   	push   %eax
8010510f:	e8 18 ff ff ff       	call   8010502c <xchg>
80105114:	83 c4 10             	add    $0x10,%esp

  popcli();
80105117:	e8 e9 00 00 00       	call   80105205 <popcli>
}
8010511c:	c9                   	leave  
8010511d:	c3                   	ret    

8010511e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010511e:	55                   	push   %ebp
8010511f:	89 e5                	mov    %esp,%ebp
80105121:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	83 e8 08             	sub    $0x8,%eax
8010512a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010512d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105134:	eb 38                	jmp    8010516e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105136:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010513a:	74 38                	je     80105174 <getcallerpcs+0x56>
8010513c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105143:	76 2f                	jbe    80105174 <getcallerpcs+0x56>
80105145:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105149:	74 29                	je     80105174 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010514b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010514e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105155:	8b 45 0c             	mov    0xc(%ebp),%eax
80105158:	01 c2                	add    %eax,%edx
8010515a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010515d:	8b 40 04             	mov    0x4(%eax),%eax
80105160:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105162:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105165:	8b 00                	mov    (%eax),%eax
80105167:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010516a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105172:	7e c2                	jle    80105136 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105174:	eb 19                	jmp    8010518f <getcallerpcs+0x71>
    pcs[i] = 0;
80105176:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105179:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105180:	8b 45 0c             	mov    0xc(%ebp),%eax
80105183:	01 d0                	add    %edx,%eax
80105185:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010518b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010518f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105193:	7e e1                	jle    80105176 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105195:	c9                   	leave  
80105196:	c3                   	ret    

80105197 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105197:	55                   	push   %ebp
80105198:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010519a:	8b 45 08             	mov    0x8(%ebp),%eax
8010519d:	8b 00                	mov    (%eax),%eax
8010519f:	85 c0                	test   %eax,%eax
801051a1:	74 17                	je     801051ba <holding+0x23>
801051a3:	8b 45 08             	mov    0x8(%ebp),%eax
801051a6:	8b 50 08             	mov    0x8(%eax),%edx
801051a9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051af:	39 c2                	cmp    %eax,%edx
801051b1:	75 07                	jne    801051ba <holding+0x23>
801051b3:	b8 01 00 00 00       	mov    $0x1,%eax
801051b8:	eb 05                	jmp    801051bf <holding+0x28>
801051ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051bf:	5d                   	pop    %ebp
801051c0:	c3                   	ret    

801051c1 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051c7:	e8 44 fe ff ff       	call   80105010 <readeflags>
801051cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051cf:	e8 4c fe ff ff       	call   80105020 <cli>
  if(cpu->ncli++ == 0)
801051d4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051db:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051e1:	8d 48 01             	lea    0x1(%eax),%ecx
801051e4:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801051ea:	85 c0                	test   %eax,%eax
801051ec:	75 15                	jne    80105203 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801051ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051f7:	81 e2 00 02 00 00    	and    $0x200,%edx
801051fd:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105203:	c9                   	leave  
80105204:	c3                   	ret    

80105205 <popcli>:

void
popcli(void)
{
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
80105208:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010520b:	e8 00 fe ff ff       	call   80105010 <readeflags>
80105210:	25 00 02 00 00       	and    $0x200,%eax
80105215:	85 c0                	test   %eax,%eax
80105217:	74 0d                	je     80105226 <popcli+0x21>
    panic("popcli - interruptible");
80105219:	83 ec 0c             	sub    $0xc,%esp
8010521c:	68 9d 89 10 80       	push   $0x8010899d
80105221:	e8 36 b3 ff ff       	call   8010055c <panic>
  if(--cpu->ncli < 0)
80105226:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010522c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105232:	83 ea 01             	sub    $0x1,%edx
80105235:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010523b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105241:	85 c0                	test   %eax,%eax
80105243:	79 0d                	jns    80105252 <popcli+0x4d>
    panic("popcli");
80105245:	83 ec 0c             	sub    $0xc,%esp
80105248:	68 b4 89 10 80       	push   $0x801089b4
8010524d:	e8 0a b3 ff ff       	call   8010055c <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105252:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105258:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010525e:	85 c0                	test   %eax,%eax
80105260:	75 15                	jne    80105277 <popcli+0x72>
80105262:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105268:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010526e:	85 c0                	test   %eax,%eax
80105270:	74 05                	je     80105277 <popcli+0x72>
    sti();
80105272:	e8 af fd ff ff       	call   80105026 <sti>
}
80105277:	c9                   	leave  
80105278:	c3                   	ret    

80105279 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105279:	55                   	push   %ebp
8010527a:	89 e5                	mov    %esp,%ebp
8010527c:	57                   	push   %edi
8010527d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010527e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105281:	8b 55 10             	mov    0x10(%ebp),%edx
80105284:	8b 45 0c             	mov    0xc(%ebp),%eax
80105287:	89 cb                	mov    %ecx,%ebx
80105289:	89 df                	mov    %ebx,%edi
8010528b:	89 d1                	mov    %edx,%ecx
8010528d:	fc                   	cld    
8010528e:	f3 aa                	rep stos %al,%es:(%edi)
80105290:	89 ca                	mov    %ecx,%edx
80105292:	89 fb                	mov    %edi,%ebx
80105294:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105297:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010529a:	5b                   	pop    %ebx
8010529b:	5f                   	pop    %edi
8010529c:	5d                   	pop    %ebp
8010529d:	c3                   	ret    

8010529e <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010529e:	55                   	push   %ebp
8010529f:	89 e5                	mov    %esp,%ebp
801052a1:	57                   	push   %edi
801052a2:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a6:	8b 55 10             	mov    0x10(%ebp),%edx
801052a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ac:	89 cb                	mov    %ecx,%ebx
801052ae:	89 df                	mov    %ebx,%edi
801052b0:	89 d1                	mov    %edx,%ecx
801052b2:	fc                   	cld    
801052b3:	f3 ab                	rep stos %eax,%es:(%edi)
801052b5:	89 ca                	mov    %ecx,%edx
801052b7:	89 fb                	mov    %edi,%ebx
801052b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052bc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052bf:	5b                   	pop    %ebx
801052c0:	5f                   	pop    %edi
801052c1:	5d                   	pop    %ebp
801052c2:	c3                   	ret    

801052c3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052c6:	8b 45 08             	mov    0x8(%ebp),%eax
801052c9:	83 e0 03             	and    $0x3,%eax
801052cc:	85 c0                	test   %eax,%eax
801052ce:	75 43                	jne    80105313 <memset+0x50>
801052d0:	8b 45 10             	mov    0x10(%ebp),%eax
801052d3:	83 e0 03             	and    $0x3,%eax
801052d6:	85 c0                	test   %eax,%eax
801052d8:	75 39                	jne    80105313 <memset+0x50>
    c &= 0xFF;
801052da:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052e1:	8b 45 10             	mov    0x10(%ebp),%eax
801052e4:	c1 e8 02             	shr    $0x2,%eax
801052e7:	89 c1                	mov    %eax,%ecx
801052e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ec:	c1 e0 18             	shl    $0x18,%eax
801052ef:	89 c2                	mov    %eax,%edx
801052f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f4:	c1 e0 10             	shl    $0x10,%eax
801052f7:	09 c2                	or     %eax,%edx
801052f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052fc:	c1 e0 08             	shl    $0x8,%eax
801052ff:	09 d0                	or     %edx,%eax
80105301:	0b 45 0c             	or     0xc(%ebp),%eax
80105304:	51                   	push   %ecx
80105305:	50                   	push   %eax
80105306:	ff 75 08             	pushl  0x8(%ebp)
80105309:	e8 90 ff ff ff       	call   8010529e <stosl>
8010530e:	83 c4 0c             	add    $0xc,%esp
80105311:	eb 12                	jmp    80105325 <memset+0x62>
  } else
    stosb(dst, c, n);
80105313:	8b 45 10             	mov    0x10(%ebp),%eax
80105316:	50                   	push   %eax
80105317:	ff 75 0c             	pushl  0xc(%ebp)
8010531a:	ff 75 08             	pushl  0x8(%ebp)
8010531d:	e8 57 ff ff ff       	call   80105279 <stosb>
80105322:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105325:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105328:	c9                   	leave  
80105329:	c3                   	ret    

8010532a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010532a:	55                   	push   %ebp
8010532b:	89 e5                	mov    %esp,%ebp
8010532d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105330:	8b 45 08             	mov    0x8(%ebp),%eax
80105333:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105336:	8b 45 0c             	mov    0xc(%ebp),%eax
80105339:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010533c:	eb 30                	jmp    8010536e <memcmp+0x44>
    if(*s1 != *s2)
8010533e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105341:	0f b6 10             	movzbl (%eax),%edx
80105344:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105347:	0f b6 00             	movzbl (%eax),%eax
8010534a:	38 c2                	cmp    %al,%dl
8010534c:	74 18                	je     80105366 <memcmp+0x3c>
      return *s1 - *s2;
8010534e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105351:	0f b6 00             	movzbl (%eax),%eax
80105354:	0f b6 d0             	movzbl %al,%edx
80105357:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535a:	0f b6 00             	movzbl (%eax),%eax
8010535d:	0f b6 c0             	movzbl %al,%eax
80105360:	29 c2                	sub    %eax,%edx
80105362:	89 d0                	mov    %edx,%eax
80105364:	eb 1a                	jmp    80105380 <memcmp+0x56>
    s1++, s2++;
80105366:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010536a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010536e:	8b 45 10             	mov    0x10(%ebp),%eax
80105371:	8d 50 ff             	lea    -0x1(%eax),%edx
80105374:	89 55 10             	mov    %edx,0x10(%ebp)
80105377:	85 c0                	test   %eax,%eax
80105379:	75 c3                	jne    8010533e <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010537b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105380:	c9                   	leave  
80105381:	c3                   	ret    

80105382 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105382:	55                   	push   %ebp
80105383:	89 e5                	mov    %esp,%ebp
80105385:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105388:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105394:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105397:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010539a:	73 3d                	jae    801053d9 <memmove+0x57>
8010539c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010539f:	8b 45 10             	mov    0x10(%ebp),%eax
801053a2:	01 d0                	add    %edx,%eax
801053a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053a7:	76 30                	jbe    801053d9 <memmove+0x57>
    s += n;
801053a9:	8b 45 10             	mov    0x10(%ebp),%eax
801053ac:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053af:	8b 45 10             	mov    0x10(%ebp),%eax
801053b2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053b5:	eb 13                	jmp    801053ca <memmove+0x48>
      *--d = *--s;
801053b7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053bb:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c2:	0f b6 10             	movzbl (%eax),%edx
801053c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c8:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801053ca:	8b 45 10             	mov    0x10(%ebp),%eax
801053cd:	8d 50 ff             	lea    -0x1(%eax),%edx
801053d0:	89 55 10             	mov    %edx,0x10(%ebp)
801053d3:	85 c0                	test   %eax,%eax
801053d5:	75 e0                	jne    801053b7 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801053d7:	eb 26                	jmp    801053ff <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053d9:	eb 17                	jmp    801053f2 <memmove+0x70>
      *d++ = *s++;
801053db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053de:	8d 50 01             	lea    0x1(%eax),%edx
801053e1:	89 55 f8             	mov    %edx,-0x8(%ebp)
801053e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053e7:	8d 4a 01             	lea    0x1(%edx),%ecx
801053ea:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801053ed:	0f b6 12             	movzbl (%edx),%edx
801053f0:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053f2:	8b 45 10             	mov    0x10(%ebp),%eax
801053f5:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f8:	89 55 10             	mov    %edx,0x10(%ebp)
801053fb:	85 c0                	test   %eax,%eax
801053fd:	75 dc                	jne    801053db <memmove+0x59>
      *d++ = *s++;

  return dst;
801053ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105402:	c9                   	leave  
80105403:	c3                   	ret    

80105404 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105404:	55                   	push   %ebp
80105405:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105407:	ff 75 10             	pushl  0x10(%ebp)
8010540a:	ff 75 0c             	pushl  0xc(%ebp)
8010540d:	ff 75 08             	pushl  0x8(%ebp)
80105410:	e8 6d ff ff ff       	call   80105382 <memmove>
80105415:	83 c4 0c             	add    $0xc,%esp
}
80105418:	c9                   	leave  
80105419:	c3                   	ret    

8010541a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010541a:	55                   	push   %ebp
8010541b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010541d:	eb 0c                	jmp    8010542b <strncmp+0x11>
    n--, p++, q++;
8010541f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105423:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105427:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010542b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010542f:	74 1a                	je     8010544b <strncmp+0x31>
80105431:	8b 45 08             	mov    0x8(%ebp),%eax
80105434:	0f b6 00             	movzbl (%eax),%eax
80105437:	84 c0                	test   %al,%al
80105439:	74 10                	je     8010544b <strncmp+0x31>
8010543b:	8b 45 08             	mov    0x8(%ebp),%eax
8010543e:	0f b6 10             	movzbl (%eax),%edx
80105441:	8b 45 0c             	mov    0xc(%ebp),%eax
80105444:	0f b6 00             	movzbl (%eax),%eax
80105447:	38 c2                	cmp    %al,%dl
80105449:	74 d4                	je     8010541f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010544b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010544f:	75 07                	jne    80105458 <strncmp+0x3e>
    return 0;
80105451:	b8 00 00 00 00       	mov    $0x0,%eax
80105456:	eb 16                	jmp    8010546e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105458:	8b 45 08             	mov    0x8(%ebp),%eax
8010545b:	0f b6 00             	movzbl (%eax),%eax
8010545e:	0f b6 d0             	movzbl %al,%edx
80105461:	8b 45 0c             	mov    0xc(%ebp),%eax
80105464:	0f b6 00             	movzbl (%eax),%eax
80105467:	0f b6 c0             	movzbl %al,%eax
8010546a:	29 c2                	sub    %eax,%edx
8010546c:	89 d0                	mov    %edx,%eax
}
8010546e:	5d                   	pop    %ebp
8010546f:	c3                   	ret    

80105470 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105470:	55                   	push   %ebp
80105471:	89 e5                	mov    %esp,%ebp
80105473:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105476:	8b 45 08             	mov    0x8(%ebp),%eax
80105479:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010547c:	90                   	nop
8010547d:	8b 45 10             	mov    0x10(%ebp),%eax
80105480:	8d 50 ff             	lea    -0x1(%eax),%edx
80105483:	89 55 10             	mov    %edx,0x10(%ebp)
80105486:	85 c0                	test   %eax,%eax
80105488:	7e 1e                	jle    801054a8 <strncpy+0x38>
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	8d 50 01             	lea    0x1(%eax),%edx
80105490:	89 55 08             	mov    %edx,0x8(%ebp)
80105493:	8b 55 0c             	mov    0xc(%ebp),%edx
80105496:	8d 4a 01             	lea    0x1(%edx),%ecx
80105499:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010549c:	0f b6 12             	movzbl (%edx),%edx
8010549f:	88 10                	mov    %dl,(%eax)
801054a1:	0f b6 00             	movzbl (%eax),%eax
801054a4:	84 c0                	test   %al,%al
801054a6:	75 d5                	jne    8010547d <strncpy+0xd>
    ;
  while(n-- > 0)
801054a8:	eb 0c                	jmp    801054b6 <strncpy+0x46>
    *s++ = 0;
801054aa:	8b 45 08             	mov    0x8(%ebp),%eax
801054ad:	8d 50 01             	lea    0x1(%eax),%edx
801054b0:	89 55 08             	mov    %edx,0x8(%ebp)
801054b3:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801054b6:	8b 45 10             	mov    0x10(%ebp),%eax
801054b9:	8d 50 ff             	lea    -0x1(%eax),%edx
801054bc:	89 55 10             	mov    %edx,0x10(%ebp)
801054bf:	85 c0                	test   %eax,%eax
801054c1:	7f e7                	jg     801054aa <strncpy+0x3a>
    *s++ = 0;
  return os;
801054c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c6:	c9                   	leave  
801054c7:	c3                   	ret    

801054c8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054c8:	55                   	push   %ebp
801054c9:	89 e5                	mov    %esp,%ebp
801054cb:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ce:	8b 45 08             	mov    0x8(%ebp),%eax
801054d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d8:	7f 05                	jg     801054df <safestrcpy+0x17>
    return os;
801054da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dd:	eb 31                	jmp    80105510 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054df:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054e7:	7e 1e                	jle    80105507 <safestrcpy+0x3f>
801054e9:	8b 45 08             	mov    0x8(%ebp),%eax
801054ec:	8d 50 01             	lea    0x1(%eax),%edx
801054ef:	89 55 08             	mov    %edx,0x8(%ebp)
801054f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801054f5:	8d 4a 01             	lea    0x1(%edx),%ecx
801054f8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054fb:	0f b6 12             	movzbl (%edx),%edx
801054fe:	88 10                	mov    %dl,(%eax)
80105500:	0f b6 00             	movzbl (%eax),%eax
80105503:	84 c0                	test   %al,%al
80105505:	75 d8                	jne    801054df <safestrcpy+0x17>
    ;
  *s = 0;
80105507:	8b 45 08             	mov    0x8(%ebp),%eax
8010550a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010550d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105510:	c9                   	leave  
80105511:	c3                   	ret    

80105512 <strlen>:

int
strlen(const char *s)
{
80105512:	55                   	push   %ebp
80105513:	89 e5                	mov    %esp,%ebp
80105515:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105518:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010551f:	eb 04                	jmp    80105525 <strlen+0x13>
80105521:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105525:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105528:	8b 45 08             	mov    0x8(%ebp),%eax
8010552b:	01 d0                	add    %edx,%eax
8010552d:	0f b6 00             	movzbl (%eax),%eax
80105530:	84 c0                	test   %al,%al
80105532:	75 ed                	jne    80105521 <strlen+0xf>
    ;
  return n;
80105534:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105537:	c9                   	leave  
80105538:	c3                   	ret    

80105539 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105539:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010553d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105541:	55                   	push   %ebp
  pushl %ebx
80105542:	53                   	push   %ebx
  pushl %esi
80105543:	56                   	push   %esi
  pushl %edi
80105544:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105545:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105547:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105549:	5f                   	pop    %edi
  popl %esi
8010554a:	5e                   	pop    %esi
  popl %ebx
8010554b:	5b                   	pop    %ebx
  popl %ebp
8010554c:	5d                   	pop    %ebp
  ret
8010554d:	c3                   	ret    

8010554e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010554e:	55                   	push   %ebp
8010554f:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105557:	8b 00                	mov    (%eax),%eax
80105559:	3b 45 08             	cmp    0x8(%ebp),%eax
8010555c:	76 12                	jbe    80105570 <fetchint+0x22>
8010555e:	8b 45 08             	mov    0x8(%ebp),%eax
80105561:	8d 50 04             	lea    0x4(%eax),%edx
80105564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556a:	8b 00                	mov    (%eax),%eax
8010556c:	39 c2                	cmp    %eax,%edx
8010556e:	76 07                	jbe    80105577 <fetchint+0x29>
    return -1;
80105570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105575:	eb 0f                	jmp    80105586 <fetchint+0x38>
  *ip = *(int*)(addr);
80105577:	8b 45 08             	mov    0x8(%ebp),%eax
8010557a:	8b 10                	mov    (%eax),%edx
8010557c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557f:	89 10                	mov    %edx,(%eax)
  return 0;
80105581:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105586:	5d                   	pop    %ebp
80105587:	c3                   	ret    

80105588 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105588:	55                   	push   %ebp
80105589:	89 e5                	mov    %esp,%ebp
8010558b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010558e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105594:	8b 00                	mov    (%eax),%eax
80105596:	3b 45 08             	cmp    0x8(%ebp),%eax
80105599:	77 07                	ja     801055a2 <fetchstr+0x1a>
    return -1;
8010559b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a0:	eb 46                	jmp    801055e8 <fetchstr+0x60>
  *pp = (char*)addr;
801055a2:	8b 55 08             	mov    0x8(%ebp),%edx
801055a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a8:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b0:	8b 00                	mov    (%eax),%eax
801055b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b8:	8b 00                	mov    (%eax),%eax
801055ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055bd:	eb 1c                	jmp    801055db <fetchstr+0x53>
    if(*s == 0)
801055bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c2:	0f b6 00             	movzbl (%eax),%eax
801055c5:	84 c0                	test   %al,%al
801055c7:	75 0e                	jne    801055d7 <fetchstr+0x4f>
      return s - *pp;
801055c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cf:	8b 00                	mov    (%eax),%eax
801055d1:	29 c2                	sub    %eax,%edx
801055d3:	89 d0                	mov    %edx,%eax
801055d5:	eb 11                	jmp    801055e8 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801055d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055e1:	72 dc                	jb     801055bf <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055e8:	c9                   	leave  
801055e9:	c3                   	ret    

801055ea <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055ea:	55                   	push   %ebp
801055eb:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f3:	8b 40 18             	mov    0x18(%eax),%eax
801055f6:	8b 40 44             	mov    0x44(%eax),%eax
801055f9:	8b 55 08             	mov    0x8(%ebp),%edx
801055fc:	c1 e2 02             	shl    $0x2,%edx
801055ff:	01 d0                	add    %edx,%eax
80105601:	83 c0 04             	add    $0x4,%eax
80105604:	ff 75 0c             	pushl  0xc(%ebp)
80105607:	50                   	push   %eax
80105608:	e8 41 ff ff ff       	call   8010554e <fetchint>
8010560d:	83 c4 08             	add    $0x8,%esp
}
80105610:	c9                   	leave  
80105611:	c3                   	ret    

80105612 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105612:	55                   	push   %ebp
80105613:	89 e5                	mov    %esp,%ebp
80105615:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105618:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010561b:	50                   	push   %eax
8010561c:	ff 75 08             	pushl  0x8(%ebp)
8010561f:	e8 c6 ff ff ff       	call   801055ea <argint>
80105624:	83 c4 08             	add    $0x8,%esp
80105627:	85 c0                	test   %eax,%eax
80105629:	79 07                	jns    80105632 <argptr+0x20>
    return -1;
8010562b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105630:	eb 3d                	jmp    8010566f <argptr+0x5d>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105632:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105635:	89 c2                	mov    %eax,%edx
80105637:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563d:	8b 00                	mov    (%eax),%eax
8010563f:	39 c2                	cmp    %eax,%edx
80105641:	73 16                	jae    80105659 <argptr+0x47>
80105643:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105646:	89 c2                	mov    %eax,%edx
80105648:	8b 45 10             	mov    0x10(%ebp),%eax
8010564b:	01 c2                	add    %eax,%edx
8010564d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105653:	8b 00                	mov    (%eax),%eax
80105655:	39 c2                	cmp    %eax,%edx
80105657:	76 07                	jbe    80105660 <argptr+0x4e>
    return -1;
80105659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565e:	eb 0f                	jmp    8010566f <argptr+0x5d>
  *pp = (char*)i;
80105660:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105663:	89 c2                	mov    %eax,%edx
80105665:	8b 45 0c             	mov    0xc(%ebp),%eax
80105668:	89 10                	mov    %edx,(%eax)
  return 0;
8010566a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566f:	c9                   	leave  
80105670:	c3                   	ret    

80105671 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105671:	55                   	push   %ebp
80105672:	89 e5                	mov    %esp,%ebp
80105674:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105677:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010567a:	50                   	push   %eax
8010567b:	ff 75 08             	pushl  0x8(%ebp)
8010567e:	e8 67 ff ff ff       	call   801055ea <argint>
80105683:	83 c4 08             	add    $0x8,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	79 07                	jns    80105691 <argstr+0x20>
    return -1;
8010568a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568f:	eb 0f                	jmp    801056a0 <argstr+0x2f>
  return fetchstr(addr, pp);
80105691:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105694:	ff 75 0c             	pushl  0xc(%ebp)
80105697:	50                   	push   %eax
80105698:	e8 eb fe ff ff       	call   80105588 <fetchstr>
8010569d:	83 c4 08             	add    $0x8,%esp
}
801056a0:	c9                   	leave  
801056a1:	c3                   	ret    

801056a2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801056a2:	55                   	push   %ebp
801056a3:	89 e5                	mov    %esp,%ebp
801056a5:	53                   	push   %ebx
801056a6:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801056a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056af:	8b 40 18             	mov    0x18(%eax),%eax
801056b2:	8b 40 1c             	mov    0x1c(%eax),%eax
801056b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056bc:	7e 30                	jle    801056ee <syscall+0x4c>
801056be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c1:	83 f8 15             	cmp    $0x15,%eax
801056c4:	77 28                	ja     801056ee <syscall+0x4c>
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056d0:	85 c0                	test   %eax,%eax
801056d2:	74 1a                	je     801056ee <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801056d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056da:	8b 58 18             	mov    0x18(%eax),%ebx
801056dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e0:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056e7:	ff d0                	call   *%eax
801056e9:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056ec:	eb 34                	jmp    80105722 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f4:	8d 50 6c             	lea    0x6c(%eax),%edx
801056f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056fd:	8b 40 10             	mov    0x10(%eax),%eax
80105700:	ff 75 f4             	pushl  -0xc(%ebp)
80105703:	52                   	push   %edx
80105704:	50                   	push   %eax
80105705:	68 bb 89 10 80       	push   $0x801089bb
8010570a:	e8 b0 ac ff ff       	call   801003bf <cprintf>
8010570f:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105712:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105718:	8b 40 18             	mov    0x18(%eax),%eax
8010571b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105725:	c9                   	leave  
80105726:	c3                   	ret    

80105727 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105727:	55                   	push   %ebp
80105728:	89 e5                	mov    %esp,%ebp
8010572a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010572d:	83 ec 08             	sub    $0x8,%esp
80105730:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105733:	50                   	push   %eax
80105734:	ff 75 08             	pushl  0x8(%ebp)
80105737:	e8 ae fe ff ff       	call   801055ea <argint>
8010573c:	83 c4 10             	add    $0x10,%esp
8010573f:	85 c0                	test   %eax,%eax
80105741:	79 07                	jns    8010574a <argfd+0x23>
    return -1;
80105743:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105748:	eb 50                	jmp    8010579a <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010574a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574d:	85 c0                	test   %eax,%eax
8010574f:	78 21                	js     80105772 <argfd+0x4b>
80105751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105754:	83 f8 0f             	cmp    $0xf,%eax
80105757:	7f 19                	jg     80105772 <argfd+0x4b>
80105759:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105762:	83 c2 08             	add    $0x8,%edx
80105765:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105769:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010576c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105770:	75 07                	jne    80105779 <argfd+0x52>
    return -1;
80105772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105777:	eb 21                	jmp    8010579a <argfd+0x73>
  if(pfd)
80105779:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010577d:	74 08                	je     80105787 <argfd+0x60>
    *pfd = fd;
8010577f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105782:	8b 45 0c             	mov    0xc(%ebp),%eax
80105785:	89 10                	mov    %edx,(%eax)
  if(pf)
80105787:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010578b:	74 08                	je     80105795 <argfd+0x6e>
    *pf = f;
8010578d:	8b 45 10             	mov    0x10(%ebp),%eax
80105790:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105793:	89 10                	mov    %edx,(%eax)
  return 0;
80105795:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010579a:	c9                   	leave  
8010579b:	c3                   	ret    

8010579c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010579c:	55                   	push   %ebp
8010579d:	89 e5                	mov    %esp,%ebp
8010579f:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a9:	eb 30                	jmp    801057db <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b4:	83 c2 08             	add    $0x8,%edx
801057b7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057bb:	85 c0                	test   %eax,%eax
801057bd:	75 18                	jne    801057d7 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057c8:	8d 4a 08             	lea    0x8(%edx),%ecx
801057cb:	8b 55 08             	mov    0x8(%ebp),%edx
801057ce:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d5:	eb 0f                	jmp    801057e6 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057db:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057df:	7e ca                	jle    801057ab <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e6:	c9                   	leave  
801057e7:	c3                   	ret    

801057e8 <sys_dup>:

int
sys_dup(void)
{
801057e8:	55                   	push   %ebp
801057e9:	89 e5                	mov    %esp,%ebp
801057eb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057ee:	83 ec 04             	sub    $0x4,%esp
801057f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f4:	50                   	push   %eax
801057f5:	6a 00                	push   $0x0
801057f7:	6a 00                	push   $0x0
801057f9:	e8 29 ff ff ff       	call   80105727 <argfd>
801057fe:	83 c4 10             	add    $0x10,%esp
80105801:	85 c0                	test   %eax,%eax
80105803:	79 07                	jns    8010580c <sys_dup+0x24>
    return -1;
80105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580a:	eb 31                	jmp    8010583d <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010580c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	50                   	push   %eax
80105813:	e8 84 ff ff ff       	call   8010579c <fdalloc>
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105822:	79 07                	jns    8010582b <sys_dup+0x43>
    return -1;
80105824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105829:	eb 12                	jmp    8010583d <sys_dup+0x55>
  filedup(f);
8010582b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582e:	83 ec 0c             	sub    $0xc,%esp
80105831:	50                   	push   %eax
80105832:	e8 85 b7 ff ff       	call   80100fbc <filedup>
80105837:	83 c4 10             	add    $0x10,%esp
  return fd;
8010583a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010583d:	c9                   	leave  
8010583e:	c3                   	ret    

8010583f <sys_read>:

int
sys_read(void)
{
8010583f:	55                   	push   %ebp
80105840:	89 e5                	mov    %esp,%ebp
80105842:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105845:	83 ec 04             	sub    $0x4,%esp
80105848:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010584b:	50                   	push   %eax
8010584c:	6a 00                	push   $0x0
8010584e:	6a 00                	push   $0x0
80105850:	e8 d2 fe ff ff       	call   80105727 <argfd>
80105855:	83 c4 10             	add    $0x10,%esp
80105858:	85 c0                	test   %eax,%eax
8010585a:	78 2e                	js     8010588a <sys_read+0x4b>
8010585c:	83 ec 08             	sub    $0x8,%esp
8010585f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105862:	50                   	push   %eax
80105863:	6a 02                	push   $0x2
80105865:	e8 80 fd ff ff       	call   801055ea <argint>
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	85 c0                	test   %eax,%eax
8010586f:	78 19                	js     8010588a <sys_read+0x4b>
80105871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105874:	83 ec 04             	sub    $0x4,%esp
80105877:	50                   	push   %eax
80105878:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010587b:	50                   	push   %eax
8010587c:	6a 01                	push   $0x1
8010587e:	e8 8f fd ff ff       	call   80105612 <argptr>
80105883:	83 c4 10             	add    $0x10,%esp
80105886:	85 c0                	test   %eax,%eax
80105888:	79 07                	jns    80105891 <sys_read+0x52>
    return -1;
8010588a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588f:	eb 17                	jmp    801058a8 <sys_read+0x69>
  return fileread(f, p, n);
80105891:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105894:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589a:	83 ec 04             	sub    $0x4,%esp
8010589d:	51                   	push   %ecx
8010589e:	52                   	push   %edx
8010589f:	50                   	push   %eax
801058a0:	e8 a7 b8 ff ff       	call   8010114c <fileread>
801058a5:	83 c4 10             	add    $0x10,%esp
}
801058a8:	c9                   	leave  
801058a9:	c3                   	ret    

801058aa <sys_write>:

int
sys_write(void)
{
801058aa:	55                   	push   %ebp
801058ab:	89 e5                	mov    %esp,%ebp
801058ad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058b0:	83 ec 04             	sub    $0x4,%esp
801058b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b6:	50                   	push   %eax
801058b7:	6a 00                	push   $0x0
801058b9:	6a 00                	push   $0x0
801058bb:	e8 67 fe ff ff       	call   80105727 <argfd>
801058c0:	83 c4 10             	add    $0x10,%esp
801058c3:	85 c0                	test   %eax,%eax
801058c5:	78 2e                	js     801058f5 <sys_write+0x4b>
801058c7:	83 ec 08             	sub    $0x8,%esp
801058ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058cd:	50                   	push   %eax
801058ce:	6a 02                	push   $0x2
801058d0:	e8 15 fd ff ff       	call   801055ea <argint>
801058d5:	83 c4 10             	add    $0x10,%esp
801058d8:	85 c0                	test   %eax,%eax
801058da:	78 19                	js     801058f5 <sys_write+0x4b>
801058dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058df:	83 ec 04             	sub    $0x4,%esp
801058e2:	50                   	push   %eax
801058e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058e6:	50                   	push   %eax
801058e7:	6a 01                	push   $0x1
801058e9:	e8 24 fd ff ff       	call   80105612 <argptr>
801058ee:	83 c4 10             	add    $0x10,%esp
801058f1:	85 c0                	test   %eax,%eax
801058f3:	79 07                	jns    801058fc <sys_write+0x52>
    return -1;
801058f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fa:	eb 17                	jmp    80105913 <sys_write+0x69>
  return filewrite(f, p, n);
801058fc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105905:	83 ec 04             	sub    $0x4,%esp
80105908:	51                   	push   %ecx
80105909:	52                   	push   %edx
8010590a:	50                   	push   %eax
8010590b:	e8 f4 b8 ff ff       	call   80101204 <filewrite>
80105910:	83 c4 10             	add    $0x10,%esp
}
80105913:	c9                   	leave  
80105914:	c3                   	ret    

80105915 <sys_close>:

int
sys_close(void)
{
80105915:	55                   	push   %ebp
80105916:	89 e5                	mov    %esp,%ebp
80105918:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010591b:	83 ec 04             	sub    $0x4,%esp
8010591e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105921:	50                   	push   %eax
80105922:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105925:	50                   	push   %eax
80105926:	6a 00                	push   $0x0
80105928:	e8 fa fd ff ff       	call   80105727 <argfd>
8010592d:	83 c4 10             	add    $0x10,%esp
80105930:	85 c0                	test   %eax,%eax
80105932:	79 07                	jns    8010593b <sys_close+0x26>
    return -1;
80105934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105939:	eb 28                	jmp    80105963 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010593b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105941:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105944:	83 c2 08             	add    $0x8,%edx
80105947:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010594e:	00 
  fileclose(f);
8010594f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105952:	83 ec 0c             	sub    $0xc,%esp
80105955:	50                   	push   %eax
80105956:	e8 b2 b6 ff ff       	call   8010100d <fileclose>
8010595b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010595e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105963:	c9                   	leave  
80105964:	c3                   	ret    

80105965 <sys_fstat>:

int
sys_fstat(void)
{
80105965:	55                   	push   %ebp
80105966:	89 e5                	mov    %esp,%ebp
80105968:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010596b:	83 ec 04             	sub    $0x4,%esp
8010596e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105971:	50                   	push   %eax
80105972:	6a 00                	push   $0x0
80105974:	6a 00                	push   $0x0
80105976:	e8 ac fd ff ff       	call   80105727 <argfd>
8010597b:	83 c4 10             	add    $0x10,%esp
8010597e:	85 c0                	test   %eax,%eax
80105980:	78 17                	js     80105999 <sys_fstat+0x34>
80105982:	83 ec 04             	sub    $0x4,%esp
80105985:	6a 14                	push   $0x14
80105987:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010598a:	50                   	push   %eax
8010598b:	6a 01                	push   $0x1
8010598d:	e8 80 fc ff ff       	call   80105612 <argptr>
80105992:	83 c4 10             	add    $0x10,%esp
80105995:	85 c0                	test   %eax,%eax
80105997:	79 07                	jns    801059a0 <sys_fstat+0x3b>
    return -1;
80105999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599e:	eb 13                	jmp    801059b3 <sys_fstat+0x4e>
  return filestat(f, st);
801059a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a6:	83 ec 08             	sub    $0x8,%esp
801059a9:	52                   	push   %edx
801059aa:	50                   	push   %eax
801059ab:	e8 45 b7 ff ff       	call   801010f5 <filestat>
801059b0:	83 c4 10             	add    $0x10,%esp
}
801059b3:	c9                   	leave  
801059b4:	c3                   	ret    

801059b5 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059b5:	55                   	push   %ebp
801059b6:	89 e5                	mov    %esp,%ebp
801059b8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059bb:	83 ec 08             	sub    $0x8,%esp
801059be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059c1:	50                   	push   %eax
801059c2:	6a 00                	push   $0x0
801059c4:	e8 a8 fc ff ff       	call   80105671 <argstr>
801059c9:	83 c4 10             	add    $0x10,%esp
801059cc:	85 c0                	test   %eax,%eax
801059ce:	78 15                	js     801059e5 <sys_link+0x30>
801059d0:	83 ec 08             	sub    $0x8,%esp
801059d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059d6:	50                   	push   %eax
801059d7:	6a 01                	push   $0x1
801059d9:	e8 93 fc ff ff       	call   80105671 <argstr>
801059de:	83 c4 10             	add    $0x10,%esp
801059e1:	85 c0                	test   %eax,%eax
801059e3:	79 0a                	jns    801059ef <sys_link+0x3a>
    return -1;
801059e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ea:	e9 69 01 00 00       	jmp    80105b58 <sys_link+0x1a3>

  begin_op();
801059ef:	e8 95 db ff ff       	call   80103589 <begin_op>
  if((ip = namei(old)) == 0){
801059f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059f7:	83 ec 0c             	sub    $0xc,%esp
801059fa:	50                   	push   %eax
801059fb:	e8 b4 cb ff ff       	call   801025b4 <namei>
80105a00:	83 c4 10             	add    $0x10,%esp
80105a03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a0a:	75 0f                	jne    80105a1b <sys_link+0x66>
    end_op();
80105a0c:	e8 06 dc ff ff       	call   80103617 <end_op>
    return -1;
80105a11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a16:	e9 3d 01 00 00       	jmp    80105b58 <sys_link+0x1a3>
  }

  ilock(ip);
80105a1b:	83 ec 0c             	sub    $0xc,%esp
80105a1e:	ff 75 f4             	pushl  -0xc(%ebp)
80105a21:	e8 b6 be ff ff       	call   801018dc <ilock>
80105a26:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a30:	66 83 f8 01          	cmp    $0x1,%ax
80105a34:	75 1d                	jne    80105a53 <sys_link+0x9e>
    iunlockput(ip);
80105a36:	83 ec 0c             	sub    $0xc,%esp
80105a39:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3c:	e8 52 c1 ff ff       	call   80101b93 <iunlockput>
80105a41:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a44:	e8 ce db ff ff       	call   80103617 <end_op>
    return -1;
80105a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4e:	e9 05 01 00 00       	jmp    80105b58 <sys_link+0x1a3>
  }

  ip->nlink++;
80105a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a56:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a5a:	83 c0 01             	add    $0x1,%eax
80105a5d:	89 c2                	mov    %eax,%edx
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a66:	83 ec 0c             	sub    $0xc,%esp
80105a69:	ff 75 f4             	pushl  -0xc(%ebp)
80105a6c:	e8 98 bc ff ff       	call   80101709 <iupdate>
80105a71:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a74:	83 ec 0c             	sub    $0xc,%esp
80105a77:	ff 75 f4             	pushl  -0xc(%ebp)
80105a7a:	e8 b4 bf ff ff       	call   80101a33 <iunlock>
80105a7f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a85:	83 ec 08             	sub    $0x8,%esp
80105a88:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a8b:	52                   	push   %edx
80105a8c:	50                   	push   %eax
80105a8d:	e8 3e cb ff ff       	call   801025d0 <nameiparent>
80105a92:	83 c4 10             	add    $0x10,%esp
80105a95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a9c:	75 02                	jne    80105aa0 <sys_link+0xeb>
    goto bad;
80105a9e:	eb 71                	jmp    80105b11 <sys_link+0x15c>
  ilock(dp);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	ff 75 f0             	pushl  -0x10(%ebp)
80105aa6:	e8 31 be ff ff       	call   801018dc <ilock>
80105aab:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab1:	8b 10                	mov    (%eax),%edx
80105ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab6:	8b 00                	mov    (%eax),%eax
80105ab8:	39 c2                	cmp    %eax,%edx
80105aba:	75 1d                	jne    80105ad9 <sys_link+0x124>
80105abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abf:	8b 40 04             	mov    0x4(%eax),%eax
80105ac2:	83 ec 04             	sub    $0x4,%esp
80105ac5:	50                   	push   %eax
80105ac6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ac9:	50                   	push   %eax
80105aca:	ff 75 f0             	pushl  -0x10(%ebp)
80105acd:	e8 06 c8 ff ff       	call   801022d8 <dirlink>
80105ad2:	83 c4 10             	add    $0x10,%esp
80105ad5:	85 c0                	test   %eax,%eax
80105ad7:	79 10                	jns    80105ae9 <sys_link+0x134>
    iunlockput(dp);
80105ad9:	83 ec 0c             	sub    $0xc,%esp
80105adc:	ff 75 f0             	pushl  -0x10(%ebp)
80105adf:	e8 af c0 ff ff       	call   80101b93 <iunlockput>
80105ae4:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ae7:	eb 28                	jmp    80105b11 <sys_link+0x15c>
  }
  iunlockput(dp);
80105ae9:	83 ec 0c             	sub    $0xc,%esp
80105aec:	ff 75 f0             	pushl  -0x10(%ebp)
80105aef:	e8 9f c0 ff ff       	call   80101b93 <iunlockput>
80105af4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105af7:	83 ec 0c             	sub    $0xc,%esp
80105afa:	ff 75 f4             	pushl  -0xc(%ebp)
80105afd:	e8 a2 bf ff ff       	call   80101aa4 <iput>
80105b02:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b05:	e8 0d db ff ff       	call   80103617 <end_op>

  return 0;
80105b0a:	b8 00 00 00 00       	mov    $0x0,%eax
80105b0f:	eb 47                	jmp    80105b58 <sys_link+0x1a3>

bad:
  ilock(ip);
80105b11:	83 ec 0c             	sub    $0xc,%esp
80105b14:	ff 75 f4             	pushl  -0xc(%ebp)
80105b17:	e8 c0 bd ff ff       	call   801018dc <ilock>
80105b1c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b22:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b26:	83 e8 01             	sub    $0x1,%eax
80105b29:	89 c2                	mov    %eax,%edx
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b32:	83 ec 0c             	sub    $0xc,%esp
80105b35:	ff 75 f4             	pushl  -0xc(%ebp)
80105b38:	e8 cc bb ff ff       	call   80101709 <iupdate>
80105b3d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b40:	83 ec 0c             	sub    $0xc,%esp
80105b43:	ff 75 f4             	pushl  -0xc(%ebp)
80105b46:	e8 48 c0 ff ff       	call   80101b93 <iunlockput>
80105b4b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b4e:	e8 c4 da ff ff       	call   80103617 <end_op>
  return -1;
80105b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b58:	c9                   	leave  
80105b59:	c3                   	ret    

80105b5a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b5a:	55                   	push   %ebp
80105b5b:	89 e5                	mov    %esp,%ebp
80105b5d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b60:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b67:	eb 40                	jmp    80105ba9 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6c:	6a 10                	push   $0x10
80105b6e:	50                   	push   %eax
80105b6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b72:	50                   	push   %eax
80105b73:	ff 75 08             	pushl  0x8(%ebp)
80105b76:	e8 c3 c2 ff ff       	call   80101e3e <readi>
80105b7b:	83 c4 10             	add    $0x10,%esp
80105b7e:	83 f8 10             	cmp    $0x10,%eax
80105b81:	74 0d                	je     80105b90 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b83:	83 ec 0c             	sub    $0xc,%esp
80105b86:	68 d7 89 10 80       	push   $0x801089d7
80105b8b:	e8 cc a9 ff ff       	call   8010055c <panic>
    if(de.inum != 0)
80105b90:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b94:	66 85 c0             	test   %ax,%ax
80105b97:	74 07                	je     80105ba0 <isdirempty+0x46>
      return 0;
80105b99:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9e:	eb 1b                	jmp    80105bbb <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba3:	83 c0 10             	add    $0x10,%eax
80105ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bac:	8b 45 08             	mov    0x8(%ebp),%eax
80105baf:	8b 40 18             	mov    0x18(%eax),%eax
80105bb2:	39 c2                	cmp    %eax,%edx
80105bb4:	72 b3                	jb     80105b69 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bb6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bbb:	c9                   	leave  
80105bbc:	c3                   	ret    

80105bbd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bbd:	55                   	push   %ebp
80105bbe:	89 e5                	mov    %esp,%ebp
80105bc0:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bc3:	83 ec 08             	sub    $0x8,%esp
80105bc6:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bc9:	50                   	push   %eax
80105bca:	6a 00                	push   $0x0
80105bcc:	e8 a0 fa ff ff       	call   80105671 <argstr>
80105bd1:	83 c4 10             	add    $0x10,%esp
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	79 0a                	jns    80105be2 <sys_unlink+0x25>
    return -1;
80105bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdd:	e9 bc 01 00 00       	jmp    80105d9e <sys_unlink+0x1e1>

  begin_op();
80105be2:	e8 a2 d9 ff ff       	call   80103589 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105be7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bea:	83 ec 08             	sub    $0x8,%esp
80105bed:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bf0:	52                   	push   %edx
80105bf1:	50                   	push   %eax
80105bf2:	e8 d9 c9 ff ff       	call   801025d0 <nameiparent>
80105bf7:	83 c4 10             	add    $0x10,%esp
80105bfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c01:	75 0f                	jne    80105c12 <sys_unlink+0x55>
    end_op();
80105c03:	e8 0f da ff ff       	call   80103617 <end_op>
    return -1;
80105c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0d:	e9 8c 01 00 00       	jmp    80105d9e <sys_unlink+0x1e1>
  }

  ilock(dp);
80105c12:	83 ec 0c             	sub    $0xc,%esp
80105c15:	ff 75 f4             	pushl  -0xc(%ebp)
80105c18:	e8 bf bc ff ff       	call   801018dc <ilock>
80105c1d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c20:	83 ec 08             	sub    $0x8,%esp
80105c23:	68 e9 89 10 80       	push   $0x801089e9
80105c28:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c2b:	50                   	push   %eax
80105c2c:	e8 03 c5 ff ff       	call   80102134 <namecmp>
80105c31:	83 c4 10             	add    $0x10,%esp
80105c34:	85 c0                	test   %eax,%eax
80105c36:	0f 84 4a 01 00 00    	je     80105d86 <sys_unlink+0x1c9>
80105c3c:	83 ec 08             	sub    $0x8,%esp
80105c3f:	68 eb 89 10 80       	push   $0x801089eb
80105c44:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c47:	50                   	push   %eax
80105c48:	e8 e7 c4 ff ff       	call   80102134 <namecmp>
80105c4d:	83 c4 10             	add    $0x10,%esp
80105c50:	85 c0                	test   %eax,%eax
80105c52:	0f 84 2e 01 00 00    	je     80105d86 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c58:	83 ec 04             	sub    $0x4,%esp
80105c5b:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c5e:	50                   	push   %eax
80105c5f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	ff 75 f4             	pushl  -0xc(%ebp)
80105c66:	e8 e4 c4 ff ff       	call   8010214f <dirlookup>
80105c6b:	83 c4 10             	add    $0x10,%esp
80105c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c75:	75 05                	jne    80105c7c <sys_unlink+0xbf>
    goto bad;
80105c77:	e9 0a 01 00 00       	jmp    80105d86 <sys_unlink+0x1c9>
  ilock(ip);
80105c7c:	83 ec 0c             	sub    $0xc,%esp
80105c7f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c82:	e8 55 bc ff ff       	call   801018dc <ilock>
80105c87:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c91:	66 85 c0             	test   %ax,%ax
80105c94:	7f 0d                	jg     80105ca3 <sys_unlink+0xe6>
    panic("unlink: nlink < 1");
80105c96:	83 ec 0c             	sub    $0xc,%esp
80105c99:	68 ee 89 10 80       	push   $0x801089ee
80105c9e:	e8 b9 a8 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105caa:	66 83 f8 01          	cmp    $0x1,%ax
80105cae:	75 25                	jne    80105cd5 <sys_unlink+0x118>
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	ff 75 f0             	pushl  -0x10(%ebp)
80105cb6:	e8 9f fe ff ff       	call   80105b5a <isdirempty>
80105cbb:	83 c4 10             	add    $0x10,%esp
80105cbe:	85 c0                	test   %eax,%eax
80105cc0:	75 13                	jne    80105cd5 <sys_unlink+0x118>
    iunlockput(ip);
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80105cc8:	e8 c6 be ff ff       	call   80101b93 <iunlockput>
80105ccd:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cd0:	e9 b1 00 00 00       	jmp    80105d86 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105cd5:	83 ec 04             	sub    $0x4,%esp
80105cd8:	6a 10                	push   $0x10
80105cda:	6a 00                	push   $0x0
80105cdc:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cdf:	50                   	push   %eax
80105ce0:	e8 de f5 ff ff       	call   801052c3 <memset>
80105ce5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ce8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ceb:	6a 10                	push   $0x10
80105ced:	50                   	push   %eax
80105cee:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cf1:	50                   	push   %eax
80105cf2:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf5:	e8 a7 c2 ff ff       	call   80101fa1 <writei>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	83 f8 10             	cmp    $0x10,%eax
80105d00:	74 0d                	je     80105d0f <sys_unlink+0x152>
    panic("unlink: writei");
80105d02:	83 ec 0c             	sub    $0xc,%esp
80105d05:	68 00 8a 10 80       	push   $0x80108a00
80105d0a:	e8 4d a8 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR){
80105d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d12:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d16:	66 83 f8 01          	cmp    $0x1,%ax
80105d1a:	75 21                	jne    80105d3d <sys_unlink+0x180>
    dp->nlink--;
80105d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d23:	83 e8 01             	sub    $0x1,%eax
80105d26:	89 c2                	mov    %eax,%edx
80105d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2b:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d2f:	83 ec 0c             	sub    $0xc,%esp
80105d32:	ff 75 f4             	pushl  -0xc(%ebp)
80105d35:	e8 cf b9 ff ff       	call   80101709 <iupdate>
80105d3a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d3d:	83 ec 0c             	sub    $0xc,%esp
80105d40:	ff 75 f4             	pushl  -0xc(%ebp)
80105d43:	e8 4b be ff ff       	call   80101b93 <iunlockput>
80105d48:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d52:	83 e8 01             	sub    $0x1,%eax
80105d55:	89 c2                	mov    %eax,%edx
80105d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d5e:	83 ec 0c             	sub    $0xc,%esp
80105d61:	ff 75 f0             	pushl  -0x10(%ebp)
80105d64:	e8 a0 b9 ff ff       	call   80101709 <iupdate>
80105d69:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d6c:	83 ec 0c             	sub    $0xc,%esp
80105d6f:	ff 75 f0             	pushl  -0x10(%ebp)
80105d72:	e8 1c be ff ff       	call   80101b93 <iunlockput>
80105d77:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d7a:	e8 98 d8 ff ff       	call   80103617 <end_op>

  return 0;
80105d7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105d84:	eb 18                	jmp    80105d9e <sys_unlink+0x1e1>

bad:
  iunlockput(dp);
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8c:	e8 02 be ff ff       	call   80101b93 <iunlockput>
80105d91:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d94:	e8 7e d8 ff ff       	call   80103617 <end_op>
  return -1;
80105d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d9e:	c9                   	leave  
80105d9f:	c3                   	ret    

80105da0 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105da0:	55                   	push   %ebp
80105da1:	89 e5                	mov    %esp,%ebp
80105da3:	83 ec 38             	sub    $0x38,%esp
80105da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105da9:	8b 55 10             	mov    0x10(%ebp),%edx
80105dac:	8b 45 14             	mov    0x14(%ebp),%eax
80105daf:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105db3:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105db7:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dbb:	83 ec 08             	sub    $0x8,%esp
80105dbe:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc1:	50                   	push   %eax
80105dc2:	ff 75 08             	pushl  0x8(%ebp)
80105dc5:	e8 06 c8 ff ff       	call   801025d0 <nameiparent>
80105dca:	83 c4 10             	add    $0x10,%esp
80105dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd4:	75 0a                	jne    80105de0 <create+0x40>
    return 0;
80105dd6:	b8 00 00 00 00       	mov    $0x0,%eax
80105ddb:	e9 b5 01 00 00       	jmp    80105f95 <create+0x1f5>
  ilock(dp);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	ff 75 f4             	pushl  -0xc(%ebp)
80105de6:	e8 f1 ba ff ff       	call   801018dc <ilock>
80105deb:	83 c4 10             	add    $0x10,%esp

  if (dp->type == T_DEV) {
80105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105df5:	66 83 f8 03          	cmp    $0x3,%ax
80105df9:	75 18                	jne    80105e13 <create+0x73>
    iunlockput(dp);
80105dfb:	83 ec 0c             	sub    $0xc,%esp
80105dfe:	ff 75 f4             	pushl  -0xc(%ebp)
80105e01:	e8 8d bd ff ff       	call   80101b93 <iunlockput>
80105e06:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e09:	b8 00 00 00 00       	mov    $0x0,%eax
80105e0e:	e9 82 01 00 00       	jmp    80105f95 <create+0x1f5>
  }

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e13:	83 ec 04             	sub    $0x4,%esp
80105e16:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e1d:	50                   	push   %eax
80105e1e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e21:	e8 29 c3 ff ff       	call   8010214f <dirlookup>
80105e26:	83 c4 10             	add    $0x10,%esp
80105e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e30:	74 50                	je     80105e82 <create+0xe2>
    iunlockput(dp);
80105e32:	83 ec 0c             	sub    $0xc,%esp
80105e35:	ff 75 f4             	pushl  -0xc(%ebp)
80105e38:	e8 56 bd ff ff       	call   80101b93 <iunlockput>
80105e3d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e40:	83 ec 0c             	sub    $0xc,%esp
80105e43:	ff 75 f0             	pushl  -0x10(%ebp)
80105e46:	e8 91 ba ff ff       	call   801018dc <ilock>
80105e4b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e4e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e53:	75 15                	jne    80105e6a <create+0xca>
80105e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e58:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e5c:	66 83 f8 02          	cmp    $0x2,%ax
80105e60:	75 08                	jne    80105e6a <create+0xca>
      return ip;
80105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e65:	e9 2b 01 00 00       	jmp    80105f95 <create+0x1f5>
    iunlockput(ip);
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	ff 75 f0             	pushl  -0x10(%ebp)
80105e70:	e8 1e bd ff ff       	call   80101b93 <iunlockput>
80105e75:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e78:	b8 00 00 00 00       	mov    $0x0,%eax
80105e7d:	e9 13 01 00 00       	jmp    80105f95 <create+0x1f5>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e82:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	8b 00                	mov    (%eax),%eax
80105e8b:	83 ec 08             	sub    $0x8,%esp
80105e8e:	52                   	push   %edx
80105e8f:	50                   	push   %eax
80105e90:	e8 93 b7 ff ff       	call   80101628 <ialloc>
80105e95:	83 c4 10             	add    $0x10,%esp
80105e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e9f:	75 0d                	jne    80105eae <create+0x10e>
    panic("create: ialloc");
80105ea1:	83 ec 0c             	sub    $0xc,%esp
80105ea4:	68 0f 8a 10 80       	push   $0x80108a0f
80105ea9:	e8 ae a6 ff ff       	call   8010055c <panic>

  ilock(ip);
80105eae:	83 ec 0c             	sub    $0xc,%esp
80105eb1:	ff 75 f0             	pushl  -0x10(%ebp)
80105eb4:	e8 23 ba ff ff       	call   801018dc <ilock>
80105eb9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebf:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ec3:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eca:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ece:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed5:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105edb:	83 ec 0c             	sub    $0xc,%esp
80105ede:	ff 75 f0             	pushl  -0x10(%ebp)
80105ee1:	e8 23 b8 ff ff       	call   80101709 <iupdate>
80105ee6:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ee9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105eee:	75 6a                	jne    80105f5a <create+0x1ba>
    dp->nlink++;  // for ".."
80105ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ef7:	83 c0 01             	add    $0x1,%eax
80105efa:	89 c2                	mov    %eax,%edx
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f03:	83 ec 0c             	sub    $0xc,%esp
80105f06:	ff 75 f4             	pushl  -0xc(%ebp)
80105f09:	e8 fb b7 ff ff       	call   80101709 <iupdate>
80105f0e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f14:	8b 40 04             	mov    0x4(%eax),%eax
80105f17:	83 ec 04             	sub    $0x4,%esp
80105f1a:	50                   	push   %eax
80105f1b:	68 e9 89 10 80       	push   $0x801089e9
80105f20:	ff 75 f0             	pushl  -0x10(%ebp)
80105f23:	e8 b0 c3 ff ff       	call   801022d8 <dirlink>
80105f28:	83 c4 10             	add    $0x10,%esp
80105f2b:	85 c0                	test   %eax,%eax
80105f2d:	78 1e                	js     80105f4d <create+0x1ad>
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	8b 40 04             	mov    0x4(%eax),%eax
80105f35:	83 ec 04             	sub    $0x4,%esp
80105f38:	50                   	push   %eax
80105f39:	68 eb 89 10 80       	push   $0x801089eb
80105f3e:	ff 75 f0             	pushl  -0x10(%ebp)
80105f41:	e8 92 c3 ff ff       	call   801022d8 <dirlink>
80105f46:	83 c4 10             	add    $0x10,%esp
80105f49:	85 c0                	test   %eax,%eax
80105f4b:	79 0d                	jns    80105f5a <create+0x1ba>
      panic("create dots");
80105f4d:	83 ec 0c             	sub    $0xc,%esp
80105f50:	68 1e 8a 10 80       	push   $0x80108a1e
80105f55:	e8 02 a6 ff ff       	call   8010055c <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5d:	8b 40 04             	mov    0x4(%eax),%eax
80105f60:	83 ec 04             	sub    $0x4,%esp
80105f63:	50                   	push   %eax
80105f64:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f67:	50                   	push   %eax
80105f68:	ff 75 f4             	pushl  -0xc(%ebp)
80105f6b:	e8 68 c3 ff ff       	call   801022d8 <dirlink>
80105f70:	83 c4 10             	add    $0x10,%esp
80105f73:	85 c0                	test   %eax,%eax
80105f75:	79 0d                	jns    80105f84 <create+0x1e4>
    panic("create: dirlink");
80105f77:	83 ec 0c             	sub    $0xc,%esp
80105f7a:	68 2a 8a 10 80       	push   $0x80108a2a
80105f7f:	e8 d8 a5 ff ff       	call   8010055c <panic>

  iunlockput(dp);
80105f84:	83 ec 0c             	sub    $0xc,%esp
80105f87:	ff 75 f4             	pushl  -0xc(%ebp)
80105f8a:	e8 04 bc ff ff       	call   80101b93 <iunlockput>
80105f8f:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f95:	c9                   	leave  
80105f96:	c3                   	ret    

80105f97 <sys_open>:

int
sys_open(void)
{
80105f97:	55                   	push   %ebp
80105f98:	89 e5                	mov    %esp,%ebp
80105f9a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f9d:	83 ec 08             	sub    $0x8,%esp
80105fa0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa3:	50                   	push   %eax
80105fa4:	6a 00                	push   $0x0
80105fa6:	e8 c6 f6 ff ff       	call   80105671 <argstr>
80105fab:	83 c4 10             	add    $0x10,%esp
80105fae:	85 c0                	test   %eax,%eax
80105fb0:	78 15                	js     80105fc7 <sys_open+0x30>
80105fb2:	83 ec 08             	sub    $0x8,%esp
80105fb5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fb8:	50                   	push   %eax
80105fb9:	6a 01                	push   $0x1
80105fbb:	e8 2a f6 ff ff       	call   801055ea <argint>
80105fc0:	83 c4 10             	add    $0x10,%esp
80105fc3:	85 c0                	test   %eax,%eax
80105fc5:	79 0a                	jns    80105fd1 <sys_open+0x3a>
    return -1;
80105fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcc:	e9 61 01 00 00       	jmp    80106132 <sys_open+0x19b>

  begin_op();
80105fd1:	e8 b3 d5 ff ff       	call   80103589 <begin_op>

  if(omode & O_CREATE){
80105fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd9:	25 00 02 00 00       	and    $0x200,%eax
80105fde:	85 c0                	test   %eax,%eax
80105fe0:	74 2a                	je     8010600c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fe2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe5:	6a 00                	push   $0x0
80105fe7:	6a 00                	push   $0x0
80105fe9:	6a 02                	push   $0x2
80105feb:	50                   	push   %eax
80105fec:	e8 af fd ff ff       	call   80105da0 <create>
80105ff1:	83 c4 10             	add    $0x10,%esp
80105ff4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ff7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffb:	75 75                	jne    80106072 <sys_open+0xdb>
      end_op();
80105ffd:	e8 15 d6 ff ff       	call   80103617 <end_op>
      return -1;
80106002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106007:	e9 26 01 00 00       	jmp    80106132 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010600c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010600f:	83 ec 0c             	sub    $0xc,%esp
80106012:	50                   	push   %eax
80106013:	e8 9c c5 ff ff       	call   801025b4 <namei>
80106018:	83 c4 10             	add    $0x10,%esp
8010601b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010601e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106022:	75 0f                	jne    80106033 <sys_open+0x9c>
      end_op();
80106024:	e8 ee d5 ff ff       	call   80103617 <end_op>
      return -1;
80106029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602e:	e9 ff 00 00 00       	jmp    80106132 <sys_open+0x19b>
    }
    ilock(ip);
80106033:	83 ec 0c             	sub    $0xc,%esp
80106036:	ff 75 f4             	pushl  -0xc(%ebp)
80106039:	e8 9e b8 ff ff       	call   801018dc <ilock>
8010603e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106044:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106048:	66 83 f8 01          	cmp    $0x1,%ax
8010604c:	75 24                	jne    80106072 <sys_open+0xdb>
8010604e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106051:	85 c0                	test   %eax,%eax
80106053:	74 1d                	je     80106072 <sys_open+0xdb>
      iunlockput(ip);
80106055:	83 ec 0c             	sub    $0xc,%esp
80106058:	ff 75 f4             	pushl  -0xc(%ebp)
8010605b:	e8 33 bb ff ff       	call   80101b93 <iunlockput>
80106060:	83 c4 10             	add    $0x10,%esp
      end_op();
80106063:	e8 af d5 ff ff       	call   80103617 <end_op>
      return -1;
80106068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606d:	e9 c0 00 00 00       	jmp    80106132 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106072:	e8 d9 ae ff ff       	call   80100f50 <filealloc>
80106077:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010607a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607e:	74 17                	je     80106097 <sys_open+0x100>
80106080:	83 ec 0c             	sub    $0xc,%esp
80106083:	ff 75 f0             	pushl  -0x10(%ebp)
80106086:	e8 11 f7 ff ff       	call   8010579c <fdalloc>
8010608b:	83 c4 10             	add    $0x10,%esp
8010608e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106091:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106095:	79 2e                	jns    801060c5 <sys_open+0x12e>
    if(f)
80106097:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010609b:	74 0e                	je     801060ab <sys_open+0x114>
      fileclose(f);
8010609d:	83 ec 0c             	sub    $0xc,%esp
801060a0:	ff 75 f0             	pushl  -0x10(%ebp)
801060a3:	e8 65 af ff ff       	call   8010100d <fileclose>
801060a8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060ab:	83 ec 0c             	sub    $0xc,%esp
801060ae:	ff 75 f4             	pushl  -0xc(%ebp)
801060b1:	e8 dd ba ff ff       	call   80101b93 <iunlockput>
801060b6:	83 c4 10             	add    $0x10,%esp
    end_op();
801060b9:	e8 59 d5 ff ff       	call   80103617 <end_op>
    return -1;
801060be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c3:	eb 6d                	jmp    80106132 <sys_open+0x19b>
  }
  iunlock(ip);
801060c5:	83 ec 0c             	sub    $0xc,%esp
801060c8:	ff 75 f4             	pushl  -0xc(%ebp)
801060cb:	e8 63 b9 ff ff       	call   80101a33 <iunlock>
801060d0:	83 c4 10             	add    $0x10,%esp
  end_op();
801060d3:	e8 3f d5 ff ff       	call   80103617 <end_op>

  f->type = FD_INODE;
801060d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060db:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060e7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ed:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f7:	83 e0 01             	and    $0x1,%eax
801060fa:	85 c0                	test   %eax,%eax
801060fc:	0f 94 c0             	sete   %al
801060ff:	89 c2                	mov    %eax,%edx
80106101:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106104:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010610a:	83 e0 01             	and    $0x1,%eax
8010610d:	85 c0                	test   %eax,%eax
8010610f:	75 0a                	jne    8010611b <sys_open+0x184>
80106111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106114:	83 e0 02             	and    $0x2,%eax
80106117:	85 c0                	test   %eax,%eax
80106119:	74 07                	je     80106122 <sys_open+0x18b>
8010611b:	b8 01 00 00 00       	mov    $0x1,%eax
80106120:	eb 05                	jmp    80106127 <sys_open+0x190>
80106122:	b8 00 00 00 00       	mov    $0x0,%eax
80106127:	89 c2                	mov    %eax,%edx
80106129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010612f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106132:	c9                   	leave  
80106133:	c3                   	ret    

80106134 <sys_mkdir>:

int
sys_mkdir(void)
{
80106134:	55                   	push   %ebp
80106135:	89 e5                	mov    %esp,%ebp
80106137:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010613a:	e8 4a d4 ff ff       	call   80103589 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010613f:	83 ec 08             	sub    $0x8,%esp
80106142:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106145:	50                   	push   %eax
80106146:	6a 00                	push   $0x0
80106148:	e8 24 f5 ff ff       	call   80105671 <argstr>
8010614d:	83 c4 10             	add    $0x10,%esp
80106150:	85 c0                	test   %eax,%eax
80106152:	78 1b                	js     8010616f <sys_mkdir+0x3b>
80106154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106157:	6a 00                	push   $0x0
80106159:	6a 00                	push   $0x0
8010615b:	6a 01                	push   $0x1
8010615d:	50                   	push   %eax
8010615e:	e8 3d fc ff ff       	call   80105da0 <create>
80106163:	83 c4 10             	add    $0x10,%esp
80106166:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616d:	75 0c                	jne    8010617b <sys_mkdir+0x47>
    end_op();
8010616f:	e8 a3 d4 ff ff       	call   80103617 <end_op>
    return -1;
80106174:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106179:	eb 18                	jmp    80106193 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	ff 75 f4             	pushl  -0xc(%ebp)
80106181:	e8 0d ba ff ff       	call   80101b93 <iunlockput>
80106186:	83 c4 10             	add    $0x10,%esp
  end_op();
80106189:	e8 89 d4 ff ff       	call   80103617 <end_op>
  return 0;
8010618e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106193:	c9                   	leave  
80106194:	c3                   	ret    

80106195 <sys_mknod>:

int
sys_mknod(void)
{
80106195:	55                   	push   %ebp
80106196:	89 e5                	mov    %esp,%ebp
80106198:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010619b:	e8 e9 d3 ff ff       	call   80103589 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801061a0:	83 ec 08             	sub    $0x8,%esp
801061a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061a6:	50                   	push   %eax
801061a7:	6a 00                	push   $0x0
801061a9:	e8 c3 f4 ff ff       	call   80105671 <argstr>
801061ae:	83 c4 10             	add    $0x10,%esp
801061b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b8:	78 4f                	js     80106209 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801061ba:	83 ec 08             	sub    $0x8,%esp
801061bd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061c0:	50                   	push   %eax
801061c1:	6a 01                	push   $0x1
801061c3:	e8 22 f4 ff ff       	call   801055ea <argint>
801061c8:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801061cb:	85 c0                	test   %eax,%eax
801061cd:	78 3a                	js     80106209 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061cf:	83 ec 08             	sub    $0x8,%esp
801061d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061d5:	50                   	push   %eax
801061d6:	6a 02                	push   $0x2
801061d8:	e8 0d f4 ff ff       	call   801055ea <argint>
801061dd:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061e0:	85 c0                	test   %eax,%eax
801061e2:	78 25                	js     80106209 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e7:	0f bf c8             	movswl %ax,%ecx
801061ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ed:	0f bf d0             	movswl %ax,%edx
801061f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061f3:	51                   	push   %ecx
801061f4:	52                   	push   %edx
801061f5:	6a 03                	push   $0x3
801061f7:	50                   	push   %eax
801061f8:	e8 a3 fb ff ff       	call   80105da0 <create>
801061fd:	83 c4 10             	add    $0x10,%esp
80106200:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106203:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106207:	75 0c                	jne    80106215 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106209:	e8 09 d4 ff ff       	call   80103617 <end_op>
    return -1;
8010620e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106213:	eb 18                	jmp    8010622d <sys_mknod+0x98>
  }
  iunlockput(ip);
80106215:	83 ec 0c             	sub    $0xc,%esp
80106218:	ff 75 f0             	pushl  -0x10(%ebp)
8010621b:	e8 73 b9 ff ff       	call   80101b93 <iunlockput>
80106220:	83 c4 10             	add    $0x10,%esp
  end_op();
80106223:	e8 ef d3 ff ff       	call   80103617 <end_op>
  return 0;
80106228:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010622d:	c9                   	leave  
8010622e:	c3                   	ret    

8010622f <sys_chdir>:

int
sys_chdir(void)
{
8010622f:	55                   	push   %ebp
80106230:	89 e5                	mov    %esp,%ebp
80106232:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106235:	e8 4f d3 ff ff       	call   80103589 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010623a:	83 ec 08             	sub    $0x8,%esp
8010623d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106240:	50                   	push   %eax
80106241:	6a 00                	push   $0x0
80106243:	e8 29 f4 ff ff       	call   80105671 <argstr>
80106248:	83 c4 10             	add    $0x10,%esp
8010624b:	85 c0                	test   %eax,%eax
8010624d:	78 18                	js     80106267 <sys_chdir+0x38>
8010624f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106252:	83 ec 0c             	sub    $0xc,%esp
80106255:	50                   	push   %eax
80106256:	e8 59 c3 ff ff       	call   801025b4 <namei>
8010625b:	83 c4 10             	add    $0x10,%esp
8010625e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106261:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106265:	75 0f                	jne    80106276 <sys_chdir+0x47>
    end_op();
80106267:	e8 ab d3 ff ff       	call   80103617 <end_op>
    return -1;
8010626c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106271:	e9 b2 00 00 00       	jmp    80106328 <sys_chdir+0xf9>
  }
  ilock(ip);
80106276:	83 ec 0c             	sub    $0xc,%esp
80106279:	ff 75 f4             	pushl  -0xc(%ebp)
8010627c:	e8 5b b6 ff ff       	call   801018dc <ilock>
80106281:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR && !IS_DEV_DIR(ip)) {
80106284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106287:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010628b:	66 83 f8 01          	cmp    $0x1,%ax
8010628f:	74 5e                	je     801062ef <sys_chdir+0xc0>
80106291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106294:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106298:	66 83 f8 03          	cmp    $0x3,%ax
8010629c:	75 37                	jne    801062d5 <sys_chdir+0xa6>
8010629e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801062a5:	98                   	cwtl   
801062a6:	c1 e0 04             	shl    $0x4,%eax
801062a9:	05 40 12 11 80       	add    $0x80111240,%eax
801062ae:	8b 00                	mov    (%eax),%eax
801062b0:	85 c0                	test   %eax,%eax
801062b2:	74 21                	je     801062d5 <sys_chdir+0xa6>
801062b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801062bb:	98                   	cwtl   
801062bc:	c1 e0 04             	shl    $0x4,%eax
801062bf:	05 40 12 11 80       	add    $0x80111240,%eax
801062c4:	8b 00                	mov    (%eax),%eax
801062c6:	83 ec 0c             	sub    $0xc,%esp
801062c9:	ff 75 f4             	pushl  -0xc(%ebp)
801062cc:	ff d0                	call   *%eax
801062ce:	83 c4 10             	add    $0x10,%esp
801062d1:	85 c0                	test   %eax,%eax
801062d3:	75 1a                	jne    801062ef <sys_chdir+0xc0>
    iunlockput(ip);
801062d5:	83 ec 0c             	sub    $0xc,%esp
801062d8:	ff 75 f4             	pushl  -0xc(%ebp)
801062db:	e8 b3 b8 ff ff       	call   80101b93 <iunlockput>
801062e0:	83 c4 10             	add    $0x10,%esp
    end_op();
801062e3:	e8 2f d3 ff ff       	call   80103617 <end_op>
    return -1;
801062e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ed:	eb 39                	jmp    80106328 <sys_chdir+0xf9>
  }
  iunlock(ip);
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	ff 75 f4             	pushl  -0xc(%ebp)
801062f5:	e8 39 b7 ff ff       	call   80101a33 <iunlock>
801062fa:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801062fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106303:	8b 40 68             	mov    0x68(%eax),%eax
80106306:	83 ec 0c             	sub    $0xc,%esp
80106309:	50                   	push   %eax
8010630a:	e8 95 b7 ff ff       	call   80101aa4 <iput>
8010630f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106312:	e8 00 d3 ff ff       	call   80103617 <end_op>
  proc->cwd = ip;
80106317:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010631d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106320:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106323:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106328:	c9                   	leave  
80106329:	c3                   	ret    

8010632a <sys_exec>:

int
sys_exec(void)
{
8010632a:	55                   	push   %ebp
8010632b:	89 e5                	mov    %esp,%ebp
8010632d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106333:	83 ec 08             	sub    $0x8,%esp
80106336:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106339:	50                   	push   %eax
8010633a:	6a 00                	push   $0x0
8010633c:	e8 30 f3 ff ff       	call   80105671 <argstr>
80106341:	83 c4 10             	add    $0x10,%esp
80106344:	85 c0                	test   %eax,%eax
80106346:	78 18                	js     80106360 <sys_exec+0x36>
80106348:	83 ec 08             	sub    $0x8,%esp
8010634b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106351:	50                   	push   %eax
80106352:	6a 01                	push   $0x1
80106354:	e8 91 f2 ff ff       	call   801055ea <argint>
80106359:	83 c4 10             	add    $0x10,%esp
8010635c:	85 c0                	test   %eax,%eax
8010635e:	79 0a                	jns    8010636a <sys_exec+0x40>
    return -1;
80106360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106365:	e9 c6 00 00 00       	jmp    80106430 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010636a:	83 ec 04             	sub    $0x4,%esp
8010636d:	68 80 00 00 00       	push   $0x80
80106372:	6a 00                	push   $0x0
80106374:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010637a:	50                   	push   %eax
8010637b:	e8 43 ef ff ff       	call   801052c3 <memset>
80106380:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106383:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010638a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638d:	83 f8 1f             	cmp    $0x1f,%eax
80106390:	76 0a                	jbe    8010639c <sys_exec+0x72>
      return -1;
80106392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106397:	e9 94 00 00 00       	jmp    80106430 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010639c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639f:	c1 e0 02             	shl    $0x2,%eax
801063a2:	89 c2                	mov    %eax,%edx
801063a4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063aa:	01 c2                	add    %eax,%edx
801063ac:	83 ec 08             	sub    $0x8,%esp
801063af:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063b5:	50                   	push   %eax
801063b6:	52                   	push   %edx
801063b7:	e8 92 f1 ff ff       	call   8010554e <fetchint>
801063bc:	83 c4 10             	add    $0x10,%esp
801063bf:	85 c0                	test   %eax,%eax
801063c1:	79 07                	jns    801063ca <sys_exec+0xa0>
      return -1;
801063c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c8:	eb 66                	jmp    80106430 <sys_exec+0x106>
    if(uarg == 0){
801063ca:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063d0:	85 c0                	test   %eax,%eax
801063d2:	75 27                	jne    801063fb <sys_exec+0xd1>
      argv[i] = 0;
801063d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063de:	00 00 00 00 
      break;
801063e2:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801063e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e6:	83 ec 08             	sub    $0x8,%esp
801063e9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063ef:	52                   	push   %edx
801063f0:	50                   	push   %eax
801063f1:	e8 4e a7 ff ff       	call   80100b44 <exec>
801063f6:	83 c4 10             	add    $0x10,%esp
801063f9:	eb 35                	jmp    80106430 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801063fb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106401:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106404:	c1 e2 02             	shl    $0x2,%edx
80106407:	01 c2                	add    %eax,%edx
80106409:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010640f:	83 ec 08             	sub    $0x8,%esp
80106412:	52                   	push   %edx
80106413:	50                   	push   %eax
80106414:	e8 6f f1 ff ff       	call   80105588 <fetchstr>
80106419:	83 c4 10             	add    $0x10,%esp
8010641c:	85 c0                	test   %eax,%eax
8010641e:	79 07                	jns    80106427 <sys_exec+0xfd>
      return -1;
80106420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106425:	eb 09                	jmp    80106430 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106427:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010642b:	e9 5a ff ff ff       	jmp    8010638a <sys_exec+0x60>
  return exec(path, argv);
}
80106430:	c9                   	leave  
80106431:	c3                   	ret    

80106432 <sys_pipe>:

int
sys_pipe(void)
{
80106432:	55                   	push   %ebp
80106433:	89 e5                	mov    %esp,%ebp
80106435:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106438:	83 ec 04             	sub    $0x4,%esp
8010643b:	6a 08                	push   $0x8
8010643d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106440:	50                   	push   %eax
80106441:	6a 00                	push   $0x0
80106443:	e8 ca f1 ff ff       	call   80105612 <argptr>
80106448:	83 c4 10             	add    $0x10,%esp
8010644b:	85 c0                	test   %eax,%eax
8010644d:	79 0a                	jns    80106459 <sys_pipe+0x27>
    return -1;
8010644f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106454:	e9 af 00 00 00       	jmp    80106508 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106459:	83 ec 08             	sub    $0x8,%esp
8010645c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010645f:	50                   	push   %eax
80106460:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106463:	50                   	push   %eax
80106464:	e8 12 dc ff ff       	call   8010407b <pipealloc>
80106469:	83 c4 10             	add    $0x10,%esp
8010646c:	85 c0                	test   %eax,%eax
8010646e:	79 0a                	jns    8010647a <sys_pipe+0x48>
    return -1;
80106470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106475:	e9 8e 00 00 00       	jmp    80106508 <sys_pipe+0xd6>
  fd0 = -1;
8010647a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106481:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106484:	83 ec 0c             	sub    $0xc,%esp
80106487:	50                   	push   %eax
80106488:	e8 0f f3 ff ff       	call   8010579c <fdalloc>
8010648d:	83 c4 10             	add    $0x10,%esp
80106490:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106493:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106497:	78 18                	js     801064b1 <sys_pipe+0x7f>
80106499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010649c:	83 ec 0c             	sub    $0xc,%esp
8010649f:	50                   	push   %eax
801064a0:	e8 f7 f2 ff ff       	call   8010579c <fdalloc>
801064a5:	83 c4 10             	add    $0x10,%esp
801064a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064af:	79 3f                	jns    801064f0 <sys_pipe+0xbe>
    if(fd0 >= 0)
801064b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064b5:	78 14                	js     801064cb <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801064b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064c0:	83 c2 08             	add    $0x8,%edx
801064c3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064ca:	00 
    fileclose(rf);
801064cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ce:	83 ec 0c             	sub    $0xc,%esp
801064d1:	50                   	push   %eax
801064d2:	e8 36 ab ff ff       	call   8010100d <fileclose>
801064d7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801064da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064dd:	83 ec 0c             	sub    $0xc,%esp
801064e0:	50                   	push   %eax
801064e1:	e8 27 ab ff ff       	call   8010100d <fileclose>
801064e6:	83 c4 10             	add    $0x10,%esp
    return -1;
801064e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ee:	eb 18                	jmp    80106508 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801064f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064f6:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064fb:	8d 50 04             	lea    0x4(%eax),%edx
801064fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106501:	89 02                	mov    %eax,(%edx)
  return 0;
80106503:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106508:	c9                   	leave  
80106509:	c3                   	ret    

8010650a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010650a:	55                   	push   %ebp
8010650b:	89 e5                	mov    %esp,%ebp
8010650d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106510:	e8 5c e2 ff ff       	call   80104771 <fork>
}
80106515:	c9                   	leave  
80106516:	c3                   	ret    

80106517 <sys_exit>:

int
sys_exit(void)
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010651d:	e8 e0 e3 ff ff       	call   80104902 <exit>
  return 0;  // not reached
80106522:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106527:	c9                   	leave  
80106528:	c3                   	ret    

80106529 <sys_wait>:

int
sys_wait(void)
{
80106529:	55                   	push   %ebp
8010652a:	89 e5                	mov    %esp,%ebp
8010652c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010652f:	e8 06 e5 ff ff       	call   80104a3a <wait>
}
80106534:	c9                   	leave  
80106535:	c3                   	ret    

80106536 <sys_kill>:

int
sys_kill(void)
{
80106536:	55                   	push   %ebp
80106537:	89 e5                	mov    %esp,%ebp
80106539:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010653c:	83 ec 08             	sub    $0x8,%esp
8010653f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106542:	50                   	push   %eax
80106543:	6a 00                	push   $0x0
80106545:	e8 a0 f0 ff ff       	call   801055ea <argint>
8010654a:	83 c4 10             	add    $0x10,%esp
8010654d:	85 c0                	test   %eax,%eax
8010654f:	79 07                	jns    80106558 <sys_kill+0x22>
    return -1;
80106551:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106556:	eb 0f                	jmp    80106567 <sys_kill+0x31>
  return kill(pid);
80106558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655b:	83 ec 0c             	sub    $0xc,%esp
8010655e:	50                   	push   %eax
8010655f:	e8 e2 e8 ff ff       	call   80104e46 <kill>
80106564:	83 c4 10             	add    $0x10,%esp
}
80106567:	c9                   	leave  
80106568:	c3                   	ret    

80106569 <sys_getpid>:

int
sys_getpid(void)
{
80106569:	55                   	push   %ebp
8010656a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010656c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106572:	8b 40 10             	mov    0x10(%eax),%eax
}
80106575:	5d                   	pop    %ebp
80106576:	c3                   	ret    

80106577 <sys_sbrk>:

int
sys_sbrk(void)
{
80106577:	55                   	push   %ebp
80106578:	89 e5                	mov    %esp,%ebp
8010657a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010657d:	83 ec 08             	sub    $0x8,%esp
80106580:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106583:	50                   	push   %eax
80106584:	6a 00                	push   $0x0
80106586:	e8 5f f0 ff ff       	call   801055ea <argint>
8010658b:	83 c4 10             	add    $0x10,%esp
8010658e:	85 c0                	test   %eax,%eax
80106590:	79 07                	jns    80106599 <sys_sbrk+0x22>
    return -1;
80106592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106597:	eb 28                	jmp    801065c1 <sys_sbrk+0x4a>
  addr = proc->sz;
80106599:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010659f:	8b 00                	mov    (%eax),%eax
801065a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a7:	83 ec 0c             	sub    $0xc,%esp
801065aa:	50                   	push   %eax
801065ab:	e8 1e e1 ff ff       	call   801046ce <growproc>
801065b0:	83 c4 10             	add    $0x10,%esp
801065b3:	85 c0                	test   %eax,%eax
801065b5:	79 07                	jns    801065be <sys_sbrk+0x47>
    return -1;
801065b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bc:	eb 03                	jmp    801065c1 <sys_sbrk+0x4a>
  return addr;
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065c1:	c9                   	leave  
801065c2:	c3                   	ret    

801065c3 <sys_sleep>:

int
sys_sleep(void)
{
801065c3:	55                   	push   %ebp
801065c4:	89 e5                	mov    %esp,%ebp
801065c6:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065c9:	83 ec 08             	sub    $0x8,%esp
801065cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065cf:	50                   	push   %eax
801065d0:	6a 00                	push   $0x0
801065d2:	e8 13 f0 ff ff       	call   801055ea <argint>
801065d7:	83 c4 10             	add    $0x10,%esp
801065da:	85 c0                	test   %eax,%eax
801065dc:	79 07                	jns    801065e5 <sys_sleep+0x22>
    return -1;
801065de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e3:	eb 77                	jmp    8010665c <sys_sleep+0x99>
  acquire(&tickslock);
801065e5:	83 ec 0c             	sub    $0xc,%esp
801065e8:	68 c0 49 11 80       	push   $0x801149c0
801065ed:	e8 75 ea ff ff       	call   80105067 <acquire>
801065f2:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065f5:	a1 00 52 11 80       	mov    0x80115200,%eax
801065fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065fd:	eb 39                	jmp    80106638 <sys_sleep+0x75>
    if(proc->killed){
801065ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106605:	8b 40 24             	mov    0x24(%eax),%eax
80106608:	85 c0                	test   %eax,%eax
8010660a:	74 17                	je     80106623 <sys_sleep+0x60>
      release(&tickslock);
8010660c:	83 ec 0c             	sub    $0xc,%esp
8010660f:	68 c0 49 11 80       	push   $0x801149c0
80106614:	e8 b4 ea ff ff       	call   801050cd <release>
80106619:	83 c4 10             	add    $0x10,%esp
      return -1;
8010661c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106621:	eb 39                	jmp    8010665c <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106623:	83 ec 08             	sub    $0x8,%esp
80106626:	68 c0 49 11 80       	push   $0x801149c0
8010662b:	68 00 52 11 80       	push   $0x80115200
80106630:	e8 f2 e6 ff ff       	call   80104d27 <sleep>
80106635:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106638:	a1 00 52 11 80       	mov    0x80115200,%eax
8010663d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106640:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106643:	39 d0                	cmp    %edx,%eax
80106645:	72 b8                	jb     801065ff <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106647:	83 ec 0c             	sub    $0xc,%esp
8010664a:	68 c0 49 11 80       	push   $0x801149c0
8010664f:	e8 79 ea ff ff       	call   801050cd <release>
80106654:	83 c4 10             	add    $0x10,%esp
  return 0;
80106657:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010665c:	c9                   	leave  
8010665d:	c3                   	ret    

8010665e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010665e:	55                   	push   %ebp
8010665f:	89 e5                	mov    %esp,%ebp
80106661:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106664:	83 ec 0c             	sub    $0xc,%esp
80106667:	68 c0 49 11 80       	push   $0x801149c0
8010666c:	e8 f6 e9 ff ff       	call   80105067 <acquire>
80106671:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106674:	a1 00 52 11 80       	mov    0x80115200,%eax
80106679:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010667c:	83 ec 0c             	sub    $0xc,%esp
8010667f:	68 c0 49 11 80       	push   $0x801149c0
80106684:	e8 44 ea ff ff       	call   801050cd <release>
80106689:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010668c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010668f:	c9                   	leave  
80106690:	c3                   	ret    

80106691 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106691:	55                   	push   %ebp
80106692:	89 e5                	mov    %esp,%ebp
80106694:	83 ec 08             	sub    $0x8,%esp
80106697:	8b 55 08             	mov    0x8(%ebp),%edx
8010669a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010669d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066a1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066a4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066a8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066ac:	ee                   	out    %al,(%dx)
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    

801066af <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801066af:	55                   	push   %ebp
801066b0:	89 e5                	mov    %esp,%ebp
801066b2:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801066b5:	6a 34                	push   $0x34
801066b7:	6a 43                	push   $0x43
801066b9:	e8 d3 ff ff ff       	call   80106691 <outb>
801066be:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801066c1:	68 9c 00 00 00       	push   $0x9c
801066c6:	6a 40                	push   $0x40
801066c8:	e8 c4 ff ff ff       	call   80106691 <outb>
801066cd:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801066d0:	6a 2e                	push   $0x2e
801066d2:	6a 40                	push   $0x40
801066d4:	e8 b8 ff ff ff       	call   80106691 <outb>
801066d9:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801066dc:	83 ec 0c             	sub    $0xc,%esp
801066df:	6a 00                	push   $0x0
801066e1:	e8 81 d8 ff ff       	call   80103f67 <picenable>
801066e6:	83 c4 10             	add    $0x10,%esp
}
801066e9:	c9                   	leave  
801066ea:	c3                   	ret    

801066eb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066eb:	1e                   	push   %ds
  pushl %es
801066ec:	06                   	push   %es
  pushl %fs
801066ed:	0f a0                	push   %fs
  pushl %gs
801066ef:	0f a8                	push   %gs
  pushal
801066f1:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801066f2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066f6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066f8:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801066fa:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801066fe:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106700:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106702:	54                   	push   %esp
  call trap
80106703:	e8 d4 01 00 00       	call   801068dc <trap>
  addl $4, %esp
80106708:	83 c4 04             	add    $0x4,%esp

8010670b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010670b:	61                   	popa   
  popl %gs
8010670c:	0f a9                	pop    %gs
  popl %fs
8010670e:	0f a1                	pop    %fs
  popl %es
80106710:	07                   	pop    %es
  popl %ds
80106711:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106712:	83 c4 08             	add    $0x8,%esp
  iret
80106715:	cf                   	iret   

80106716 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010671c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010671f:	83 e8 01             	sub    $0x1,%eax
80106722:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106726:	8b 45 08             	mov    0x8(%ebp),%eax
80106729:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010672d:	8b 45 08             	mov    0x8(%ebp),%eax
80106730:	c1 e8 10             	shr    $0x10,%eax
80106733:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106737:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010673a:	0f 01 18             	lidtl  (%eax)
}
8010673d:	c9                   	leave  
8010673e:	c3                   	ret    

8010673f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010673f:	55                   	push   %ebp
80106740:	89 e5                	mov    %esp,%ebp
80106742:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106745:	0f 20 d0             	mov    %cr2,%eax
80106748:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010674b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010674e:	c9                   	leave  
8010674f:	c3                   	ret    

80106750 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106750:	55                   	push   %ebp
80106751:	89 e5                	mov    %esp,%ebp
80106753:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010675d:	e9 c3 00 00 00       	jmp    80106825 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106765:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010676c:	89 c2                	mov    %eax,%edx
8010676e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106771:	66 89 14 c5 00 4a 11 	mov    %dx,-0x7feeb600(,%eax,8)
80106778:	80 
80106779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677c:	66 c7 04 c5 02 4a 11 	movw   $0x8,-0x7feeb5fe(,%eax,8)
80106783:	80 08 00 
80106786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106789:	0f b6 14 c5 04 4a 11 	movzbl -0x7feeb5fc(,%eax,8),%edx
80106790:	80 
80106791:	83 e2 e0             	and    $0xffffffe0,%edx
80106794:	88 14 c5 04 4a 11 80 	mov    %dl,-0x7feeb5fc(,%eax,8)
8010679b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679e:	0f b6 14 c5 04 4a 11 	movzbl -0x7feeb5fc(,%eax,8),%edx
801067a5:	80 
801067a6:	83 e2 1f             	and    $0x1f,%edx
801067a9:	88 14 c5 04 4a 11 80 	mov    %dl,-0x7feeb5fc(,%eax,8)
801067b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b3:	0f b6 14 c5 05 4a 11 	movzbl -0x7feeb5fb(,%eax,8),%edx
801067ba:	80 
801067bb:	83 e2 f0             	and    $0xfffffff0,%edx
801067be:	83 ca 0e             	or     $0xe,%edx
801067c1:	88 14 c5 05 4a 11 80 	mov    %dl,-0x7feeb5fb(,%eax,8)
801067c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cb:	0f b6 14 c5 05 4a 11 	movzbl -0x7feeb5fb(,%eax,8),%edx
801067d2:	80 
801067d3:	83 e2 ef             	and    $0xffffffef,%edx
801067d6:	88 14 c5 05 4a 11 80 	mov    %dl,-0x7feeb5fb(,%eax,8)
801067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e0:	0f b6 14 c5 05 4a 11 	movzbl -0x7feeb5fb(,%eax,8),%edx
801067e7:	80 
801067e8:	83 e2 9f             	and    $0xffffff9f,%edx
801067eb:	88 14 c5 05 4a 11 80 	mov    %dl,-0x7feeb5fb(,%eax,8)
801067f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f5:	0f b6 14 c5 05 4a 11 	movzbl -0x7feeb5fb(,%eax,8),%edx
801067fc:	80 
801067fd:	83 ca 80             	or     $0xffffff80,%edx
80106800:	88 14 c5 05 4a 11 80 	mov    %dl,-0x7feeb5fb(,%eax,8)
80106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680a:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106811:	c1 e8 10             	shr    $0x10,%eax
80106814:	89 c2                	mov    %eax,%edx
80106816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106819:	66 89 14 c5 06 4a 11 	mov    %dx,-0x7feeb5fa(,%eax,8)
80106820:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106821:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106825:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010682c:	0f 8e 30 ff ff ff    	jle    80106762 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106832:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106837:	66 a3 00 4c 11 80    	mov    %ax,0x80114c00
8010683d:	66 c7 05 02 4c 11 80 	movw   $0x8,0x80114c02
80106844:	08 00 
80106846:	0f b6 05 04 4c 11 80 	movzbl 0x80114c04,%eax
8010684d:	83 e0 e0             	and    $0xffffffe0,%eax
80106850:	a2 04 4c 11 80       	mov    %al,0x80114c04
80106855:	0f b6 05 04 4c 11 80 	movzbl 0x80114c04,%eax
8010685c:	83 e0 1f             	and    $0x1f,%eax
8010685f:	a2 04 4c 11 80       	mov    %al,0x80114c04
80106864:	0f b6 05 05 4c 11 80 	movzbl 0x80114c05,%eax
8010686b:	83 c8 0f             	or     $0xf,%eax
8010686e:	a2 05 4c 11 80       	mov    %al,0x80114c05
80106873:	0f b6 05 05 4c 11 80 	movzbl 0x80114c05,%eax
8010687a:	83 e0 ef             	and    $0xffffffef,%eax
8010687d:	a2 05 4c 11 80       	mov    %al,0x80114c05
80106882:	0f b6 05 05 4c 11 80 	movzbl 0x80114c05,%eax
80106889:	83 c8 60             	or     $0x60,%eax
8010688c:	a2 05 4c 11 80       	mov    %al,0x80114c05
80106891:	0f b6 05 05 4c 11 80 	movzbl 0x80114c05,%eax
80106898:	83 c8 80             	or     $0xffffff80,%eax
8010689b:	a2 05 4c 11 80       	mov    %al,0x80114c05
801068a0:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801068a5:	c1 e8 10             	shr    $0x10,%eax
801068a8:	66 a3 06 4c 11 80    	mov    %ax,0x80114c06
  
  initlock(&tickslock, "time");
801068ae:	83 ec 08             	sub    $0x8,%esp
801068b1:	68 3c 8a 10 80       	push   $0x80108a3c
801068b6:	68 c0 49 11 80       	push   $0x801149c0
801068bb:	e8 86 e7 ff ff       	call   80105046 <initlock>
801068c0:	83 c4 10             	add    $0x10,%esp
}
801068c3:	c9                   	leave  
801068c4:	c3                   	ret    

801068c5 <idtinit>:

void
idtinit(void)
{
801068c5:	55                   	push   %ebp
801068c6:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801068c8:	68 00 08 00 00       	push   $0x800
801068cd:	68 00 4a 11 80       	push   $0x80114a00
801068d2:	e8 3f fe ff ff       	call   80106716 <lidt>
801068d7:	83 c4 08             	add    $0x8,%esp
}
801068da:	c9                   	leave  
801068db:	c3                   	ret    

801068dc <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068dc:	55                   	push   %ebp
801068dd:	89 e5                	mov    %esp,%ebp
801068df:	57                   	push   %edi
801068e0:	56                   	push   %esi
801068e1:	53                   	push   %ebx
801068e2:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801068e5:	8b 45 08             	mov    0x8(%ebp),%eax
801068e8:	8b 40 30             	mov    0x30(%eax),%eax
801068eb:	83 f8 40             	cmp    $0x40,%eax
801068ee:	75 3f                	jne    8010692f <trap+0x53>
    if(proc->killed)
801068f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068f6:	8b 40 24             	mov    0x24(%eax),%eax
801068f9:	85 c0                	test   %eax,%eax
801068fb:	74 05                	je     80106902 <trap+0x26>
      exit();
801068fd:	e8 00 e0 ff ff       	call   80104902 <exit>
    proc->tf = tf;
80106902:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106908:	8b 55 08             	mov    0x8(%ebp),%edx
8010690b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010690e:	e8 8f ed ff ff       	call   801056a2 <syscall>
    if(proc->killed)
80106913:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106919:	8b 40 24             	mov    0x24(%eax),%eax
8010691c:	85 c0                	test   %eax,%eax
8010691e:	74 0a                	je     8010692a <trap+0x4e>
      exit();
80106920:	e8 dd df ff ff       	call   80104902 <exit>
    return;
80106925:	e9 14 02 00 00       	jmp    80106b3e <trap+0x262>
8010692a:	e9 0f 02 00 00       	jmp    80106b3e <trap+0x262>
  }

  switch(tf->trapno){
8010692f:	8b 45 08             	mov    0x8(%ebp),%eax
80106932:	8b 40 30             	mov    0x30(%eax),%eax
80106935:	83 e8 20             	sub    $0x20,%eax
80106938:	83 f8 1f             	cmp    $0x1f,%eax
8010693b:	0f 87 c0 00 00 00    	ja     80106a01 <trap+0x125>
80106941:	8b 04 85 e4 8a 10 80 	mov    -0x7fef751c(,%eax,4),%eax
80106948:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010694a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106950:	0f b6 00             	movzbl (%eax),%eax
80106953:	84 c0                	test   %al,%al
80106955:	75 3d                	jne    80106994 <trap+0xb8>
      acquire(&tickslock);
80106957:	83 ec 0c             	sub    $0xc,%esp
8010695a:	68 c0 49 11 80       	push   $0x801149c0
8010695f:	e8 03 e7 ff ff       	call   80105067 <acquire>
80106964:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106967:	a1 00 52 11 80       	mov    0x80115200,%eax
8010696c:	83 c0 01             	add    $0x1,%eax
8010696f:	a3 00 52 11 80       	mov    %eax,0x80115200
      wakeup(&ticks);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	68 00 52 11 80       	push   $0x80115200
8010697c:	e8 8f e4 ff ff       	call   80104e10 <wakeup>
80106981:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106984:	83 ec 0c             	sub    $0xc,%esp
80106987:	68 c0 49 11 80       	push   $0x801149c0
8010698c:	e8 3c e7 ff ff       	call   801050cd <release>
80106991:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106994:	e8 c9 c6 ff ff       	call   80103062 <lapiceoi>
    break;
80106999:	e9 1c 01 00 00       	jmp    80106aba <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010699e:	e8 e0 be ff ff       	call   80102883 <ideintr>
    lapiceoi();
801069a3:	e8 ba c6 ff ff       	call   80103062 <lapiceoi>
    break;
801069a8:	e9 0d 01 00 00       	jmp    80106aba <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069ad:	e8 b7 c4 ff ff       	call   80102e69 <kbdintr>
    lapiceoi();
801069b2:	e8 ab c6 ff ff       	call   80103062 <lapiceoi>
    break;
801069b7:	e9 fe 00 00 00       	jmp    80106aba <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069bc:	e8 5a 03 00 00       	call   80106d1b <uartintr>
    lapiceoi();
801069c1:	e8 9c c6 ff ff       	call   80103062 <lapiceoi>
    break;
801069c6:	e9 ef 00 00 00       	jmp    80106aba <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069cb:	8b 45 08             	mov    0x8(%ebp),%eax
801069ce:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801069d1:	8b 45 08             	mov    0x8(%ebp),%eax
801069d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069d8:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801069db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069e1:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069e4:	0f b6 c0             	movzbl %al,%eax
801069e7:	51                   	push   %ecx
801069e8:	52                   	push   %edx
801069e9:	50                   	push   %eax
801069ea:	68 44 8a 10 80       	push   $0x80108a44
801069ef:	e8 cb 99 ff ff       	call   801003bf <cprintf>
801069f4:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801069f7:	e8 66 c6 ff ff       	call   80103062 <lapiceoi>
    break;
801069fc:	e9 b9 00 00 00       	jmp    80106aba <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a07:	85 c0                	test   %eax,%eax
80106a09:	74 11                	je     80106a1c <trap+0x140>
80106a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a12:	0f b7 c0             	movzwl %ax,%eax
80106a15:	83 e0 03             	and    $0x3,%eax
80106a18:	85 c0                	test   %eax,%eax
80106a1a:	75 40                	jne    80106a5c <trap+0x180>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a1c:	e8 1e fd ff ff       	call   8010673f <rcr2>
80106a21:	89 c3                	mov    %eax,%ebx
80106a23:	8b 45 08             	mov    0x8(%ebp),%eax
80106a26:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a2f:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a32:	0f b6 d0             	movzbl %al,%edx
80106a35:	8b 45 08             	mov    0x8(%ebp),%eax
80106a38:	8b 40 30             	mov    0x30(%eax),%eax
80106a3b:	83 ec 0c             	sub    $0xc,%esp
80106a3e:	53                   	push   %ebx
80106a3f:	51                   	push   %ecx
80106a40:	52                   	push   %edx
80106a41:	50                   	push   %eax
80106a42:	68 68 8a 10 80       	push   $0x80108a68
80106a47:	e8 73 99 ff ff       	call   801003bf <cprintf>
80106a4c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106a4f:	83 ec 0c             	sub    $0xc,%esp
80106a52:	68 9a 8a 10 80       	push   $0x80108a9a
80106a57:	e8 00 9b ff ff       	call   8010055c <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a5c:	e8 de fc ff ff       	call   8010673f <rcr2>
80106a61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a64:	8b 45 08             	mov    0x8(%ebp),%eax
80106a67:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a6a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a70:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a73:	0f b6 d8             	movzbl %al,%ebx
80106a76:	8b 45 08             	mov    0x8(%ebp),%eax
80106a79:	8b 48 34             	mov    0x34(%eax),%ecx
80106a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7f:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a88:	8d 78 6c             	lea    0x6c(%eax),%edi
80106a8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a91:	8b 40 10             	mov    0x10(%eax),%eax
80106a94:	ff 75 e4             	pushl  -0x1c(%ebp)
80106a97:	56                   	push   %esi
80106a98:	53                   	push   %ebx
80106a99:	51                   	push   %ecx
80106a9a:	52                   	push   %edx
80106a9b:	57                   	push   %edi
80106a9c:	50                   	push   %eax
80106a9d:	68 a0 8a 10 80       	push   $0x80108aa0
80106aa2:	e8 18 99 ff ff       	call   801003bf <cprintf>
80106aa7:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106aaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ab7:	eb 01                	jmp    80106aba <trap+0x1de>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106ab9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106aba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac0:	85 c0                	test   %eax,%eax
80106ac2:	74 24                	je     80106ae8 <trap+0x20c>
80106ac4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aca:	8b 40 24             	mov    0x24(%eax),%eax
80106acd:	85 c0                	test   %eax,%eax
80106acf:	74 17                	je     80106ae8 <trap+0x20c>
80106ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ad8:	0f b7 c0             	movzwl %ax,%eax
80106adb:	83 e0 03             	and    $0x3,%eax
80106ade:	83 f8 03             	cmp    $0x3,%eax
80106ae1:	75 05                	jne    80106ae8 <trap+0x20c>
    exit();
80106ae3:	e8 1a de ff ff       	call   80104902 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ae8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aee:	85 c0                	test   %eax,%eax
80106af0:	74 1e                	je     80106b10 <trap+0x234>
80106af2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af8:	8b 40 0c             	mov    0xc(%eax),%eax
80106afb:	83 f8 04             	cmp    $0x4,%eax
80106afe:	75 10                	jne    80106b10 <trap+0x234>
80106b00:	8b 45 08             	mov    0x8(%ebp),%eax
80106b03:	8b 40 30             	mov    0x30(%eax),%eax
80106b06:	83 f8 20             	cmp    $0x20,%eax
80106b09:	75 05                	jne    80106b10 <trap+0x234>
    yield();
80106b0b:	e8 ad e1 ff ff       	call   80104cbd <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b16:	85 c0                	test   %eax,%eax
80106b18:	74 24                	je     80106b3e <trap+0x262>
80106b1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b20:	8b 40 24             	mov    0x24(%eax),%eax
80106b23:	85 c0                	test   %eax,%eax
80106b25:	74 17                	je     80106b3e <trap+0x262>
80106b27:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b2e:	0f b7 c0             	movzwl %ax,%eax
80106b31:	83 e0 03             	and    $0x3,%eax
80106b34:	83 f8 03             	cmp    $0x3,%eax
80106b37:	75 05                	jne    80106b3e <trap+0x262>
    exit();
80106b39:	e8 c4 dd ff ff       	call   80104902 <exit>
}
80106b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b41:	5b                   	pop    %ebx
80106b42:	5e                   	pop    %esi
80106b43:	5f                   	pop    %edi
80106b44:	5d                   	pop    %ebp
80106b45:	c3                   	ret    

80106b46 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b46:	55                   	push   %ebp
80106b47:	89 e5                	mov    %esp,%ebp
80106b49:	83 ec 14             	sub    $0x14,%esp
80106b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b53:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b57:	89 c2                	mov    %eax,%edx
80106b59:	ec                   	in     (%dx),%al
80106b5a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b5d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b61:	c9                   	leave  
80106b62:	c3                   	ret    

80106b63 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b63:	55                   	push   %ebp
80106b64:	89 e5                	mov    %esp,%ebp
80106b66:	83 ec 08             	sub    $0x8,%esp
80106b69:	8b 55 08             	mov    0x8(%ebp),%edx
80106b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b6f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b73:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b76:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b7a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b7e:	ee                   	out    %al,(%dx)
}
80106b7f:	c9                   	leave  
80106b80:	c3                   	ret    

80106b81 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b81:	55                   	push   %ebp
80106b82:	89 e5                	mov    %esp,%ebp
80106b84:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b87:	6a 00                	push   $0x0
80106b89:	68 fa 03 00 00       	push   $0x3fa
80106b8e:	e8 d0 ff ff ff       	call   80106b63 <outb>
80106b93:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b96:	68 80 00 00 00       	push   $0x80
80106b9b:	68 fb 03 00 00       	push   $0x3fb
80106ba0:	e8 be ff ff ff       	call   80106b63 <outb>
80106ba5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106ba8:	6a 0c                	push   $0xc
80106baa:	68 f8 03 00 00       	push   $0x3f8
80106baf:	e8 af ff ff ff       	call   80106b63 <outb>
80106bb4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106bb7:	6a 00                	push   $0x0
80106bb9:	68 f9 03 00 00       	push   $0x3f9
80106bbe:	e8 a0 ff ff ff       	call   80106b63 <outb>
80106bc3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106bc6:	6a 03                	push   $0x3
80106bc8:	68 fb 03 00 00       	push   $0x3fb
80106bcd:	e8 91 ff ff ff       	call   80106b63 <outb>
80106bd2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106bd5:	6a 00                	push   $0x0
80106bd7:	68 fc 03 00 00       	push   $0x3fc
80106bdc:	e8 82 ff ff ff       	call   80106b63 <outb>
80106be1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106be4:	6a 01                	push   $0x1
80106be6:	68 f9 03 00 00       	push   $0x3f9
80106beb:	e8 73 ff ff ff       	call   80106b63 <outb>
80106bf0:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bf3:	68 fd 03 00 00       	push   $0x3fd
80106bf8:	e8 49 ff ff ff       	call   80106b46 <inb>
80106bfd:	83 c4 04             	add    $0x4,%esp
80106c00:	3c ff                	cmp    $0xff,%al
80106c02:	75 02                	jne    80106c06 <uartinit+0x85>
    return;
80106c04:	eb 6c                	jmp    80106c72 <uartinit+0xf1>
  uart = 1;
80106c06:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106c0d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c10:	68 fa 03 00 00       	push   $0x3fa
80106c15:	e8 2c ff ff ff       	call   80106b46 <inb>
80106c1a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c1d:	68 f8 03 00 00       	push   $0x3f8
80106c22:	e8 1f ff ff ff       	call   80106b46 <inb>
80106c27:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106c2a:	83 ec 0c             	sub    $0xc,%esp
80106c2d:	6a 04                	push   $0x4
80106c2f:	e8 33 d3 ff ff       	call   80103f67 <picenable>
80106c34:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106c37:	83 ec 08             	sub    $0x8,%esp
80106c3a:	6a 00                	push   $0x0
80106c3c:	6a 04                	push   $0x4
80106c3e:	e8 de be ff ff       	call   80102b21 <ioapicenable>
80106c43:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c46:	c7 45 f4 64 8b 10 80 	movl   $0x80108b64,-0xc(%ebp)
80106c4d:	eb 19                	jmp    80106c68 <uartinit+0xe7>
    uartputc(*p);
80106c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c52:	0f b6 00             	movzbl (%eax),%eax
80106c55:	0f be c0             	movsbl %al,%eax
80106c58:	83 ec 0c             	sub    $0xc,%esp
80106c5b:	50                   	push   %eax
80106c5c:	e8 13 00 00 00       	call   80106c74 <uartputc>
80106c61:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6b:	0f b6 00             	movzbl (%eax),%eax
80106c6e:	84 c0                	test   %al,%al
80106c70:	75 dd                	jne    80106c4f <uartinit+0xce>
    uartputc(*p);
}
80106c72:	c9                   	leave  
80106c73:	c3                   	ret    

80106c74 <uartputc>:

void
uartputc(int c)
{
80106c74:	55                   	push   %ebp
80106c75:	89 e5                	mov    %esp,%ebp
80106c77:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c7a:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106c7f:	85 c0                	test   %eax,%eax
80106c81:	75 02                	jne    80106c85 <uartputc+0x11>
    return;
80106c83:	eb 51                	jmp    80106cd6 <uartputc+0x62>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c8c:	eb 11                	jmp    80106c9f <uartputc+0x2b>
    microdelay(10);
80106c8e:	83 ec 0c             	sub    $0xc,%esp
80106c91:	6a 0a                	push   $0xa
80106c93:	e8 e4 c3 ff ff       	call   8010307c <microdelay>
80106c98:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c9f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ca3:	7f 1a                	jg     80106cbf <uartputc+0x4b>
80106ca5:	83 ec 0c             	sub    $0xc,%esp
80106ca8:	68 fd 03 00 00       	push   $0x3fd
80106cad:	e8 94 fe ff ff       	call   80106b46 <inb>
80106cb2:	83 c4 10             	add    $0x10,%esp
80106cb5:	0f b6 c0             	movzbl %al,%eax
80106cb8:	83 e0 20             	and    $0x20,%eax
80106cbb:	85 c0                	test   %eax,%eax
80106cbd:	74 cf                	je     80106c8e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc2:	0f b6 c0             	movzbl %al,%eax
80106cc5:	83 ec 08             	sub    $0x8,%esp
80106cc8:	50                   	push   %eax
80106cc9:	68 f8 03 00 00       	push   $0x3f8
80106cce:	e8 90 fe ff ff       	call   80106b63 <outb>
80106cd3:	83 c4 10             	add    $0x10,%esp
}
80106cd6:	c9                   	leave  
80106cd7:	c3                   	ret    

80106cd8 <uartgetc>:

static int
uartgetc(void)
{
80106cd8:	55                   	push   %ebp
80106cd9:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cdb:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106ce0:	85 c0                	test   %eax,%eax
80106ce2:	75 07                	jne    80106ceb <uartgetc+0x13>
    return -1;
80106ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce9:	eb 2e                	jmp    80106d19 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106ceb:	68 fd 03 00 00       	push   $0x3fd
80106cf0:	e8 51 fe ff ff       	call   80106b46 <inb>
80106cf5:	83 c4 04             	add    $0x4,%esp
80106cf8:	0f b6 c0             	movzbl %al,%eax
80106cfb:	83 e0 01             	and    $0x1,%eax
80106cfe:	85 c0                	test   %eax,%eax
80106d00:	75 07                	jne    80106d09 <uartgetc+0x31>
    return -1;
80106d02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d07:	eb 10                	jmp    80106d19 <uartgetc+0x41>
  return inb(COM1+0);
80106d09:	68 f8 03 00 00       	push   $0x3f8
80106d0e:	e8 33 fe ff ff       	call   80106b46 <inb>
80106d13:	83 c4 04             	add    $0x4,%esp
80106d16:	0f b6 c0             	movzbl %al,%eax
}
80106d19:	c9                   	leave  
80106d1a:	c3                   	ret    

80106d1b <uartintr>:

void
uartintr(void)
{
80106d1b:	55                   	push   %ebp
80106d1c:	89 e5                	mov    %esp,%ebp
80106d1e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d21:	83 ec 0c             	sub    $0xc,%esp
80106d24:	68 d8 6c 10 80       	push   $0x80106cd8
80106d29:	e8 a3 9a ff ff       	call   801007d1 <consoleintr>
80106d2e:	83 c4 10             	add    $0x10,%esp
}
80106d31:	c9                   	leave  
80106d32:	c3                   	ret    

80106d33 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $0
80106d35:	6a 00                	push   $0x0
  jmp alltraps
80106d37:	e9 af f9 ff ff       	jmp    801066eb <alltraps>

80106d3c <vector1>:
.globl vector1
vector1:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $1
80106d3e:	6a 01                	push   $0x1
  jmp alltraps
80106d40:	e9 a6 f9 ff ff       	jmp    801066eb <alltraps>

80106d45 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $2
80106d47:	6a 02                	push   $0x2
  jmp alltraps
80106d49:	e9 9d f9 ff ff       	jmp    801066eb <alltraps>

80106d4e <vector3>:
.globl vector3
vector3:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $3
80106d50:	6a 03                	push   $0x3
  jmp alltraps
80106d52:	e9 94 f9 ff ff       	jmp    801066eb <alltraps>

80106d57 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $4
80106d59:	6a 04                	push   $0x4
  jmp alltraps
80106d5b:	e9 8b f9 ff ff       	jmp    801066eb <alltraps>

80106d60 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $5
80106d62:	6a 05                	push   $0x5
  jmp alltraps
80106d64:	e9 82 f9 ff ff       	jmp    801066eb <alltraps>

80106d69 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $6
80106d6b:	6a 06                	push   $0x6
  jmp alltraps
80106d6d:	e9 79 f9 ff ff       	jmp    801066eb <alltraps>

80106d72 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $7
80106d74:	6a 07                	push   $0x7
  jmp alltraps
80106d76:	e9 70 f9 ff ff       	jmp    801066eb <alltraps>

80106d7b <vector8>:
.globl vector8
vector8:
  pushl $8
80106d7b:	6a 08                	push   $0x8
  jmp alltraps
80106d7d:	e9 69 f9 ff ff       	jmp    801066eb <alltraps>

80106d82 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $9
80106d84:	6a 09                	push   $0x9
  jmp alltraps
80106d86:	e9 60 f9 ff ff       	jmp    801066eb <alltraps>

80106d8b <vector10>:
.globl vector10
vector10:
  pushl $10
80106d8b:	6a 0a                	push   $0xa
  jmp alltraps
80106d8d:	e9 59 f9 ff ff       	jmp    801066eb <alltraps>

80106d92 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d92:	6a 0b                	push   $0xb
  jmp alltraps
80106d94:	e9 52 f9 ff ff       	jmp    801066eb <alltraps>

80106d99 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d99:	6a 0c                	push   $0xc
  jmp alltraps
80106d9b:	e9 4b f9 ff ff       	jmp    801066eb <alltraps>

80106da0 <vector13>:
.globl vector13
vector13:
  pushl $13
80106da0:	6a 0d                	push   $0xd
  jmp alltraps
80106da2:	e9 44 f9 ff ff       	jmp    801066eb <alltraps>

80106da7 <vector14>:
.globl vector14
vector14:
  pushl $14
80106da7:	6a 0e                	push   $0xe
  jmp alltraps
80106da9:	e9 3d f9 ff ff       	jmp    801066eb <alltraps>

80106dae <vector15>:
.globl vector15
vector15:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $15
80106db0:	6a 0f                	push   $0xf
  jmp alltraps
80106db2:	e9 34 f9 ff ff       	jmp    801066eb <alltraps>

80106db7 <vector16>:
.globl vector16
vector16:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $16
80106db9:	6a 10                	push   $0x10
  jmp alltraps
80106dbb:	e9 2b f9 ff ff       	jmp    801066eb <alltraps>

80106dc0 <vector17>:
.globl vector17
vector17:
  pushl $17
80106dc0:	6a 11                	push   $0x11
  jmp alltraps
80106dc2:	e9 24 f9 ff ff       	jmp    801066eb <alltraps>

80106dc7 <vector18>:
.globl vector18
vector18:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $18
80106dc9:	6a 12                	push   $0x12
  jmp alltraps
80106dcb:	e9 1b f9 ff ff       	jmp    801066eb <alltraps>

80106dd0 <vector19>:
.globl vector19
vector19:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $19
80106dd2:	6a 13                	push   $0x13
  jmp alltraps
80106dd4:	e9 12 f9 ff ff       	jmp    801066eb <alltraps>

80106dd9 <vector20>:
.globl vector20
vector20:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $20
80106ddb:	6a 14                	push   $0x14
  jmp alltraps
80106ddd:	e9 09 f9 ff ff       	jmp    801066eb <alltraps>

80106de2 <vector21>:
.globl vector21
vector21:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $21
80106de4:	6a 15                	push   $0x15
  jmp alltraps
80106de6:	e9 00 f9 ff ff       	jmp    801066eb <alltraps>

80106deb <vector22>:
.globl vector22
vector22:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $22
80106ded:	6a 16                	push   $0x16
  jmp alltraps
80106def:	e9 f7 f8 ff ff       	jmp    801066eb <alltraps>

80106df4 <vector23>:
.globl vector23
vector23:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $23
80106df6:	6a 17                	push   $0x17
  jmp alltraps
80106df8:	e9 ee f8 ff ff       	jmp    801066eb <alltraps>

80106dfd <vector24>:
.globl vector24
vector24:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $24
80106dff:	6a 18                	push   $0x18
  jmp alltraps
80106e01:	e9 e5 f8 ff ff       	jmp    801066eb <alltraps>

80106e06 <vector25>:
.globl vector25
vector25:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $25
80106e08:	6a 19                	push   $0x19
  jmp alltraps
80106e0a:	e9 dc f8 ff ff       	jmp    801066eb <alltraps>

80106e0f <vector26>:
.globl vector26
vector26:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $26
80106e11:	6a 1a                	push   $0x1a
  jmp alltraps
80106e13:	e9 d3 f8 ff ff       	jmp    801066eb <alltraps>

80106e18 <vector27>:
.globl vector27
vector27:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $27
80106e1a:	6a 1b                	push   $0x1b
  jmp alltraps
80106e1c:	e9 ca f8 ff ff       	jmp    801066eb <alltraps>

80106e21 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $28
80106e23:	6a 1c                	push   $0x1c
  jmp alltraps
80106e25:	e9 c1 f8 ff ff       	jmp    801066eb <alltraps>

80106e2a <vector29>:
.globl vector29
vector29:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $29
80106e2c:	6a 1d                	push   $0x1d
  jmp alltraps
80106e2e:	e9 b8 f8 ff ff       	jmp    801066eb <alltraps>

80106e33 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $30
80106e35:	6a 1e                	push   $0x1e
  jmp alltraps
80106e37:	e9 af f8 ff ff       	jmp    801066eb <alltraps>

80106e3c <vector31>:
.globl vector31
vector31:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $31
80106e3e:	6a 1f                	push   $0x1f
  jmp alltraps
80106e40:	e9 a6 f8 ff ff       	jmp    801066eb <alltraps>

80106e45 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $32
80106e47:	6a 20                	push   $0x20
  jmp alltraps
80106e49:	e9 9d f8 ff ff       	jmp    801066eb <alltraps>

80106e4e <vector33>:
.globl vector33
vector33:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $33
80106e50:	6a 21                	push   $0x21
  jmp alltraps
80106e52:	e9 94 f8 ff ff       	jmp    801066eb <alltraps>

80106e57 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $34
80106e59:	6a 22                	push   $0x22
  jmp alltraps
80106e5b:	e9 8b f8 ff ff       	jmp    801066eb <alltraps>

80106e60 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $35
80106e62:	6a 23                	push   $0x23
  jmp alltraps
80106e64:	e9 82 f8 ff ff       	jmp    801066eb <alltraps>

80106e69 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $36
80106e6b:	6a 24                	push   $0x24
  jmp alltraps
80106e6d:	e9 79 f8 ff ff       	jmp    801066eb <alltraps>

80106e72 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $37
80106e74:	6a 25                	push   $0x25
  jmp alltraps
80106e76:	e9 70 f8 ff ff       	jmp    801066eb <alltraps>

80106e7b <vector38>:
.globl vector38
vector38:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $38
80106e7d:	6a 26                	push   $0x26
  jmp alltraps
80106e7f:	e9 67 f8 ff ff       	jmp    801066eb <alltraps>

80106e84 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $39
80106e86:	6a 27                	push   $0x27
  jmp alltraps
80106e88:	e9 5e f8 ff ff       	jmp    801066eb <alltraps>

80106e8d <vector40>:
.globl vector40
vector40:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $40
80106e8f:	6a 28                	push   $0x28
  jmp alltraps
80106e91:	e9 55 f8 ff ff       	jmp    801066eb <alltraps>

80106e96 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $41
80106e98:	6a 29                	push   $0x29
  jmp alltraps
80106e9a:	e9 4c f8 ff ff       	jmp    801066eb <alltraps>

80106e9f <vector42>:
.globl vector42
vector42:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $42
80106ea1:	6a 2a                	push   $0x2a
  jmp alltraps
80106ea3:	e9 43 f8 ff ff       	jmp    801066eb <alltraps>

80106ea8 <vector43>:
.globl vector43
vector43:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $43
80106eaa:	6a 2b                	push   $0x2b
  jmp alltraps
80106eac:	e9 3a f8 ff ff       	jmp    801066eb <alltraps>

80106eb1 <vector44>:
.globl vector44
vector44:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $44
80106eb3:	6a 2c                	push   $0x2c
  jmp alltraps
80106eb5:	e9 31 f8 ff ff       	jmp    801066eb <alltraps>

80106eba <vector45>:
.globl vector45
vector45:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $45
80106ebc:	6a 2d                	push   $0x2d
  jmp alltraps
80106ebe:	e9 28 f8 ff ff       	jmp    801066eb <alltraps>

80106ec3 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $46
80106ec5:	6a 2e                	push   $0x2e
  jmp alltraps
80106ec7:	e9 1f f8 ff ff       	jmp    801066eb <alltraps>

80106ecc <vector47>:
.globl vector47
vector47:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $47
80106ece:	6a 2f                	push   $0x2f
  jmp alltraps
80106ed0:	e9 16 f8 ff ff       	jmp    801066eb <alltraps>

80106ed5 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $48
80106ed7:	6a 30                	push   $0x30
  jmp alltraps
80106ed9:	e9 0d f8 ff ff       	jmp    801066eb <alltraps>

80106ede <vector49>:
.globl vector49
vector49:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $49
80106ee0:	6a 31                	push   $0x31
  jmp alltraps
80106ee2:	e9 04 f8 ff ff       	jmp    801066eb <alltraps>

80106ee7 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $50
80106ee9:	6a 32                	push   $0x32
  jmp alltraps
80106eeb:	e9 fb f7 ff ff       	jmp    801066eb <alltraps>

80106ef0 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $51
80106ef2:	6a 33                	push   $0x33
  jmp alltraps
80106ef4:	e9 f2 f7 ff ff       	jmp    801066eb <alltraps>

80106ef9 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $52
80106efb:	6a 34                	push   $0x34
  jmp alltraps
80106efd:	e9 e9 f7 ff ff       	jmp    801066eb <alltraps>

80106f02 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $53
80106f04:	6a 35                	push   $0x35
  jmp alltraps
80106f06:	e9 e0 f7 ff ff       	jmp    801066eb <alltraps>

80106f0b <vector54>:
.globl vector54
vector54:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $54
80106f0d:	6a 36                	push   $0x36
  jmp alltraps
80106f0f:	e9 d7 f7 ff ff       	jmp    801066eb <alltraps>

80106f14 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $55
80106f16:	6a 37                	push   $0x37
  jmp alltraps
80106f18:	e9 ce f7 ff ff       	jmp    801066eb <alltraps>

80106f1d <vector56>:
.globl vector56
vector56:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $56
80106f1f:	6a 38                	push   $0x38
  jmp alltraps
80106f21:	e9 c5 f7 ff ff       	jmp    801066eb <alltraps>

80106f26 <vector57>:
.globl vector57
vector57:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $57
80106f28:	6a 39                	push   $0x39
  jmp alltraps
80106f2a:	e9 bc f7 ff ff       	jmp    801066eb <alltraps>

80106f2f <vector58>:
.globl vector58
vector58:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $58
80106f31:	6a 3a                	push   $0x3a
  jmp alltraps
80106f33:	e9 b3 f7 ff ff       	jmp    801066eb <alltraps>

80106f38 <vector59>:
.globl vector59
vector59:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $59
80106f3a:	6a 3b                	push   $0x3b
  jmp alltraps
80106f3c:	e9 aa f7 ff ff       	jmp    801066eb <alltraps>

80106f41 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $60
80106f43:	6a 3c                	push   $0x3c
  jmp alltraps
80106f45:	e9 a1 f7 ff ff       	jmp    801066eb <alltraps>

80106f4a <vector61>:
.globl vector61
vector61:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $61
80106f4c:	6a 3d                	push   $0x3d
  jmp alltraps
80106f4e:	e9 98 f7 ff ff       	jmp    801066eb <alltraps>

80106f53 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $62
80106f55:	6a 3e                	push   $0x3e
  jmp alltraps
80106f57:	e9 8f f7 ff ff       	jmp    801066eb <alltraps>

80106f5c <vector63>:
.globl vector63
vector63:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $63
80106f5e:	6a 3f                	push   $0x3f
  jmp alltraps
80106f60:	e9 86 f7 ff ff       	jmp    801066eb <alltraps>

80106f65 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $64
80106f67:	6a 40                	push   $0x40
  jmp alltraps
80106f69:	e9 7d f7 ff ff       	jmp    801066eb <alltraps>

80106f6e <vector65>:
.globl vector65
vector65:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $65
80106f70:	6a 41                	push   $0x41
  jmp alltraps
80106f72:	e9 74 f7 ff ff       	jmp    801066eb <alltraps>

80106f77 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $66
80106f79:	6a 42                	push   $0x42
  jmp alltraps
80106f7b:	e9 6b f7 ff ff       	jmp    801066eb <alltraps>

80106f80 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $67
80106f82:	6a 43                	push   $0x43
  jmp alltraps
80106f84:	e9 62 f7 ff ff       	jmp    801066eb <alltraps>

80106f89 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $68
80106f8b:	6a 44                	push   $0x44
  jmp alltraps
80106f8d:	e9 59 f7 ff ff       	jmp    801066eb <alltraps>

80106f92 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $69
80106f94:	6a 45                	push   $0x45
  jmp alltraps
80106f96:	e9 50 f7 ff ff       	jmp    801066eb <alltraps>

80106f9b <vector70>:
.globl vector70
vector70:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $70
80106f9d:	6a 46                	push   $0x46
  jmp alltraps
80106f9f:	e9 47 f7 ff ff       	jmp    801066eb <alltraps>

80106fa4 <vector71>:
.globl vector71
vector71:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $71
80106fa6:	6a 47                	push   $0x47
  jmp alltraps
80106fa8:	e9 3e f7 ff ff       	jmp    801066eb <alltraps>

80106fad <vector72>:
.globl vector72
vector72:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $72
80106faf:	6a 48                	push   $0x48
  jmp alltraps
80106fb1:	e9 35 f7 ff ff       	jmp    801066eb <alltraps>

80106fb6 <vector73>:
.globl vector73
vector73:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $73
80106fb8:	6a 49                	push   $0x49
  jmp alltraps
80106fba:	e9 2c f7 ff ff       	jmp    801066eb <alltraps>

80106fbf <vector74>:
.globl vector74
vector74:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $74
80106fc1:	6a 4a                	push   $0x4a
  jmp alltraps
80106fc3:	e9 23 f7 ff ff       	jmp    801066eb <alltraps>

80106fc8 <vector75>:
.globl vector75
vector75:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $75
80106fca:	6a 4b                	push   $0x4b
  jmp alltraps
80106fcc:	e9 1a f7 ff ff       	jmp    801066eb <alltraps>

80106fd1 <vector76>:
.globl vector76
vector76:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $76
80106fd3:	6a 4c                	push   $0x4c
  jmp alltraps
80106fd5:	e9 11 f7 ff ff       	jmp    801066eb <alltraps>

80106fda <vector77>:
.globl vector77
vector77:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $77
80106fdc:	6a 4d                	push   $0x4d
  jmp alltraps
80106fde:	e9 08 f7 ff ff       	jmp    801066eb <alltraps>

80106fe3 <vector78>:
.globl vector78
vector78:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $78
80106fe5:	6a 4e                	push   $0x4e
  jmp alltraps
80106fe7:	e9 ff f6 ff ff       	jmp    801066eb <alltraps>

80106fec <vector79>:
.globl vector79
vector79:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $79
80106fee:	6a 4f                	push   $0x4f
  jmp alltraps
80106ff0:	e9 f6 f6 ff ff       	jmp    801066eb <alltraps>

80106ff5 <vector80>:
.globl vector80
vector80:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $80
80106ff7:	6a 50                	push   $0x50
  jmp alltraps
80106ff9:	e9 ed f6 ff ff       	jmp    801066eb <alltraps>

80106ffe <vector81>:
.globl vector81
vector81:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $81
80107000:	6a 51                	push   $0x51
  jmp alltraps
80107002:	e9 e4 f6 ff ff       	jmp    801066eb <alltraps>

80107007 <vector82>:
.globl vector82
vector82:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $82
80107009:	6a 52                	push   $0x52
  jmp alltraps
8010700b:	e9 db f6 ff ff       	jmp    801066eb <alltraps>

80107010 <vector83>:
.globl vector83
vector83:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $83
80107012:	6a 53                	push   $0x53
  jmp alltraps
80107014:	e9 d2 f6 ff ff       	jmp    801066eb <alltraps>

80107019 <vector84>:
.globl vector84
vector84:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $84
8010701b:	6a 54                	push   $0x54
  jmp alltraps
8010701d:	e9 c9 f6 ff ff       	jmp    801066eb <alltraps>

80107022 <vector85>:
.globl vector85
vector85:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $85
80107024:	6a 55                	push   $0x55
  jmp alltraps
80107026:	e9 c0 f6 ff ff       	jmp    801066eb <alltraps>

8010702b <vector86>:
.globl vector86
vector86:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $86
8010702d:	6a 56                	push   $0x56
  jmp alltraps
8010702f:	e9 b7 f6 ff ff       	jmp    801066eb <alltraps>

80107034 <vector87>:
.globl vector87
vector87:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $87
80107036:	6a 57                	push   $0x57
  jmp alltraps
80107038:	e9 ae f6 ff ff       	jmp    801066eb <alltraps>

8010703d <vector88>:
.globl vector88
vector88:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $88
8010703f:	6a 58                	push   $0x58
  jmp alltraps
80107041:	e9 a5 f6 ff ff       	jmp    801066eb <alltraps>

80107046 <vector89>:
.globl vector89
vector89:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $89
80107048:	6a 59                	push   $0x59
  jmp alltraps
8010704a:	e9 9c f6 ff ff       	jmp    801066eb <alltraps>

8010704f <vector90>:
.globl vector90
vector90:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $90
80107051:	6a 5a                	push   $0x5a
  jmp alltraps
80107053:	e9 93 f6 ff ff       	jmp    801066eb <alltraps>

80107058 <vector91>:
.globl vector91
vector91:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $91
8010705a:	6a 5b                	push   $0x5b
  jmp alltraps
8010705c:	e9 8a f6 ff ff       	jmp    801066eb <alltraps>

80107061 <vector92>:
.globl vector92
vector92:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $92
80107063:	6a 5c                	push   $0x5c
  jmp alltraps
80107065:	e9 81 f6 ff ff       	jmp    801066eb <alltraps>

8010706a <vector93>:
.globl vector93
vector93:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $93
8010706c:	6a 5d                	push   $0x5d
  jmp alltraps
8010706e:	e9 78 f6 ff ff       	jmp    801066eb <alltraps>

80107073 <vector94>:
.globl vector94
vector94:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $94
80107075:	6a 5e                	push   $0x5e
  jmp alltraps
80107077:	e9 6f f6 ff ff       	jmp    801066eb <alltraps>

8010707c <vector95>:
.globl vector95
vector95:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $95
8010707e:	6a 5f                	push   $0x5f
  jmp alltraps
80107080:	e9 66 f6 ff ff       	jmp    801066eb <alltraps>

80107085 <vector96>:
.globl vector96
vector96:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $96
80107087:	6a 60                	push   $0x60
  jmp alltraps
80107089:	e9 5d f6 ff ff       	jmp    801066eb <alltraps>

8010708e <vector97>:
.globl vector97
vector97:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $97
80107090:	6a 61                	push   $0x61
  jmp alltraps
80107092:	e9 54 f6 ff ff       	jmp    801066eb <alltraps>

80107097 <vector98>:
.globl vector98
vector98:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $98
80107099:	6a 62                	push   $0x62
  jmp alltraps
8010709b:	e9 4b f6 ff ff       	jmp    801066eb <alltraps>

801070a0 <vector99>:
.globl vector99
vector99:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $99
801070a2:	6a 63                	push   $0x63
  jmp alltraps
801070a4:	e9 42 f6 ff ff       	jmp    801066eb <alltraps>

801070a9 <vector100>:
.globl vector100
vector100:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $100
801070ab:	6a 64                	push   $0x64
  jmp alltraps
801070ad:	e9 39 f6 ff ff       	jmp    801066eb <alltraps>

801070b2 <vector101>:
.globl vector101
vector101:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $101
801070b4:	6a 65                	push   $0x65
  jmp alltraps
801070b6:	e9 30 f6 ff ff       	jmp    801066eb <alltraps>

801070bb <vector102>:
.globl vector102
vector102:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $102
801070bd:	6a 66                	push   $0x66
  jmp alltraps
801070bf:	e9 27 f6 ff ff       	jmp    801066eb <alltraps>

801070c4 <vector103>:
.globl vector103
vector103:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $103
801070c6:	6a 67                	push   $0x67
  jmp alltraps
801070c8:	e9 1e f6 ff ff       	jmp    801066eb <alltraps>

801070cd <vector104>:
.globl vector104
vector104:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $104
801070cf:	6a 68                	push   $0x68
  jmp alltraps
801070d1:	e9 15 f6 ff ff       	jmp    801066eb <alltraps>

801070d6 <vector105>:
.globl vector105
vector105:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $105
801070d8:	6a 69                	push   $0x69
  jmp alltraps
801070da:	e9 0c f6 ff ff       	jmp    801066eb <alltraps>

801070df <vector106>:
.globl vector106
vector106:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $106
801070e1:	6a 6a                	push   $0x6a
  jmp alltraps
801070e3:	e9 03 f6 ff ff       	jmp    801066eb <alltraps>

801070e8 <vector107>:
.globl vector107
vector107:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $107
801070ea:	6a 6b                	push   $0x6b
  jmp alltraps
801070ec:	e9 fa f5 ff ff       	jmp    801066eb <alltraps>

801070f1 <vector108>:
.globl vector108
vector108:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $108
801070f3:	6a 6c                	push   $0x6c
  jmp alltraps
801070f5:	e9 f1 f5 ff ff       	jmp    801066eb <alltraps>

801070fa <vector109>:
.globl vector109
vector109:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $109
801070fc:	6a 6d                	push   $0x6d
  jmp alltraps
801070fe:	e9 e8 f5 ff ff       	jmp    801066eb <alltraps>

80107103 <vector110>:
.globl vector110
vector110:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $110
80107105:	6a 6e                	push   $0x6e
  jmp alltraps
80107107:	e9 df f5 ff ff       	jmp    801066eb <alltraps>

8010710c <vector111>:
.globl vector111
vector111:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $111
8010710e:	6a 6f                	push   $0x6f
  jmp alltraps
80107110:	e9 d6 f5 ff ff       	jmp    801066eb <alltraps>

80107115 <vector112>:
.globl vector112
vector112:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $112
80107117:	6a 70                	push   $0x70
  jmp alltraps
80107119:	e9 cd f5 ff ff       	jmp    801066eb <alltraps>

8010711e <vector113>:
.globl vector113
vector113:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $113
80107120:	6a 71                	push   $0x71
  jmp alltraps
80107122:	e9 c4 f5 ff ff       	jmp    801066eb <alltraps>

80107127 <vector114>:
.globl vector114
vector114:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $114
80107129:	6a 72                	push   $0x72
  jmp alltraps
8010712b:	e9 bb f5 ff ff       	jmp    801066eb <alltraps>

80107130 <vector115>:
.globl vector115
vector115:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $115
80107132:	6a 73                	push   $0x73
  jmp alltraps
80107134:	e9 b2 f5 ff ff       	jmp    801066eb <alltraps>

80107139 <vector116>:
.globl vector116
vector116:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $116
8010713b:	6a 74                	push   $0x74
  jmp alltraps
8010713d:	e9 a9 f5 ff ff       	jmp    801066eb <alltraps>

80107142 <vector117>:
.globl vector117
vector117:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $117
80107144:	6a 75                	push   $0x75
  jmp alltraps
80107146:	e9 a0 f5 ff ff       	jmp    801066eb <alltraps>

8010714b <vector118>:
.globl vector118
vector118:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $118
8010714d:	6a 76                	push   $0x76
  jmp alltraps
8010714f:	e9 97 f5 ff ff       	jmp    801066eb <alltraps>

80107154 <vector119>:
.globl vector119
vector119:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $119
80107156:	6a 77                	push   $0x77
  jmp alltraps
80107158:	e9 8e f5 ff ff       	jmp    801066eb <alltraps>

8010715d <vector120>:
.globl vector120
vector120:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $120
8010715f:	6a 78                	push   $0x78
  jmp alltraps
80107161:	e9 85 f5 ff ff       	jmp    801066eb <alltraps>

80107166 <vector121>:
.globl vector121
vector121:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $121
80107168:	6a 79                	push   $0x79
  jmp alltraps
8010716a:	e9 7c f5 ff ff       	jmp    801066eb <alltraps>

8010716f <vector122>:
.globl vector122
vector122:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $122
80107171:	6a 7a                	push   $0x7a
  jmp alltraps
80107173:	e9 73 f5 ff ff       	jmp    801066eb <alltraps>

80107178 <vector123>:
.globl vector123
vector123:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $123
8010717a:	6a 7b                	push   $0x7b
  jmp alltraps
8010717c:	e9 6a f5 ff ff       	jmp    801066eb <alltraps>

80107181 <vector124>:
.globl vector124
vector124:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $124
80107183:	6a 7c                	push   $0x7c
  jmp alltraps
80107185:	e9 61 f5 ff ff       	jmp    801066eb <alltraps>

8010718a <vector125>:
.globl vector125
vector125:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $125
8010718c:	6a 7d                	push   $0x7d
  jmp alltraps
8010718e:	e9 58 f5 ff ff       	jmp    801066eb <alltraps>

80107193 <vector126>:
.globl vector126
vector126:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $126
80107195:	6a 7e                	push   $0x7e
  jmp alltraps
80107197:	e9 4f f5 ff ff       	jmp    801066eb <alltraps>

8010719c <vector127>:
.globl vector127
vector127:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $127
8010719e:	6a 7f                	push   $0x7f
  jmp alltraps
801071a0:	e9 46 f5 ff ff       	jmp    801066eb <alltraps>

801071a5 <vector128>:
.globl vector128
vector128:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $128
801071a7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071ac:	e9 3a f5 ff ff       	jmp    801066eb <alltraps>

801071b1 <vector129>:
.globl vector129
vector129:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $129
801071b3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071b8:	e9 2e f5 ff ff       	jmp    801066eb <alltraps>

801071bd <vector130>:
.globl vector130
vector130:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $130
801071bf:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071c4:	e9 22 f5 ff ff       	jmp    801066eb <alltraps>

801071c9 <vector131>:
.globl vector131
vector131:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $131
801071cb:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071d0:	e9 16 f5 ff ff       	jmp    801066eb <alltraps>

801071d5 <vector132>:
.globl vector132
vector132:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $132
801071d7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071dc:	e9 0a f5 ff ff       	jmp    801066eb <alltraps>

801071e1 <vector133>:
.globl vector133
vector133:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $133
801071e3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071e8:	e9 fe f4 ff ff       	jmp    801066eb <alltraps>

801071ed <vector134>:
.globl vector134
vector134:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $134
801071ef:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071f4:	e9 f2 f4 ff ff       	jmp    801066eb <alltraps>

801071f9 <vector135>:
.globl vector135
vector135:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $135
801071fb:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107200:	e9 e6 f4 ff ff       	jmp    801066eb <alltraps>

80107205 <vector136>:
.globl vector136
vector136:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $136
80107207:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010720c:	e9 da f4 ff ff       	jmp    801066eb <alltraps>

80107211 <vector137>:
.globl vector137
vector137:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $137
80107213:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107218:	e9 ce f4 ff ff       	jmp    801066eb <alltraps>

8010721d <vector138>:
.globl vector138
vector138:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $138
8010721f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107224:	e9 c2 f4 ff ff       	jmp    801066eb <alltraps>

80107229 <vector139>:
.globl vector139
vector139:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $139
8010722b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107230:	e9 b6 f4 ff ff       	jmp    801066eb <alltraps>

80107235 <vector140>:
.globl vector140
vector140:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $140
80107237:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010723c:	e9 aa f4 ff ff       	jmp    801066eb <alltraps>

80107241 <vector141>:
.globl vector141
vector141:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $141
80107243:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107248:	e9 9e f4 ff ff       	jmp    801066eb <alltraps>

8010724d <vector142>:
.globl vector142
vector142:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $142
8010724f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107254:	e9 92 f4 ff ff       	jmp    801066eb <alltraps>

80107259 <vector143>:
.globl vector143
vector143:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $143
8010725b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107260:	e9 86 f4 ff ff       	jmp    801066eb <alltraps>

80107265 <vector144>:
.globl vector144
vector144:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $144
80107267:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010726c:	e9 7a f4 ff ff       	jmp    801066eb <alltraps>

80107271 <vector145>:
.globl vector145
vector145:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $145
80107273:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107278:	e9 6e f4 ff ff       	jmp    801066eb <alltraps>

8010727d <vector146>:
.globl vector146
vector146:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $146
8010727f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107284:	e9 62 f4 ff ff       	jmp    801066eb <alltraps>

80107289 <vector147>:
.globl vector147
vector147:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $147
8010728b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107290:	e9 56 f4 ff ff       	jmp    801066eb <alltraps>

80107295 <vector148>:
.globl vector148
vector148:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $148
80107297:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010729c:	e9 4a f4 ff ff       	jmp    801066eb <alltraps>

801072a1 <vector149>:
.globl vector149
vector149:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $149
801072a3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072a8:	e9 3e f4 ff ff       	jmp    801066eb <alltraps>

801072ad <vector150>:
.globl vector150
vector150:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $150
801072af:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072b4:	e9 32 f4 ff ff       	jmp    801066eb <alltraps>

801072b9 <vector151>:
.globl vector151
vector151:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $151
801072bb:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072c0:	e9 26 f4 ff ff       	jmp    801066eb <alltraps>

801072c5 <vector152>:
.globl vector152
vector152:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $152
801072c7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072cc:	e9 1a f4 ff ff       	jmp    801066eb <alltraps>

801072d1 <vector153>:
.globl vector153
vector153:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $153
801072d3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072d8:	e9 0e f4 ff ff       	jmp    801066eb <alltraps>

801072dd <vector154>:
.globl vector154
vector154:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $154
801072df:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072e4:	e9 02 f4 ff ff       	jmp    801066eb <alltraps>

801072e9 <vector155>:
.globl vector155
vector155:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $155
801072eb:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072f0:	e9 f6 f3 ff ff       	jmp    801066eb <alltraps>

801072f5 <vector156>:
.globl vector156
vector156:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $156
801072f7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072fc:	e9 ea f3 ff ff       	jmp    801066eb <alltraps>

80107301 <vector157>:
.globl vector157
vector157:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $157
80107303:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107308:	e9 de f3 ff ff       	jmp    801066eb <alltraps>

8010730d <vector158>:
.globl vector158
vector158:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $158
8010730f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107314:	e9 d2 f3 ff ff       	jmp    801066eb <alltraps>

80107319 <vector159>:
.globl vector159
vector159:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $159
8010731b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107320:	e9 c6 f3 ff ff       	jmp    801066eb <alltraps>

80107325 <vector160>:
.globl vector160
vector160:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $160
80107327:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010732c:	e9 ba f3 ff ff       	jmp    801066eb <alltraps>

80107331 <vector161>:
.globl vector161
vector161:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $161
80107333:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107338:	e9 ae f3 ff ff       	jmp    801066eb <alltraps>

8010733d <vector162>:
.globl vector162
vector162:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $162
8010733f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107344:	e9 a2 f3 ff ff       	jmp    801066eb <alltraps>

80107349 <vector163>:
.globl vector163
vector163:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $163
8010734b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107350:	e9 96 f3 ff ff       	jmp    801066eb <alltraps>

80107355 <vector164>:
.globl vector164
vector164:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $164
80107357:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010735c:	e9 8a f3 ff ff       	jmp    801066eb <alltraps>

80107361 <vector165>:
.globl vector165
vector165:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $165
80107363:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107368:	e9 7e f3 ff ff       	jmp    801066eb <alltraps>

8010736d <vector166>:
.globl vector166
vector166:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $166
8010736f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107374:	e9 72 f3 ff ff       	jmp    801066eb <alltraps>

80107379 <vector167>:
.globl vector167
vector167:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $167
8010737b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107380:	e9 66 f3 ff ff       	jmp    801066eb <alltraps>

80107385 <vector168>:
.globl vector168
vector168:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $168
80107387:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010738c:	e9 5a f3 ff ff       	jmp    801066eb <alltraps>

80107391 <vector169>:
.globl vector169
vector169:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $169
80107393:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107398:	e9 4e f3 ff ff       	jmp    801066eb <alltraps>

8010739d <vector170>:
.globl vector170
vector170:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $170
8010739f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073a4:	e9 42 f3 ff ff       	jmp    801066eb <alltraps>

801073a9 <vector171>:
.globl vector171
vector171:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $171
801073ab:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073b0:	e9 36 f3 ff ff       	jmp    801066eb <alltraps>

801073b5 <vector172>:
.globl vector172
vector172:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $172
801073b7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073bc:	e9 2a f3 ff ff       	jmp    801066eb <alltraps>

801073c1 <vector173>:
.globl vector173
vector173:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $173
801073c3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073c8:	e9 1e f3 ff ff       	jmp    801066eb <alltraps>

801073cd <vector174>:
.globl vector174
vector174:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $174
801073cf:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073d4:	e9 12 f3 ff ff       	jmp    801066eb <alltraps>

801073d9 <vector175>:
.globl vector175
vector175:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $175
801073db:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073e0:	e9 06 f3 ff ff       	jmp    801066eb <alltraps>

801073e5 <vector176>:
.globl vector176
vector176:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $176
801073e7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073ec:	e9 fa f2 ff ff       	jmp    801066eb <alltraps>

801073f1 <vector177>:
.globl vector177
vector177:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $177
801073f3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073f8:	e9 ee f2 ff ff       	jmp    801066eb <alltraps>

801073fd <vector178>:
.globl vector178
vector178:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $178
801073ff:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107404:	e9 e2 f2 ff ff       	jmp    801066eb <alltraps>

80107409 <vector179>:
.globl vector179
vector179:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $179
8010740b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107410:	e9 d6 f2 ff ff       	jmp    801066eb <alltraps>

80107415 <vector180>:
.globl vector180
vector180:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $180
80107417:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010741c:	e9 ca f2 ff ff       	jmp    801066eb <alltraps>

80107421 <vector181>:
.globl vector181
vector181:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $181
80107423:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107428:	e9 be f2 ff ff       	jmp    801066eb <alltraps>

8010742d <vector182>:
.globl vector182
vector182:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $182
8010742f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107434:	e9 b2 f2 ff ff       	jmp    801066eb <alltraps>

80107439 <vector183>:
.globl vector183
vector183:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $183
8010743b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107440:	e9 a6 f2 ff ff       	jmp    801066eb <alltraps>

80107445 <vector184>:
.globl vector184
vector184:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $184
80107447:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010744c:	e9 9a f2 ff ff       	jmp    801066eb <alltraps>

80107451 <vector185>:
.globl vector185
vector185:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $185
80107453:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107458:	e9 8e f2 ff ff       	jmp    801066eb <alltraps>

8010745d <vector186>:
.globl vector186
vector186:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $186
8010745f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107464:	e9 82 f2 ff ff       	jmp    801066eb <alltraps>

80107469 <vector187>:
.globl vector187
vector187:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $187
8010746b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107470:	e9 76 f2 ff ff       	jmp    801066eb <alltraps>

80107475 <vector188>:
.globl vector188
vector188:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $188
80107477:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010747c:	e9 6a f2 ff ff       	jmp    801066eb <alltraps>

80107481 <vector189>:
.globl vector189
vector189:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $189
80107483:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107488:	e9 5e f2 ff ff       	jmp    801066eb <alltraps>

8010748d <vector190>:
.globl vector190
vector190:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $190
8010748f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107494:	e9 52 f2 ff ff       	jmp    801066eb <alltraps>

80107499 <vector191>:
.globl vector191
vector191:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $191
8010749b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074a0:	e9 46 f2 ff ff       	jmp    801066eb <alltraps>

801074a5 <vector192>:
.globl vector192
vector192:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $192
801074a7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074ac:	e9 3a f2 ff ff       	jmp    801066eb <alltraps>

801074b1 <vector193>:
.globl vector193
vector193:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $193
801074b3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074b8:	e9 2e f2 ff ff       	jmp    801066eb <alltraps>

801074bd <vector194>:
.globl vector194
vector194:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $194
801074bf:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074c4:	e9 22 f2 ff ff       	jmp    801066eb <alltraps>

801074c9 <vector195>:
.globl vector195
vector195:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $195
801074cb:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074d0:	e9 16 f2 ff ff       	jmp    801066eb <alltraps>

801074d5 <vector196>:
.globl vector196
vector196:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $196
801074d7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074dc:	e9 0a f2 ff ff       	jmp    801066eb <alltraps>

801074e1 <vector197>:
.globl vector197
vector197:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $197
801074e3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074e8:	e9 fe f1 ff ff       	jmp    801066eb <alltraps>

801074ed <vector198>:
.globl vector198
vector198:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $198
801074ef:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074f4:	e9 f2 f1 ff ff       	jmp    801066eb <alltraps>

801074f9 <vector199>:
.globl vector199
vector199:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $199
801074fb:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107500:	e9 e6 f1 ff ff       	jmp    801066eb <alltraps>

80107505 <vector200>:
.globl vector200
vector200:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $200
80107507:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010750c:	e9 da f1 ff ff       	jmp    801066eb <alltraps>

80107511 <vector201>:
.globl vector201
vector201:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $201
80107513:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107518:	e9 ce f1 ff ff       	jmp    801066eb <alltraps>

8010751d <vector202>:
.globl vector202
vector202:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $202
8010751f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107524:	e9 c2 f1 ff ff       	jmp    801066eb <alltraps>

80107529 <vector203>:
.globl vector203
vector203:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $203
8010752b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107530:	e9 b6 f1 ff ff       	jmp    801066eb <alltraps>

80107535 <vector204>:
.globl vector204
vector204:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $204
80107537:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010753c:	e9 aa f1 ff ff       	jmp    801066eb <alltraps>

80107541 <vector205>:
.globl vector205
vector205:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $205
80107543:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107548:	e9 9e f1 ff ff       	jmp    801066eb <alltraps>

8010754d <vector206>:
.globl vector206
vector206:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $206
8010754f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107554:	e9 92 f1 ff ff       	jmp    801066eb <alltraps>

80107559 <vector207>:
.globl vector207
vector207:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $207
8010755b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107560:	e9 86 f1 ff ff       	jmp    801066eb <alltraps>

80107565 <vector208>:
.globl vector208
vector208:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $208
80107567:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010756c:	e9 7a f1 ff ff       	jmp    801066eb <alltraps>

80107571 <vector209>:
.globl vector209
vector209:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $209
80107573:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107578:	e9 6e f1 ff ff       	jmp    801066eb <alltraps>

8010757d <vector210>:
.globl vector210
vector210:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $210
8010757f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107584:	e9 62 f1 ff ff       	jmp    801066eb <alltraps>

80107589 <vector211>:
.globl vector211
vector211:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $211
8010758b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107590:	e9 56 f1 ff ff       	jmp    801066eb <alltraps>

80107595 <vector212>:
.globl vector212
vector212:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $212
80107597:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010759c:	e9 4a f1 ff ff       	jmp    801066eb <alltraps>

801075a1 <vector213>:
.globl vector213
vector213:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $213
801075a3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075a8:	e9 3e f1 ff ff       	jmp    801066eb <alltraps>

801075ad <vector214>:
.globl vector214
vector214:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $214
801075af:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075b4:	e9 32 f1 ff ff       	jmp    801066eb <alltraps>

801075b9 <vector215>:
.globl vector215
vector215:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $215
801075bb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075c0:	e9 26 f1 ff ff       	jmp    801066eb <alltraps>

801075c5 <vector216>:
.globl vector216
vector216:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $216
801075c7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075cc:	e9 1a f1 ff ff       	jmp    801066eb <alltraps>

801075d1 <vector217>:
.globl vector217
vector217:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $217
801075d3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075d8:	e9 0e f1 ff ff       	jmp    801066eb <alltraps>

801075dd <vector218>:
.globl vector218
vector218:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $218
801075df:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075e4:	e9 02 f1 ff ff       	jmp    801066eb <alltraps>

801075e9 <vector219>:
.globl vector219
vector219:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $219
801075eb:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075f0:	e9 f6 f0 ff ff       	jmp    801066eb <alltraps>

801075f5 <vector220>:
.globl vector220
vector220:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $220
801075f7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075fc:	e9 ea f0 ff ff       	jmp    801066eb <alltraps>

80107601 <vector221>:
.globl vector221
vector221:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $221
80107603:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107608:	e9 de f0 ff ff       	jmp    801066eb <alltraps>

8010760d <vector222>:
.globl vector222
vector222:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $222
8010760f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107614:	e9 d2 f0 ff ff       	jmp    801066eb <alltraps>

80107619 <vector223>:
.globl vector223
vector223:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $223
8010761b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107620:	e9 c6 f0 ff ff       	jmp    801066eb <alltraps>

80107625 <vector224>:
.globl vector224
vector224:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $224
80107627:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010762c:	e9 ba f0 ff ff       	jmp    801066eb <alltraps>

80107631 <vector225>:
.globl vector225
vector225:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $225
80107633:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107638:	e9 ae f0 ff ff       	jmp    801066eb <alltraps>

8010763d <vector226>:
.globl vector226
vector226:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $226
8010763f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107644:	e9 a2 f0 ff ff       	jmp    801066eb <alltraps>

80107649 <vector227>:
.globl vector227
vector227:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $227
8010764b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107650:	e9 96 f0 ff ff       	jmp    801066eb <alltraps>

80107655 <vector228>:
.globl vector228
vector228:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $228
80107657:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010765c:	e9 8a f0 ff ff       	jmp    801066eb <alltraps>

80107661 <vector229>:
.globl vector229
vector229:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $229
80107663:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107668:	e9 7e f0 ff ff       	jmp    801066eb <alltraps>

8010766d <vector230>:
.globl vector230
vector230:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $230
8010766f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107674:	e9 72 f0 ff ff       	jmp    801066eb <alltraps>

80107679 <vector231>:
.globl vector231
vector231:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $231
8010767b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107680:	e9 66 f0 ff ff       	jmp    801066eb <alltraps>

80107685 <vector232>:
.globl vector232
vector232:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $232
80107687:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010768c:	e9 5a f0 ff ff       	jmp    801066eb <alltraps>

80107691 <vector233>:
.globl vector233
vector233:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $233
80107693:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107698:	e9 4e f0 ff ff       	jmp    801066eb <alltraps>

8010769d <vector234>:
.globl vector234
vector234:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $234
8010769f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076a4:	e9 42 f0 ff ff       	jmp    801066eb <alltraps>

801076a9 <vector235>:
.globl vector235
vector235:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $235
801076ab:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076b0:	e9 36 f0 ff ff       	jmp    801066eb <alltraps>

801076b5 <vector236>:
.globl vector236
vector236:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $236
801076b7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076bc:	e9 2a f0 ff ff       	jmp    801066eb <alltraps>

801076c1 <vector237>:
.globl vector237
vector237:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $237
801076c3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076c8:	e9 1e f0 ff ff       	jmp    801066eb <alltraps>

801076cd <vector238>:
.globl vector238
vector238:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $238
801076cf:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076d4:	e9 12 f0 ff ff       	jmp    801066eb <alltraps>

801076d9 <vector239>:
.globl vector239
vector239:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $239
801076db:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076e0:	e9 06 f0 ff ff       	jmp    801066eb <alltraps>

801076e5 <vector240>:
.globl vector240
vector240:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $240
801076e7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076ec:	e9 fa ef ff ff       	jmp    801066eb <alltraps>

801076f1 <vector241>:
.globl vector241
vector241:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $241
801076f3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076f8:	e9 ee ef ff ff       	jmp    801066eb <alltraps>

801076fd <vector242>:
.globl vector242
vector242:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $242
801076ff:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107704:	e9 e2 ef ff ff       	jmp    801066eb <alltraps>

80107709 <vector243>:
.globl vector243
vector243:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $243
8010770b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107710:	e9 d6 ef ff ff       	jmp    801066eb <alltraps>

80107715 <vector244>:
.globl vector244
vector244:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $244
80107717:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010771c:	e9 ca ef ff ff       	jmp    801066eb <alltraps>

80107721 <vector245>:
.globl vector245
vector245:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $245
80107723:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107728:	e9 be ef ff ff       	jmp    801066eb <alltraps>

8010772d <vector246>:
.globl vector246
vector246:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $246
8010772f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107734:	e9 b2 ef ff ff       	jmp    801066eb <alltraps>

80107739 <vector247>:
.globl vector247
vector247:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $247
8010773b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107740:	e9 a6 ef ff ff       	jmp    801066eb <alltraps>

80107745 <vector248>:
.globl vector248
vector248:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $248
80107747:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010774c:	e9 9a ef ff ff       	jmp    801066eb <alltraps>

80107751 <vector249>:
.globl vector249
vector249:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $249
80107753:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107758:	e9 8e ef ff ff       	jmp    801066eb <alltraps>

8010775d <vector250>:
.globl vector250
vector250:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $250
8010775f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107764:	e9 82 ef ff ff       	jmp    801066eb <alltraps>

80107769 <vector251>:
.globl vector251
vector251:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $251
8010776b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107770:	e9 76 ef ff ff       	jmp    801066eb <alltraps>

80107775 <vector252>:
.globl vector252
vector252:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $252
80107777:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010777c:	e9 6a ef ff ff       	jmp    801066eb <alltraps>

80107781 <vector253>:
.globl vector253
vector253:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $253
80107783:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107788:	e9 5e ef ff ff       	jmp    801066eb <alltraps>

8010778d <vector254>:
.globl vector254
vector254:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $254
8010778f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107794:	e9 52 ef ff ff       	jmp    801066eb <alltraps>

80107799 <vector255>:
.globl vector255
vector255:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $255
8010779b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077a0:	e9 46 ef ff ff       	jmp    801066eb <alltraps>

801077a5 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801077a5:	55                   	push   %ebp
801077a6:	89 e5                	mov    %esp,%ebp
801077a8:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801077ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801077ae:	83 e8 01             	sub    $0x1,%eax
801077b1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077b5:	8b 45 08             	mov    0x8(%ebp),%eax
801077b8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077bc:	8b 45 08             	mov    0x8(%ebp),%eax
801077bf:	c1 e8 10             	shr    $0x10,%eax
801077c2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801077c6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077c9:	0f 01 10             	lgdtl  (%eax)
}
801077cc:	c9                   	leave  
801077cd:	c3                   	ret    

801077ce <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801077ce:	55                   	push   %ebp
801077cf:	89 e5                	mov    %esp,%ebp
801077d1:	83 ec 04             	sub    $0x4,%esp
801077d4:	8b 45 08             	mov    0x8(%ebp),%eax
801077d7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077db:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077df:	0f 00 d8             	ltr    %ax
}
801077e2:	c9                   	leave  
801077e3:	c3                   	ret    

801077e4 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801077e4:	55                   	push   %ebp
801077e5:	89 e5                	mov    %esp,%ebp
801077e7:	83 ec 04             	sub    $0x4,%esp
801077ea:	8b 45 08             	mov    0x8(%ebp),%eax
801077ed:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077f1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077f5:	8e e8                	mov    %eax,%gs
}
801077f7:	c9                   	leave  
801077f8:	c3                   	ret    

801077f9 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077f9:	55                   	push   %ebp
801077fa:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077fc:	8b 45 08             	mov    0x8(%ebp),%eax
801077ff:	0f 22 d8             	mov    %eax,%cr3
}
80107802:	5d                   	pop    %ebp
80107803:	c3                   	ret    

80107804 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107804:	55                   	push   %ebp
80107805:	89 e5                	mov    %esp,%ebp
80107807:	8b 45 08             	mov    0x8(%ebp),%eax
8010780a:	05 00 00 00 80       	add    $0x80000000,%eax
8010780f:	5d                   	pop    %ebp
80107810:	c3                   	ret    

80107811 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107811:	55                   	push   %ebp
80107812:	89 e5                	mov    %esp,%ebp
80107814:	8b 45 08             	mov    0x8(%ebp),%eax
80107817:	05 00 00 00 80       	add    $0x80000000,%eax
8010781c:	5d                   	pop    %ebp
8010781d:	c3                   	ret    

8010781e <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010781e:	55                   	push   %ebp
8010781f:	89 e5                	mov    %esp,%ebp
80107821:	53                   	push   %ebx
80107822:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107825:	e8 df b7 ff ff       	call   80103009 <cpunum>
8010782a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107830:	05 80 24 11 80       	add    $0x80112480,%eax
80107835:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107844:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010784a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107858:	83 e2 f0             	and    $0xfffffff0,%edx
8010785b:	83 ca 0a             	or     $0xa,%edx
8010785e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107864:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107868:	83 ca 10             	or     $0x10,%edx
8010786b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010786e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107871:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107875:	83 e2 9f             	and    $0xffffff9f,%edx
80107878:	88 50 7d             	mov    %dl,0x7d(%eax)
8010787b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107882:	83 ca 80             	or     $0xffffff80,%edx
80107885:	88 50 7d             	mov    %dl,0x7d(%eax)
80107888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010788f:	83 ca 0f             	or     $0xf,%edx
80107892:	88 50 7e             	mov    %dl,0x7e(%eax)
80107895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107898:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010789c:	83 e2 ef             	and    $0xffffffef,%edx
8010789f:	88 50 7e             	mov    %dl,0x7e(%eax)
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078a9:	83 e2 df             	and    $0xffffffdf,%edx
801078ac:	88 50 7e             	mov    %dl,0x7e(%eax)
801078af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078b6:	83 ca 40             	or     $0x40,%edx
801078b9:	88 50 7e             	mov    %dl,0x7e(%eax)
801078bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078c3:	83 ca 80             	or     $0xffffff80,%edx
801078c6:	88 50 7e             	mov    %dl,0x7e(%eax)
801078c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078da:	ff ff 
801078dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078df:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078e6:	00 00 
801078e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078eb:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078fc:	83 e2 f0             	and    $0xfffffff0,%edx
801078ff:	83 ca 02             	or     $0x2,%edx
80107902:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107912:	83 ca 10             	or     $0x10,%edx
80107915:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010791b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107925:	83 e2 9f             	and    $0xffffff9f,%edx
80107928:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010792e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107931:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107938:	83 ca 80             	or     $0xffffff80,%edx
8010793b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107944:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010794b:	83 ca 0f             	or     $0xf,%edx
8010794e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107957:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010795e:	83 e2 ef             	and    $0xffffffef,%edx
80107961:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107971:	83 e2 df             	and    $0xffffffdf,%edx
80107974:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107984:	83 ca 40             	or     $0x40,%edx
80107987:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010798d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107990:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107997:	83 ca 80             	or     $0xffffff80,%edx
8010799a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ad:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079b4:	ff ff 
801079b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b9:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079c0:	00 00 
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079d6:	83 e2 f0             	and    $0xfffffff0,%edx
801079d9:	83 ca 0a             	or     $0xa,%edx
801079dc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ec:	83 ca 10             	or     $0x10,%edx
801079ef:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ff:	83 ca 60             	or     $0x60,%edx
80107a02:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a12:	83 ca 80             	or     $0xffffff80,%edx
80107a15:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a25:	83 ca 0f             	or     $0xf,%edx
80107a28:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a31:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a38:	83 e2 ef             	and    $0xffffffef,%edx
80107a3b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a44:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a4b:	83 e2 df             	and    $0xffffffdf,%edx
80107a4e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a5e:	83 ca 40             	or     $0x40,%edx
80107a61:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a71:	83 ca 80             	or     $0xffffff80,%edx
80107a74:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a8e:	ff ff 
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a9a:	00 00 
80107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9f:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ab0:	83 e2 f0             	and    $0xfffffff0,%edx
80107ab3:	83 ca 02             	or     $0x2,%edx
80107ab6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ac6:	83 ca 10             	or     $0x10,%edx
80107ac9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ad9:	83 ca 60             	or     $0x60,%edx
80107adc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107aec:	83 ca 80             	or     $0xffffff80,%edx
80107aef:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aff:	83 ca 0f             	or     $0xf,%edx
80107b02:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b12:	83 e2 ef             	and    $0xffffffef,%edx
80107b15:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b25:	83 e2 df             	and    $0xffffffdf,%edx
80107b28:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b38:	83 ca 40             	or     $0x40,%edx
80107b3b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b44:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b4b:	83 ca 80             	or     $0xffffff80,%edx
80107b4e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	05 b4 00 00 00       	add    $0xb4,%eax
80107b66:	89 c3                	mov    %eax,%ebx
80107b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6b:	05 b4 00 00 00       	add    $0xb4,%eax
80107b70:	c1 e8 10             	shr    $0x10,%eax
80107b73:	89 c2                	mov    %eax,%edx
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	05 b4 00 00 00       	add    $0xb4,%eax
80107b7d:	c1 e8 18             	shr    $0x18,%eax
80107b80:	89 c1                	mov    %eax,%ecx
80107b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b85:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b8c:	00 00 
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bab:	83 e2 f0             	and    $0xfffffff0,%edx
80107bae:	83 ca 02             	or     $0x2,%edx
80107bb1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bba:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bc1:	83 ca 10             	or     $0x10,%edx
80107bc4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bd4:	83 e2 9f             	and    $0xffffff9f,%edx
80107bd7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107be7:	83 ca 80             	or     $0xffffff80,%edx
80107bea:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bfa:	83 e2 f0             	and    $0xfffffff0,%edx
80107bfd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c06:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c0d:	83 e2 ef             	and    $0xffffffef,%edx
80107c10:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c19:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c20:	83 e2 df             	and    $0xffffffdf,%edx
80107c23:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c33:	83 ca 40             	or     $0x40,%edx
80107c36:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c46:	83 ca 80             	or     $0xffffff80,%edx
80107c49:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c52:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	83 c0 70             	add    $0x70,%eax
80107c5e:	83 ec 08             	sub    $0x8,%esp
80107c61:	6a 38                	push   $0x38
80107c63:	50                   	push   %eax
80107c64:	e8 3c fb ff ff       	call   801077a5 <lgdt>
80107c69:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107c6c:	83 ec 0c             	sub    $0xc,%esp
80107c6f:	6a 18                	push   $0x18
80107c71:	e8 6e fb ff ff       	call   801077e4 <loadgs>
80107c76:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c82:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c89:	00 00 00 00 
}
80107c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c90:	c9                   	leave  
80107c91:	c3                   	ret    

80107c92 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c92:	55                   	push   %ebp
80107c93:	89 e5                	mov    %esp,%ebp
80107c95:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c9b:	c1 e8 16             	shr    $0x16,%eax
80107c9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca8:	01 d0                	add    %edx,%eax
80107caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb0:	8b 00                	mov    (%eax),%eax
80107cb2:	83 e0 01             	and    $0x1,%eax
80107cb5:	85 c0                	test   %eax,%eax
80107cb7:	74 18                	je     80107cd1 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cbc:	8b 00                	mov    (%eax),%eax
80107cbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cc3:	50                   	push   %eax
80107cc4:	e8 48 fb ff ff       	call   80107811 <p2v>
80107cc9:	83 c4 04             	add    $0x4,%esp
80107ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ccf:	eb 48                	jmp    80107d19 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107cd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107cd5:	74 0e                	je     80107ce5 <walkpgdir+0x53>
80107cd7:	e8 cc af ff ff       	call   80102ca8 <kalloc>
80107cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ce3:	75 07                	jne    80107cec <walkpgdir+0x5a>
      return 0;
80107ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cea:	eb 44                	jmp    80107d30 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107cec:	83 ec 04             	sub    $0x4,%esp
80107cef:	68 00 10 00 00       	push   $0x1000
80107cf4:	6a 00                	push   $0x0
80107cf6:	ff 75 f4             	pushl  -0xc(%ebp)
80107cf9:	e8 c5 d5 ff ff       	call   801052c3 <memset>
80107cfe:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107d01:	83 ec 0c             	sub    $0xc,%esp
80107d04:	ff 75 f4             	pushl  -0xc(%ebp)
80107d07:	e8 f8 fa ff ff       	call   80107804 <v2p>
80107d0c:	83 c4 10             	add    $0x10,%esp
80107d0f:	83 c8 07             	or     $0x7,%eax
80107d12:	89 c2                	mov    %eax,%edx
80107d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d17:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d19:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d1c:	c1 e8 0c             	shr    $0xc,%eax
80107d1f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	01 d0                	add    %edx,%eax
}
80107d30:	c9                   	leave  
80107d31:	c3                   	ret    

80107d32 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d32:	55                   	push   %ebp
80107d33:	89 e5                	mov    %esp,%ebp
80107d35:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d43:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d46:	8b 45 10             	mov    0x10(%ebp),%eax
80107d49:	01 d0                	add    %edx,%eax
80107d4b:	83 e8 01             	sub    $0x1,%eax
80107d4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d56:	83 ec 04             	sub    $0x4,%esp
80107d59:	6a 01                	push   $0x1
80107d5b:	ff 75 f4             	pushl  -0xc(%ebp)
80107d5e:	ff 75 08             	pushl  0x8(%ebp)
80107d61:	e8 2c ff ff ff       	call   80107c92 <walkpgdir>
80107d66:	83 c4 10             	add    $0x10,%esp
80107d69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d70:	75 07                	jne    80107d79 <mappages+0x47>
      return -1;
80107d72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d77:	eb 49                	jmp    80107dc2 <mappages+0x90>
    if(*pte & PTE_P)
80107d79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d7c:	8b 00                	mov    (%eax),%eax
80107d7e:	83 e0 01             	and    $0x1,%eax
80107d81:	85 c0                	test   %eax,%eax
80107d83:	74 0d                	je     80107d92 <mappages+0x60>
      panic("remap");
80107d85:	83 ec 0c             	sub    $0xc,%esp
80107d88:	68 6c 8b 10 80       	push   $0x80108b6c
80107d8d:	e8 ca 87 ff ff       	call   8010055c <panic>
    *pte = pa | perm | PTE_P;
80107d92:	8b 45 18             	mov    0x18(%ebp),%eax
80107d95:	0b 45 14             	or     0x14(%ebp),%eax
80107d98:	83 c8 01             	or     $0x1,%eax
80107d9b:	89 c2                	mov    %eax,%edx
80107d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da0:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107da8:	75 08                	jne    80107db2 <mappages+0x80>
      break;
80107daa:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107dab:	b8 00 00 00 00       	mov    $0x0,%eax
80107db0:	eb 10                	jmp    80107dc2 <mappages+0x90>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107db2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107db9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107dc0:	eb 94                	jmp    80107d56 <mappages+0x24>
  return 0;
}
80107dc2:	c9                   	leave  
80107dc3:	c3                   	ret    

80107dc4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107dc4:	55                   	push   %ebp
80107dc5:	89 e5                	mov    %esp,%ebp
80107dc7:	53                   	push   %ebx
80107dc8:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107dcb:	e8 d8 ae ff ff       	call   80102ca8 <kalloc>
80107dd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107dd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dd7:	75 0a                	jne    80107de3 <setupkvm+0x1f>
    return 0;
80107dd9:	b8 00 00 00 00       	mov    $0x0,%eax
80107dde:	e9 8e 00 00 00       	jmp    80107e71 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107de3:	83 ec 04             	sub    $0x4,%esp
80107de6:	68 00 10 00 00       	push   $0x1000
80107deb:	6a 00                	push   $0x0
80107ded:	ff 75 f0             	pushl  -0x10(%ebp)
80107df0:	e8 ce d4 ff ff       	call   801052c3 <memset>
80107df5:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107df8:	83 ec 0c             	sub    $0xc,%esp
80107dfb:	68 00 00 00 0e       	push   $0xe000000
80107e00:	e8 0c fa ff ff       	call   80107811 <p2v>
80107e05:	83 c4 10             	add    $0x10,%esp
80107e08:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107e0d:	76 0d                	jbe    80107e1c <setupkvm+0x58>
    panic("PHYSTOP too high");
80107e0f:	83 ec 0c             	sub    $0xc,%esp
80107e12:	68 72 8b 10 80       	push   $0x80108b72
80107e17:	e8 40 87 ff ff       	call   8010055c <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e1c:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107e23:	eb 40                	jmp    80107e65 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	8b 48 0c             	mov    0xc(%eax),%ecx
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	8b 50 04             	mov    0x4(%eax),%edx
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	8b 58 08             	mov    0x8(%eax),%ebx
80107e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3a:	8b 40 04             	mov    0x4(%eax),%eax
80107e3d:	29 c3                	sub    %eax,%ebx
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	8b 00                	mov    (%eax),%eax
80107e44:	83 ec 0c             	sub    $0xc,%esp
80107e47:	51                   	push   %ecx
80107e48:	52                   	push   %edx
80107e49:	53                   	push   %ebx
80107e4a:	50                   	push   %eax
80107e4b:	ff 75 f0             	pushl  -0x10(%ebp)
80107e4e:	e8 df fe ff ff       	call   80107d32 <mappages>
80107e53:	83 c4 20             	add    $0x20,%esp
80107e56:	85 c0                	test   %eax,%eax
80107e58:	79 07                	jns    80107e61 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107e5a:	b8 00 00 00 00       	mov    $0x0,%eax
80107e5f:	eb 10                	jmp    80107e71 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e61:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e65:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107e6c:	72 b7                	jb     80107e25 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e74:	c9                   	leave  
80107e75:	c3                   	ret    

80107e76 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e76:	55                   	push   %ebp
80107e77:	89 e5                	mov    %esp,%ebp
80107e79:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e7c:	e8 43 ff ff ff       	call   80107dc4 <setupkvm>
80107e81:	a3 58 52 11 80       	mov    %eax,0x80115258
  switchkvm();
80107e86:	e8 02 00 00 00       	call   80107e8d <switchkvm>
}
80107e8b:	c9                   	leave  
80107e8c:	c3                   	ret    

80107e8d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e8d:	55                   	push   %ebp
80107e8e:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e90:	a1 58 52 11 80       	mov    0x80115258,%eax
80107e95:	50                   	push   %eax
80107e96:	e8 69 f9 ff ff       	call   80107804 <v2p>
80107e9b:	83 c4 04             	add    $0x4,%esp
80107e9e:	50                   	push   %eax
80107e9f:	e8 55 f9 ff ff       	call   801077f9 <lcr3>
80107ea4:	83 c4 04             	add    $0x4,%esp
}
80107ea7:	c9                   	leave  
80107ea8:	c3                   	ret    

80107ea9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ea9:	55                   	push   %ebp
80107eaa:	89 e5                	mov    %esp,%ebp
80107eac:	56                   	push   %esi
80107ead:	53                   	push   %ebx
  pushcli();
80107eae:	e8 0e d3 ff ff       	call   801051c1 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107eb3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107eb9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ec0:	83 c2 08             	add    $0x8,%edx
80107ec3:	89 d6                	mov    %edx,%esi
80107ec5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ecc:	83 c2 08             	add    $0x8,%edx
80107ecf:	c1 ea 10             	shr    $0x10,%edx
80107ed2:	89 d3                	mov    %edx,%ebx
80107ed4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107edb:	83 c2 08             	add    $0x8,%edx
80107ede:	c1 ea 18             	shr    $0x18,%edx
80107ee1:	89 d1                	mov    %edx,%ecx
80107ee3:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107eea:	67 00 
80107eec:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107ef3:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107ef9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f00:	83 e2 f0             	and    $0xfffffff0,%edx
80107f03:	83 ca 09             	or     $0x9,%edx
80107f06:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f0c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f13:	83 ca 10             	or     $0x10,%edx
80107f16:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f1c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f23:	83 e2 9f             	and    $0xffffff9f,%edx
80107f26:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f2c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f33:	83 ca 80             	or     $0xffffff80,%edx
80107f36:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f3c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f43:	83 e2 f0             	and    $0xfffffff0,%edx
80107f46:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f4c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f53:	83 e2 ef             	and    $0xffffffef,%edx
80107f56:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f5c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f63:	83 e2 df             	and    $0xffffffdf,%edx
80107f66:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f6c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f73:	83 ca 40             	or     $0x40,%edx
80107f76:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f7c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f83:	83 e2 7f             	and    $0x7f,%edx
80107f86:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f8c:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f92:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f98:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f9f:	83 e2 ef             	and    $0xffffffef,%edx
80107fa2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107fa8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fae:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107fb4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fba:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107fc1:	8b 52 08             	mov    0x8(%edx),%edx
80107fc4:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107fca:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107fcd:	83 ec 0c             	sub    $0xc,%esp
80107fd0:	6a 30                	push   $0x30
80107fd2:	e8 f7 f7 ff ff       	call   801077ce <ltr>
80107fd7:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107fda:	8b 45 08             	mov    0x8(%ebp),%eax
80107fdd:	8b 40 04             	mov    0x4(%eax),%eax
80107fe0:	85 c0                	test   %eax,%eax
80107fe2:	75 0d                	jne    80107ff1 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107fe4:	83 ec 0c             	sub    $0xc,%esp
80107fe7:	68 83 8b 10 80       	push   $0x80108b83
80107fec:	e8 6b 85 ff ff       	call   8010055c <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff4:	8b 40 04             	mov    0x4(%eax),%eax
80107ff7:	83 ec 0c             	sub    $0xc,%esp
80107ffa:	50                   	push   %eax
80107ffb:	e8 04 f8 ff ff       	call   80107804 <v2p>
80108000:	83 c4 10             	add    $0x10,%esp
80108003:	83 ec 0c             	sub    $0xc,%esp
80108006:	50                   	push   %eax
80108007:	e8 ed f7 ff ff       	call   801077f9 <lcr3>
8010800c:	83 c4 10             	add    $0x10,%esp
  popcli();
8010800f:	e8 f1 d1 ff ff       	call   80105205 <popcli>
}
80108014:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108017:	5b                   	pop    %ebx
80108018:	5e                   	pop    %esi
80108019:	5d                   	pop    %ebp
8010801a:	c3                   	ret    

8010801b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010801b:	55                   	push   %ebp
8010801c:	89 e5                	mov    %esp,%ebp
8010801e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108021:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108028:	76 0d                	jbe    80108037 <inituvm+0x1c>
    panic("inituvm: more than a page");
8010802a:	83 ec 0c             	sub    $0xc,%esp
8010802d:	68 97 8b 10 80       	push   $0x80108b97
80108032:	e8 25 85 ff ff       	call   8010055c <panic>
  mem = kalloc();
80108037:	e8 6c ac ff ff       	call   80102ca8 <kalloc>
8010803c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010803f:	83 ec 04             	sub    $0x4,%esp
80108042:	68 00 10 00 00       	push   $0x1000
80108047:	6a 00                	push   $0x0
80108049:	ff 75 f4             	pushl  -0xc(%ebp)
8010804c:	e8 72 d2 ff ff       	call   801052c3 <memset>
80108051:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108054:	83 ec 0c             	sub    $0xc,%esp
80108057:	ff 75 f4             	pushl  -0xc(%ebp)
8010805a:	e8 a5 f7 ff ff       	call   80107804 <v2p>
8010805f:	83 c4 10             	add    $0x10,%esp
80108062:	83 ec 0c             	sub    $0xc,%esp
80108065:	6a 06                	push   $0x6
80108067:	50                   	push   %eax
80108068:	68 00 10 00 00       	push   $0x1000
8010806d:	6a 00                	push   $0x0
8010806f:	ff 75 08             	pushl  0x8(%ebp)
80108072:	e8 bb fc ff ff       	call   80107d32 <mappages>
80108077:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010807a:	83 ec 04             	sub    $0x4,%esp
8010807d:	ff 75 10             	pushl  0x10(%ebp)
80108080:	ff 75 0c             	pushl  0xc(%ebp)
80108083:	ff 75 f4             	pushl  -0xc(%ebp)
80108086:	e8 f7 d2 ff ff       	call   80105382 <memmove>
8010808b:	83 c4 10             	add    $0x10,%esp
}
8010808e:	c9                   	leave  
8010808f:	c3                   	ret    

80108090 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108090:	55                   	push   %ebp
80108091:	89 e5                	mov    %esp,%ebp
80108093:	53                   	push   %ebx
80108094:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010809a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010809f:	85 c0                	test   %eax,%eax
801080a1:	74 0d                	je     801080b0 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801080a3:	83 ec 0c             	sub    $0xc,%esp
801080a6:	68 b4 8b 10 80       	push   $0x80108bb4
801080ab:	e8 ac 84 ff ff       	call   8010055c <panic>
  for(i = 0; i < sz; i += PGSIZE){
801080b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080b7:	e9 95 00 00 00       	jmp    80108151 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801080bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801080bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c2:	01 d0                	add    %edx,%eax
801080c4:	83 ec 04             	sub    $0x4,%esp
801080c7:	6a 00                	push   $0x0
801080c9:	50                   	push   %eax
801080ca:	ff 75 08             	pushl  0x8(%ebp)
801080cd:	e8 c0 fb ff ff       	call   80107c92 <walkpgdir>
801080d2:	83 c4 10             	add    $0x10,%esp
801080d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080d8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080dc:	75 0d                	jne    801080eb <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801080de:	83 ec 0c             	sub    $0xc,%esp
801080e1:	68 d7 8b 10 80       	push   $0x80108bd7
801080e6:	e8 71 84 ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
801080eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ee:	8b 00                	mov    (%eax),%eax
801080f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080f8:	8b 45 18             	mov    0x18(%ebp),%eax
801080fb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080fe:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108103:	77 0b                	ja     80108110 <loaduvm+0x80>
      n = sz - i;
80108105:	8b 45 18             	mov    0x18(%ebp),%eax
80108108:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010810b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010810e:	eb 07                	jmp    80108117 <loaduvm+0x87>
    else
      n = PGSIZE;
80108110:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108117:	8b 55 14             	mov    0x14(%ebp),%edx
8010811a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108120:	83 ec 0c             	sub    $0xc,%esp
80108123:	ff 75 e8             	pushl  -0x18(%ebp)
80108126:	e8 e6 f6 ff ff       	call   80107811 <p2v>
8010812b:	83 c4 10             	add    $0x10,%esp
8010812e:	ff 75 f0             	pushl  -0x10(%ebp)
80108131:	53                   	push   %ebx
80108132:	50                   	push   %eax
80108133:	ff 75 10             	pushl  0x10(%ebp)
80108136:	e8 03 9d ff ff       	call   80101e3e <readi>
8010813b:	83 c4 10             	add    $0x10,%esp
8010813e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108141:	74 07                	je     8010814a <loaduvm+0xba>
      return -1;
80108143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108148:	eb 18                	jmp    80108162 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010814a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108154:	3b 45 18             	cmp    0x18(%ebp),%eax
80108157:	0f 82 5f ff ff ff    	jb     801080bc <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010815d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108165:	c9                   	leave  
80108166:	c3                   	ret    

80108167 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108167:	55                   	push   %ebp
80108168:	89 e5                	mov    %esp,%ebp
8010816a:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010816d:	8b 45 10             	mov    0x10(%ebp),%eax
80108170:	85 c0                	test   %eax,%eax
80108172:	79 0a                	jns    8010817e <allocuvm+0x17>
    return 0;
80108174:	b8 00 00 00 00       	mov    $0x0,%eax
80108179:	e9 b0 00 00 00       	jmp    8010822e <allocuvm+0xc7>
  if(newsz < oldsz)
8010817e:	8b 45 10             	mov    0x10(%ebp),%eax
80108181:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108184:	73 08                	jae    8010818e <allocuvm+0x27>
    return oldsz;
80108186:	8b 45 0c             	mov    0xc(%ebp),%eax
80108189:	e9 a0 00 00 00       	jmp    8010822e <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010818e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108191:	05 ff 0f 00 00       	add    $0xfff,%eax
80108196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010819b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010819e:	eb 7f                	jmp    8010821f <allocuvm+0xb8>
    mem = kalloc();
801081a0:	e8 03 ab ff ff       	call   80102ca8 <kalloc>
801081a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801081a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ac:	75 2b                	jne    801081d9 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801081ae:	83 ec 0c             	sub    $0xc,%esp
801081b1:	68 f5 8b 10 80       	push   $0x80108bf5
801081b6:	e8 04 82 ff ff       	call   801003bf <cprintf>
801081bb:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801081be:	83 ec 04             	sub    $0x4,%esp
801081c1:	ff 75 0c             	pushl  0xc(%ebp)
801081c4:	ff 75 10             	pushl  0x10(%ebp)
801081c7:	ff 75 08             	pushl  0x8(%ebp)
801081ca:	e8 61 00 00 00       	call   80108230 <deallocuvm>
801081cf:	83 c4 10             	add    $0x10,%esp
      return 0;
801081d2:	b8 00 00 00 00       	mov    $0x0,%eax
801081d7:	eb 55                	jmp    8010822e <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801081d9:	83 ec 04             	sub    $0x4,%esp
801081dc:	68 00 10 00 00       	push   $0x1000
801081e1:	6a 00                	push   $0x0
801081e3:	ff 75 f0             	pushl  -0x10(%ebp)
801081e6:	e8 d8 d0 ff ff       	call   801052c3 <memset>
801081eb:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081ee:	83 ec 0c             	sub    $0xc,%esp
801081f1:	ff 75 f0             	pushl  -0x10(%ebp)
801081f4:	e8 0b f6 ff ff       	call   80107804 <v2p>
801081f9:	83 c4 10             	add    $0x10,%esp
801081fc:	89 c2                	mov    %eax,%edx
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	83 ec 0c             	sub    $0xc,%esp
80108204:	6a 06                	push   $0x6
80108206:	52                   	push   %edx
80108207:	68 00 10 00 00       	push   $0x1000
8010820c:	50                   	push   %eax
8010820d:	ff 75 08             	pushl  0x8(%ebp)
80108210:	e8 1d fb ff ff       	call   80107d32 <mappages>
80108215:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108218:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010821f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108222:	3b 45 10             	cmp    0x10(%ebp),%eax
80108225:	0f 82 75 ff ff ff    	jb     801081a0 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010822b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010822e:	c9                   	leave  
8010822f:	c3                   	ret    

80108230 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108230:	55                   	push   %ebp
80108231:	89 e5                	mov    %esp,%ebp
80108233:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108236:	8b 45 10             	mov    0x10(%ebp),%eax
80108239:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010823c:	72 08                	jb     80108246 <deallocuvm+0x16>
    return oldsz;
8010823e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108241:	e9 a5 00 00 00       	jmp    801082eb <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108246:	8b 45 10             	mov    0x10(%ebp),%eax
80108249:	05 ff 0f 00 00       	add    $0xfff,%eax
8010824e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108253:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108256:	e9 81 00 00 00       	jmp    801082dc <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825e:	83 ec 04             	sub    $0x4,%esp
80108261:	6a 00                	push   $0x0
80108263:	50                   	push   %eax
80108264:	ff 75 08             	pushl  0x8(%ebp)
80108267:	e8 26 fa ff ff       	call   80107c92 <walkpgdir>
8010826c:	83 c4 10             	add    $0x10,%esp
8010826f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108272:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108276:	75 09                	jne    80108281 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108278:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010827f:	eb 54                	jmp    801082d5 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108281:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108284:	8b 00                	mov    (%eax),%eax
80108286:	83 e0 01             	and    $0x1,%eax
80108289:	85 c0                	test   %eax,%eax
8010828b:	74 48                	je     801082d5 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010828d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108290:	8b 00                	mov    (%eax),%eax
80108292:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108297:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010829a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010829e:	75 0d                	jne    801082ad <deallocuvm+0x7d>
        panic("kfree");
801082a0:	83 ec 0c             	sub    $0xc,%esp
801082a3:	68 0d 8c 10 80       	push   $0x80108c0d
801082a8:	e8 af 82 ff ff       	call   8010055c <panic>
      char *v = p2v(pa);
801082ad:	83 ec 0c             	sub    $0xc,%esp
801082b0:	ff 75 ec             	pushl  -0x14(%ebp)
801082b3:	e8 59 f5 ff ff       	call   80107811 <p2v>
801082b8:	83 c4 10             	add    $0x10,%esp
801082bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801082be:	83 ec 0c             	sub    $0xc,%esp
801082c1:	ff 75 e8             	pushl  -0x18(%ebp)
801082c4:	e8 43 a9 ff ff       	call   80102c0c <kfree>
801082c9:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801082cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801082d5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082df:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082e2:	0f 82 73 ff ff ff    	jb     8010825b <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801082e8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082eb:	c9                   	leave  
801082ec:	c3                   	ret    

801082ed <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082ed:	55                   	push   %ebp
801082ee:	89 e5                	mov    %esp,%ebp
801082f0:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801082f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082f7:	75 0d                	jne    80108306 <freevm+0x19>
    panic("freevm: no pgdir");
801082f9:	83 ec 0c             	sub    $0xc,%esp
801082fc:	68 13 8c 10 80       	push   $0x80108c13
80108301:	e8 56 82 ff ff       	call   8010055c <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108306:	83 ec 04             	sub    $0x4,%esp
80108309:	6a 00                	push   $0x0
8010830b:	68 00 00 00 80       	push   $0x80000000
80108310:	ff 75 08             	pushl  0x8(%ebp)
80108313:	e8 18 ff ff ff       	call   80108230 <deallocuvm>
80108318:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010831b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108322:	eb 4f                	jmp    80108373 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108327:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010832e:	8b 45 08             	mov    0x8(%ebp),%eax
80108331:	01 d0                	add    %edx,%eax
80108333:	8b 00                	mov    (%eax),%eax
80108335:	83 e0 01             	and    $0x1,%eax
80108338:	85 c0                	test   %eax,%eax
8010833a:	74 33                	je     8010836f <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010833c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108346:	8b 45 08             	mov    0x8(%ebp),%eax
80108349:	01 d0                	add    %edx,%eax
8010834b:	8b 00                	mov    (%eax),%eax
8010834d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108352:	83 ec 0c             	sub    $0xc,%esp
80108355:	50                   	push   %eax
80108356:	e8 b6 f4 ff ff       	call   80107811 <p2v>
8010835b:	83 c4 10             	add    $0x10,%esp
8010835e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108361:	83 ec 0c             	sub    $0xc,%esp
80108364:	ff 75 f0             	pushl  -0x10(%ebp)
80108367:	e8 a0 a8 ff ff       	call   80102c0c <kfree>
8010836c:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010836f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108373:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010837a:	76 a8                	jbe    80108324 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010837c:	83 ec 0c             	sub    $0xc,%esp
8010837f:	ff 75 08             	pushl  0x8(%ebp)
80108382:	e8 85 a8 ff ff       	call   80102c0c <kfree>
80108387:	83 c4 10             	add    $0x10,%esp
}
8010838a:	c9                   	leave  
8010838b:	c3                   	ret    

8010838c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010838c:	55                   	push   %ebp
8010838d:	89 e5                	mov    %esp,%ebp
8010838f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108392:	83 ec 04             	sub    $0x4,%esp
80108395:	6a 00                	push   $0x0
80108397:	ff 75 0c             	pushl  0xc(%ebp)
8010839a:	ff 75 08             	pushl  0x8(%ebp)
8010839d:	e8 f0 f8 ff ff       	call   80107c92 <walkpgdir>
801083a2:	83 c4 10             	add    $0x10,%esp
801083a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083ac:	75 0d                	jne    801083bb <clearpteu+0x2f>
    panic("clearpteu");
801083ae:	83 ec 0c             	sub    $0xc,%esp
801083b1:	68 24 8c 10 80       	push   $0x80108c24
801083b6:	e8 a1 81 ff ff       	call   8010055c <panic>
  *pte &= ~PTE_U;
801083bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083be:	8b 00                	mov    (%eax),%eax
801083c0:	83 e0 fb             	and    $0xfffffffb,%eax
801083c3:	89 c2                	mov    %eax,%edx
801083c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c8:	89 10                	mov    %edx,(%eax)
}
801083ca:	c9                   	leave  
801083cb:	c3                   	ret    

801083cc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083cc:	55                   	push   %ebp
801083cd:	89 e5                	mov    %esp,%ebp
801083cf:	53                   	push   %ebx
801083d0:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801083d3:	e8 ec f9 ff ff       	call   80107dc4 <setupkvm>
801083d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083df:	75 0a                	jne    801083eb <copyuvm+0x1f>
    return 0;
801083e1:	b8 00 00 00 00       	mov    $0x0,%eax
801083e6:	e9 f8 00 00 00       	jmp    801084e3 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801083eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083f2:	e9 c8 00 00 00       	jmp    801084bf <copyuvm+0xf3>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	83 ec 04             	sub    $0x4,%esp
801083fd:	6a 00                	push   $0x0
801083ff:	50                   	push   %eax
80108400:	ff 75 08             	pushl  0x8(%ebp)
80108403:	e8 8a f8 ff ff       	call   80107c92 <walkpgdir>
80108408:	83 c4 10             	add    $0x10,%esp
8010840b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010840e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108412:	75 0d                	jne    80108421 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108414:	83 ec 0c             	sub    $0xc,%esp
80108417:	68 2e 8c 10 80       	push   $0x80108c2e
8010841c:	e8 3b 81 ff ff       	call   8010055c <panic>
    if(!(*pte & PTE_P))
80108421:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108424:	8b 00                	mov    (%eax),%eax
80108426:	83 e0 01             	and    $0x1,%eax
80108429:	85 c0                	test   %eax,%eax
8010842b:	75 0d                	jne    8010843a <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010842d:	83 ec 0c             	sub    $0xc,%esp
80108430:	68 48 8c 10 80       	push   $0x80108c48
80108435:	e8 22 81 ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
8010843a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010843d:	8b 00                	mov    (%eax),%eax
8010843f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108444:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844a:	8b 00                	mov    (%eax),%eax
8010844c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108454:	e8 4f a8 ff ff       	call   80102ca8 <kalloc>
80108459:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010845c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108460:	75 02                	jne    80108464 <copyuvm+0x98>
      goto bad;
80108462:	eb 6c                	jmp    801084d0 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108464:	83 ec 0c             	sub    $0xc,%esp
80108467:	ff 75 e8             	pushl  -0x18(%ebp)
8010846a:	e8 a2 f3 ff ff       	call   80107811 <p2v>
8010846f:	83 c4 10             	add    $0x10,%esp
80108472:	83 ec 04             	sub    $0x4,%esp
80108475:	68 00 10 00 00       	push   $0x1000
8010847a:	50                   	push   %eax
8010847b:	ff 75 e0             	pushl  -0x20(%ebp)
8010847e:	e8 ff ce ff ff       	call   80105382 <memmove>
80108483:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108486:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108489:	83 ec 0c             	sub    $0xc,%esp
8010848c:	ff 75 e0             	pushl  -0x20(%ebp)
8010848f:	e8 70 f3 ff ff       	call   80107804 <v2p>
80108494:	83 c4 10             	add    $0x10,%esp
80108497:	89 c2                	mov    %eax,%edx
80108499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849c:	83 ec 0c             	sub    $0xc,%esp
8010849f:	53                   	push   %ebx
801084a0:	52                   	push   %edx
801084a1:	68 00 10 00 00       	push   $0x1000
801084a6:	50                   	push   %eax
801084a7:	ff 75 f0             	pushl  -0x10(%ebp)
801084aa:	e8 83 f8 ff ff       	call   80107d32 <mappages>
801084af:	83 c4 20             	add    $0x20,%esp
801084b2:	85 c0                	test   %eax,%eax
801084b4:	79 02                	jns    801084b8 <copyuvm+0xec>
      goto bad;
801084b6:	eb 18                	jmp    801084d0 <copyuvm+0x104>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801084b8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084c5:	0f 82 2c ff ff ff    	jb     801083f7 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801084cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ce:	eb 13                	jmp    801084e3 <copyuvm+0x117>

bad:
  freevm(d);
801084d0:	83 ec 0c             	sub    $0xc,%esp
801084d3:	ff 75 f0             	pushl  -0x10(%ebp)
801084d6:	e8 12 fe ff ff       	call   801082ed <freevm>
801084db:	83 c4 10             	add    $0x10,%esp
  return 0;
801084de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084e6:	c9                   	leave  
801084e7:	c3                   	ret    

801084e8 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084e8:	55                   	push   %ebp
801084e9:	89 e5                	mov    %esp,%ebp
801084eb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084ee:	83 ec 04             	sub    $0x4,%esp
801084f1:	6a 00                	push   $0x0
801084f3:	ff 75 0c             	pushl  0xc(%ebp)
801084f6:	ff 75 08             	pushl  0x8(%ebp)
801084f9:	e8 94 f7 ff ff       	call   80107c92 <walkpgdir>
801084fe:	83 c4 10             	add    $0x10,%esp
80108501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108507:	8b 00                	mov    (%eax),%eax
80108509:	83 e0 01             	and    $0x1,%eax
8010850c:	85 c0                	test   %eax,%eax
8010850e:	75 07                	jne    80108517 <uva2ka+0x2f>
    return 0;
80108510:	b8 00 00 00 00       	mov    $0x0,%eax
80108515:	eb 29                	jmp    80108540 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	8b 00                	mov    (%eax),%eax
8010851c:	83 e0 04             	and    $0x4,%eax
8010851f:	85 c0                	test   %eax,%eax
80108521:	75 07                	jne    8010852a <uva2ka+0x42>
    return 0;
80108523:	b8 00 00 00 00       	mov    $0x0,%eax
80108528:	eb 16                	jmp    80108540 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	8b 00                	mov    (%eax),%eax
8010852f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108534:	83 ec 0c             	sub    $0xc,%esp
80108537:	50                   	push   %eax
80108538:	e8 d4 f2 ff ff       	call   80107811 <p2v>
8010853d:	83 c4 10             	add    $0x10,%esp
}
80108540:	c9                   	leave  
80108541:	c3                   	ret    

80108542 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108542:	55                   	push   %ebp
80108543:	89 e5                	mov    %esp,%ebp
80108545:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108548:	8b 45 10             	mov    0x10(%ebp),%eax
8010854b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010854e:	eb 7f                	jmp    801085cf <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108550:	8b 45 0c             	mov    0xc(%ebp),%eax
80108553:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108558:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010855b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855e:	83 ec 08             	sub    $0x8,%esp
80108561:	50                   	push   %eax
80108562:	ff 75 08             	pushl  0x8(%ebp)
80108565:	e8 7e ff ff ff       	call   801084e8 <uva2ka>
8010856a:	83 c4 10             	add    $0x10,%esp
8010856d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108570:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108574:	75 07                	jne    8010857d <copyout+0x3b>
      return -1;
80108576:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010857b:	eb 61                	jmp    801085de <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010857d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108580:	2b 45 0c             	sub    0xc(%ebp),%eax
80108583:	05 00 10 00 00       	add    $0x1000,%eax
80108588:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010858b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108591:	76 06                	jbe    80108599 <copyout+0x57>
      n = len;
80108593:	8b 45 14             	mov    0x14(%ebp),%eax
80108596:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108599:	8b 45 0c             	mov    0xc(%ebp),%eax
8010859c:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010859f:	89 c2                	mov    %eax,%edx
801085a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085a4:	01 d0                	add    %edx,%eax
801085a6:	83 ec 04             	sub    $0x4,%esp
801085a9:	ff 75 f0             	pushl  -0x10(%ebp)
801085ac:	ff 75 f4             	pushl  -0xc(%ebp)
801085af:	50                   	push   %eax
801085b0:	e8 cd cd ff ff       	call   80105382 <memmove>
801085b5:	83 c4 10             	add    $0x10,%esp
    len -= n;
801085b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bb:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c7:	05 00 10 00 00       	add    $0x1000,%eax
801085cc:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085cf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085d3:	0f 85 77 ff ff ff    	jne    80108550 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801085d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085de:	c9                   	leave  
801085df:	c3                   	ret    
