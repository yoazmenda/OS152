
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
80100028:	bc b0 c6 10 80       	mov    $0x8010c6b0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 d3 38 10 80       	mov    $0x801038d3,%eax
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
8010003d:	68 e0 87 10 80       	push   $0x801087e0
80100042:	68 c0 c6 10 80       	push   $0x8010c6c0
80100047:	e8 f9 51 00 00       	call   80105245 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 d0 05 11 80 c4 	movl   $0x801105c4,0x801105d0
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d4 05 11 80 c4 	movl   $0x801105c4,0x801105d4
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 f4 c6 10 80 	movl   $0x8010c6f4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 d4 05 11 80    	mov    0x801105d4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c c4 05 11 80 	movl   $0x801105c4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 d4 05 11 80       	mov    0x801105d4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 d4 05 11 80       	mov    %eax,0x801105d4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	81 7d f4 c4 05 11 80 	cmpl   $0x801105c4,-0xc(%ebp)
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
801000ba:	68 c0 c6 10 80       	push   $0x8010c6c0
801000bf:	e8 a2 51 00 00       	call   80105266 <acquire>
801000c4:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c7:	a1 d4 05 11 80       	mov    0x801105d4,%eax
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
80100105:	68 c0 c6 10 80       	push   $0x8010c6c0
8010010a:	e8 bd 51 00 00       	call   801052cc <release>
8010010f:	83 c4 10             	add    $0x10,%esp
        return b;
80100112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100115:	e9 98 00 00 00       	jmp    801001b2 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011a:	83 ec 08             	sub    $0x8,%esp
8010011d:	68 c0 c6 10 80       	push   $0x8010c6c0
80100122:	ff 75 f4             	pushl  -0xc(%ebp)
80100125:	e8 08 4c 00 00       	call   80104d32 <sleep>
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
80100138:	81 7d f4 c4 05 11 80 	cmpl   $0x801105c4,-0xc(%ebp)
8010013f:	75 90                	jne    801000d1 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 d0 05 11 80       	mov    0x801105d0,%eax
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
80100181:	68 c0 c6 10 80       	push   $0x8010c6c0
80100186:	e8 41 51 00 00       	call   801052cc <release>
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
8010019c:	81 7d f4 c4 05 11 80 	cmpl   $0x801105c4,-0xc(%ebp)
801001a3:	75 a6                	jne    8010014b <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	68 e7 87 10 80       	push   $0x801087e7
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
801001e0:	e8 7e 27 00 00       	call   80102963 <iderw>
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
80100202:	68 f8 87 10 80       	push   $0x801087f8
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
80100221:	e8 3d 27 00 00       	call   80102963 <iderw>
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
80100240:	68 ff 87 10 80       	push   $0x801087ff
80100245:	e8 12 03 00 00       	call   8010055c <panic>

  acquire(&bcache.lock);
8010024a:	83 ec 0c             	sub    $0xc,%esp
8010024d:	68 c0 c6 10 80       	push   $0x8010c6c0
80100252:	e8 0f 50 00 00       	call   80105266 <acquire>
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
80100278:	8b 15 d4 05 11 80    	mov    0x801105d4,%edx
8010027e:	8b 45 08             	mov    0x8(%ebp),%eax
80100281:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100284:	8b 45 08             	mov    0x8(%ebp),%eax
80100287:	c7 40 0c c4 05 11 80 	movl   $0x801105c4,0xc(%eax)
  bcache.head.next->prev = b;
8010028e:	a1 d4 05 11 80       	mov    0x801105d4,%eax
80100293:	8b 55 08             	mov    0x8(%ebp),%edx
80100296:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100299:	8b 45 08             	mov    0x8(%ebp),%eax
8010029c:	a3 d4 05 11 80       	mov    %eax,0x801105d4

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
801002b6:	e8 60 4b 00 00       	call   80104e1b <wakeup>
801002bb:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 c0 c6 10 80       	push   $0x8010c6c0
801002c6:	e8 01 50 00 00       	call   801052cc <release>
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
801003c5:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801003ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d1:	74 10                	je     801003e3 <cprintf+0x24>
    acquire(&cons.lock);
801003d3:	83 ec 0c             	sub    $0xc,%esp
801003d6:	68 20 b6 10 80       	push   $0x8010b620
801003db:	e8 86 4e 00 00       	call   80105266 <acquire>
801003e0:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e3:	8b 45 08             	mov    0x8(%ebp),%eax
801003e6:	85 c0                	test   %eax,%eax
801003e8:	75 0d                	jne    801003f7 <cprintf+0x38>
    panic("null fmt");
801003ea:	83 ec 0c             	sub    $0xc,%esp
801003ed:	68 06 88 10 80       	push   $0x80108806
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
801004c7:	c7 45 ec 0f 88 10 80 	movl   $0x8010880f,-0x14(%ebp)
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
8010054d:	68 20 b6 10 80       	push   $0x8010b620
80100552:	e8 75 4d 00 00       	call   801052cc <release>
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
80100567:	c7 05 54 b6 10 80 00 	movl   $0x0,0x8010b654
8010056e:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100571:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100577:	0f b6 00             	movzbl (%eax),%eax
8010057a:	0f b6 c0             	movzbl %al,%eax
8010057d:	83 ec 08             	sub    $0x8,%esp
80100580:	50                   	push   %eax
80100581:	68 16 88 10 80       	push   $0x80108816
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
801005a0:	68 25 88 10 80       	push   $0x80108825
801005a5:	e8 15 fe ff ff       	call   801003bf <cprintf>
801005aa:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ad:	83 ec 08             	sub    $0x8,%esp
801005b0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005b3:	50                   	push   %eax
801005b4:	8d 45 08             	lea    0x8(%ebp),%eax
801005b7:	50                   	push   %eax
801005b8:	e8 60 4d 00 00       	call   8010531d <getcallerpcs>
801005bd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005c7:	eb 1c                	jmp    801005e5 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005cc:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005d0:	83 ec 08             	sub    $0x8,%esp
801005d3:	50                   	push   %eax
801005d4:	68 27 88 10 80       	push   $0x80108827
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
801005eb:	c7 05 00 b6 10 80 01 	movl   $0x1,0x8010b600
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
801006d1:	e8 ab 4e 00 00       	call   80105581 <memmove>
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
801006fb:	e8 c2 4d 00 00       	call   801054c2 <memset>
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
80100771:	a1 00 b6 10 80       	mov    0x8010b600,%eax
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
8010078f:	e8 df 66 00 00       	call   80106e73 <uartputc>
80100794:	83 c4 10             	add    $0x10,%esp
80100797:	83 ec 0c             	sub    $0xc,%esp
8010079a:	6a 20                	push   $0x20
8010079c:	e8 d2 66 00 00       	call   80106e73 <uartputc>
801007a1:	83 c4 10             	add    $0x10,%esp
801007a4:	83 ec 0c             	sub    $0xc,%esp
801007a7:	6a 08                	push   $0x8
801007a9:	e8 c5 66 00 00       	call   80106e73 <uartputc>
801007ae:	83 c4 10             	add    $0x10,%esp
801007b1:	eb 0e                	jmp    801007c1 <consputc+0x56>
  } else
    uartputc(c);
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	ff 75 08             	pushl  0x8(%ebp)
801007b9:	e8 b5 66 00 00       	call   80106e73 <uartputc>
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
801007da:	68 00 08 11 80       	push   $0x80110800
801007df:	e8 82 4a 00 00       	call   80105266 <acquire>
801007e4:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007e7:	e9 43 01 00 00       	jmp    8010092f <consoleintr+0x15e>
    switch(c){
801007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007ef:	83 f8 10             	cmp    $0x10,%eax
801007f2:	74 1e                	je     80100812 <consoleintr+0x41>
801007f4:	83 f8 10             	cmp    $0x10,%eax
801007f7:	7f 0a                	jg     80100803 <consoleintr+0x32>
801007f9:	83 f8 08             	cmp    $0x8,%eax
801007fc:	74 67                	je     80100865 <consoleintr+0x94>
801007fe:	e9 93 00 00 00       	jmp    80100896 <consoleintr+0xc5>
80100803:	83 f8 15             	cmp    $0x15,%eax
80100806:	74 31                	je     80100839 <consoleintr+0x68>
80100808:	83 f8 7f             	cmp    $0x7f,%eax
8010080b:	74 58                	je     80100865 <consoleintr+0x94>
8010080d:	e9 84 00 00 00       	jmp    80100896 <consoleintr+0xc5>
    case C('P'):  // Process listing.
      procdump();
80100812:	e8 be 46 00 00       	call   80104ed5 <procdump>
      break;
80100817:	e9 13 01 00 00       	jmp    8010092f <consoleintr+0x15e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010081c:	a1 bc 08 11 80       	mov    0x801108bc,%eax
80100821:	83 e8 01             	sub    $0x1,%eax
80100824:	a3 bc 08 11 80       	mov    %eax,0x801108bc
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
80100839:	8b 15 bc 08 11 80    	mov    0x801108bc,%edx
8010083f:	a1 b8 08 11 80       	mov    0x801108b8,%eax
80100844:	39 c2                	cmp    %eax,%edx
80100846:	74 18                	je     80100860 <consoleintr+0x8f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100848:	a1 bc 08 11 80       	mov    0x801108bc,%eax
8010084d:	83 e8 01             	sub    $0x1,%eax
80100850:	83 e0 7f             	and    $0x7f,%eax
80100853:	05 00 08 11 80       	add    $0x80110800,%eax
80100858:	0f b6 40 34          	movzbl 0x34(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010085c:	3c 0a                	cmp    $0xa,%al
8010085e:	75 bc                	jne    8010081c <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100860:	e9 ca 00 00 00       	jmp    8010092f <consoleintr+0x15e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100865:	8b 15 bc 08 11 80    	mov    0x801108bc,%edx
8010086b:	a1 b8 08 11 80       	mov    0x801108b8,%eax
80100870:	39 c2                	cmp    %eax,%edx
80100872:	74 1d                	je     80100891 <consoleintr+0xc0>
        input.e--;
80100874:	a1 bc 08 11 80       	mov    0x801108bc,%eax
80100879:	83 e8 01             	sub    $0x1,%eax
8010087c:	a3 bc 08 11 80       	mov    %eax,0x801108bc
        consputc(BACKSPACE);
80100881:	83 ec 0c             	sub    $0xc,%esp
80100884:	68 00 01 00 00       	push   $0x100
80100889:	e8 dd fe ff ff       	call   8010076b <consputc>
8010088e:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100891:	e9 99 00 00 00       	jmp    8010092f <consoleintr+0x15e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100896:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010089a:	0f 84 8e 00 00 00    	je     8010092e <consoleintr+0x15d>
801008a0:	8b 15 bc 08 11 80    	mov    0x801108bc,%edx
801008a6:	a1 b4 08 11 80       	mov    0x801108b4,%eax
801008ab:	29 c2                	sub    %eax,%edx
801008ad:	89 d0                	mov    %edx,%eax
801008af:	83 f8 7f             	cmp    $0x7f,%eax
801008b2:	77 7a                	ja     8010092e <consoleintr+0x15d>
        c = (c == '\r') ? '\n' : c;
801008b4:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008b8:	74 05                	je     801008bf <consoleintr+0xee>
801008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bd:	eb 05                	jmp    801008c4 <consoleintr+0xf3>
801008bf:	b8 0a 00 00 00       	mov    $0xa,%eax
801008c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c7:	a1 bc 08 11 80       	mov    0x801108bc,%eax
801008cc:	8d 50 01             	lea    0x1(%eax),%edx
801008cf:	89 15 bc 08 11 80    	mov    %edx,0x801108bc
801008d5:	83 e0 7f             	and    $0x7f,%eax
801008d8:	89 c2                	mov    %eax,%edx
801008da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008dd:	89 c1                	mov    %eax,%ecx
801008df:	8d 82 00 08 11 80    	lea    -0x7feef800(%edx),%eax
801008e5:	88 48 34             	mov    %cl,0x34(%eax)
        consputc(c);
801008e8:	83 ec 0c             	sub    $0xc,%esp
801008eb:	ff 75 f4             	pushl  -0xc(%ebp)
801008ee:	e8 78 fe ff ff       	call   8010076b <consputc>
801008f3:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008f6:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008fa:	74 18                	je     80100914 <consoleintr+0x143>
801008fc:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80100900:	74 12                	je     80100914 <consoleintr+0x143>
80100902:	a1 bc 08 11 80       	mov    0x801108bc,%eax
80100907:	8b 15 b4 08 11 80    	mov    0x801108b4,%edx
8010090d:	83 ea 80             	sub    $0xffffff80,%edx
80100910:	39 d0                	cmp    %edx,%eax
80100912:	75 1a                	jne    8010092e <consoleintr+0x15d>
          input.w = input.e;
80100914:	a1 bc 08 11 80       	mov    0x801108bc,%eax
80100919:	a3 b8 08 11 80       	mov    %eax,0x801108b8
          wakeup(&input.r);
8010091e:	83 ec 0c             	sub    $0xc,%esp
80100921:	68 b4 08 11 80       	push   $0x801108b4
80100926:	e8 f0 44 00 00       	call   80104e1b <wakeup>
8010092b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010092e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010092f:	8b 45 08             	mov    0x8(%ebp),%eax
80100932:	ff d0                	call   *%eax
80100934:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100937:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010093b:	0f 89 ab fe ff ff    	jns    801007ec <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100941:	83 ec 0c             	sub    $0xc,%esp
80100944:	68 00 08 11 80       	push   $0x80110800
80100949:	e8 7e 49 00 00       	call   801052cc <release>
8010094e:	83 c4 10             	add    $0x10,%esp
}
80100951:	c9                   	leave  
80100952:	c3                   	ret    

80100953 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int off, int n)
{
80100953:	55                   	push   %ebp
80100954:	89 e5                	mov    %esp,%ebp
80100956:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100959:	83 ec 0c             	sub    $0xc,%esp
8010095c:	ff 75 08             	pushl  0x8(%ebp)
8010095f:	e8 da 10 00 00       	call   80101a3e <iunlock>
80100964:	83 c4 10             	add    $0x10,%esp
  target = n;
80100967:	8b 45 14             	mov    0x14(%ebp),%eax
8010096a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010096d:	83 ec 0c             	sub    $0xc,%esp
80100970:	68 00 08 11 80       	push   $0x80110800
80100975:	e8 ec 48 00 00       	call   80105266 <acquire>
8010097a:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
8010097d:	e9 b4 00 00 00       	jmp    80100a36 <consoleread+0xe3>
    while(input.r == input.w){
80100982:	eb 4a                	jmp    801009ce <consoleread+0x7b>
      if(proc->killed){
80100984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010098a:	8b 40 24             	mov    0x24(%eax),%eax
8010098d:	85 c0                	test   %eax,%eax
8010098f:	74 28                	je     801009b9 <consoleread+0x66>
        release(&input.lock);
80100991:	83 ec 0c             	sub    $0xc,%esp
80100994:	68 00 08 11 80       	push   $0x80110800
80100999:	e8 2e 49 00 00       	call   801052cc <release>
8010099e:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009a1:	83 ec 0c             	sub    $0xc,%esp
801009a4:	ff 75 08             	pushl  0x8(%ebp)
801009a7:	e8 3b 0f 00 00       	call   801018e7 <ilock>
801009ac:	83 c4 10             	add    $0x10,%esp
        return -1;
801009af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009b4:	e9 af 00 00 00       	jmp    80100a68 <consoleread+0x115>
      }
      sleep(&input.r, &input.lock);
801009b9:	83 ec 08             	sub    $0x8,%esp
801009bc:	68 00 08 11 80       	push   $0x80110800
801009c1:	68 b4 08 11 80       	push   $0x801108b4
801009c6:	e8 67 43 00 00       	call   80104d32 <sleep>
801009cb:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009ce:	8b 15 b4 08 11 80    	mov    0x801108b4,%edx
801009d4:	a1 b8 08 11 80       	mov    0x801108b8,%eax
801009d9:	39 c2                	cmp    %eax,%edx
801009db:	74 a7                	je     80100984 <consoleread+0x31>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009dd:	a1 b4 08 11 80       	mov    0x801108b4,%eax
801009e2:	8d 50 01             	lea    0x1(%eax),%edx
801009e5:	89 15 b4 08 11 80    	mov    %edx,0x801108b4
801009eb:	83 e0 7f             	and    $0x7f,%eax
801009ee:	05 00 08 11 80       	add    $0x80110800,%eax
801009f3:	0f b6 40 34          	movzbl 0x34(%eax),%eax
801009f7:	0f be c0             	movsbl %al,%eax
801009fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009fd:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a01:	75 19                	jne    80100a1c <consoleread+0xc9>
      if(n < target){
80100a03:	8b 45 14             	mov    0x14(%ebp),%eax
80100a06:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a09:	73 0f                	jae    80100a1a <consoleread+0xc7>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a0b:	a1 b4 08 11 80       	mov    0x801108b4,%eax
80100a10:	83 e8 01             	sub    $0x1,%eax
80100a13:	a3 b4 08 11 80       	mov    %eax,0x801108b4
      }
      break;
80100a18:	eb 26                	jmp    80100a40 <consoleread+0xed>
80100a1a:	eb 24                	jmp    80100a40 <consoleread+0xed>
    }
    *dst++ = c;
80100a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a1f:	8d 50 01             	lea    0x1(%eax),%edx
80100a22:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a28:	88 10                	mov    %dl,(%eax)
    --n;
80100a2a:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
    if(c == '\n')
80100a2e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a32:	75 02                	jne    80100a36 <consoleread+0xe3>
      break;
80100a34:	eb 0a                	jmp    80100a40 <consoleread+0xed>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a36:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80100a3a:	0f 8f 42 ff ff ff    	jg     80100982 <consoleread+0x2f>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
80100a40:	83 ec 0c             	sub    $0xc,%esp
80100a43:	68 00 08 11 80       	push   $0x80110800
80100a48:	e8 7f 48 00 00       	call   801052cc <release>
80100a4d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a50:	83 ec 0c             	sub    $0xc,%esp
80100a53:	ff 75 08             	pushl  0x8(%ebp)
80100a56:	e8 8c 0e 00 00       	call   801018e7 <ilock>
80100a5b:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a5e:	8b 45 14             	mov    0x14(%ebp),%eax
80100a61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a64:	29 c2                	sub    %eax,%edx
80100a66:	89 d0                	mov    %edx,%eax
}
80100a68:	c9                   	leave  
80100a69:	c3                   	ret    

80100a6a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a6a:	55                   	push   %ebp
80100a6b:	89 e5                	mov    %esp,%ebp
80100a6d:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a70:	83 ec 0c             	sub    $0xc,%esp
80100a73:	ff 75 08             	pushl  0x8(%ebp)
80100a76:	e8 c3 0f 00 00       	call   80101a3e <iunlock>
80100a7b:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a7e:	83 ec 0c             	sub    $0xc,%esp
80100a81:	68 20 b6 10 80       	push   $0x8010b620
80100a86:	e8 db 47 00 00       	call   80105266 <acquire>
80100a8b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a95:	eb 21                	jmp    80100ab8 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a9d:	01 d0                	add    %edx,%eax
80100a9f:	0f b6 00             	movzbl (%eax),%eax
80100aa2:	0f be c0             	movsbl %al,%eax
80100aa5:	0f b6 c0             	movzbl %al,%eax
80100aa8:	83 ec 0c             	sub    $0xc,%esp
80100aab:	50                   	push   %eax
80100aac:	e8 ba fc ff ff       	call   8010076b <consputc>
80100ab1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100ab4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100abb:	3b 45 10             	cmp    0x10(%ebp),%eax
80100abe:	7c d7                	jl     80100a97 <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac0:	83 ec 0c             	sub    $0xc,%esp
80100ac3:	68 20 b6 10 80       	push   $0x8010b620
80100ac8:	e8 ff 47 00 00       	call   801052cc <release>
80100acd:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad0:	83 ec 0c             	sub    $0xc,%esp
80100ad3:	ff 75 08             	pushl  0x8(%ebp)
80100ad6:	e8 0c 0e 00 00       	call   801018e7 <ilock>
80100adb:	83 c4 10             	add    $0x10,%esp

  return n;
80100ade:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae1:	c9                   	leave  
80100ae2:	c3                   	ret    

80100ae3 <consoleinit>:

void
consoleinit(void)
{
80100ae3:	55                   	push   %ebp
80100ae4:	89 e5                	mov    %esp,%ebp
80100ae6:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100ae9:	83 ec 08             	sub    $0x8,%esp
80100aec:	68 2b 88 10 80       	push   $0x8010882b
80100af1:	68 20 b6 10 80       	push   $0x8010b620
80100af6:	e8 4a 47 00 00       	call   80105245 <initlock>
80100afb:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100afe:	83 ec 08             	sub    $0x8,%esp
80100b01:	68 33 88 10 80       	push   $0x80108833
80100b06:	68 00 08 11 80       	push   $0x80110800
80100b0b:	e8 35 47 00 00       	call   80105245 <initlock>
80100b10:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b13:	c7 05 9c 12 11 80 6a 	movl   $0x80100a6a,0x8011129c
80100b1a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b1d:	c7 05 98 12 11 80 53 	movl   $0x80100953,0x80111298
80100b24:	09 10 80 
  cons.locking = 1;
80100b27:	c7 05 54 b6 10 80 01 	movl   $0x1,0x8010b654
80100b2e:	00 00 00 

  picenable(IRQ_KBD);
80100b31:	83 ec 0c             	sub    $0xc,%esp
80100b34:	6a 01                	push   $0x1
80100b36:	e8 37 34 00 00       	call   80103f72 <picenable>
80100b3b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b3e:	83 ec 08             	sub    $0x8,%esp
80100b41:	6a 00                	push   $0x0
80100b43:	6a 01                	push   $0x1
80100b45:	e8 e2 1f 00 00       	call   80102b2c <ioapicenable>
80100b4a:	83 c4 10             	add    $0x10,%esp
}
80100b4d:	c9                   	leave  
80100b4e:	c3                   	ret    

80100b4f <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b4f:	55                   	push   %ebp
80100b50:	89 e5                	mov    %esp,%ebp
80100b52:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b58:	e8 37 2a 00 00       	call   80103594 <begin_op>
  if((ip = namei(path)) == 0){
80100b5d:	83 ec 0c             	sub    $0xc,%esp
80100b60:	ff 75 08             	pushl  0x8(%ebp)
80100b63:	e8 57 1a 00 00       	call   801025bf <namei>
80100b68:	83 c4 10             	add    $0x10,%esp
80100b6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b6e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b72:	75 0f                	jne    80100b83 <exec+0x34>
    end_op();
80100b74:	e8 a9 2a 00 00       	call   80103622 <end_op>
    return -1;
80100b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b7e:	e9 b9 03 00 00       	jmp    80100f3c <exec+0x3ed>
  }
  ilock(ip);
80100b83:	83 ec 0c             	sub    $0xc,%esp
80100b86:	ff 75 d8             	pushl  -0x28(%ebp)
80100b89:	e8 59 0d 00 00       	call   801018e7 <ilock>
80100b8e:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b91:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b98:	6a 34                	push   $0x34
80100b9a:	6a 00                	push   $0x0
80100b9c:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba2:	50                   	push   %eax
80100ba3:	ff 75 d8             	pushl  -0x28(%ebp)
80100ba6:	e8 9e 12 00 00       	call   80101e49 <readi>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	83 f8 33             	cmp    $0x33,%eax
80100bb1:	77 05                	ja     80100bb8 <exec+0x69>
    goto bad;
80100bb3:	e9 52 03 00 00       	jmp    80100f0a <exec+0x3bb>
  if(elf.magic != ELF_MAGIC)
80100bb8:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bbe:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc3:	74 05                	je     80100bca <exec+0x7b>
    goto bad;
80100bc5:	e9 40 03 00 00       	jmp    80100f0a <exec+0x3bb>

  if((pgdir = setupkvm()) == 0)
80100bca:	e8 f4 73 00 00       	call   80107fc3 <setupkvm>
80100bcf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bd6:	75 05                	jne    80100bdd <exec+0x8e>
    goto bad;
80100bd8:	e9 2d 03 00 00       	jmp    80100f0a <exec+0x3bb>

  // Load program into memory.
  sz = 0;
80100bdd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100beb:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf4:	e9 ae 00 00 00       	jmp    80100ca7 <exec+0x158>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bfc:	6a 20                	push   $0x20
80100bfe:	50                   	push   %eax
80100bff:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c05:	50                   	push   %eax
80100c06:	ff 75 d8             	pushl  -0x28(%ebp)
80100c09:	e8 3b 12 00 00       	call   80101e49 <readi>
80100c0e:	83 c4 10             	add    $0x10,%esp
80100c11:	83 f8 20             	cmp    $0x20,%eax
80100c14:	74 05                	je     80100c1b <exec+0xcc>
      goto bad;
80100c16:	e9 ef 02 00 00       	jmp    80100f0a <exec+0x3bb>
    if(ph.type != ELF_PROG_LOAD)
80100c1b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c21:	83 f8 01             	cmp    $0x1,%eax
80100c24:	74 02                	je     80100c28 <exec+0xd9>
      continue;
80100c26:	eb 72                	jmp    80100c9a <exec+0x14b>
    if(ph.memsz < ph.filesz)
80100c28:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c34:	39 c2                	cmp    %eax,%edx
80100c36:	73 05                	jae    80100c3d <exec+0xee>
      goto bad;
80100c38:	e9 cd 02 00 00       	jmp    80100f0a <exec+0x3bb>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 0c 77 00 00       	call   80108366 <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	75 05                	jne    80100c6b <exec+0x11c>
      goto bad;
80100c66:	e9 9f 02 00 00       	jmp    80100f0a <exec+0x3bb>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6b:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c71:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c77:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7d:	83 ec 0c             	sub    $0xc,%esp
80100c80:	52                   	push   %edx
80100c81:	50                   	push   %eax
80100c82:	ff 75 d8             	pushl  -0x28(%ebp)
80100c85:	51                   	push   %ecx
80100c86:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c89:	e8 01 76 00 00       	call   8010828f <loaduvm>
80100c8e:	83 c4 20             	add    $0x20,%esp
80100c91:	85 c0                	test   %eax,%eax
80100c93:	79 05                	jns    80100c9a <exec+0x14b>
      goto bad;
80100c95:	e9 70 02 00 00       	jmp    80100f0a <exec+0x3bb>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca1:	83 c0 20             	add    $0x20,%eax
80100ca4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca7:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cae:	0f b7 c0             	movzwl %ax,%eax
80100cb1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb4:	0f 8f 3f ff ff ff    	jg     80100bf9 <exec+0xaa>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cba:	83 ec 0c             	sub    $0xc,%esp
80100cbd:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc0:	e8 d9 0e 00 00       	call   80101b9e <iunlockput>
80100cc5:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc8:	e8 55 29 00 00       	call   80103622 <end_op>
  ip = 0;
80100ccd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd7:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce7:	05 00 20 00 00       	add    $0x2000,%eax
80100cec:	83 ec 04             	sub    $0x4,%esp
80100cef:	50                   	push   %eax
80100cf0:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf6:	e8 6b 76 00 00       	call   80108366 <allocuvm>
80100cfb:	83 c4 10             	add    $0x10,%esp
80100cfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d01:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d05:	75 05                	jne    80100d0c <exec+0x1bd>
    goto bad;
80100d07:	e9 fe 01 00 00       	jmp    80100f0a <exec+0x3bb>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d14:	83 ec 08             	sub    $0x8,%esp
80100d17:	50                   	push   %eax
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 6b 78 00 00       	call   8010858b <clearpteu>
80100d20:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d26:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d30:	e9 98 00 00 00       	jmp    80100dcd <exec+0x27e>
    if(argc >= MAXARG)
80100d35:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d39:	76 05                	jbe    80100d40 <exec+0x1f1>
      goto bad;
80100d3b:	e9 ca 01 00 00       	jmp    80100f0a <exec+0x3bb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4d:	01 d0                	add    %edx,%eax
80100d4f:	8b 00                	mov    (%eax),%eax
80100d51:	83 ec 0c             	sub    $0xc,%esp
80100d54:	50                   	push   %eax
80100d55:	e8 b7 49 00 00       	call   80105711 <strlen>
80100d5a:	83 c4 10             	add    $0x10,%esp
80100d5d:	89 c2                	mov    %eax,%edx
80100d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d62:	29 d0                	sub    %edx,%eax
80100d64:	83 e8 01             	sub    $0x1,%eax
80100d67:	83 e0 fc             	and    $0xfffffffc,%eax
80100d6a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d7a:	01 d0                	add    %edx,%eax
80100d7c:	8b 00                	mov    (%eax),%eax
80100d7e:	83 ec 0c             	sub    $0xc,%esp
80100d81:	50                   	push   %eax
80100d82:	e8 8a 49 00 00       	call   80105711 <strlen>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	83 c0 01             	add    $0x1,%eax
80100d8d:	89 c1                	mov    %eax,%ecx
80100d8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d99:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9c:	01 d0                	add    %edx,%eax
80100d9e:	8b 00                	mov    (%eax),%eax
80100da0:	51                   	push   %ecx
80100da1:	50                   	push   %eax
80100da2:	ff 75 dc             	pushl  -0x24(%ebp)
80100da5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da8:	e8 94 79 00 00       	call   80108741 <copyout>
80100dad:	83 c4 10             	add    $0x10,%esp
80100db0:	85 c0                	test   %eax,%eax
80100db2:	79 05                	jns    80100db9 <exec+0x26a>
      goto bad;
80100db4:	e9 51 01 00 00       	jmp    80100f0a <exec+0x3bb>
    ustack[3+argc] = sp;
80100db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbc:	8d 50 03             	lea    0x3(%eax),%edx
80100dbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc2:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dda:	01 d0                	add    %edx,%eax
80100ddc:	8b 00                	mov    (%eax),%eax
80100dde:	85 c0                	test   %eax,%eax
80100de0:	0f 85 4f ff ff ff    	jne    80100d35 <exec+0x1e6>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	83 c0 03             	add    $0x3,%eax
80100dec:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df3:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df7:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dfe:	ff ff ff 
  ustack[1] = argc;
80100e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e04:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0d:	83 c0 01             	add    $0x1,%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1a:	29 d0                	sub    %edx,%eax
80100e1c:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e25:	83 c0 04             	add    $0x4,%eax
80100e28:	c1 e0 02             	shl    $0x2,%eax
80100e2b:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e31:	83 c0 04             	add    $0x4,%eax
80100e34:	c1 e0 02             	shl    $0x2,%eax
80100e37:	50                   	push   %eax
80100e38:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e3e:	50                   	push   %eax
80100e3f:	ff 75 dc             	pushl  -0x24(%ebp)
80100e42:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e45:	e8 f7 78 00 00       	call   80108741 <copyout>
80100e4a:	83 c4 10             	add    $0x10,%esp
80100e4d:	85 c0                	test   %eax,%eax
80100e4f:	79 05                	jns    80100e56 <exec+0x307>
    goto bad;
80100e51:	e9 b4 00 00 00       	jmp    80100f0a <exec+0x3bb>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e56:	8b 45 08             	mov    0x8(%ebp),%eax
80100e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e62:	eb 17                	jmp    80100e7b <exec+0x32c>
    if(*s == '/')
80100e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e67:	0f b6 00             	movzbl (%eax),%eax
80100e6a:	3c 2f                	cmp    $0x2f,%al
80100e6c:	75 09                	jne    80100e77 <exec+0x328>
      last = s+1;
80100e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e71:	83 c0 01             	add    $0x1,%eax
80100e74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7e:	0f b6 00             	movzbl (%eax),%eax
80100e81:	84 c0                	test   %al,%al
80100e83:	75 df                	jne    80100e64 <exec+0x315>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8b:	83 c0 6c             	add    $0x6c,%eax
80100e8e:	83 ec 04             	sub    $0x4,%esp
80100e91:	6a 10                	push   $0x10
80100e93:	ff 75 f0             	pushl  -0x10(%ebp)
80100e96:	50                   	push   %eax
80100e97:	e8 2b 48 00 00       	call   801056c7 <safestrcpy>
80100e9c:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	8b 40 04             	mov    0x4(%eax),%eax
80100ea8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb4:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ec0:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec8:	8b 40 18             	mov    0x18(%eax),%eax
80100ecb:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ed1:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eda:	8b 40 18             	mov    0x18(%eax),%eax
80100edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ee0:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee9:	83 ec 0c             	sub    $0xc,%esp
80100eec:	50                   	push   %eax
80100eed:	e8 b6 71 00 00       	call   801080a8 <switchuvm>
80100ef2:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ef5:	83 ec 0c             	sub    $0xc,%esp
80100ef8:	ff 75 d0             	pushl  -0x30(%ebp)
80100efb:	e8 ec 75 00 00       	call   801084ec <freevm>
80100f00:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f03:	b8 00 00 00 00       	mov    $0x0,%eax
80100f08:	eb 32                	jmp    80100f3c <exec+0x3ed>

 bad:
  if(pgdir)
80100f0a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f0e:	74 0e                	je     80100f1e <exec+0x3cf>
    freevm(pgdir);
80100f10:	83 ec 0c             	sub    $0xc,%esp
80100f13:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f16:	e8 d1 75 00 00       	call   801084ec <freevm>
80100f1b:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f1e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f22:	74 13                	je     80100f37 <exec+0x3e8>
    iunlockput(ip);
80100f24:	83 ec 0c             	sub    $0xc,%esp
80100f27:	ff 75 d8             	pushl  -0x28(%ebp)
80100f2a:	e8 6f 0c 00 00       	call   80101b9e <iunlockput>
80100f2f:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f32:	e8 eb 26 00 00       	call   80103622 <end_op>
  }
  return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f3c:	c9                   	leave  
80100f3d:	c3                   	ret    

80100f3e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f3e:	55                   	push   %ebp
80100f3f:	89 e5                	mov    %esp,%ebp
80100f41:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f44:	83 ec 08             	sub    $0x8,%esp
80100f47:	68 39 88 10 80       	push   $0x80108839
80100f4c:	68 c0 08 11 80       	push   $0x801108c0
80100f51:	e8 ef 42 00 00       	call   80105245 <initlock>
80100f56:	83 c4 10             	add    $0x10,%esp
}
80100f59:	c9                   	leave  
80100f5a:	c3                   	ret    

80100f5b <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f5b:	55                   	push   %ebp
80100f5c:	89 e5                	mov    %esp,%ebp
80100f5e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f61:	83 ec 0c             	sub    $0xc,%esp
80100f64:	68 c0 08 11 80       	push   $0x801108c0
80100f69:	e8 f8 42 00 00       	call   80105266 <acquire>
80100f6e:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f71:	c7 45 f4 f4 08 11 80 	movl   $0x801108f4,-0xc(%ebp)
80100f78:	eb 2d                	jmp    80100fa7 <filealloc+0x4c>
    if(f->ref == 0){
80100f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7d:	8b 40 04             	mov    0x4(%eax),%eax
80100f80:	85 c0                	test   %eax,%eax
80100f82:	75 1f                	jne    80100fa3 <filealloc+0x48>
      f->ref = 1;
80100f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f87:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f8e:	83 ec 0c             	sub    $0xc,%esp
80100f91:	68 c0 08 11 80       	push   $0x801108c0
80100f96:	e8 31 43 00 00       	call   801052cc <release>
80100f9b:	83 c4 10             	add    $0x10,%esp
      return f;
80100f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa1:	eb 22                	jmp    80100fc5 <filealloc+0x6a>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa3:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fa7:	81 7d f4 54 12 11 80 	cmpl   $0x80111254,-0xc(%ebp)
80100fae:	72 ca                	jb     80100f7a <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fb0:	83 ec 0c             	sub    $0xc,%esp
80100fb3:	68 c0 08 11 80       	push   $0x801108c0
80100fb8:	e8 0f 43 00 00       	call   801052cc <release>
80100fbd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fc5:	c9                   	leave  
80100fc6:	c3                   	ret    

80100fc7 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fc7:	55                   	push   %ebp
80100fc8:	89 e5                	mov    %esp,%ebp
80100fca:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100fcd:	83 ec 0c             	sub    $0xc,%esp
80100fd0:	68 c0 08 11 80       	push   $0x801108c0
80100fd5:	e8 8c 42 00 00       	call   80105266 <acquire>
80100fda:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe0:	8b 40 04             	mov    0x4(%eax),%eax
80100fe3:	85 c0                	test   %eax,%eax
80100fe5:	7f 0d                	jg     80100ff4 <filedup+0x2d>
    panic("filedup");
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	68 40 88 10 80       	push   $0x80108840
80100fef:	e8 68 f5 ff ff       	call   8010055c <panic>
  f->ref++;
80100ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff7:	8b 40 04             	mov    0x4(%eax),%eax
80100ffa:	8d 50 01             	lea    0x1(%eax),%edx
80100ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80101000:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101003:	83 ec 0c             	sub    $0xc,%esp
80101006:	68 c0 08 11 80       	push   $0x801108c0
8010100b:	e8 bc 42 00 00       	call   801052cc <release>
80101010:	83 c4 10             	add    $0x10,%esp
  return f;
80101013:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101016:	c9                   	leave  
80101017:	c3                   	ret    

80101018 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101018:	55                   	push   %ebp
80101019:	89 e5                	mov    %esp,%ebp
8010101b:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010101e:	83 ec 0c             	sub    $0xc,%esp
80101021:	68 c0 08 11 80       	push   $0x801108c0
80101026:	e8 3b 42 00 00       	call   80105266 <acquire>
8010102b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010102e:	8b 45 08             	mov    0x8(%ebp),%eax
80101031:	8b 40 04             	mov    0x4(%eax),%eax
80101034:	85 c0                	test   %eax,%eax
80101036:	7f 0d                	jg     80101045 <fileclose+0x2d>
    panic("fileclose");
80101038:	83 ec 0c             	sub    $0xc,%esp
8010103b:	68 48 88 10 80       	push   $0x80108848
80101040:	e8 17 f5 ff ff       	call   8010055c <panic>
  if(--f->ref > 0){
80101045:	8b 45 08             	mov    0x8(%ebp),%eax
80101048:	8b 40 04             	mov    0x4(%eax),%eax
8010104b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010104e:	8b 45 08             	mov    0x8(%ebp),%eax
80101051:	89 50 04             	mov    %edx,0x4(%eax)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7e 15                	jle    80101073 <fileclose+0x5b>
    release(&ftable.lock);
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 c0 08 11 80       	push   $0x801108c0
80101066:	e8 61 42 00 00       	call   801052cc <release>
8010106b:	83 c4 10             	add    $0x10,%esp
8010106e:	e9 8b 00 00 00       	jmp    801010fe <fileclose+0xe6>
    return;
  }
  ff = *f;
80101073:	8b 45 08             	mov    0x8(%ebp),%eax
80101076:	8b 10                	mov    (%eax),%edx
80101078:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010107b:	8b 50 04             	mov    0x4(%eax),%edx
8010107e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101081:	8b 50 08             	mov    0x8(%eax),%edx
80101084:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101087:	8b 50 0c             	mov    0xc(%eax),%edx
8010108a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010108d:	8b 50 10             	mov    0x10(%eax),%edx
80101090:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101093:	8b 40 14             	mov    0x14(%eax),%eax
80101096:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
8010109c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
801010a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010ac:	83 ec 0c             	sub    $0xc,%esp
801010af:	68 c0 08 11 80       	push   $0x801108c0
801010b4:	e8 13 42 00 00       	call   801052cc <release>
801010b9:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010bf:	83 f8 01             	cmp    $0x1,%eax
801010c2:	75 19                	jne    801010dd <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010c4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010c8:	0f be d0             	movsbl %al,%edx
801010cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010ce:	83 ec 08             	sub    $0x8,%esp
801010d1:	52                   	push   %edx
801010d2:	50                   	push   %eax
801010d3:	e8 01 31 00 00       	call   801041d9 <pipeclose>
801010d8:	83 c4 10             	add    $0x10,%esp
801010db:	eb 21                	jmp    801010fe <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e0:	83 f8 02             	cmp    $0x2,%eax
801010e3:	75 19                	jne    801010fe <fileclose+0xe6>
    begin_op();
801010e5:	e8 aa 24 00 00       	call   80103594 <begin_op>
    iput(ff.ip);
801010ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010ed:	83 ec 0c             	sub    $0xc,%esp
801010f0:	50                   	push   %eax
801010f1:	e8 b9 09 00 00       	call   80101aaf <iput>
801010f6:	83 c4 10             	add    $0x10,%esp
    end_op();
801010f9:	e8 24 25 00 00       	call   80103622 <end_op>
  }
}
801010fe:	c9                   	leave  
801010ff:	c3                   	ret    

80101100 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101100:	55                   	push   %ebp
80101101:	89 e5                	mov    %esp,%ebp
80101103:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101106:	8b 45 08             	mov    0x8(%ebp),%eax
80101109:	8b 00                	mov    (%eax),%eax
8010110b:	83 f8 02             	cmp    $0x2,%eax
8010110e:	75 40                	jne    80101150 <filestat+0x50>
    ilock(f->ip);
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
80101113:	8b 40 10             	mov    0x10(%eax),%eax
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	50                   	push   %eax
8010111a:	e8 c8 07 00 00       	call   801018e7 <ilock>
8010111f:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101122:	8b 45 08             	mov    0x8(%ebp),%eax
80101125:	8b 40 10             	mov    0x10(%eax),%eax
80101128:	83 ec 08             	sub    $0x8,%esp
8010112b:	ff 75 0c             	pushl  0xc(%ebp)
8010112e:	50                   	push   %eax
8010112f:	e8 d0 0c 00 00       	call   80101e04 <stati>
80101134:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 40 10             	mov    0x10(%eax),%eax
8010113d:	83 ec 0c             	sub    $0xc,%esp
80101140:	50                   	push   %eax
80101141:	e8 f8 08 00 00       	call   80101a3e <iunlock>
80101146:	83 c4 10             	add    $0x10,%esp
    return 0;
80101149:	b8 00 00 00 00       	mov    $0x0,%eax
8010114e:	eb 05                	jmp    80101155 <filestat+0x55>
  }
  return -1;
80101150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101155:	c9                   	leave  
80101156:	c3                   	ret    

80101157 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101157:	55                   	push   %ebp
80101158:	89 e5                	mov    %esp,%ebp
8010115a:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101164:	84 c0                	test   %al,%al
80101166:	75 0a                	jne    80101172 <fileread+0x1b>
    return -1;
80101168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010116d:	e9 9b 00 00 00       	jmp    8010120d <fileread+0xb6>
  if(f->type == FD_PIPE)
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 00                	mov    (%eax),%eax
80101177:	83 f8 01             	cmp    $0x1,%eax
8010117a:	75 1a                	jne    80101196 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 40 0c             	mov    0xc(%eax),%eax
80101182:	83 ec 04             	sub    $0x4,%esp
80101185:	ff 75 10             	pushl  0x10(%ebp)
80101188:	ff 75 0c             	pushl  0xc(%ebp)
8010118b:	50                   	push   %eax
8010118c:	e8 f5 31 00 00       	call   80104386 <piperead>
80101191:	83 c4 10             	add    $0x10,%esp
80101194:	eb 77                	jmp    8010120d <fileread+0xb6>
  if(f->type == FD_INODE){
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	8b 00                	mov    (%eax),%eax
8010119b:	83 f8 02             	cmp    $0x2,%eax
8010119e:	75 60                	jne    80101200 <fileread+0xa9>
    ilock(f->ip);
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 40 10             	mov    0x10(%eax),%eax
801011a6:	83 ec 0c             	sub    $0xc,%esp
801011a9:	50                   	push   %eax
801011aa:	e8 38 07 00 00       	call   801018e7 <ilock>
801011af:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 50 14             	mov    0x14(%eax),%edx
801011bb:	8b 45 08             	mov    0x8(%ebp),%eax
801011be:	8b 40 10             	mov    0x10(%eax),%eax
801011c1:	51                   	push   %ecx
801011c2:	52                   	push   %edx
801011c3:	ff 75 0c             	pushl  0xc(%ebp)
801011c6:	50                   	push   %eax
801011c7:	e8 7d 0c 00 00       	call   80101e49 <readi>
801011cc:	83 c4 10             	add    $0x10,%esp
801011cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011d6:	7e 11                	jle    801011e9 <fileread+0x92>
      f->off += r;
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 50 14             	mov    0x14(%eax),%edx
801011de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011e1:	01 c2                	add    %eax,%edx
801011e3:	8b 45 08             	mov    0x8(%ebp),%eax
801011e6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 46 08 00 00       	call   80101a3e <iunlock>
801011f8:	83 c4 10             	add    $0x10,%esp
    return r;
801011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011fe:	eb 0d                	jmp    8010120d <fileread+0xb6>
  }
  panic("fileread");
80101200:	83 ec 0c             	sub    $0xc,%esp
80101203:	68 52 88 10 80       	push   $0x80108852
80101208:	e8 4f f3 ff ff       	call   8010055c <panic>
}
8010120d:	c9                   	leave  
8010120e:	c3                   	ret    

8010120f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010120f:	55                   	push   %ebp
80101210:	89 e5                	mov    %esp,%ebp
80101212:	53                   	push   %ebx
80101213:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101216:	8b 45 08             	mov    0x8(%ebp),%eax
80101219:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010121d:	84 c0                	test   %al,%al
8010121f:	75 0a                	jne    8010122b <filewrite+0x1c>
    return -1;
80101221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101226:	e9 1a 01 00 00       	jmp    80101345 <filewrite+0x136>
  if(f->type == FD_PIPE)
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	8b 00                	mov    (%eax),%eax
80101230:	83 f8 01             	cmp    $0x1,%eax
80101233:	75 1d                	jne    80101252 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 40 0c             	mov    0xc(%eax),%eax
8010123b:	83 ec 04             	sub    $0x4,%esp
8010123e:	ff 75 10             	pushl  0x10(%ebp)
80101241:	ff 75 0c             	pushl  0xc(%ebp)
80101244:	50                   	push   %eax
80101245:	e8 38 30 00 00       	call   80104282 <pipewrite>
8010124a:	83 c4 10             	add    $0x10,%esp
8010124d:	e9 f3 00 00 00       	jmp    80101345 <filewrite+0x136>
  if(f->type == FD_INODE){
80101252:	8b 45 08             	mov    0x8(%ebp),%eax
80101255:	8b 00                	mov    (%eax),%eax
80101257:	83 f8 02             	cmp    $0x2,%eax
8010125a:	0f 85 d8 00 00 00    	jne    80101338 <filewrite+0x129>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101260:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010126e:	e9 a5 00 00 00       	jmp    80101318 <filewrite+0x109>
      int n1 = n - i;
80101273:	8b 45 10             	mov    0x10(%ebp),%eax
80101276:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101279:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010127c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010127f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101282:	7e 06                	jle    8010128a <filewrite+0x7b>
        n1 = max;
80101284:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101287:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010128a:	e8 05 23 00 00       	call   80103594 <begin_op>
      ilock(f->ip);
8010128f:	8b 45 08             	mov    0x8(%ebp),%eax
80101292:	8b 40 10             	mov    0x10(%eax),%eax
80101295:	83 ec 0c             	sub    $0xc,%esp
80101298:	50                   	push   %eax
80101299:	e8 49 06 00 00       	call   801018e7 <ilock>
8010129e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012a4:	8b 45 08             	mov    0x8(%ebp),%eax
801012a7:	8b 50 14             	mov    0x14(%eax),%edx
801012aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801012b0:	01 c3                	add    %eax,%ebx
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 10             	mov    0x10(%eax),%eax
801012b8:	51                   	push   %ecx
801012b9:	52                   	push   %edx
801012ba:	53                   	push   %ebx
801012bb:	50                   	push   %eax
801012bc:	e8 eb 0c 00 00       	call   80101fac <writei>
801012c1:	83 c4 10             	add    $0x10,%esp
801012c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012cb:	7e 11                	jle    801012de <filewrite+0xcf>
        f->off += r;
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	8b 50 14             	mov    0x14(%eax),%edx
801012d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d6:	01 c2                	add    %eax,%edx
801012d8:	8b 45 08             	mov    0x8(%ebp),%eax
801012db:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012de:	8b 45 08             	mov    0x8(%ebp),%eax
801012e1:	8b 40 10             	mov    0x10(%eax),%eax
801012e4:	83 ec 0c             	sub    $0xc,%esp
801012e7:	50                   	push   %eax
801012e8:	e8 51 07 00 00       	call   80101a3e <iunlock>
801012ed:	83 c4 10             	add    $0x10,%esp
      end_op();
801012f0:	e8 2d 23 00 00       	call   80103622 <end_op>

      if(r < 0)
801012f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012f9:	79 02                	jns    801012fd <filewrite+0xee>
        break;
801012fb:	eb 27                	jmp    80101324 <filewrite+0x115>
      if(r != n1)
801012fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101300:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101303:	74 0d                	je     80101312 <filewrite+0x103>
        panic("short filewrite");
80101305:	83 ec 0c             	sub    $0xc,%esp
80101308:	68 5b 88 10 80       	push   $0x8010885b
8010130d:	e8 4a f2 ff ff       	call   8010055c <panic>
      i += r;
80101312:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101315:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010131e:	0f 8c 4f ff ff ff    	jl     80101273 <filewrite+0x64>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101327:	3b 45 10             	cmp    0x10(%ebp),%eax
8010132a:	75 05                	jne    80101331 <filewrite+0x122>
8010132c:	8b 45 10             	mov    0x10(%ebp),%eax
8010132f:	eb 14                	jmp    80101345 <filewrite+0x136>
80101331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101336:	eb 0d                	jmp    80101345 <filewrite+0x136>
  }
  panic("filewrite");
80101338:	83 ec 0c             	sub    $0xc,%esp
8010133b:	68 6b 88 10 80       	push   $0x8010886b
80101340:	e8 17 f2 ff ff       	call   8010055c <panic>
}
80101345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101348:	c9                   	leave  
80101349:	c3                   	ret    

8010134a <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010134a:	55                   	push   %ebp
8010134b:	89 e5                	mov    %esp,%ebp
8010134d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	83 ec 08             	sub    $0x8,%esp
80101356:	6a 01                	push   $0x1
80101358:	50                   	push   %eax
80101359:	e8 56 ee ff ff       	call   801001b4 <bread>
8010135e:	83 c4 10             	add    $0x10,%esp
80101361:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101367:	83 c0 18             	add    $0x18,%eax
8010136a:	83 ec 04             	sub    $0x4,%esp
8010136d:	6a 10                	push   $0x10
8010136f:	50                   	push   %eax
80101370:	ff 75 0c             	pushl  0xc(%ebp)
80101373:	e8 09 42 00 00       	call   80105581 <memmove>
80101378:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010137b:	83 ec 0c             	sub    $0xc,%esp
8010137e:	ff 75 f4             	pushl  -0xc(%ebp)
80101381:	e8 a5 ee ff ff       	call   8010022b <brelse>
80101386:	83 c4 10             	add    $0x10,%esp
}
80101389:	c9                   	leave  
8010138a:	c3                   	ret    

8010138b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010138b:	55                   	push   %ebp
8010138c:	89 e5                	mov    %esp,%ebp
8010138e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101391:	8b 55 0c             	mov    0xc(%ebp),%edx
80101394:	8b 45 08             	mov    0x8(%ebp),%eax
80101397:	83 ec 08             	sub    $0x8,%esp
8010139a:	52                   	push   %edx
8010139b:	50                   	push   %eax
8010139c:	e8 13 ee ff ff       	call   801001b4 <bread>
801013a1:	83 c4 10             	add    $0x10,%esp
801013a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013aa:	83 c0 18             	add    $0x18,%eax
801013ad:	83 ec 04             	sub    $0x4,%esp
801013b0:	68 00 02 00 00       	push   $0x200
801013b5:	6a 00                	push   $0x0
801013b7:	50                   	push   %eax
801013b8:	e8 05 41 00 00       	call   801054c2 <memset>
801013bd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013c0:	83 ec 0c             	sub    $0xc,%esp
801013c3:	ff 75 f4             	pushl  -0xc(%ebp)
801013c6:	e8 00 24 00 00       	call   801037cb <log_write>
801013cb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ce:	83 ec 0c             	sub    $0xc,%esp
801013d1:	ff 75 f4             	pushl  -0xc(%ebp)
801013d4:	e8 52 ee ff ff       	call   8010022b <brelse>
801013d9:	83 c4 10             	add    $0x10,%esp
}
801013dc:	c9                   	leave  
801013dd:	c3                   	ret    

801013de <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013de:	55                   	push   %ebp
801013df:	89 e5                	mov    %esp,%ebp
801013e1:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013eb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ee:	83 ec 08             	sub    $0x8,%esp
801013f1:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013f4:	52                   	push   %edx
801013f5:	50                   	push   %eax
801013f6:	e8 4f ff ff ff       	call   8010134a <readsb>
801013fb:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801013fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101405:	e9 15 01 00 00       	jmp    8010151f <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101413:	85 c0                	test   %eax,%eax
80101415:	0f 48 c2             	cmovs  %edx,%eax
80101418:	c1 f8 0c             	sar    $0xc,%eax
8010141b:	89 c2                	mov    %eax,%edx
8010141d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101420:	c1 e8 03             	shr    $0x3,%eax
80101423:	01 d0                	add    %edx,%eax
80101425:	83 c0 03             	add    $0x3,%eax
80101428:	83 ec 08             	sub    $0x8,%esp
8010142b:	50                   	push   %eax
8010142c:	ff 75 08             	pushl  0x8(%ebp)
8010142f:	e8 80 ed ff ff       	call   801001b4 <bread>
80101434:	83 c4 10             	add    $0x10,%esp
80101437:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010143a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101441:	e9 a6 00 00 00       	jmp    801014ec <balloc+0x10e>
      m = 1 << (bi % 8);
80101446:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101449:	99                   	cltd   
8010144a:	c1 ea 1d             	shr    $0x1d,%edx
8010144d:	01 d0                	add    %edx,%eax
8010144f:	83 e0 07             	and    $0x7,%eax
80101452:	29 d0                	sub    %edx,%eax
80101454:	ba 01 00 00 00       	mov    $0x1,%edx
80101459:	89 c1                	mov    %eax,%ecx
8010145b:	d3 e2                	shl    %cl,%edx
8010145d:	89 d0                	mov    %edx,%eax
8010145f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101465:	8d 50 07             	lea    0x7(%eax),%edx
80101468:	85 c0                	test   %eax,%eax
8010146a:	0f 48 c2             	cmovs  %edx,%eax
8010146d:	c1 f8 03             	sar    $0x3,%eax
80101470:	89 c2                	mov    %eax,%edx
80101472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101475:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010147a:	0f b6 c0             	movzbl %al,%eax
8010147d:	23 45 e8             	and    -0x18(%ebp),%eax
80101480:	85 c0                	test   %eax,%eax
80101482:	75 64                	jne    801014e8 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101487:	8d 50 07             	lea    0x7(%eax),%edx
8010148a:	85 c0                	test   %eax,%eax
8010148c:	0f 48 c2             	cmovs  %edx,%eax
8010148f:	c1 f8 03             	sar    $0x3,%eax
80101492:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101495:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010149a:	89 d1                	mov    %edx,%ecx
8010149c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010149f:	09 ca                	or     %ecx,%edx
801014a1:	89 d1                	mov    %edx,%ecx
801014a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014a6:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014aa:	83 ec 0c             	sub    $0xc,%esp
801014ad:	ff 75 ec             	pushl  -0x14(%ebp)
801014b0:	e8 16 23 00 00       	call   801037cb <log_write>
801014b5:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014b8:	83 ec 0c             	sub    $0xc,%esp
801014bb:	ff 75 ec             	pushl  -0x14(%ebp)
801014be:	e8 68 ed ff ff       	call   8010022b <brelse>
801014c3:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	01 c2                	add    %eax,%edx
801014ce:	8b 45 08             	mov    0x8(%ebp),%eax
801014d1:	83 ec 08             	sub    $0x8,%esp
801014d4:	52                   	push   %edx
801014d5:	50                   	push   %eax
801014d6:	e8 b0 fe ff ff       	call   8010138b <bzero>
801014db:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e4:	01 d0                	add    %edx,%eax
801014e6:	eb 52                	jmp    8010153a <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014ec:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014f3:	7f 15                	jg     8010150a <balloc+0x12c>
801014f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	01 d0                	add    %edx,%eax
801014fd:	89 c2                	mov    %eax,%edx
801014ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101502:	39 c2                	cmp    %eax,%edx
80101504:	0f 82 3c ff ff ff    	jb     80101446 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010150a:	83 ec 0c             	sub    $0xc,%esp
8010150d:	ff 75 ec             	pushl  -0x14(%ebp)
80101510:	e8 16 ed ff ff       	call   8010022b <brelse>
80101515:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101518:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010151f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101522:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101525:	39 c2                	cmp    %eax,%edx
80101527:	0f 82 dd fe ff ff    	jb     8010140a <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010152d:	83 ec 0c             	sub    $0xc,%esp
80101530:	68 75 88 10 80       	push   $0x80108875
80101535:	e8 22 f0 ff ff       	call   8010055c <panic>
}
8010153a:	c9                   	leave  
8010153b:	c3                   	ret    

8010153c <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010153c:	55                   	push   %ebp
8010153d:	89 e5                	mov    %esp,%ebp
8010153f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101548:	50                   	push   %eax
80101549:	ff 75 08             	pushl  0x8(%ebp)
8010154c:	e8 f9 fd ff ff       	call   8010134a <readsb>
80101551:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101554:	8b 45 0c             	mov    0xc(%ebp),%eax
80101557:	c1 e8 0c             	shr    $0xc,%eax
8010155a:	89 c2                	mov    %eax,%edx
8010155c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010155f:	c1 e8 03             	shr    $0x3,%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	8d 50 03             	lea    0x3(%eax),%edx
80101567:	8b 45 08             	mov    0x8(%ebp),%eax
8010156a:	83 ec 08             	sub    $0x8,%esp
8010156d:	52                   	push   %edx
8010156e:	50                   	push   %eax
8010156f:	e8 40 ec ff ff       	call   801001b4 <bread>
80101574:	83 c4 10             	add    $0x10,%esp
80101577:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010157a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010157d:	25 ff 0f 00 00       	and    $0xfff,%eax
80101582:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101588:	99                   	cltd   
80101589:	c1 ea 1d             	shr    $0x1d,%edx
8010158c:	01 d0                	add    %edx,%eax
8010158e:	83 e0 07             	and    $0x7,%eax
80101591:	29 d0                	sub    %edx,%eax
80101593:	ba 01 00 00 00       	mov    $0x1,%edx
80101598:	89 c1                	mov    %eax,%ecx
8010159a:	d3 e2                	shl    %cl,%edx
8010159c:	89 d0                	mov    %edx,%eax
8010159e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a4:	8d 50 07             	lea    0x7(%eax),%edx
801015a7:	85 c0                	test   %eax,%eax
801015a9:	0f 48 c2             	cmovs  %edx,%eax
801015ac:	c1 f8 03             	sar    $0x3,%eax
801015af:	89 c2                	mov    %eax,%edx
801015b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b4:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015b9:	0f b6 c0             	movzbl %al,%eax
801015bc:	23 45 ec             	and    -0x14(%ebp),%eax
801015bf:	85 c0                	test   %eax,%eax
801015c1:	75 0d                	jne    801015d0 <bfree+0x94>
    panic("freeing free block");
801015c3:	83 ec 0c             	sub    $0xc,%esp
801015c6:	68 8b 88 10 80       	push   $0x8010888b
801015cb:	e8 8c ef ff ff       	call   8010055c <panic>
  bp->data[bi/8] &= ~m;
801015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d3:	8d 50 07             	lea    0x7(%eax),%edx
801015d6:	85 c0                	test   %eax,%eax
801015d8:	0f 48 c2             	cmovs  %edx,%eax
801015db:	c1 f8 03             	sar    $0x3,%eax
801015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e1:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015e6:	89 d1                	mov    %edx,%ecx
801015e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015eb:	f7 d2                	not    %edx
801015ed:	21 ca                	and    %ecx,%edx
801015ef:	89 d1                	mov    %edx,%ecx
801015f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f4:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015f8:	83 ec 0c             	sub    $0xc,%esp
801015fb:	ff 75 f4             	pushl  -0xc(%ebp)
801015fe:	e8 c8 21 00 00       	call   801037cb <log_write>
80101603:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101606:	83 ec 0c             	sub    $0xc,%esp
80101609:	ff 75 f4             	pushl  -0xc(%ebp)
8010160c:	e8 1a ec ff ff       	call   8010022b <brelse>
80101611:	83 c4 10             	add    $0x10,%esp
}
80101614:	c9                   	leave  
80101615:	c3                   	ret    

80101616 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101616:	55                   	push   %ebp
80101617:	89 e5                	mov    %esp,%ebp
80101619:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010161c:	83 ec 08             	sub    $0x8,%esp
8010161f:	68 9e 88 10 80       	push   $0x8010889e
80101624:	68 40 13 11 80       	push   $0x80111340
80101629:	e8 17 3c 00 00       	call   80105245 <initlock>
8010162e:	83 c4 10             	add    $0x10,%esp
}
80101631:	c9                   	leave  
80101632:	c3                   	ret    

80101633 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101633:	55                   	push   %ebp
80101634:	89 e5                	mov    %esp,%ebp
80101636:	83 ec 38             	sub    $0x38,%esp
80101639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163c:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101640:	8b 45 08             	mov    0x8(%ebp),%eax
80101643:	83 ec 08             	sub    $0x8,%esp
80101646:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101649:	52                   	push   %edx
8010164a:	50                   	push   %eax
8010164b:	e8 fa fc ff ff       	call   8010134a <readsb>
80101650:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101653:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010165a:	e9 98 00 00 00       	jmp    801016f7 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
8010165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101662:	c1 e8 03             	shr    $0x3,%eax
80101665:	83 c0 02             	add    $0x2,%eax
80101668:	83 ec 08             	sub    $0x8,%esp
8010166b:	50                   	push   %eax
8010166c:	ff 75 08             	pushl  0x8(%ebp)
8010166f:	e8 40 eb ff ff       	call   801001b4 <bread>
80101674:	83 c4 10             	add    $0x10,%esp
80101677:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167d:	8d 50 18             	lea    0x18(%eax),%edx
80101680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101683:	83 e0 07             	and    $0x7,%eax
80101686:	c1 e0 06             	shl    $0x6,%eax
80101689:	01 d0                	add    %edx,%eax
8010168b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010168e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101691:	0f b7 00             	movzwl (%eax),%eax
80101694:	66 85 c0             	test   %ax,%ax
80101697:	75 4c                	jne    801016e5 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
80101699:	83 ec 04             	sub    $0x4,%esp
8010169c:	6a 40                	push   $0x40
8010169e:	6a 00                	push   $0x0
801016a0:	ff 75 ec             	pushl  -0x14(%ebp)
801016a3:	e8 1a 3e 00 00       	call   801054c2 <memset>
801016a8:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016ae:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016b2:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016b5:	83 ec 0c             	sub    $0xc,%esp
801016b8:	ff 75 f0             	pushl  -0x10(%ebp)
801016bb:	e8 0b 21 00 00       	call   801037cb <log_write>
801016c0:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016c3:	83 ec 0c             	sub    $0xc,%esp
801016c6:	ff 75 f0             	pushl  -0x10(%ebp)
801016c9:	e8 5d eb ff ff       	call   8010022b <brelse>
801016ce:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d4:	83 ec 08             	sub    $0x8,%esp
801016d7:	50                   	push   %eax
801016d8:	ff 75 08             	pushl  0x8(%ebp)
801016db:	e8 ee 00 00 00       	call   801017ce <iget>
801016e0:	83 c4 10             	add    $0x10,%esp
801016e3:	eb 2d                	jmp    80101712 <ialloc+0xdf>
    }
    brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f0             	pushl  -0x10(%ebp)
801016eb:	e8 3b eb ff ff       	call   8010022b <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016fd:	39 c2                	cmp    %eax,%edx
801016ff:	0f 82 5a ff ff ff    	jb     8010165f <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101705:	83 ec 0c             	sub    $0xc,%esp
80101708:	68 a5 88 10 80       	push   $0x801088a5
8010170d:	e8 4a ee ff ff       	call   8010055c <panic>
}
80101712:	c9                   	leave  
80101713:	c3                   	ret    

80101714 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101714:	55                   	push   %ebp
80101715:	89 e5                	mov    %esp,%ebp
80101717:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010171a:	8b 45 08             	mov    0x8(%ebp),%eax
8010171d:	8b 40 04             	mov    0x4(%eax),%eax
80101720:	c1 e8 03             	shr    $0x3,%eax
80101723:	8d 50 02             	lea    0x2(%eax),%edx
80101726:	8b 45 08             	mov    0x8(%ebp),%eax
80101729:	8b 00                	mov    (%eax),%eax
8010172b:	83 ec 08             	sub    $0x8,%esp
8010172e:	52                   	push   %edx
8010172f:	50                   	push   %eax
80101730:	e8 7f ea ff ff       	call   801001b4 <bread>
80101735:	83 c4 10             	add    $0x10,%esp
80101738:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173e:	8d 50 18             	lea    0x18(%eax),%edx
80101741:	8b 45 08             	mov    0x8(%ebp),%eax
80101744:	8b 40 04             	mov    0x4(%eax),%eax
80101747:	83 e0 07             	and    $0x7,%eax
8010174a:	c1 e0 06             	shl    $0x6,%eax
8010174d:	01 d0                	add    %edx,%eax
8010174f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101752:	8b 45 08             	mov    0x8(%ebp),%eax
80101755:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101759:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010175f:	8b 45 08             	mov    0x8(%ebp),%eax
80101762:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101769:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010176d:	8b 45 08             	mov    0x8(%ebp),%eax
80101770:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101777:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010177b:	8b 45 08             	mov    0x8(%ebp),%eax
8010177e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101785:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101789:	8b 45 08             	mov    0x8(%ebp),%eax
8010178c:	8b 50 18             	mov    0x18(%eax),%edx
8010178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101792:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101795:	8b 45 08             	mov    0x8(%ebp),%eax
80101798:	8d 50 1c             	lea    0x1c(%eax),%edx
8010179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179e:	83 c0 0c             	add    $0xc,%eax
801017a1:	83 ec 04             	sub    $0x4,%esp
801017a4:	6a 34                	push   $0x34
801017a6:	52                   	push   %edx
801017a7:	50                   	push   %eax
801017a8:	e8 d4 3d 00 00       	call   80105581 <memmove>
801017ad:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017b0:	83 ec 0c             	sub    $0xc,%esp
801017b3:	ff 75 f4             	pushl  -0xc(%ebp)
801017b6:	e8 10 20 00 00       	call   801037cb <log_write>
801017bb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017be:	83 ec 0c             	sub    $0xc,%esp
801017c1:	ff 75 f4             	pushl  -0xc(%ebp)
801017c4:	e8 62 ea ff ff       	call   8010022b <brelse>
801017c9:	83 c4 10             	add    $0x10,%esp
}
801017cc:	c9                   	leave  
801017cd:	c3                   	ret    

801017ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017ce:	55                   	push   %ebp
801017cf:	89 e5                	mov    %esp,%ebp
801017d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017d4:	83 ec 0c             	sub    $0xc,%esp
801017d7:	68 40 13 11 80       	push   $0x80111340
801017dc:	e8 85 3a 00 00       	call   80105266 <acquire>
801017e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801017e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017eb:	c7 45 f4 74 13 11 80 	movl   $0x80111374,-0xc(%ebp)
801017f2:	eb 5d                	jmp    80101851 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	8b 40 08             	mov    0x8(%eax),%eax
801017fa:	85 c0                	test   %eax,%eax
801017fc:	7e 39                	jle    80101837 <iget+0x69>
801017fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101801:	8b 00                	mov    (%eax),%eax
80101803:	3b 45 08             	cmp    0x8(%ebp),%eax
80101806:	75 2f                	jne    80101837 <iget+0x69>
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 40 04             	mov    0x4(%eax),%eax
8010180e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101811:	75 24                	jne    80101837 <iget+0x69>
      ip->ref++;
80101813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101816:	8b 40 08             	mov    0x8(%eax),%eax
80101819:	8d 50 01             	lea    0x1(%eax),%edx
8010181c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101822:	83 ec 0c             	sub    $0xc,%esp
80101825:	68 40 13 11 80       	push   $0x80111340
8010182a:	e8 9d 3a 00 00       	call   801052cc <release>
8010182f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101835:	eb 74                	jmp    801018ab <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101837:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010183b:	75 10                	jne    8010184d <iget+0x7f>
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101840:	8b 40 08             	mov    0x8(%eax),%eax
80101843:	85 c0                	test   %eax,%eax
80101845:	75 06                	jne    8010184d <iget+0x7f>
      empty = ip;
80101847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010184d:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101851:	81 7d f4 14 23 11 80 	cmpl   $0x80112314,-0xc(%ebp)
80101858:	72 9a                	jb     801017f4 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010185a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010185e:	75 0d                	jne    8010186d <iget+0x9f>
    panic("iget: no inodes");
80101860:	83 ec 0c             	sub    $0xc,%esp
80101863:	68 b7 88 10 80       	push   $0x801088b7
80101868:	e8 ef ec ff ff       	call   8010055c <panic>

  ip = empty;
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	8b 55 08             	mov    0x8(%ebp),%edx
80101879:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101881:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101887:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010188e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101891:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101898:	83 ec 0c             	sub    $0xc,%esp
8010189b:	68 40 13 11 80       	push   $0x80111340
801018a0:	e8 27 3a 00 00       	call   801052cc <release>
801018a5:	83 c4 10             	add    $0x10,%esp

  return ip;
801018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018ab:	c9                   	leave  
801018ac:	c3                   	ret    

801018ad <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018ad:	55                   	push   %ebp
801018ae:	89 e5                	mov    %esp,%ebp
801018b0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018b3:	83 ec 0c             	sub    $0xc,%esp
801018b6:	68 40 13 11 80       	push   $0x80111340
801018bb:	e8 a6 39 00 00       	call   80105266 <acquire>
801018c0:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	8b 40 08             	mov    0x8(%eax),%eax
801018c9:	8d 50 01             	lea    0x1(%eax),%edx
801018cc:	8b 45 08             	mov    0x8(%ebp),%eax
801018cf:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018d2:	83 ec 0c             	sub    $0xc,%esp
801018d5:	68 40 13 11 80       	push   $0x80111340
801018da:	e8 ed 39 00 00       	call   801052cc <release>
801018df:	83 c4 10             	add    $0x10,%esp
  return ip;
801018e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018e5:	c9                   	leave  
801018e6:	c3                   	ret    

801018e7 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018e7:	55                   	push   %ebp
801018e8:	89 e5                	mov    %esp,%ebp
801018ea:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018f1:	74 0a                	je     801018fd <ilock+0x16>
801018f3:	8b 45 08             	mov    0x8(%ebp),%eax
801018f6:	8b 40 08             	mov    0x8(%eax),%eax
801018f9:	85 c0                	test   %eax,%eax
801018fb:	7f 0d                	jg     8010190a <ilock+0x23>
    panic("ilock");
801018fd:	83 ec 0c             	sub    $0xc,%esp
80101900:	68 c7 88 10 80       	push   $0x801088c7
80101905:	e8 52 ec ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
8010190a:	83 ec 0c             	sub    $0xc,%esp
8010190d:	68 40 13 11 80       	push   $0x80111340
80101912:	e8 4f 39 00 00       	call   80105266 <acquire>
80101917:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010191a:	eb 13                	jmp    8010192f <ilock+0x48>
    sleep(ip, &icache.lock);
8010191c:	83 ec 08             	sub    $0x8,%esp
8010191f:	68 40 13 11 80       	push   $0x80111340
80101924:	ff 75 08             	pushl  0x8(%ebp)
80101927:	e8 06 34 00 00       	call   80104d32 <sleep>
8010192c:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	8b 40 0c             	mov    0xc(%eax),%eax
80101935:	83 e0 01             	and    $0x1,%eax
80101938:	85 c0                	test   %eax,%eax
8010193a:	75 e0                	jne    8010191c <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010193c:	8b 45 08             	mov    0x8(%ebp),%eax
8010193f:	8b 40 0c             	mov    0xc(%eax),%eax
80101942:	83 c8 01             	or     $0x1,%eax
80101945:	89 c2                	mov    %eax,%edx
80101947:	8b 45 08             	mov    0x8(%ebp),%eax
8010194a:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
8010194d:	83 ec 0c             	sub    $0xc,%esp
80101950:	68 40 13 11 80       	push   $0x80111340
80101955:	e8 72 39 00 00       	call   801052cc <release>
8010195a:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	8b 40 0c             	mov    0xc(%eax),%eax
80101963:	83 e0 02             	and    $0x2,%eax
80101966:	85 c0                	test   %eax,%eax
80101968:	0f 85 ce 00 00 00    	jne    80101a3c <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	8b 40 04             	mov    0x4(%eax),%eax
80101974:	c1 e8 03             	shr    $0x3,%eax
80101977:	8d 50 02             	lea    0x2(%eax),%edx
8010197a:	8b 45 08             	mov    0x8(%ebp),%eax
8010197d:	8b 00                	mov    (%eax),%eax
8010197f:	83 ec 08             	sub    $0x8,%esp
80101982:	52                   	push   %edx
80101983:	50                   	push   %eax
80101984:	e8 2b e8 ff ff       	call   801001b4 <bread>
80101989:	83 c4 10             	add    $0x10,%esp
8010198c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	8d 50 18             	lea    0x18(%eax),%edx
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	8b 40 04             	mov    0x4(%eax),%eax
8010199b:	83 e0 07             	and    $0x7,%eax
8010199e:	c1 e0 06             	shl    $0x6,%eax
801019a1:	01 d0                	add    %edx,%eax
801019a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a9:	0f b7 10             	movzwl (%eax),%edx
801019ac:	8b 45 08             	mov    0x8(%ebp),%eax
801019af:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b6:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c4:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019c8:	8b 45 08             	mov    0x8(%ebp),%eax
801019cb:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d2:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019d6:	8b 45 08             	mov    0x8(%ebp),%eax
801019d9:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e0:	8b 50 08             	mov    0x8(%eax),%edx
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ec:	8d 50 0c             	lea    0xc(%eax),%edx
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	83 c0 1c             	add    $0x1c,%eax
801019f5:	83 ec 04             	sub    $0x4,%esp
801019f8:	6a 34                	push   $0x34
801019fa:	52                   	push   %edx
801019fb:	50                   	push   %eax
801019fc:	e8 80 3b 00 00       	call   80105581 <memmove>
80101a01:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a04:	83 ec 0c             	sub    $0xc,%esp
80101a07:	ff 75 f4             	pushl  -0xc(%ebp)
80101a0a:	e8 1c e8 ff ff       	call   8010022b <brelse>
80101a0f:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	8b 40 0c             	mov    0xc(%eax),%eax
80101a18:	83 c8 02             	or     $0x2,%eax
80101a1b:	89 c2                	mov    %eax,%edx
80101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a20:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a23:	8b 45 08             	mov    0x8(%ebp),%eax
80101a26:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a2a:	66 85 c0             	test   %ax,%ax
80101a2d:	75 0d                	jne    80101a3c <ilock+0x155>
      panic("ilock: no type");
80101a2f:	83 ec 0c             	sub    $0xc,%esp
80101a32:	68 cd 88 10 80       	push   $0x801088cd
80101a37:	e8 20 eb ff ff       	call   8010055c <panic>
  }
}
80101a3c:	c9                   	leave  
80101a3d:	c3                   	ret    

80101a3e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a3e:	55                   	push   %ebp
80101a3f:	89 e5                	mov    %esp,%ebp
80101a41:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a44:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a48:	74 17                	je     80101a61 <iunlock+0x23>
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a50:	83 e0 01             	and    $0x1,%eax
80101a53:	85 c0                	test   %eax,%eax
80101a55:	74 0a                	je     80101a61 <iunlock+0x23>
80101a57:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5a:	8b 40 08             	mov    0x8(%eax),%eax
80101a5d:	85 c0                	test   %eax,%eax
80101a5f:	7f 0d                	jg     80101a6e <iunlock+0x30>
    panic("iunlock");
80101a61:	83 ec 0c             	sub    $0xc,%esp
80101a64:	68 dc 88 10 80       	push   $0x801088dc
80101a69:	e8 ee ea ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
80101a6e:	83 ec 0c             	sub    $0xc,%esp
80101a71:	68 40 13 11 80       	push   $0x80111340
80101a76:	e8 eb 37 00 00       	call   80105266 <acquire>
80101a7b:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	83 e0 fe             	and    $0xfffffffe,%eax
80101a87:	89 c2                	mov    %eax,%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a8f:	83 ec 0c             	sub    $0xc,%esp
80101a92:	ff 75 08             	pushl  0x8(%ebp)
80101a95:	e8 81 33 00 00       	call   80104e1b <wakeup>
80101a9a:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101a9d:	83 ec 0c             	sub    $0xc,%esp
80101aa0:	68 40 13 11 80       	push   $0x80111340
80101aa5:	e8 22 38 00 00       	call   801052cc <release>
80101aaa:	83 c4 10             	add    $0x10,%esp
}
80101aad:	c9                   	leave  
80101aae:	c3                   	ret    

80101aaf <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101aaf:	55                   	push   %ebp
80101ab0:	89 e5                	mov    %esp,%ebp
80101ab2:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ab5:	83 ec 0c             	sub    $0xc,%esp
80101ab8:	68 40 13 11 80       	push   $0x80111340
80101abd:	e8 a4 37 00 00       	call   80105266 <acquire>
80101ac2:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	8b 40 08             	mov    0x8(%eax),%eax
80101acb:	83 f8 01             	cmp    $0x1,%eax
80101ace:	0f 85 a9 00 00 00    	jne    80101b7d <iput+0xce>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	8b 40 0c             	mov    0xc(%eax),%eax
80101ada:	83 e0 02             	and    $0x2,%eax
80101add:	85 c0                	test   %eax,%eax
80101adf:	0f 84 98 00 00 00    	je     80101b7d <iput+0xce>
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101aec:	66 85 c0             	test   %ax,%ax
80101aef:	0f 85 88 00 00 00    	jne    80101b7d <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	8b 40 0c             	mov    0xc(%eax),%eax
80101afb:	83 e0 01             	and    $0x1,%eax
80101afe:	85 c0                	test   %eax,%eax
80101b00:	74 0d                	je     80101b0f <iput+0x60>
      panic("iput busy");
80101b02:	83 ec 0c             	sub    $0xc,%esp
80101b05:	68 e4 88 10 80       	push   $0x801088e4
80101b0a:	e8 4d ea ff ff       	call   8010055c <panic>
    ip->flags |= I_BUSY;
80101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b12:	8b 40 0c             	mov    0xc(%eax),%eax
80101b15:	83 c8 01             	or     $0x1,%eax
80101b18:	89 c2                	mov    %eax,%edx
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b20:	83 ec 0c             	sub    $0xc,%esp
80101b23:	68 40 13 11 80       	push   $0x80111340
80101b28:	e8 9f 37 00 00       	call   801052cc <release>
80101b2d:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b30:	83 ec 0c             	sub    $0xc,%esp
80101b33:	ff 75 08             	pushl  0x8(%ebp)
80101b36:	e8 a6 01 00 00       	call   80101ce1 <itrunc>
80101b3b:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b47:	83 ec 0c             	sub    $0xc,%esp
80101b4a:	ff 75 08             	pushl  0x8(%ebp)
80101b4d:	e8 c2 fb ff ff       	call   80101714 <iupdate>
80101b52:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b55:	83 ec 0c             	sub    $0xc,%esp
80101b58:	68 40 13 11 80       	push   $0x80111340
80101b5d:	e8 04 37 00 00       	call   80105266 <acquire>
80101b62:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b6f:	83 ec 0c             	sub    $0xc,%esp
80101b72:	ff 75 08             	pushl  0x8(%ebp)
80101b75:	e8 a1 32 00 00       	call   80104e1b <wakeup>
80101b7a:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b80:	8b 40 08             	mov    0x8(%eax),%eax
80101b83:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b86:	8b 45 08             	mov    0x8(%ebp),%eax
80101b89:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b8c:	83 ec 0c             	sub    $0xc,%esp
80101b8f:	68 40 13 11 80       	push   $0x80111340
80101b94:	e8 33 37 00 00       	call   801052cc <release>
80101b99:	83 c4 10             	add    $0x10,%esp
}
80101b9c:	c9                   	leave  
80101b9d:	c3                   	ret    

80101b9e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b9e:	55                   	push   %ebp
80101b9f:	89 e5                	mov    %esp,%ebp
80101ba1:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101ba4:	83 ec 0c             	sub    $0xc,%esp
80101ba7:	ff 75 08             	pushl  0x8(%ebp)
80101baa:	e8 8f fe ff ff       	call   80101a3e <iunlock>
80101baf:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101bb2:	83 ec 0c             	sub    $0xc,%esp
80101bb5:	ff 75 08             	pushl  0x8(%ebp)
80101bb8:	e8 f2 fe ff ff       	call   80101aaf <iput>
80101bbd:	83 c4 10             	add    $0x10,%esp
}
80101bc0:	c9                   	leave  
80101bc1:	c3                   	ret    

80101bc2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bc2:	55                   	push   %ebp
80101bc3:	89 e5                	mov    %esp,%ebp
80101bc5:	53                   	push   %ebx
80101bc6:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bc9:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101bcd:	77 42                	ja     80101c11 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bd5:	83 c2 04             	add    $0x4,%edx
80101bd8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be3:	75 24                	jne    80101c09 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101be5:	8b 45 08             	mov    0x8(%ebp),%eax
80101be8:	8b 00                	mov    (%eax),%eax
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	50                   	push   %eax
80101bee:	e8 eb f7 ff ff       	call   801013de <balloc>
80101bf3:	83 c4 10             	add    $0x10,%esp
80101bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bff:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c05:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0c:	e9 cb 00 00 00       	jmp    80101cdc <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c11:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c15:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c19:	0f 87 b0 00 00 00    	ja     80101ccf <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c2c:	75 1d                	jne    80101c4b <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	8b 00                	mov    (%eax),%eax
80101c33:	83 ec 0c             	sub    $0xc,%esp
80101c36:	50                   	push   %eax
80101c37:	e8 a2 f7 ff ff       	call   801013de <balloc>
80101c3c:	83 c4 10             	add    $0x10,%esp
80101c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c48:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4e:	8b 00                	mov    (%eax),%eax
80101c50:	83 ec 08             	sub    $0x8,%esp
80101c53:	ff 75 f4             	pushl  -0xc(%ebp)
80101c56:	50                   	push   %eax
80101c57:	e8 58 e5 ff ff       	call   801001b4 <bread>
80101c5c:	83 c4 10             	add    $0x10,%esp
80101c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c65:	83 c0 18             	add    $0x18,%eax
80101c68:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c78:	01 d0                	add    %edx,%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c83:	75 37                	jne    80101cbc <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c92:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c95:	8b 45 08             	mov    0x8(%ebp),%eax
80101c98:	8b 00                	mov    (%eax),%eax
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	50                   	push   %eax
80101c9e:	e8 3b f7 ff ff       	call   801013de <balloc>
80101ca3:	83 c4 10             	add    $0x10,%esp
80101ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cac:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cae:	83 ec 0c             	sub    $0xc,%esp
80101cb1:	ff 75 f0             	pushl  -0x10(%ebp)
80101cb4:	e8 12 1b 00 00       	call   801037cb <log_write>
80101cb9:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cbc:	83 ec 0c             	sub    $0xc,%esp
80101cbf:	ff 75 f0             	pushl  -0x10(%ebp)
80101cc2:	e8 64 e5 ff ff       	call   8010022b <brelse>
80101cc7:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ccd:	eb 0d                	jmp    80101cdc <bmap+0x11a>
  }

  panic("bmap: out of range");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 ee 88 10 80       	push   $0x801088ee
80101cd7:	e8 80 e8 ff ff       	call   8010055c <panic>
}
80101cdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101cdf:	c9                   	leave  
80101ce0:	c3                   	ret    

80101ce1 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ce1:	55                   	push   %ebp
80101ce2:	89 e5                	mov    %esp,%ebp
80101ce4:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ce7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101cee:	eb 45                	jmp    80101d35 <itrunc+0x54>
    if(ip->addrs[i]){
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf6:	83 c2 04             	add    $0x4,%edx
80101cf9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cfd:	85 c0                	test   %eax,%eax
80101cff:	74 30                	je     80101d31 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d07:	83 c2 04             	add    $0x4,%edx
80101d0a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d0e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d11:	8b 12                	mov    (%edx),%edx
80101d13:	83 ec 08             	sub    $0x8,%esp
80101d16:	50                   	push   %eax
80101d17:	52                   	push   %edx
80101d18:	e8 1f f8 ff ff       	call   8010153c <bfree>
80101d1d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d26:	83 c2 04             	add    $0x4,%edx
80101d29:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d30:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d35:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d39:	7e b5                	jle    80101cf0 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d41:	85 c0                	test   %eax,%eax
80101d43:	0f 84 a1 00 00 00    	je     80101dea <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d49:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4c:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 00                	mov    (%eax),%eax
80101d54:	83 ec 08             	sub    $0x8,%esp
80101d57:	52                   	push   %edx
80101d58:	50                   	push   %eax
80101d59:	e8 56 e4 ff ff       	call   801001b4 <bread>
80101d5e:	83 c4 10             	add    $0x10,%esp
80101d61:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d67:	83 c0 18             	add    $0x18,%eax
80101d6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d6d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d74:	eb 3c                	jmp    80101db2 <itrunc+0xd1>
      if(a[j])
80101d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d83:	01 d0                	add    %edx,%eax
80101d85:	8b 00                	mov    (%eax),%eax
80101d87:	85 c0                	test   %eax,%eax
80101d89:	74 23                	je     80101dae <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d98:	01 d0                	add    %edx,%eax
80101d9a:	8b 00                	mov    (%eax),%eax
80101d9c:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9f:	8b 12                	mov    (%edx),%edx
80101da1:	83 ec 08             	sub    $0x8,%esp
80101da4:	50                   	push   %eax
80101da5:	52                   	push   %edx
80101da6:	e8 91 f7 ff ff       	call   8010153c <bfree>
80101dab:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101dae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db5:	83 f8 7f             	cmp    $0x7f,%eax
80101db8:	76 bc                	jbe    80101d76 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dba:	83 ec 0c             	sub    $0xc,%esp
80101dbd:	ff 75 ec             	pushl  -0x14(%ebp)
80101dc0:	e8 66 e4 ff ff       	call   8010022b <brelse>
80101dc5:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dce:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd1:	8b 12                	mov    (%edx),%edx
80101dd3:	83 ec 08             	sub    $0x8,%esp
80101dd6:	50                   	push   %eax
80101dd7:	52                   	push   %edx
80101dd8:	e8 5f f7 ff ff       	call   8010153c <bfree>
80101ddd:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101df4:	83 ec 0c             	sub    $0xc,%esp
80101df7:	ff 75 08             	pushl  0x8(%ebp)
80101dfa:	e8 15 f9 ff ff       	call   80101714 <iupdate>
80101dff:	83 c4 10             	add    $0x10,%esp
}
80101e02:	c9                   	leave  
80101e03:	c3                   	ret    

80101e04 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e04:	55                   	push   %ebp
80101e05:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e07:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	89 c2                	mov    %eax,%edx
80101e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e11:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 50 04             	mov    0x4(%eax),%edx
80101e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e1d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e30:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e37:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3e:	8b 50 18             	mov    0x18(%eax),%edx
80101e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e44:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e47:	5d                   	pop    %ebp
80101e48:	c3                   	ret    

80101e49 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e49:	55                   	push   %ebp
80101e4a:	89 e5                	mov    %esp,%ebp
80101e4c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e52:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e56:	66 83 f8 03          	cmp    $0x3,%ax
80101e5a:	75 65                	jne    80101ec1 <readi+0x78>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e63:	66 85 c0             	test   %ax,%ax
80101e66:	78 24                	js     80101e8c <readi+0x43>
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e6f:	66 83 f8 09          	cmp    $0x9,%ax
80101e73:	7f 17                	jg     80101e8c <readi+0x43>
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e7c:	98                   	cwtl   
80101e7d:	c1 e0 04             	shl    $0x4,%eax
80101e80:	05 80 12 11 80       	add    $0x80111280,%eax
80101e85:	8b 40 08             	mov    0x8(%eax),%eax
80101e88:	85 c0                	test   %eax,%eax
80101e8a:	75 0a                	jne    80101e96 <readi+0x4d>
      return -1;
80101e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e91:	e9 14 01 00 00       	jmp    80101faa <readi+0x161>
    return devsw[ip->major].read(ip, dst, off, n);
80101e96:	8b 45 08             	mov    0x8(%ebp),%eax
80101e99:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e9d:	98                   	cwtl   
80101e9e:	c1 e0 04             	shl    $0x4,%eax
80101ea1:	05 80 12 11 80       	add    $0x80111280,%eax
80101ea6:	8b 40 08             	mov    0x8(%eax),%eax
80101ea9:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101eac:	8b 55 10             	mov    0x10(%ebp),%edx
80101eaf:	51                   	push   %ecx
80101eb0:	52                   	push   %edx
80101eb1:	ff 75 0c             	pushl  0xc(%ebp)
80101eb4:	ff 75 08             	pushl  0x8(%ebp)
80101eb7:	ff d0                	call   *%eax
80101eb9:	83 c4 10             	add    $0x10,%esp
80101ebc:	e9 e9 00 00 00       	jmp    80101faa <readi+0x161>
  }

  if(off > ip->size || off + n < off)
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	8b 40 18             	mov    0x18(%eax),%eax
80101ec7:	3b 45 10             	cmp    0x10(%ebp),%eax
80101eca:	72 0d                	jb     80101ed9 <readi+0x90>
80101ecc:	8b 55 10             	mov    0x10(%ebp),%edx
80101ecf:	8b 45 14             	mov    0x14(%ebp),%eax
80101ed2:	01 d0                	add    %edx,%eax
80101ed4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ed7:	73 0a                	jae    80101ee3 <readi+0x9a>
    return -1;
80101ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ede:	e9 c7 00 00 00       	jmp    80101faa <readi+0x161>
  if(off + n > ip->size)
80101ee3:	8b 55 10             	mov    0x10(%ebp),%edx
80101ee6:	8b 45 14             	mov    0x14(%ebp),%eax
80101ee9:	01 c2                	add    %eax,%edx
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	8b 40 18             	mov    0x18(%eax),%eax
80101ef1:	39 c2                	cmp    %eax,%edx
80101ef3:	76 0c                	jbe    80101f01 <readi+0xb8>
    n = ip->size - off;
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	8b 40 18             	mov    0x18(%eax),%eax
80101efb:	2b 45 10             	sub    0x10(%ebp),%eax
80101efe:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f08:	e9 8e 00 00 00       	jmp    80101f9b <readi+0x152>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80101f10:	c1 e8 09             	shr    $0x9,%eax
80101f13:	83 ec 08             	sub    $0x8,%esp
80101f16:	50                   	push   %eax
80101f17:	ff 75 08             	pushl  0x8(%ebp)
80101f1a:	e8 a3 fc ff ff       	call   80101bc2 <bmap>
80101f1f:	83 c4 10             	add    $0x10,%esp
80101f22:	89 c2                	mov    %eax,%edx
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	8b 00                	mov    (%eax),%eax
80101f29:	83 ec 08             	sub    $0x8,%esp
80101f2c:	52                   	push   %edx
80101f2d:	50                   	push   %eax
80101f2e:	e8 81 e2 ff ff       	call   801001b4 <bread>
80101f33:	83 c4 10             	add    $0x10,%esp
80101f36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f39:	8b 45 10             	mov    0x10(%ebp),%eax
80101f3c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f41:	ba 00 02 00 00       	mov    $0x200,%edx
80101f46:	29 c2                	sub    %eax,%edx
80101f48:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f4e:	39 c2                	cmp    %eax,%edx
80101f50:	0f 46 c2             	cmovbe %edx,%eax
80101f53:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f56:	8b 45 10             	mov    0x10(%ebp),%eax
80101f59:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f5e:	8d 50 10             	lea    0x10(%eax),%edx
80101f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f64:	01 d0                	add    %edx,%eax
80101f66:	83 c0 08             	add    $0x8,%eax
80101f69:	83 ec 04             	sub    $0x4,%esp
80101f6c:	ff 75 ec             	pushl  -0x14(%ebp)
80101f6f:	50                   	push   %eax
80101f70:	ff 75 0c             	pushl  0xc(%ebp)
80101f73:	e8 09 36 00 00       	call   80105581 <memmove>
80101f78:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f7b:	83 ec 0c             	sub    $0xc,%esp
80101f7e:	ff 75 f0             	pushl  -0x10(%ebp)
80101f81:	e8 a5 e2 ff ff       	call   8010022b <brelse>
80101f86:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f8c:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f92:	01 45 10             	add    %eax,0x10(%ebp)
80101f95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f98:	01 45 0c             	add    %eax,0xc(%ebp)
80101f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f9e:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fa1:	0f 82 66 ff ff ff    	jb     80101f0d <readi+0xc4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fa7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101faa:	c9                   	leave  
80101fab:	c3                   	ret    

80101fac <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fac:	55                   	push   %ebp
80101fad:	89 e5                	mov    %esp,%ebp
80101faf:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fb9:	66 83 f8 03          	cmp    $0x3,%ax
80101fbd:	75 64                	jne    80102023 <writei+0x77>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc6:	66 85 c0             	test   %ax,%ax
80101fc9:	78 24                	js     80101fef <writei+0x43>
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd2:	66 83 f8 09          	cmp    $0x9,%ax
80101fd6:	7f 17                	jg     80101fef <writei+0x43>
80101fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fdf:	98                   	cwtl   
80101fe0:	c1 e0 04             	shl    $0x4,%eax
80101fe3:	05 80 12 11 80       	add    $0x80111280,%eax
80101fe8:	8b 40 0c             	mov    0xc(%eax),%eax
80101feb:	85 c0                	test   %eax,%eax
80101fed:	75 0a                	jne    80101ff9 <writei+0x4d>
      return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 44 01 00 00       	jmp    8010213d <writei+0x191>
    return devsw[ip->major].write(ip, src, n);
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102000:	98                   	cwtl   
80102001:	c1 e0 04             	shl    $0x4,%eax
80102004:	05 80 12 11 80       	add    $0x80111280,%eax
80102009:	8b 40 0c             	mov    0xc(%eax),%eax
8010200c:	8b 55 14             	mov    0x14(%ebp),%edx
8010200f:	83 ec 04             	sub    $0x4,%esp
80102012:	52                   	push   %edx
80102013:	ff 75 0c             	pushl  0xc(%ebp)
80102016:	ff 75 08             	pushl  0x8(%ebp)
80102019:	ff d0                	call   *%eax
8010201b:	83 c4 10             	add    $0x10,%esp
8010201e:	e9 1a 01 00 00       	jmp    8010213d <writei+0x191>
  }

  if(off > ip->size || off + n < off)
80102023:	8b 45 08             	mov    0x8(%ebp),%eax
80102026:	8b 40 18             	mov    0x18(%eax),%eax
80102029:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202c:	72 0d                	jb     8010203b <writei+0x8f>
8010202e:	8b 55 10             	mov    0x10(%ebp),%edx
80102031:	8b 45 14             	mov    0x14(%ebp),%eax
80102034:	01 d0                	add    %edx,%eax
80102036:	3b 45 10             	cmp    0x10(%ebp),%eax
80102039:	73 0a                	jae    80102045 <writei+0x99>
    return -1;
8010203b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102040:	e9 f8 00 00 00       	jmp    8010213d <writei+0x191>
  if(off + n > MAXFILE*BSIZE)
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	8b 45 14             	mov    0x14(%ebp),%eax
8010204b:	01 d0                	add    %edx,%eax
8010204d:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102052:	76 0a                	jbe    8010205e <writei+0xb2>
    return -1;
80102054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102059:	e9 df 00 00 00       	jmp    8010213d <writei+0x191>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010205e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102065:	e9 9c 00 00 00       	jmp    80102106 <writei+0x15a>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010206a:	8b 45 10             	mov    0x10(%ebp),%eax
8010206d:	c1 e8 09             	shr    $0x9,%eax
80102070:	83 ec 08             	sub    $0x8,%esp
80102073:	50                   	push   %eax
80102074:	ff 75 08             	pushl  0x8(%ebp)
80102077:	e8 46 fb ff ff       	call   80101bc2 <bmap>
8010207c:	83 c4 10             	add    $0x10,%esp
8010207f:	89 c2                	mov    %eax,%edx
80102081:	8b 45 08             	mov    0x8(%ebp),%eax
80102084:	8b 00                	mov    (%eax),%eax
80102086:	83 ec 08             	sub    $0x8,%esp
80102089:	52                   	push   %edx
8010208a:	50                   	push   %eax
8010208b:	e8 24 e1 ff ff       	call   801001b4 <bread>
80102090:	83 c4 10             	add    $0x10,%esp
80102093:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102096:	8b 45 10             	mov    0x10(%ebp),%eax
80102099:	25 ff 01 00 00       	and    $0x1ff,%eax
8010209e:	ba 00 02 00 00       	mov    $0x200,%edx
801020a3:	29 c2                	sub    %eax,%edx
801020a5:	8b 45 14             	mov    0x14(%ebp),%eax
801020a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020ab:	39 c2                	cmp    %eax,%edx
801020ad:	0f 46 c2             	cmovbe %edx,%eax
801020b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020b3:	8b 45 10             	mov    0x10(%ebp),%eax
801020b6:	25 ff 01 00 00       	and    $0x1ff,%eax
801020bb:	8d 50 10             	lea    0x10(%eax),%edx
801020be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020c1:	01 d0                	add    %edx,%eax
801020c3:	83 c0 08             	add    $0x8,%eax
801020c6:	83 ec 04             	sub    $0x4,%esp
801020c9:	ff 75 ec             	pushl  -0x14(%ebp)
801020cc:	ff 75 0c             	pushl  0xc(%ebp)
801020cf:	50                   	push   %eax
801020d0:	e8 ac 34 00 00       	call   80105581 <memmove>
801020d5:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020d8:	83 ec 0c             	sub    $0xc,%esp
801020db:	ff 75 f0             	pushl  -0x10(%ebp)
801020de:	e8 e8 16 00 00       	call   801037cb <log_write>
801020e3:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020e6:	83 ec 0c             	sub    $0xc,%esp
801020e9:	ff 75 f0             	pushl  -0x10(%ebp)
801020ec:	e8 3a e1 ff ff       	call   8010022b <brelse>
801020f1:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f7:	01 45 f4             	add    %eax,-0xc(%ebp)
801020fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020fd:	01 45 10             	add    %eax,0x10(%ebp)
80102100:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102103:	01 45 0c             	add    %eax,0xc(%ebp)
80102106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102109:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210c:	0f 82 58 ff ff ff    	jb     8010206a <writei+0xbe>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102112:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102116:	74 22                	je     8010213a <writei+0x18e>
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	8b 40 18             	mov    0x18(%eax),%eax
8010211e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102121:	73 17                	jae    8010213a <writei+0x18e>
    ip->size = off;
80102123:	8b 45 08             	mov    0x8(%ebp),%eax
80102126:	8b 55 10             	mov    0x10(%ebp),%edx
80102129:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010212c:	83 ec 0c             	sub    $0xc,%esp
8010212f:	ff 75 08             	pushl  0x8(%ebp)
80102132:	e8 dd f5 ff ff       	call   80101714 <iupdate>
80102137:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010213a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010213d:	c9                   	leave  
8010213e:	c3                   	ret    

8010213f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010213f:	55                   	push   %ebp
80102140:	89 e5                	mov    %esp,%ebp
80102142:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102145:	83 ec 04             	sub    $0x4,%esp
80102148:	6a 0e                	push   $0xe
8010214a:	ff 75 0c             	pushl  0xc(%ebp)
8010214d:	ff 75 08             	pushl  0x8(%ebp)
80102150:	e8 c4 34 00 00       	call   80105619 <strncmp>
80102155:	83 c4 10             	add    $0x10,%esp
}
80102158:	c9                   	leave  
80102159:	c3                   	ret    

8010215a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010215a:	55                   	push   %ebp
8010215b:	89 e5                	mov    %esp,%ebp
8010215d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;
  struct inode *ip;

  if(dp->type != T_DIR && !IS_DEV_DIR(dp))
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102167:	66 83 f8 01          	cmp    $0x1,%ax
8010216b:	74 51                	je     801021be <dirlookup+0x64>
8010216d:	8b 45 08             	mov    0x8(%ebp),%eax
80102170:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102174:	66 83 f8 03          	cmp    $0x3,%ax
80102178:	75 37                	jne    801021b1 <dirlookup+0x57>
8010217a:	8b 45 08             	mov    0x8(%ebp),%eax
8010217d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102181:	98                   	cwtl   
80102182:	c1 e0 04             	shl    $0x4,%eax
80102185:	05 80 12 11 80       	add    $0x80111280,%eax
8010218a:	8b 00                	mov    (%eax),%eax
8010218c:	85 c0                	test   %eax,%eax
8010218e:	74 21                	je     801021b1 <dirlookup+0x57>
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102197:	98                   	cwtl   
80102198:	c1 e0 04             	shl    $0x4,%eax
8010219b:	05 80 12 11 80       	add    $0x80111280,%eax
801021a0:	8b 00                	mov    (%eax),%eax
801021a2:	83 ec 0c             	sub    $0xc,%esp
801021a5:	ff 75 08             	pushl  0x8(%ebp)
801021a8:	ff d0                	call   *%eax
801021aa:	83 c4 10             	add    $0x10,%esp
801021ad:	85 c0                	test   %eax,%eax
801021af:	75 0d                	jne    801021be <dirlookup+0x64>
    panic("dirlookup not DIR");
801021b1:	83 ec 0c             	sub    $0xc,%esp
801021b4:	68 01 89 10 80       	push   $0x80108901
801021b9:	e8 9e e3 ff ff       	call   8010055c <panic>

  for(off = 0; off < dp->size || dp->type == T_DEV; off += sizeof(de)){
801021be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021c5:	e9 f2 00 00 00       	jmp    801022bc <dirlookup+0x162>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de)) {
801021ca:	6a 10                	push   $0x10
801021cc:	ff 75 f4             	pushl  -0xc(%ebp)
801021cf:	8d 45 dc             	lea    -0x24(%ebp),%eax
801021d2:	50                   	push   %eax
801021d3:	ff 75 08             	pushl  0x8(%ebp)
801021d6:	e8 6e fc ff ff       	call   80101e49 <readi>
801021db:	83 c4 10             	add    $0x10,%esp
801021de:	83 f8 10             	cmp    $0x10,%eax
801021e1:	74 24                	je     80102207 <dirlookup+0xad>
      if (dp->type == T_DEV)
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021ea:	66 83 f8 03          	cmp    $0x3,%ax
801021ee:	75 0a                	jne    801021fa <dirlookup+0xa0>
        return 0;
801021f0:	b8 00 00 00 00       	mov    $0x0,%eax
801021f5:	e9 e7 00 00 00       	jmp    801022e1 <dirlookup+0x187>
      else
        panic("dirlink read");
801021fa:	83 ec 0c             	sub    $0xc,%esp
801021fd:	68 13 89 10 80       	push   $0x80108913
80102202:	e8 55 e3 ff ff       	call   8010055c <panic>
    }
    if(de.inum == 0)
80102207:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
8010220b:	66 85 c0             	test   %ax,%ax
8010220e:	75 05                	jne    80102215 <dirlookup+0xbb>
      continue;
80102210:	e9 a3 00 00 00       	jmp    801022b8 <dirlookup+0x15e>
    if(namecmp(name, de.name) == 0){
80102215:	83 ec 08             	sub    $0x8,%esp
80102218:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010221b:	83 c0 02             	add    $0x2,%eax
8010221e:	50                   	push   %eax
8010221f:	ff 75 0c             	pushl  0xc(%ebp)
80102222:	e8 18 ff ff ff       	call   8010213f <namecmp>
80102227:	83 c4 10             	add    $0x10,%esp
8010222a:	85 c0                	test   %eax,%eax
8010222c:	0f 85 86 00 00 00    	jne    801022b8 <dirlookup+0x15e>
      // entry matches path element
      if(poff)
80102232:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102236:	74 08                	je     80102240 <dirlookup+0xe6>
        *poff = off;
80102238:	8b 45 10             	mov    0x10(%ebp),%eax
8010223b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010223e:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102240:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
80102244:	0f b7 c0             	movzwl %ax,%eax
80102247:	89 45 f0             	mov    %eax,-0x10(%ebp)
      ip = iget(dp->dev, inum);
8010224a:	8b 45 08             	mov    0x8(%ebp),%eax
8010224d:	8b 00                	mov    (%eax),%eax
8010224f:	83 ec 08             	sub    $0x8,%esp
80102252:	ff 75 f0             	pushl  -0x10(%ebp)
80102255:	50                   	push   %eax
80102256:	e8 73 f5 ff ff       	call   801017ce <iget>
8010225b:	83 c4 10             	add    $0x10,%esp
8010225e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (!(ip->flags & I_VALID) && dp->type == T_DEV && devsw[dp->major].iread) {
80102261:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102264:	8b 40 0c             	mov    0xc(%eax),%eax
80102267:	83 e0 02             	and    $0x2,%eax
8010226a:	85 c0                	test   %eax,%eax
8010226c:	75 45                	jne    801022b3 <dirlookup+0x159>
8010226e:	8b 45 08             	mov    0x8(%ebp),%eax
80102271:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102275:	66 83 f8 03          	cmp    $0x3,%ax
80102279:	75 38                	jne    801022b3 <dirlookup+0x159>
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102282:	98                   	cwtl   
80102283:	c1 e0 04             	shl    $0x4,%eax
80102286:	05 80 12 11 80       	add    $0x80111280,%eax
8010228b:	8b 40 04             	mov    0x4(%eax),%eax
8010228e:	85 c0                	test   %eax,%eax
80102290:	74 21                	je     801022b3 <dirlookup+0x159>
    	  devsw[dp->major].iread(dp, ip);
80102292:	8b 45 08             	mov    0x8(%ebp),%eax
80102295:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102299:	98                   	cwtl   
8010229a:	c1 e0 04             	shl    $0x4,%eax
8010229d:	05 80 12 11 80       	add    $0x80111280,%eax
801022a2:	8b 40 04             	mov    0x4(%eax),%eax
801022a5:	83 ec 08             	sub    $0x8,%esp
801022a8:	ff 75 ec             	pushl  -0x14(%ebp)
801022ab:	ff 75 08             	pushl  0x8(%ebp)
801022ae:	ff d0                	call   *%eax
801022b0:	83 c4 10             	add    $0x10,%esp
      }
      return ip;
801022b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b6:	eb 29                	jmp    801022e1 <dirlookup+0x187>
  struct inode *ip;

  if(dp->type != T_DIR && !IS_DEV_DIR(dp))
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size || dp->type == T_DEV; off += sizeof(de)){
801022b8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022bc:	8b 45 08             	mov    0x8(%ebp),%eax
801022bf:	8b 40 18             	mov    0x18(%eax),%eax
801022c2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022c5:	0f 87 ff fe ff ff    	ja     801021ca <dirlookup+0x70>
801022cb:	8b 45 08             	mov    0x8(%ebp),%eax
801022ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801022d2:	66 83 f8 03          	cmp    $0x3,%ax
801022d6:	0f 84 ee fe ff ff    	je     801021ca <dirlookup+0x70>
      }
      return ip;
    }
  }

  return 0;
801022dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022e1:	c9                   	leave  
801022e2:	c3                   	ret    

801022e3 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022e3:	55                   	push   %ebp
801022e4:	89 e5                	mov    %esp,%ebp
801022e6:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022e9:	83 ec 04             	sub    $0x4,%esp
801022ec:	6a 00                	push   $0x0
801022ee:	ff 75 0c             	pushl  0xc(%ebp)
801022f1:	ff 75 08             	pushl  0x8(%ebp)
801022f4:	e8 61 fe ff ff       	call   8010215a <dirlookup>
801022f9:	83 c4 10             	add    $0x10,%esp
801022fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102303:	74 18                	je     8010231d <dirlink+0x3a>
    iput(ip);
80102305:	83 ec 0c             	sub    $0xc,%esp
80102308:	ff 75 f0             	pushl  -0x10(%ebp)
8010230b:	e8 9f f7 ff ff       	call   80101aaf <iput>
80102310:	83 c4 10             	add    $0x10,%esp
    return -1;
80102313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102318:	e9 9b 00 00 00       	jmp    801023b8 <dirlink+0xd5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010231d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102324:	eb 3b                	jmp    80102361 <dirlink+0x7e>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102329:	6a 10                	push   $0x10
8010232b:	50                   	push   %eax
8010232c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232f:	50                   	push   %eax
80102330:	ff 75 08             	pushl  0x8(%ebp)
80102333:	e8 11 fb ff ff       	call   80101e49 <readi>
80102338:	83 c4 10             	add    $0x10,%esp
8010233b:	83 f8 10             	cmp    $0x10,%eax
8010233e:	74 0d                	je     8010234d <dirlink+0x6a>
      panic("dirlink read");
80102340:	83 ec 0c             	sub    $0xc,%esp
80102343:	68 13 89 10 80       	push   $0x80108913
80102348:	e8 0f e2 ff ff       	call   8010055c <panic>
    if(de.inum == 0)
8010234d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102351:	66 85 c0             	test   %ax,%ax
80102354:	75 02                	jne    80102358 <dirlink+0x75>
      break;
80102356:	eb 16                	jmp    8010236e <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235b:	83 c0 10             	add    $0x10,%eax
8010235e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102361:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102364:	8b 45 08             	mov    0x8(%ebp),%eax
80102367:	8b 40 18             	mov    0x18(%eax),%eax
8010236a:	39 c2                	cmp    %eax,%edx
8010236c:	72 b8                	jb     80102326 <dirlink+0x43>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010236e:	83 ec 04             	sub    $0x4,%esp
80102371:	6a 0e                	push   $0xe
80102373:	ff 75 0c             	pushl  0xc(%ebp)
80102376:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102379:	83 c0 02             	add    $0x2,%eax
8010237c:	50                   	push   %eax
8010237d:	e8 ed 32 00 00       	call   8010566f <strncpy>
80102382:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102385:	8b 45 10             	mov    0x10(%ebp),%eax
80102388:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238f:	6a 10                	push   $0x10
80102391:	50                   	push   %eax
80102392:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102395:	50                   	push   %eax
80102396:	ff 75 08             	pushl  0x8(%ebp)
80102399:	e8 0e fc ff ff       	call   80101fac <writei>
8010239e:	83 c4 10             	add    $0x10,%esp
801023a1:	83 f8 10             	cmp    $0x10,%eax
801023a4:	74 0d                	je     801023b3 <dirlink+0xd0>
    panic("dirlink");
801023a6:	83 ec 0c             	sub    $0xc,%esp
801023a9:	68 20 89 10 80       	push   $0x80108920
801023ae:	e8 a9 e1 ff ff       	call   8010055c <panic>
  
  return 0;
801023b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023b8:	c9                   	leave  
801023b9:	c3                   	ret    

801023ba <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023ba:	55                   	push   %ebp
801023bb:	89 e5                	mov    %esp,%ebp
801023bd:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023c0:	eb 04                	jmp    801023c6 <skipelem+0xc>
    path++;
801023c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023c6:	8b 45 08             	mov    0x8(%ebp),%eax
801023c9:	0f b6 00             	movzbl (%eax),%eax
801023cc:	3c 2f                	cmp    $0x2f,%al
801023ce:	74 f2                	je     801023c2 <skipelem+0x8>
    path++;
  if(*path == 0)
801023d0:	8b 45 08             	mov    0x8(%ebp),%eax
801023d3:	0f b6 00             	movzbl (%eax),%eax
801023d6:	84 c0                	test   %al,%al
801023d8:	75 07                	jne    801023e1 <skipelem+0x27>
    return 0;
801023da:	b8 00 00 00 00       	mov    $0x0,%eax
801023df:	eb 7b                	jmp    8010245c <skipelem+0xa2>
  s = path;
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
801023e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023e7:	eb 04                	jmp    801023ed <skipelem+0x33>
    path++;
801023e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023ed:	8b 45 08             	mov    0x8(%ebp),%eax
801023f0:	0f b6 00             	movzbl (%eax),%eax
801023f3:	3c 2f                	cmp    $0x2f,%al
801023f5:	74 0a                	je     80102401 <skipelem+0x47>
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	84 c0                	test   %al,%al
801023ff:	75 e8                	jne    801023e9 <skipelem+0x2f>
    path++;
  len = path - s;
80102401:	8b 55 08             	mov    0x8(%ebp),%edx
80102404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102407:	29 c2                	sub    %eax,%edx
80102409:	89 d0                	mov    %edx,%eax
8010240b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010240e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102412:	7e 15                	jle    80102429 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102414:	83 ec 04             	sub    $0x4,%esp
80102417:	6a 0e                	push   $0xe
80102419:	ff 75 f4             	pushl  -0xc(%ebp)
8010241c:	ff 75 0c             	pushl  0xc(%ebp)
8010241f:	e8 5d 31 00 00       	call   80105581 <memmove>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	eb 20                	jmp    80102449 <skipelem+0x8f>
  else {
    memmove(name, s, len);
80102429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010242c:	83 ec 04             	sub    $0x4,%esp
8010242f:	50                   	push   %eax
80102430:	ff 75 f4             	pushl  -0xc(%ebp)
80102433:	ff 75 0c             	pushl  0xc(%ebp)
80102436:	e8 46 31 00 00       	call   80105581 <memmove>
8010243b:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010243e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102441:	8b 45 0c             	mov    0xc(%ebp),%eax
80102444:	01 d0                	add    %edx,%eax
80102446:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102449:	eb 04                	jmp    8010244f <skipelem+0x95>
    path++;
8010244b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010244f:	8b 45 08             	mov    0x8(%ebp),%eax
80102452:	0f b6 00             	movzbl (%eax),%eax
80102455:	3c 2f                	cmp    $0x2f,%al
80102457:	74 f2                	je     8010244b <skipelem+0x91>
    path++;
  return path;
80102459:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010245c:	c9                   	leave  
8010245d:	c3                   	ret    

8010245e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010245e:	55                   	push   %ebp
8010245f:	89 e5                	mov    %esp,%ebp
80102461:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/'){
80102464:	8b 45 08             	mov    0x8(%ebp),%eax
80102467:	0f b6 00             	movzbl (%eax),%eax
8010246a:	3c 2f                	cmp    $0x2f,%al
8010246c:	75 14                	jne    80102482 <namex+0x24>
	  ip = iget(ROOTDEV, ROOTINO);
8010246e:	83 ec 08             	sub    $0x8,%esp
80102471:	6a 01                	push   $0x1
80102473:	6a 01                	push   $0x1
80102475:	e8 54 f3 ff ff       	call   801017ce <iget>
8010247a:	83 c4 10             	add    $0x10,%esp
8010247d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102480:	eb 18                	jmp    8010249a <namex+0x3c>
  }

  else
    ip = idup(proc->cwd);
80102482:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102488:	8b 40 68             	mov    0x68(%eax),%eax
8010248b:	83 ec 0c             	sub    $0xc,%esp
8010248e:	50                   	push   %eax
8010248f:	e8 19 f4 ff ff       	call   801018ad <idup>
80102494:	83 c4 10             	add    $0x10,%esp
80102497:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010249a:	e9 e2 00 00 00       	jmp    80102581 <namex+0x123>
    ilock(ip);
8010249f:	83 ec 0c             	sub    $0xc,%esp
801024a2:	ff 75 f4             	pushl  -0xc(%ebp)
801024a5:	e8 3d f4 ff ff       	call   801018e7 <ilock>
801024aa:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR && !IS_DEV_DIR(ip)){
801024ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024b4:	66 83 f8 01          	cmp    $0x1,%ax
801024b8:	74 5c                	je     80102516 <namex+0xb8>
801024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024bd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024c1:	66 83 f8 03          	cmp    $0x3,%ax
801024c5:	75 37                	jne    801024fe <namex+0xa0>
801024c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ca:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024ce:	98                   	cwtl   
801024cf:	c1 e0 04             	shl    $0x4,%eax
801024d2:	05 80 12 11 80       	add    $0x80111280,%eax
801024d7:	8b 00                	mov    (%eax),%eax
801024d9:	85 c0                	test   %eax,%eax
801024db:	74 21                	je     801024fe <namex+0xa0>
801024dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024e4:	98                   	cwtl   
801024e5:	c1 e0 04             	shl    $0x4,%eax
801024e8:	05 80 12 11 80       	add    $0x80111280,%eax
801024ed:	8b 00                	mov    (%eax),%eax
801024ef:	83 ec 0c             	sub    $0xc,%esp
801024f2:	ff 75 f4             	pushl  -0xc(%ebp)
801024f5:	ff d0                	call   *%eax
801024f7:	83 c4 10             	add    $0x10,%esp
801024fa:	85 c0                	test   %eax,%eax
801024fc:	75 18                	jne    80102516 <namex+0xb8>
      iunlockput(ip);
801024fe:	83 ec 0c             	sub    $0xc,%esp
80102501:	ff 75 f4             	pushl  -0xc(%ebp)
80102504:	e8 95 f6 ff ff       	call   80101b9e <iunlockput>
80102509:	83 c4 10             	add    $0x10,%esp
      return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
80102511:	e9 a7 00 00 00       	jmp    801025bd <namex+0x15f>
    }
    if(nameiparent && *path == '\0'){
80102516:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010251a:	74 20                	je     8010253c <namex+0xde>
8010251c:	8b 45 08             	mov    0x8(%ebp),%eax
8010251f:	0f b6 00             	movzbl (%eax),%eax
80102522:	84 c0                	test   %al,%al
80102524:	75 16                	jne    8010253c <namex+0xde>
      // Stop one level early.
      iunlock(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	pushl  -0xc(%ebp)
8010252c:	e8 0d f5 ff ff       	call   80101a3e <iunlock>
80102531:	83 c4 10             	add    $0x10,%esp
      return ip;
80102534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102537:	e9 81 00 00 00       	jmp    801025bd <namex+0x15f>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010253c:	83 ec 04             	sub    $0x4,%esp
8010253f:	6a 00                	push   $0x0
80102541:	ff 75 10             	pushl  0x10(%ebp)
80102544:	ff 75 f4             	pushl  -0xc(%ebp)
80102547:	e8 0e fc ff ff       	call   8010215a <dirlookup>
8010254c:	83 c4 10             	add    $0x10,%esp
8010254f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102552:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102556:	75 15                	jne    8010256d <namex+0x10f>
      iunlockput(ip);
80102558:	83 ec 0c             	sub    $0xc,%esp
8010255b:	ff 75 f4             	pushl  -0xc(%ebp)
8010255e:	e8 3b f6 ff ff       	call   80101b9e <iunlockput>
80102563:	83 c4 10             	add    $0x10,%esp
      return 0;
80102566:	b8 00 00 00 00       	mov    $0x0,%eax
8010256b:	eb 50                	jmp    801025bd <namex+0x15f>
    }
    iunlockput(ip);
8010256d:	83 ec 0c             	sub    $0xc,%esp
80102570:	ff 75 f4             	pushl  -0xc(%ebp)
80102573:	e8 26 f6 ff ff       	call   80101b9e <iunlockput>
80102578:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010257b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010257e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }

  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102581:	83 ec 08             	sub    $0x8,%esp
80102584:	ff 75 10             	pushl  0x10(%ebp)
80102587:	ff 75 08             	pushl  0x8(%ebp)
8010258a:	e8 2b fe ff ff       	call   801023ba <skipelem>
8010258f:	83 c4 10             	add    $0x10,%esp
80102592:	89 45 08             	mov    %eax,0x8(%ebp)
80102595:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102599:	0f 85 00 ff ff ff    	jne    8010249f <namex+0x41>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010259f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025a3:	74 15                	je     801025ba <namex+0x15c>
    iput(ip);
801025a5:	83 ec 0c             	sub    $0xc,%esp
801025a8:	ff 75 f4             	pushl  -0xc(%ebp)
801025ab:	e8 ff f4 ff ff       	call   80101aaf <iput>
801025b0:	83 c4 10             	add    $0x10,%esp
    return 0;
801025b3:	b8 00 00 00 00       	mov    $0x0,%eax
801025b8:	eb 03                	jmp    801025bd <namex+0x15f>
  }
  return ip;
801025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025bd:	c9                   	leave  
801025be:	c3                   	ret    

801025bf <namei>:

struct inode*
namei(char *path)
{
801025bf:	55                   	push   %ebp
801025c0:	89 e5                	mov    %esp,%ebp
801025c2:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025c5:	83 ec 04             	sub    $0x4,%esp
801025c8:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025cb:	50                   	push   %eax
801025cc:	6a 00                	push   $0x0
801025ce:	ff 75 08             	pushl  0x8(%ebp)
801025d1:	e8 88 fe ff ff       	call   8010245e <namex>
801025d6:	83 c4 10             	add    $0x10,%esp
}
801025d9:	c9                   	leave  
801025da:	c3                   	ret    

801025db <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025db:	55                   	push   %ebp
801025dc:	89 e5                	mov    %esp,%ebp
801025de:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025e1:	83 ec 04             	sub    $0x4,%esp
801025e4:	ff 75 0c             	pushl  0xc(%ebp)
801025e7:	6a 01                	push   $0x1
801025e9:	ff 75 08             	pushl  0x8(%ebp)
801025ec:	e8 6d fe ff ff       	call   8010245e <namex>
801025f1:	83 c4 10             	add    $0x10,%esp
}
801025f4:	c9                   	leave  
801025f5:	c3                   	ret    

801025f6 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025f6:	55                   	push   %ebp
801025f7:	89 e5                	mov    %esp,%ebp
801025f9:	83 ec 14             	sub    $0x14,%esp
801025fc:	8b 45 08             	mov    0x8(%ebp),%eax
801025ff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102603:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102607:	89 c2                	mov    %eax,%edx
80102609:	ec                   	in     (%dx),%al
8010260a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010260d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102611:	c9                   	leave  
80102612:	c3                   	ret    

80102613 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102613:	55                   	push   %ebp
80102614:	89 e5                	mov    %esp,%ebp
80102616:	57                   	push   %edi
80102617:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102618:	8b 55 08             	mov    0x8(%ebp),%edx
8010261b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010261e:	8b 45 10             	mov    0x10(%ebp),%eax
80102621:	89 cb                	mov    %ecx,%ebx
80102623:	89 df                	mov    %ebx,%edi
80102625:	89 c1                	mov    %eax,%ecx
80102627:	fc                   	cld    
80102628:	f3 6d                	rep insl (%dx),%es:(%edi)
8010262a:	89 c8                	mov    %ecx,%eax
8010262c:	89 fb                	mov    %edi,%ebx
8010262e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102631:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102634:	5b                   	pop    %ebx
80102635:	5f                   	pop    %edi
80102636:	5d                   	pop    %ebp
80102637:	c3                   	ret    

80102638 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	83 ec 08             	sub    $0x8,%esp
8010263e:	8b 55 08             	mov    0x8(%ebp),%edx
80102641:	8b 45 0c             	mov    0xc(%ebp),%eax
80102644:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102648:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010264b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010264f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102653:	ee                   	out    %al,(%dx)
}
80102654:	c9                   	leave  
80102655:	c3                   	ret    

80102656 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102656:	55                   	push   %ebp
80102657:	89 e5                	mov    %esp,%ebp
80102659:	56                   	push   %esi
8010265a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010265b:	8b 55 08             	mov    0x8(%ebp),%edx
8010265e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102661:	8b 45 10             	mov    0x10(%ebp),%eax
80102664:	89 cb                	mov    %ecx,%ebx
80102666:	89 de                	mov    %ebx,%esi
80102668:	89 c1                	mov    %eax,%ecx
8010266a:	fc                   	cld    
8010266b:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010266d:	89 c8                	mov    %ecx,%eax
8010266f:	89 f3                	mov    %esi,%ebx
80102671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102674:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102677:	5b                   	pop    %ebx
80102678:	5e                   	pop    %esi
80102679:	5d                   	pop    %ebp
8010267a:	c3                   	ret    

8010267b <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010267b:	55                   	push   %ebp
8010267c:	89 e5                	mov    %esp,%ebp
8010267e:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102681:	90                   	nop
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 6a ff ff ff       	call   801025f6 <inb>
8010268c:	83 c4 04             	add    $0x4,%esp
8010268f:	0f b6 c0             	movzbl %al,%eax
80102692:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102695:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102698:	25 c0 00 00 00       	and    $0xc0,%eax
8010269d:	83 f8 40             	cmp    $0x40,%eax
801026a0:	75 e0                	jne    80102682 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026a6:	74 11                	je     801026b9 <idewait+0x3e>
801026a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026ab:	83 e0 21             	and    $0x21,%eax
801026ae:	85 c0                	test   %eax,%eax
801026b0:	74 07                	je     801026b9 <idewait+0x3e>
    return -1;
801026b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026b7:	eb 05                	jmp    801026be <idewait+0x43>
  return 0;
801026b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026be:	c9                   	leave  
801026bf:	c3                   	ret    

801026c0 <ideinit>:

void
ideinit(void)
{
801026c0:	55                   	push   %ebp
801026c1:	89 e5                	mov    %esp,%ebp
801026c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026c6:	83 ec 08             	sub    $0x8,%esp
801026c9:	68 28 89 10 80       	push   $0x80108928
801026ce:	68 60 b6 10 80       	push   $0x8010b660
801026d3:	e8 6d 2b 00 00       	call   80105245 <initlock>
801026d8:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026db:	83 ec 0c             	sub    $0xc,%esp
801026de:	6a 0e                	push   $0xe
801026e0:	e8 8d 18 00 00       	call   80103f72 <picenable>
801026e5:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026e8:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
801026ed:	83 e8 01             	sub    $0x1,%eax
801026f0:	83 ec 08             	sub    $0x8,%esp
801026f3:	50                   	push   %eax
801026f4:	6a 0e                	push   $0xe
801026f6:	e8 31 04 00 00       	call   80102b2c <ioapicenable>
801026fb:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026fe:	83 ec 0c             	sub    $0xc,%esp
80102701:	6a 00                	push   $0x0
80102703:	e8 73 ff ff ff       	call   8010267b <idewait>
80102708:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010270b:	83 ec 08             	sub    $0x8,%esp
8010270e:	68 f0 00 00 00       	push   $0xf0
80102713:	68 f6 01 00 00       	push   $0x1f6
80102718:	e8 1b ff ff ff       	call   80102638 <outb>
8010271d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102727:	eb 24                	jmp    8010274d <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102729:	83 ec 0c             	sub    $0xc,%esp
8010272c:	68 f7 01 00 00       	push   $0x1f7
80102731:	e8 c0 fe ff ff       	call   801025f6 <inb>
80102736:	83 c4 10             	add    $0x10,%esp
80102739:	84 c0                	test   %al,%al
8010273b:	74 0c                	je     80102749 <ideinit+0x89>
      havedisk1 = 1;
8010273d:	c7 05 98 b6 10 80 01 	movl   $0x1,0x8010b698
80102744:	00 00 00 
      break;
80102747:	eb 0d                	jmp    80102756 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010274d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102754:	7e d3                	jle    80102729 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102756:	83 ec 08             	sub    $0x8,%esp
80102759:	68 e0 00 00 00       	push   $0xe0
8010275e:	68 f6 01 00 00       	push   $0x1f6
80102763:	e8 d0 fe ff ff       	call   80102638 <outb>
80102768:	83 c4 10             	add    $0x10,%esp
}
8010276b:	c9                   	leave  
8010276c:	c3                   	ret    

8010276d <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010276d:	55                   	push   %ebp
8010276e:	89 e5                	mov    %esp,%ebp
80102770:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102773:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102777:	75 0d                	jne    80102786 <idestart+0x19>
    panic("idestart");
80102779:	83 ec 0c             	sub    $0xc,%esp
8010277c:	68 2c 89 10 80       	push   $0x8010892c
80102781:	e8 d6 dd ff ff       	call   8010055c <panic>

  idewait(0);
80102786:	83 ec 0c             	sub    $0xc,%esp
80102789:	6a 00                	push   $0x0
8010278b:	e8 eb fe ff ff       	call   8010267b <idewait>
80102790:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102793:	83 ec 08             	sub    $0x8,%esp
80102796:	6a 00                	push   $0x0
80102798:	68 f6 03 00 00       	push   $0x3f6
8010279d:	e8 96 fe ff ff       	call   80102638 <outb>
801027a2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801027a5:	83 ec 08             	sub    $0x8,%esp
801027a8:	6a 01                	push   $0x1
801027aa:	68 f2 01 00 00       	push   $0x1f2
801027af:	e8 84 fe ff ff       	call   80102638 <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	8b 40 08             	mov    0x8(%eax),%eax
801027bd:	0f b6 c0             	movzbl %al,%eax
801027c0:	83 ec 08             	sub    $0x8,%esp
801027c3:	50                   	push   %eax
801027c4:	68 f3 01 00 00       	push   $0x1f3
801027c9:	e8 6a fe ff ff       	call   80102638 <outb>
801027ce:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801027d1:	8b 45 08             	mov    0x8(%ebp),%eax
801027d4:	8b 40 08             	mov    0x8(%eax),%eax
801027d7:	c1 e8 08             	shr    $0x8,%eax
801027da:	0f b6 c0             	movzbl %al,%eax
801027dd:	83 ec 08             	sub    $0x8,%esp
801027e0:	50                   	push   %eax
801027e1:	68 f4 01 00 00       	push   $0x1f4
801027e6:	e8 4d fe ff ff       	call   80102638 <outb>
801027eb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801027ee:	8b 45 08             	mov    0x8(%ebp),%eax
801027f1:	8b 40 08             	mov    0x8(%eax),%eax
801027f4:	c1 e8 10             	shr    $0x10,%eax
801027f7:	0f b6 c0             	movzbl %al,%eax
801027fa:	83 ec 08             	sub    $0x8,%esp
801027fd:	50                   	push   %eax
801027fe:	68 f5 01 00 00       	push   $0x1f5
80102803:	e8 30 fe ff ff       	call   80102638 <outb>
80102808:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
8010280b:	8b 45 08             	mov    0x8(%ebp),%eax
8010280e:	8b 40 04             	mov    0x4(%eax),%eax
80102811:	83 e0 01             	and    $0x1,%eax
80102814:	c1 e0 04             	shl    $0x4,%eax
80102817:	89 c2                	mov    %eax,%edx
80102819:	8b 45 08             	mov    0x8(%ebp),%eax
8010281c:	8b 40 08             	mov    0x8(%eax),%eax
8010281f:	c1 e8 18             	shr    $0x18,%eax
80102822:	83 e0 0f             	and    $0xf,%eax
80102825:	09 d0                	or     %edx,%eax
80102827:	83 c8 e0             	or     $0xffffffe0,%eax
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	83 ec 08             	sub    $0x8,%esp
80102830:	50                   	push   %eax
80102831:	68 f6 01 00 00       	push   $0x1f6
80102836:	e8 fd fd ff ff       	call   80102638 <outb>
8010283b:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010283e:	8b 45 08             	mov    0x8(%ebp),%eax
80102841:	8b 00                	mov    (%eax),%eax
80102843:	83 e0 04             	and    $0x4,%eax
80102846:	85 c0                	test   %eax,%eax
80102848:	74 30                	je     8010287a <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010284a:	83 ec 08             	sub    $0x8,%esp
8010284d:	6a 30                	push   $0x30
8010284f:	68 f7 01 00 00       	push   $0x1f7
80102854:	e8 df fd ff ff       	call   80102638 <outb>
80102859:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
8010285c:	8b 45 08             	mov    0x8(%ebp),%eax
8010285f:	83 c0 18             	add    $0x18,%eax
80102862:	83 ec 04             	sub    $0x4,%esp
80102865:	68 80 00 00 00       	push   $0x80
8010286a:	50                   	push   %eax
8010286b:	68 f0 01 00 00       	push   $0x1f0
80102870:	e8 e1 fd ff ff       	call   80102656 <outsl>
80102875:	83 c4 10             	add    $0x10,%esp
80102878:	eb 12                	jmp    8010288c <idestart+0x11f>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010287a:	83 ec 08             	sub    $0x8,%esp
8010287d:	6a 20                	push   $0x20
8010287f:	68 f7 01 00 00       	push   $0x1f7
80102884:	e8 af fd ff ff       	call   80102638 <outb>
80102889:	83 c4 10             	add    $0x10,%esp
  }
}
8010288c:	c9                   	leave  
8010288d:	c3                   	ret    

8010288e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010288e:	55                   	push   %ebp
8010288f:	89 e5                	mov    %esp,%ebp
80102891:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102894:	83 ec 0c             	sub    $0xc,%esp
80102897:	68 60 b6 10 80       	push   $0x8010b660
8010289c:	e8 c5 29 00 00       	call   80105266 <acquire>
801028a1:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028a4:	a1 94 b6 10 80       	mov    0x8010b694,%eax
801028a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028b0:	75 15                	jne    801028c7 <ideintr+0x39>
    release(&idelock);
801028b2:	83 ec 0c             	sub    $0xc,%esp
801028b5:	68 60 b6 10 80       	push   $0x8010b660
801028ba:	e8 0d 2a 00 00       	call   801052cc <release>
801028bf:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801028c2:	e9 9a 00 00 00       	jmp    80102961 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 40 14             	mov    0x14(%eax),%eax
801028cd:	a3 94 b6 10 80       	mov    %eax,0x8010b694

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d5:	8b 00                	mov    (%eax),%eax
801028d7:	83 e0 04             	and    $0x4,%eax
801028da:	85 c0                	test   %eax,%eax
801028dc:	75 2d                	jne    8010290b <ideintr+0x7d>
801028de:	83 ec 0c             	sub    $0xc,%esp
801028e1:	6a 01                	push   $0x1
801028e3:	e8 93 fd ff ff       	call   8010267b <idewait>
801028e8:	83 c4 10             	add    $0x10,%esp
801028eb:	85 c0                	test   %eax,%eax
801028ed:	78 1c                	js     8010290b <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801028ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f2:	83 c0 18             	add    $0x18,%eax
801028f5:	83 ec 04             	sub    $0x4,%esp
801028f8:	68 80 00 00 00       	push   $0x80
801028fd:	50                   	push   %eax
801028fe:	68 f0 01 00 00       	push   $0x1f0
80102903:	e8 0b fd ff ff       	call   80102613 <insl>
80102908:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010290b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290e:	8b 00                	mov    (%eax),%eax
80102910:	83 c8 02             	or     $0x2,%eax
80102913:	89 c2                	mov    %eax,%edx
80102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102918:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010291a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291d:	8b 00                	mov    (%eax),%eax
8010291f:	83 e0 fb             	and    $0xfffffffb,%eax
80102922:	89 c2                	mov    %eax,%edx
80102924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102927:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102929:	83 ec 0c             	sub    $0xc,%esp
8010292c:	ff 75 f4             	pushl  -0xc(%ebp)
8010292f:	e8 e7 24 00 00       	call   80104e1b <wakeup>
80102934:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102937:	a1 94 b6 10 80       	mov    0x8010b694,%eax
8010293c:	85 c0                	test   %eax,%eax
8010293e:	74 11                	je     80102951 <ideintr+0xc3>
    idestart(idequeue);
80102940:	a1 94 b6 10 80       	mov    0x8010b694,%eax
80102945:	83 ec 0c             	sub    $0xc,%esp
80102948:	50                   	push   %eax
80102949:	e8 1f fe ff ff       	call   8010276d <idestart>
8010294e:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102951:	83 ec 0c             	sub    $0xc,%esp
80102954:	68 60 b6 10 80       	push   $0x8010b660
80102959:	e8 6e 29 00 00       	call   801052cc <release>
8010295e:	83 c4 10             	add    $0x10,%esp
}
80102961:	c9                   	leave  
80102962:	c3                   	ret    

80102963 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102963:	55                   	push   %ebp
80102964:	89 e5                	mov    %esp,%ebp
80102966:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102969:	8b 45 08             	mov    0x8(%ebp),%eax
8010296c:	8b 00                	mov    (%eax),%eax
8010296e:	83 e0 01             	and    $0x1,%eax
80102971:	85 c0                	test   %eax,%eax
80102973:	75 0d                	jne    80102982 <iderw+0x1f>
    panic("iderw: buf not busy");
80102975:	83 ec 0c             	sub    $0xc,%esp
80102978:	68 35 89 10 80       	push   $0x80108935
8010297d:	e8 da db ff ff       	call   8010055c <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102982:	8b 45 08             	mov    0x8(%ebp),%eax
80102985:	8b 00                	mov    (%eax),%eax
80102987:	83 e0 06             	and    $0x6,%eax
8010298a:	83 f8 02             	cmp    $0x2,%eax
8010298d:	75 0d                	jne    8010299c <iderw+0x39>
    panic("iderw: nothing to do");
8010298f:	83 ec 0c             	sub    $0xc,%esp
80102992:	68 49 89 10 80       	push   $0x80108949
80102997:	e8 c0 db ff ff       	call   8010055c <panic>
  if(b->dev != 0 && !havedisk1)
8010299c:	8b 45 08             	mov    0x8(%ebp),%eax
8010299f:	8b 40 04             	mov    0x4(%eax),%eax
801029a2:	85 c0                	test   %eax,%eax
801029a4:	74 16                	je     801029bc <iderw+0x59>
801029a6:	a1 98 b6 10 80       	mov    0x8010b698,%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	75 0d                	jne    801029bc <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029af:	83 ec 0c             	sub    $0xc,%esp
801029b2:	68 5e 89 10 80       	push   $0x8010895e
801029b7:	e8 a0 db ff ff       	call   8010055c <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029bc:	83 ec 0c             	sub    $0xc,%esp
801029bf:	68 60 b6 10 80       	push   $0x8010b660
801029c4:	e8 9d 28 00 00       	call   80105266 <acquire>
801029c9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029cc:	8b 45 08             	mov    0x8(%ebp),%eax
801029cf:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029d6:	c7 45 f4 94 b6 10 80 	movl   $0x8010b694,-0xc(%ebp)
801029dd:	eb 0b                	jmp    801029ea <iderw+0x87>
801029df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e2:	8b 00                	mov    (%eax),%eax
801029e4:	83 c0 14             	add    $0x14,%eax
801029e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ed:	8b 00                	mov    (%eax),%eax
801029ef:	85 c0                	test   %eax,%eax
801029f1:	75 ec                	jne    801029df <iderw+0x7c>
    ;
  *pp = b;
801029f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f6:	8b 55 08             	mov    0x8(%ebp),%edx
801029f9:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029fb:	a1 94 b6 10 80       	mov    0x8010b694,%eax
80102a00:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a03:	75 0e                	jne    80102a13 <iderw+0xb0>
    idestart(b);
80102a05:	83 ec 0c             	sub    $0xc,%esp
80102a08:	ff 75 08             	pushl  0x8(%ebp)
80102a0b:	e8 5d fd ff ff       	call   8010276d <idestart>
80102a10:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a13:	eb 13                	jmp    80102a28 <iderw+0xc5>
    sleep(b, &idelock);
80102a15:	83 ec 08             	sub    $0x8,%esp
80102a18:	68 60 b6 10 80       	push   $0x8010b660
80102a1d:	ff 75 08             	pushl  0x8(%ebp)
80102a20:	e8 0d 23 00 00       	call   80104d32 <sleep>
80102a25:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a28:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2b:	8b 00                	mov    (%eax),%eax
80102a2d:	83 e0 06             	and    $0x6,%eax
80102a30:	83 f8 02             	cmp    $0x2,%eax
80102a33:	75 e0                	jne    80102a15 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a35:	83 ec 0c             	sub    $0xc,%esp
80102a38:	68 60 b6 10 80       	push   $0x8010b660
80102a3d:	e8 8a 28 00 00       	call   801052cc <release>
80102a42:	83 c4 10             	add    $0x10,%esp
}
80102a45:	c9                   	leave  
80102a46:	c3                   	ret    

80102a47 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a47:	55                   	push   %ebp
80102a48:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a4a:	a1 14 23 11 80       	mov    0x80112314,%eax
80102a4f:	8b 55 08             	mov    0x8(%ebp),%edx
80102a52:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a54:	a1 14 23 11 80       	mov    0x80112314,%eax
80102a59:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a5c:	5d                   	pop    %ebp
80102a5d:	c3                   	ret    

80102a5e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a5e:	55                   	push   %ebp
80102a5f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a61:	a1 14 23 11 80       	mov    0x80112314,%eax
80102a66:	8b 55 08             	mov    0x8(%ebp),%edx
80102a69:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a6b:	a1 14 23 11 80       	mov    0x80112314,%eax
80102a70:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a73:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a76:	5d                   	pop    %ebp
80102a77:	c3                   	ret    

80102a78 <ioapicinit>:

void
ioapicinit(void)
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a7e:	a1 84 24 11 80       	mov    0x80112484,%eax
80102a83:	85 c0                	test   %eax,%eax
80102a85:	75 05                	jne    80102a8c <ioapicinit+0x14>
    return;
80102a87:	e9 9e 00 00 00       	jmp    80102b2a <ioapicinit+0xb2>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a8c:	c7 05 14 23 11 80 00 	movl   $0xfec00000,0x80112314
80102a93:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a96:	6a 01                	push   $0x1
80102a98:	e8 aa ff ff ff       	call   80102a47 <ioapicread>
80102a9d:	83 c4 04             	add    $0x4,%esp
80102aa0:	c1 e8 10             	shr    $0x10,%eax
80102aa3:	25 ff 00 00 00       	and    $0xff,%eax
80102aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102aab:	6a 00                	push   $0x0
80102aad:	e8 95 ff ff ff       	call   80102a47 <ioapicread>
80102ab2:	83 c4 04             	add    $0x4,%esp
80102ab5:	c1 e8 18             	shr    $0x18,%eax
80102ab8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102abb:	0f b6 05 80 24 11 80 	movzbl 0x80112480,%eax
80102ac2:	0f b6 c0             	movzbl %al,%eax
80102ac5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102ac8:	74 10                	je     80102ada <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aca:	83 ec 0c             	sub    $0xc,%esp
80102acd:	68 7c 89 10 80       	push   $0x8010897c
80102ad2:	e8 e8 d8 ff ff       	call   801003bf <cprintf>
80102ad7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ae1:	eb 3f                	jmp    80102b22 <ioapicinit+0xaa>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae6:	83 c0 20             	add    $0x20,%eax
80102ae9:	0d 00 00 01 00       	or     $0x10000,%eax
80102aee:	89 c2                	mov    %eax,%edx
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	83 c0 08             	add    $0x8,%eax
80102af6:	01 c0                	add    %eax,%eax
80102af8:	83 ec 08             	sub    $0x8,%esp
80102afb:	52                   	push   %edx
80102afc:	50                   	push   %eax
80102afd:	e8 5c ff ff ff       	call   80102a5e <ioapicwrite>
80102b02:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b08:	83 c0 08             	add    $0x8,%eax
80102b0b:	01 c0                	add    %eax,%eax
80102b0d:	83 c0 01             	add    $0x1,%eax
80102b10:	83 ec 08             	sub    $0x8,%esp
80102b13:	6a 00                	push   $0x0
80102b15:	50                   	push   %eax
80102b16:	e8 43 ff ff ff       	call   80102a5e <ioapicwrite>
80102b1b:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b25:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b28:	7e b9                	jle    80102ae3 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b2a:	c9                   	leave  
80102b2b:	c3                   	ret    

80102b2c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b2c:	55                   	push   %ebp
80102b2d:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b2f:	a1 84 24 11 80       	mov    0x80112484,%eax
80102b34:	85 c0                	test   %eax,%eax
80102b36:	75 02                	jne    80102b3a <ioapicenable+0xe>
    return;
80102b38:	eb 37                	jmp    80102b71 <ioapicenable+0x45>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	83 c0 20             	add    $0x20,%eax
80102b40:	89 c2                	mov    %eax,%edx
80102b42:	8b 45 08             	mov    0x8(%ebp),%eax
80102b45:	83 c0 08             	add    $0x8,%eax
80102b48:	01 c0                	add    %eax,%eax
80102b4a:	52                   	push   %edx
80102b4b:	50                   	push   %eax
80102b4c:	e8 0d ff ff ff       	call   80102a5e <ioapicwrite>
80102b51:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b57:	c1 e0 18             	shl    $0x18,%eax
80102b5a:	89 c2                	mov    %eax,%edx
80102b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5f:	83 c0 08             	add    $0x8,%eax
80102b62:	01 c0                	add    %eax,%eax
80102b64:	83 c0 01             	add    $0x1,%eax
80102b67:	52                   	push   %edx
80102b68:	50                   	push   %eax
80102b69:	e8 f0 fe ff ff       	call   80102a5e <ioapicwrite>
80102b6e:	83 c4 08             	add    $0x8,%esp
}
80102b71:	c9                   	leave  
80102b72:	c3                   	ret    

80102b73 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b73:	55                   	push   %ebp
80102b74:	89 e5                	mov    %esp,%ebp
80102b76:	8b 45 08             	mov    0x8(%ebp),%eax
80102b79:	05 00 00 00 80       	add    $0x80000000,%eax
80102b7e:	5d                   	pop    %ebp
80102b7f:	c3                   	ret    

80102b80 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b80:	55                   	push   %ebp
80102b81:	89 e5                	mov    %esp,%ebp
80102b83:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b86:	83 ec 08             	sub    $0x8,%esp
80102b89:	68 ae 89 10 80       	push   $0x801089ae
80102b8e:	68 20 23 11 80       	push   $0x80112320
80102b93:	e8 ad 26 00 00       	call   80105245 <initlock>
80102b98:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b9b:	c7 05 54 23 11 80 00 	movl   $0x0,0x80112354
80102ba2:	00 00 00 
  freerange(vstart, vend);
80102ba5:	83 ec 08             	sub    $0x8,%esp
80102ba8:	ff 75 0c             	pushl  0xc(%ebp)
80102bab:	ff 75 08             	pushl  0x8(%ebp)
80102bae:	e8 28 00 00 00       	call   80102bdb <freerange>
80102bb3:	83 c4 10             	add    $0x10,%esp
}
80102bb6:	c9                   	leave  
80102bb7:	c3                   	ret    

80102bb8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bb8:	55                   	push   %ebp
80102bb9:	89 e5                	mov    %esp,%ebp
80102bbb:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102bbe:	83 ec 08             	sub    $0x8,%esp
80102bc1:	ff 75 0c             	pushl  0xc(%ebp)
80102bc4:	ff 75 08             	pushl  0x8(%ebp)
80102bc7:	e8 0f 00 00 00       	call   80102bdb <freerange>
80102bcc:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bcf:	c7 05 54 23 11 80 01 	movl   $0x1,0x80112354
80102bd6:	00 00 00 
}
80102bd9:	c9                   	leave  
80102bda:	c3                   	ret    

80102bdb <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bdb:	55                   	push   %ebp
80102bdc:	89 e5                	mov    %esp,%ebp
80102bde:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102be1:	8b 45 08             	mov    0x8(%ebp),%eax
80102be4:	05 ff 0f 00 00       	add    $0xfff,%eax
80102be9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bf1:	eb 15                	jmp    80102c08 <freerange+0x2d>
    kfree(p);
80102bf3:	83 ec 0c             	sub    $0xc,%esp
80102bf6:	ff 75 f4             	pushl  -0xc(%ebp)
80102bf9:	e8 19 00 00 00       	call   80102c17 <kfree>
80102bfe:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c01:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0b:	05 00 10 00 00       	add    $0x1000,%eax
80102c10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c13:	76 de                	jbe    80102bf3 <freerange+0x18>
    kfree(p);
}
80102c15:	c9                   	leave  
80102c16:	c3                   	ret    

80102c17 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c17:	55                   	push   %ebp
80102c18:	89 e5                	mov    %esp,%ebp
80102c1a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c20:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c25:	85 c0                	test   %eax,%eax
80102c27:	75 1b                	jne    80102c44 <kfree+0x2d>
80102c29:	81 7d 08 dc 56 11 80 	cmpl   $0x801156dc,0x8(%ebp)
80102c30:	72 12                	jb     80102c44 <kfree+0x2d>
80102c32:	ff 75 08             	pushl  0x8(%ebp)
80102c35:	e8 39 ff ff ff       	call   80102b73 <v2p>
80102c3a:	83 c4 04             	add    $0x4,%esp
80102c3d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c42:	76 0d                	jbe    80102c51 <kfree+0x3a>
    panic("kfree");
80102c44:	83 ec 0c             	sub    $0xc,%esp
80102c47:	68 b3 89 10 80       	push   $0x801089b3
80102c4c:	e8 0b d9 ff ff       	call   8010055c <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c51:	83 ec 04             	sub    $0x4,%esp
80102c54:	68 00 10 00 00       	push   $0x1000
80102c59:	6a 01                	push   $0x1
80102c5b:	ff 75 08             	pushl  0x8(%ebp)
80102c5e:	e8 5f 28 00 00       	call   801054c2 <memset>
80102c63:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c66:	a1 54 23 11 80       	mov    0x80112354,%eax
80102c6b:	85 c0                	test   %eax,%eax
80102c6d:	74 10                	je     80102c7f <kfree+0x68>
    acquire(&kmem.lock);
80102c6f:	83 ec 0c             	sub    $0xc,%esp
80102c72:	68 20 23 11 80       	push   $0x80112320
80102c77:	e8 ea 25 00 00       	call   80105266 <acquire>
80102c7c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c85:	8b 15 58 23 11 80    	mov    0x80112358,%edx
80102c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c93:	a3 58 23 11 80       	mov    %eax,0x80112358
  if(kmem.use_lock)
80102c98:	a1 54 23 11 80       	mov    0x80112354,%eax
80102c9d:	85 c0                	test   %eax,%eax
80102c9f:	74 10                	je     80102cb1 <kfree+0x9a>
    release(&kmem.lock);
80102ca1:	83 ec 0c             	sub    $0xc,%esp
80102ca4:	68 20 23 11 80       	push   $0x80112320
80102ca9:	e8 1e 26 00 00       	call   801052cc <release>
80102cae:	83 c4 10             	add    $0x10,%esp
}
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
80102cb6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102cb9:	a1 54 23 11 80       	mov    0x80112354,%eax
80102cbe:	85 c0                	test   %eax,%eax
80102cc0:	74 10                	je     80102cd2 <kalloc+0x1f>
    acquire(&kmem.lock);
80102cc2:	83 ec 0c             	sub    $0xc,%esp
80102cc5:	68 20 23 11 80       	push   $0x80112320
80102cca:	e8 97 25 00 00       	call   80105266 <acquire>
80102ccf:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cd2:	a1 58 23 11 80       	mov    0x80112358,%eax
80102cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cde:	74 0a                	je     80102cea <kalloc+0x37>
    kmem.freelist = r->next;
80102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce3:	8b 00                	mov    (%eax),%eax
80102ce5:	a3 58 23 11 80       	mov    %eax,0x80112358
  if(kmem.use_lock)
80102cea:	a1 54 23 11 80       	mov    0x80112354,%eax
80102cef:	85 c0                	test   %eax,%eax
80102cf1:	74 10                	je     80102d03 <kalloc+0x50>
    release(&kmem.lock);
80102cf3:	83 ec 0c             	sub    $0xc,%esp
80102cf6:	68 20 23 11 80       	push   $0x80112320
80102cfb:	e8 cc 25 00 00       	call   801052cc <release>
80102d00:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 14             	sub    $0x14,%esp
80102d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d11:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d15:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d19:	89 c2                	mov    %eax,%edx
80102d1b:	ec                   	in     (%dx),%al
80102d1c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d1f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d23:	c9                   	leave  
80102d24:	c3                   	ret    

80102d25 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d25:	55                   	push   %ebp
80102d26:	89 e5                	mov    %esp,%ebp
80102d28:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d2b:	6a 64                	push   $0x64
80102d2d:	e8 d6 ff ff ff       	call   80102d08 <inb>
80102d32:	83 c4 04             	add    $0x4,%esp
80102d35:	0f b6 c0             	movzbl %al,%eax
80102d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d3e:	83 e0 01             	and    $0x1,%eax
80102d41:	85 c0                	test   %eax,%eax
80102d43:	75 0a                	jne    80102d4f <kbdgetc+0x2a>
    return -1;
80102d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d4a:	e9 23 01 00 00       	jmp    80102e72 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d4f:	6a 60                	push   $0x60
80102d51:	e8 b2 ff ff ff       	call   80102d08 <inb>
80102d56:	83 c4 04             	add    $0x4,%esp
80102d59:	0f b6 c0             	movzbl %al,%eax
80102d5c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d5f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d66:	75 17                	jne    80102d7f <kbdgetc+0x5a>
    shift |= E0ESC;
80102d68:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102d6d:	83 c8 40             	or     $0x40,%eax
80102d70:	a3 9c b6 10 80       	mov    %eax,0x8010b69c
    return 0;
80102d75:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7a:	e9 f3 00 00 00       	jmp    80102e72 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d82:	25 80 00 00 00       	and    $0x80,%eax
80102d87:	85 c0                	test   %eax,%eax
80102d89:	74 45                	je     80102dd0 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d8b:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102d90:	83 e0 40             	and    $0x40,%eax
80102d93:	85 c0                	test   %eax,%eax
80102d95:	75 08                	jne    80102d9f <kbdgetc+0x7a>
80102d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d9a:	83 e0 7f             	and    $0x7f,%eax
80102d9d:	eb 03                	jmp    80102da2 <kbdgetc+0x7d>
80102d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102da5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da8:	05 40 90 10 80       	add    $0x80109040,%eax
80102dad:	0f b6 00             	movzbl (%eax),%eax
80102db0:	83 c8 40             	or     $0x40,%eax
80102db3:	0f b6 c0             	movzbl %al,%eax
80102db6:	f7 d0                	not    %eax
80102db8:	89 c2                	mov    %eax,%edx
80102dba:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102dbf:	21 d0                	and    %edx,%eax
80102dc1:	a3 9c b6 10 80       	mov    %eax,0x8010b69c
    return 0;
80102dc6:	b8 00 00 00 00       	mov    $0x0,%eax
80102dcb:	e9 a2 00 00 00       	jmp    80102e72 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102dd0:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102dd5:	83 e0 40             	and    $0x40,%eax
80102dd8:	85 c0                	test   %eax,%eax
80102dda:	74 14                	je     80102df0 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ddc:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102de3:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102de8:	83 e0 bf             	and    $0xffffffbf,%eax
80102deb:	a3 9c b6 10 80       	mov    %eax,0x8010b69c
  }

  shift |= shiftcode[data];
80102df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df3:	05 40 90 10 80       	add    $0x80109040,%eax
80102df8:	0f b6 00             	movzbl (%eax),%eax
80102dfb:	0f b6 d0             	movzbl %al,%edx
80102dfe:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102e03:	09 d0                	or     %edx,%eax
80102e05:	a3 9c b6 10 80       	mov    %eax,0x8010b69c
  shift ^= togglecode[data];
80102e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0d:	05 40 91 10 80       	add    $0x80109140,%eax
80102e12:	0f b6 00             	movzbl (%eax),%eax
80102e15:	0f b6 d0             	movzbl %al,%edx
80102e18:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102e1d:	31 d0                	xor    %edx,%eax
80102e1f:	a3 9c b6 10 80       	mov    %eax,0x8010b69c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e24:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102e29:	83 e0 03             	and    $0x3,%eax
80102e2c:	8b 14 85 40 95 10 80 	mov    -0x7fef6ac0(,%eax,4),%edx
80102e33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e36:	01 d0                	add    %edx,%eax
80102e38:	0f b6 00             	movzbl (%eax),%eax
80102e3b:	0f b6 c0             	movzbl %al,%eax
80102e3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e41:	a1 9c b6 10 80       	mov    0x8010b69c,%eax
80102e46:	83 e0 08             	and    $0x8,%eax
80102e49:	85 c0                	test   %eax,%eax
80102e4b:	74 22                	je     80102e6f <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e4d:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e51:	76 0c                	jbe    80102e5f <kbdgetc+0x13a>
80102e53:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e57:	77 06                	ja     80102e5f <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e59:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e5d:	eb 10                	jmp    80102e6f <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e5f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e63:	76 0a                	jbe    80102e6f <kbdgetc+0x14a>
80102e65:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e69:	77 04                	ja     80102e6f <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e6b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e72:	c9                   	leave  
80102e73:	c3                   	ret    

80102e74 <kbdintr>:

void
kbdintr(void)
{
80102e74:	55                   	push   %ebp
80102e75:	89 e5                	mov    %esp,%ebp
80102e77:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e7a:	83 ec 0c             	sub    $0xc,%esp
80102e7d:	68 25 2d 10 80       	push   $0x80102d25
80102e82:	e8 4a d9 ff ff       	call   801007d1 <consoleintr>
80102e87:	83 c4 10             	add    $0x10,%esp
}
80102e8a:	c9                   	leave  
80102e8b:	c3                   	ret    

80102e8c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
80102e8f:	83 ec 14             	sub    $0x14,%esp
80102e92:	8b 45 08             	mov    0x8(%ebp),%eax
80102e95:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e99:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e9d:	89 c2                	mov    %eax,%edx
80102e9f:	ec                   	in     (%dx),%al
80102ea0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ea3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ea7:	c9                   	leave  
80102ea8:	c3                   	ret    

80102ea9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ea9:	55                   	push   %ebp
80102eaa:	89 e5                	mov    %esp,%ebp
80102eac:	83 ec 08             	sub    $0x8,%esp
80102eaf:	8b 55 08             	mov    0x8(%ebp),%edx
80102eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102eb9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ebc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ec0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ec4:	ee                   	out    %al,(%dx)
}
80102ec5:	c9                   	leave  
80102ec6:	c3                   	ret    

80102ec7 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102ec7:	55                   	push   %ebp
80102ec8:	89 e5                	mov    %esp,%ebp
80102eca:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102ecd:	9c                   	pushf  
80102ece:	58                   	pop    %eax
80102ecf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102ed2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102ed5:	c9                   	leave  
80102ed6:	c3                   	ret    

80102ed7 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ed7:	55                   	push   %ebp
80102ed8:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102eda:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80102edf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ee2:	c1 e2 02             	shl    $0x2,%edx
80102ee5:	01 c2                	add    %eax,%edx
80102ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eea:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eec:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80102ef1:	83 c0 20             	add    $0x20,%eax
80102ef4:	8b 00                	mov    (%eax),%eax
}
80102ef6:	5d                   	pop    %ebp
80102ef7:	c3                   	ret    

80102ef8 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ef8:	55                   	push   %ebp
80102ef9:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102efb:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80102f00:	85 c0                	test   %eax,%eax
80102f02:	75 05                	jne    80102f09 <lapicinit+0x11>
    return;
80102f04:	e9 09 01 00 00       	jmp    80103012 <lapicinit+0x11a>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f09:	68 3f 01 00 00       	push   $0x13f
80102f0e:	6a 3c                	push   $0x3c
80102f10:	e8 c2 ff ff ff       	call   80102ed7 <lapicw>
80102f15:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f18:	6a 0b                	push   $0xb
80102f1a:	68 f8 00 00 00       	push   $0xf8
80102f1f:	e8 b3 ff ff ff       	call   80102ed7 <lapicw>
80102f24:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f27:	68 20 00 02 00       	push   $0x20020
80102f2c:	68 c8 00 00 00       	push   $0xc8
80102f31:	e8 a1 ff ff ff       	call   80102ed7 <lapicw>
80102f36:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f39:	68 80 96 98 00       	push   $0x989680
80102f3e:	68 e0 00 00 00       	push   $0xe0
80102f43:	e8 8f ff ff ff       	call   80102ed7 <lapicw>
80102f48:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d4 00 00 00       	push   $0xd4
80102f55:	e8 7d ff ff ff       	call   80102ed7 <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f5d:	68 00 00 01 00       	push   $0x10000
80102f62:	68 d8 00 00 00       	push   $0xd8
80102f67:	e8 6b ff ff ff       	call   80102ed7 <lapicw>
80102f6c:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f6f:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80102f74:	83 c0 30             	add    $0x30,%eax
80102f77:	8b 00                	mov    (%eax),%eax
80102f79:	c1 e8 10             	shr    $0x10,%eax
80102f7c:	0f b6 c0             	movzbl %al,%eax
80102f7f:	83 f8 03             	cmp    $0x3,%eax
80102f82:	76 12                	jbe    80102f96 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f84:	68 00 00 01 00       	push   $0x10000
80102f89:	68 d0 00 00 00       	push   $0xd0
80102f8e:	e8 44 ff ff ff       	call   80102ed7 <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f96:	6a 33                	push   $0x33
80102f98:	68 dc 00 00 00       	push   $0xdc
80102f9d:	e8 35 ff ff ff       	call   80102ed7 <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fa5:	6a 00                	push   $0x0
80102fa7:	68 a0 00 00 00       	push   $0xa0
80102fac:	e8 26 ff ff ff       	call   80102ed7 <lapicw>
80102fb1:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102fb4:	6a 00                	push   $0x0
80102fb6:	68 a0 00 00 00       	push   $0xa0
80102fbb:	e8 17 ff ff ff       	call   80102ed7 <lapicw>
80102fc0:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fc3:	6a 00                	push   $0x0
80102fc5:	6a 2c                	push   $0x2c
80102fc7:	e8 0b ff ff ff       	call   80102ed7 <lapicw>
80102fcc:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fcf:	6a 00                	push   $0x0
80102fd1:	68 c4 00 00 00       	push   $0xc4
80102fd6:	e8 fc fe ff ff       	call   80102ed7 <lapicw>
80102fdb:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fde:	68 00 85 08 00       	push   $0x88500
80102fe3:	68 c0 00 00 00       	push   $0xc0
80102fe8:	e8 ea fe ff ff       	call   80102ed7 <lapicw>
80102fed:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ff0:	90                   	nop
80102ff1:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80102ff6:	05 00 03 00 00       	add    $0x300,%eax
80102ffb:	8b 00                	mov    (%eax),%eax
80102ffd:	25 00 10 00 00       	and    $0x1000,%eax
80103002:	85 c0                	test   %eax,%eax
80103004:	75 eb                	jne    80102ff1 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103006:	6a 00                	push   $0x0
80103008:	6a 20                	push   $0x20
8010300a:	e8 c8 fe ff ff       	call   80102ed7 <lapicw>
8010300f:	83 c4 08             	add    $0x8,%esp
}
80103012:	c9                   	leave  
80103013:	c3                   	ret    

80103014 <cpunum>:

int
cpunum(void)
{
80103014:	55                   	push   %ebp
80103015:	89 e5                	mov    %esp,%ebp
80103017:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010301a:	e8 a8 fe ff ff       	call   80102ec7 <readeflags>
8010301f:	25 00 02 00 00       	and    $0x200,%eax
80103024:	85 c0                	test   %eax,%eax
80103026:	74 26                	je     8010304e <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103028:	a1 a0 b6 10 80       	mov    0x8010b6a0,%eax
8010302d:	8d 50 01             	lea    0x1(%eax),%edx
80103030:	89 15 a0 b6 10 80    	mov    %edx,0x8010b6a0
80103036:	85 c0                	test   %eax,%eax
80103038:	75 14                	jne    8010304e <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010303a:	8b 45 04             	mov    0x4(%ebp),%eax
8010303d:	83 ec 08             	sub    $0x8,%esp
80103040:	50                   	push   %eax
80103041:	68 bc 89 10 80       	push   $0x801089bc
80103046:	e8 74 d3 ff ff       	call   801003bf <cprintf>
8010304b:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010304e:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80103053:	85 c0                	test   %eax,%eax
80103055:	74 0f                	je     80103066 <cpunum+0x52>
    return lapic[ID]>>24;
80103057:	a1 5c 23 11 80       	mov    0x8011235c,%eax
8010305c:	83 c0 20             	add    $0x20,%eax
8010305f:	8b 00                	mov    (%eax),%eax
80103061:	c1 e8 18             	shr    $0x18,%eax
80103064:	eb 05                	jmp    8010306b <cpunum+0x57>
  return 0;
80103066:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010306b:	c9                   	leave  
8010306c:	c3                   	ret    

8010306d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010306d:	55                   	push   %ebp
8010306e:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103070:	a1 5c 23 11 80       	mov    0x8011235c,%eax
80103075:	85 c0                	test   %eax,%eax
80103077:	74 0c                	je     80103085 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103079:	6a 00                	push   $0x0
8010307b:	6a 2c                	push   $0x2c
8010307d:	e8 55 fe ff ff       	call   80102ed7 <lapicw>
80103082:	83 c4 08             	add    $0x8,%esp
}
80103085:	c9                   	leave  
80103086:	c3                   	ret    

80103087 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103087:	55                   	push   %ebp
80103088:	89 e5                	mov    %esp,%ebp
}
8010308a:	5d                   	pop    %ebp
8010308b:	c3                   	ret    

8010308c <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010308c:	55                   	push   %ebp
8010308d:	89 e5                	mov    %esp,%ebp
8010308f:	83 ec 14             	sub    $0x14,%esp
80103092:	8b 45 08             	mov    0x8(%ebp),%eax
80103095:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103098:	6a 0f                	push   $0xf
8010309a:	6a 70                	push   $0x70
8010309c:	e8 08 fe ff ff       	call   80102ea9 <outb>
801030a1:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030a4:	6a 0a                	push   $0xa
801030a6:	6a 71                	push   $0x71
801030a8:	e8 fc fd ff ff       	call   80102ea9 <outb>
801030ad:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030b0:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ba:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030c2:	83 c0 02             	add    $0x2,%eax
801030c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801030c8:	c1 ea 04             	shr    $0x4,%edx
801030cb:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030ce:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d2:	c1 e0 18             	shl    $0x18,%eax
801030d5:	50                   	push   %eax
801030d6:	68 c4 00 00 00       	push   $0xc4
801030db:	e8 f7 fd ff ff       	call   80102ed7 <lapicw>
801030e0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030e3:	68 00 c5 00 00       	push   $0xc500
801030e8:	68 c0 00 00 00       	push   $0xc0
801030ed:	e8 e5 fd ff ff       	call   80102ed7 <lapicw>
801030f2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030f5:	68 c8 00 00 00       	push   $0xc8
801030fa:	e8 88 ff ff ff       	call   80103087 <microdelay>
801030ff:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103102:	68 00 85 00 00       	push   $0x8500
80103107:	68 c0 00 00 00       	push   $0xc0
8010310c:	e8 c6 fd ff ff       	call   80102ed7 <lapicw>
80103111:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103114:	6a 64                	push   $0x64
80103116:	e8 6c ff ff ff       	call   80103087 <microdelay>
8010311b:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010311e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103125:	eb 3d                	jmp    80103164 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103127:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010312b:	c1 e0 18             	shl    $0x18,%eax
8010312e:	50                   	push   %eax
8010312f:	68 c4 00 00 00       	push   $0xc4
80103134:	e8 9e fd ff ff       	call   80102ed7 <lapicw>
80103139:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010313c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010313f:	c1 e8 0c             	shr    $0xc,%eax
80103142:	80 cc 06             	or     $0x6,%ah
80103145:	50                   	push   %eax
80103146:	68 c0 00 00 00       	push   $0xc0
8010314b:	e8 87 fd ff ff       	call   80102ed7 <lapicw>
80103150:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103153:	68 c8 00 00 00       	push   $0xc8
80103158:	e8 2a ff ff ff       	call   80103087 <microdelay>
8010315d:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103160:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103164:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103168:	7e bd                	jle    80103127 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010316a:	c9                   	leave  
8010316b:	c3                   	ret    

8010316c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010316c:	55                   	push   %ebp
8010316d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010316f:	8b 45 08             	mov    0x8(%ebp),%eax
80103172:	0f b6 c0             	movzbl %al,%eax
80103175:	50                   	push   %eax
80103176:	6a 70                	push   $0x70
80103178:	e8 2c fd ff ff       	call   80102ea9 <outb>
8010317d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103180:	68 c8 00 00 00       	push   $0xc8
80103185:	e8 fd fe ff ff       	call   80103087 <microdelay>
8010318a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010318d:	6a 71                	push   $0x71
8010318f:	e8 f8 fc ff ff       	call   80102e8c <inb>
80103194:	83 c4 04             	add    $0x4,%esp
80103197:	0f b6 c0             	movzbl %al,%eax
}
8010319a:	c9                   	leave  
8010319b:	c3                   	ret    

8010319c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010319c:	55                   	push   %ebp
8010319d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010319f:	6a 00                	push   $0x0
801031a1:	e8 c6 ff ff ff       	call   8010316c <cmos_read>
801031a6:	83 c4 04             	add    $0x4,%esp
801031a9:	89 c2                	mov    %eax,%edx
801031ab:	8b 45 08             	mov    0x8(%ebp),%eax
801031ae:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031b0:	6a 02                	push   $0x2
801031b2:	e8 b5 ff ff ff       	call   8010316c <cmos_read>
801031b7:	83 c4 04             	add    $0x4,%esp
801031ba:	89 c2                	mov    %eax,%edx
801031bc:	8b 45 08             	mov    0x8(%ebp),%eax
801031bf:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801031c2:	6a 04                	push   $0x4
801031c4:	e8 a3 ff ff ff       	call   8010316c <cmos_read>
801031c9:	83 c4 04             	add    $0x4,%esp
801031cc:	89 c2                	mov    %eax,%edx
801031ce:	8b 45 08             	mov    0x8(%ebp),%eax
801031d1:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801031d4:	6a 07                	push   $0x7
801031d6:	e8 91 ff ff ff       	call   8010316c <cmos_read>
801031db:	83 c4 04             	add    $0x4,%esp
801031de:	89 c2                	mov    %eax,%edx
801031e0:	8b 45 08             	mov    0x8(%ebp),%eax
801031e3:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031e6:	6a 08                	push   $0x8
801031e8:	e8 7f ff ff ff       	call   8010316c <cmos_read>
801031ed:	83 c4 04             	add    $0x4,%esp
801031f0:	89 c2                	mov    %eax,%edx
801031f2:	8b 45 08             	mov    0x8(%ebp),%eax
801031f5:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031f8:	6a 09                	push   $0x9
801031fa:	e8 6d ff ff ff       	call   8010316c <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	89 c2                	mov    %eax,%edx
80103204:	8b 45 08             	mov    0x8(%ebp),%eax
80103207:	89 50 14             	mov    %edx,0x14(%eax)
}
8010320a:	c9                   	leave  
8010320b:	c3                   	ret    

8010320c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010320c:	55                   	push   %ebp
8010320d:	89 e5                	mov    %esp,%ebp
8010320f:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103212:	6a 0b                	push   $0xb
80103214:	e8 53 ff ff ff       	call   8010316c <cmos_read>
80103219:	83 c4 04             	add    $0x4,%esp
8010321c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010321f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103222:	83 e0 04             	and    $0x4,%eax
80103225:	85 c0                	test   %eax,%eax
80103227:	0f 94 c0             	sete   %al
8010322a:	0f b6 c0             	movzbl %al,%eax
8010322d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103230:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103233:	50                   	push   %eax
80103234:	e8 63 ff ff ff       	call   8010319c <fill_rtcdate>
80103239:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010323c:	6a 0a                	push   $0xa
8010323e:	e8 29 ff ff ff       	call   8010316c <cmos_read>
80103243:	83 c4 04             	add    $0x4,%esp
80103246:	25 80 00 00 00       	and    $0x80,%eax
8010324b:	85 c0                	test   %eax,%eax
8010324d:	74 02                	je     80103251 <cmostime+0x45>
        continue;
8010324f:	eb 32                	jmp    80103283 <cmostime+0x77>
    fill_rtcdate(&t2);
80103251:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103254:	50                   	push   %eax
80103255:	e8 42 ff ff ff       	call   8010319c <fill_rtcdate>
8010325a:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010325d:	83 ec 04             	sub    $0x4,%esp
80103260:	6a 18                	push   $0x18
80103262:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103265:	50                   	push   %eax
80103266:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103269:	50                   	push   %eax
8010326a:	e8 ba 22 00 00       	call   80105529 <memcmp>
8010326f:	83 c4 10             	add    $0x10,%esp
80103272:	85 c0                	test   %eax,%eax
80103274:	75 0d                	jne    80103283 <cmostime+0x77>
      break;
80103276:	90                   	nop
  }

  // convert
  if (bcd) {
80103277:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010327b:	0f 84 b8 00 00 00    	je     80103339 <cmostime+0x12d>
80103281:	eb 02                	jmp    80103285 <cmostime+0x79>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103283:	eb ab                	jmp    80103230 <cmostime+0x24>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103285:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103288:	c1 e8 04             	shr    $0x4,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	89 d0                	mov    %edx,%eax
8010328f:	c1 e0 02             	shl    $0x2,%eax
80103292:	01 d0                	add    %edx,%eax
80103294:	01 c0                	add    %eax,%eax
80103296:	89 c2                	mov    %eax,%edx
80103298:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010329b:	83 e0 0f             	and    $0xf,%eax
8010329e:	01 d0                	add    %edx,%eax
801032a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032a6:	c1 e8 04             	shr    $0x4,%eax
801032a9:	89 c2                	mov    %eax,%edx
801032ab:	89 d0                	mov    %edx,%eax
801032ad:	c1 e0 02             	shl    $0x2,%eax
801032b0:	01 d0                	add    %edx,%eax
801032b2:	01 c0                	add    %eax,%eax
801032b4:	89 c2                	mov    %eax,%edx
801032b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032b9:	83 e0 0f             	and    $0xf,%eax
801032bc:	01 d0                	add    %edx,%eax
801032be:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032c4:	c1 e8 04             	shr    $0x4,%eax
801032c7:	89 c2                	mov    %eax,%edx
801032c9:	89 d0                	mov    %edx,%eax
801032cb:	c1 e0 02             	shl    $0x2,%eax
801032ce:	01 d0                	add    %edx,%eax
801032d0:	01 c0                	add    %eax,%eax
801032d2:	89 c2                	mov    %eax,%edx
801032d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032d7:	83 e0 0f             	and    $0xf,%eax
801032da:	01 d0                	add    %edx,%eax
801032dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032e2:	c1 e8 04             	shr    $0x4,%eax
801032e5:	89 c2                	mov    %eax,%edx
801032e7:	89 d0                	mov    %edx,%eax
801032e9:	c1 e0 02             	shl    $0x2,%eax
801032ec:	01 d0                	add    %edx,%eax
801032ee:	01 c0                	add    %eax,%eax
801032f0:	89 c2                	mov    %eax,%edx
801032f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032f5:	83 e0 0f             	and    $0xf,%eax
801032f8:	01 d0                	add    %edx,%eax
801032fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103300:	c1 e8 04             	shr    $0x4,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	89 d0                	mov    %edx,%eax
80103307:	c1 e0 02             	shl    $0x2,%eax
8010330a:	01 d0                	add    %edx,%eax
8010330c:	01 c0                	add    %eax,%eax
8010330e:	89 c2                	mov    %eax,%edx
80103310:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103313:	83 e0 0f             	and    $0xf,%eax
80103316:	01 d0                	add    %edx,%eax
80103318:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010331b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010331e:	c1 e8 04             	shr    $0x4,%eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	89 d0                	mov    %edx,%eax
80103325:	c1 e0 02             	shl    $0x2,%eax
80103328:	01 d0                	add    %edx,%eax
8010332a:	01 c0                	add    %eax,%eax
8010332c:	89 c2                	mov    %eax,%edx
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	83 e0 0f             	and    $0xf,%eax
80103334:	01 d0                	add    %edx,%eax
80103336:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103339:	8b 45 08             	mov    0x8(%ebp),%eax
8010333c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010333f:	89 10                	mov    %edx,(%eax)
80103341:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103344:	89 50 04             	mov    %edx,0x4(%eax)
80103347:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010334a:	89 50 08             	mov    %edx,0x8(%eax)
8010334d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103350:	89 50 0c             	mov    %edx,0xc(%eax)
80103353:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103356:	89 50 10             	mov    %edx,0x10(%eax)
80103359:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010335c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010335f:	8b 45 08             	mov    0x8(%ebp),%eax
80103362:	8b 40 14             	mov    0x14(%eax),%eax
80103365:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010336b:	8b 45 08             	mov    0x8(%ebp),%eax
8010336e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103371:	c9                   	leave  
80103372:	c3                   	ret    

80103373 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103373:	55                   	push   %ebp
80103374:	89 e5                	mov    %esp,%ebp
80103376:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103379:	83 ec 08             	sub    $0x8,%esp
8010337c:	68 e8 89 10 80       	push   $0x801089e8
80103381:	68 80 23 11 80       	push   $0x80112380
80103386:	e8 ba 1e 00 00       	call   80105245 <initlock>
8010338b:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
8010338e:	83 ec 08             	sub    $0x8,%esp
80103391:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103394:	50                   	push   %eax
80103395:	6a 01                	push   $0x1
80103397:	e8 ae df ff ff       	call   8010134a <readsb>
8010339c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
8010339f:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a5:	29 c2                	sub    %eax,%edx
801033a7:	89 d0                	mov    %edx,%eax
801033a9:	a3 b4 23 11 80       	mov    %eax,0x801123b4
  log.size = sb.nlog;
801033ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b1:	a3 b8 23 11 80       	mov    %eax,0x801123b8
  log.dev = ROOTDEV;
801033b6:	c7 05 c4 23 11 80 01 	movl   $0x1,0x801123c4
801033bd:	00 00 00 
  recover_from_log();
801033c0:	e8 ae 01 00 00       	call   80103573 <recover_from_log>
}
801033c5:	c9                   	leave  
801033c6:	c3                   	ret    

801033c7 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033c7:	55                   	push   %ebp
801033c8:	89 e5                	mov    %esp,%ebp
801033ca:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033d4:	e9 95 00 00 00       	jmp    8010346e <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033d9:	8b 15 b4 23 11 80    	mov    0x801123b4,%edx
801033df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033e2:	01 d0                	add    %edx,%eax
801033e4:	83 c0 01             	add    $0x1,%eax
801033e7:	89 c2                	mov    %eax,%edx
801033e9:	a1 c4 23 11 80       	mov    0x801123c4,%eax
801033ee:	83 ec 08             	sub    $0x8,%esp
801033f1:	52                   	push   %edx
801033f2:	50                   	push   %eax
801033f3:	e8 bc cd ff ff       	call   801001b4 <bread>
801033f8:	83 c4 10             	add    $0x10,%esp
801033fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103401:	83 c0 10             	add    $0x10,%eax
80103404:	8b 04 85 8c 23 11 80 	mov    -0x7feedc74(,%eax,4),%eax
8010340b:	89 c2                	mov    %eax,%edx
8010340d:	a1 c4 23 11 80       	mov    0x801123c4,%eax
80103412:	83 ec 08             	sub    $0x8,%esp
80103415:	52                   	push   %edx
80103416:	50                   	push   %eax
80103417:	e8 98 cd ff ff       	call   801001b4 <bread>
8010341c:	83 c4 10             	add    $0x10,%esp
8010341f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103425:	8d 50 18             	lea    0x18(%eax),%edx
80103428:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342b:	83 c0 18             	add    $0x18,%eax
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	68 00 02 00 00       	push   $0x200
80103436:	52                   	push   %edx
80103437:	50                   	push   %eax
80103438:	e8 44 21 00 00       	call   80105581 <memmove>
8010343d:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103440:	83 ec 0c             	sub    $0xc,%esp
80103443:	ff 75 ec             	pushl  -0x14(%ebp)
80103446:	e8 a2 cd ff ff       	call   801001ed <bwrite>
8010344b:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010344e:	83 ec 0c             	sub    $0xc,%esp
80103451:	ff 75 f0             	pushl  -0x10(%ebp)
80103454:	e8 d2 cd ff ff       	call   8010022b <brelse>
80103459:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010345c:	83 ec 0c             	sub    $0xc,%esp
8010345f:	ff 75 ec             	pushl  -0x14(%ebp)
80103462:	e8 c4 cd ff ff       	call   8010022b <brelse>
80103467:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010346a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346e:	a1 c8 23 11 80       	mov    0x801123c8,%eax
80103473:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103476:	0f 8f 5d ff ff ff    	jg     801033d9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010347c:	c9                   	leave  
8010347d:	c3                   	ret    

8010347e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010347e:	55                   	push   %ebp
8010347f:	89 e5                	mov    %esp,%ebp
80103481:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103484:	a1 b4 23 11 80       	mov    0x801123b4,%eax
80103489:	89 c2                	mov    %eax,%edx
8010348b:	a1 c4 23 11 80       	mov    0x801123c4,%eax
80103490:	83 ec 08             	sub    $0x8,%esp
80103493:	52                   	push   %edx
80103494:	50                   	push   %eax
80103495:	e8 1a cd ff ff       	call   801001b4 <bread>
8010349a:	83 c4 10             	add    $0x10,%esp
8010349d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a3:	83 c0 18             	add    $0x18,%eax
801034a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ac:	8b 00                	mov    (%eax),%eax
801034ae:	a3 c8 23 11 80       	mov    %eax,0x801123c8
  for (i = 0; i < log.lh.n; i++) {
801034b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ba:	eb 1b                	jmp    801034d7 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801034bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c2:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c9:	83 c2 10             	add    $0x10,%edx
801034cc:	89 04 95 8c 23 11 80 	mov    %eax,-0x7feedc74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d7:	a1 c8 23 11 80       	mov    0x801123c8,%eax
801034dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034df:	7f db                	jg     801034bc <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034e1:	83 ec 0c             	sub    $0xc,%esp
801034e4:	ff 75 f0             	pushl  -0x10(%ebp)
801034e7:	e8 3f cd ff ff       	call   8010022b <brelse>
801034ec:	83 c4 10             	add    $0x10,%esp
}
801034ef:	c9                   	leave  
801034f0:	c3                   	ret    

801034f1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034f1:	55                   	push   %ebp
801034f2:	89 e5                	mov    %esp,%ebp
801034f4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034f7:	a1 b4 23 11 80       	mov    0x801123b4,%eax
801034fc:	89 c2                	mov    %eax,%edx
801034fe:	a1 c4 23 11 80       	mov    0x801123c4,%eax
80103503:	83 ec 08             	sub    $0x8,%esp
80103506:	52                   	push   %edx
80103507:	50                   	push   %eax
80103508:	e8 a7 cc ff ff       	call   801001b4 <bread>
8010350d:	83 c4 10             	add    $0x10,%esp
80103510:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103516:	83 c0 18             	add    $0x18,%eax
80103519:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010351c:	8b 15 c8 23 11 80    	mov    0x801123c8,%edx
80103522:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103525:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103527:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010352e:	eb 1b                	jmp    8010354b <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103533:	83 c0 10             	add    $0x10,%eax
80103536:	8b 0c 85 8c 23 11 80 	mov    -0x7feedc74(,%eax,4),%ecx
8010353d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103540:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103543:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103547:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010354b:	a1 c8 23 11 80       	mov    0x801123c8,%eax
80103550:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103553:	7f db                	jg     80103530 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103555:	83 ec 0c             	sub    $0xc,%esp
80103558:	ff 75 f0             	pushl  -0x10(%ebp)
8010355b:	e8 8d cc ff ff       	call   801001ed <bwrite>
80103560:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103563:	83 ec 0c             	sub    $0xc,%esp
80103566:	ff 75 f0             	pushl  -0x10(%ebp)
80103569:	e8 bd cc ff ff       	call   8010022b <brelse>
8010356e:	83 c4 10             	add    $0x10,%esp
}
80103571:	c9                   	leave  
80103572:	c3                   	ret    

80103573 <recover_from_log>:

static void
recover_from_log(void)
{
80103573:	55                   	push   %ebp
80103574:	89 e5                	mov    %esp,%ebp
80103576:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103579:	e8 00 ff ff ff       	call   8010347e <read_head>
  install_trans(); // if committed, copy from log to disk
8010357e:	e8 44 fe ff ff       	call   801033c7 <install_trans>
  log.lh.n = 0;
80103583:	c7 05 c8 23 11 80 00 	movl   $0x0,0x801123c8
8010358a:	00 00 00 
  write_head(); // clear the log
8010358d:	e8 5f ff ff ff       	call   801034f1 <write_head>
}
80103592:	c9                   	leave  
80103593:	c3                   	ret    

80103594 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103594:	55                   	push   %ebp
80103595:	89 e5                	mov    %esp,%ebp
80103597:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010359a:	83 ec 0c             	sub    $0xc,%esp
8010359d:	68 80 23 11 80       	push   $0x80112380
801035a2:	e8 bf 1c 00 00       	call   80105266 <acquire>
801035a7:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801035aa:	a1 c0 23 11 80       	mov    0x801123c0,%eax
801035af:	85 c0                	test   %eax,%eax
801035b1:	74 17                	je     801035ca <begin_op+0x36>
      sleep(&log, &log.lock);
801035b3:	83 ec 08             	sub    $0x8,%esp
801035b6:	68 80 23 11 80       	push   $0x80112380
801035bb:	68 80 23 11 80       	push   $0x80112380
801035c0:	e8 6d 17 00 00       	call   80104d32 <sleep>
801035c5:	83 c4 10             	add    $0x10,%esp
801035c8:	eb 54                	jmp    8010361e <begin_op+0x8a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035ca:	8b 0d c8 23 11 80    	mov    0x801123c8,%ecx
801035d0:	a1 bc 23 11 80       	mov    0x801123bc,%eax
801035d5:	8d 50 01             	lea    0x1(%eax),%edx
801035d8:	89 d0                	mov    %edx,%eax
801035da:	c1 e0 02             	shl    $0x2,%eax
801035dd:	01 d0                	add    %edx,%eax
801035df:	01 c0                	add    %eax,%eax
801035e1:	01 c8                	add    %ecx,%eax
801035e3:	83 f8 1e             	cmp    $0x1e,%eax
801035e6:	7e 17                	jle    801035ff <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035e8:	83 ec 08             	sub    $0x8,%esp
801035eb:	68 80 23 11 80       	push   $0x80112380
801035f0:	68 80 23 11 80       	push   $0x80112380
801035f5:	e8 38 17 00 00       	call   80104d32 <sleep>
801035fa:	83 c4 10             	add    $0x10,%esp
801035fd:	eb 1f                	jmp    8010361e <begin_op+0x8a>
    } else {
      log.outstanding += 1;
801035ff:	a1 bc 23 11 80       	mov    0x801123bc,%eax
80103604:	83 c0 01             	add    $0x1,%eax
80103607:	a3 bc 23 11 80       	mov    %eax,0x801123bc
      release(&log.lock);
8010360c:	83 ec 0c             	sub    $0xc,%esp
8010360f:	68 80 23 11 80       	push   $0x80112380
80103614:	e8 b3 1c 00 00       	call   801052cc <release>
80103619:	83 c4 10             	add    $0x10,%esp
      break;
8010361c:	eb 02                	jmp    80103620 <begin_op+0x8c>
    }
  }
8010361e:	eb 8a                	jmp    801035aa <begin_op+0x16>
}
80103620:	c9                   	leave  
80103621:	c3                   	ret    

80103622 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103622:	55                   	push   %ebp
80103623:	89 e5                	mov    %esp,%ebp
80103625:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103628:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010362f:	83 ec 0c             	sub    $0xc,%esp
80103632:	68 80 23 11 80       	push   $0x80112380
80103637:	e8 2a 1c 00 00       	call   80105266 <acquire>
8010363c:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010363f:	a1 bc 23 11 80       	mov    0x801123bc,%eax
80103644:	83 e8 01             	sub    $0x1,%eax
80103647:	a3 bc 23 11 80       	mov    %eax,0x801123bc
  if(log.committing)
8010364c:	a1 c0 23 11 80       	mov    0x801123c0,%eax
80103651:	85 c0                	test   %eax,%eax
80103653:	74 0d                	je     80103662 <end_op+0x40>
    panic("log.committing");
80103655:	83 ec 0c             	sub    $0xc,%esp
80103658:	68 ec 89 10 80       	push   $0x801089ec
8010365d:	e8 fa ce ff ff       	call   8010055c <panic>
  if(log.outstanding == 0){
80103662:	a1 bc 23 11 80       	mov    0x801123bc,%eax
80103667:	85 c0                	test   %eax,%eax
80103669:	75 13                	jne    8010367e <end_op+0x5c>
    do_commit = 1;
8010366b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103672:	c7 05 c0 23 11 80 01 	movl   $0x1,0x801123c0
80103679:	00 00 00 
8010367c:	eb 10                	jmp    8010368e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010367e:	83 ec 0c             	sub    $0xc,%esp
80103681:	68 80 23 11 80       	push   $0x80112380
80103686:	e8 90 17 00 00       	call   80104e1b <wakeup>
8010368b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010368e:	83 ec 0c             	sub    $0xc,%esp
80103691:	68 80 23 11 80       	push   $0x80112380
80103696:	e8 31 1c 00 00       	call   801052cc <release>
8010369b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010369e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036a2:	74 3f                	je     801036e3 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036a4:	e8 f3 00 00 00       	call   8010379c <commit>
    acquire(&log.lock);
801036a9:	83 ec 0c             	sub    $0xc,%esp
801036ac:	68 80 23 11 80       	push   $0x80112380
801036b1:	e8 b0 1b 00 00       	call   80105266 <acquire>
801036b6:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801036b9:	c7 05 c0 23 11 80 00 	movl   $0x0,0x801123c0
801036c0:	00 00 00 
    wakeup(&log);
801036c3:	83 ec 0c             	sub    $0xc,%esp
801036c6:	68 80 23 11 80       	push   $0x80112380
801036cb:	e8 4b 17 00 00       	call   80104e1b <wakeup>
801036d0:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	68 80 23 11 80       	push   $0x80112380
801036db:	e8 ec 1b 00 00       	call   801052cc <release>
801036e0:	83 c4 10             	add    $0x10,%esp
  }
}
801036e3:	c9                   	leave  
801036e4:	c3                   	ret    

801036e5 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036e5:	55                   	push   %ebp
801036e6:	89 e5                	mov    %esp,%ebp
801036e8:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036f2:	e9 95 00 00 00       	jmp    8010378c <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036f7:	8b 15 b4 23 11 80    	mov    0x801123b4,%edx
801036fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103700:	01 d0                	add    %edx,%eax
80103702:	83 c0 01             	add    $0x1,%eax
80103705:	89 c2                	mov    %eax,%edx
80103707:	a1 c4 23 11 80       	mov    0x801123c4,%eax
8010370c:	83 ec 08             	sub    $0x8,%esp
8010370f:	52                   	push   %edx
80103710:	50                   	push   %eax
80103711:	e8 9e ca ff ff       	call   801001b4 <bread>
80103716:	83 c4 10             	add    $0x10,%esp
80103719:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010371c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371f:	83 c0 10             	add    $0x10,%eax
80103722:	8b 04 85 8c 23 11 80 	mov    -0x7feedc74(,%eax,4),%eax
80103729:	89 c2                	mov    %eax,%edx
8010372b:	a1 c4 23 11 80       	mov    0x801123c4,%eax
80103730:	83 ec 08             	sub    $0x8,%esp
80103733:	52                   	push   %edx
80103734:	50                   	push   %eax
80103735:	e8 7a ca ff ff       	call   801001b4 <bread>
8010373a:	83 c4 10             	add    $0x10,%esp
8010373d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103740:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103743:	8d 50 18             	lea    0x18(%eax),%edx
80103746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103749:	83 c0 18             	add    $0x18,%eax
8010374c:	83 ec 04             	sub    $0x4,%esp
8010374f:	68 00 02 00 00       	push   $0x200
80103754:	52                   	push   %edx
80103755:	50                   	push   %eax
80103756:	e8 26 1e 00 00       	call   80105581 <memmove>
8010375b:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010375e:	83 ec 0c             	sub    $0xc,%esp
80103761:	ff 75 f0             	pushl  -0x10(%ebp)
80103764:	e8 84 ca ff ff       	call   801001ed <bwrite>
80103769:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010376c:	83 ec 0c             	sub    $0xc,%esp
8010376f:	ff 75 ec             	pushl  -0x14(%ebp)
80103772:	e8 b4 ca ff ff       	call   8010022b <brelse>
80103777:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010377a:	83 ec 0c             	sub    $0xc,%esp
8010377d:	ff 75 f0             	pushl  -0x10(%ebp)
80103780:	e8 a6 ca ff ff       	call   8010022b <brelse>
80103785:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103788:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010378c:	a1 c8 23 11 80       	mov    0x801123c8,%eax
80103791:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103794:	0f 8f 5d ff ff ff    	jg     801036f7 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010379a:	c9                   	leave  
8010379b:	c3                   	ret    

8010379c <commit>:

static void
commit()
{
8010379c:	55                   	push   %ebp
8010379d:	89 e5                	mov    %esp,%ebp
8010379f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037a2:	a1 c8 23 11 80       	mov    0x801123c8,%eax
801037a7:	85 c0                	test   %eax,%eax
801037a9:	7e 1e                	jle    801037c9 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037ab:	e8 35 ff ff ff       	call   801036e5 <write_log>
    write_head();    // Write header to disk -- the real commit
801037b0:	e8 3c fd ff ff       	call   801034f1 <write_head>
    install_trans(); // Now install writes to home locations
801037b5:	e8 0d fc ff ff       	call   801033c7 <install_trans>
    log.lh.n = 0; 
801037ba:	c7 05 c8 23 11 80 00 	movl   $0x0,0x801123c8
801037c1:	00 00 00 
    write_head();    // Erase the transaction from the log
801037c4:	e8 28 fd ff ff       	call   801034f1 <write_head>
  }
}
801037c9:	c9                   	leave  
801037ca:	c3                   	ret    

801037cb <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037cb:	55                   	push   %ebp
801037cc:	89 e5                	mov    %esp,%ebp
801037ce:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037d1:	a1 c8 23 11 80       	mov    0x801123c8,%eax
801037d6:	83 f8 1d             	cmp    $0x1d,%eax
801037d9:	7f 12                	jg     801037ed <log_write+0x22>
801037db:	a1 c8 23 11 80       	mov    0x801123c8,%eax
801037e0:	8b 15 b8 23 11 80    	mov    0x801123b8,%edx
801037e6:	83 ea 01             	sub    $0x1,%edx
801037e9:	39 d0                	cmp    %edx,%eax
801037eb:	7c 0d                	jl     801037fa <log_write+0x2f>
    panic("too big a transaction");
801037ed:	83 ec 0c             	sub    $0xc,%esp
801037f0:	68 fb 89 10 80       	push   $0x801089fb
801037f5:	e8 62 cd ff ff       	call   8010055c <panic>
  if (log.outstanding < 1)
801037fa:	a1 bc 23 11 80       	mov    0x801123bc,%eax
801037ff:	85 c0                	test   %eax,%eax
80103801:	7f 0d                	jg     80103810 <log_write+0x45>
    panic("log_write outside of trans");
80103803:	83 ec 0c             	sub    $0xc,%esp
80103806:	68 11 8a 10 80       	push   $0x80108a11
8010380b:	e8 4c cd ff ff       	call   8010055c <panic>

  acquire(&log.lock);
80103810:	83 ec 0c             	sub    $0xc,%esp
80103813:	68 80 23 11 80       	push   $0x80112380
80103818:	e8 49 1a 00 00       	call   80105266 <acquire>
8010381d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103820:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103827:	eb 1f                	jmp    80103848 <log_write+0x7d>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010382c:	83 c0 10             	add    $0x10,%eax
8010382f:	8b 04 85 8c 23 11 80 	mov    -0x7feedc74(,%eax,4),%eax
80103836:	89 c2                	mov    %eax,%edx
80103838:	8b 45 08             	mov    0x8(%ebp),%eax
8010383b:	8b 40 08             	mov    0x8(%eax),%eax
8010383e:	39 c2                	cmp    %eax,%edx
80103840:	75 02                	jne    80103844 <log_write+0x79>
      break;
80103842:	eb 0e                	jmp    80103852 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103844:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103848:	a1 c8 23 11 80       	mov    0x801123c8,%eax
8010384d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103850:	7f d7                	jg     80103829 <log_write+0x5e>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
80103852:	8b 45 08             	mov    0x8(%ebp),%eax
80103855:	8b 40 08             	mov    0x8(%eax),%eax
80103858:	89 c2                	mov    %eax,%edx
8010385a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010385d:	83 c0 10             	add    $0x10,%eax
80103860:	89 14 85 8c 23 11 80 	mov    %edx,-0x7feedc74(,%eax,4)
  if (i == log.lh.n)
80103867:	a1 c8 23 11 80       	mov    0x801123c8,%eax
8010386c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010386f:	75 0d                	jne    8010387e <log_write+0xb3>
    log.lh.n++;
80103871:	a1 c8 23 11 80       	mov    0x801123c8,%eax
80103876:	83 c0 01             	add    $0x1,%eax
80103879:	a3 c8 23 11 80       	mov    %eax,0x801123c8
  b->flags |= B_DIRTY; // prevent eviction
8010387e:	8b 45 08             	mov    0x8(%ebp),%eax
80103881:	8b 00                	mov    (%eax),%eax
80103883:	83 c8 04             	or     $0x4,%eax
80103886:	89 c2                	mov    %eax,%edx
80103888:	8b 45 08             	mov    0x8(%ebp),%eax
8010388b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010388d:	83 ec 0c             	sub    $0xc,%esp
80103890:	68 80 23 11 80       	push   $0x80112380
80103895:	e8 32 1a 00 00       	call   801052cc <release>
8010389a:	83 c4 10             	add    $0x10,%esp
}
8010389d:	c9                   	leave  
8010389e:	c3                   	ret    

8010389f <v2p>:
8010389f:	55                   	push   %ebp
801038a0:	89 e5                	mov    %esp,%ebp
801038a2:	8b 45 08             	mov    0x8(%ebp),%eax
801038a5:	05 00 00 00 80       	add    $0x80000000,%eax
801038aa:	5d                   	pop    %ebp
801038ab:	c3                   	ret    

801038ac <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801038ac:	55                   	push   %ebp
801038ad:	89 e5                	mov    %esp,%ebp
801038af:	8b 45 08             	mov    0x8(%ebp),%eax
801038b2:	05 00 00 00 80       	add    $0x80000000,%eax
801038b7:	5d                   	pop    %ebp
801038b8:	c3                   	ret    

801038b9 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038b9:	55                   	push   %ebp
801038ba:	89 e5                	mov    %esp,%ebp
801038bc:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038bf:	8b 55 08             	mov    0x8(%ebp),%edx
801038c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801038c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038c8:	f0 87 02             	lock xchg %eax,(%edx)
801038cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038d1:	c9                   	leave  
801038d2:	c3                   	ret    

801038d3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038d3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038d7:	83 e4 f0             	and    $0xfffffff0,%esp
801038da:	ff 71 fc             	pushl  -0x4(%ecx)
801038dd:	55                   	push   %ebp
801038de:	89 e5                	mov    %esp,%ebp
801038e0:	51                   	push   %ecx
801038e1:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038e4:	83 ec 08             	sub    $0x8,%esp
801038e7:	68 00 00 40 80       	push   $0x80400000
801038ec:	68 dc 56 11 80       	push   $0x801156dc
801038f1:	e8 8a f2 ff ff       	call   80102b80 <kinit1>
801038f6:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038f9:	e8 77 47 00 00       	call   80108075 <kvmalloc>
  mpinit();        // collect info about this machine
801038fe:	e8 4a 04 00 00       	call   80103d4d <mpinit>
  lapicinit();
80103903:	e8 f0 f5 ff ff       	call   80102ef8 <lapicinit>
  seginit();       // set up segments
80103908:	e8 10 41 00 00       	call   80107a1d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010390d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103913:	0f b6 00             	movzbl (%eax),%eax
80103916:	0f b6 c0             	movzbl %al,%eax
80103919:	83 ec 08             	sub    $0x8,%esp
8010391c:	50                   	push   %eax
8010391d:	68 2c 8a 10 80       	push   $0x80108a2c
80103922:	e8 98 ca ff ff       	call   801003bf <cprintf>
80103927:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010392a:	e8 6f 06 00 00       	call   80103f9e <picinit>
  ioapicinit();    // another interrupt controller
8010392f:	e8 44 f1 ff ff       	call   80102a78 <ioapicinit>
  procfsinit();
80103934:	e8 a9 18 00 00       	call   801051e2 <procfsinit>
  consoleinit();   // I/O devices & their interrupts
80103939:	e8 a5 d1 ff ff       	call   80100ae3 <consoleinit>
  uartinit();      // serial port
8010393e:	e8 3d 34 00 00       	call   80106d80 <uartinit>
  pinit();         // process table
80103943:	e8 55 0b 00 00       	call   8010449d <pinit>
  tvinit();        // trap vectors
80103948:	e8 02 30 00 00       	call   8010694f <tvinit>
  binit();         // buffer cache
8010394d:	e8 e2 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103952:	e8 e7 d5 ff ff       	call   80100f3e <fileinit>
  iinit();         // inode cache
80103957:	e8 ba dc ff ff       	call   80101616 <iinit>
  ideinit();       // disk
8010395c:	e8 5f ed ff ff       	call   801026c0 <ideinit>
  if(!ismp)
80103961:	a1 84 24 11 80       	mov    0x80112484,%eax
80103966:	85 c0                	test   %eax,%eax
80103968:	75 05                	jne    8010396f <main+0x9c>
    timerinit();   // uniprocessor timer
8010396a:	e8 3f 2f 00 00       	call   801068ae <timerinit>
  startothers();   // start other processors
8010396f:	e8 7f 00 00 00       	call   801039f3 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103974:	83 ec 08             	sub    $0x8,%esp
80103977:	68 00 00 00 8e       	push   $0x8e000000
8010397c:	68 00 00 40 80       	push   $0x80400000
80103981:	e8 32 f2 ff ff       	call   80102bb8 <kinit2>
80103986:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103989:	e8 31 0c 00 00       	call   801045bf <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010398e:	e8 1a 00 00 00       	call   801039ad <mpmain>

80103993 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103993:	55                   	push   %ebp
80103994:	89 e5                	mov    %esp,%ebp
80103996:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103999:	e8 ee 46 00 00       	call   8010808c <switchkvm>
  seginit();
8010399e:	e8 7a 40 00 00       	call   80107a1d <seginit>
  lapicinit();
801039a3:	e8 50 f5 ff ff       	call   80102ef8 <lapicinit>
  mpmain();
801039a8:	e8 00 00 00 00       	call   801039ad <mpmain>

801039ad <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039ad:	55                   	push   %ebp
801039ae:	89 e5                	mov    %esp,%ebp
801039b0:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801039b3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039b9:	0f b6 00             	movzbl (%eax),%eax
801039bc:	0f b6 c0             	movzbl %al,%eax
801039bf:	83 ec 08             	sub    $0x8,%esp
801039c2:	50                   	push   %eax
801039c3:	68 43 8a 10 80       	push   $0x80108a43
801039c8:	e8 f2 c9 ff ff       	call   801003bf <cprintf>
801039cd:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039d0:	e8 ef 30 00 00       	call   80106ac4 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039db:	05 a8 00 00 00       	add    $0xa8,%eax
801039e0:	83 ec 08             	sub    $0x8,%esp
801039e3:	6a 01                	push   $0x1
801039e5:	50                   	push   %eax
801039e6:	e8 ce fe ff ff       	call   801038b9 <xchg>
801039eb:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039ee:	e8 76 11 00 00       	call   80104b69 <scheduler>

801039f3 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039f3:	55                   	push   %ebp
801039f4:	89 e5                	mov    %esp,%ebp
801039f6:	53                   	push   %ebx
801039f7:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039fa:	68 00 70 00 00       	push   $0x7000
801039ff:	e8 a8 fe ff ff       	call   801038ac <p2v>
80103a04:	83 c4 04             	add    $0x4,%esp
80103a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a0a:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a0f:	83 ec 04             	sub    $0x4,%esp
80103a12:	50                   	push   %eax
80103a13:	68 6c b5 10 80       	push   $0x8010b56c
80103a18:	ff 75 f0             	pushl  -0x10(%ebp)
80103a1b:	e8 61 1b 00 00       	call   80105581 <memmove>
80103a20:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a23:	c7 45 f4 c0 24 11 80 	movl   $0x801124c0,-0xc(%ebp)
80103a2a:	e9 8f 00 00 00       	jmp    80103abe <startothers+0xcb>
    if(c == cpus+cpunum())  // We've started already.
80103a2f:	e8 e0 f5 ff ff       	call   80103014 <cpunum>
80103a34:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a3a:	05 c0 24 11 80       	add    $0x801124c0,%eax
80103a3f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a42:	75 02                	jne    80103a46 <startothers+0x53>
      continue;
80103a44:	eb 71                	jmp    80103ab7 <startothers+0xc4>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a46:	e8 68 f2 ff ff       	call   80102cb3 <kalloc>
80103a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a51:	83 e8 04             	sub    $0x4,%eax
80103a54:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a57:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a5d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a62:	83 e8 08             	sub    $0x8,%eax
80103a65:	c7 00 93 39 10 80    	movl   $0x80103993,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6e:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a71:	83 ec 0c             	sub    $0xc,%esp
80103a74:	68 00 a0 10 80       	push   $0x8010a000
80103a79:	e8 21 fe ff ff       	call   8010389f <v2p>
80103a7e:	83 c4 10             	add    $0x10,%esp
80103a81:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a83:	83 ec 0c             	sub    $0xc,%esp
80103a86:	ff 75 f0             	pushl  -0x10(%ebp)
80103a89:	e8 11 fe ff ff       	call   8010389f <v2p>
80103a8e:	83 c4 10             	add    $0x10,%esp
80103a91:	89 c2                	mov    %eax,%edx
80103a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a96:	0f b6 00             	movzbl (%eax),%eax
80103a99:	0f b6 c0             	movzbl %al,%eax
80103a9c:	83 ec 08             	sub    $0x8,%esp
80103a9f:	52                   	push   %edx
80103aa0:	50                   	push   %eax
80103aa1:	e8 e6 f5 ff ff       	call   8010308c <lapicstartap>
80103aa6:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103aa9:	90                   	nop
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103ab3:	85 c0                	test   %eax,%eax
80103ab5:	74 f3                	je     80103aaa <startothers+0xb7>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103ab7:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103abe:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103ac3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ac9:	05 c0 24 11 80       	add    $0x801124c0,%eax
80103ace:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ad1:	0f 87 58 ff ff ff    	ja     80103a2f <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ada:	c9                   	leave  
80103adb:	c3                   	ret    

80103adc <p2v>:
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ae7:	5d                   	pop    %ebp
80103ae8:	c3                   	ret    

80103ae9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ae9:	55                   	push   %ebp
80103aea:	89 e5                	mov    %esp,%ebp
80103aec:	83 ec 14             	sub    $0x14,%esp
80103aef:	8b 45 08             	mov    0x8(%ebp),%eax
80103af2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103af6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103afa:	89 c2                	mov    %eax,%edx
80103afc:	ec                   	in     (%dx),%al
80103afd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b00:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b04:	c9                   	leave  
80103b05:	c3                   	ret    

80103b06 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b06:	55                   	push   %ebp
80103b07:	89 e5                	mov    %esp,%ebp
80103b09:	83 ec 08             	sub    $0x8,%esp
80103b0c:	8b 55 08             	mov    0x8(%ebp),%edx
80103b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b12:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b16:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b19:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b1d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b21:	ee                   	out    %al,(%dx)
}
80103b22:	c9                   	leave  
80103b23:	c3                   	ret    

80103b24 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b27:	a1 a4 b6 10 80       	mov    0x8010b6a4,%eax
80103b2c:	89 c2                	mov    %eax,%edx
80103b2e:	b8 c0 24 11 80       	mov    $0x801124c0,%eax
80103b33:	29 c2                	sub    %eax,%edx
80103b35:	89 d0                	mov    %edx,%eax
80103b37:	c1 f8 02             	sar    $0x2,%eax
80103b3a:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b40:	5d                   	pop    %ebp
80103b41:	c3                   	ret    

80103b42 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b42:	55                   	push   %ebp
80103b43:	89 e5                	mov    %esp,%ebp
80103b45:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b48:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b4f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b56:	eb 15                	jmp    80103b6d <sum+0x2b>
    sum += addr[i];
80103b58:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b5e:	01 d0                	add    %edx,%eax
80103b60:	0f b6 00             	movzbl (%eax),%eax
80103b63:	0f b6 c0             	movzbl %al,%eax
80103b66:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b69:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b70:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b73:	7c e3                	jl     80103b58 <sum+0x16>
    sum += addr[i];
  return sum;
80103b75:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b78:	c9                   	leave  
80103b79:	c3                   	ret    

80103b7a <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b7a:	55                   	push   %ebp
80103b7b:	89 e5                	mov    %esp,%ebp
80103b7d:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b80:	ff 75 08             	pushl  0x8(%ebp)
80103b83:	e8 54 ff ff ff       	call   80103adc <p2v>
80103b88:	83 c4 04             	add    $0x4,%esp
80103b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b94:	01 d0                	add    %edx,%eax
80103b96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b9f:	eb 36                	jmp    80103bd7 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ba1:	83 ec 04             	sub    $0x4,%esp
80103ba4:	6a 04                	push   $0x4
80103ba6:	68 54 8a 10 80       	push   $0x80108a54
80103bab:	ff 75 f4             	pushl  -0xc(%ebp)
80103bae:	e8 76 19 00 00       	call   80105529 <memcmp>
80103bb3:	83 c4 10             	add    $0x10,%esp
80103bb6:	85 c0                	test   %eax,%eax
80103bb8:	75 19                	jne    80103bd3 <mpsearch1+0x59>
80103bba:	83 ec 08             	sub    $0x8,%esp
80103bbd:	6a 10                	push   $0x10
80103bbf:	ff 75 f4             	pushl  -0xc(%ebp)
80103bc2:	e8 7b ff ff ff       	call   80103b42 <sum>
80103bc7:	83 c4 10             	add    $0x10,%esp
80103bca:	84 c0                	test   %al,%al
80103bcc:	75 05                	jne    80103bd3 <mpsearch1+0x59>
      return (struct mp*)p;
80103bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd1:	eb 11                	jmp    80103be4 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103bd3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bda:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bdd:	72 c2                	jb     80103ba1 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103be4:	c9                   	leave  
80103be5:	c3                   	ret    

80103be6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103be6:	55                   	push   %ebp
80103be7:	89 e5                	mov    %esp,%ebp
80103be9:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bec:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf6:	83 c0 0f             	add    $0xf,%eax
80103bf9:	0f b6 00             	movzbl (%eax),%eax
80103bfc:	0f b6 c0             	movzbl %al,%eax
80103bff:	c1 e0 08             	shl    $0x8,%eax
80103c02:	89 c2                	mov    %eax,%edx
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	83 c0 0e             	add    $0xe,%eax
80103c0a:	0f b6 00             	movzbl (%eax),%eax
80103c0d:	0f b6 c0             	movzbl %al,%eax
80103c10:	09 d0                	or     %edx,%eax
80103c12:	c1 e0 04             	shl    $0x4,%eax
80103c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c1c:	74 21                	je     80103c3f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c1e:	83 ec 08             	sub    $0x8,%esp
80103c21:	68 00 04 00 00       	push   $0x400
80103c26:	ff 75 f0             	pushl  -0x10(%ebp)
80103c29:	e8 4c ff ff ff       	call   80103b7a <mpsearch1>
80103c2e:	83 c4 10             	add    $0x10,%esp
80103c31:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c38:	74 51                	je     80103c8b <mpsearch+0xa5>
      return mp;
80103c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3d:	eb 61                	jmp    80103ca0 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	83 c0 14             	add    $0x14,%eax
80103c45:	0f b6 00             	movzbl (%eax),%eax
80103c48:	0f b6 c0             	movzbl %al,%eax
80103c4b:	c1 e0 08             	shl    $0x8,%eax
80103c4e:	89 c2                	mov    %eax,%edx
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	83 c0 13             	add    $0x13,%eax
80103c56:	0f b6 00             	movzbl (%eax),%eax
80103c59:	0f b6 c0             	movzbl %al,%eax
80103c5c:	09 d0                	or     %edx,%eax
80103c5e:	c1 e0 0a             	shl    $0xa,%eax
80103c61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c67:	2d 00 04 00 00       	sub    $0x400,%eax
80103c6c:	83 ec 08             	sub    $0x8,%esp
80103c6f:	68 00 04 00 00       	push   $0x400
80103c74:	50                   	push   %eax
80103c75:	e8 00 ff ff ff       	call   80103b7a <mpsearch1>
80103c7a:	83 c4 10             	add    $0x10,%esp
80103c7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c84:	74 05                	je     80103c8b <mpsearch+0xa5>
      return mp;
80103c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c89:	eb 15                	jmp    80103ca0 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c8b:	83 ec 08             	sub    $0x8,%esp
80103c8e:	68 00 00 01 00       	push   $0x10000
80103c93:	68 00 00 0f 00       	push   $0xf0000
80103c98:	e8 dd fe ff ff       	call   80103b7a <mpsearch1>
80103c9d:	83 c4 10             	add    $0x10,%esp
}
80103ca0:	c9                   	leave  
80103ca1:	c3                   	ret    

80103ca2 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ca2:	55                   	push   %ebp
80103ca3:	89 e5                	mov    %esp,%ebp
80103ca5:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ca8:	e8 39 ff ff ff       	call   80103be6 <mpsearch>
80103cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cb4:	74 0a                	je     80103cc0 <mpconfig+0x1e>
80103cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb9:	8b 40 04             	mov    0x4(%eax),%eax
80103cbc:	85 c0                	test   %eax,%eax
80103cbe:	75 0a                	jne    80103cca <mpconfig+0x28>
    return 0;
80103cc0:	b8 00 00 00 00       	mov    $0x0,%eax
80103cc5:	e9 81 00 00 00       	jmp    80103d4b <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccd:	8b 40 04             	mov    0x4(%eax),%eax
80103cd0:	83 ec 0c             	sub    $0xc,%esp
80103cd3:	50                   	push   %eax
80103cd4:	e8 03 fe ff ff       	call   80103adc <p2v>
80103cd9:	83 c4 10             	add    $0x10,%esp
80103cdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cdf:	83 ec 04             	sub    $0x4,%esp
80103ce2:	6a 04                	push   $0x4
80103ce4:	68 59 8a 10 80       	push   $0x80108a59
80103ce9:	ff 75 f0             	pushl  -0x10(%ebp)
80103cec:	e8 38 18 00 00       	call   80105529 <memcmp>
80103cf1:	83 c4 10             	add    $0x10,%esp
80103cf4:	85 c0                	test   %eax,%eax
80103cf6:	74 07                	je     80103cff <mpconfig+0x5d>
    return 0;
80103cf8:	b8 00 00 00 00       	mov    $0x0,%eax
80103cfd:	eb 4c                	jmp    80103d4b <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d02:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d06:	3c 01                	cmp    $0x1,%al
80103d08:	74 12                	je     80103d1c <mpconfig+0x7a>
80103d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d11:	3c 04                	cmp    $0x4,%al
80103d13:	74 07                	je     80103d1c <mpconfig+0x7a>
    return 0;
80103d15:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1a:	eb 2f                	jmp    80103d4b <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d23:	0f b7 c0             	movzwl %ax,%eax
80103d26:	83 ec 08             	sub    $0x8,%esp
80103d29:	50                   	push   %eax
80103d2a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d2d:	e8 10 fe ff ff       	call   80103b42 <sum>
80103d32:	83 c4 10             	add    $0x10,%esp
80103d35:	84 c0                	test   %al,%al
80103d37:	74 07                	je     80103d40 <mpconfig+0x9e>
    return 0;
80103d39:	b8 00 00 00 00       	mov    $0x0,%eax
80103d3e:	eb 0b                	jmp    80103d4b <mpconfig+0xa9>
  *pmp = mp;
80103d40:	8b 45 08             	mov    0x8(%ebp),%eax
80103d43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d46:	89 10                	mov    %edx,(%eax)
  return conf;
80103d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d4b:	c9                   	leave  
80103d4c:	c3                   	ret    

80103d4d <mpinit>:

void
mpinit(void)
{
80103d4d:	55                   	push   %ebp
80103d4e:	89 e5                	mov    %esp,%ebp
80103d50:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d53:	c7 05 a4 b6 10 80 c0 	movl   $0x801124c0,0x8010b6a4
80103d5a:	24 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d5d:	83 ec 0c             	sub    $0xc,%esp
80103d60:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d63:	50                   	push   %eax
80103d64:	e8 39 ff ff ff       	call   80103ca2 <mpconfig>
80103d69:	83 c4 10             	add    $0x10,%esp
80103d6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d73:	75 05                	jne    80103d7a <mpinit+0x2d>
    return;
80103d75:	e9 94 01 00 00       	jmp    80103f0e <mpinit+0x1c1>
  ismp = 1;
80103d7a:	c7 05 84 24 11 80 01 	movl   $0x1,0x80112484
80103d81:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d87:	8b 40 24             	mov    0x24(%eax),%eax
80103d8a:	a3 5c 23 11 80       	mov    %eax,0x8011235c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d92:	83 c0 2c             	add    $0x2c,%eax
80103d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d9f:	0f b7 d0             	movzwl %ax,%edx
80103da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da5:	01 d0                	add    %edx,%eax
80103da7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103daa:	e9 f2 00 00 00       	jmp    80103ea1 <mpinit+0x154>
    switch(*p){
80103daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db2:	0f b6 00             	movzbl (%eax),%eax
80103db5:	0f b6 c0             	movzbl %al,%eax
80103db8:	83 f8 04             	cmp    $0x4,%eax
80103dbb:	0f 87 bc 00 00 00    	ja     80103e7d <mpinit+0x130>
80103dc1:	8b 04 85 9c 8a 10 80 	mov    -0x7fef7564(,%eax,4),%eax
80103dc8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103dd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dd3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dd7:	0f b6 d0             	movzbl %al,%edx
80103dda:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103ddf:	39 c2                	cmp    %eax,%edx
80103de1:	74 2b                	je     80103e0e <mpinit+0xc1>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103de3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103de6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dea:	0f b6 d0             	movzbl %al,%edx
80103ded:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103df2:	83 ec 04             	sub    $0x4,%esp
80103df5:	52                   	push   %edx
80103df6:	50                   	push   %eax
80103df7:	68 5e 8a 10 80       	push   $0x80108a5e
80103dfc:	e8 be c5 ff ff       	call   801003bf <cprintf>
80103e01:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e04:	c7 05 84 24 11 80 00 	movl   $0x0,0x80112484
80103e0b:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e11:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e15:	0f b6 c0             	movzbl %al,%eax
80103e18:	83 e0 02             	and    $0x2,%eax
80103e1b:	85 c0                	test   %eax,%eax
80103e1d:	74 15                	je     80103e34 <mpinit+0xe7>
        bcpu = &cpus[ncpu];
80103e1f:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103e24:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e2a:	05 c0 24 11 80       	add    $0x801124c0,%eax
80103e2f:	a3 a4 b6 10 80       	mov    %eax,0x8010b6a4
      cpus[ncpu].id = ncpu;
80103e34:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103e39:	8b 15 a0 2a 11 80    	mov    0x80112aa0,%edx
80103e3f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e45:	05 c0 24 11 80       	add    $0x801124c0,%eax
80103e4a:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e4c:	a1 a0 2a 11 80       	mov    0x80112aa0,%eax
80103e51:	83 c0 01             	add    $0x1,%eax
80103e54:	a3 a0 2a 11 80       	mov    %eax,0x80112aa0
      p += sizeof(struct mpproc);
80103e59:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e5d:	eb 42                	jmp    80103ea1 <mpinit+0x154>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e68:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e6c:	a2 80 24 11 80       	mov    %al,0x80112480
      p += sizeof(struct mpioapic);
80103e71:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e75:	eb 2a                	jmp    80103ea1 <mpinit+0x154>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e77:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e7b:	eb 24                	jmp    80103ea1 <mpinit+0x154>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e80:	0f b6 00             	movzbl (%eax),%eax
80103e83:	0f b6 c0             	movzbl %al,%eax
80103e86:	83 ec 08             	sub    $0x8,%esp
80103e89:	50                   	push   %eax
80103e8a:	68 7c 8a 10 80       	push   $0x80108a7c
80103e8f:	e8 2b c5 ff ff       	call   801003bf <cprintf>
80103e94:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e97:	c7 05 84 24 11 80 00 	movl   $0x0,0x80112484
80103e9e:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ea7:	0f 82 02 ff ff ff    	jb     80103daf <mpinit+0x62>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103ead:	a1 84 24 11 80       	mov    0x80112484,%eax
80103eb2:	85 c0                	test   %eax,%eax
80103eb4:	75 1d                	jne    80103ed3 <mpinit+0x186>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103eb6:	c7 05 a0 2a 11 80 01 	movl   $0x1,0x80112aa0
80103ebd:	00 00 00 
    lapic = 0;
80103ec0:	c7 05 5c 23 11 80 00 	movl   $0x0,0x8011235c
80103ec7:	00 00 00 
    ioapicid = 0;
80103eca:	c6 05 80 24 11 80 00 	movb   $0x0,0x80112480
    return;
80103ed1:	eb 3b                	jmp    80103f0e <mpinit+0x1c1>
  }

  if(mp->imcrp){
80103ed3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ed6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103eda:	84 c0                	test   %al,%al
80103edc:	74 30                	je     80103f0e <mpinit+0x1c1>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ede:	83 ec 08             	sub    $0x8,%esp
80103ee1:	6a 70                	push   $0x70
80103ee3:	6a 22                	push   $0x22
80103ee5:	e8 1c fc ff ff       	call   80103b06 <outb>
80103eea:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103eed:	83 ec 0c             	sub    $0xc,%esp
80103ef0:	6a 23                	push   $0x23
80103ef2:	e8 f2 fb ff ff       	call   80103ae9 <inb>
80103ef7:	83 c4 10             	add    $0x10,%esp
80103efa:	83 c8 01             	or     $0x1,%eax
80103efd:	0f b6 c0             	movzbl %al,%eax
80103f00:	83 ec 08             	sub    $0x8,%esp
80103f03:	50                   	push   %eax
80103f04:	6a 23                	push   $0x23
80103f06:	e8 fb fb ff ff       	call   80103b06 <outb>
80103f0b:	83 c4 10             	add    $0x10,%esp
  }
}
80103f0e:	c9                   	leave  
80103f0f:	c3                   	ret    

80103f10 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
80103f13:	83 ec 08             	sub    $0x8,%esp
80103f16:	8b 55 08             	mov    0x8(%ebp),%edx
80103f19:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f1c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f20:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f23:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f27:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f2b:	ee                   	out    %al,(%dx)
}
80103f2c:	c9                   	leave  
80103f2d:	c3                   	ret    

80103f2e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f2e:	55                   	push   %ebp
80103f2f:	89 e5                	mov    %esp,%ebp
80103f31:	83 ec 04             	sub    $0x4,%esp
80103f34:	8b 45 08             	mov    0x8(%ebp),%eax
80103f37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f3b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f3f:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f45:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f49:	0f b6 c0             	movzbl %al,%eax
80103f4c:	50                   	push   %eax
80103f4d:	6a 21                	push   $0x21
80103f4f:	e8 bc ff ff ff       	call   80103f10 <outb>
80103f54:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f57:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f5b:	66 c1 e8 08          	shr    $0x8,%ax
80103f5f:	0f b6 c0             	movzbl %al,%eax
80103f62:	50                   	push   %eax
80103f63:	68 a1 00 00 00       	push   $0xa1
80103f68:	e8 a3 ff ff ff       	call   80103f10 <outb>
80103f6d:	83 c4 08             	add    $0x8,%esp
}
80103f70:	c9                   	leave  
80103f71:	c3                   	ret    

80103f72 <picenable>:

void
picenable(int irq)
{
80103f72:	55                   	push   %ebp
80103f73:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f75:	8b 45 08             	mov    0x8(%ebp),%eax
80103f78:	ba 01 00 00 00       	mov    $0x1,%edx
80103f7d:	89 c1                	mov    %eax,%ecx
80103f7f:	d3 e2                	shl    %cl,%edx
80103f81:	89 d0                	mov    %edx,%eax
80103f83:	f7 d0                	not    %eax
80103f85:	89 c2                	mov    %eax,%edx
80103f87:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f8e:	21 d0                	and    %edx,%eax
80103f90:	0f b7 c0             	movzwl %ax,%eax
80103f93:	50                   	push   %eax
80103f94:	e8 95 ff ff ff       	call   80103f2e <picsetmask>
80103f99:	83 c4 04             	add    $0x4,%esp
}
80103f9c:	c9                   	leave  
80103f9d:	c3                   	ret    

80103f9e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f9e:	55                   	push   %ebp
80103f9f:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fa1:	68 ff 00 00 00       	push   $0xff
80103fa6:	6a 21                	push   $0x21
80103fa8:	e8 63 ff ff ff       	call   80103f10 <outb>
80103fad:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fb0:	68 ff 00 00 00       	push   $0xff
80103fb5:	68 a1 00 00 00       	push   $0xa1
80103fba:	e8 51 ff ff ff       	call   80103f10 <outb>
80103fbf:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fc2:	6a 11                	push   $0x11
80103fc4:	6a 20                	push   $0x20
80103fc6:	e8 45 ff ff ff       	call   80103f10 <outb>
80103fcb:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fce:	6a 20                	push   $0x20
80103fd0:	6a 21                	push   $0x21
80103fd2:	e8 39 ff ff ff       	call   80103f10 <outb>
80103fd7:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fda:	6a 04                	push   $0x4
80103fdc:	6a 21                	push   $0x21
80103fde:	e8 2d ff ff ff       	call   80103f10 <outb>
80103fe3:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fe6:	6a 03                	push   $0x3
80103fe8:	6a 21                	push   $0x21
80103fea:	e8 21 ff ff ff       	call   80103f10 <outb>
80103fef:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ff2:	6a 11                	push   $0x11
80103ff4:	68 a0 00 00 00       	push   $0xa0
80103ff9:	e8 12 ff ff ff       	call   80103f10 <outb>
80103ffe:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104001:	6a 28                	push   $0x28
80104003:	68 a1 00 00 00       	push   $0xa1
80104008:	e8 03 ff ff ff       	call   80103f10 <outb>
8010400d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104010:	6a 02                	push   $0x2
80104012:	68 a1 00 00 00       	push   $0xa1
80104017:	e8 f4 fe ff ff       	call   80103f10 <outb>
8010401c:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010401f:	6a 03                	push   $0x3
80104021:	68 a1 00 00 00       	push   $0xa1
80104026:	e8 e5 fe ff ff       	call   80103f10 <outb>
8010402b:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010402e:	6a 68                	push   $0x68
80104030:	6a 20                	push   $0x20
80104032:	e8 d9 fe ff ff       	call   80103f10 <outb>
80104037:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010403a:	6a 0a                	push   $0xa
8010403c:	6a 20                	push   $0x20
8010403e:	e8 cd fe ff ff       	call   80103f10 <outb>
80104043:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104046:	6a 68                	push   $0x68
80104048:	68 a0 00 00 00       	push   $0xa0
8010404d:	e8 be fe ff ff       	call   80103f10 <outb>
80104052:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104055:	6a 0a                	push   $0xa
80104057:	68 a0 00 00 00       	push   $0xa0
8010405c:	e8 af fe ff ff       	call   80103f10 <outb>
80104061:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104064:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010406b:	66 83 f8 ff          	cmp    $0xffff,%ax
8010406f:	74 13                	je     80104084 <picinit+0xe6>
    picsetmask(irqmask);
80104071:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104078:	0f b7 c0             	movzwl %ax,%eax
8010407b:	50                   	push   %eax
8010407c:	e8 ad fe ff ff       	call   80103f2e <picsetmask>
80104081:	83 c4 04             	add    $0x4,%esp
}
80104084:	c9                   	leave  
80104085:	c3                   	ret    

80104086 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104086:	55                   	push   %ebp
80104087:	89 e5                	mov    %esp,%ebp
80104089:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010408c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104093:	8b 45 0c             	mov    0xc(%ebp),%eax
80104096:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010409c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409f:	8b 10                	mov    (%eax),%edx
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040a6:	e8 b0 ce ff ff       	call   80100f5b <filealloc>
801040ab:	89 c2                	mov    %eax,%edx
801040ad:	8b 45 08             	mov    0x8(%ebp),%eax
801040b0:	89 10                	mov    %edx,(%eax)
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	0f 84 cb 00 00 00    	je     8010418a <pipealloc+0x104>
801040bf:	e8 97 ce ff ff       	call   80100f5b <filealloc>
801040c4:	89 c2                	mov    %eax,%edx
801040c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c9:	89 10                	mov    %edx,(%eax)
801040cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ce:	8b 00                	mov    (%eax),%eax
801040d0:	85 c0                	test   %eax,%eax
801040d2:	0f 84 b2 00 00 00    	je     8010418a <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040d8:	e8 d6 eb ff ff       	call   80102cb3 <kalloc>
801040dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040e4:	75 05                	jne    801040eb <pipealloc+0x65>
    goto bad;
801040e6:	e9 9f 00 00 00       	jmp    8010418a <pipealloc+0x104>
  p->readopen = 1;
801040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ee:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040f5:	00 00 00 
  p->writeopen = 1;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104102:	00 00 00 
  p->nwrite = 0;
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010410f:	00 00 00 
  p->nread = 0;
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010411c:	00 00 00 
  initlock(&p->lock, "pipe");
8010411f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104122:	83 ec 08             	sub    $0x8,%esp
80104125:	68 b0 8a 10 80       	push   $0x80108ab0
8010412a:	50                   	push   %eax
8010412b:	e8 15 11 00 00       	call   80105245 <initlock>
80104130:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 00                	mov    (%eax),%eax
80104138:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 00                	mov    (%eax),%eax
80104143:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	8b 00                	mov    (%eax),%eax
8010414c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	8b 00                	mov    (%eax),%eax
80104155:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104158:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010415b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415e:	8b 00                	mov    (%eax),%eax
80104160:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104166:	8b 45 0c             	mov    0xc(%ebp),%eax
80104169:	8b 00                	mov    (%eax),%eax
8010416b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010416f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104172:	8b 00                	mov    (%eax),%eax
80104174:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104178:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417b:	8b 00                	mov    (%eax),%eax
8010417d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104180:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104183:	b8 00 00 00 00       	mov    $0x0,%eax
80104188:	eb 4d                	jmp    801041d7 <pipealloc+0x151>

//PAGEBREAK: 20
 bad:
  if(p)
8010418a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010418e:	74 0e                	je     8010419e <pipealloc+0x118>
    kfree((char*)p);
80104190:	83 ec 0c             	sub    $0xc,%esp
80104193:	ff 75 f4             	pushl  -0xc(%ebp)
80104196:	e8 7c ea ff ff       	call   80102c17 <kfree>
8010419b:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 00                	mov    (%eax),%eax
801041a3:	85 c0                	test   %eax,%eax
801041a5:	74 11                	je     801041b8 <pipealloc+0x132>
    fileclose(*f0);
801041a7:	8b 45 08             	mov    0x8(%ebp),%eax
801041aa:	8b 00                	mov    (%eax),%eax
801041ac:	83 ec 0c             	sub    $0xc,%esp
801041af:	50                   	push   %eax
801041b0:	e8 63 ce ff ff       	call   80101018 <fileclose>
801041b5:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bb:	8b 00                	mov    (%eax),%eax
801041bd:	85 c0                	test   %eax,%eax
801041bf:	74 11                	je     801041d2 <pipealloc+0x14c>
    fileclose(*f1);
801041c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c4:	8b 00                	mov    (%eax),%eax
801041c6:	83 ec 0c             	sub    $0xc,%esp
801041c9:	50                   	push   %eax
801041ca:	e8 49 ce ff ff       	call   80101018 <fileclose>
801041cf:	83 c4 10             	add    $0x10,%esp
  return -1;
801041d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041d7:	c9                   	leave  
801041d8:	c3                   	ret    

801041d9 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041d9:	55                   	push   %ebp
801041da:	89 e5                	mov    %esp,%ebp
801041dc:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	83 ec 0c             	sub    $0xc,%esp
801041e5:	50                   	push   %eax
801041e6:	e8 7b 10 00 00       	call   80105266 <acquire>
801041eb:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041f2:	74 23                	je     80104217 <pipeclose+0x3e>
    p->writeopen = 0;
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041fe:	00 00 00 
    wakeup(&p->nread);
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	05 34 02 00 00       	add    $0x234,%eax
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	50                   	push   %eax
8010420d:	e8 09 0c 00 00       	call   80104e1b <wakeup>
80104212:	83 c4 10             	add    $0x10,%esp
80104215:	eb 21                	jmp    80104238 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104221:	00 00 00 
    wakeup(&p->nwrite);
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	05 38 02 00 00       	add    $0x238,%eax
8010422c:	83 ec 0c             	sub    $0xc,%esp
8010422f:	50                   	push   %eax
80104230:	e8 e6 0b 00 00       	call   80104e1b <wakeup>
80104235:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104241:	85 c0                	test   %eax,%eax
80104243:	75 2c                	jne    80104271 <pipeclose+0x98>
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010424e:	85 c0                	test   %eax,%eax
80104250:	75 1f                	jne    80104271 <pipeclose+0x98>
    release(&p->lock);
80104252:	8b 45 08             	mov    0x8(%ebp),%eax
80104255:	83 ec 0c             	sub    $0xc,%esp
80104258:	50                   	push   %eax
80104259:	e8 6e 10 00 00       	call   801052cc <release>
8010425e:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104261:	83 ec 0c             	sub    $0xc,%esp
80104264:	ff 75 08             	pushl  0x8(%ebp)
80104267:	e8 ab e9 ff ff       	call   80102c17 <kfree>
8010426c:	83 c4 10             	add    $0x10,%esp
8010426f:	eb 0f                	jmp    80104280 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	83 ec 0c             	sub    $0xc,%esp
80104277:	50                   	push   %eax
80104278:	e8 4f 10 00 00       	call   801052cc <release>
8010427d:	83 c4 10             	add    $0x10,%esp
}
80104280:	c9                   	leave  
80104281:	c3                   	ret    

80104282 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104282:	55                   	push   %ebp
80104283:	89 e5                	mov    %esp,%ebp
80104285:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104288:	8b 45 08             	mov    0x8(%ebp),%eax
8010428b:	83 ec 0c             	sub    $0xc,%esp
8010428e:	50                   	push   %eax
8010428f:	e8 d2 0f 00 00       	call   80105266 <acquire>
80104294:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104297:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010429e:	e9 af 00 00 00       	jmp    80104352 <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042a3:	eb 60                	jmp    80104305 <pipewrite+0x83>
      if(p->readopen == 0 || proc->killed){
801042a5:	8b 45 08             	mov    0x8(%ebp),%eax
801042a8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 0d                	je     801042bf <pipewrite+0x3d>
801042b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b8:	8b 40 24             	mov    0x24(%eax),%eax
801042bb:	85 c0                	test   %eax,%eax
801042bd:	74 19                	je     801042d8 <pipewrite+0x56>
        release(&p->lock);
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	83 ec 0c             	sub    $0xc,%esp
801042c5:	50                   	push   %eax
801042c6:	e8 01 10 00 00       	call   801052cc <release>
801042cb:	83 c4 10             	add    $0x10,%esp
        return -1;
801042ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d3:	e9 ac 00 00 00       	jmp    80104384 <pipewrite+0x102>
      }
      wakeup(&p->nread);
801042d8:	8b 45 08             	mov    0x8(%ebp),%eax
801042db:	05 34 02 00 00       	add    $0x234,%eax
801042e0:	83 ec 0c             	sub    $0xc,%esp
801042e3:	50                   	push   %eax
801042e4:	e8 32 0b 00 00       	call   80104e1b <wakeup>
801042e9:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 55 08             	mov    0x8(%ebp),%edx
801042f2:	81 c2 38 02 00 00    	add    $0x238,%edx
801042f8:	83 ec 08             	sub    $0x8,%esp
801042fb:	50                   	push   %eax
801042fc:	52                   	push   %edx
801042fd:	e8 30 0a 00 00       	call   80104d32 <sleep>
80104302:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104305:	8b 45 08             	mov    0x8(%ebp),%eax
80104308:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010430e:	8b 45 08             	mov    0x8(%ebp),%eax
80104311:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104317:	05 00 02 00 00       	add    $0x200,%eax
8010431c:	39 c2                	cmp    %eax,%edx
8010431e:	74 85                	je     801042a5 <pipewrite+0x23>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104320:	8b 45 08             	mov    0x8(%ebp),%eax
80104323:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104329:	8d 48 01             	lea    0x1(%eax),%ecx
8010432c:	8b 55 08             	mov    0x8(%ebp),%edx
8010432f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104335:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433a:	89 c1                	mov    %eax,%ecx
8010433c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010433f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104342:	01 d0                	add    %edx,%eax
80104344:	0f b6 10             	movzbl (%eax),%edx
80104347:	8b 45 08             	mov    0x8(%ebp),%eax
8010434a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010434e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	3b 45 10             	cmp    0x10(%ebp),%eax
80104358:	0f 8c 45 ff ff ff    	jl     801042a3 <pipewrite+0x21>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010435e:	8b 45 08             	mov    0x8(%ebp),%eax
80104361:	05 34 02 00 00       	add    $0x234,%eax
80104366:	83 ec 0c             	sub    $0xc,%esp
80104369:	50                   	push   %eax
8010436a:	e8 ac 0a 00 00       	call   80104e1b <wakeup>
8010436f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104372:	8b 45 08             	mov    0x8(%ebp),%eax
80104375:	83 ec 0c             	sub    $0xc,%esp
80104378:	50                   	push   %eax
80104379:	e8 4e 0f 00 00       	call   801052cc <release>
8010437e:	83 c4 10             	add    $0x10,%esp
  return n;
80104381:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104384:	c9                   	leave  
80104385:	c3                   	ret    

80104386 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104386:	55                   	push   %ebp
80104387:	89 e5                	mov    %esp,%ebp
80104389:	53                   	push   %ebx
8010438a:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010438d:	8b 45 08             	mov    0x8(%ebp),%eax
80104390:	83 ec 0c             	sub    $0xc,%esp
80104393:	50                   	push   %eax
80104394:	e8 cd 0e 00 00       	call   80105266 <acquire>
80104399:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010439c:	eb 3f                	jmp    801043dd <piperead+0x57>
    if(proc->killed){
8010439e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043a4:	8b 40 24             	mov    0x24(%eax),%eax
801043a7:	85 c0                	test   %eax,%eax
801043a9:	74 19                	je     801043c4 <piperead+0x3e>
      release(&p->lock);
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	83 ec 0c             	sub    $0xc,%esp
801043b1:	50                   	push   %eax
801043b2:	e8 15 0f 00 00       	call   801052cc <release>
801043b7:	83 c4 10             	add    $0x10,%esp
      return -1;
801043ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043bf:	e9 be 00 00 00       	jmp    80104482 <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043c4:	8b 45 08             	mov    0x8(%ebp),%eax
801043c7:	8b 55 08             	mov    0x8(%ebp),%edx
801043ca:	81 c2 34 02 00 00    	add    $0x234,%edx
801043d0:	83 ec 08             	sub    $0x8,%esp
801043d3:	50                   	push   %eax
801043d4:	52                   	push   %edx
801043d5:	e8 58 09 00 00       	call   80104d32 <sleep>
801043da:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043dd:	8b 45 08             	mov    0x8(%ebp),%eax
801043e0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043e6:	8b 45 08             	mov    0x8(%ebp),%eax
801043e9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043ef:	39 c2                	cmp    %eax,%edx
801043f1:	75 0d                	jne    80104400 <piperead+0x7a>
801043f3:	8b 45 08             	mov    0x8(%ebp),%eax
801043f6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043fc:	85 c0                	test   %eax,%eax
801043fe:	75 9e                	jne    8010439e <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104400:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104407:	eb 4b                	jmp    80104454 <piperead+0xce>
    if(p->nread == p->nwrite)
80104409:	8b 45 08             	mov    0x8(%ebp),%eax
8010440c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104412:	8b 45 08             	mov    0x8(%ebp),%eax
80104415:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010441b:	39 c2                	cmp    %eax,%edx
8010441d:	75 02                	jne    80104421 <piperead+0x9b>
      break;
8010441f:	eb 3b                	jmp    8010445c <piperead+0xd6>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104424:	8b 45 0c             	mov    0xc(%ebp),%eax
80104427:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010442a:	8b 45 08             	mov    0x8(%ebp),%eax
8010442d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104433:	8d 48 01             	lea    0x1(%eax),%ecx
80104436:	8b 55 08             	mov    0x8(%ebp),%edx
80104439:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010443f:	25 ff 01 00 00       	and    $0x1ff,%eax
80104444:	89 c2                	mov    %eax,%edx
80104446:	8b 45 08             	mov    0x8(%ebp),%eax
80104449:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010444e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104450:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104457:	3b 45 10             	cmp    0x10(%ebp),%eax
8010445a:	7c ad                	jl     80104409 <piperead+0x83>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010445c:	8b 45 08             	mov    0x8(%ebp),%eax
8010445f:	05 38 02 00 00       	add    $0x238,%eax
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	50                   	push   %eax
80104468:	e8 ae 09 00 00       	call   80104e1b <wakeup>
8010446d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104470:	8b 45 08             	mov    0x8(%ebp),%eax
80104473:	83 ec 0c             	sub    $0xc,%esp
80104476:	50                   	push   %eax
80104477:	e8 50 0e 00 00       	call   801052cc <release>
8010447c:	83 c4 10             	add    $0x10,%esp
  return i;
8010447f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104485:	c9                   	leave  
80104486:	c3                   	ret    

80104487 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104487:	55                   	push   %ebp
80104488:	89 e5                	mov    %esp,%ebp
8010448a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010448d:	9c                   	pushf  
8010448e:	58                   	pop    %eax
8010448f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104492:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104495:	c9                   	leave  
80104496:	c3                   	ret    

80104497 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104497:	55                   	push   %ebp
80104498:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010449a:	fb                   	sti    
}
8010449b:	5d                   	pop    %ebp
8010449c:	c3                   	ret    

8010449d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010449d:	55                   	push   %ebp
8010449e:	89 e5                	mov    %esp,%ebp
801044a0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801044a3:	83 ec 08             	sub    $0x8,%esp
801044a6:	68 b5 8a 10 80       	push   $0x80108ab5
801044ab:	68 c0 2a 11 80       	push   $0x80112ac0
801044b0:	e8 90 0d 00 00       	call   80105245 <initlock>
801044b5:	83 c4 10             	add    $0x10,%esp
}
801044b8:	c9                   	leave  
801044b9:	c3                   	ret    

801044ba <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044ba:	55                   	push   %ebp
801044bb:	89 e5                	mov    %esp,%ebp
801044bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	68 c0 2a 11 80       	push   $0x80112ac0
801044c8:	e8 99 0d 00 00       	call   80105266 <acquire>
801044cd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044d0:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
801044d7:	eb 56                	jmp    8010452f <allocproc+0x75>
    if(p->state == UNUSED)
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	8b 40 0c             	mov    0xc(%eax),%eax
801044df:	85 c0                	test   %eax,%eax
801044e1:	75 48                	jne    8010452b <allocproc+0x71>
      goto found;
801044e3:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e7:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044ee:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044f3:	8d 50 01             	lea    0x1(%eax),%edx
801044f6:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ff:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104502:	83 ec 0c             	sub    $0xc,%esp
80104505:	68 c0 2a 11 80       	push   $0x80112ac0
8010450a:	e8 bd 0d 00 00       	call   801052cc <release>
8010450f:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104512:	e8 9c e7 ff ff       	call   80102cb3 <kalloc>
80104517:	89 c2                	mov    %eax,%edx
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	89 50 08             	mov    %edx,0x8(%eax)
8010451f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104522:	8b 40 08             	mov    0x8(%eax),%eax
80104525:	85 c0                	test   %eax,%eax
80104527:	75 37                	jne    80104560 <allocproc+0xa6>
80104529:	eb 24                	jmp    8010454f <allocproc+0x95>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010452b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010452f:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
80104536:	72 a1                	jb     801044d9 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104538:	83 ec 0c             	sub    $0xc,%esp
8010453b:	68 c0 2a 11 80       	push   $0x80112ac0
80104540:	e8 87 0d 00 00       	call   801052cc <release>
80104545:	83 c4 10             	add    $0x10,%esp
  return 0;
80104548:	b8 00 00 00 00       	mov    $0x0,%eax
8010454d:	eb 6e                	jmp    801045bd <allocproc+0x103>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104559:	b8 00 00 00 00       	mov    $0x0,%eax
8010455e:	eb 5d                	jmp    801045bd <allocproc+0x103>
  }
  sp = p->kstack + KSTACKSIZE;
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	8b 40 08             	mov    0x8(%eax),%eax
80104566:	05 00 10 00 00       	add    $0x1000,%eax
8010456b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010456e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104578:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010457b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010457f:	ba 0a 69 10 80       	mov    $0x8010690a,%edx
80104584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104587:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104589:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104593:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 1c             	mov    0x1c(%eax),%eax
8010459c:	83 ec 04             	sub    $0x4,%esp
8010459f:	6a 14                	push   $0x14
801045a1:	6a 00                	push   $0x0
801045a3:	50                   	push   %eax
801045a4:	e8 19 0f 00 00       	call   801054c2 <memset>
801045a9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045af:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b2:	ba 02 4d 10 80       	mov    $0x80104d02,%edx
801045b7:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045bd:	c9                   	leave  
801045be:	c3                   	ret    

801045bf <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045bf:	55                   	push   %ebp
801045c0:	89 e5                	mov    %esp,%ebp
801045c2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045c5:	e8 f0 fe ff ff       	call   801044ba <allocproc>
801045ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d0:	a3 a8 b6 10 80       	mov    %eax,0x8010b6a8
  if((p->pgdir = setupkvm()) == 0)
801045d5:	e8 e9 39 00 00       	call   80107fc3 <setupkvm>
801045da:	89 c2                	mov    %eax,%edx
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	89 50 04             	mov    %edx,0x4(%eax)
801045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e5:	8b 40 04             	mov    0x4(%eax),%eax
801045e8:	85 c0                	test   %eax,%eax
801045ea:	75 0d                	jne    801045f9 <userinit+0x3a>
    panic("userinit: out of memory?");
801045ec:	83 ec 0c             	sub    $0xc,%esp
801045ef:	68 bc 8a 10 80       	push   $0x80108abc
801045f4:	e8 63 bf ff ff       	call   8010055c <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045f9:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104601:	8b 40 04             	mov    0x4(%eax),%eax
80104604:	83 ec 04             	sub    $0x4,%esp
80104607:	52                   	push   %edx
80104608:	68 40 b5 10 80       	push   $0x8010b540
8010460d:	50                   	push   %eax
8010460e:	e8 07 3c 00 00       	call   8010821a <inituvm>
80104613:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104619:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010461f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104622:	8b 40 18             	mov    0x18(%eax),%eax
80104625:	83 ec 04             	sub    $0x4,%esp
80104628:	6a 4c                	push   $0x4c
8010462a:	6a 00                	push   $0x0
8010462c:	50                   	push   %eax
8010462d:	e8 90 0e 00 00       	call   801054c2 <memset>
80104632:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104638:	8b 40 18             	mov    0x18(%eax),%eax
8010463b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	8b 40 18             	mov    0x18(%eax),%eax
80104647:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010464d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104650:	8b 40 18             	mov    0x18(%eax),%eax
80104653:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104656:	8b 52 18             	mov    0x18(%edx),%edx
80104659:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010465d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104664:	8b 40 18             	mov    0x18(%eax),%eax
80104667:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010466a:	8b 52 18             	mov    0x18(%edx),%edx
8010466d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104671:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104678:	8b 40 18             	mov    0x18(%eax),%eax
8010467b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104685:	8b 40 18             	mov    0x18(%eax),%eax
80104688:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010468f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104692:	8b 40 18             	mov    0x18(%eax),%eax
80104695:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010469c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469f:	83 c0 6c             	add    $0x6c,%eax
801046a2:	83 ec 04             	sub    $0x4,%esp
801046a5:	6a 10                	push   $0x10
801046a7:	68 d5 8a 10 80       	push   $0x80108ad5
801046ac:	50                   	push   %eax
801046ad:	e8 15 10 00 00       	call   801056c7 <safestrcpy>
801046b2:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046b5:	83 ec 0c             	sub    $0xc,%esp
801046b8:	68 de 8a 10 80       	push   $0x80108ade
801046bd:	e8 fd de ff ff       	call   801025bf <namei>
801046c2:	83 c4 10             	add    $0x10,%esp
801046c5:	89 c2                	mov    %eax,%edx
801046c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ca:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046d7:	c9                   	leave  
801046d8:	c3                   	ret    

801046d9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046d9:	55                   	push   %ebp
801046da:	89 e5                	mov    %esp,%ebp
801046dc:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e5:	8b 00                	mov    (%eax),%eax
801046e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046ea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046ee:	7e 31                	jle    80104721 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046f0:	8b 55 08             	mov    0x8(%ebp),%edx
801046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f6:	01 c2                	add    %eax,%edx
801046f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fe:	8b 40 04             	mov    0x4(%eax),%eax
80104701:	83 ec 04             	sub    $0x4,%esp
80104704:	52                   	push   %edx
80104705:	ff 75 f4             	pushl  -0xc(%ebp)
80104708:	50                   	push   %eax
80104709:	e8 58 3c 00 00       	call   80108366 <allocuvm>
8010470e:	83 c4 10             	add    $0x10,%esp
80104711:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104714:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104718:	75 3e                	jne    80104758 <growproc+0x7f>
      return -1;
8010471a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471f:	eb 59                	jmp    8010477a <growproc+0xa1>
  } else if(n < 0){
80104721:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104725:	79 31                	jns    80104758 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104727:	8b 55 08             	mov    0x8(%ebp),%edx
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	01 c2                	add    %eax,%edx
8010472f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104735:	8b 40 04             	mov    0x4(%eax),%eax
80104738:	83 ec 04             	sub    $0x4,%esp
8010473b:	52                   	push   %edx
8010473c:	ff 75 f4             	pushl  -0xc(%ebp)
8010473f:	50                   	push   %eax
80104740:	e8 ea 3c 00 00       	call   8010842f <deallocuvm>
80104745:	83 c4 10             	add    $0x10,%esp
80104748:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010474b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010474f:	75 07                	jne    80104758 <growproc+0x7f>
      return -1;
80104751:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104756:	eb 22                	jmp    8010477a <growproc+0xa1>
  }
  proc->sz = sz;
80104758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104761:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104769:	83 ec 0c             	sub    $0xc,%esp
8010476c:	50                   	push   %eax
8010476d:	e8 36 39 00 00       	call   801080a8 <switchuvm>
80104772:	83 c4 10             	add    $0x10,%esp
  return 0;
80104775:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010477a:	c9                   	leave  
8010477b:	c3                   	ret    

8010477c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010477c:	55                   	push   %ebp
8010477d:	89 e5                	mov    %esp,%ebp
8010477f:	57                   	push   %edi
80104780:	56                   	push   %esi
80104781:	53                   	push   %ebx
80104782:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104785:	e8 30 fd ff ff       	call   801044ba <allocproc>
8010478a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010478d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104791:	75 0a                	jne    8010479d <fork+0x21>
    return -1;
80104793:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104798:	e9 68 01 00 00       	jmp    80104905 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010479d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a3:	8b 10                	mov    (%eax),%edx
801047a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ab:	8b 40 04             	mov    0x4(%eax),%eax
801047ae:	83 ec 08             	sub    $0x8,%esp
801047b1:	52                   	push   %edx
801047b2:	50                   	push   %eax
801047b3:	e8 13 3e 00 00       	call   801085cb <copyuvm>
801047b8:	83 c4 10             	add    $0x10,%esp
801047bb:	89 c2                	mov    %eax,%edx
801047bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c0:	89 50 04             	mov    %edx,0x4(%eax)
801047c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c6:	8b 40 04             	mov    0x4(%eax),%eax
801047c9:	85 c0                	test   %eax,%eax
801047cb:	75 30                	jne    801047fd <fork+0x81>
    kfree(np->kstack);
801047cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d0:	8b 40 08             	mov    0x8(%eax),%eax
801047d3:	83 ec 0c             	sub    $0xc,%esp
801047d6:	50                   	push   %eax
801047d7:	e8 3b e4 ff ff       	call   80102c17 <kfree>
801047dc:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f8:	e9 08 01 00 00       	jmp    80104905 <fork+0x189>
  }
  np->sz = proc->sz;
801047fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104803:	8b 10                	mov    (%eax),%edx
80104805:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104808:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010480a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104811:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104814:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104817:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481a:	8b 50 18             	mov    0x18(%eax),%edx
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 40 18             	mov    0x18(%eax),%eax
80104826:	89 c3                	mov    %eax,%ebx
80104828:	b8 13 00 00 00       	mov    $0x13,%eax
8010482d:	89 d7                	mov    %edx,%edi
8010482f:	89 de                	mov    %ebx,%esi
80104831:	89 c1                	mov    %eax,%ecx
80104833:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104835:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104838:	8b 40 18             	mov    0x18(%eax),%eax
8010483b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104842:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104849:	eb 43                	jmp    8010488e <fork+0x112>
    if(proc->ofile[i])
8010484b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104851:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104854:	83 c2 08             	add    $0x8,%edx
80104857:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010485b:	85 c0                	test   %eax,%eax
8010485d:	74 2b                	je     8010488a <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010485f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104865:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104868:	83 c2 08             	add    $0x8,%edx
8010486b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010486f:	83 ec 0c             	sub    $0xc,%esp
80104872:	50                   	push   %eax
80104873:	e8 4f c7 ff ff       	call   80100fc7 <filedup>
80104878:	83 c4 10             	add    $0x10,%esp
8010487b:	89 c1                	mov    %eax,%ecx
8010487d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104880:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104883:	83 c2 08             	add    $0x8,%edx
80104886:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010488a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010488e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104892:	7e b7                	jle    8010484b <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104894:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489a:	8b 40 68             	mov    0x68(%eax),%eax
8010489d:	83 ec 0c             	sub    $0xc,%esp
801048a0:	50                   	push   %eax
801048a1:	e8 07 d0 ff ff       	call   801018ad <idup>
801048a6:	83 c4 10             	add    $0x10,%esp
801048a9:	89 c2                	mov    %eax,%edx
801048ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ae:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b7:	8d 50 6c             	lea    0x6c(%eax),%edx
801048ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048bd:	83 c0 6c             	add    $0x6c,%eax
801048c0:	83 ec 04             	sub    $0x4,%esp
801048c3:	6a 10                	push   $0x10
801048c5:	52                   	push   %edx
801048c6:	50                   	push   %eax
801048c7:	e8 fb 0d 00 00       	call   801056c7 <safestrcpy>
801048cc:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d2:	8b 40 10             	mov    0x10(%eax),%eax
801048d5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048d8:	83 ec 0c             	sub    $0xc,%esp
801048db:	68 c0 2a 11 80       	push   $0x80112ac0
801048e0:	e8 81 09 00 00       	call   80105266 <acquire>
801048e5:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048eb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	68 c0 2a 11 80       	push   $0x80112ac0
801048fa:	e8 cd 09 00 00       	call   801052cc <release>
801048ff:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104902:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104905:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104908:	5b                   	pop    %ebx
80104909:	5e                   	pop    %esi
8010490a:	5f                   	pop    %edi
8010490b:	5d                   	pop    %ebp
8010490c:	c3                   	ret    

8010490d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010490d:	55                   	push   %ebp
8010490e:	89 e5                	mov    %esp,%ebp
80104910:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104913:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010491a:	a1 a8 b6 10 80       	mov    0x8010b6a8,%eax
8010491f:	39 c2                	cmp    %eax,%edx
80104921:	75 0d                	jne    80104930 <exit+0x23>
    panic("init exiting");
80104923:	83 ec 0c             	sub    $0xc,%esp
80104926:	68 e0 8a 10 80       	push   $0x80108ae0
8010492b:	e8 2c bc ff ff       	call   8010055c <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104930:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104937:	eb 48                	jmp    80104981 <exit+0x74>
    if(proc->ofile[fd]){
80104939:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104942:	83 c2 08             	add    $0x8,%edx
80104945:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104949:	85 c0                	test   %eax,%eax
8010494b:	74 30                	je     8010497d <exit+0x70>
      fileclose(proc->ofile[fd]);
8010494d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104953:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104956:	83 c2 08             	add    $0x8,%edx
80104959:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010495d:	83 ec 0c             	sub    $0xc,%esp
80104960:	50                   	push   %eax
80104961:	e8 b2 c6 ff ff       	call   80101018 <fileclose>
80104966:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104969:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104972:	83 c2 08             	add    $0x8,%edx
80104975:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010497c:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010497d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104981:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104985:	7e b2                	jle    80104939 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104987:	e8 08 ec ff ff       	call   80103594 <begin_op>
  iput(proc->cwd);
8010498c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104992:	8b 40 68             	mov    0x68(%eax),%eax
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	50                   	push   %eax
80104999:	e8 11 d1 ff ff       	call   80101aaf <iput>
8010499e:	83 c4 10             	add    $0x10,%esp
  end_op();
801049a1:	e8 7c ec ff ff       	call   80103622 <end_op>
  proc->cwd = 0;
801049a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ac:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049b3:	83 ec 0c             	sub    $0xc,%esp
801049b6:	68 c0 2a 11 80       	push   $0x80112ac0
801049bb:	e8 a6 08 00 00       	call   80105266 <acquire>
801049c0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c9:	8b 40 14             	mov    0x14(%eax),%eax
801049cc:	83 ec 0c             	sub    $0xc,%esp
801049cf:	50                   	push   %eax
801049d0:	e8 08 04 00 00       	call   80104ddd <wakeup1>
801049d5:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d8:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
801049df:	eb 3c                	jmp    80104a1d <exit+0x110>
    if(p->parent == proc){
801049e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e4:	8b 50 14             	mov    0x14(%eax),%edx
801049e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ed:	39 c2                	cmp    %eax,%edx
801049ef:	75 28                	jne    80104a19 <exit+0x10c>
      p->parent = initproc;
801049f1:	8b 15 a8 b6 10 80    	mov    0x8010b6a8,%edx
801049f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fa:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a00:	8b 40 0c             	mov    0xc(%eax),%eax
80104a03:	83 f8 05             	cmp    $0x5,%eax
80104a06:	75 11                	jne    80104a19 <exit+0x10c>
        wakeup1(initproc);
80104a08:	a1 a8 b6 10 80       	mov    0x8010b6a8,%eax
80104a0d:	83 ec 0c             	sub    $0xc,%esp
80104a10:	50                   	push   %eax
80104a11:	e8 c7 03 00 00       	call   80104ddd <wakeup1>
80104a16:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a19:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a1d:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
80104a24:	72 bb                	jb     801049e1 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a2c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a33:	e8 d5 01 00 00       	call   80104c0d <sched>
  panic("zombie exit");
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 ed 8a 10 80       	push   $0x80108aed
80104a40:	e8 17 bb ff ff       	call   8010055c <panic>

80104a45 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a45:	55                   	push   %ebp
80104a46:	89 e5                	mov    %esp,%ebp
80104a48:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	68 c0 2a 11 80       	push   $0x80112ac0
80104a53:	e8 0e 08 00 00       	call   80105266 <acquire>
80104a58:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a5b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a62:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
80104a69:	e9 a6 00 00 00       	jmp    80104b14 <wait+0xcf>
      if(p->parent != proc)
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	8b 50 14             	mov    0x14(%eax),%edx
80104a74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7a:	39 c2                	cmp    %eax,%edx
80104a7c:	74 05                	je     80104a83 <wait+0x3e>
        continue;
80104a7e:	e9 8d 00 00 00       	jmp    80104b10 <wait+0xcb>
      havekids = 1;
80104a83:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104a90:	83 f8 05             	cmp    $0x5,%eax
80104a93:	75 7b                	jne    80104b10 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 40 10             	mov    0x10(%eax),%eax
80104a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 08             	mov    0x8(%eax),%eax
80104aa4:	83 ec 0c             	sub    $0xc,%esp
80104aa7:	50                   	push   %eax
80104aa8:	e8 6a e1 ff ff       	call   80102c17 <kfree>
80104aad:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abd:	8b 40 04             	mov    0x4(%eax),%eax
80104ac0:	83 ec 0c             	sub    $0xc,%esp
80104ac3:	50                   	push   %eax
80104ac4:	e8 23 3a 00 00       	call   801084ec <freevm>
80104ac9:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104afb:	83 ec 0c             	sub    $0xc,%esp
80104afe:	68 c0 2a 11 80       	push   $0x80112ac0
80104b03:	e8 c4 07 00 00       	call   801052cc <release>
80104b08:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b0e:	eb 57                	jmp    80104b67 <wait+0x122>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b10:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b14:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
80104b1b:	0f 82 4d ff ff ff    	jb     80104a6e <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b25:	74 0d                	je     80104b34 <wait+0xef>
80104b27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2d:	8b 40 24             	mov    0x24(%eax),%eax
80104b30:	85 c0                	test   %eax,%eax
80104b32:	74 17                	je     80104b4b <wait+0x106>
      release(&ptable.lock);
80104b34:	83 ec 0c             	sub    $0xc,%esp
80104b37:	68 c0 2a 11 80       	push   $0x80112ac0
80104b3c:	e8 8b 07 00 00       	call   801052cc <release>
80104b41:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b49:	eb 1c                	jmp    80104b67 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b51:	83 ec 08             	sub    $0x8,%esp
80104b54:	68 c0 2a 11 80       	push   $0x80112ac0
80104b59:	50                   	push   %eax
80104b5a:	e8 d3 01 00 00       	call   80104d32 <sleep>
80104b5f:	83 c4 10             	add    $0x10,%esp
  }
80104b62:	e9 f4 fe ff ff       	jmp    80104a5b <wait+0x16>
}
80104b67:	c9                   	leave  
80104b68:	c3                   	ret    

80104b69 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b69:	55                   	push   %ebp
80104b6a:	89 e5                	mov    %esp,%ebp
80104b6c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b6f:	e8 23 f9 ff ff       	call   80104497 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b74:	83 ec 0c             	sub    $0xc,%esp
80104b77:	68 c0 2a 11 80       	push   $0x80112ac0
80104b7c:	e8 e5 06 00 00       	call   80105266 <acquire>
80104b81:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b84:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
80104b8b:	eb 62                	jmp    80104bef <scheduler+0x86>
      if(p->state != RUNNABLE)
80104b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b90:	8b 40 0c             	mov    0xc(%eax),%eax
80104b93:	83 f8 03             	cmp    $0x3,%eax
80104b96:	74 02                	je     80104b9a <scheduler+0x31>
        continue;
80104b98:	eb 51                	jmp    80104beb <scheduler+0x82>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ba3:	83 ec 0c             	sub    $0xc,%esp
80104ba6:	ff 75 f4             	pushl  -0xc(%ebp)
80104ba9:	e8 fa 34 00 00       	call   801080a8 <switchuvm>
80104bae:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc1:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bc4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bcb:	83 c2 04             	add    $0x4,%edx
80104bce:	83 ec 08             	sub    $0x8,%esp
80104bd1:	50                   	push   %eax
80104bd2:	52                   	push   %edx
80104bd3:	e8 60 0b 00 00       	call   80105738 <swtch>
80104bd8:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104bdb:	e8 ac 34 00 00       	call   8010808c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104be0:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104be7:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104beb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bef:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
80104bf6:	72 95                	jb     80104b8d <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104bf8:	83 ec 0c             	sub    $0xc,%esp
80104bfb:	68 c0 2a 11 80       	push   $0x80112ac0
80104c00:	e8 c7 06 00 00       	call   801052cc <release>
80104c05:	83 c4 10             	add    $0x10,%esp

  }
80104c08:	e9 62 ff ff ff       	jmp    80104b6f <scheduler+0x6>

80104c0d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c13:	83 ec 0c             	sub    $0xc,%esp
80104c16:	68 c0 2a 11 80       	push   $0x80112ac0
80104c1b:	e8 76 07 00 00       	call   80105396 <holding>
80104c20:	83 c4 10             	add    $0x10,%esp
80104c23:	85 c0                	test   %eax,%eax
80104c25:	75 0d                	jne    80104c34 <sched+0x27>
    panic("sched ptable.lock");
80104c27:	83 ec 0c             	sub    $0xc,%esp
80104c2a:	68 f9 8a 10 80       	push   $0x80108af9
80104c2f:	e8 28 b9 ff ff       	call   8010055c <panic>
  if(cpu->ncli != 1)
80104c34:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c3a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c40:	83 f8 01             	cmp    $0x1,%eax
80104c43:	74 0d                	je     80104c52 <sched+0x45>
    panic("sched locks");
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	68 0b 8b 10 80       	push   $0x80108b0b
80104c4d:	e8 0a b9 ff ff       	call   8010055c <panic>
  if(proc->state == RUNNING)
80104c52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c58:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5b:	83 f8 04             	cmp    $0x4,%eax
80104c5e:	75 0d                	jne    80104c6d <sched+0x60>
    panic("sched running");
80104c60:	83 ec 0c             	sub    $0xc,%esp
80104c63:	68 17 8b 10 80       	push   $0x80108b17
80104c68:	e8 ef b8 ff ff       	call   8010055c <panic>
  if(readeflags()&FL_IF)
80104c6d:	e8 15 f8 ff ff       	call   80104487 <readeflags>
80104c72:	25 00 02 00 00       	and    $0x200,%eax
80104c77:	85 c0                	test   %eax,%eax
80104c79:	74 0d                	je     80104c88 <sched+0x7b>
    panic("sched interruptible");
80104c7b:	83 ec 0c             	sub    $0xc,%esp
80104c7e:	68 25 8b 10 80       	push   $0x80108b25
80104c83:	e8 d4 b8 ff ff       	call   8010055c <panic>
  intena = cpu->intena;
80104c88:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c8e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c9d:	8b 40 04             	mov    0x4(%eax),%eax
80104ca0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ca7:	83 c2 1c             	add    $0x1c,%edx
80104caa:	83 ec 08             	sub    $0x8,%esp
80104cad:	50                   	push   %eax
80104cae:	52                   	push   %edx
80104caf:	e8 84 0a 00 00       	call   80105738 <swtch>
80104cb4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cb7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cc6:	c9                   	leave  
80104cc7:	c3                   	ret    

80104cc8 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cc8:	55                   	push   %ebp
80104cc9:	89 e5                	mov    %esp,%ebp
80104ccb:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cce:	83 ec 0c             	sub    $0xc,%esp
80104cd1:	68 c0 2a 11 80       	push   $0x80112ac0
80104cd6:	e8 8b 05 00 00       	call   80105266 <acquire>
80104cdb:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ceb:	e8 1d ff ff ff       	call   80104c0d <sched>
  release(&ptable.lock);
80104cf0:	83 ec 0c             	sub    $0xc,%esp
80104cf3:	68 c0 2a 11 80       	push   $0x80112ac0
80104cf8:	e8 cf 05 00 00       	call   801052cc <release>
80104cfd:	83 c4 10             	add    $0x10,%esp
}
80104d00:	c9                   	leave  
80104d01:	c3                   	ret    

80104d02 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d02:	55                   	push   %ebp
80104d03:	89 e5                	mov    %esp,%ebp
80104d05:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d08:	83 ec 0c             	sub    $0xc,%esp
80104d0b:	68 c0 2a 11 80       	push   $0x80112ac0
80104d10:	e8 b7 05 00 00       	call   801052cc <release>
80104d15:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d18:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d1d:	85 c0                	test   %eax,%eax
80104d1f:	74 0f                	je     80104d30 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d21:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d28:	00 00 00 
    initlog();
80104d2b:	e8 43 e6 ff ff       	call   80103373 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d30:	c9                   	leave  
80104d31:	c3                   	ret    

80104d32 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d32:	55                   	push   %ebp
80104d33:	89 e5                	mov    %esp,%ebp
80104d35:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3e:	85 c0                	test   %eax,%eax
80104d40:	75 0d                	jne    80104d4f <sleep+0x1d>
    panic("sleep");
80104d42:	83 ec 0c             	sub    $0xc,%esp
80104d45:	68 39 8b 10 80       	push   $0x80108b39
80104d4a:	e8 0d b8 ff ff       	call   8010055c <panic>

  if(lk == 0)
80104d4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d53:	75 0d                	jne    80104d62 <sleep+0x30>
    panic("sleep without lk");
80104d55:	83 ec 0c             	sub    $0xc,%esp
80104d58:	68 3f 8b 10 80       	push   $0x80108b3f
80104d5d:	e8 fa b7 ff ff       	call   8010055c <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d62:	81 7d 0c c0 2a 11 80 	cmpl   $0x80112ac0,0xc(%ebp)
80104d69:	74 1e                	je     80104d89 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d6b:	83 ec 0c             	sub    $0xc,%esp
80104d6e:	68 c0 2a 11 80       	push   $0x80112ac0
80104d73:	e8 ee 04 00 00       	call   80105266 <acquire>
80104d78:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d7b:	83 ec 0c             	sub    $0xc,%esp
80104d7e:	ff 75 0c             	pushl  0xc(%ebp)
80104d81:	e8 46 05 00 00       	call   801052cc <release>
80104d86:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104d89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80104d92:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d9b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104da2:	e8 66 fe ff ff       	call   80104c0d <sched>

  // Tidy up.
  proc->chan = 0;
80104da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dad:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104db4:	81 7d 0c c0 2a 11 80 	cmpl   $0x80112ac0,0xc(%ebp)
80104dbb:	74 1e                	je     80104ddb <sleep+0xa9>
    release(&ptable.lock);
80104dbd:	83 ec 0c             	sub    $0xc,%esp
80104dc0:	68 c0 2a 11 80       	push   $0x80112ac0
80104dc5:	e8 02 05 00 00       	call   801052cc <release>
80104dca:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104dcd:	83 ec 0c             	sub    $0xc,%esp
80104dd0:	ff 75 0c             	pushl  0xc(%ebp)
80104dd3:	e8 8e 04 00 00       	call   80105266 <acquire>
80104dd8:	83 c4 10             	add    $0x10,%esp
  }
}
80104ddb:	c9                   	leave  
80104ddc:	c3                   	ret    

80104ddd <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ddd:	55                   	push   %ebp
80104dde:	89 e5                	mov    %esp,%ebp
80104de0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104de3:	c7 45 fc f4 2a 11 80 	movl   $0x80112af4,-0x4(%ebp)
80104dea:	eb 24                	jmp    80104e10 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104def:	8b 40 0c             	mov    0xc(%eax),%eax
80104df2:	83 f8 02             	cmp    $0x2,%eax
80104df5:	75 15                	jne    80104e0c <wakeup1+0x2f>
80104df7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfa:	8b 40 20             	mov    0x20(%eax),%eax
80104dfd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e00:	75 0a                	jne    80104e0c <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e05:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e0c:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e10:	81 7d fc f4 49 11 80 	cmpl   $0x801149f4,-0x4(%ebp)
80104e17:	72 d3                	jb     80104dec <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e19:	c9                   	leave  
80104e1a:	c3                   	ret    

80104e1b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e1b:	55                   	push   %ebp
80104e1c:	89 e5                	mov    %esp,%ebp
80104e1e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e21:	83 ec 0c             	sub    $0xc,%esp
80104e24:	68 c0 2a 11 80       	push   $0x80112ac0
80104e29:	e8 38 04 00 00       	call   80105266 <acquire>
80104e2e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e31:	83 ec 0c             	sub    $0xc,%esp
80104e34:	ff 75 08             	pushl  0x8(%ebp)
80104e37:	e8 a1 ff ff ff       	call   80104ddd <wakeup1>
80104e3c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e3f:	83 ec 0c             	sub    $0xc,%esp
80104e42:	68 c0 2a 11 80       	push   $0x80112ac0
80104e47:	e8 80 04 00 00       	call   801052cc <release>
80104e4c:	83 c4 10             	add    $0x10,%esp
}
80104e4f:	c9                   	leave  
80104e50:	c3                   	ret    

80104e51 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e51:	55                   	push   %ebp
80104e52:	89 e5                	mov    %esp,%ebp
80104e54:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e57:	83 ec 0c             	sub    $0xc,%esp
80104e5a:	68 c0 2a 11 80       	push   $0x80112ac0
80104e5f:	e8 02 04 00 00       	call   80105266 <acquire>
80104e64:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e67:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
80104e6e:	eb 45                	jmp    80104eb5 <kill+0x64>
    if(p->pid == pid){
80104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e73:	8b 40 10             	mov    0x10(%eax),%eax
80104e76:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e79:	75 36                	jne    80104eb1 <kill+0x60>
      p->killed = 1;
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e88:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8b:	83 f8 02             	cmp    $0x2,%eax
80104e8e:	75 0a                	jne    80104e9a <kill+0x49>
        p->state = RUNNABLE;
80104e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e93:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e9a:	83 ec 0c             	sub    $0xc,%esp
80104e9d:	68 c0 2a 11 80       	push   $0x80112ac0
80104ea2:	e8 25 04 00 00       	call   801052cc <release>
80104ea7:	83 c4 10             	add    $0x10,%esp
      return 0;
80104eaa:	b8 00 00 00 00       	mov    $0x0,%eax
80104eaf:	eb 22                	jmp    80104ed3 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eb1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104eb5:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
80104ebc:	72 b2                	jb     80104e70 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ebe:	83 ec 0c             	sub    $0xc,%esp
80104ec1:	68 c0 2a 11 80       	push   $0x80112ac0
80104ec6:	e8 01 04 00 00       	call   801052cc <release>
80104ecb:	83 c4 10             	add    $0x10,%esp
  return -1;
80104ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed3:	c9                   	leave  
80104ed4:	c3                   	ret    

80104ed5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ed5:	55                   	push   %ebp
80104ed6:	89 e5                	mov    %esp,%ebp
80104ed8:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104edb:	c7 45 f0 f4 2a 11 80 	movl   $0x80112af4,-0x10(%ebp)
80104ee2:	e9 d5 00 00 00       	jmp    80104fbc <procdump+0xe7>
    if(p->state == UNUSED)
80104ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eea:	8b 40 0c             	mov    0xc(%eax),%eax
80104eed:	85 c0                	test   %eax,%eax
80104eef:	75 05                	jne    80104ef6 <procdump+0x21>
      continue;
80104ef1:	e9 c2 00 00 00       	jmp    80104fb8 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef9:	8b 40 0c             	mov    0xc(%eax),%eax
80104efc:	83 f8 05             	cmp    $0x5,%eax
80104eff:	77 23                	ja     80104f24 <procdump+0x4f>
80104f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f04:	8b 40 0c             	mov    0xc(%eax),%eax
80104f07:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f0e:	85 c0                	test   %eax,%eax
80104f10:	74 12                	je     80104f24 <procdump+0x4f>
      state = states[p->state];
80104f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f15:	8b 40 0c             	mov    0xc(%eax),%eax
80104f18:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f22:	eb 07                	jmp    80104f2b <procdump+0x56>
    else
      state = "???";
80104f24:	c7 45 ec 50 8b 10 80 	movl   $0x80108b50,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f34:	8b 40 10             	mov    0x10(%eax),%eax
80104f37:	52                   	push   %edx
80104f38:	ff 75 ec             	pushl  -0x14(%ebp)
80104f3b:	50                   	push   %eax
80104f3c:	68 54 8b 10 80       	push   $0x80108b54
80104f41:	e8 79 b4 ff ff       	call   801003bf <cprintf>
80104f46:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f4f:	83 f8 02             	cmp    $0x2,%eax
80104f52:	75 54                	jne    80104fa8 <procdump+0xd3>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f57:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f5a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5d:	83 c0 08             	add    $0x8,%eax
80104f60:	89 c2                	mov    %eax,%edx
80104f62:	83 ec 08             	sub    $0x8,%esp
80104f65:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f68:	50                   	push   %eax
80104f69:	52                   	push   %edx
80104f6a:	e8 ae 03 00 00       	call   8010531d <getcallerpcs>
80104f6f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f79:	eb 1c                	jmp    80104f97 <procdump+0xc2>
        cprintf(" %p", pc[i]);
80104f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f82:	83 ec 08             	sub    $0x8,%esp
80104f85:	50                   	push   %eax
80104f86:	68 5d 8b 10 80       	push   $0x80108b5d
80104f8b:	e8 2f b4 ff ff       	call   801003bf <cprintf>
80104f90:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f97:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f9b:	7f 0b                	jg     80104fa8 <procdump+0xd3>
80104f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fa4:	85 c0                	test   %eax,%eax
80104fa6:	75 d3                	jne    80104f7b <procdump+0xa6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104fa8:	83 ec 0c             	sub    $0xc,%esp
80104fab:	68 61 8b 10 80       	push   $0x80108b61
80104fb0:	e8 0a b4 ff ff       	call   801003bf <cprintf>
80104fb5:	83 c4 10             	add    $0x10,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fb8:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104fbc:	81 7d f0 f4 49 11 80 	cmpl   $0x801149f4,-0x10(%ebp)
80104fc3:	0f 82 1e ff ff ff    	jb     80104ee7 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fc9:	c9                   	leave  
80104fca:	c3                   	ret    

80104fcb <itoa>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"

int itoa(int n, char *str){
80104fcb:	55                   	push   %ebp
80104fcc:	89 e5                	mov    %esp,%ebp
80104fce:	53                   	push   %ebx
80104fcf:	83 ec 10             	sub    $0x10,%esp
	int temp, len;
	temp = n;
80104fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	len = 1;
80104fd8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while (temp/10!=0){
80104fdf:	eb 1f                	jmp    80105000 <itoa+0x35>
		len++;
80104fe1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		temp /= 10;
80104fe5:	8b 4d f8             	mov    -0x8(%ebp),%ecx
80104fe8:	ba 67 66 66 66       	mov    $0x66666667,%edx
80104fed:	89 c8                	mov    %ecx,%eax
80104fef:	f7 ea                	imul   %edx
80104ff1:	c1 fa 02             	sar    $0x2,%edx
80104ff4:	89 c8                	mov    %ecx,%eax
80104ff6:	c1 f8 1f             	sar    $0x1f,%eax
80104ff9:	29 c2                	sub    %eax,%edx
80104ffb:	89 d0                	mov    %edx,%eax
80104ffd:	89 45 f8             	mov    %eax,-0x8(%ebp)

int itoa(int n, char *str){
	int temp, len;
	temp = n;
	len = 1;
	while (temp/10!=0){
80105000:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105003:	83 c0 09             	add    $0x9,%eax
80105006:	83 f8 12             	cmp    $0x12,%eax
80105009:	77 d6                	ja     80104fe1 <itoa+0x16>
		len++;
		temp /= 10;
	}
	for (temp = len; temp > 0; temp--){
8010500b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500e:	89 45 f8             	mov    %eax,-0x8(%ebp)
80105011:	eb 55                	jmp    80105068 <itoa+0x9d>
		str[temp-1] = (n%10)+48;
80105013:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105016:	8d 50 ff             	lea    -0x1(%eax),%edx
80105019:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010501f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105022:	ba 67 66 66 66       	mov    $0x66666667,%edx
80105027:	89 c8                	mov    %ecx,%eax
80105029:	f7 ea                	imul   %edx
8010502b:	c1 fa 02             	sar    $0x2,%edx
8010502e:	89 c8                	mov    %ecx,%eax
80105030:	c1 f8 1f             	sar    $0x1f,%eax
80105033:	29 c2                	sub    %eax,%edx
80105035:	89 d0                	mov    %edx,%eax
80105037:	c1 e0 02             	shl    $0x2,%eax
8010503a:	01 d0                	add    %edx,%eax
8010503c:	01 c0                	add    %eax,%eax
8010503e:	29 c1                	sub    %eax,%ecx
80105040:	89 ca                	mov    %ecx,%edx
80105042:	89 d0                	mov    %edx,%eax
80105044:	83 c0 30             	add    $0x30,%eax
80105047:	88 03                	mov    %al,(%ebx)
		n/=10;
80105049:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010504c:	ba 67 66 66 66       	mov    $0x66666667,%edx
80105051:	89 c8                	mov    %ecx,%eax
80105053:	f7 ea                	imul   %edx
80105055:	c1 fa 02             	sar    $0x2,%edx
80105058:	89 c8                	mov    %ecx,%eax
8010505a:	c1 f8 1f             	sar    $0x1f,%eax
8010505d:	29 c2                	sub    %eax,%edx
8010505f:	89 d0                	mov    %edx,%eax
80105061:	89 45 08             	mov    %eax,0x8(%ebp)
	len = 1;
	while (temp/10!=0){
		len++;
		temp /= 10;
	}
	for (temp = len; temp > 0; temp--){
80105064:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105068:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
8010506c:	7f a5                	jg     80105013 <itoa+0x48>
		str[temp-1] = (n%10)+48;
		n/=10;
	}
	str[len]='\0';
8010506e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105071:	8b 45 0c             	mov    0xc(%ebp),%eax
80105074:	01 d0                	add    %edx,%eax
80105076:	c6 00 00             	movb   $0x0,(%eax)
	return len-1;
80105079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507c:	83 e8 01             	sub    $0x1,%eax
}
8010507f:	83 c4 10             	add    $0x10,%esp
80105082:	5b                   	pop    %ebx
80105083:	5d                   	pop    %ebp
80105084:	c3                   	ret    

80105085 <procfsisdir>:
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

int 
procfsisdir(struct inode *ip) {
80105085:	55                   	push   %ebp
80105086:	89 e5                	mov    %esp,%ebp
	return ip->minor == T_DIR;
80105088:	8b 45 08             	mov    0x8(%ebp),%eax
8010508b:	0f b7 40 14          	movzwl 0x14(%eax),%eax
8010508f:	66 83 f8 01          	cmp    $0x1,%ax
80105093:	0f 94 c0             	sete   %al
80105096:	0f b6 c0             	movzbl %al,%eax
}
80105099:	5d                   	pop    %ebp
8010509a:	c3                   	ret    

8010509b <procfsiread>:



void
procfsiread(struct inode* dp, struct inode *ip) {
8010509b:	55                   	push   %ebp
8010509c:	89 e5                	mov    %esp,%ebp

	ip->flags |= I_VALID;
8010509e:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a1:	8b 40 0c             	mov    0xc(%eax),%eax
801050a4:	83 c8 02             	or     $0x2,%eax
801050a7:	89 c2                	mov    %eax,%edx
801050a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ac:	89 50 0c             	mov    %edx,0xc(%eax)
	ip->type = T_DEV;
801050af:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b2:	66 c7 40 10 03 00    	movw   $0x3,0x10(%eax)
	ip->major = 2;
801050b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050bb:	66 c7 40 12 02 00    	movw   $0x2,0x12(%eax)
	//if ((ip->inum % 1000) == FDINFO || dp->inum == PROC_INUM)
	//	ip->minor = T_DIR;
	//else
		ip->minor = T_FILE;
801050c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c4:	66 c7 40 14 02 00    	movw   $0x2,0x14(%eax)
	ip->ref = 1;
801050ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801050cd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

}
801050d4:	5d                   	pop    %ebp
801050d5:	c3                   	ret    

801050d6 <procfsread>:

int
procfsread(struct inode *ip, char *dst, int off, int n) {
801050d6:	55                   	push   %ebp
801050d7:	89 e5                	mov    %esp,%ebp
801050d9:	83 ec 28             	sub    $0x28,%esp
	//cprintf("size of struct dirent: %d\n", sizeof(struct dirent));
	char pid_name[4];
	int len;
	struct proc *p;
	struct dirent *de = (struct dirent *)buf;
801050dc:	c7 45 f0 00 4a 11 80 	movl   $0x80114a00,-0x10(%ebp)
	char * prev = buf;
801050e3:	c7 45 ec 00 4a 11 80 	movl   $0x80114a00,-0x14(%ebp)

	//case /proc/
	if (namei("proc")==ip){
801050ea:	83 ec 0c             	sub    $0xc,%esp
801050ed:	68 b0 8b 10 80       	push   $0x80108bb0
801050f2:	e8 c8 d4 ff ff       	call   801025bf <namei>
801050f7:	83 c4 10             	add    $0x10,%esp
801050fa:	3b 45 08             	cmp    0x8(%ebp),%eax
801050fd:	0f 85 ce 00 00 00    	jne    801051d1 <procfsread+0xfb>
	acquire(&ptable.lock);
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	68 c0 2a 11 80       	push   $0x80112ac0
8010510b:	e8 56 01 00 00       	call   80105266 <acquire>
80105110:	83 c4 10             	add    $0x10,%esp
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105113:	c7 45 f4 f4 2a 11 80 	movl   $0x80112af4,-0xc(%ebp)
8010511a:	eb 7c                	jmp    80105198 <procfsread+0xc2>
			if(p->state != UNUSED && p->state != ZOMBIE){
8010511c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511f:	8b 40 0c             	mov    0xc(%eax),%eax
80105122:	85 c0                	test   %eax,%eax
80105124:	74 6e                	je     80105194 <procfsread+0xbe>
80105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105129:	8b 40 0c             	mov    0xc(%eax),%eax
8010512c:	83 f8 05             	cmp    $0x5,%eax
8010512f:	74 63                	je     80105194 <procfsread+0xbe>
				//PID
				len = itoa(p->pid, pid_name);
80105131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105134:	8b 40 10             	mov    0x10(%eax),%eax
80105137:	83 ec 08             	sub    $0x8,%esp
8010513a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
8010513d:	52                   	push   %edx
8010513e:	50                   	push   %eax
8010513f:	e8 87 fe ff ff       	call   80104fcb <itoa>
80105144:	83 c4 10             	add    $0x10,%esp
80105147:	89 45 e8             	mov    %eax,-0x18(%ebp)
				memmove(de->name, pid_name, len+1);
8010514a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010514d:	83 c0 01             	add    $0x1,%eax
80105150:	89 c1                	mov    %eax,%ecx
80105152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105155:	8d 50 02             	lea    0x2(%eax),%edx
80105158:	83 ec 04             	sub    $0x4,%esp
8010515b:	51                   	push   %ecx
8010515c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010515f:	50                   	push   %eax
80105160:	52                   	push   %edx
80105161:	e8 1b 04 00 00       	call   80105581 <memmove>
80105166:	83 c4 10             	add    $0x10,%esp
				//inode number
				de->inum = p->pid + 60000;
80105169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516c:	8b 40 10             	mov    0x10(%eax),%eax
8010516f:	8d 90 60 ea ff ff    	lea    -0x15a0(%eax),%edx
80105175:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105178:	66 89 10             	mov    %dx,(%eax)
				de  = (struct dirent *)prev+len+1+(sizeof (ushort));
8010517b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010517e:	83 c0 03             	add    $0x3,%eax
80105181:	c1 e0 04             	shl    $0x4,%eax
80105184:	89 c2                	mov    %eax,%edx
80105186:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105189:	01 d0                	add    %edx,%eax
8010518b:	89 45 f0             	mov    %eax,-0x10(%ebp)
				prev = (char *)de;
8010518e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105191:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char * prev = buf;

	//case /proc/
	if (namei("proc")==ip){
	acquire(&ptable.lock);
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105194:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105198:	81 7d f4 f4 49 11 80 	cmpl   $0x801149f4,-0xc(%ebp)
8010519f:	0f 82 77 ff ff ff    	jb     8010511c <procfsread+0x46>
				de->inum = p->pid + 60000;
				de  = (struct dirent *)prev+len+1+(sizeof (ushort));
				prev = (char *)de;
			}
		}
		memmove(dst, buf+off, n);
801051a5:	8b 45 14             	mov    0x14(%ebp),%eax
801051a8:	8b 55 10             	mov    0x10(%ebp),%edx
801051ab:	81 c2 00 4a 11 80    	add    $0x80114a00,%edx
801051b1:	83 ec 04             	sub    $0x4,%esp
801051b4:	50                   	push   %eax
801051b5:	52                   	push   %edx
801051b6:	ff 75 0c             	pushl  0xc(%ebp)
801051b9:	e8 c3 03 00 00       	call   80105581 <memmove>
801051be:	83 c4 10             	add    $0x10,%esp
//				cprintf("de->num: %d.\n", de->inum);
//				de  = (struct dirent *)prev+len+1+2;
//				prev = (char *)de;
//			}
//		}
			release(&ptable.lock);
801051c1:	83 ec 0c             	sub    $0xc,%esp
801051c4:	68 c0 2a 11 80       	push   $0x80112ac0
801051c9:	e8 fe 00 00 00       	call   801052cc <release>
801051ce:	83 c4 10             	add    $0x10,%esp
//	else if(){
//
//
//	}

	return 0;
801051d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051d6:	c9                   	leave  
801051d7:	c3                   	ret    

801051d8 <procfswrite>:

int
procfswrite(struct inode *ip, char *buf, int n)
{
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
  return 0;
801051db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e0:	5d                   	pop    %ebp
801051e1:	c3                   	ret    

801051e2 <procfsinit>:

void
procfsinit(void)
{
801051e2:	55                   	push   %ebp
801051e3:	89 e5                	mov    %esp,%ebp
  devsw[PROCFS].isdir = procfsisdir;
801051e5:	c7 05 a0 12 11 80 85 	movl   $0x80105085,0x801112a0
801051ec:	50 10 80 
  devsw[PROCFS].iread = procfsiread;
801051ef:	c7 05 a4 12 11 80 9b 	movl   $0x8010509b,0x801112a4
801051f6:	50 10 80 
  devsw[PROCFS].write = procfswrite;
801051f9:	c7 05 ac 12 11 80 d8 	movl   $0x801051d8,0x801112ac
80105200:	51 10 80 
  devsw[PROCFS].read = procfsread;
80105203:	c7 05 a8 12 11 80 d6 	movl   $0x801050d6,0x801112a8
8010520a:	50 10 80 
}
8010520d:	5d                   	pop    %ebp
8010520e:	c3                   	ret    

8010520f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010520f:	55                   	push   %ebp
80105210:	89 e5                	mov    %esp,%ebp
80105212:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105215:	9c                   	pushf  
80105216:	58                   	pop    %eax
80105217:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010521a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010521d:	c9                   	leave  
8010521e:	c3                   	ret    

8010521f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010521f:	55                   	push   %ebp
80105220:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105222:	fa                   	cli    
}
80105223:	5d                   	pop    %ebp
80105224:	c3                   	ret    

80105225 <sti>:

static inline void
sti(void)
{
80105225:	55                   	push   %ebp
80105226:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105228:	fb                   	sti    
}
80105229:	5d                   	pop    %ebp
8010522a:	c3                   	ret    

8010522b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010522b:	55                   	push   %ebp
8010522c:	89 e5                	mov    %esp,%ebp
8010522e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105231:	8b 55 08             	mov    0x8(%ebp),%edx
80105234:	8b 45 0c             	mov    0xc(%ebp),%eax
80105237:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010523a:	f0 87 02             	lock xchg %eax,(%edx)
8010523d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105240:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105243:	c9                   	leave  
80105244:	c3                   	ret    

80105245 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105245:	55                   	push   %ebp
80105246:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105248:	8b 45 08             	mov    0x8(%ebp),%eax
8010524b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010524e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105251:	8b 45 08             	mov    0x8(%ebp),%eax
80105254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010525a:	8b 45 08             	mov    0x8(%ebp),%eax
8010525d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105264:	5d                   	pop    %ebp
80105265:	c3                   	ret    

80105266 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105266:	55                   	push   %ebp
80105267:	89 e5                	mov    %esp,%ebp
80105269:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010526c:	e8 4f 01 00 00       	call   801053c0 <pushcli>
  if(holding(lk))
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	83 ec 0c             	sub    $0xc,%esp
80105277:	50                   	push   %eax
80105278:	e8 19 01 00 00       	call   80105396 <holding>
8010527d:	83 c4 10             	add    $0x10,%esp
80105280:	85 c0                	test   %eax,%eax
80105282:	74 0d                	je     80105291 <acquire+0x2b>
    panic("acquire");
80105284:	83 ec 0c             	sub    $0xc,%esp
80105287:	68 b5 8b 10 80       	push   $0x80108bb5
8010528c:	e8 cb b2 ff ff       	call   8010055c <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105291:	90                   	nop
80105292:	8b 45 08             	mov    0x8(%ebp),%eax
80105295:	83 ec 08             	sub    $0x8,%esp
80105298:	6a 01                	push   $0x1
8010529a:	50                   	push   %eax
8010529b:	e8 8b ff ff ff       	call   8010522b <xchg>
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	85 c0                	test   %eax,%eax
801052a5:	75 eb                	jne    80105292 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801052a7:	8b 45 08             	mov    0x8(%ebp),%eax
801052aa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801052b1:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801052b4:	8b 45 08             	mov    0x8(%ebp),%eax
801052b7:	83 c0 0c             	add    $0xc,%eax
801052ba:	83 ec 08             	sub    $0x8,%esp
801052bd:	50                   	push   %eax
801052be:	8d 45 08             	lea    0x8(%ebp),%eax
801052c1:	50                   	push   %eax
801052c2:	e8 56 00 00 00       	call   8010531d <getcallerpcs>
801052c7:	83 c4 10             	add    $0x10,%esp
}
801052ca:	c9                   	leave  
801052cb:	c3                   	ret    

801052cc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801052cc:	55                   	push   %ebp
801052cd:	89 e5                	mov    %esp,%ebp
801052cf:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801052d2:	83 ec 0c             	sub    $0xc,%esp
801052d5:	ff 75 08             	pushl  0x8(%ebp)
801052d8:	e8 b9 00 00 00       	call   80105396 <holding>
801052dd:	83 c4 10             	add    $0x10,%esp
801052e0:	85 c0                	test   %eax,%eax
801052e2:	75 0d                	jne    801052f1 <release+0x25>
    panic("release");
801052e4:	83 ec 0c             	sub    $0xc,%esp
801052e7:	68 bd 8b 10 80       	push   $0x80108bbd
801052ec:	e8 6b b2 ff ff       	call   8010055c <panic>

  lk->pcs[0] = 0;
801052f1:	8b 45 08             	mov    0x8(%ebp),%eax
801052f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801052fb:	8b 45 08             	mov    0x8(%ebp),%eax
801052fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105305:	8b 45 08             	mov    0x8(%ebp),%eax
80105308:	83 ec 08             	sub    $0x8,%esp
8010530b:	6a 00                	push   $0x0
8010530d:	50                   	push   %eax
8010530e:	e8 18 ff ff ff       	call   8010522b <xchg>
80105313:	83 c4 10             	add    $0x10,%esp

  popcli();
80105316:	e8 e9 00 00 00       	call   80105404 <popcli>
}
8010531b:	c9                   	leave  
8010531c:	c3                   	ret    

8010531d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010531d:	55                   	push   %ebp
8010531e:	89 e5                	mov    %esp,%ebp
80105320:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105323:	8b 45 08             	mov    0x8(%ebp),%eax
80105326:	83 e8 08             	sub    $0x8,%eax
80105329:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010532c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105333:	eb 38                	jmp    8010536d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105335:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105339:	74 38                	je     80105373 <getcallerpcs+0x56>
8010533b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105342:	76 2f                	jbe    80105373 <getcallerpcs+0x56>
80105344:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105348:	74 29                	je     80105373 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010534a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010534d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105354:	8b 45 0c             	mov    0xc(%ebp),%eax
80105357:	01 c2                	add    %eax,%edx
80105359:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010535c:	8b 40 04             	mov    0x4(%eax),%eax
8010535f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105361:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105364:	8b 00                	mov    (%eax),%eax
80105366:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105369:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010536d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105371:	7e c2                	jle    80105335 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105373:	eb 19                	jmp    8010538e <getcallerpcs+0x71>
    pcs[i] = 0;
80105375:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105378:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010537f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105382:	01 d0                	add    %edx,%eax
80105384:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010538a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010538e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105392:	7e e1                	jle    80105375 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105394:	c9                   	leave  
80105395:	c3                   	ret    

80105396 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105396:	55                   	push   %ebp
80105397:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105399:	8b 45 08             	mov    0x8(%ebp),%eax
8010539c:	8b 00                	mov    (%eax),%eax
8010539e:	85 c0                	test   %eax,%eax
801053a0:	74 17                	je     801053b9 <holding+0x23>
801053a2:	8b 45 08             	mov    0x8(%ebp),%eax
801053a5:	8b 50 08             	mov    0x8(%eax),%edx
801053a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053ae:	39 c2                	cmp    %eax,%edx
801053b0:	75 07                	jne    801053b9 <holding+0x23>
801053b2:	b8 01 00 00 00       	mov    $0x1,%eax
801053b7:	eb 05                	jmp    801053be <holding+0x28>
801053b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053be:	5d                   	pop    %ebp
801053bf:	c3                   	ret    

801053c0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801053c0:	55                   	push   %ebp
801053c1:	89 e5                	mov    %esp,%ebp
801053c3:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801053c6:	e8 44 fe ff ff       	call   8010520f <readeflags>
801053cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801053ce:	e8 4c fe ff ff       	call   8010521f <cli>
  if(cpu->ncli++ == 0)
801053d3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801053da:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801053e0:	8d 48 01             	lea    0x1(%eax),%ecx
801053e3:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801053e9:	85 c0                	test   %eax,%eax
801053eb:	75 15                	jne    80105402 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801053ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053f6:	81 e2 00 02 00 00    	and    $0x200,%edx
801053fc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105402:	c9                   	leave  
80105403:	c3                   	ret    

80105404 <popcli>:

void
popcli(void)
{
80105404:	55                   	push   %ebp
80105405:	89 e5                	mov    %esp,%ebp
80105407:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010540a:	e8 00 fe ff ff       	call   8010520f <readeflags>
8010540f:	25 00 02 00 00       	and    $0x200,%eax
80105414:	85 c0                	test   %eax,%eax
80105416:	74 0d                	je     80105425 <popcli+0x21>
    panic("popcli - interruptible");
80105418:	83 ec 0c             	sub    $0xc,%esp
8010541b:	68 c5 8b 10 80       	push   $0x80108bc5
80105420:	e8 37 b1 ff ff       	call   8010055c <panic>
  if(--cpu->ncli < 0)
80105425:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010542b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105431:	83 ea 01             	sub    $0x1,%edx
80105434:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010543a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105440:	85 c0                	test   %eax,%eax
80105442:	79 0d                	jns    80105451 <popcli+0x4d>
    panic("popcli");
80105444:	83 ec 0c             	sub    $0xc,%esp
80105447:	68 dc 8b 10 80       	push   $0x80108bdc
8010544c:	e8 0b b1 ff ff       	call   8010055c <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105451:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105457:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010545d:	85 c0                	test   %eax,%eax
8010545f:	75 15                	jne    80105476 <popcli+0x72>
80105461:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105467:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010546d:	85 c0                	test   %eax,%eax
8010546f:	74 05                	je     80105476 <popcli+0x72>
    sti();
80105471:	e8 af fd ff ff       	call   80105225 <sti>
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	57                   	push   %edi
8010547c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010547d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105480:	8b 55 10             	mov    0x10(%ebp),%edx
80105483:	8b 45 0c             	mov    0xc(%ebp),%eax
80105486:	89 cb                	mov    %ecx,%ebx
80105488:	89 df                	mov    %ebx,%edi
8010548a:	89 d1                	mov    %edx,%ecx
8010548c:	fc                   	cld    
8010548d:	f3 aa                	rep stos %al,%es:(%edi)
8010548f:	89 ca                	mov    %ecx,%edx
80105491:	89 fb                	mov    %edi,%ebx
80105493:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105496:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105499:	5b                   	pop    %ebx
8010549a:	5f                   	pop    %edi
8010549b:	5d                   	pop    %ebp
8010549c:	c3                   	ret    

8010549d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010549d:	55                   	push   %ebp
8010549e:	89 e5                	mov    %esp,%ebp
801054a0:	57                   	push   %edi
801054a1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054a5:	8b 55 10             	mov    0x10(%ebp),%edx
801054a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ab:	89 cb                	mov    %ecx,%ebx
801054ad:	89 df                	mov    %ebx,%edi
801054af:	89 d1                	mov    %edx,%ecx
801054b1:	fc                   	cld    
801054b2:	f3 ab                	rep stos %eax,%es:(%edi)
801054b4:	89 ca                	mov    %ecx,%edx
801054b6:	89 fb                	mov    %edi,%ebx
801054b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054bb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054be:	5b                   	pop    %ebx
801054bf:	5f                   	pop    %edi
801054c0:	5d                   	pop    %ebp
801054c1:	c3                   	ret    

801054c2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054c2:	55                   	push   %ebp
801054c3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
801054c8:	83 e0 03             	and    $0x3,%eax
801054cb:	85 c0                	test   %eax,%eax
801054cd:	75 43                	jne    80105512 <memset+0x50>
801054cf:	8b 45 10             	mov    0x10(%ebp),%eax
801054d2:	83 e0 03             	and    $0x3,%eax
801054d5:	85 c0                	test   %eax,%eax
801054d7:	75 39                	jne    80105512 <memset+0x50>
    c &= 0xFF;
801054d9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801054e0:	8b 45 10             	mov    0x10(%ebp),%eax
801054e3:	c1 e8 02             	shr    $0x2,%eax
801054e6:	89 c1                	mov    %eax,%ecx
801054e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054eb:	c1 e0 18             	shl    $0x18,%eax
801054ee:	89 c2                	mov    %eax,%edx
801054f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f3:	c1 e0 10             	shl    $0x10,%eax
801054f6:	09 c2                	or     %eax,%edx
801054f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054fb:	c1 e0 08             	shl    $0x8,%eax
801054fe:	09 d0                	or     %edx,%eax
80105500:	0b 45 0c             	or     0xc(%ebp),%eax
80105503:	51                   	push   %ecx
80105504:	50                   	push   %eax
80105505:	ff 75 08             	pushl  0x8(%ebp)
80105508:	e8 90 ff ff ff       	call   8010549d <stosl>
8010550d:	83 c4 0c             	add    $0xc,%esp
80105510:	eb 12                	jmp    80105524 <memset+0x62>
  } else
    stosb(dst, c, n);
80105512:	8b 45 10             	mov    0x10(%ebp),%eax
80105515:	50                   	push   %eax
80105516:	ff 75 0c             	pushl  0xc(%ebp)
80105519:	ff 75 08             	pushl  0x8(%ebp)
8010551c:	e8 57 ff ff ff       	call   80105478 <stosb>
80105521:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105524:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105527:	c9                   	leave  
80105528:	c3                   	ret    

80105529 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105529:	55                   	push   %ebp
8010552a:	89 e5                	mov    %esp,%ebp
8010552c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010552f:	8b 45 08             	mov    0x8(%ebp),%eax
80105532:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105535:	8b 45 0c             	mov    0xc(%ebp),%eax
80105538:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010553b:	eb 30                	jmp    8010556d <memcmp+0x44>
    if(*s1 != *s2)
8010553d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105540:	0f b6 10             	movzbl (%eax),%edx
80105543:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105546:	0f b6 00             	movzbl (%eax),%eax
80105549:	38 c2                	cmp    %al,%dl
8010554b:	74 18                	je     80105565 <memcmp+0x3c>
      return *s1 - *s2;
8010554d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105550:	0f b6 00             	movzbl (%eax),%eax
80105553:	0f b6 d0             	movzbl %al,%edx
80105556:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105559:	0f b6 00             	movzbl (%eax),%eax
8010555c:	0f b6 c0             	movzbl %al,%eax
8010555f:	29 c2                	sub    %eax,%edx
80105561:	89 d0                	mov    %edx,%eax
80105563:	eb 1a                	jmp    8010557f <memcmp+0x56>
    s1++, s2++;
80105565:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105569:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010556d:	8b 45 10             	mov    0x10(%ebp),%eax
80105570:	8d 50 ff             	lea    -0x1(%eax),%edx
80105573:	89 55 10             	mov    %edx,0x10(%ebp)
80105576:	85 c0                	test   %eax,%eax
80105578:	75 c3                	jne    8010553d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010557a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010557f:	c9                   	leave  
80105580:	c3                   	ret    

80105581 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105581:	55                   	push   %ebp
80105582:	89 e5                	mov    %esp,%ebp
80105584:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105587:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
80105590:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105593:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105596:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105599:	73 3d                	jae    801055d8 <memmove+0x57>
8010559b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010559e:	8b 45 10             	mov    0x10(%ebp),%eax
801055a1:	01 d0                	add    %edx,%eax
801055a3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055a6:	76 30                	jbe    801055d8 <memmove+0x57>
    s += n;
801055a8:	8b 45 10             	mov    0x10(%ebp),%eax
801055ab:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801055ae:	8b 45 10             	mov    0x10(%ebp),%eax
801055b1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801055b4:	eb 13                	jmp    801055c9 <memmove+0x48>
      *--d = *--s;
801055b6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801055ba:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801055be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c1:	0f b6 10             	movzbl (%eax),%edx
801055c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055c7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801055c9:	8b 45 10             	mov    0x10(%ebp),%eax
801055cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801055cf:	89 55 10             	mov    %edx,0x10(%ebp)
801055d2:	85 c0                	test   %eax,%eax
801055d4:	75 e0                	jne    801055b6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801055d6:	eb 26                	jmp    801055fe <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801055d8:	eb 17                	jmp    801055f1 <memmove+0x70>
      *d++ = *s++;
801055da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055dd:	8d 50 01             	lea    0x1(%eax),%edx
801055e0:	89 55 f8             	mov    %edx,-0x8(%ebp)
801055e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055e6:	8d 4a 01             	lea    0x1(%edx),%ecx
801055e9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801055ec:	0f b6 12             	movzbl (%edx),%edx
801055ef:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801055f1:	8b 45 10             	mov    0x10(%ebp),%eax
801055f4:	8d 50 ff             	lea    -0x1(%eax),%edx
801055f7:	89 55 10             	mov    %edx,0x10(%ebp)
801055fa:	85 c0                	test   %eax,%eax
801055fc:	75 dc                	jne    801055da <memmove+0x59>
      *d++ = *s++;

  return dst;
801055fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105601:	c9                   	leave  
80105602:	c3                   	ret    

80105603 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105603:	55                   	push   %ebp
80105604:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105606:	ff 75 10             	pushl  0x10(%ebp)
80105609:	ff 75 0c             	pushl  0xc(%ebp)
8010560c:	ff 75 08             	pushl  0x8(%ebp)
8010560f:	e8 6d ff ff ff       	call   80105581 <memmove>
80105614:	83 c4 0c             	add    $0xc,%esp
}
80105617:	c9                   	leave  
80105618:	c3                   	ret    

80105619 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105619:	55                   	push   %ebp
8010561a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010561c:	eb 0c                	jmp    8010562a <strncmp+0x11>
    n--, p++, q++;
8010561e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105622:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105626:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010562a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010562e:	74 1a                	je     8010564a <strncmp+0x31>
80105630:	8b 45 08             	mov    0x8(%ebp),%eax
80105633:	0f b6 00             	movzbl (%eax),%eax
80105636:	84 c0                	test   %al,%al
80105638:	74 10                	je     8010564a <strncmp+0x31>
8010563a:	8b 45 08             	mov    0x8(%ebp),%eax
8010563d:	0f b6 10             	movzbl (%eax),%edx
80105640:	8b 45 0c             	mov    0xc(%ebp),%eax
80105643:	0f b6 00             	movzbl (%eax),%eax
80105646:	38 c2                	cmp    %al,%dl
80105648:	74 d4                	je     8010561e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010564a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010564e:	75 07                	jne    80105657 <strncmp+0x3e>
    return 0;
80105650:	b8 00 00 00 00       	mov    $0x0,%eax
80105655:	eb 16                	jmp    8010566d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105657:	8b 45 08             	mov    0x8(%ebp),%eax
8010565a:	0f b6 00             	movzbl (%eax),%eax
8010565d:	0f b6 d0             	movzbl %al,%edx
80105660:	8b 45 0c             	mov    0xc(%ebp),%eax
80105663:	0f b6 00             	movzbl (%eax),%eax
80105666:	0f b6 c0             	movzbl %al,%eax
80105669:	29 c2                	sub    %eax,%edx
8010566b:	89 d0                	mov    %edx,%eax
}
8010566d:	5d                   	pop    %ebp
8010566e:	c3                   	ret    

8010566f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105675:	8b 45 08             	mov    0x8(%ebp),%eax
80105678:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010567b:	90                   	nop
8010567c:	8b 45 10             	mov    0x10(%ebp),%eax
8010567f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105682:	89 55 10             	mov    %edx,0x10(%ebp)
80105685:	85 c0                	test   %eax,%eax
80105687:	7e 1e                	jle    801056a7 <strncpy+0x38>
80105689:	8b 45 08             	mov    0x8(%ebp),%eax
8010568c:	8d 50 01             	lea    0x1(%eax),%edx
8010568f:	89 55 08             	mov    %edx,0x8(%ebp)
80105692:	8b 55 0c             	mov    0xc(%ebp),%edx
80105695:	8d 4a 01             	lea    0x1(%edx),%ecx
80105698:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010569b:	0f b6 12             	movzbl (%edx),%edx
8010569e:	88 10                	mov    %dl,(%eax)
801056a0:	0f b6 00             	movzbl (%eax),%eax
801056a3:	84 c0                	test   %al,%al
801056a5:	75 d5                	jne    8010567c <strncpy+0xd>
    ;
  while(n-- > 0)
801056a7:	eb 0c                	jmp    801056b5 <strncpy+0x46>
    *s++ = 0;
801056a9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ac:	8d 50 01             	lea    0x1(%eax),%edx
801056af:	89 55 08             	mov    %edx,0x8(%ebp)
801056b2:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801056b5:	8b 45 10             	mov    0x10(%ebp),%eax
801056b8:	8d 50 ff             	lea    -0x1(%eax),%edx
801056bb:	89 55 10             	mov    %edx,0x10(%ebp)
801056be:	85 c0                	test   %eax,%eax
801056c0:	7f e7                	jg     801056a9 <strncpy+0x3a>
    *s++ = 0;
  return os;
801056c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056c5:	c9                   	leave  
801056c6:	c3                   	ret    

801056c7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801056c7:	55                   	push   %ebp
801056c8:	89 e5                	mov    %esp,%ebp
801056ca:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801056cd:	8b 45 08             	mov    0x8(%ebp),%eax
801056d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801056d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056d7:	7f 05                	jg     801056de <safestrcpy+0x17>
    return os;
801056d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056dc:	eb 31                	jmp    8010570f <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801056de:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056e6:	7e 1e                	jle    80105706 <safestrcpy+0x3f>
801056e8:	8b 45 08             	mov    0x8(%ebp),%eax
801056eb:	8d 50 01             	lea    0x1(%eax),%edx
801056ee:	89 55 08             	mov    %edx,0x8(%ebp)
801056f1:	8b 55 0c             	mov    0xc(%ebp),%edx
801056f4:	8d 4a 01             	lea    0x1(%edx),%ecx
801056f7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801056fa:	0f b6 12             	movzbl (%edx),%edx
801056fd:	88 10                	mov    %dl,(%eax)
801056ff:	0f b6 00             	movzbl (%eax),%eax
80105702:	84 c0                	test   %al,%al
80105704:	75 d8                	jne    801056de <safestrcpy+0x17>
    ;
  *s = 0;
80105706:	8b 45 08             	mov    0x8(%ebp),%eax
80105709:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010570c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010570f:	c9                   	leave  
80105710:	c3                   	ret    

80105711 <strlen>:

int
strlen(const char *s)
{
80105711:	55                   	push   %ebp
80105712:	89 e5                	mov    %esp,%ebp
80105714:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105717:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010571e:	eb 04                	jmp    80105724 <strlen+0x13>
80105720:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105724:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105727:	8b 45 08             	mov    0x8(%ebp),%eax
8010572a:	01 d0                	add    %edx,%eax
8010572c:	0f b6 00             	movzbl (%eax),%eax
8010572f:	84 c0                	test   %al,%al
80105731:	75 ed                	jne    80105720 <strlen+0xf>
    ;
  return n;
80105733:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105736:	c9                   	leave  
80105737:	c3                   	ret    

80105738 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105738:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010573c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105740:	55                   	push   %ebp
  pushl %ebx
80105741:	53                   	push   %ebx
  pushl %esi
80105742:	56                   	push   %esi
  pushl %edi
80105743:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105744:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105746:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105748:	5f                   	pop    %edi
  popl %esi
80105749:	5e                   	pop    %esi
  popl %ebx
8010574a:	5b                   	pop    %ebx
  popl %ebp
8010574b:	5d                   	pop    %ebp
  ret
8010574c:	c3                   	ret    

8010574d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010574d:	55                   	push   %ebp
8010574e:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105756:	8b 00                	mov    (%eax),%eax
80105758:	3b 45 08             	cmp    0x8(%ebp),%eax
8010575b:	76 12                	jbe    8010576f <fetchint+0x22>
8010575d:	8b 45 08             	mov    0x8(%ebp),%eax
80105760:	8d 50 04             	lea    0x4(%eax),%edx
80105763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105769:	8b 00                	mov    (%eax),%eax
8010576b:	39 c2                	cmp    %eax,%edx
8010576d:	76 07                	jbe    80105776 <fetchint+0x29>
    return -1;
8010576f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105774:	eb 0f                	jmp    80105785 <fetchint+0x38>
  *ip = *(int*)(addr);
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	8b 10                	mov    (%eax),%edx
8010577b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577e:	89 10                	mov    %edx,(%eax)
  return 0;
80105780:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105785:	5d                   	pop    %ebp
80105786:	c3                   	ret    

80105787 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105787:	55                   	push   %ebp
80105788:	89 e5                	mov    %esp,%ebp
8010578a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010578d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105793:	8b 00                	mov    (%eax),%eax
80105795:	3b 45 08             	cmp    0x8(%ebp),%eax
80105798:	77 07                	ja     801057a1 <fetchstr+0x1a>
    return -1;
8010579a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579f:	eb 46                	jmp    801057e7 <fetchstr+0x60>
  *pp = (char*)addr;
801057a1:	8b 55 08             	mov    0x8(%ebp),%edx
801057a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a7:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801057a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057af:	8b 00                	mov    (%eax),%eax
801057b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801057b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b7:	8b 00                	mov    (%eax),%eax
801057b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801057bc:	eb 1c                	jmp    801057da <fetchstr+0x53>
    if(*s == 0)
801057be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c1:	0f b6 00             	movzbl (%eax),%eax
801057c4:	84 c0                	test   %al,%al
801057c6:	75 0e                	jne    801057d6 <fetchstr+0x4f>
      return s - *pp;
801057c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ce:	8b 00                	mov    (%eax),%eax
801057d0:	29 c2                	sub    %eax,%edx
801057d2:	89 d0                	mov    %edx,%eax
801057d4:	eb 11                	jmp    801057e7 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801057d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057dd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057e0:	72 dc                	jb     801057be <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801057e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e7:	c9                   	leave  
801057e8:	c3                   	ret    

801057e9 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801057e9:	55                   	push   %ebp
801057ea:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801057ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f2:	8b 40 18             	mov    0x18(%eax),%eax
801057f5:	8b 40 44             	mov    0x44(%eax),%eax
801057f8:	8b 55 08             	mov    0x8(%ebp),%edx
801057fb:	c1 e2 02             	shl    $0x2,%edx
801057fe:	01 d0                	add    %edx,%eax
80105800:	83 c0 04             	add    $0x4,%eax
80105803:	ff 75 0c             	pushl  0xc(%ebp)
80105806:	50                   	push   %eax
80105807:	e8 41 ff ff ff       	call   8010574d <fetchint>
8010580c:	83 c4 08             	add    $0x8,%esp
}
8010580f:	c9                   	leave  
80105810:	c3                   	ret    

80105811 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105811:	55                   	push   %ebp
80105812:	89 e5                	mov    %esp,%ebp
80105814:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105817:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010581a:	50                   	push   %eax
8010581b:	ff 75 08             	pushl  0x8(%ebp)
8010581e:	e8 c6 ff ff ff       	call   801057e9 <argint>
80105823:	83 c4 08             	add    $0x8,%esp
80105826:	85 c0                	test   %eax,%eax
80105828:	79 07                	jns    80105831 <argptr+0x20>
    return -1;
8010582a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582f:	eb 3d                	jmp    8010586e <argptr+0x5d>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105831:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105834:	89 c2                	mov    %eax,%edx
80105836:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583c:	8b 00                	mov    (%eax),%eax
8010583e:	39 c2                	cmp    %eax,%edx
80105840:	73 16                	jae    80105858 <argptr+0x47>
80105842:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105845:	89 c2                	mov    %eax,%edx
80105847:	8b 45 10             	mov    0x10(%ebp),%eax
8010584a:	01 c2                	add    %eax,%edx
8010584c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105852:	8b 00                	mov    (%eax),%eax
80105854:	39 c2                	cmp    %eax,%edx
80105856:	76 07                	jbe    8010585f <argptr+0x4e>
    return -1;
80105858:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585d:	eb 0f                	jmp    8010586e <argptr+0x5d>
  *pp = (char*)i;
8010585f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105862:	89 c2                	mov    %eax,%edx
80105864:	8b 45 0c             	mov    0xc(%ebp),%eax
80105867:	89 10                	mov    %edx,(%eax)
  return 0;
80105869:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010586e:	c9                   	leave  
8010586f:	c3                   	ret    

80105870 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105876:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105879:	50                   	push   %eax
8010587a:	ff 75 08             	pushl  0x8(%ebp)
8010587d:	e8 67 ff ff ff       	call   801057e9 <argint>
80105882:	83 c4 08             	add    $0x8,%esp
80105885:	85 c0                	test   %eax,%eax
80105887:	79 07                	jns    80105890 <argstr+0x20>
    return -1;
80105889:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588e:	eb 0f                	jmp    8010589f <argstr+0x2f>
  return fetchstr(addr, pp);
80105890:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105893:	ff 75 0c             	pushl  0xc(%ebp)
80105896:	50                   	push   %eax
80105897:	e8 eb fe ff ff       	call   80105787 <fetchstr>
8010589c:	83 c4 08             	add    $0x8,%esp
}
8010589f:	c9                   	leave  
801058a0:	c3                   	ret    

801058a1 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801058a1:	55                   	push   %ebp
801058a2:	89 e5                	mov    %esp,%ebp
801058a4:	53                   	push   %ebx
801058a5:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801058a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ae:	8b 40 18             	mov    0x18(%eax),%eax
801058b1:	8b 40 1c             	mov    0x1c(%eax),%eax
801058b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801058b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058bb:	7e 30                	jle    801058ed <syscall+0x4c>
801058bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c0:	83 f8 15             	cmp    $0x15,%eax
801058c3:	77 28                	ja     801058ed <syscall+0x4c>
801058c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c8:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801058cf:	85 c0                	test   %eax,%eax
801058d1:	74 1a                	je     801058ed <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801058d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d9:	8b 58 18             	mov    0x18(%eax),%ebx
801058dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058df:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801058e6:	ff d0                	call   *%eax
801058e8:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058eb:	eb 34                	jmp    80105921 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801058ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f3:	8d 50 6c             	lea    0x6c(%eax),%edx
801058f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058fc:	8b 40 10             	mov    0x10(%eax),%eax
801058ff:	ff 75 f4             	pushl  -0xc(%ebp)
80105902:	52                   	push   %edx
80105903:	50                   	push   %eax
80105904:	68 e3 8b 10 80       	push   $0x80108be3
80105909:	e8 b1 aa ff ff       	call   801003bf <cprintf>
8010590e:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105917:	8b 40 18             	mov    0x18(%eax),%eax
8010591a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105924:	c9                   	leave  
80105925:	c3                   	ret    

80105926 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105926:	55                   	push   %ebp
80105927:	89 e5                	mov    %esp,%ebp
80105929:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010592c:	83 ec 08             	sub    $0x8,%esp
8010592f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105932:	50                   	push   %eax
80105933:	ff 75 08             	pushl  0x8(%ebp)
80105936:	e8 ae fe ff ff       	call   801057e9 <argint>
8010593b:	83 c4 10             	add    $0x10,%esp
8010593e:	85 c0                	test   %eax,%eax
80105940:	79 07                	jns    80105949 <argfd+0x23>
    return -1;
80105942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105947:	eb 50                	jmp    80105999 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594c:	85 c0                	test   %eax,%eax
8010594e:	78 21                	js     80105971 <argfd+0x4b>
80105950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105953:	83 f8 0f             	cmp    $0xf,%eax
80105956:	7f 19                	jg     80105971 <argfd+0x4b>
80105958:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105961:	83 c2 08             	add    $0x8,%edx
80105964:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105968:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010596b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010596f:	75 07                	jne    80105978 <argfd+0x52>
    return -1;
80105971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105976:	eb 21                	jmp    80105999 <argfd+0x73>
  if(pfd)
80105978:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010597c:	74 08                	je     80105986 <argfd+0x60>
    *pfd = fd;
8010597e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105981:	8b 45 0c             	mov    0xc(%ebp),%eax
80105984:	89 10                	mov    %edx,(%eax)
  if(pf)
80105986:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010598a:	74 08                	je     80105994 <argfd+0x6e>
    *pf = f;
8010598c:	8b 45 10             	mov    0x10(%ebp),%eax
8010598f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105992:	89 10                	mov    %edx,(%eax)
  return 0;
80105994:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105999:	c9                   	leave  
8010599a:	c3                   	ret    

8010599b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010599b:	55                   	push   %ebp
8010599c:	89 e5                	mov    %esp,%ebp
8010599e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059a8:	eb 30                	jmp    801059da <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801059aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059b3:	83 c2 08             	add    $0x8,%edx
801059b6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059ba:	85 c0                	test   %eax,%eax
801059bc:	75 18                	jne    801059d6 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801059be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059c7:	8d 4a 08             	lea    0x8(%edx),%ecx
801059ca:	8b 55 08             	mov    0x8(%ebp),%edx
801059cd:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059d4:	eb 0f                	jmp    801059e5 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059da:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801059de:	7e ca                	jle    801059aa <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801059e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059e5:	c9                   	leave  
801059e6:	c3                   	ret    

801059e7 <sys_dup>:

int
sys_dup(void)
{
801059e7:	55                   	push   %ebp
801059e8:	89 e5                	mov    %esp,%ebp
801059ea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059ed:	83 ec 04             	sub    $0x4,%esp
801059f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059f3:	50                   	push   %eax
801059f4:	6a 00                	push   $0x0
801059f6:	6a 00                	push   $0x0
801059f8:	e8 29 ff ff ff       	call   80105926 <argfd>
801059fd:	83 c4 10             	add    $0x10,%esp
80105a00:	85 c0                	test   %eax,%eax
80105a02:	79 07                	jns    80105a0b <sys_dup+0x24>
    return -1;
80105a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a09:	eb 31                	jmp    80105a3c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	50                   	push   %eax
80105a12:	e8 84 ff ff ff       	call   8010599b <fdalloc>
80105a17:	83 c4 10             	add    $0x10,%esp
80105a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a21:	79 07                	jns    80105a2a <sys_dup+0x43>
    return -1;
80105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a28:	eb 12                	jmp    80105a3c <sys_dup+0x55>
  filedup(f);
80105a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2d:	83 ec 0c             	sub    $0xc,%esp
80105a30:	50                   	push   %eax
80105a31:	e8 91 b5 ff ff       	call   80100fc7 <filedup>
80105a36:	83 c4 10             	add    $0x10,%esp
  return fd;
80105a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a3c:	c9                   	leave  
80105a3d:	c3                   	ret    

80105a3e <sys_read>:

int
sys_read(void)
{
80105a3e:	55                   	push   %ebp
80105a3f:	89 e5                	mov    %esp,%ebp
80105a41:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a44:	83 ec 04             	sub    $0x4,%esp
80105a47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a4a:	50                   	push   %eax
80105a4b:	6a 00                	push   $0x0
80105a4d:	6a 00                	push   $0x0
80105a4f:	e8 d2 fe ff ff       	call   80105926 <argfd>
80105a54:	83 c4 10             	add    $0x10,%esp
80105a57:	85 c0                	test   %eax,%eax
80105a59:	78 2e                	js     80105a89 <sys_read+0x4b>
80105a5b:	83 ec 08             	sub    $0x8,%esp
80105a5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a61:	50                   	push   %eax
80105a62:	6a 02                	push   $0x2
80105a64:	e8 80 fd ff ff       	call   801057e9 <argint>
80105a69:	83 c4 10             	add    $0x10,%esp
80105a6c:	85 c0                	test   %eax,%eax
80105a6e:	78 19                	js     80105a89 <sys_read+0x4b>
80105a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a73:	83 ec 04             	sub    $0x4,%esp
80105a76:	50                   	push   %eax
80105a77:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a7a:	50                   	push   %eax
80105a7b:	6a 01                	push   $0x1
80105a7d:	e8 8f fd ff ff       	call   80105811 <argptr>
80105a82:	83 c4 10             	add    $0x10,%esp
80105a85:	85 c0                	test   %eax,%eax
80105a87:	79 07                	jns    80105a90 <sys_read+0x52>
    return -1;
80105a89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8e:	eb 17                	jmp    80105aa7 <sys_read+0x69>
  return fileread(f, p, n);
80105a90:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a93:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a99:	83 ec 04             	sub    $0x4,%esp
80105a9c:	51                   	push   %ecx
80105a9d:	52                   	push   %edx
80105a9e:	50                   	push   %eax
80105a9f:	e8 b3 b6 ff ff       	call   80101157 <fileread>
80105aa4:	83 c4 10             	add    $0x10,%esp
}
80105aa7:	c9                   	leave  
80105aa8:	c3                   	ret    

80105aa9 <sys_write>:

int
sys_write(void)
{
80105aa9:	55                   	push   %ebp
80105aaa:	89 e5                	mov    %esp,%ebp
80105aac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aaf:	83 ec 04             	sub    $0x4,%esp
80105ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 00                	push   $0x0
80105ab8:	6a 00                	push   $0x0
80105aba:	e8 67 fe ff ff       	call   80105926 <argfd>
80105abf:	83 c4 10             	add    $0x10,%esp
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	78 2e                	js     80105af4 <sys_write+0x4b>
80105ac6:	83 ec 08             	sub    $0x8,%esp
80105ac9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105acc:	50                   	push   %eax
80105acd:	6a 02                	push   $0x2
80105acf:	e8 15 fd ff ff       	call   801057e9 <argint>
80105ad4:	83 c4 10             	add    $0x10,%esp
80105ad7:	85 c0                	test   %eax,%eax
80105ad9:	78 19                	js     80105af4 <sys_write+0x4b>
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	83 ec 04             	sub    $0x4,%esp
80105ae1:	50                   	push   %eax
80105ae2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ae5:	50                   	push   %eax
80105ae6:	6a 01                	push   $0x1
80105ae8:	e8 24 fd ff ff       	call   80105811 <argptr>
80105aed:	83 c4 10             	add    $0x10,%esp
80105af0:	85 c0                	test   %eax,%eax
80105af2:	79 07                	jns    80105afb <sys_write+0x52>
    return -1;
80105af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af9:	eb 17                	jmp    80105b12 <sys_write+0x69>
  return filewrite(f, p, n);
80105afb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105afe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b04:	83 ec 04             	sub    $0x4,%esp
80105b07:	51                   	push   %ecx
80105b08:	52                   	push   %edx
80105b09:	50                   	push   %eax
80105b0a:	e8 00 b7 ff ff       	call   8010120f <filewrite>
80105b0f:	83 c4 10             	add    $0x10,%esp
}
80105b12:	c9                   	leave  
80105b13:	c3                   	ret    

80105b14 <sys_close>:

int
sys_close(void)
{
80105b14:	55                   	push   %ebp
80105b15:	89 e5                	mov    %esp,%ebp
80105b17:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105b1a:	83 ec 04             	sub    $0x4,%esp
80105b1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b20:	50                   	push   %eax
80105b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b24:	50                   	push   %eax
80105b25:	6a 00                	push   $0x0
80105b27:	e8 fa fd ff ff       	call   80105926 <argfd>
80105b2c:	83 c4 10             	add    $0x10,%esp
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	79 07                	jns    80105b3a <sys_close+0x26>
    return -1;
80105b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b38:	eb 28                	jmp    80105b62 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105b3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b43:	83 c2 08             	add    $0x8,%edx
80105b46:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b4d:	00 
  fileclose(f);
80105b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b51:	83 ec 0c             	sub    $0xc,%esp
80105b54:	50                   	push   %eax
80105b55:	e8 be b4 ff ff       	call   80101018 <fileclose>
80105b5a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b62:	c9                   	leave  
80105b63:	c3                   	ret    

80105b64 <sys_fstat>:

int
sys_fstat(void)
{
80105b64:	55                   	push   %ebp
80105b65:	89 e5                	mov    %esp,%ebp
80105b67:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b6a:	83 ec 04             	sub    $0x4,%esp
80105b6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b70:	50                   	push   %eax
80105b71:	6a 00                	push   $0x0
80105b73:	6a 00                	push   $0x0
80105b75:	e8 ac fd ff ff       	call   80105926 <argfd>
80105b7a:	83 c4 10             	add    $0x10,%esp
80105b7d:	85 c0                	test   %eax,%eax
80105b7f:	78 17                	js     80105b98 <sys_fstat+0x34>
80105b81:	83 ec 04             	sub    $0x4,%esp
80105b84:	6a 14                	push   $0x14
80105b86:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b89:	50                   	push   %eax
80105b8a:	6a 01                	push   $0x1
80105b8c:	e8 80 fc ff ff       	call   80105811 <argptr>
80105b91:	83 c4 10             	add    $0x10,%esp
80105b94:	85 c0                	test   %eax,%eax
80105b96:	79 07                	jns    80105b9f <sys_fstat+0x3b>
    return -1;
80105b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9d:	eb 13                	jmp    80105bb2 <sys_fstat+0x4e>
  return filestat(f, st);
80105b9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba5:	83 ec 08             	sub    $0x8,%esp
80105ba8:	52                   	push   %edx
80105ba9:	50                   	push   %eax
80105baa:	e8 51 b5 ff ff       	call   80101100 <filestat>
80105baf:	83 c4 10             	add    $0x10,%esp
}
80105bb2:	c9                   	leave  
80105bb3:	c3                   	ret    

80105bb4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bb4:	55                   	push   %ebp
80105bb5:	89 e5                	mov    %esp,%ebp
80105bb7:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bba:	83 ec 08             	sub    $0x8,%esp
80105bbd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bc0:	50                   	push   %eax
80105bc1:	6a 00                	push   $0x0
80105bc3:	e8 a8 fc ff ff       	call   80105870 <argstr>
80105bc8:	83 c4 10             	add    $0x10,%esp
80105bcb:	85 c0                	test   %eax,%eax
80105bcd:	78 15                	js     80105be4 <sys_link+0x30>
80105bcf:	83 ec 08             	sub    $0x8,%esp
80105bd2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bd5:	50                   	push   %eax
80105bd6:	6a 01                	push   $0x1
80105bd8:	e8 93 fc ff ff       	call   80105870 <argstr>
80105bdd:	83 c4 10             	add    $0x10,%esp
80105be0:	85 c0                	test   %eax,%eax
80105be2:	79 0a                	jns    80105bee <sys_link+0x3a>
    return -1;
80105be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be9:	e9 69 01 00 00       	jmp    80105d57 <sys_link+0x1a3>

  begin_op();
80105bee:	e8 a1 d9 ff ff       	call   80103594 <begin_op>
  if((ip = namei(old)) == 0){
80105bf3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105bf6:	83 ec 0c             	sub    $0xc,%esp
80105bf9:	50                   	push   %eax
80105bfa:	e8 c0 c9 ff ff       	call   801025bf <namei>
80105bff:	83 c4 10             	add    $0x10,%esp
80105c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c09:	75 0f                	jne    80105c1a <sys_link+0x66>
    end_op();
80105c0b:	e8 12 da ff ff       	call   80103622 <end_op>
    return -1;
80105c10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c15:	e9 3d 01 00 00       	jmp    80105d57 <sys_link+0x1a3>
  }

  ilock(ip);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105c20:	e8 c2 bc ff ff       	call   801018e7 <ilock>
80105c25:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c2f:	66 83 f8 01          	cmp    $0x1,%ax
80105c33:	75 1d                	jne    80105c52 <sys_link+0x9e>
    iunlockput(ip);
80105c35:	83 ec 0c             	sub    $0xc,%esp
80105c38:	ff 75 f4             	pushl  -0xc(%ebp)
80105c3b:	e8 5e bf ff ff       	call   80101b9e <iunlockput>
80105c40:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c43:	e8 da d9 ff ff       	call   80103622 <end_op>
    return -1;
80105c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4d:	e9 05 01 00 00       	jmp    80105d57 <sys_link+0x1a3>
  }

  ip->nlink++;
80105c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c55:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c59:	83 c0 01             	add    $0x1,%eax
80105c5c:	89 c2                	mov    %eax,%edx
80105c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c61:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c65:	83 ec 0c             	sub    $0xc,%esp
80105c68:	ff 75 f4             	pushl  -0xc(%ebp)
80105c6b:	e8 a4 ba ff ff       	call   80101714 <iupdate>
80105c70:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105c73:	83 ec 0c             	sub    $0xc,%esp
80105c76:	ff 75 f4             	pushl  -0xc(%ebp)
80105c79:	e8 c0 bd ff ff       	call   80101a3e <iunlock>
80105c7e:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105c81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c84:	83 ec 08             	sub    $0x8,%esp
80105c87:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c8a:	52                   	push   %edx
80105c8b:	50                   	push   %eax
80105c8c:	e8 4a c9 ff ff       	call   801025db <nameiparent>
80105c91:	83 c4 10             	add    $0x10,%esp
80105c94:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c9b:	75 02                	jne    80105c9f <sys_link+0xeb>
    goto bad;
80105c9d:	eb 71                	jmp    80105d10 <sys_link+0x15c>
  ilock(dp);
80105c9f:	83 ec 0c             	sub    $0xc,%esp
80105ca2:	ff 75 f0             	pushl  -0x10(%ebp)
80105ca5:	e8 3d bc ff ff       	call   801018e7 <ilock>
80105caa:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb0:	8b 10                	mov    (%eax),%edx
80105cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb5:	8b 00                	mov    (%eax),%eax
80105cb7:	39 c2                	cmp    %eax,%edx
80105cb9:	75 1d                	jne    80105cd8 <sys_link+0x124>
80105cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbe:	8b 40 04             	mov    0x4(%eax),%eax
80105cc1:	83 ec 04             	sub    $0x4,%esp
80105cc4:	50                   	push   %eax
80105cc5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105cc8:	50                   	push   %eax
80105cc9:	ff 75 f0             	pushl  -0x10(%ebp)
80105ccc:	e8 12 c6 ff ff       	call   801022e3 <dirlink>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	79 10                	jns    80105ce8 <sys_link+0x134>
    iunlockput(dp);
80105cd8:	83 ec 0c             	sub    $0xc,%esp
80105cdb:	ff 75 f0             	pushl  -0x10(%ebp)
80105cde:	e8 bb be ff ff       	call   80101b9e <iunlockput>
80105ce3:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ce6:	eb 28                	jmp    80105d10 <sys_link+0x15c>
  }
  iunlockput(dp);
80105ce8:	83 ec 0c             	sub    $0xc,%esp
80105ceb:	ff 75 f0             	pushl  -0x10(%ebp)
80105cee:	e8 ab be ff ff       	call   80101b9e <iunlockput>
80105cf3:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105cf6:	83 ec 0c             	sub    $0xc,%esp
80105cf9:	ff 75 f4             	pushl  -0xc(%ebp)
80105cfc:	e8 ae bd ff ff       	call   80101aaf <iput>
80105d01:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d04:	e8 19 d9 ff ff       	call   80103622 <end_op>

  return 0;
80105d09:	b8 00 00 00 00       	mov    $0x0,%eax
80105d0e:	eb 47                	jmp    80105d57 <sys_link+0x1a3>

bad:
  ilock(ip);
80105d10:	83 ec 0c             	sub    $0xc,%esp
80105d13:	ff 75 f4             	pushl  -0xc(%ebp)
80105d16:	e8 cc bb ff ff       	call   801018e7 <ilock>
80105d1b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d21:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d25:	83 e8 01             	sub    $0x1,%eax
80105d28:	89 c2                	mov    %eax,%edx
80105d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d31:	83 ec 0c             	sub    $0xc,%esp
80105d34:	ff 75 f4             	pushl  -0xc(%ebp)
80105d37:	e8 d8 b9 ff ff       	call   80101714 <iupdate>
80105d3c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d3f:	83 ec 0c             	sub    $0xc,%esp
80105d42:	ff 75 f4             	pushl  -0xc(%ebp)
80105d45:	e8 54 be ff ff       	call   80101b9e <iunlockput>
80105d4a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d4d:	e8 d0 d8 ff ff       	call   80103622 <end_op>
  return -1;
80105d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d57:	c9                   	leave  
80105d58:	c3                   	ret    

80105d59 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d59:	55                   	push   %ebp
80105d5a:	89 e5                	mov    %esp,%ebp
80105d5c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d5f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d66:	eb 40                	jmp    80105da8 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6b:	6a 10                	push   $0x10
80105d6d:	50                   	push   %eax
80105d6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d71:	50                   	push   %eax
80105d72:	ff 75 08             	pushl  0x8(%ebp)
80105d75:	e8 cf c0 ff ff       	call   80101e49 <readi>
80105d7a:	83 c4 10             	add    $0x10,%esp
80105d7d:	83 f8 10             	cmp    $0x10,%eax
80105d80:	74 0d                	je     80105d8f <isdirempty+0x36>
      panic("isdirempty: readi");
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	68 ff 8b 10 80       	push   $0x80108bff
80105d8a:	e8 cd a7 ff ff       	call   8010055c <panic>
    if(de.inum != 0)
80105d8f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d93:	66 85 c0             	test   %ax,%ax
80105d96:	74 07                	je     80105d9f <isdirempty+0x46>
      return 0;
80105d98:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9d:	eb 1b                	jmp    80105dba <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da2:	83 c0 10             	add    $0x10,%eax
80105da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dab:	8b 45 08             	mov    0x8(%ebp),%eax
80105dae:	8b 40 18             	mov    0x18(%eax),%eax
80105db1:	39 c2                	cmp    %eax,%edx
80105db3:	72 b3                	jb     80105d68 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105db5:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105dba:	c9                   	leave  
80105dbb:	c3                   	ret    

80105dbc <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105dbc:	55                   	push   %ebp
80105dbd:	89 e5                	mov    %esp,%ebp
80105dbf:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105dc2:	83 ec 08             	sub    $0x8,%esp
80105dc5:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105dc8:	50                   	push   %eax
80105dc9:	6a 00                	push   $0x0
80105dcb:	e8 a0 fa ff ff       	call   80105870 <argstr>
80105dd0:	83 c4 10             	add    $0x10,%esp
80105dd3:	85 c0                	test   %eax,%eax
80105dd5:	79 0a                	jns    80105de1 <sys_unlink+0x25>
    return -1;
80105dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddc:	e9 bc 01 00 00       	jmp    80105f9d <sys_unlink+0x1e1>

  begin_op();
80105de1:	e8 ae d7 ff ff       	call   80103594 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105de6:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105de9:	83 ec 08             	sub    $0x8,%esp
80105dec:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105def:	52                   	push   %edx
80105df0:	50                   	push   %eax
80105df1:	e8 e5 c7 ff ff       	call   801025db <nameiparent>
80105df6:	83 c4 10             	add    $0x10,%esp
80105df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e00:	75 0f                	jne    80105e11 <sys_unlink+0x55>
    end_op();
80105e02:	e8 1b d8 ff ff       	call   80103622 <end_op>
    return -1;
80105e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0c:	e9 8c 01 00 00       	jmp    80105f9d <sys_unlink+0x1e1>
  }

  ilock(dp);
80105e11:	83 ec 0c             	sub    $0xc,%esp
80105e14:	ff 75 f4             	pushl  -0xc(%ebp)
80105e17:	e8 cb ba ff ff       	call   801018e7 <ilock>
80105e1c:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e1f:	83 ec 08             	sub    $0x8,%esp
80105e22:	68 11 8c 10 80       	push   $0x80108c11
80105e27:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e2a:	50                   	push   %eax
80105e2b:	e8 0f c3 ff ff       	call   8010213f <namecmp>
80105e30:	83 c4 10             	add    $0x10,%esp
80105e33:	85 c0                	test   %eax,%eax
80105e35:	0f 84 4a 01 00 00    	je     80105f85 <sys_unlink+0x1c9>
80105e3b:	83 ec 08             	sub    $0x8,%esp
80105e3e:	68 13 8c 10 80       	push   $0x80108c13
80105e43:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e46:	50                   	push   %eax
80105e47:	e8 f3 c2 ff ff       	call   8010213f <namecmp>
80105e4c:	83 c4 10             	add    $0x10,%esp
80105e4f:	85 c0                	test   %eax,%eax
80105e51:	0f 84 2e 01 00 00    	je     80105f85 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e57:	83 ec 04             	sub    $0x4,%esp
80105e5a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e5d:	50                   	push   %eax
80105e5e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e61:	50                   	push   %eax
80105e62:	ff 75 f4             	pushl  -0xc(%ebp)
80105e65:	e8 f0 c2 ff ff       	call   8010215a <dirlookup>
80105e6a:	83 c4 10             	add    $0x10,%esp
80105e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e74:	75 05                	jne    80105e7b <sys_unlink+0xbf>
    goto bad;
80105e76:	e9 0a 01 00 00       	jmp    80105f85 <sys_unlink+0x1c9>
  ilock(ip);
80105e7b:	83 ec 0c             	sub    $0xc,%esp
80105e7e:	ff 75 f0             	pushl  -0x10(%ebp)
80105e81:	e8 61 ba ff ff       	call   801018e7 <ilock>
80105e86:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e90:	66 85 c0             	test   %ax,%ax
80105e93:	7f 0d                	jg     80105ea2 <sys_unlink+0xe6>
    panic("unlink: nlink < 1");
80105e95:	83 ec 0c             	sub    $0xc,%esp
80105e98:	68 16 8c 10 80       	push   $0x80108c16
80105e9d:	e8 ba a6 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ea9:	66 83 f8 01          	cmp    $0x1,%ax
80105ead:	75 25                	jne    80105ed4 <sys_unlink+0x118>
80105eaf:	83 ec 0c             	sub    $0xc,%esp
80105eb2:	ff 75 f0             	pushl  -0x10(%ebp)
80105eb5:	e8 9f fe ff ff       	call   80105d59 <isdirempty>
80105eba:	83 c4 10             	add    $0x10,%esp
80105ebd:	85 c0                	test   %eax,%eax
80105ebf:	75 13                	jne    80105ed4 <sys_unlink+0x118>
    iunlockput(ip);
80105ec1:	83 ec 0c             	sub    $0xc,%esp
80105ec4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec7:	e8 d2 bc ff ff       	call   80101b9e <iunlockput>
80105ecc:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ecf:	e9 b1 00 00 00       	jmp    80105f85 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105ed4:	83 ec 04             	sub    $0x4,%esp
80105ed7:	6a 10                	push   $0x10
80105ed9:	6a 00                	push   $0x0
80105edb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ede:	50                   	push   %eax
80105edf:	e8 de f5 ff ff       	call   801054c2 <memset>
80105ee4:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ee7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eea:	6a 10                	push   $0x10
80105eec:	50                   	push   %eax
80105eed:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ef0:	50                   	push   %eax
80105ef1:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef4:	e8 b3 c0 ff ff       	call   80101fac <writei>
80105ef9:	83 c4 10             	add    $0x10,%esp
80105efc:	83 f8 10             	cmp    $0x10,%eax
80105eff:	74 0d                	je     80105f0e <sys_unlink+0x152>
    panic("unlink: writei");
80105f01:	83 ec 0c             	sub    $0xc,%esp
80105f04:	68 28 8c 10 80       	push   $0x80108c28
80105f09:	e8 4e a6 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR){
80105f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f11:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f15:	66 83 f8 01          	cmp    $0x1,%ax
80105f19:	75 21                	jne    80105f3c <sys_unlink+0x180>
    dp->nlink--;
80105f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f22:	83 e8 01             	sub    $0x1,%eax
80105f25:	89 c2                	mov    %eax,%edx
80105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f2e:	83 ec 0c             	sub    $0xc,%esp
80105f31:	ff 75 f4             	pushl  -0xc(%ebp)
80105f34:	e8 db b7 ff ff       	call   80101714 <iupdate>
80105f39:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105f3c:	83 ec 0c             	sub    $0xc,%esp
80105f3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105f42:	e8 57 bc ff ff       	call   80101b9e <iunlockput>
80105f47:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f51:	83 e8 01             	sub    $0x1,%eax
80105f54:	89 c2                	mov    %eax,%edx
80105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f59:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f5d:	83 ec 0c             	sub    $0xc,%esp
80105f60:	ff 75 f0             	pushl  -0x10(%ebp)
80105f63:	e8 ac b7 ff ff       	call   80101714 <iupdate>
80105f68:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f6b:	83 ec 0c             	sub    $0xc,%esp
80105f6e:	ff 75 f0             	pushl  -0x10(%ebp)
80105f71:	e8 28 bc ff ff       	call   80101b9e <iunlockput>
80105f76:	83 c4 10             	add    $0x10,%esp

  end_op();
80105f79:	e8 a4 d6 ff ff       	call   80103622 <end_op>

  return 0;
80105f7e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f83:	eb 18                	jmp    80105f9d <sys_unlink+0x1e1>

bad:
  iunlockput(dp);
80105f85:	83 ec 0c             	sub    $0xc,%esp
80105f88:	ff 75 f4             	pushl  -0xc(%ebp)
80105f8b:	e8 0e bc ff ff       	call   80101b9e <iunlockput>
80105f90:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f93:	e8 8a d6 ff ff       	call   80103622 <end_op>
  return -1;
80105f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f9d:	c9                   	leave  
80105f9e:	c3                   	ret    

80105f9f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f9f:	55                   	push   %ebp
80105fa0:	89 e5                	mov    %esp,%ebp
80105fa2:	83 ec 38             	sub    $0x38,%esp
80105fa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105fa8:	8b 55 10             	mov    0x10(%ebp),%edx
80105fab:	8b 45 14             	mov    0x14(%ebp),%eax
80105fae:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105fb2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105fb6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105fba:	83 ec 08             	sub    $0x8,%esp
80105fbd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fc0:	50                   	push   %eax
80105fc1:	ff 75 08             	pushl  0x8(%ebp)
80105fc4:	e8 12 c6 ff ff       	call   801025db <nameiparent>
80105fc9:	83 c4 10             	add    $0x10,%esp
80105fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fcf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd3:	75 0a                	jne    80105fdf <create+0x40>
    return 0;
80105fd5:	b8 00 00 00 00       	mov    $0x0,%eax
80105fda:	e9 b5 01 00 00       	jmp    80106194 <create+0x1f5>
  ilock(dp);
80105fdf:	83 ec 0c             	sub    $0xc,%esp
80105fe2:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe5:	e8 fd b8 ff ff       	call   801018e7 <ilock>
80105fea:	83 c4 10             	add    $0x10,%esp

  if (dp->type == T_DEV) {
80105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ff4:	66 83 f8 03          	cmp    $0x3,%ax
80105ff8:	75 18                	jne    80106012 <create+0x73>
    iunlockput(dp);
80105ffa:	83 ec 0c             	sub    $0xc,%esp
80105ffd:	ff 75 f4             	pushl  -0xc(%ebp)
80106000:	e8 99 bb ff ff       	call   80101b9e <iunlockput>
80106005:	83 c4 10             	add    $0x10,%esp
    return 0;
80106008:	b8 00 00 00 00       	mov    $0x0,%eax
8010600d:	e9 82 01 00 00       	jmp    80106194 <create+0x1f5>
  }

  if((ip = dirlookup(dp, name, &off)) != 0){
80106012:	83 ec 04             	sub    $0x4,%esp
80106015:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106018:	50                   	push   %eax
80106019:	8d 45 de             	lea    -0x22(%ebp),%eax
8010601c:	50                   	push   %eax
8010601d:	ff 75 f4             	pushl  -0xc(%ebp)
80106020:	e8 35 c1 ff ff       	call   8010215a <dirlookup>
80106025:	83 c4 10             	add    $0x10,%esp
80106028:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010602b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010602f:	74 50                	je     80106081 <create+0xe2>
    iunlockput(dp);
80106031:	83 ec 0c             	sub    $0xc,%esp
80106034:	ff 75 f4             	pushl  -0xc(%ebp)
80106037:	e8 62 bb ff ff       	call   80101b9e <iunlockput>
8010603c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010603f:	83 ec 0c             	sub    $0xc,%esp
80106042:	ff 75 f0             	pushl  -0x10(%ebp)
80106045:	e8 9d b8 ff ff       	call   801018e7 <ilock>
8010604a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010604d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106052:	75 15                	jne    80106069 <create+0xca>
80106054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106057:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010605b:	66 83 f8 02          	cmp    $0x2,%ax
8010605f:	75 08                	jne    80106069 <create+0xca>
      return ip;
80106061:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106064:	e9 2b 01 00 00       	jmp    80106194 <create+0x1f5>
    iunlockput(ip);
80106069:	83 ec 0c             	sub    $0xc,%esp
8010606c:	ff 75 f0             	pushl  -0x10(%ebp)
8010606f:	e8 2a bb ff ff       	call   80101b9e <iunlockput>
80106074:	83 c4 10             	add    $0x10,%esp
    return 0;
80106077:	b8 00 00 00 00       	mov    $0x0,%eax
8010607c:	e9 13 01 00 00       	jmp    80106194 <create+0x1f5>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106081:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106088:	8b 00                	mov    (%eax),%eax
8010608a:	83 ec 08             	sub    $0x8,%esp
8010608d:	52                   	push   %edx
8010608e:	50                   	push   %eax
8010608f:	e8 9f b5 ff ff       	call   80101633 <ialloc>
80106094:	83 c4 10             	add    $0x10,%esp
80106097:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010609a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010609e:	75 0d                	jne    801060ad <create+0x10e>
    panic("create: ialloc");
801060a0:	83 ec 0c             	sub    $0xc,%esp
801060a3:	68 37 8c 10 80       	push   $0x80108c37
801060a8:	e8 af a4 ff ff       	call   8010055c <panic>

  ilock(ip);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	ff 75 f0             	pushl  -0x10(%ebp)
801060b3:	e8 2f b8 ff ff       	call   801018e7 <ilock>
801060b8:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801060bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060be:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801060c2:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801060c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c9:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801060cd:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801060d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d4:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801060da:	83 ec 0c             	sub    $0xc,%esp
801060dd:	ff 75 f0             	pushl  -0x10(%ebp)
801060e0:	e8 2f b6 ff ff       	call   80101714 <iupdate>
801060e5:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801060e8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801060ed:	75 6a                	jne    80106159 <create+0x1ba>
    dp->nlink++;  // for ".."
801060ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060f6:	83 c0 01             	add    $0x1,%eax
801060f9:	89 c2                	mov    %eax,%edx
801060fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fe:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	ff 75 f4             	pushl  -0xc(%ebp)
80106108:	e8 07 b6 ff ff       	call   80101714 <iupdate>
8010610d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106113:	8b 40 04             	mov    0x4(%eax),%eax
80106116:	83 ec 04             	sub    $0x4,%esp
80106119:	50                   	push   %eax
8010611a:	68 11 8c 10 80       	push   $0x80108c11
8010611f:	ff 75 f0             	pushl  -0x10(%ebp)
80106122:	e8 bc c1 ff ff       	call   801022e3 <dirlink>
80106127:	83 c4 10             	add    $0x10,%esp
8010612a:	85 c0                	test   %eax,%eax
8010612c:	78 1e                	js     8010614c <create+0x1ad>
8010612e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106131:	8b 40 04             	mov    0x4(%eax),%eax
80106134:	83 ec 04             	sub    $0x4,%esp
80106137:	50                   	push   %eax
80106138:	68 13 8c 10 80       	push   $0x80108c13
8010613d:	ff 75 f0             	pushl  -0x10(%ebp)
80106140:	e8 9e c1 ff ff       	call   801022e3 <dirlink>
80106145:	83 c4 10             	add    $0x10,%esp
80106148:	85 c0                	test   %eax,%eax
8010614a:	79 0d                	jns    80106159 <create+0x1ba>
      panic("create dots");
8010614c:	83 ec 0c             	sub    $0xc,%esp
8010614f:	68 46 8c 10 80       	push   $0x80108c46
80106154:	e8 03 a4 ff ff       	call   8010055c <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615c:	8b 40 04             	mov    0x4(%eax),%eax
8010615f:	83 ec 04             	sub    $0x4,%esp
80106162:	50                   	push   %eax
80106163:	8d 45 de             	lea    -0x22(%ebp),%eax
80106166:	50                   	push   %eax
80106167:	ff 75 f4             	pushl  -0xc(%ebp)
8010616a:	e8 74 c1 ff ff       	call   801022e3 <dirlink>
8010616f:	83 c4 10             	add    $0x10,%esp
80106172:	85 c0                	test   %eax,%eax
80106174:	79 0d                	jns    80106183 <create+0x1e4>
    panic("create: dirlink");
80106176:	83 ec 0c             	sub    $0xc,%esp
80106179:	68 52 8c 10 80       	push   $0x80108c52
8010617e:	e8 d9 a3 ff ff       	call   8010055c <panic>

  iunlockput(dp);
80106183:	83 ec 0c             	sub    $0xc,%esp
80106186:	ff 75 f4             	pushl  -0xc(%ebp)
80106189:	e8 10 ba ff ff       	call   80101b9e <iunlockput>
8010618e:	83 c4 10             	add    $0x10,%esp

  return ip;
80106191:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106194:	c9                   	leave  
80106195:	c3                   	ret    

80106196 <sys_open>:

int
sys_open(void)
{
80106196:	55                   	push   %ebp
80106197:	89 e5                	mov    %esp,%ebp
80106199:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010619c:	83 ec 08             	sub    $0x8,%esp
8010619f:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061a2:	50                   	push   %eax
801061a3:	6a 00                	push   $0x0
801061a5:	e8 c6 f6 ff ff       	call   80105870 <argstr>
801061aa:	83 c4 10             	add    $0x10,%esp
801061ad:	85 c0                	test   %eax,%eax
801061af:	78 15                	js     801061c6 <sys_open+0x30>
801061b1:	83 ec 08             	sub    $0x8,%esp
801061b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061b7:	50                   	push   %eax
801061b8:	6a 01                	push   $0x1
801061ba:	e8 2a f6 ff ff       	call   801057e9 <argint>
801061bf:	83 c4 10             	add    $0x10,%esp
801061c2:	85 c0                	test   %eax,%eax
801061c4:	79 0a                	jns    801061d0 <sys_open+0x3a>
    return -1;
801061c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cb:	e9 61 01 00 00       	jmp    80106331 <sys_open+0x19b>

  begin_op();
801061d0:	e8 bf d3 ff ff       	call   80103594 <begin_op>

  if(omode & O_CREATE){
801061d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061d8:	25 00 02 00 00       	and    $0x200,%eax
801061dd:	85 c0                	test   %eax,%eax
801061df:	74 2a                	je     8010620b <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801061e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061e4:	6a 00                	push   $0x0
801061e6:	6a 00                	push   $0x0
801061e8:	6a 02                	push   $0x2
801061ea:	50                   	push   %eax
801061eb:	e8 af fd ff ff       	call   80105f9f <create>
801061f0:	83 c4 10             	add    $0x10,%esp
801061f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801061f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061fa:	75 75                	jne    80106271 <sys_open+0xdb>
      end_op();
801061fc:	e8 21 d4 ff ff       	call   80103622 <end_op>
      return -1;
80106201:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106206:	e9 26 01 00 00       	jmp    80106331 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010620b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010620e:	83 ec 0c             	sub    $0xc,%esp
80106211:	50                   	push   %eax
80106212:	e8 a8 c3 ff ff       	call   801025bf <namei>
80106217:	83 c4 10             	add    $0x10,%esp
8010621a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106221:	75 0f                	jne    80106232 <sys_open+0x9c>
      end_op();
80106223:	e8 fa d3 ff ff       	call   80103622 <end_op>
      return -1;
80106228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622d:	e9 ff 00 00 00       	jmp    80106331 <sys_open+0x19b>
    }
    ilock(ip);
80106232:	83 ec 0c             	sub    $0xc,%esp
80106235:	ff 75 f4             	pushl  -0xc(%ebp)
80106238:	e8 aa b6 ff ff       	call   801018e7 <ilock>
8010623d:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106247:	66 83 f8 01          	cmp    $0x1,%ax
8010624b:	75 24                	jne    80106271 <sys_open+0xdb>
8010624d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106250:	85 c0                	test   %eax,%eax
80106252:	74 1d                	je     80106271 <sys_open+0xdb>
      iunlockput(ip);
80106254:	83 ec 0c             	sub    $0xc,%esp
80106257:	ff 75 f4             	pushl  -0xc(%ebp)
8010625a:	e8 3f b9 ff ff       	call   80101b9e <iunlockput>
8010625f:	83 c4 10             	add    $0x10,%esp
      end_op();
80106262:	e8 bb d3 ff ff       	call   80103622 <end_op>
      return -1;
80106267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626c:	e9 c0 00 00 00       	jmp    80106331 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106271:	e8 e5 ac ff ff       	call   80100f5b <filealloc>
80106276:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106279:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010627d:	74 17                	je     80106296 <sys_open+0x100>
8010627f:	83 ec 0c             	sub    $0xc,%esp
80106282:	ff 75 f0             	pushl  -0x10(%ebp)
80106285:	e8 11 f7 ff ff       	call   8010599b <fdalloc>
8010628a:	83 c4 10             	add    $0x10,%esp
8010628d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106290:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106294:	79 2e                	jns    801062c4 <sys_open+0x12e>
    if(f)
80106296:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010629a:	74 0e                	je     801062aa <sys_open+0x114>
      fileclose(f);
8010629c:	83 ec 0c             	sub    $0xc,%esp
8010629f:	ff 75 f0             	pushl  -0x10(%ebp)
801062a2:	e8 71 ad ff ff       	call   80101018 <fileclose>
801062a7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801062aa:	83 ec 0c             	sub    $0xc,%esp
801062ad:	ff 75 f4             	pushl  -0xc(%ebp)
801062b0:	e8 e9 b8 ff ff       	call   80101b9e <iunlockput>
801062b5:	83 c4 10             	add    $0x10,%esp
    end_op();
801062b8:	e8 65 d3 ff ff       	call   80103622 <end_op>
    return -1;
801062bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c2:	eb 6d                	jmp    80106331 <sys_open+0x19b>
  }
  iunlock(ip);
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	ff 75 f4             	pushl  -0xc(%ebp)
801062ca:	e8 6f b7 ff ff       	call   80101a3e <iunlock>
801062cf:	83 c4 10             	add    $0x10,%esp
  end_op();
801062d2:	e8 4b d3 ff ff       	call   80103622 <end_op>

  f->type = FD_INODE;
801062d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062da:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801062e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ec:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801062f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062f6:	83 e0 01             	and    $0x1,%eax
801062f9:	85 c0                	test   %eax,%eax
801062fb:	0f 94 c0             	sete   %al
801062fe:	89 c2                	mov    %eax,%edx
80106300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106303:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106309:	83 e0 01             	and    $0x1,%eax
8010630c:	85 c0                	test   %eax,%eax
8010630e:	75 0a                	jne    8010631a <sys_open+0x184>
80106310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106313:	83 e0 02             	and    $0x2,%eax
80106316:	85 c0                	test   %eax,%eax
80106318:	74 07                	je     80106321 <sys_open+0x18b>
8010631a:	b8 01 00 00 00       	mov    $0x1,%eax
8010631f:	eb 05                	jmp    80106326 <sys_open+0x190>
80106321:	b8 00 00 00 00       	mov    $0x0,%eax
80106326:	89 c2                	mov    %eax,%edx
80106328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010632e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106331:	c9                   	leave  
80106332:	c3                   	ret    

80106333 <sys_mkdir>:

int
sys_mkdir(void)
{
80106333:	55                   	push   %ebp
80106334:	89 e5                	mov    %esp,%ebp
80106336:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106339:	e8 56 d2 ff ff       	call   80103594 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010633e:	83 ec 08             	sub    $0x8,%esp
80106341:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106344:	50                   	push   %eax
80106345:	6a 00                	push   $0x0
80106347:	e8 24 f5 ff ff       	call   80105870 <argstr>
8010634c:	83 c4 10             	add    $0x10,%esp
8010634f:	85 c0                	test   %eax,%eax
80106351:	78 1b                	js     8010636e <sys_mkdir+0x3b>
80106353:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106356:	6a 00                	push   $0x0
80106358:	6a 00                	push   $0x0
8010635a:	6a 01                	push   $0x1
8010635c:	50                   	push   %eax
8010635d:	e8 3d fc ff ff       	call   80105f9f <create>
80106362:	83 c4 10             	add    $0x10,%esp
80106365:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106368:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010636c:	75 0c                	jne    8010637a <sys_mkdir+0x47>
    end_op();
8010636e:	e8 af d2 ff ff       	call   80103622 <end_op>
    return -1;
80106373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106378:	eb 18                	jmp    80106392 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010637a:	83 ec 0c             	sub    $0xc,%esp
8010637d:	ff 75 f4             	pushl  -0xc(%ebp)
80106380:	e8 19 b8 ff ff       	call   80101b9e <iunlockput>
80106385:	83 c4 10             	add    $0x10,%esp
  end_op();
80106388:	e8 95 d2 ff ff       	call   80103622 <end_op>
  return 0;
8010638d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106392:	c9                   	leave  
80106393:	c3                   	ret    

80106394 <sys_mknod>:

int
sys_mknod(void)
{
80106394:	55                   	push   %ebp
80106395:	89 e5                	mov    %esp,%ebp
80106397:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010639a:	e8 f5 d1 ff ff       	call   80103594 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010639f:	83 ec 08             	sub    $0x8,%esp
801063a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063a5:	50                   	push   %eax
801063a6:	6a 00                	push   $0x0
801063a8:	e8 c3 f4 ff ff       	call   80105870 <argstr>
801063ad:	83 c4 10             	add    $0x10,%esp
801063b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063b7:	78 4f                	js     80106408 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801063b9:	83 ec 08             	sub    $0x8,%esp
801063bc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063bf:	50                   	push   %eax
801063c0:	6a 01                	push   $0x1
801063c2:	e8 22 f4 ff ff       	call   801057e9 <argint>
801063c7:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801063ca:	85 c0                	test   %eax,%eax
801063cc:	78 3a                	js     80106408 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063ce:	83 ec 08             	sub    $0x8,%esp
801063d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063d4:	50                   	push   %eax
801063d5:	6a 02                	push   $0x2
801063d7:	e8 0d f4 ff ff       	call   801057e9 <argint>
801063dc:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801063df:	85 c0                	test   %eax,%eax
801063e1:	78 25                	js     80106408 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801063e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063e6:	0f bf c8             	movswl %ax,%ecx
801063e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063ec:	0f bf d0             	movswl %ax,%edx
801063ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063f2:	51                   	push   %ecx
801063f3:	52                   	push   %edx
801063f4:	6a 03                	push   $0x3
801063f6:	50                   	push   %eax
801063f7:	e8 a3 fb ff ff       	call   80105f9f <create>
801063fc:	83 c4 10             	add    $0x10,%esp
801063ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106402:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106406:	75 0c                	jne    80106414 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106408:	e8 15 d2 ff ff       	call   80103622 <end_op>
    return -1;
8010640d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106412:	eb 18                	jmp    8010642c <sys_mknod+0x98>
  }
  iunlockput(ip);
80106414:	83 ec 0c             	sub    $0xc,%esp
80106417:	ff 75 f0             	pushl  -0x10(%ebp)
8010641a:	e8 7f b7 ff ff       	call   80101b9e <iunlockput>
8010641f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106422:	e8 fb d1 ff ff       	call   80103622 <end_op>
  return 0;
80106427:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010642c:	c9                   	leave  
8010642d:	c3                   	ret    

8010642e <sys_chdir>:

int
sys_chdir(void)
{
8010642e:	55                   	push   %ebp
8010642f:	89 e5                	mov    %esp,%ebp
80106431:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106434:	e8 5b d1 ff ff       	call   80103594 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106439:	83 ec 08             	sub    $0x8,%esp
8010643c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010643f:	50                   	push   %eax
80106440:	6a 00                	push   $0x0
80106442:	e8 29 f4 ff ff       	call   80105870 <argstr>
80106447:	83 c4 10             	add    $0x10,%esp
8010644a:	85 c0                	test   %eax,%eax
8010644c:	78 18                	js     80106466 <sys_chdir+0x38>
8010644e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106451:	83 ec 0c             	sub    $0xc,%esp
80106454:	50                   	push   %eax
80106455:	e8 65 c1 ff ff       	call   801025bf <namei>
8010645a:	83 c4 10             	add    $0x10,%esp
8010645d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106460:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106464:	75 0f                	jne    80106475 <sys_chdir+0x47>
    end_op();
80106466:	e8 b7 d1 ff ff       	call   80103622 <end_op>
    return -1;
8010646b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106470:	e9 b2 00 00 00       	jmp    80106527 <sys_chdir+0xf9>
  }
  ilock(ip);
80106475:	83 ec 0c             	sub    $0xc,%esp
80106478:	ff 75 f4             	pushl  -0xc(%ebp)
8010647b:	e8 67 b4 ff ff       	call   801018e7 <ilock>
80106480:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR && !IS_DEV_DIR(ip)) {
80106483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106486:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010648a:	66 83 f8 01          	cmp    $0x1,%ax
8010648e:	74 5e                	je     801064ee <sys_chdir+0xc0>
80106490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106493:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106497:	66 83 f8 03          	cmp    $0x3,%ax
8010649b:	75 37                	jne    801064d4 <sys_chdir+0xa6>
8010649d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801064a4:	98                   	cwtl   
801064a5:	c1 e0 04             	shl    $0x4,%eax
801064a8:	05 80 12 11 80       	add    $0x80111280,%eax
801064ad:	8b 00                	mov    (%eax),%eax
801064af:	85 c0                	test   %eax,%eax
801064b1:	74 21                	je     801064d4 <sys_chdir+0xa6>
801064b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801064ba:	98                   	cwtl   
801064bb:	c1 e0 04             	shl    $0x4,%eax
801064be:	05 80 12 11 80       	add    $0x80111280,%eax
801064c3:	8b 00                	mov    (%eax),%eax
801064c5:	83 ec 0c             	sub    $0xc,%esp
801064c8:	ff 75 f4             	pushl  -0xc(%ebp)
801064cb:	ff d0                	call   *%eax
801064cd:	83 c4 10             	add    $0x10,%esp
801064d0:	85 c0                	test   %eax,%eax
801064d2:	75 1a                	jne    801064ee <sys_chdir+0xc0>
    iunlockput(ip);
801064d4:	83 ec 0c             	sub    $0xc,%esp
801064d7:	ff 75 f4             	pushl  -0xc(%ebp)
801064da:	e8 bf b6 ff ff       	call   80101b9e <iunlockput>
801064df:	83 c4 10             	add    $0x10,%esp
    end_op();
801064e2:	e8 3b d1 ff ff       	call   80103622 <end_op>
    return -1;
801064e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ec:	eb 39                	jmp    80106527 <sys_chdir+0xf9>
  }
  iunlock(ip);
801064ee:	83 ec 0c             	sub    $0xc,%esp
801064f1:	ff 75 f4             	pushl  -0xc(%ebp)
801064f4:	e8 45 b5 ff ff       	call   80101a3e <iunlock>
801064f9:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801064fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106502:	8b 40 68             	mov    0x68(%eax),%eax
80106505:	83 ec 0c             	sub    $0xc,%esp
80106508:	50                   	push   %eax
80106509:	e8 a1 b5 ff ff       	call   80101aaf <iput>
8010650e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106511:	e8 0c d1 ff ff       	call   80103622 <end_op>
  proc->cwd = ip;
80106516:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010651c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010651f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106522:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106527:	c9                   	leave  
80106528:	c3                   	ret    

80106529 <sys_exec>:

int
sys_exec(void)
{
80106529:	55                   	push   %ebp
8010652a:	89 e5                	mov    %esp,%ebp
8010652c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106532:	83 ec 08             	sub    $0x8,%esp
80106535:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106538:	50                   	push   %eax
80106539:	6a 00                	push   $0x0
8010653b:	e8 30 f3 ff ff       	call   80105870 <argstr>
80106540:	83 c4 10             	add    $0x10,%esp
80106543:	85 c0                	test   %eax,%eax
80106545:	78 18                	js     8010655f <sys_exec+0x36>
80106547:	83 ec 08             	sub    $0x8,%esp
8010654a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106550:	50                   	push   %eax
80106551:	6a 01                	push   $0x1
80106553:	e8 91 f2 ff ff       	call   801057e9 <argint>
80106558:	83 c4 10             	add    $0x10,%esp
8010655b:	85 c0                	test   %eax,%eax
8010655d:	79 0a                	jns    80106569 <sys_exec+0x40>
    return -1;
8010655f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106564:	e9 c6 00 00 00       	jmp    8010662f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106569:	83 ec 04             	sub    $0x4,%esp
8010656c:	68 80 00 00 00       	push   $0x80
80106571:	6a 00                	push   $0x0
80106573:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106579:	50                   	push   %eax
8010657a:	e8 43 ef ff ff       	call   801054c2 <memset>
8010657f:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106582:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658c:	83 f8 1f             	cmp    $0x1f,%eax
8010658f:	76 0a                	jbe    8010659b <sys_exec+0x72>
      return -1;
80106591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106596:	e9 94 00 00 00       	jmp    8010662f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010659b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659e:	c1 e0 02             	shl    $0x2,%eax
801065a1:	89 c2                	mov    %eax,%edx
801065a3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065a9:	01 c2                	add    %eax,%edx
801065ab:	83 ec 08             	sub    $0x8,%esp
801065ae:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065b4:	50                   	push   %eax
801065b5:	52                   	push   %edx
801065b6:	e8 92 f1 ff ff       	call   8010574d <fetchint>
801065bb:	83 c4 10             	add    $0x10,%esp
801065be:	85 c0                	test   %eax,%eax
801065c0:	79 07                	jns    801065c9 <sys_exec+0xa0>
      return -1;
801065c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c7:	eb 66                	jmp    8010662f <sys_exec+0x106>
    if(uarg == 0){
801065c9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065cf:	85 c0                	test   %eax,%eax
801065d1:	75 27                	jne    801065fa <sys_exec+0xd1>
      argv[i] = 0;
801065d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d6:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801065dd:	00 00 00 00 
      break;
801065e1:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801065e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e5:	83 ec 08             	sub    $0x8,%esp
801065e8:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801065ee:	52                   	push   %edx
801065ef:	50                   	push   %eax
801065f0:	e8 5a a5 ff ff       	call   80100b4f <exec>
801065f5:	83 c4 10             	add    $0x10,%esp
801065f8:	eb 35                	jmp    8010662f <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801065fa:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106600:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106603:	c1 e2 02             	shl    $0x2,%edx
80106606:	01 c2                	add    %eax,%edx
80106608:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010660e:	83 ec 08             	sub    $0x8,%esp
80106611:	52                   	push   %edx
80106612:	50                   	push   %eax
80106613:	e8 6f f1 ff ff       	call   80105787 <fetchstr>
80106618:	83 c4 10             	add    $0x10,%esp
8010661b:	85 c0                	test   %eax,%eax
8010661d:	79 07                	jns    80106626 <sys_exec+0xfd>
      return -1;
8010661f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106624:	eb 09                	jmp    8010662f <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010662a:	e9 5a ff ff ff       	jmp    80106589 <sys_exec+0x60>
  return exec(path, argv);
}
8010662f:	c9                   	leave  
80106630:	c3                   	ret    

80106631 <sys_pipe>:

int
sys_pipe(void)
{
80106631:	55                   	push   %ebp
80106632:	89 e5                	mov    %esp,%ebp
80106634:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106637:	83 ec 04             	sub    $0x4,%esp
8010663a:	6a 08                	push   $0x8
8010663c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010663f:	50                   	push   %eax
80106640:	6a 00                	push   $0x0
80106642:	e8 ca f1 ff ff       	call   80105811 <argptr>
80106647:	83 c4 10             	add    $0x10,%esp
8010664a:	85 c0                	test   %eax,%eax
8010664c:	79 0a                	jns    80106658 <sys_pipe+0x27>
    return -1;
8010664e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106653:	e9 af 00 00 00       	jmp    80106707 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106658:	83 ec 08             	sub    $0x8,%esp
8010665b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010665e:	50                   	push   %eax
8010665f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106662:	50                   	push   %eax
80106663:	e8 1e da ff ff       	call   80104086 <pipealloc>
80106668:	83 c4 10             	add    $0x10,%esp
8010666b:	85 c0                	test   %eax,%eax
8010666d:	79 0a                	jns    80106679 <sys_pipe+0x48>
    return -1;
8010666f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106674:	e9 8e 00 00 00       	jmp    80106707 <sys_pipe+0xd6>
  fd0 = -1;
80106679:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106680:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106683:	83 ec 0c             	sub    $0xc,%esp
80106686:	50                   	push   %eax
80106687:	e8 0f f3 ff ff       	call   8010599b <fdalloc>
8010668c:	83 c4 10             	add    $0x10,%esp
8010668f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106692:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106696:	78 18                	js     801066b0 <sys_pipe+0x7f>
80106698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010669b:	83 ec 0c             	sub    $0xc,%esp
8010669e:	50                   	push   %eax
8010669f:	e8 f7 f2 ff ff       	call   8010599b <fdalloc>
801066a4:	83 c4 10             	add    $0x10,%esp
801066a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066ae:	79 3f                	jns    801066ef <sys_pipe+0xbe>
    if(fd0 >= 0)
801066b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066b4:	78 14                	js     801066ca <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801066b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066bf:	83 c2 08             	add    $0x8,%edx
801066c2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066c9:	00 
    fileclose(rf);
801066ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066cd:	83 ec 0c             	sub    $0xc,%esp
801066d0:	50                   	push   %eax
801066d1:	e8 42 a9 ff ff       	call   80101018 <fileclose>
801066d6:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801066d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066dc:	83 ec 0c             	sub    $0xc,%esp
801066df:	50                   	push   %eax
801066e0:	e8 33 a9 ff ff       	call   80101018 <fileclose>
801066e5:	83 c4 10             	add    $0x10,%esp
    return -1;
801066e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ed:	eb 18                	jmp    80106707 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801066ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066f5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801066f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066fa:	8d 50 04             	lea    0x4(%eax),%edx
801066fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106700:	89 02                	mov    %eax,(%edx)
  return 0;
80106702:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106707:	c9                   	leave  
80106708:	c3                   	ret    

80106709 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106709:	55                   	push   %ebp
8010670a:	89 e5                	mov    %esp,%ebp
8010670c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010670f:	e8 68 e0 ff ff       	call   8010477c <fork>
}
80106714:	c9                   	leave  
80106715:	c3                   	ret    

80106716 <sys_exit>:

int
sys_exit(void)
{
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 08             	sub    $0x8,%esp
  exit();
8010671c:	e8 ec e1 ff ff       	call   8010490d <exit>
  return 0;  // not reached
80106721:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106726:	c9                   	leave  
80106727:	c3                   	ret    

80106728 <sys_wait>:

int
sys_wait(void)
{
80106728:	55                   	push   %ebp
80106729:	89 e5                	mov    %esp,%ebp
8010672b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010672e:	e8 12 e3 ff ff       	call   80104a45 <wait>
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <sys_kill>:

int
sys_kill(void)
{
80106735:	55                   	push   %ebp
80106736:	89 e5                	mov    %esp,%ebp
80106738:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010673b:	83 ec 08             	sub    $0x8,%esp
8010673e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106741:	50                   	push   %eax
80106742:	6a 00                	push   $0x0
80106744:	e8 a0 f0 ff ff       	call   801057e9 <argint>
80106749:	83 c4 10             	add    $0x10,%esp
8010674c:	85 c0                	test   %eax,%eax
8010674e:	79 07                	jns    80106757 <sys_kill+0x22>
    return -1;
80106750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106755:	eb 0f                	jmp    80106766 <sys_kill+0x31>
  return kill(pid);
80106757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675a:	83 ec 0c             	sub    $0xc,%esp
8010675d:	50                   	push   %eax
8010675e:	e8 ee e6 ff ff       	call   80104e51 <kill>
80106763:	83 c4 10             	add    $0x10,%esp
}
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <sys_getpid>:

int
sys_getpid(void)
{
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010676b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106771:	8b 40 10             	mov    0x10(%eax),%eax
}
80106774:	5d                   	pop    %ebp
80106775:	c3                   	ret    

80106776 <sys_sbrk>:

int
sys_sbrk(void)
{
80106776:	55                   	push   %ebp
80106777:	89 e5                	mov    %esp,%ebp
80106779:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010677c:	83 ec 08             	sub    $0x8,%esp
8010677f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106782:	50                   	push   %eax
80106783:	6a 00                	push   $0x0
80106785:	e8 5f f0 ff ff       	call   801057e9 <argint>
8010678a:	83 c4 10             	add    $0x10,%esp
8010678d:	85 c0                	test   %eax,%eax
8010678f:	79 07                	jns    80106798 <sys_sbrk+0x22>
    return -1;
80106791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106796:	eb 28                	jmp    801067c0 <sys_sbrk+0x4a>
  addr = proc->sz;
80106798:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010679e:	8b 00                	mov    (%eax),%eax
801067a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a6:	83 ec 0c             	sub    $0xc,%esp
801067a9:	50                   	push   %eax
801067aa:	e8 2a df ff ff       	call   801046d9 <growproc>
801067af:	83 c4 10             	add    $0x10,%esp
801067b2:	85 c0                	test   %eax,%eax
801067b4:	79 07                	jns    801067bd <sys_sbrk+0x47>
    return -1;
801067b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bb:	eb 03                	jmp    801067c0 <sys_sbrk+0x4a>
  return addr;
801067bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067c0:	c9                   	leave  
801067c1:	c3                   	ret    

801067c2 <sys_sleep>:

int
sys_sleep(void)
{
801067c2:	55                   	push   %ebp
801067c3:	89 e5                	mov    %esp,%ebp
801067c5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801067c8:	83 ec 08             	sub    $0x8,%esp
801067cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067ce:	50                   	push   %eax
801067cf:	6a 00                	push   $0x0
801067d1:	e8 13 f0 ff ff       	call   801057e9 <argint>
801067d6:	83 c4 10             	add    $0x10,%esp
801067d9:	85 c0                	test   %eax,%eax
801067db:	79 07                	jns    801067e4 <sys_sleep+0x22>
    return -1;
801067dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e2:	eb 77                	jmp    8010685b <sys_sleep+0x99>
  acquire(&tickslock);
801067e4:	83 ec 0c             	sub    $0xc,%esp
801067e7:	68 40 4e 11 80       	push   $0x80114e40
801067ec:	e8 75 ea ff ff       	call   80105266 <acquire>
801067f1:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801067f4:	a1 80 56 11 80       	mov    0x80115680,%eax
801067f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067fc:	eb 39                	jmp    80106837 <sys_sleep+0x75>
    if(proc->killed){
801067fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106804:	8b 40 24             	mov    0x24(%eax),%eax
80106807:	85 c0                	test   %eax,%eax
80106809:	74 17                	je     80106822 <sys_sleep+0x60>
      release(&tickslock);
8010680b:	83 ec 0c             	sub    $0xc,%esp
8010680e:	68 40 4e 11 80       	push   $0x80114e40
80106813:	e8 b4 ea ff ff       	call   801052cc <release>
80106818:	83 c4 10             	add    $0x10,%esp
      return -1;
8010681b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106820:	eb 39                	jmp    8010685b <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106822:	83 ec 08             	sub    $0x8,%esp
80106825:	68 40 4e 11 80       	push   $0x80114e40
8010682a:	68 80 56 11 80       	push   $0x80115680
8010682f:	e8 fe e4 ff ff       	call   80104d32 <sleep>
80106834:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106837:	a1 80 56 11 80       	mov    0x80115680,%eax
8010683c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010683f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106842:	39 d0                	cmp    %edx,%eax
80106844:	72 b8                	jb     801067fe <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106846:	83 ec 0c             	sub    $0xc,%esp
80106849:	68 40 4e 11 80       	push   $0x80114e40
8010684e:	e8 79 ea ff ff       	call   801052cc <release>
80106853:	83 c4 10             	add    $0x10,%esp
  return 0;
80106856:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010685b:	c9                   	leave  
8010685c:	c3                   	ret    

8010685d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010685d:	55                   	push   %ebp
8010685e:	89 e5                	mov    %esp,%ebp
80106860:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106863:	83 ec 0c             	sub    $0xc,%esp
80106866:	68 40 4e 11 80       	push   $0x80114e40
8010686b:	e8 f6 e9 ff ff       	call   80105266 <acquire>
80106870:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106873:	a1 80 56 11 80       	mov    0x80115680,%eax
80106878:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010687b:	83 ec 0c             	sub    $0xc,%esp
8010687e:	68 40 4e 11 80       	push   $0x80114e40
80106883:	e8 44 ea ff ff       	call   801052cc <release>
80106888:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010688b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010688e:	c9                   	leave  
8010688f:	c3                   	ret    

80106890 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106890:	55                   	push   %ebp
80106891:	89 e5                	mov    %esp,%ebp
80106893:	83 ec 08             	sub    $0x8,%esp
80106896:	8b 55 08             	mov    0x8(%ebp),%edx
80106899:	8b 45 0c             	mov    0xc(%ebp),%eax
8010689c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068ab:	ee                   	out    %al,(%dx)
}
801068ac:	c9                   	leave  
801068ad:	c3                   	ret    

801068ae <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801068ae:	55                   	push   %ebp
801068af:	89 e5                	mov    %esp,%ebp
801068b1:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801068b4:	6a 34                	push   $0x34
801068b6:	6a 43                	push   $0x43
801068b8:	e8 d3 ff ff ff       	call   80106890 <outb>
801068bd:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068c0:	68 9c 00 00 00       	push   $0x9c
801068c5:	6a 40                	push   $0x40
801068c7:	e8 c4 ff ff ff       	call   80106890 <outb>
801068cc:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068cf:	6a 2e                	push   $0x2e
801068d1:	6a 40                	push   $0x40
801068d3:	e8 b8 ff ff ff       	call   80106890 <outb>
801068d8:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801068db:	83 ec 0c             	sub    $0xc,%esp
801068de:	6a 00                	push   $0x0
801068e0:	e8 8d d6 ff ff       	call   80103f72 <picenable>
801068e5:	83 c4 10             	add    $0x10,%esp
}
801068e8:	c9                   	leave  
801068e9:	c3                   	ret    

801068ea <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068ea:	1e                   	push   %ds
  pushl %es
801068eb:	06                   	push   %es
  pushl %fs
801068ec:	0f a0                	push   %fs
  pushl %gs
801068ee:	0f a8                	push   %gs
  pushal
801068f0:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068f1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068f5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068f7:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068f9:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068fd:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068ff:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106901:	54                   	push   %esp
  call trap
80106902:	e8 d4 01 00 00       	call   80106adb <trap>
  addl $4, %esp
80106907:	83 c4 04             	add    $0x4,%esp

8010690a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010690a:	61                   	popa   
  popl %gs
8010690b:	0f a9                	pop    %gs
  popl %fs
8010690d:	0f a1                	pop    %fs
  popl %es
8010690f:	07                   	pop    %es
  popl %ds
80106910:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106911:	83 c4 08             	add    $0x8,%esp
  iret
80106914:	cf                   	iret   

80106915 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106915:	55                   	push   %ebp
80106916:	89 e5                	mov    %esp,%ebp
80106918:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010691b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010691e:	83 e8 01             	sub    $0x1,%eax
80106921:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106925:	8b 45 08             	mov    0x8(%ebp),%eax
80106928:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010692c:	8b 45 08             	mov    0x8(%ebp),%eax
8010692f:	c1 e8 10             	shr    $0x10,%eax
80106932:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106936:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106939:	0f 01 18             	lidtl  (%eax)
}
8010693c:	c9                   	leave  
8010693d:	c3                   	ret    

8010693e <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010693e:	55                   	push   %ebp
8010693f:	89 e5                	mov    %esp,%ebp
80106941:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106944:	0f 20 d0             	mov    %cr2,%eax
80106947:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010694a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010694d:	c9                   	leave  
8010694e:	c3                   	ret    

8010694f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010695c:	e9 c3 00 00 00       	jmp    80106a24 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106964:	8b 04 85 d8 b0 10 80 	mov    -0x7fef4f28(,%eax,4),%eax
8010696b:	89 c2                	mov    %eax,%edx
8010696d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106970:	66 89 14 c5 80 4e 11 	mov    %dx,-0x7feeb180(,%eax,8)
80106977:	80 
80106978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697b:	66 c7 04 c5 82 4e 11 	movw   $0x8,-0x7feeb17e(,%eax,8)
80106982:	80 08 00 
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106988:	0f b6 14 c5 84 4e 11 	movzbl -0x7feeb17c(,%eax,8),%edx
8010698f:	80 
80106990:	83 e2 e0             	and    $0xffffffe0,%edx
80106993:	88 14 c5 84 4e 11 80 	mov    %dl,-0x7feeb17c(,%eax,8)
8010699a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699d:	0f b6 14 c5 84 4e 11 	movzbl -0x7feeb17c(,%eax,8),%edx
801069a4:	80 
801069a5:	83 e2 1f             	and    $0x1f,%edx
801069a8:	88 14 c5 84 4e 11 80 	mov    %dl,-0x7feeb17c(,%eax,8)
801069af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b2:	0f b6 14 c5 85 4e 11 	movzbl -0x7feeb17b(,%eax,8),%edx
801069b9:	80 
801069ba:	83 e2 f0             	and    $0xfffffff0,%edx
801069bd:	83 ca 0e             	or     $0xe,%edx
801069c0:	88 14 c5 85 4e 11 80 	mov    %dl,-0x7feeb17b(,%eax,8)
801069c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ca:	0f b6 14 c5 85 4e 11 	movzbl -0x7feeb17b(,%eax,8),%edx
801069d1:	80 
801069d2:	83 e2 ef             	and    $0xffffffef,%edx
801069d5:	88 14 c5 85 4e 11 80 	mov    %dl,-0x7feeb17b(,%eax,8)
801069dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069df:	0f b6 14 c5 85 4e 11 	movzbl -0x7feeb17b(,%eax,8),%edx
801069e6:	80 
801069e7:	83 e2 9f             	and    $0xffffff9f,%edx
801069ea:	88 14 c5 85 4e 11 80 	mov    %dl,-0x7feeb17b(,%eax,8)
801069f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f4:	0f b6 14 c5 85 4e 11 	movzbl -0x7feeb17b(,%eax,8),%edx
801069fb:	80 
801069fc:	83 ca 80             	or     $0xffffff80,%edx
801069ff:	88 14 c5 85 4e 11 80 	mov    %dl,-0x7feeb17b(,%eax,8)
80106a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a09:	8b 04 85 d8 b0 10 80 	mov    -0x7fef4f28(,%eax,4),%eax
80106a10:	c1 e8 10             	shr    $0x10,%eax
80106a13:	89 c2                	mov    %eax,%edx
80106a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a18:	66 89 14 c5 86 4e 11 	mov    %dx,-0x7feeb17a(,%eax,8)
80106a1f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a24:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a2b:	0f 8e 30 ff ff ff    	jle    80106961 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a31:	a1 d8 b1 10 80       	mov    0x8010b1d8,%eax
80106a36:	66 a3 80 50 11 80    	mov    %ax,0x80115080
80106a3c:	66 c7 05 82 50 11 80 	movw   $0x8,0x80115082
80106a43:	08 00 
80106a45:	0f b6 05 84 50 11 80 	movzbl 0x80115084,%eax
80106a4c:	83 e0 e0             	and    $0xffffffe0,%eax
80106a4f:	a2 84 50 11 80       	mov    %al,0x80115084
80106a54:	0f b6 05 84 50 11 80 	movzbl 0x80115084,%eax
80106a5b:	83 e0 1f             	and    $0x1f,%eax
80106a5e:	a2 84 50 11 80       	mov    %al,0x80115084
80106a63:	0f b6 05 85 50 11 80 	movzbl 0x80115085,%eax
80106a6a:	83 c8 0f             	or     $0xf,%eax
80106a6d:	a2 85 50 11 80       	mov    %al,0x80115085
80106a72:	0f b6 05 85 50 11 80 	movzbl 0x80115085,%eax
80106a79:	83 e0 ef             	and    $0xffffffef,%eax
80106a7c:	a2 85 50 11 80       	mov    %al,0x80115085
80106a81:	0f b6 05 85 50 11 80 	movzbl 0x80115085,%eax
80106a88:	83 c8 60             	or     $0x60,%eax
80106a8b:	a2 85 50 11 80       	mov    %al,0x80115085
80106a90:	0f b6 05 85 50 11 80 	movzbl 0x80115085,%eax
80106a97:	83 c8 80             	or     $0xffffff80,%eax
80106a9a:	a2 85 50 11 80       	mov    %al,0x80115085
80106a9f:	a1 d8 b1 10 80       	mov    0x8010b1d8,%eax
80106aa4:	c1 e8 10             	shr    $0x10,%eax
80106aa7:	66 a3 86 50 11 80    	mov    %ax,0x80115086
  
  initlock(&tickslock, "time");
80106aad:	83 ec 08             	sub    $0x8,%esp
80106ab0:	68 64 8c 10 80       	push   $0x80108c64
80106ab5:	68 40 4e 11 80       	push   $0x80114e40
80106aba:	e8 86 e7 ff ff       	call   80105245 <initlock>
80106abf:	83 c4 10             	add    $0x10,%esp
}
80106ac2:	c9                   	leave  
80106ac3:	c3                   	ret    

80106ac4 <idtinit>:

void
idtinit(void)
{
80106ac4:	55                   	push   %ebp
80106ac5:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106ac7:	68 00 08 00 00       	push   $0x800
80106acc:	68 80 4e 11 80       	push   $0x80114e80
80106ad1:	e8 3f fe ff ff       	call   80106915 <lidt>
80106ad6:	83 c4 08             	add    $0x8,%esp
}
80106ad9:	c9                   	leave  
80106ada:	c3                   	ret    

80106adb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106adb:	55                   	push   %ebp
80106adc:	89 e5                	mov    %esp,%ebp
80106ade:	57                   	push   %edi
80106adf:	56                   	push   %esi
80106ae0:	53                   	push   %ebx
80106ae1:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae7:	8b 40 30             	mov    0x30(%eax),%eax
80106aea:	83 f8 40             	cmp    $0x40,%eax
80106aed:	75 3f                	jne    80106b2e <trap+0x53>
    if(proc->killed)
80106aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af5:	8b 40 24             	mov    0x24(%eax),%eax
80106af8:	85 c0                	test   %eax,%eax
80106afa:	74 05                	je     80106b01 <trap+0x26>
      exit();
80106afc:	e8 0c de ff ff       	call   8010490d <exit>
    proc->tf = tf;
80106b01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b07:	8b 55 08             	mov    0x8(%ebp),%edx
80106b0a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b0d:	e8 8f ed ff ff       	call   801058a1 <syscall>
    if(proc->killed)
80106b12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b18:	8b 40 24             	mov    0x24(%eax),%eax
80106b1b:	85 c0                	test   %eax,%eax
80106b1d:	74 0a                	je     80106b29 <trap+0x4e>
      exit();
80106b1f:	e8 e9 dd ff ff       	call   8010490d <exit>
    return;
80106b24:	e9 14 02 00 00       	jmp    80106d3d <trap+0x262>
80106b29:	e9 0f 02 00 00       	jmp    80106d3d <trap+0x262>
  }

  switch(tf->trapno){
80106b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b31:	8b 40 30             	mov    0x30(%eax),%eax
80106b34:	83 e8 20             	sub    $0x20,%eax
80106b37:	83 f8 1f             	cmp    $0x1f,%eax
80106b3a:	0f 87 c0 00 00 00    	ja     80106c00 <trap+0x125>
80106b40:	8b 04 85 0c 8d 10 80 	mov    -0x7fef72f4(,%eax,4),%eax
80106b47:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b49:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b4f:	0f b6 00             	movzbl (%eax),%eax
80106b52:	84 c0                	test   %al,%al
80106b54:	75 3d                	jne    80106b93 <trap+0xb8>
      acquire(&tickslock);
80106b56:	83 ec 0c             	sub    $0xc,%esp
80106b59:	68 40 4e 11 80       	push   $0x80114e40
80106b5e:	e8 03 e7 ff ff       	call   80105266 <acquire>
80106b63:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106b66:	a1 80 56 11 80       	mov    0x80115680,%eax
80106b6b:	83 c0 01             	add    $0x1,%eax
80106b6e:	a3 80 56 11 80       	mov    %eax,0x80115680
      wakeup(&ticks);
80106b73:	83 ec 0c             	sub    $0xc,%esp
80106b76:	68 80 56 11 80       	push   $0x80115680
80106b7b:	e8 9b e2 ff ff       	call   80104e1b <wakeup>
80106b80:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106b83:	83 ec 0c             	sub    $0xc,%esp
80106b86:	68 40 4e 11 80       	push   $0x80114e40
80106b8b:	e8 3c e7 ff ff       	call   801052cc <release>
80106b90:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106b93:	e8 d5 c4 ff ff       	call   8010306d <lapiceoi>
    break;
80106b98:	e9 1c 01 00 00       	jmp    80106cb9 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b9d:	e8 ec bc ff ff       	call   8010288e <ideintr>
    lapiceoi();
80106ba2:	e8 c6 c4 ff ff       	call   8010306d <lapiceoi>
    break;
80106ba7:	e9 0d 01 00 00       	jmp    80106cb9 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bac:	e8 c3 c2 ff ff       	call   80102e74 <kbdintr>
    lapiceoi();
80106bb1:	e8 b7 c4 ff ff       	call   8010306d <lapiceoi>
    break;
80106bb6:	e9 fe 00 00 00       	jmp    80106cb9 <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bbb:	e8 5a 03 00 00       	call   80106f1a <uartintr>
    lapiceoi();
80106bc0:	e8 a8 c4 ff ff       	call   8010306d <lapiceoi>
    break;
80106bc5:	e9 ef 00 00 00       	jmp    80106cb9 <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bca:	8b 45 08             	mov    0x8(%ebp),%eax
80106bcd:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bd7:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bda:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106be0:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106be3:	0f b6 c0             	movzbl %al,%eax
80106be6:	51                   	push   %ecx
80106be7:	52                   	push   %edx
80106be8:	50                   	push   %eax
80106be9:	68 6c 8c 10 80       	push   $0x80108c6c
80106bee:	e8 cc 97 ff ff       	call   801003bf <cprintf>
80106bf3:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106bf6:	e8 72 c4 ff ff       	call   8010306d <lapiceoi>
    break;
80106bfb:	e9 b9 00 00 00       	jmp    80106cb9 <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c06:	85 c0                	test   %eax,%eax
80106c08:	74 11                	je     80106c1b <trap+0x140>
80106c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80106c0d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c11:	0f b7 c0             	movzwl %ax,%eax
80106c14:	83 e0 03             	and    $0x3,%eax
80106c17:	85 c0                	test   %eax,%eax
80106c19:	75 40                	jne    80106c5b <trap+0x180>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c1b:	e8 1e fd ff ff       	call   8010693e <rcr2>
80106c20:	89 c3                	mov    %eax,%ebx
80106c22:	8b 45 08             	mov    0x8(%ebp),%eax
80106c25:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c2e:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c31:	0f b6 d0             	movzbl %al,%edx
80106c34:	8b 45 08             	mov    0x8(%ebp),%eax
80106c37:	8b 40 30             	mov    0x30(%eax),%eax
80106c3a:	83 ec 0c             	sub    $0xc,%esp
80106c3d:	53                   	push   %ebx
80106c3e:	51                   	push   %ecx
80106c3f:	52                   	push   %edx
80106c40:	50                   	push   %eax
80106c41:	68 90 8c 10 80       	push   $0x80108c90
80106c46:	e8 74 97 ff ff       	call   801003bf <cprintf>
80106c4b:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c4e:	83 ec 0c             	sub    $0xc,%esp
80106c51:	68 c2 8c 10 80       	push   $0x80108cc2
80106c56:	e8 01 99 ff ff       	call   8010055c <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c5b:	e8 de fc ff ff       	call   8010693e <rcr2>
80106c60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c63:	8b 45 08             	mov    0x8(%ebp),%eax
80106c66:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c69:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c6f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c72:	0f b6 d8             	movzbl %al,%ebx
80106c75:	8b 45 08             	mov    0x8(%ebp),%eax
80106c78:	8b 48 34             	mov    0x34(%eax),%ecx
80106c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7e:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c87:	8d 78 6c             	lea    0x6c(%eax),%edi
80106c8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c90:	8b 40 10             	mov    0x10(%eax),%eax
80106c93:	ff 75 e4             	pushl  -0x1c(%ebp)
80106c96:	56                   	push   %esi
80106c97:	53                   	push   %ebx
80106c98:	51                   	push   %ecx
80106c99:	52                   	push   %edx
80106c9a:	57                   	push   %edi
80106c9b:	50                   	push   %eax
80106c9c:	68 c8 8c 10 80       	push   $0x80108cc8
80106ca1:	e8 19 97 ff ff       	call   801003bf <cprintf>
80106ca6:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106caf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cb6:	eb 01                	jmp    80106cb9 <trap+0x1de>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cb8:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbf:	85 c0                	test   %eax,%eax
80106cc1:	74 24                	je     80106ce7 <trap+0x20c>
80106cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc9:	8b 40 24             	mov    0x24(%eax),%eax
80106ccc:	85 c0                	test   %eax,%eax
80106cce:	74 17                	je     80106ce7 <trap+0x20c>
80106cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cd7:	0f b7 c0             	movzwl %ax,%eax
80106cda:	83 e0 03             	and    $0x3,%eax
80106cdd:	83 f8 03             	cmp    $0x3,%eax
80106ce0:	75 05                	jne    80106ce7 <trap+0x20c>
    exit();
80106ce2:	e8 26 dc ff ff       	call   8010490d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ce7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ced:	85 c0                	test   %eax,%eax
80106cef:	74 1e                	je     80106d0f <trap+0x234>
80106cf1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf7:	8b 40 0c             	mov    0xc(%eax),%eax
80106cfa:	83 f8 04             	cmp    $0x4,%eax
80106cfd:	75 10                	jne    80106d0f <trap+0x234>
80106cff:	8b 45 08             	mov    0x8(%ebp),%eax
80106d02:	8b 40 30             	mov    0x30(%eax),%eax
80106d05:	83 f8 20             	cmp    $0x20,%eax
80106d08:	75 05                	jne    80106d0f <trap+0x234>
    yield();
80106d0a:	e8 b9 df ff ff       	call   80104cc8 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d15:	85 c0                	test   %eax,%eax
80106d17:	74 24                	je     80106d3d <trap+0x262>
80106d19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1f:	8b 40 24             	mov    0x24(%eax),%eax
80106d22:	85 c0                	test   %eax,%eax
80106d24:	74 17                	je     80106d3d <trap+0x262>
80106d26:	8b 45 08             	mov    0x8(%ebp),%eax
80106d29:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d2d:	0f b7 c0             	movzwl %ax,%eax
80106d30:	83 e0 03             	and    $0x3,%eax
80106d33:	83 f8 03             	cmp    $0x3,%eax
80106d36:	75 05                	jne    80106d3d <trap+0x262>
    exit();
80106d38:	e8 d0 db ff ff       	call   8010490d <exit>
}
80106d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d40:	5b                   	pop    %ebx
80106d41:	5e                   	pop    %esi
80106d42:	5f                   	pop    %edi
80106d43:	5d                   	pop    %ebp
80106d44:	c3                   	ret    

80106d45 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d45:	55                   	push   %ebp
80106d46:	89 e5                	mov    %esp,%ebp
80106d48:	83 ec 14             	sub    $0x14,%esp
80106d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d52:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d56:	89 c2                	mov    %eax,%edx
80106d58:	ec                   	in     (%dx),%al
80106d59:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d5c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d60:	c9                   	leave  
80106d61:	c3                   	ret    

80106d62 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d62:	55                   	push   %ebp
80106d63:	89 e5                	mov    %esp,%ebp
80106d65:	83 ec 08             	sub    $0x8,%esp
80106d68:	8b 55 08             	mov    0x8(%ebp),%edx
80106d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d6e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d72:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d75:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d79:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d7d:	ee                   	out    %al,(%dx)
}
80106d7e:	c9                   	leave  
80106d7f:	c3                   	ret    

80106d80 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d80:	55                   	push   %ebp
80106d81:	89 e5                	mov    %esp,%ebp
80106d83:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d86:	6a 00                	push   $0x0
80106d88:	68 fa 03 00 00       	push   $0x3fa
80106d8d:	e8 d0 ff ff ff       	call   80106d62 <outb>
80106d92:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d95:	68 80 00 00 00       	push   $0x80
80106d9a:	68 fb 03 00 00       	push   $0x3fb
80106d9f:	e8 be ff ff ff       	call   80106d62 <outb>
80106da4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106da7:	6a 0c                	push   $0xc
80106da9:	68 f8 03 00 00       	push   $0x3f8
80106dae:	e8 af ff ff ff       	call   80106d62 <outb>
80106db3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106db6:	6a 00                	push   $0x0
80106db8:	68 f9 03 00 00       	push   $0x3f9
80106dbd:	e8 a0 ff ff ff       	call   80106d62 <outb>
80106dc2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dc5:	6a 03                	push   $0x3
80106dc7:	68 fb 03 00 00       	push   $0x3fb
80106dcc:	e8 91 ff ff ff       	call   80106d62 <outb>
80106dd1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106dd4:	6a 00                	push   $0x0
80106dd6:	68 fc 03 00 00       	push   $0x3fc
80106ddb:	e8 82 ff ff ff       	call   80106d62 <outb>
80106de0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106de3:	6a 01                	push   $0x1
80106de5:	68 f9 03 00 00       	push   $0x3f9
80106dea:	e8 73 ff ff ff       	call   80106d62 <outb>
80106def:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106df2:	68 fd 03 00 00       	push   $0x3fd
80106df7:	e8 49 ff ff ff       	call   80106d45 <inb>
80106dfc:	83 c4 04             	add    $0x4,%esp
80106dff:	3c ff                	cmp    $0xff,%al
80106e01:	75 02                	jne    80106e05 <uartinit+0x85>
    return;
80106e03:	eb 6c                	jmp    80106e71 <uartinit+0xf1>
  uart = 1;
80106e05:	c7 05 ac b6 10 80 01 	movl   $0x1,0x8010b6ac
80106e0c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e0f:	68 fa 03 00 00       	push   $0x3fa
80106e14:	e8 2c ff ff ff       	call   80106d45 <inb>
80106e19:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e1c:	68 f8 03 00 00       	push   $0x3f8
80106e21:	e8 1f ff ff ff       	call   80106d45 <inb>
80106e26:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106e29:	83 ec 0c             	sub    $0xc,%esp
80106e2c:	6a 04                	push   $0x4
80106e2e:	e8 3f d1 ff ff       	call   80103f72 <picenable>
80106e33:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106e36:	83 ec 08             	sub    $0x8,%esp
80106e39:	6a 00                	push   $0x0
80106e3b:	6a 04                	push   $0x4
80106e3d:	e8 ea bc ff ff       	call   80102b2c <ioapicenable>
80106e42:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e45:	c7 45 f4 8c 8d 10 80 	movl   $0x80108d8c,-0xc(%ebp)
80106e4c:	eb 19                	jmp    80106e67 <uartinit+0xe7>
    uartputc(*p);
80106e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e51:	0f b6 00             	movzbl (%eax),%eax
80106e54:	0f be c0             	movsbl %al,%eax
80106e57:	83 ec 0c             	sub    $0xc,%esp
80106e5a:	50                   	push   %eax
80106e5b:	e8 13 00 00 00       	call   80106e73 <uartputc>
80106e60:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6a:	0f b6 00             	movzbl (%eax),%eax
80106e6d:	84 c0                	test   %al,%al
80106e6f:	75 dd                	jne    80106e4e <uartinit+0xce>
    uartputc(*p);
}
80106e71:	c9                   	leave  
80106e72:	c3                   	ret    

80106e73 <uartputc>:

void
uartputc(int c)
{
80106e73:	55                   	push   %ebp
80106e74:	89 e5                	mov    %esp,%ebp
80106e76:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e79:	a1 ac b6 10 80       	mov    0x8010b6ac,%eax
80106e7e:	85 c0                	test   %eax,%eax
80106e80:	75 02                	jne    80106e84 <uartputc+0x11>
    return;
80106e82:	eb 51                	jmp    80106ed5 <uartputc+0x62>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e8b:	eb 11                	jmp    80106e9e <uartputc+0x2b>
    microdelay(10);
80106e8d:	83 ec 0c             	sub    $0xc,%esp
80106e90:	6a 0a                	push   $0xa
80106e92:	e8 f0 c1 ff ff       	call   80103087 <microdelay>
80106e97:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e9e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ea2:	7f 1a                	jg     80106ebe <uartputc+0x4b>
80106ea4:	83 ec 0c             	sub    $0xc,%esp
80106ea7:	68 fd 03 00 00       	push   $0x3fd
80106eac:	e8 94 fe ff ff       	call   80106d45 <inb>
80106eb1:	83 c4 10             	add    $0x10,%esp
80106eb4:	0f b6 c0             	movzbl %al,%eax
80106eb7:	83 e0 20             	and    $0x20,%eax
80106eba:	85 c0                	test   %eax,%eax
80106ebc:	74 cf                	je     80106e8d <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec1:	0f b6 c0             	movzbl %al,%eax
80106ec4:	83 ec 08             	sub    $0x8,%esp
80106ec7:	50                   	push   %eax
80106ec8:	68 f8 03 00 00       	push   $0x3f8
80106ecd:	e8 90 fe ff ff       	call   80106d62 <outb>
80106ed2:	83 c4 10             	add    $0x10,%esp
}
80106ed5:	c9                   	leave  
80106ed6:	c3                   	ret    

80106ed7 <uartgetc>:

static int
uartgetc(void)
{
80106ed7:	55                   	push   %ebp
80106ed8:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106eda:	a1 ac b6 10 80       	mov    0x8010b6ac,%eax
80106edf:	85 c0                	test   %eax,%eax
80106ee1:	75 07                	jne    80106eea <uartgetc+0x13>
    return -1;
80106ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee8:	eb 2e                	jmp    80106f18 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106eea:	68 fd 03 00 00       	push   $0x3fd
80106eef:	e8 51 fe ff ff       	call   80106d45 <inb>
80106ef4:	83 c4 04             	add    $0x4,%esp
80106ef7:	0f b6 c0             	movzbl %al,%eax
80106efa:	83 e0 01             	and    $0x1,%eax
80106efd:	85 c0                	test   %eax,%eax
80106eff:	75 07                	jne    80106f08 <uartgetc+0x31>
    return -1;
80106f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f06:	eb 10                	jmp    80106f18 <uartgetc+0x41>
  return inb(COM1+0);
80106f08:	68 f8 03 00 00       	push   $0x3f8
80106f0d:	e8 33 fe ff ff       	call   80106d45 <inb>
80106f12:	83 c4 04             	add    $0x4,%esp
80106f15:	0f b6 c0             	movzbl %al,%eax
}
80106f18:	c9                   	leave  
80106f19:	c3                   	ret    

80106f1a <uartintr>:

void
uartintr(void)
{
80106f1a:	55                   	push   %ebp
80106f1b:	89 e5                	mov    %esp,%ebp
80106f1d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f20:	83 ec 0c             	sub    $0xc,%esp
80106f23:	68 d7 6e 10 80       	push   $0x80106ed7
80106f28:	e8 a4 98 ff ff       	call   801007d1 <consoleintr>
80106f2d:	83 c4 10             	add    $0x10,%esp
}
80106f30:	c9                   	leave  
80106f31:	c3                   	ret    

80106f32 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $0
80106f34:	6a 00                	push   $0x0
  jmp alltraps
80106f36:	e9 af f9 ff ff       	jmp    801068ea <alltraps>

80106f3b <vector1>:
.globl vector1
vector1:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $1
80106f3d:	6a 01                	push   $0x1
  jmp alltraps
80106f3f:	e9 a6 f9 ff ff       	jmp    801068ea <alltraps>

80106f44 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $2
80106f46:	6a 02                	push   $0x2
  jmp alltraps
80106f48:	e9 9d f9 ff ff       	jmp    801068ea <alltraps>

80106f4d <vector3>:
.globl vector3
vector3:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $3
80106f4f:	6a 03                	push   $0x3
  jmp alltraps
80106f51:	e9 94 f9 ff ff       	jmp    801068ea <alltraps>

80106f56 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $4
80106f58:	6a 04                	push   $0x4
  jmp alltraps
80106f5a:	e9 8b f9 ff ff       	jmp    801068ea <alltraps>

80106f5f <vector5>:
.globl vector5
vector5:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $5
80106f61:	6a 05                	push   $0x5
  jmp alltraps
80106f63:	e9 82 f9 ff ff       	jmp    801068ea <alltraps>

80106f68 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $6
80106f6a:	6a 06                	push   $0x6
  jmp alltraps
80106f6c:	e9 79 f9 ff ff       	jmp    801068ea <alltraps>

80106f71 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $7
80106f73:	6a 07                	push   $0x7
  jmp alltraps
80106f75:	e9 70 f9 ff ff       	jmp    801068ea <alltraps>

80106f7a <vector8>:
.globl vector8
vector8:
  pushl $8
80106f7a:	6a 08                	push   $0x8
  jmp alltraps
80106f7c:	e9 69 f9 ff ff       	jmp    801068ea <alltraps>

80106f81 <vector9>:
.globl vector9
vector9:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $9
80106f83:	6a 09                	push   $0x9
  jmp alltraps
80106f85:	e9 60 f9 ff ff       	jmp    801068ea <alltraps>

80106f8a <vector10>:
.globl vector10
vector10:
  pushl $10
80106f8a:	6a 0a                	push   $0xa
  jmp alltraps
80106f8c:	e9 59 f9 ff ff       	jmp    801068ea <alltraps>

80106f91 <vector11>:
.globl vector11
vector11:
  pushl $11
80106f91:	6a 0b                	push   $0xb
  jmp alltraps
80106f93:	e9 52 f9 ff ff       	jmp    801068ea <alltraps>

80106f98 <vector12>:
.globl vector12
vector12:
  pushl $12
80106f98:	6a 0c                	push   $0xc
  jmp alltraps
80106f9a:	e9 4b f9 ff ff       	jmp    801068ea <alltraps>

80106f9f <vector13>:
.globl vector13
vector13:
  pushl $13
80106f9f:	6a 0d                	push   $0xd
  jmp alltraps
80106fa1:	e9 44 f9 ff ff       	jmp    801068ea <alltraps>

80106fa6 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fa6:	6a 0e                	push   $0xe
  jmp alltraps
80106fa8:	e9 3d f9 ff ff       	jmp    801068ea <alltraps>

80106fad <vector15>:
.globl vector15
vector15:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $15
80106faf:	6a 0f                	push   $0xf
  jmp alltraps
80106fb1:	e9 34 f9 ff ff       	jmp    801068ea <alltraps>

80106fb6 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $16
80106fb8:	6a 10                	push   $0x10
  jmp alltraps
80106fba:	e9 2b f9 ff ff       	jmp    801068ea <alltraps>

80106fbf <vector17>:
.globl vector17
vector17:
  pushl $17
80106fbf:	6a 11                	push   $0x11
  jmp alltraps
80106fc1:	e9 24 f9 ff ff       	jmp    801068ea <alltraps>

80106fc6 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $18
80106fc8:	6a 12                	push   $0x12
  jmp alltraps
80106fca:	e9 1b f9 ff ff       	jmp    801068ea <alltraps>

80106fcf <vector19>:
.globl vector19
vector19:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $19
80106fd1:	6a 13                	push   $0x13
  jmp alltraps
80106fd3:	e9 12 f9 ff ff       	jmp    801068ea <alltraps>

80106fd8 <vector20>:
.globl vector20
vector20:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $20
80106fda:	6a 14                	push   $0x14
  jmp alltraps
80106fdc:	e9 09 f9 ff ff       	jmp    801068ea <alltraps>

80106fe1 <vector21>:
.globl vector21
vector21:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $21
80106fe3:	6a 15                	push   $0x15
  jmp alltraps
80106fe5:	e9 00 f9 ff ff       	jmp    801068ea <alltraps>

80106fea <vector22>:
.globl vector22
vector22:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $22
80106fec:	6a 16                	push   $0x16
  jmp alltraps
80106fee:	e9 f7 f8 ff ff       	jmp    801068ea <alltraps>

80106ff3 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $23
80106ff5:	6a 17                	push   $0x17
  jmp alltraps
80106ff7:	e9 ee f8 ff ff       	jmp    801068ea <alltraps>

80106ffc <vector24>:
.globl vector24
vector24:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $24
80106ffe:	6a 18                	push   $0x18
  jmp alltraps
80107000:	e9 e5 f8 ff ff       	jmp    801068ea <alltraps>

80107005 <vector25>:
.globl vector25
vector25:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $25
80107007:	6a 19                	push   $0x19
  jmp alltraps
80107009:	e9 dc f8 ff ff       	jmp    801068ea <alltraps>

8010700e <vector26>:
.globl vector26
vector26:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $26
80107010:	6a 1a                	push   $0x1a
  jmp alltraps
80107012:	e9 d3 f8 ff ff       	jmp    801068ea <alltraps>

80107017 <vector27>:
.globl vector27
vector27:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $27
80107019:	6a 1b                	push   $0x1b
  jmp alltraps
8010701b:	e9 ca f8 ff ff       	jmp    801068ea <alltraps>

80107020 <vector28>:
.globl vector28
vector28:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $28
80107022:	6a 1c                	push   $0x1c
  jmp alltraps
80107024:	e9 c1 f8 ff ff       	jmp    801068ea <alltraps>

80107029 <vector29>:
.globl vector29
vector29:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $29
8010702b:	6a 1d                	push   $0x1d
  jmp alltraps
8010702d:	e9 b8 f8 ff ff       	jmp    801068ea <alltraps>

80107032 <vector30>:
.globl vector30
vector30:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $30
80107034:	6a 1e                	push   $0x1e
  jmp alltraps
80107036:	e9 af f8 ff ff       	jmp    801068ea <alltraps>

8010703b <vector31>:
.globl vector31
vector31:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $31
8010703d:	6a 1f                	push   $0x1f
  jmp alltraps
8010703f:	e9 a6 f8 ff ff       	jmp    801068ea <alltraps>

80107044 <vector32>:
.globl vector32
vector32:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $32
80107046:	6a 20                	push   $0x20
  jmp alltraps
80107048:	e9 9d f8 ff ff       	jmp    801068ea <alltraps>

8010704d <vector33>:
.globl vector33
vector33:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $33
8010704f:	6a 21                	push   $0x21
  jmp alltraps
80107051:	e9 94 f8 ff ff       	jmp    801068ea <alltraps>

80107056 <vector34>:
.globl vector34
vector34:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $34
80107058:	6a 22                	push   $0x22
  jmp alltraps
8010705a:	e9 8b f8 ff ff       	jmp    801068ea <alltraps>

8010705f <vector35>:
.globl vector35
vector35:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $35
80107061:	6a 23                	push   $0x23
  jmp alltraps
80107063:	e9 82 f8 ff ff       	jmp    801068ea <alltraps>

80107068 <vector36>:
.globl vector36
vector36:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $36
8010706a:	6a 24                	push   $0x24
  jmp alltraps
8010706c:	e9 79 f8 ff ff       	jmp    801068ea <alltraps>

80107071 <vector37>:
.globl vector37
vector37:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $37
80107073:	6a 25                	push   $0x25
  jmp alltraps
80107075:	e9 70 f8 ff ff       	jmp    801068ea <alltraps>

8010707a <vector38>:
.globl vector38
vector38:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $38
8010707c:	6a 26                	push   $0x26
  jmp alltraps
8010707e:	e9 67 f8 ff ff       	jmp    801068ea <alltraps>

80107083 <vector39>:
.globl vector39
vector39:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $39
80107085:	6a 27                	push   $0x27
  jmp alltraps
80107087:	e9 5e f8 ff ff       	jmp    801068ea <alltraps>

8010708c <vector40>:
.globl vector40
vector40:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $40
8010708e:	6a 28                	push   $0x28
  jmp alltraps
80107090:	e9 55 f8 ff ff       	jmp    801068ea <alltraps>

80107095 <vector41>:
.globl vector41
vector41:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $41
80107097:	6a 29                	push   $0x29
  jmp alltraps
80107099:	e9 4c f8 ff ff       	jmp    801068ea <alltraps>

8010709e <vector42>:
.globl vector42
vector42:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $42
801070a0:	6a 2a                	push   $0x2a
  jmp alltraps
801070a2:	e9 43 f8 ff ff       	jmp    801068ea <alltraps>

801070a7 <vector43>:
.globl vector43
vector43:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $43
801070a9:	6a 2b                	push   $0x2b
  jmp alltraps
801070ab:	e9 3a f8 ff ff       	jmp    801068ea <alltraps>

801070b0 <vector44>:
.globl vector44
vector44:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $44
801070b2:	6a 2c                	push   $0x2c
  jmp alltraps
801070b4:	e9 31 f8 ff ff       	jmp    801068ea <alltraps>

801070b9 <vector45>:
.globl vector45
vector45:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $45
801070bb:	6a 2d                	push   $0x2d
  jmp alltraps
801070bd:	e9 28 f8 ff ff       	jmp    801068ea <alltraps>

801070c2 <vector46>:
.globl vector46
vector46:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $46
801070c4:	6a 2e                	push   $0x2e
  jmp alltraps
801070c6:	e9 1f f8 ff ff       	jmp    801068ea <alltraps>

801070cb <vector47>:
.globl vector47
vector47:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $47
801070cd:	6a 2f                	push   $0x2f
  jmp alltraps
801070cf:	e9 16 f8 ff ff       	jmp    801068ea <alltraps>

801070d4 <vector48>:
.globl vector48
vector48:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $48
801070d6:	6a 30                	push   $0x30
  jmp alltraps
801070d8:	e9 0d f8 ff ff       	jmp    801068ea <alltraps>

801070dd <vector49>:
.globl vector49
vector49:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $49
801070df:	6a 31                	push   $0x31
  jmp alltraps
801070e1:	e9 04 f8 ff ff       	jmp    801068ea <alltraps>

801070e6 <vector50>:
.globl vector50
vector50:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $50
801070e8:	6a 32                	push   $0x32
  jmp alltraps
801070ea:	e9 fb f7 ff ff       	jmp    801068ea <alltraps>

801070ef <vector51>:
.globl vector51
vector51:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $51
801070f1:	6a 33                	push   $0x33
  jmp alltraps
801070f3:	e9 f2 f7 ff ff       	jmp    801068ea <alltraps>

801070f8 <vector52>:
.globl vector52
vector52:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $52
801070fa:	6a 34                	push   $0x34
  jmp alltraps
801070fc:	e9 e9 f7 ff ff       	jmp    801068ea <alltraps>

80107101 <vector53>:
.globl vector53
vector53:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $53
80107103:	6a 35                	push   $0x35
  jmp alltraps
80107105:	e9 e0 f7 ff ff       	jmp    801068ea <alltraps>

8010710a <vector54>:
.globl vector54
vector54:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $54
8010710c:	6a 36                	push   $0x36
  jmp alltraps
8010710e:	e9 d7 f7 ff ff       	jmp    801068ea <alltraps>

80107113 <vector55>:
.globl vector55
vector55:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $55
80107115:	6a 37                	push   $0x37
  jmp alltraps
80107117:	e9 ce f7 ff ff       	jmp    801068ea <alltraps>

8010711c <vector56>:
.globl vector56
vector56:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $56
8010711e:	6a 38                	push   $0x38
  jmp alltraps
80107120:	e9 c5 f7 ff ff       	jmp    801068ea <alltraps>

80107125 <vector57>:
.globl vector57
vector57:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $57
80107127:	6a 39                	push   $0x39
  jmp alltraps
80107129:	e9 bc f7 ff ff       	jmp    801068ea <alltraps>

8010712e <vector58>:
.globl vector58
vector58:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $58
80107130:	6a 3a                	push   $0x3a
  jmp alltraps
80107132:	e9 b3 f7 ff ff       	jmp    801068ea <alltraps>

80107137 <vector59>:
.globl vector59
vector59:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $59
80107139:	6a 3b                	push   $0x3b
  jmp alltraps
8010713b:	e9 aa f7 ff ff       	jmp    801068ea <alltraps>

80107140 <vector60>:
.globl vector60
vector60:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $60
80107142:	6a 3c                	push   $0x3c
  jmp alltraps
80107144:	e9 a1 f7 ff ff       	jmp    801068ea <alltraps>

80107149 <vector61>:
.globl vector61
vector61:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $61
8010714b:	6a 3d                	push   $0x3d
  jmp alltraps
8010714d:	e9 98 f7 ff ff       	jmp    801068ea <alltraps>

80107152 <vector62>:
.globl vector62
vector62:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $62
80107154:	6a 3e                	push   $0x3e
  jmp alltraps
80107156:	e9 8f f7 ff ff       	jmp    801068ea <alltraps>

8010715b <vector63>:
.globl vector63
vector63:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $63
8010715d:	6a 3f                	push   $0x3f
  jmp alltraps
8010715f:	e9 86 f7 ff ff       	jmp    801068ea <alltraps>

80107164 <vector64>:
.globl vector64
vector64:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $64
80107166:	6a 40                	push   $0x40
  jmp alltraps
80107168:	e9 7d f7 ff ff       	jmp    801068ea <alltraps>

8010716d <vector65>:
.globl vector65
vector65:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $65
8010716f:	6a 41                	push   $0x41
  jmp alltraps
80107171:	e9 74 f7 ff ff       	jmp    801068ea <alltraps>

80107176 <vector66>:
.globl vector66
vector66:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $66
80107178:	6a 42                	push   $0x42
  jmp alltraps
8010717a:	e9 6b f7 ff ff       	jmp    801068ea <alltraps>

8010717f <vector67>:
.globl vector67
vector67:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $67
80107181:	6a 43                	push   $0x43
  jmp alltraps
80107183:	e9 62 f7 ff ff       	jmp    801068ea <alltraps>

80107188 <vector68>:
.globl vector68
vector68:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $68
8010718a:	6a 44                	push   $0x44
  jmp alltraps
8010718c:	e9 59 f7 ff ff       	jmp    801068ea <alltraps>

80107191 <vector69>:
.globl vector69
vector69:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $69
80107193:	6a 45                	push   $0x45
  jmp alltraps
80107195:	e9 50 f7 ff ff       	jmp    801068ea <alltraps>

8010719a <vector70>:
.globl vector70
vector70:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $70
8010719c:	6a 46                	push   $0x46
  jmp alltraps
8010719e:	e9 47 f7 ff ff       	jmp    801068ea <alltraps>

801071a3 <vector71>:
.globl vector71
vector71:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $71
801071a5:	6a 47                	push   $0x47
  jmp alltraps
801071a7:	e9 3e f7 ff ff       	jmp    801068ea <alltraps>

801071ac <vector72>:
.globl vector72
vector72:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $72
801071ae:	6a 48                	push   $0x48
  jmp alltraps
801071b0:	e9 35 f7 ff ff       	jmp    801068ea <alltraps>

801071b5 <vector73>:
.globl vector73
vector73:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $73
801071b7:	6a 49                	push   $0x49
  jmp alltraps
801071b9:	e9 2c f7 ff ff       	jmp    801068ea <alltraps>

801071be <vector74>:
.globl vector74
vector74:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $74
801071c0:	6a 4a                	push   $0x4a
  jmp alltraps
801071c2:	e9 23 f7 ff ff       	jmp    801068ea <alltraps>

801071c7 <vector75>:
.globl vector75
vector75:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $75
801071c9:	6a 4b                	push   $0x4b
  jmp alltraps
801071cb:	e9 1a f7 ff ff       	jmp    801068ea <alltraps>

801071d0 <vector76>:
.globl vector76
vector76:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $76
801071d2:	6a 4c                	push   $0x4c
  jmp alltraps
801071d4:	e9 11 f7 ff ff       	jmp    801068ea <alltraps>

801071d9 <vector77>:
.globl vector77
vector77:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $77
801071db:	6a 4d                	push   $0x4d
  jmp alltraps
801071dd:	e9 08 f7 ff ff       	jmp    801068ea <alltraps>

801071e2 <vector78>:
.globl vector78
vector78:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $78
801071e4:	6a 4e                	push   $0x4e
  jmp alltraps
801071e6:	e9 ff f6 ff ff       	jmp    801068ea <alltraps>

801071eb <vector79>:
.globl vector79
vector79:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $79
801071ed:	6a 4f                	push   $0x4f
  jmp alltraps
801071ef:	e9 f6 f6 ff ff       	jmp    801068ea <alltraps>

801071f4 <vector80>:
.globl vector80
vector80:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $80
801071f6:	6a 50                	push   $0x50
  jmp alltraps
801071f8:	e9 ed f6 ff ff       	jmp    801068ea <alltraps>

801071fd <vector81>:
.globl vector81
vector81:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $81
801071ff:	6a 51                	push   $0x51
  jmp alltraps
80107201:	e9 e4 f6 ff ff       	jmp    801068ea <alltraps>

80107206 <vector82>:
.globl vector82
vector82:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $82
80107208:	6a 52                	push   $0x52
  jmp alltraps
8010720a:	e9 db f6 ff ff       	jmp    801068ea <alltraps>

8010720f <vector83>:
.globl vector83
vector83:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $83
80107211:	6a 53                	push   $0x53
  jmp alltraps
80107213:	e9 d2 f6 ff ff       	jmp    801068ea <alltraps>

80107218 <vector84>:
.globl vector84
vector84:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $84
8010721a:	6a 54                	push   $0x54
  jmp alltraps
8010721c:	e9 c9 f6 ff ff       	jmp    801068ea <alltraps>

80107221 <vector85>:
.globl vector85
vector85:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $85
80107223:	6a 55                	push   $0x55
  jmp alltraps
80107225:	e9 c0 f6 ff ff       	jmp    801068ea <alltraps>

8010722a <vector86>:
.globl vector86
vector86:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $86
8010722c:	6a 56                	push   $0x56
  jmp alltraps
8010722e:	e9 b7 f6 ff ff       	jmp    801068ea <alltraps>

80107233 <vector87>:
.globl vector87
vector87:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $87
80107235:	6a 57                	push   $0x57
  jmp alltraps
80107237:	e9 ae f6 ff ff       	jmp    801068ea <alltraps>

8010723c <vector88>:
.globl vector88
vector88:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $88
8010723e:	6a 58                	push   $0x58
  jmp alltraps
80107240:	e9 a5 f6 ff ff       	jmp    801068ea <alltraps>

80107245 <vector89>:
.globl vector89
vector89:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $89
80107247:	6a 59                	push   $0x59
  jmp alltraps
80107249:	e9 9c f6 ff ff       	jmp    801068ea <alltraps>

8010724e <vector90>:
.globl vector90
vector90:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $90
80107250:	6a 5a                	push   $0x5a
  jmp alltraps
80107252:	e9 93 f6 ff ff       	jmp    801068ea <alltraps>

80107257 <vector91>:
.globl vector91
vector91:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $91
80107259:	6a 5b                	push   $0x5b
  jmp alltraps
8010725b:	e9 8a f6 ff ff       	jmp    801068ea <alltraps>

80107260 <vector92>:
.globl vector92
vector92:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $92
80107262:	6a 5c                	push   $0x5c
  jmp alltraps
80107264:	e9 81 f6 ff ff       	jmp    801068ea <alltraps>

80107269 <vector93>:
.globl vector93
vector93:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $93
8010726b:	6a 5d                	push   $0x5d
  jmp alltraps
8010726d:	e9 78 f6 ff ff       	jmp    801068ea <alltraps>

80107272 <vector94>:
.globl vector94
vector94:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $94
80107274:	6a 5e                	push   $0x5e
  jmp alltraps
80107276:	e9 6f f6 ff ff       	jmp    801068ea <alltraps>

8010727b <vector95>:
.globl vector95
vector95:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $95
8010727d:	6a 5f                	push   $0x5f
  jmp alltraps
8010727f:	e9 66 f6 ff ff       	jmp    801068ea <alltraps>

80107284 <vector96>:
.globl vector96
vector96:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $96
80107286:	6a 60                	push   $0x60
  jmp alltraps
80107288:	e9 5d f6 ff ff       	jmp    801068ea <alltraps>

8010728d <vector97>:
.globl vector97
vector97:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $97
8010728f:	6a 61                	push   $0x61
  jmp alltraps
80107291:	e9 54 f6 ff ff       	jmp    801068ea <alltraps>

80107296 <vector98>:
.globl vector98
vector98:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $98
80107298:	6a 62                	push   $0x62
  jmp alltraps
8010729a:	e9 4b f6 ff ff       	jmp    801068ea <alltraps>

8010729f <vector99>:
.globl vector99
vector99:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $99
801072a1:	6a 63                	push   $0x63
  jmp alltraps
801072a3:	e9 42 f6 ff ff       	jmp    801068ea <alltraps>

801072a8 <vector100>:
.globl vector100
vector100:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $100
801072aa:	6a 64                	push   $0x64
  jmp alltraps
801072ac:	e9 39 f6 ff ff       	jmp    801068ea <alltraps>

801072b1 <vector101>:
.globl vector101
vector101:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $101
801072b3:	6a 65                	push   $0x65
  jmp alltraps
801072b5:	e9 30 f6 ff ff       	jmp    801068ea <alltraps>

801072ba <vector102>:
.globl vector102
vector102:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $102
801072bc:	6a 66                	push   $0x66
  jmp alltraps
801072be:	e9 27 f6 ff ff       	jmp    801068ea <alltraps>

801072c3 <vector103>:
.globl vector103
vector103:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $103
801072c5:	6a 67                	push   $0x67
  jmp alltraps
801072c7:	e9 1e f6 ff ff       	jmp    801068ea <alltraps>

801072cc <vector104>:
.globl vector104
vector104:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $104
801072ce:	6a 68                	push   $0x68
  jmp alltraps
801072d0:	e9 15 f6 ff ff       	jmp    801068ea <alltraps>

801072d5 <vector105>:
.globl vector105
vector105:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $105
801072d7:	6a 69                	push   $0x69
  jmp alltraps
801072d9:	e9 0c f6 ff ff       	jmp    801068ea <alltraps>

801072de <vector106>:
.globl vector106
vector106:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $106
801072e0:	6a 6a                	push   $0x6a
  jmp alltraps
801072e2:	e9 03 f6 ff ff       	jmp    801068ea <alltraps>

801072e7 <vector107>:
.globl vector107
vector107:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $107
801072e9:	6a 6b                	push   $0x6b
  jmp alltraps
801072eb:	e9 fa f5 ff ff       	jmp    801068ea <alltraps>

801072f0 <vector108>:
.globl vector108
vector108:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $108
801072f2:	6a 6c                	push   $0x6c
  jmp alltraps
801072f4:	e9 f1 f5 ff ff       	jmp    801068ea <alltraps>

801072f9 <vector109>:
.globl vector109
vector109:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $109
801072fb:	6a 6d                	push   $0x6d
  jmp alltraps
801072fd:	e9 e8 f5 ff ff       	jmp    801068ea <alltraps>

80107302 <vector110>:
.globl vector110
vector110:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $110
80107304:	6a 6e                	push   $0x6e
  jmp alltraps
80107306:	e9 df f5 ff ff       	jmp    801068ea <alltraps>

8010730b <vector111>:
.globl vector111
vector111:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $111
8010730d:	6a 6f                	push   $0x6f
  jmp alltraps
8010730f:	e9 d6 f5 ff ff       	jmp    801068ea <alltraps>

80107314 <vector112>:
.globl vector112
vector112:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $112
80107316:	6a 70                	push   $0x70
  jmp alltraps
80107318:	e9 cd f5 ff ff       	jmp    801068ea <alltraps>

8010731d <vector113>:
.globl vector113
vector113:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $113
8010731f:	6a 71                	push   $0x71
  jmp alltraps
80107321:	e9 c4 f5 ff ff       	jmp    801068ea <alltraps>

80107326 <vector114>:
.globl vector114
vector114:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $114
80107328:	6a 72                	push   $0x72
  jmp alltraps
8010732a:	e9 bb f5 ff ff       	jmp    801068ea <alltraps>

8010732f <vector115>:
.globl vector115
vector115:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $115
80107331:	6a 73                	push   $0x73
  jmp alltraps
80107333:	e9 b2 f5 ff ff       	jmp    801068ea <alltraps>

80107338 <vector116>:
.globl vector116
vector116:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $116
8010733a:	6a 74                	push   $0x74
  jmp alltraps
8010733c:	e9 a9 f5 ff ff       	jmp    801068ea <alltraps>

80107341 <vector117>:
.globl vector117
vector117:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $117
80107343:	6a 75                	push   $0x75
  jmp alltraps
80107345:	e9 a0 f5 ff ff       	jmp    801068ea <alltraps>

8010734a <vector118>:
.globl vector118
vector118:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $118
8010734c:	6a 76                	push   $0x76
  jmp alltraps
8010734e:	e9 97 f5 ff ff       	jmp    801068ea <alltraps>

80107353 <vector119>:
.globl vector119
vector119:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $119
80107355:	6a 77                	push   $0x77
  jmp alltraps
80107357:	e9 8e f5 ff ff       	jmp    801068ea <alltraps>

8010735c <vector120>:
.globl vector120
vector120:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $120
8010735e:	6a 78                	push   $0x78
  jmp alltraps
80107360:	e9 85 f5 ff ff       	jmp    801068ea <alltraps>

80107365 <vector121>:
.globl vector121
vector121:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $121
80107367:	6a 79                	push   $0x79
  jmp alltraps
80107369:	e9 7c f5 ff ff       	jmp    801068ea <alltraps>

8010736e <vector122>:
.globl vector122
vector122:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $122
80107370:	6a 7a                	push   $0x7a
  jmp alltraps
80107372:	e9 73 f5 ff ff       	jmp    801068ea <alltraps>

80107377 <vector123>:
.globl vector123
vector123:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $123
80107379:	6a 7b                	push   $0x7b
  jmp alltraps
8010737b:	e9 6a f5 ff ff       	jmp    801068ea <alltraps>

80107380 <vector124>:
.globl vector124
vector124:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $124
80107382:	6a 7c                	push   $0x7c
  jmp alltraps
80107384:	e9 61 f5 ff ff       	jmp    801068ea <alltraps>

80107389 <vector125>:
.globl vector125
vector125:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $125
8010738b:	6a 7d                	push   $0x7d
  jmp alltraps
8010738d:	e9 58 f5 ff ff       	jmp    801068ea <alltraps>

80107392 <vector126>:
.globl vector126
vector126:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $126
80107394:	6a 7e                	push   $0x7e
  jmp alltraps
80107396:	e9 4f f5 ff ff       	jmp    801068ea <alltraps>

8010739b <vector127>:
.globl vector127
vector127:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $127
8010739d:	6a 7f                	push   $0x7f
  jmp alltraps
8010739f:	e9 46 f5 ff ff       	jmp    801068ea <alltraps>

801073a4 <vector128>:
.globl vector128
vector128:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $128
801073a6:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073ab:	e9 3a f5 ff ff       	jmp    801068ea <alltraps>

801073b0 <vector129>:
.globl vector129
vector129:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $129
801073b2:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073b7:	e9 2e f5 ff ff       	jmp    801068ea <alltraps>

801073bc <vector130>:
.globl vector130
vector130:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $130
801073be:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073c3:	e9 22 f5 ff ff       	jmp    801068ea <alltraps>

801073c8 <vector131>:
.globl vector131
vector131:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $131
801073ca:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073cf:	e9 16 f5 ff ff       	jmp    801068ea <alltraps>

801073d4 <vector132>:
.globl vector132
vector132:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $132
801073d6:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073db:	e9 0a f5 ff ff       	jmp    801068ea <alltraps>

801073e0 <vector133>:
.globl vector133
vector133:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $133
801073e2:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801073e7:	e9 fe f4 ff ff       	jmp    801068ea <alltraps>

801073ec <vector134>:
.globl vector134
vector134:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $134
801073ee:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801073f3:	e9 f2 f4 ff ff       	jmp    801068ea <alltraps>

801073f8 <vector135>:
.globl vector135
vector135:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $135
801073fa:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801073ff:	e9 e6 f4 ff ff       	jmp    801068ea <alltraps>

80107404 <vector136>:
.globl vector136
vector136:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $136
80107406:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010740b:	e9 da f4 ff ff       	jmp    801068ea <alltraps>

80107410 <vector137>:
.globl vector137
vector137:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $137
80107412:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107417:	e9 ce f4 ff ff       	jmp    801068ea <alltraps>

8010741c <vector138>:
.globl vector138
vector138:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $138
8010741e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107423:	e9 c2 f4 ff ff       	jmp    801068ea <alltraps>

80107428 <vector139>:
.globl vector139
vector139:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $139
8010742a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010742f:	e9 b6 f4 ff ff       	jmp    801068ea <alltraps>

80107434 <vector140>:
.globl vector140
vector140:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $140
80107436:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010743b:	e9 aa f4 ff ff       	jmp    801068ea <alltraps>

80107440 <vector141>:
.globl vector141
vector141:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $141
80107442:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107447:	e9 9e f4 ff ff       	jmp    801068ea <alltraps>

8010744c <vector142>:
.globl vector142
vector142:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $142
8010744e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107453:	e9 92 f4 ff ff       	jmp    801068ea <alltraps>

80107458 <vector143>:
.globl vector143
vector143:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $143
8010745a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010745f:	e9 86 f4 ff ff       	jmp    801068ea <alltraps>

80107464 <vector144>:
.globl vector144
vector144:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $144
80107466:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010746b:	e9 7a f4 ff ff       	jmp    801068ea <alltraps>

80107470 <vector145>:
.globl vector145
vector145:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $145
80107472:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107477:	e9 6e f4 ff ff       	jmp    801068ea <alltraps>

8010747c <vector146>:
.globl vector146
vector146:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $146
8010747e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107483:	e9 62 f4 ff ff       	jmp    801068ea <alltraps>

80107488 <vector147>:
.globl vector147
vector147:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $147
8010748a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010748f:	e9 56 f4 ff ff       	jmp    801068ea <alltraps>

80107494 <vector148>:
.globl vector148
vector148:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $148
80107496:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010749b:	e9 4a f4 ff ff       	jmp    801068ea <alltraps>

801074a0 <vector149>:
.globl vector149
vector149:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $149
801074a2:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074a7:	e9 3e f4 ff ff       	jmp    801068ea <alltraps>

801074ac <vector150>:
.globl vector150
vector150:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $150
801074ae:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074b3:	e9 32 f4 ff ff       	jmp    801068ea <alltraps>

801074b8 <vector151>:
.globl vector151
vector151:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $151
801074ba:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074bf:	e9 26 f4 ff ff       	jmp    801068ea <alltraps>

801074c4 <vector152>:
.globl vector152
vector152:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $152
801074c6:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074cb:	e9 1a f4 ff ff       	jmp    801068ea <alltraps>

801074d0 <vector153>:
.globl vector153
vector153:
  pushl $0
801074d0:	6a 00                	push   $0x0
  pushl $153
801074d2:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074d7:	e9 0e f4 ff ff       	jmp    801068ea <alltraps>

801074dc <vector154>:
.globl vector154
vector154:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $154
801074de:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074e3:	e9 02 f4 ff ff       	jmp    801068ea <alltraps>

801074e8 <vector155>:
.globl vector155
vector155:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $155
801074ea:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801074ef:	e9 f6 f3 ff ff       	jmp    801068ea <alltraps>

801074f4 <vector156>:
.globl vector156
vector156:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $156
801074f6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801074fb:	e9 ea f3 ff ff       	jmp    801068ea <alltraps>

80107500 <vector157>:
.globl vector157
vector157:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $157
80107502:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107507:	e9 de f3 ff ff       	jmp    801068ea <alltraps>

8010750c <vector158>:
.globl vector158
vector158:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $158
8010750e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107513:	e9 d2 f3 ff ff       	jmp    801068ea <alltraps>

80107518 <vector159>:
.globl vector159
vector159:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $159
8010751a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010751f:	e9 c6 f3 ff ff       	jmp    801068ea <alltraps>

80107524 <vector160>:
.globl vector160
vector160:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $160
80107526:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010752b:	e9 ba f3 ff ff       	jmp    801068ea <alltraps>

80107530 <vector161>:
.globl vector161
vector161:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $161
80107532:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107537:	e9 ae f3 ff ff       	jmp    801068ea <alltraps>

8010753c <vector162>:
.globl vector162
vector162:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $162
8010753e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107543:	e9 a2 f3 ff ff       	jmp    801068ea <alltraps>

80107548 <vector163>:
.globl vector163
vector163:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $163
8010754a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010754f:	e9 96 f3 ff ff       	jmp    801068ea <alltraps>

80107554 <vector164>:
.globl vector164
vector164:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $164
80107556:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010755b:	e9 8a f3 ff ff       	jmp    801068ea <alltraps>

80107560 <vector165>:
.globl vector165
vector165:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $165
80107562:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107567:	e9 7e f3 ff ff       	jmp    801068ea <alltraps>

8010756c <vector166>:
.globl vector166
vector166:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $166
8010756e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107573:	e9 72 f3 ff ff       	jmp    801068ea <alltraps>

80107578 <vector167>:
.globl vector167
vector167:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $167
8010757a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010757f:	e9 66 f3 ff ff       	jmp    801068ea <alltraps>

80107584 <vector168>:
.globl vector168
vector168:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $168
80107586:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010758b:	e9 5a f3 ff ff       	jmp    801068ea <alltraps>

80107590 <vector169>:
.globl vector169
vector169:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $169
80107592:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107597:	e9 4e f3 ff ff       	jmp    801068ea <alltraps>

8010759c <vector170>:
.globl vector170
vector170:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $170
8010759e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075a3:	e9 42 f3 ff ff       	jmp    801068ea <alltraps>

801075a8 <vector171>:
.globl vector171
vector171:
  pushl $0
801075a8:	6a 00                	push   $0x0
  pushl $171
801075aa:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075af:	e9 36 f3 ff ff       	jmp    801068ea <alltraps>

801075b4 <vector172>:
.globl vector172
vector172:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $172
801075b6:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075bb:	e9 2a f3 ff ff       	jmp    801068ea <alltraps>

801075c0 <vector173>:
.globl vector173
vector173:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $173
801075c2:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075c7:	e9 1e f3 ff ff       	jmp    801068ea <alltraps>

801075cc <vector174>:
.globl vector174
vector174:
  pushl $0
801075cc:	6a 00                	push   $0x0
  pushl $174
801075ce:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075d3:	e9 12 f3 ff ff       	jmp    801068ea <alltraps>

801075d8 <vector175>:
.globl vector175
vector175:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $175
801075da:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075df:	e9 06 f3 ff ff       	jmp    801068ea <alltraps>

801075e4 <vector176>:
.globl vector176
vector176:
  pushl $0
801075e4:	6a 00                	push   $0x0
  pushl $176
801075e6:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801075eb:	e9 fa f2 ff ff       	jmp    801068ea <alltraps>

801075f0 <vector177>:
.globl vector177
vector177:
  pushl $0
801075f0:	6a 00                	push   $0x0
  pushl $177
801075f2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801075f7:	e9 ee f2 ff ff       	jmp    801068ea <alltraps>

801075fc <vector178>:
.globl vector178
vector178:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $178
801075fe:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107603:	e9 e2 f2 ff ff       	jmp    801068ea <alltraps>

80107608 <vector179>:
.globl vector179
vector179:
  pushl $0
80107608:	6a 00                	push   $0x0
  pushl $179
8010760a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010760f:	e9 d6 f2 ff ff       	jmp    801068ea <alltraps>

80107614 <vector180>:
.globl vector180
vector180:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $180
80107616:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010761b:	e9 ca f2 ff ff       	jmp    801068ea <alltraps>

80107620 <vector181>:
.globl vector181
vector181:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $181
80107622:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107627:	e9 be f2 ff ff       	jmp    801068ea <alltraps>

8010762c <vector182>:
.globl vector182
vector182:
  pushl $0
8010762c:	6a 00                	push   $0x0
  pushl $182
8010762e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107633:	e9 b2 f2 ff ff       	jmp    801068ea <alltraps>

80107638 <vector183>:
.globl vector183
vector183:
  pushl $0
80107638:	6a 00                	push   $0x0
  pushl $183
8010763a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010763f:	e9 a6 f2 ff ff       	jmp    801068ea <alltraps>

80107644 <vector184>:
.globl vector184
vector184:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $184
80107646:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010764b:	e9 9a f2 ff ff       	jmp    801068ea <alltraps>

80107650 <vector185>:
.globl vector185
vector185:
  pushl $0
80107650:	6a 00                	push   $0x0
  pushl $185
80107652:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107657:	e9 8e f2 ff ff       	jmp    801068ea <alltraps>

8010765c <vector186>:
.globl vector186
vector186:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $186
8010765e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107663:	e9 82 f2 ff ff       	jmp    801068ea <alltraps>

80107668 <vector187>:
.globl vector187
vector187:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $187
8010766a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010766f:	e9 76 f2 ff ff       	jmp    801068ea <alltraps>

80107674 <vector188>:
.globl vector188
vector188:
  pushl $0
80107674:	6a 00                	push   $0x0
  pushl $188
80107676:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010767b:	e9 6a f2 ff ff       	jmp    801068ea <alltraps>

80107680 <vector189>:
.globl vector189
vector189:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $189
80107682:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107687:	e9 5e f2 ff ff       	jmp    801068ea <alltraps>

8010768c <vector190>:
.globl vector190
vector190:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $190
8010768e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107693:	e9 52 f2 ff ff       	jmp    801068ea <alltraps>

80107698 <vector191>:
.globl vector191
vector191:
  pushl $0
80107698:	6a 00                	push   $0x0
  pushl $191
8010769a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010769f:	e9 46 f2 ff ff       	jmp    801068ea <alltraps>

801076a4 <vector192>:
.globl vector192
vector192:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $192
801076a6:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076ab:	e9 3a f2 ff ff       	jmp    801068ea <alltraps>

801076b0 <vector193>:
.globl vector193
vector193:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $193
801076b2:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076b7:	e9 2e f2 ff ff       	jmp    801068ea <alltraps>

801076bc <vector194>:
.globl vector194
vector194:
  pushl $0
801076bc:	6a 00                	push   $0x0
  pushl $194
801076be:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076c3:	e9 22 f2 ff ff       	jmp    801068ea <alltraps>

801076c8 <vector195>:
.globl vector195
vector195:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $195
801076ca:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076cf:	e9 16 f2 ff ff       	jmp    801068ea <alltraps>

801076d4 <vector196>:
.globl vector196
vector196:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $196
801076d6:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076db:	e9 0a f2 ff ff       	jmp    801068ea <alltraps>

801076e0 <vector197>:
.globl vector197
vector197:
  pushl $0
801076e0:	6a 00                	push   $0x0
  pushl $197
801076e2:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801076e7:	e9 fe f1 ff ff       	jmp    801068ea <alltraps>

801076ec <vector198>:
.globl vector198
vector198:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $198
801076ee:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801076f3:	e9 f2 f1 ff ff       	jmp    801068ea <alltraps>

801076f8 <vector199>:
.globl vector199
vector199:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $199
801076fa:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801076ff:	e9 e6 f1 ff ff       	jmp    801068ea <alltraps>

80107704 <vector200>:
.globl vector200
vector200:
  pushl $0
80107704:	6a 00                	push   $0x0
  pushl $200
80107706:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010770b:	e9 da f1 ff ff       	jmp    801068ea <alltraps>

80107710 <vector201>:
.globl vector201
vector201:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $201
80107712:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107717:	e9 ce f1 ff ff       	jmp    801068ea <alltraps>

8010771c <vector202>:
.globl vector202
vector202:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $202
8010771e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107723:	e9 c2 f1 ff ff       	jmp    801068ea <alltraps>

80107728 <vector203>:
.globl vector203
vector203:
  pushl $0
80107728:	6a 00                	push   $0x0
  pushl $203
8010772a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010772f:	e9 b6 f1 ff ff       	jmp    801068ea <alltraps>

80107734 <vector204>:
.globl vector204
vector204:
  pushl $0
80107734:	6a 00                	push   $0x0
  pushl $204
80107736:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010773b:	e9 aa f1 ff ff       	jmp    801068ea <alltraps>

80107740 <vector205>:
.globl vector205
vector205:
  pushl $0
80107740:	6a 00                	push   $0x0
  pushl $205
80107742:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107747:	e9 9e f1 ff ff       	jmp    801068ea <alltraps>

8010774c <vector206>:
.globl vector206
vector206:
  pushl $0
8010774c:	6a 00                	push   $0x0
  pushl $206
8010774e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107753:	e9 92 f1 ff ff       	jmp    801068ea <alltraps>

80107758 <vector207>:
.globl vector207
vector207:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $207
8010775a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010775f:	e9 86 f1 ff ff       	jmp    801068ea <alltraps>

80107764 <vector208>:
.globl vector208
vector208:
  pushl $0
80107764:	6a 00                	push   $0x0
  pushl $208
80107766:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010776b:	e9 7a f1 ff ff       	jmp    801068ea <alltraps>

80107770 <vector209>:
.globl vector209
vector209:
  pushl $0
80107770:	6a 00                	push   $0x0
  pushl $209
80107772:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107777:	e9 6e f1 ff ff       	jmp    801068ea <alltraps>

8010777c <vector210>:
.globl vector210
vector210:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $210
8010777e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107783:	e9 62 f1 ff ff       	jmp    801068ea <alltraps>

80107788 <vector211>:
.globl vector211
vector211:
  pushl $0
80107788:	6a 00                	push   $0x0
  pushl $211
8010778a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010778f:	e9 56 f1 ff ff       	jmp    801068ea <alltraps>

80107794 <vector212>:
.globl vector212
vector212:
  pushl $0
80107794:	6a 00                	push   $0x0
  pushl $212
80107796:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010779b:	e9 4a f1 ff ff       	jmp    801068ea <alltraps>

801077a0 <vector213>:
.globl vector213
vector213:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $213
801077a2:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077a7:	e9 3e f1 ff ff       	jmp    801068ea <alltraps>

801077ac <vector214>:
.globl vector214
vector214:
  pushl $0
801077ac:	6a 00                	push   $0x0
  pushl $214
801077ae:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077b3:	e9 32 f1 ff ff       	jmp    801068ea <alltraps>

801077b8 <vector215>:
.globl vector215
vector215:
  pushl $0
801077b8:	6a 00                	push   $0x0
  pushl $215
801077ba:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077bf:	e9 26 f1 ff ff       	jmp    801068ea <alltraps>

801077c4 <vector216>:
.globl vector216
vector216:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $216
801077c6:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077cb:	e9 1a f1 ff ff       	jmp    801068ea <alltraps>

801077d0 <vector217>:
.globl vector217
vector217:
  pushl $0
801077d0:	6a 00                	push   $0x0
  pushl $217
801077d2:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077d7:	e9 0e f1 ff ff       	jmp    801068ea <alltraps>

801077dc <vector218>:
.globl vector218
vector218:
  pushl $0
801077dc:	6a 00                	push   $0x0
  pushl $218
801077de:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077e3:	e9 02 f1 ff ff       	jmp    801068ea <alltraps>

801077e8 <vector219>:
.globl vector219
vector219:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $219
801077ea:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801077ef:	e9 f6 f0 ff ff       	jmp    801068ea <alltraps>

801077f4 <vector220>:
.globl vector220
vector220:
  pushl $0
801077f4:	6a 00                	push   $0x0
  pushl $220
801077f6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801077fb:	e9 ea f0 ff ff       	jmp    801068ea <alltraps>

80107800 <vector221>:
.globl vector221
vector221:
  pushl $0
80107800:	6a 00                	push   $0x0
  pushl $221
80107802:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107807:	e9 de f0 ff ff       	jmp    801068ea <alltraps>

8010780c <vector222>:
.globl vector222
vector222:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $222
8010780e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107813:	e9 d2 f0 ff ff       	jmp    801068ea <alltraps>

80107818 <vector223>:
.globl vector223
vector223:
  pushl $0
80107818:	6a 00                	push   $0x0
  pushl $223
8010781a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010781f:	e9 c6 f0 ff ff       	jmp    801068ea <alltraps>

80107824 <vector224>:
.globl vector224
vector224:
  pushl $0
80107824:	6a 00                	push   $0x0
  pushl $224
80107826:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010782b:	e9 ba f0 ff ff       	jmp    801068ea <alltraps>

80107830 <vector225>:
.globl vector225
vector225:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $225
80107832:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107837:	e9 ae f0 ff ff       	jmp    801068ea <alltraps>

8010783c <vector226>:
.globl vector226
vector226:
  pushl $0
8010783c:	6a 00                	push   $0x0
  pushl $226
8010783e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107843:	e9 a2 f0 ff ff       	jmp    801068ea <alltraps>

80107848 <vector227>:
.globl vector227
vector227:
  pushl $0
80107848:	6a 00                	push   $0x0
  pushl $227
8010784a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010784f:	e9 96 f0 ff ff       	jmp    801068ea <alltraps>

80107854 <vector228>:
.globl vector228
vector228:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $228
80107856:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010785b:	e9 8a f0 ff ff       	jmp    801068ea <alltraps>

80107860 <vector229>:
.globl vector229
vector229:
  pushl $0
80107860:	6a 00                	push   $0x0
  pushl $229
80107862:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107867:	e9 7e f0 ff ff       	jmp    801068ea <alltraps>

8010786c <vector230>:
.globl vector230
vector230:
  pushl $0
8010786c:	6a 00                	push   $0x0
  pushl $230
8010786e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107873:	e9 72 f0 ff ff       	jmp    801068ea <alltraps>

80107878 <vector231>:
.globl vector231
vector231:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $231
8010787a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010787f:	e9 66 f0 ff ff       	jmp    801068ea <alltraps>

80107884 <vector232>:
.globl vector232
vector232:
  pushl $0
80107884:	6a 00                	push   $0x0
  pushl $232
80107886:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010788b:	e9 5a f0 ff ff       	jmp    801068ea <alltraps>

80107890 <vector233>:
.globl vector233
vector233:
  pushl $0
80107890:	6a 00                	push   $0x0
  pushl $233
80107892:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107897:	e9 4e f0 ff ff       	jmp    801068ea <alltraps>

8010789c <vector234>:
.globl vector234
vector234:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $234
8010789e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078a3:	e9 42 f0 ff ff       	jmp    801068ea <alltraps>

801078a8 <vector235>:
.globl vector235
vector235:
  pushl $0
801078a8:	6a 00                	push   $0x0
  pushl $235
801078aa:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078af:	e9 36 f0 ff ff       	jmp    801068ea <alltraps>

801078b4 <vector236>:
.globl vector236
vector236:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $236
801078b6:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078bb:	e9 2a f0 ff ff       	jmp    801068ea <alltraps>

801078c0 <vector237>:
.globl vector237
vector237:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $237
801078c2:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078c7:	e9 1e f0 ff ff       	jmp    801068ea <alltraps>

801078cc <vector238>:
.globl vector238
vector238:
  pushl $0
801078cc:	6a 00                	push   $0x0
  pushl $238
801078ce:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078d3:	e9 12 f0 ff ff       	jmp    801068ea <alltraps>

801078d8 <vector239>:
.globl vector239
vector239:
  pushl $0
801078d8:	6a 00                	push   $0x0
  pushl $239
801078da:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078df:	e9 06 f0 ff ff       	jmp    801068ea <alltraps>

801078e4 <vector240>:
.globl vector240
vector240:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $240
801078e6:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801078eb:	e9 fa ef ff ff       	jmp    801068ea <alltraps>

801078f0 <vector241>:
.globl vector241
vector241:
  pushl $0
801078f0:	6a 00                	push   $0x0
  pushl $241
801078f2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801078f7:	e9 ee ef ff ff       	jmp    801068ea <alltraps>

801078fc <vector242>:
.globl vector242
vector242:
  pushl $0
801078fc:	6a 00                	push   $0x0
  pushl $242
801078fe:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107903:	e9 e2 ef ff ff       	jmp    801068ea <alltraps>

80107908 <vector243>:
.globl vector243
vector243:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $243
8010790a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010790f:	e9 d6 ef ff ff       	jmp    801068ea <alltraps>

80107914 <vector244>:
.globl vector244
vector244:
  pushl $0
80107914:	6a 00                	push   $0x0
  pushl $244
80107916:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010791b:	e9 ca ef ff ff       	jmp    801068ea <alltraps>

80107920 <vector245>:
.globl vector245
vector245:
  pushl $0
80107920:	6a 00                	push   $0x0
  pushl $245
80107922:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107927:	e9 be ef ff ff       	jmp    801068ea <alltraps>

8010792c <vector246>:
.globl vector246
vector246:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $246
8010792e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107933:	e9 b2 ef ff ff       	jmp    801068ea <alltraps>

80107938 <vector247>:
.globl vector247
vector247:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $247
8010793a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010793f:	e9 a6 ef ff ff       	jmp    801068ea <alltraps>

80107944 <vector248>:
.globl vector248
vector248:
  pushl $0
80107944:	6a 00                	push   $0x0
  pushl $248
80107946:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010794b:	e9 9a ef ff ff       	jmp    801068ea <alltraps>

80107950 <vector249>:
.globl vector249
vector249:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $249
80107952:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107957:	e9 8e ef ff ff       	jmp    801068ea <alltraps>

8010795c <vector250>:
.globl vector250
vector250:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $250
8010795e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107963:	e9 82 ef ff ff       	jmp    801068ea <alltraps>

80107968 <vector251>:
.globl vector251
vector251:
  pushl $0
80107968:	6a 00                	push   $0x0
  pushl $251
8010796a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010796f:	e9 76 ef ff ff       	jmp    801068ea <alltraps>

80107974 <vector252>:
.globl vector252
vector252:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $252
80107976:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010797b:	e9 6a ef ff ff       	jmp    801068ea <alltraps>

80107980 <vector253>:
.globl vector253
vector253:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $253
80107982:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107987:	e9 5e ef ff ff       	jmp    801068ea <alltraps>

8010798c <vector254>:
.globl vector254
vector254:
  pushl $0
8010798c:	6a 00                	push   $0x0
  pushl $254
8010798e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107993:	e9 52 ef ff ff       	jmp    801068ea <alltraps>

80107998 <vector255>:
.globl vector255
vector255:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $255
8010799a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010799f:	e9 46 ef ff ff       	jmp    801068ea <alltraps>

801079a4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079a4:	55                   	push   %ebp
801079a5:	89 e5                	mov    %esp,%ebp
801079a7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801079ad:	83 e8 01             	sub    $0x1,%eax
801079b0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079b4:	8b 45 08             	mov    0x8(%ebp),%eax
801079b7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079bb:	8b 45 08             	mov    0x8(%ebp),%eax
801079be:	c1 e8 10             	shr    $0x10,%eax
801079c1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079c5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079c8:	0f 01 10             	lgdtl  (%eax)
}
801079cb:	c9                   	leave  
801079cc:	c3                   	ret    

801079cd <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801079cd:	55                   	push   %ebp
801079ce:	89 e5                	mov    %esp,%ebp
801079d0:	83 ec 04             	sub    $0x4,%esp
801079d3:	8b 45 08             	mov    0x8(%ebp),%eax
801079d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079da:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079de:	0f 00 d8             	ltr    %ax
}
801079e1:	c9                   	leave  
801079e2:	c3                   	ret    

801079e3 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801079e3:	55                   	push   %ebp
801079e4:	89 e5                	mov    %esp,%ebp
801079e6:	83 ec 04             	sub    $0x4,%esp
801079e9:	8b 45 08             	mov    0x8(%ebp),%eax
801079ec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801079f0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079f4:	8e e8                	mov    %eax,%gs
}
801079f6:	c9                   	leave  
801079f7:	c3                   	ret    

801079f8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801079f8:	55                   	push   %ebp
801079f9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801079fb:	8b 45 08             	mov    0x8(%ebp),%eax
801079fe:	0f 22 d8             	mov    %eax,%cr3
}
80107a01:	5d                   	pop    %ebp
80107a02:	c3                   	ret    

80107a03 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a03:	55                   	push   %ebp
80107a04:	89 e5                	mov    %esp,%ebp
80107a06:	8b 45 08             	mov    0x8(%ebp),%eax
80107a09:	05 00 00 00 80       	add    $0x80000000,%eax
80107a0e:	5d                   	pop    %ebp
80107a0f:	c3                   	ret    

80107a10 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a10:	55                   	push   %ebp
80107a11:	89 e5                	mov    %esp,%ebp
80107a13:	8b 45 08             	mov    0x8(%ebp),%eax
80107a16:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1b:	5d                   	pop    %ebp
80107a1c:	c3                   	ret    

80107a1d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a1d:	55                   	push   %ebp
80107a1e:	89 e5                	mov    %esp,%ebp
80107a20:	53                   	push   %ebx
80107a21:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a24:	e8 eb b5 ff ff       	call   80103014 <cpunum>
80107a29:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a2f:	05 c0 24 11 80       	add    $0x801124c0,%eax
80107a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a43:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a53:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a57:	83 e2 f0             	and    $0xfffffff0,%edx
80107a5a:	83 ca 0a             	or     $0xa,%edx
80107a5d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a67:	83 ca 10             	or     $0x10,%edx
80107a6a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a74:	83 e2 9f             	and    $0xffffff9f,%edx
80107a77:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a81:	83 ca 80             	or     $0xffffff80,%edx
80107a84:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a8e:	83 ca 0f             	or     $0xf,%edx
80107a91:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a97:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a9b:	83 e2 ef             	and    $0xffffffef,%edx
80107a9e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aa8:	83 e2 df             	and    $0xffffffdf,%edx
80107aab:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab5:	83 ca 40             	or     $0x40,%edx
80107ab8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac2:	83 ca 80             	or     $0xffffff80,%edx
80107ac5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ad9:	ff ff 
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ae5:	00 00 
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107afb:	83 e2 f0             	and    $0xfffffff0,%edx
80107afe:	83 ca 02             	or     $0x2,%edx
80107b01:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b11:	83 ca 10             	or     $0x10,%edx
80107b14:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b24:	83 e2 9f             	and    $0xffffff9f,%edx
80107b27:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b30:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b37:	83 ca 80             	or     $0xffffff80,%edx
80107b3a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b4a:	83 ca 0f             	or     $0xf,%edx
80107b4d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b5d:	83 e2 ef             	and    $0xffffffef,%edx
80107b60:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b70:	83 e2 df             	and    $0xffffffdf,%edx
80107b73:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b83:	83 ca 40             	or     $0x40,%edx
80107b86:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b96:	83 ca 80             	or     $0xffffff80,%edx
80107b99:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bac:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bb3:	ff ff 
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bbf:	00 00 
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bd5:	83 e2 f0             	and    $0xfffffff0,%edx
80107bd8:	83 ca 0a             	or     $0xa,%edx
80107bdb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107beb:	83 ca 10             	or     $0x10,%edx
80107bee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bfe:	83 ca 60             	or     $0x60,%edx
80107c01:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c11:	83 ca 80             	or     $0xffffff80,%edx
80107c14:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c24:	83 ca 0f             	or     $0xf,%edx
80107c27:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c37:	83 e2 ef             	and    $0xffffffef,%edx
80107c3a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c43:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c4a:	83 e2 df             	and    $0xffffffdf,%edx
80107c4d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c5d:	83 ca 40             	or     $0x40,%edx
80107c60:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c69:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c70:	83 ca 80             	or     $0xffffff80,%edx
80107c73:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c86:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c8d:	ff ff 
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107c99:	00 00 
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107caf:	83 e2 f0             	and    $0xfffffff0,%edx
80107cb2:	83 ca 02             	or     $0x2,%edx
80107cb5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cc5:	83 ca 10             	or     $0x10,%edx
80107cc8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cd8:	83 ca 60             	or     $0x60,%edx
80107cdb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ceb:	83 ca 80             	or     $0xffffff80,%edx
80107cee:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cfe:	83 ca 0f             	or     $0xf,%edx
80107d01:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d11:	83 e2 ef             	and    $0xffffffef,%edx
80107d14:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d24:	83 e2 df             	and    $0xffffffdf,%edx
80107d27:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d37:	83 ca 40             	or     $0x40,%edx
80107d3a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d43:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d4a:	83 ca 80             	or     $0xffffff80,%edx
80107d4d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d56:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d60:	05 b4 00 00 00       	add    $0xb4,%eax
80107d65:	89 c3                	mov    %eax,%ebx
80107d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6a:	05 b4 00 00 00       	add    $0xb4,%eax
80107d6f:	c1 e8 10             	shr    $0x10,%eax
80107d72:	89 c2                	mov    %eax,%edx
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d77:	05 b4 00 00 00       	add    $0xb4,%eax
80107d7c:	c1 e8 18             	shr    $0x18,%eax
80107d7f:	89 c1                	mov    %eax,%ecx
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d8b:	00 00 
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9a:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107daa:	83 e2 f0             	and    $0xfffffff0,%edx
80107dad:	83 ca 02             	or     $0x2,%edx
80107db0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dc0:	83 ca 10             	or     $0x10,%edx
80107dc3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dd3:	83 e2 9f             	and    $0xffffff9f,%edx
80107dd6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107de6:	83 ca 80             	or     $0xffffff80,%edx
80107de9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107df9:	83 e2 f0             	and    $0xfffffff0,%edx
80107dfc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e0c:	83 e2 ef             	and    $0xffffffef,%edx
80107e0f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e18:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e1f:	83 e2 df             	and    $0xffffffdf,%edx
80107e22:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e32:	83 ca 40             	or     $0x40,%edx
80107e35:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e45:	83 ca 80             	or     $0xffffff80,%edx
80107e48:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	83 c0 70             	add    $0x70,%eax
80107e5d:	83 ec 08             	sub    $0x8,%esp
80107e60:	6a 38                	push   $0x38
80107e62:	50                   	push   %eax
80107e63:	e8 3c fb ff ff       	call   801079a4 <lgdt>
80107e68:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107e6b:	83 ec 0c             	sub    $0xc,%esp
80107e6e:	6a 18                	push   $0x18
80107e70:	e8 6e fb ff ff       	call   801079e3 <loadgs>
80107e75:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7b:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e81:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e88:	00 00 00 00 
}
80107e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e8f:	c9                   	leave  
80107e90:	c3                   	ret    

80107e91 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e91:	55                   	push   %ebp
80107e92:	89 e5                	mov    %esp,%ebp
80107e94:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e9a:	c1 e8 16             	shr    $0x16,%eax
80107e9d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea7:	01 d0                	add    %edx,%eax
80107ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eaf:	8b 00                	mov    (%eax),%eax
80107eb1:	83 e0 01             	and    $0x1,%eax
80107eb4:	85 c0                	test   %eax,%eax
80107eb6:	74 18                	je     80107ed0 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebb:	8b 00                	mov    (%eax),%eax
80107ebd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ec2:	50                   	push   %eax
80107ec3:	e8 48 fb ff ff       	call   80107a10 <p2v>
80107ec8:	83 c4 04             	add    $0x4,%esp
80107ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ece:	eb 48                	jmp    80107f18 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ed0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ed4:	74 0e                	je     80107ee4 <walkpgdir+0x53>
80107ed6:	e8 d8 ad ff ff       	call   80102cb3 <kalloc>
80107edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ede:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ee2:	75 07                	jne    80107eeb <walkpgdir+0x5a>
      return 0;
80107ee4:	b8 00 00 00 00       	mov    $0x0,%eax
80107ee9:	eb 44                	jmp    80107f2f <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107eeb:	83 ec 04             	sub    $0x4,%esp
80107eee:	68 00 10 00 00       	push   $0x1000
80107ef3:	6a 00                	push   $0x0
80107ef5:	ff 75 f4             	pushl  -0xc(%ebp)
80107ef8:	e8 c5 d5 ff ff       	call   801054c2 <memset>
80107efd:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f00:	83 ec 0c             	sub    $0xc,%esp
80107f03:	ff 75 f4             	pushl  -0xc(%ebp)
80107f06:	e8 f8 fa ff ff       	call   80107a03 <v2p>
80107f0b:	83 c4 10             	add    $0x10,%esp
80107f0e:	83 c8 07             	or     $0x7,%eax
80107f11:	89 c2                	mov    %eax,%edx
80107f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f16:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f1b:	c1 e8 0c             	shr    $0xc,%eax
80107f1e:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2d:	01 d0                	add    %edx,%eax
}
80107f2f:	c9                   	leave  
80107f30:	c3                   	ret    

80107f31 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f31:	55                   	push   %ebp
80107f32:	89 e5                	mov    %esp,%ebp
80107f34:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f42:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f45:	8b 45 10             	mov    0x10(%ebp),%eax
80107f48:	01 d0                	add    %edx,%eax
80107f4a:	83 e8 01             	sub    $0x1,%eax
80107f4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f55:	83 ec 04             	sub    $0x4,%esp
80107f58:	6a 01                	push   $0x1
80107f5a:	ff 75 f4             	pushl  -0xc(%ebp)
80107f5d:	ff 75 08             	pushl  0x8(%ebp)
80107f60:	e8 2c ff ff ff       	call   80107e91 <walkpgdir>
80107f65:	83 c4 10             	add    $0x10,%esp
80107f68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f6f:	75 07                	jne    80107f78 <mappages+0x47>
      return -1;
80107f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f76:	eb 49                	jmp    80107fc1 <mappages+0x90>
    if(*pte & PTE_P)
80107f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f7b:	8b 00                	mov    (%eax),%eax
80107f7d:	83 e0 01             	and    $0x1,%eax
80107f80:	85 c0                	test   %eax,%eax
80107f82:	74 0d                	je     80107f91 <mappages+0x60>
      panic("remap");
80107f84:	83 ec 0c             	sub    $0xc,%esp
80107f87:	68 94 8d 10 80       	push   $0x80108d94
80107f8c:	e8 cb 85 ff ff       	call   8010055c <panic>
    *pte = pa | perm | PTE_P;
80107f91:	8b 45 18             	mov    0x18(%ebp),%eax
80107f94:	0b 45 14             	or     0x14(%ebp),%eax
80107f97:	83 c8 01             	or     $0x1,%eax
80107f9a:	89 c2                	mov    %eax,%edx
80107f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f9f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fa7:	75 08                	jne    80107fb1 <mappages+0x80>
      break;
80107fa9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107faa:	b8 00 00 00 00       	mov    $0x0,%eax
80107faf:	eb 10                	jmp    80107fc1 <mappages+0x90>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107fb1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fb8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107fbf:	eb 94                	jmp    80107f55 <mappages+0x24>
  return 0;
}
80107fc1:	c9                   	leave  
80107fc2:	c3                   	ret    

80107fc3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107fc3:	55                   	push   %ebp
80107fc4:	89 e5                	mov    %esp,%ebp
80107fc6:	53                   	push   %ebx
80107fc7:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107fca:	e8 e4 ac ff ff       	call   80102cb3 <kalloc>
80107fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fd6:	75 0a                	jne    80107fe2 <setupkvm+0x1f>
    return 0;
80107fd8:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdd:	e9 8e 00 00 00       	jmp    80108070 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107fe2:	83 ec 04             	sub    $0x4,%esp
80107fe5:	68 00 10 00 00       	push   $0x1000
80107fea:	6a 00                	push   $0x0
80107fec:	ff 75 f0             	pushl  -0x10(%ebp)
80107fef:	e8 ce d4 ff ff       	call   801054c2 <memset>
80107ff4:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ff7:	83 ec 0c             	sub    $0xc,%esp
80107ffa:	68 00 00 00 0e       	push   $0xe000000
80107fff:	e8 0c fa ff ff       	call   80107a10 <p2v>
80108004:	83 c4 10             	add    $0x10,%esp
80108007:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010800c:	76 0d                	jbe    8010801b <setupkvm+0x58>
    panic("PHYSTOP too high");
8010800e:	83 ec 0c             	sub    $0xc,%esp
80108011:	68 9a 8d 10 80       	push   $0x80108d9a
80108016:	e8 41 85 ff ff       	call   8010055c <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010801b:	c7 45 f4 00 b5 10 80 	movl   $0x8010b500,-0xc(%ebp)
80108022:	eb 40                	jmp    80108064 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108027:	8b 48 0c             	mov    0xc(%eax),%ecx
8010802a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802d:	8b 50 04             	mov    0x4(%eax),%edx
80108030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108033:	8b 58 08             	mov    0x8(%eax),%ebx
80108036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108039:	8b 40 04             	mov    0x4(%eax),%eax
8010803c:	29 c3                	sub    %eax,%ebx
8010803e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108041:	8b 00                	mov    (%eax),%eax
80108043:	83 ec 0c             	sub    $0xc,%esp
80108046:	51                   	push   %ecx
80108047:	52                   	push   %edx
80108048:	53                   	push   %ebx
80108049:	50                   	push   %eax
8010804a:	ff 75 f0             	pushl  -0x10(%ebp)
8010804d:	e8 df fe ff ff       	call   80107f31 <mappages>
80108052:	83 c4 20             	add    $0x20,%esp
80108055:	85 c0                	test   %eax,%eax
80108057:	79 07                	jns    80108060 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108059:	b8 00 00 00 00       	mov    $0x0,%eax
8010805e:	eb 10                	jmp    80108070 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108060:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108064:	81 7d f4 40 b5 10 80 	cmpl   $0x8010b540,-0xc(%ebp)
8010806b:	72 b7                	jb     80108024 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010806d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108073:	c9                   	leave  
80108074:	c3                   	ret    

80108075 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108075:	55                   	push   %ebp
80108076:	89 e5                	mov    %esp,%ebp
80108078:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010807b:	e8 43 ff ff ff       	call   80107fc3 <setupkvm>
80108080:	a3 d8 56 11 80       	mov    %eax,0x801156d8
  switchkvm();
80108085:	e8 02 00 00 00       	call   8010808c <switchkvm>
}
8010808a:	c9                   	leave  
8010808b:	c3                   	ret    

8010808c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010808c:	55                   	push   %ebp
8010808d:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010808f:	a1 d8 56 11 80       	mov    0x801156d8,%eax
80108094:	50                   	push   %eax
80108095:	e8 69 f9 ff ff       	call   80107a03 <v2p>
8010809a:	83 c4 04             	add    $0x4,%esp
8010809d:	50                   	push   %eax
8010809e:	e8 55 f9 ff ff       	call   801079f8 <lcr3>
801080a3:	83 c4 04             	add    $0x4,%esp
}
801080a6:	c9                   	leave  
801080a7:	c3                   	ret    

801080a8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080a8:	55                   	push   %ebp
801080a9:	89 e5                	mov    %esp,%ebp
801080ab:	56                   	push   %esi
801080ac:	53                   	push   %ebx
  pushcli();
801080ad:	e8 0e d3 ff ff       	call   801053c0 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080b8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080bf:	83 c2 08             	add    $0x8,%edx
801080c2:	89 d6                	mov    %edx,%esi
801080c4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080cb:	83 c2 08             	add    $0x8,%edx
801080ce:	c1 ea 10             	shr    $0x10,%edx
801080d1:	89 d3                	mov    %edx,%ebx
801080d3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080da:	83 c2 08             	add    $0x8,%edx
801080dd:	c1 ea 18             	shr    $0x18,%edx
801080e0:	89 d1                	mov    %edx,%ecx
801080e2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801080e9:	67 00 
801080eb:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801080f2:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801080f8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080ff:	83 e2 f0             	and    $0xfffffff0,%edx
80108102:	83 ca 09             	or     $0x9,%edx
80108105:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010810b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108112:	83 ca 10             	or     $0x10,%edx
80108115:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010811b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108122:	83 e2 9f             	and    $0xffffff9f,%edx
80108125:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010812b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108132:	83 ca 80             	or     $0xffffff80,%edx
80108135:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010813b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108142:	83 e2 f0             	and    $0xfffffff0,%edx
80108145:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010814b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108152:	83 e2 ef             	and    $0xffffffef,%edx
80108155:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010815b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108162:	83 e2 df             	and    $0xffffffdf,%edx
80108165:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010816b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108172:	83 ca 40             	or     $0x40,%edx
80108175:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010817b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108182:	83 e2 7f             	and    $0x7f,%edx
80108185:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010818b:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108191:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108197:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010819e:	83 e2 ef             	and    $0xffffffef,%edx
801081a1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081ad:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081b3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081b9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081c0:	8b 52 08             	mov    0x8(%edx),%edx
801081c3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801081c9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801081cc:	83 ec 0c             	sub    $0xc,%esp
801081cf:	6a 30                	push   $0x30
801081d1:	e8 f7 f7 ff ff       	call   801079cd <ltr>
801081d6:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
801081d9:	8b 45 08             	mov    0x8(%ebp),%eax
801081dc:	8b 40 04             	mov    0x4(%eax),%eax
801081df:	85 c0                	test   %eax,%eax
801081e1:	75 0d                	jne    801081f0 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
801081e3:	83 ec 0c             	sub    $0xc,%esp
801081e6:	68 ab 8d 10 80       	push   $0x80108dab
801081eb:	e8 6c 83 ff ff       	call   8010055c <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801081f0:	8b 45 08             	mov    0x8(%ebp),%eax
801081f3:	8b 40 04             	mov    0x4(%eax),%eax
801081f6:	83 ec 0c             	sub    $0xc,%esp
801081f9:	50                   	push   %eax
801081fa:	e8 04 f8 ff ff       	call   80107a03 <v2p>
801081ff:	83 c4 10             	add    $0x10,%esp
80108202:	83 ec 0c             	sub    $0xc,%esp
80108205:	50                   	push   %eax
80108206:	e8 ed f7 ff ff       	call   801079f8 <lcr3>
8010820b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010820e:	e8 f1 d1 ff ff       	call   80105404 <popcli>
}
80108213:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108216:	5b                   	pop    %ebx
80108217:	5e                   	pop    %esi
80108218:	5d                   	pop    %ebp
80108219:	c3                   	ret    

8010821a <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010821a:	55                   	push   %ebp
8010821b:	89 e5                	mov    %esp,%ebp
8010821d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108220:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108227:	76 0d                	jbe    80108236 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108229:	83 ec 0c             	sub    $0xc,%esp
8010822c:	68 bf 8d 10 80       	push   $0x80108dbf
80108231:	e8 26 83 ff ff       	call   8010055c <panic>
  mem = kalloc();
80108236:	e8 78 aa ff ff       	call   80102cb3 <kalloc>
8010823b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010823e:	83 ec 04             	sub    $0x4,%esp
80108241:	68 00 10 00 00       	push   $0x1000
80108246:	6a 00                	push   $0x0
80108248:	ff 75 f4             	pushl  -0xc(%ebp)
8010824b:	e8 72 d2 ff ff       	call   801054c2 <memset>
80108250:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108253:	83 ec 0c             	sub    $0xc,%esp
80108256:	ff 75 f4             	pushl  -0xc(%ebp)
80108259:	e8 a5 f7 ff ff       	call   80107a03 <v2p>
8010825e:	83 c4 10             	add    $0x10,%esp
80108261:	83 ec 0c             	sub    $0xc,%esp
80108264:	6a 06                	push   $0x6
80108266:	50                   	push   %eax
80108267:	68 00 10 00 00       	push   $0x1000
8010826c:	6a 00                	push   $0x0
8010826e:	ff 75 08             	pushl  0x8(%ebp)
80108271:	e8 bb fc ff ff       	call   80107f31 <mappages>
80108276:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108279:	83 ec 04             	sub    $0x4,%esp
8010827c:	ff 75 10             	pushl  0x10(%ebp)
8010827f:	ff 75 0c             	pushl  0xc(%ebp)
80108282:	ff 75 f4             	pushl  -0xc(%ebp)
80108285:	e8 f7 d2 ff ff       	call   80105581 <memmove>
8010828a:	83 c4 10             	add    $0x10,%esp
}
8010828d:	c9                   	leave  
8010828e:	c3                   	ret    

8010828f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010828f:	55                   	push   %ebp
80108290:	89 e5                	mov    %esp,%ebp
80108292:	53                   	push   %ebx
80108293:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108296:	8b 45 0c             	mov    0xc(%ebp),%eax
80108299:	25 ff 0f 00 00       	and    $0xfff,%eax
8010829e:	85 c0                	test   %eax,%eax
801082a0:	74 0d                	je     801082af <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801082a2:	83 ec 0c             	sub    $0xc,%esp
801082a5:	68 dc 8d 10 80       	push   $0x80108ddc
801082aa:	e8 ad 82 ff ff       	call   8010055c <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082b6:	e9 95 00 00 00       	jmp    80108350 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801082be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c1:	01 d0                	add    %edx,%eax
801082c3:	83 ec 04             	sub    $0x4,%esp
801082c6:	6a 00                	push   $0x0
801082c8:	50                   	push   %eax
801082c9:	ff 75 08             	pushl  0x8(%ebp)
801082cc:	e8 c0 fb ff ff       	call   80107e91 <walkpgdir>
801082d1:	83 c4 10             	add    $0x10,%esp
801082d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082db:	75 0d                	jne    801082ea <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801082dd:	83 ec 0c             	sub    $0xc,%esp
801082e0:	68 ff 8d 10 80       	push   $0x80108dff
801082e5:	e8 72 82 ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
801082ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ed:	8b 00                	mov    (%eax),%eax
801082ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801082f7:	8b 45 18             	mov    0x18(%ebp),%eax
801082fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801082fd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108302:	77 0b                	ja     8010830f <loaduvm+0x80>
      n = sz - i;
80108304:	8b 45 18             	mov    0x18(%ebp),%eax
80108307:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010830a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010830d:	eb 07                	jmp    80108316 <loaduvm+0x87>
    else
      n = PGSIZE;
8010830f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108316:	8b 55 14             	mov    0x14(%ebp),%edx
80108319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010831f:	83 ec 0c             	sub    $0xc,%esp
80108322:	ff 75 e8             	pushl  -0x18(%ebp)
80108325:	e8 e6 f6 ff ff       	call   80107a10 <p2v>
8010832a:	83 c4 10             	add    $0x10,%esp
8010832d:	ff 75 f0             	pushl  -0x10(%ebp)
80108330:	53                   	push   %ebx
80108331:	50                   	push   %eax
80108332:	ff 75 10             	pushl  0x10(%ebp)
80108335:	e8 0f 9b ff ff       	call   80101e49 <readi>
8010833a:	83 c4 10             	add    $0x10,%esp
8010833d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108340:	74 07                	je     80108349 <loaduvm+0xba>
      return -1;
80108342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108347:	eb 18                	jmp    80108361 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108349:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108353:	3b 45 18             	cmp    0x18(%ebp),%eax
80108356:	0f 82 5f ff ff ff    	jb     801082bb <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010835c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108364:	c9                   	leave  
80108365:	c3                   	ret    

80108366 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108366:	55                   	push   %ebp
80108367:	89 e5                	mov    %esp,%ebp
80108369:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010836c:	8b 45 10             	mov    0x10(%ebp),%eax
8010836f:	85 c0                	test   %eax,%eax
80108371:	79 0a                	jns    8010837d <allocuvm+0x17>
    return 0;
80108373:	b8 00 00 00 00       	mov    $0x0,%eax
80108378:	e9 b0 00 00 00       	jmp    8010842d <allocuvm+0xc7>
  if(newsz < oldsz)
8010837d:	8b 45 10             	mov    0x10(%ebp),%eax
80108380:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108383:	73 08                	jae    8010838d <allocuvm+0x27>
    return oldsz;
80108385:	8b 45 0c             	mov    0xc(%ebp),%eax
80108388:	e9 a0 00 00 00       	jmp    8010842d <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010838d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108390:	05 ff 0f 00 00       	add    $0xfff,%eax
80108395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010839a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010839d:	eb 7f                	jmp    8010841e <allocuvm+0xb8>
    mem = kalloc();
8010839f:	e8 0f a9 ff ff       	call   80102cb3 <kalloc>
801083a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083ab:	75 2b                	jne    801083d8 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801083ad:	83 ec 0c             	sub    $0xc,%esp
801083b0:	68 1d 8e 10 80       	push   $0x80108e1d
801083b5:	e8 05 80 ff ff       	call   801003bf <cprintf>
801083ba:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801083bd:	83 ec 04             	sub    $0x4,%esp
801083c0:	ff 75 0c             	pushl  0xc(%ebp)
801083c3:	ff 75 10             	pushl  0x10(%ebp)
801083c6:	ff 75 08             	pushl  0x8(%ebp)
801083c9:	e8 61 00 00 00       	call   8010842f <deallocuvm>
801083ce:	83 c4 10             	add    $0x10,%esp
      return 0;
801083d1:	b8 00 00 00 00       	mov    $0x0,%eax
801083d6:	eb 55                	jmp    8010842d <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801083d8:	83 ec 04             	sub    $0x4,%esp
801083db:	68 00 10 00 00       	push   $0x1000
801083e0:	6a 00                	push   $0x0
801083e2:	ff 75 f0             	pushl  -0x10(%ebp)
801083e5:	e8 d8 d0 ff ff       	call   801054c2 <memset>
801083ea:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801083ed:	83 ec 0c             	sub    $0xc,%esp
801083f0:	ff 75 f0             	pushl  -0x10(%ebp)
801083f3:	e8 0b f6 ff ff       	call   80107a03 <v2p>
801083f8:	83 c4 10             	add    $0x10,%esp
801083fb:	89 c2                	mov    %eax,%edx
801083fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108400:	83 ec 0c             	sub    $0xc,%esp
80108403:	6a 06                	push   $0x6
80108405:	52                   	push   %edx
80108406:	68 00 10 00 00       	push   $0x1000
8010840b:	50                   	push   %eax
8010840c:	ff 75 08             	pushl  0x8(%ebp)
8010840f:	e8 1d fb ff ff       	call   80107f31 <mappages>
80108414:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108417:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010841e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108421:	3b 45 10             	cmp    0x10(%ebp),%eax
80108424:	0f 82 75 ff ff ff    	jb     8010839f <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010842a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010842d:	c9                   	leave  
8010842e:	c3                   	ret    

8010842f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010842f:	55                   	push   %ebp
80108430:	89 e5                	mov    %esp,%ebp
80108432:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108435:	8b 45 10             	mov    0x10(%ebp),%eax
80108438:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010843b:	72 08                	jb     80108445 <deallocuvm+0x16>
    return oldsz;
8010843d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108440:	e9 a5 00 00 00       	jmp    801084ea <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108445:	8b 45 10             	mov    0x10(%ebp),%eax
80108448:	05 ff 0f 00 00       	add    $0xfff,%eax
8010844d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108452:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108455:	e9 81 00 00 00       	jmp    801084db <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010845a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845d:	83 ec 04             	sub    $0x4,%esp
80108460:	6a 00                	push   $0x0
80108462:	50                   	push   %eax
80108463:	ff 75 08             	pushl  0x8(%ebp)
80108466:	e8 26 fa ff ff       	call   80107e91 <walkpgdir>
8010846b:	83 c4 10             	add    $0x10,%esp
8010846e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108471:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108475:	75 09                	jne    80108480 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108477:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010847e:	eb 54                	jmp    801084d4 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108483:	8b 00                	mov    (%eax),%eax
80108485:	83 e0 01             	and    $0x1,%eax
80108488:	85 c0                	test   %eax,%eax
8010848a:	74 48                	je     801084d4 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010848c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010848f:	8b 00                	mov    (%eax),%eax
80108491:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108496:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108499:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010849d:	75 0d                	jne    801084ac <deallocuvm+0x7d>
        panic("kfree");
8010849f:	83 ec 0c             	sub    $0xc,%esp
801084a2:	68 35 8e 10 80       	push   $0x80108e35
801084a7:	e8 b0 80 ff ff       	call   8010055c <panic>
      char *v = p2v(pa);
801084ac:	83 ec 0c             	sub    $0xc,%esp
801084af:	ff 75 ec             	pushl  -0x14(%ebp)
801084b2:	e8 59 f5 ff ff       	call   80107a10 <p2v>
801084b7:	83 c4 10             	add    $0x10,%esp
801084ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801084bd:	83 ec 0c             	sub    $0xc,%esp
801084c0:	ff 75 e8             	pushl  -0x18(%ebp)
801084c3:	e8 4f a7 ff ff       	call   80102c17 <kfree>
801084c8:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801084cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801084d4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084de:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084e1:	0f 82 73 ff ff ff    	jb     8010845a <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801084e7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084ea:	c9                   	leave  
801084eb:	c3                   	ret    

801084ec <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801084ec:	55                   	push   %ebp
801084ed:	89 e5                	mov    %esp,%ebp
801084ef:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801084f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084f6:	75 0d                	jne    80108505 <freevm+0x19>
    panic("freevm: no pgdir");
801084f8:	83 ec 0c             	sub    $0xc,%esp
801084fb:	68 3b 8e 10 80       	push   $0x80108e3b
80108500:	e8 57 80 ff ff       	call   8010055c <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108505:	83 ec 04             	sub    $0x4,%esp
80108508:	6a 00                	push   $0x0
8010850a:	68 00 00 00 80       	push   $0x80000000
8010850f:	ff 75 08             	pushl  0x8(%ebp)
80108512:	e8 18 ff ff ff       	call   8010842f <deallocuvm>
80108517:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010851a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108521:	eb 4f                	jmp    80108572 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108526:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010852d:	8b 45 08             	mov    0x8(%ebp),%eax
80108530:	01 d0                	add    %edx,%eax
80108532:	8b 00                	mov    (%eax),%eax
80108534:	83 e0 01             	and    $0x1,%eax
80108537:	85 c0                	test   %eax,%eax
80108539:	74 33                	je     8010856e <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108545:	8b 45 08             	mov    0x8(%ebp),%eax
80108548:	01 d0                	add    %edx,%eax
8010854a:	8b 00                	mov    (%eax),%eax
8010854c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108551:	83 ec 0c             	sub    $0xc,%esp
80108554:	50                   	push   %eax
80108555:	e8 b6 f4 ff ff       	call   80107a10 <p2v>
8010855a:	83 c4 10             	add    $0x10,%esp
8010855d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108560:	83 ec 0c             	sub    $0xc,%esp
80108563:	ff 75 f0             	pushl  -0x10(%ebp)
80108566:	e8 ac a6 ff ff       	call   80102c17 <kfree>
8010856b:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010856e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108572:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108579:	76 a8                	jbe    80108523 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010857b:	83 ec 0c             	sub    $0xc,%esp
8010857e:	ff 75 08             	pushl  0x8(%ebp)
80108581:	e8 91 a6 ff ff       	call   80102c17 <kfree>
80108586:	83 c4 10             	add    $0x10,%esp
}
80108589:	c9                   	leave  
8010858a:	c3                   	ret    

8010858b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010858b:	55                   	push   %ebp
8010858c:	89 e5                	mov    %esp,%ebp
8010858e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108591:	83 ec 04             	sub    $0x4,%esp
80108594:	6a 00                	push   $0x0
80108596:	ff 75 0c             	pushl  0xc(%ebp)
80108599:	ff 75 08             	pushl  0x8(%ebp)
8010859c:	e8 f0 f8 ff ff       	call   80107e91 <walkpgdir>
801085a1:	83 c4 10             	add    $0x10,%esp
801085a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801085a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085ab:	75 0d                	jne    801085ba <clearpteu+0x2f>
    panic("clearpteu");
801085ad:	83 ec 0c             	sub    $0xc,%esp
801085b0:	68 4c 8e 10 80       	push   $0x80108e4c
801085b5:	e8 a2 7f ff ff       	call   8010055c <panic>
  *pte &= ~PTE_U;
801085ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bd:	8b 00                	mov    (%eax),%eax
801085bf:	83 e0 fb             	and    $0xfffffffb,%eax
801085c2:	89 c2                	mov    %eax,%edx
801085c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c7:	89 10                	mov    %edx,(%eax)
}
801085c9:	c9                   	leave  
801085ca:	c3                   	ret    

801085cb <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801085cb:	55                   	push   %ebp
801085cc:	89 e5                	mov    %esp,%ebp
801085ce:	53                   	push   %ebx
801085cf:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801085d2:	e8 ec f9 ff ff       	call   80107fc3 <setupkvm>
801085d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085de:	75 0a                	jne    801085ea <copyuvm+0x1f>
    return 0;
801085e0:	b8 00 00 00 00       	mov    $0x0,%eax
801085e5:	e9 f8 00 00 00       	jmp    801086e2 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801085ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085f1:	e9 c8 00 00 00       	jmp    801086be <copyuvm+0xf3>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801085f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f9:	83 ec 04             	sub    $0x4,%esp
801085fc:	6a 00                	push   $0x0
801085fe:	50                   	push   %eax
801085ff:	ff 75 08             	pushl  0x8(%ebp)
80108602:	e8 8a f8 ff ff       	call   80107e91 <walkpgdir>
80108607:	83 c4 10             	add    $0x10,%esp
8010860a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010860d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108611:	75 0d                	jne    80108620 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108613:	83 ec 0c             	sub    $0xc,%esp
80108616:	68 56 8e 10 80       	push   $0x80108e56
8010861b:	e8 3c 7f ff ff       	call   8010055c <panic>
    if(!(*pte & PTE_P))
80108620:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108623:	8b 00                	mov    (%eax),%eax
80108625:	83 e0 01             	and    $0x1,%eax
80108628:	85 c0                	test   %eax,%eax
8010862a:	75 0d                	jne    80108639 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010862c:	83 ec 0c             	sub    $0xc,%esp
8010862f:	68 70 8e 10 80       	push   $0x80108e70
80108634:	e8 23 7f ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
80108639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010863c:	8b 00                	mov    (%eax),%eax
8010863e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108643:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108646:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108649:	8b 00                	mov    (%eax),%eax
8010864b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108653:	e8 5b a6 ff ff       	call   80102cb3 <kalloc>
80108658:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010865b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010865f:	75 02                	jne    80108663 <copyuvm+0x98>
      goto bad;
80108661:	eb 6c                	jmp    801086cf <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108663:	83 ec 0c             	sub    $0xc,%esp
80108666:	ff 75 e8             	pushl  -0x18(%ebp)
80108669:	e8 a2 f3 ff ff       	call   80107a10 <p2v>
8010866e:	83 c4 10             	add    $0x10,%esp
80108671:	83 ec 04             	sub    $0x4,%esp
80108674:	68 00 10 00 00       	push   $0x1000
80108679:	50                   	push   %eax
8010867a:	ff 75 e0             	pushl  -0x20(%ebp)
8010867d:	e8 ff ce ff ff       	call   80105581 <memmove>
80108682:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108685:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108688:	83 ec 0c             	sub    $0xc,%esp
8010868b:	ff 75 e0             	pushl  -0x20(%ebp)
8010868e:	e8 70 f3 ff ff       	call   80107a03 <v2p>
80108693:	83 c4 10             	add    $0x10,%esp
80108696:	89 c2                	mov    %eax,%edx
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	83 ec 0c             	sub    $0xc,%esp
8010869e:	53                   	push   %ebx
8010869f:	52                   	push   %edx
801086a0:	68 00 10 00 00       	push   $0x1000
801086a5:	50                   	push   %eax
801086a6:	ff 75 f0             	pushl  -0x10(%ebp)
801086a9:	e8 83 f8 ff ff       	call   80107f31 <mappages>
801086ae:	83 c4 20             	add    $0x20,%esp
801086b1:	85 c0                	test   %eax,%eax
801086b3:	79 02                	jns    801086b7 <copyuvm+0xec>
      goto bad;
801086b5:	eb 18                	jmp    801086cf <copyuvm+0x104>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801086b7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086c4:	0f 82 2c ff ff ff    	jb     801085f6 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801086ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086cd:	eb 13                	jmp    801086e2 <copyuvm+0x117>

bad:
  freevm(d);
801086cf:	83 ec 0c             	sub    $0xc,%esp
801086d2:	ff 75 f0             	pushl  -0x10(%ebp)
801086d5:	e8 12 fe ff ff       	call   801084ec <freevm>
801086da:	83 c4 10             	add    $0x10,%esp
  return 0;
801086dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086e5:	c9                   	leave  
801086e6:	c3                   	ret    

801086e7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801086e7:	55                   	push   %ebp
801086e8:	89 e5                	mov    %esp,%ebp
801086ea:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086ed:	83 ec 04             	sub    $0x4,%esp
801086f0:	6a 00                	push   $0x0
801086f2:	ff 75 0c             	pushl  0xc(%ebp)
801086f5:	ff 75 08             	pushl  0x8(%ebp)
801086f8:	e8 94 f7 ff ff       	call   80107e91 <walkpgdir>
801086fd:	83 c4 10             	add    $0x10,%esp
80108700:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108706:	8b 00                	mov    (%eax),%eax
80108708:	83 e0 01             	and    $0x1,%eax
8010870b:	85 c0                	test   %eax,%eax
8010870d:	75 07                	jne    80108716 <uva2ka+0x2f>
    return 0;
8010870f:	b8 00 00 00 00       	mov    $0x0,%eax
80108714:	eb 29                	jmp    8010873f <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108719:	8b 00                	mov    (%eax),%eax
8010871b:	83 e0 04             	and    $0x4,%eax
8010871e:	85 c0                	test   %eax,%eax
80108720:	75 07                	jne    80108729 <uva2ka+0x42>
    return 0;
80108722:	b8 00 00 00 00       	mov    $0x0,%eax
80108727:	eb 16                	jmp    8010873f <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872c:	8b 00                	mov    (%eax),%eax
8010872e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108733:	83 ec 0c             	sub    $0xc,%esp
80108736:	50                   	push   %eax
80108737:	e8 d4 f2 ff ff       	call   80107a10 <p2v>
8010873c:	83 c4 10             	add    $0x10,%esp
}
8010873f:	c9                   	leave  
80108740:	c3                   	ret    

80108741 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108741:	55                   	push   %ebp
80108742:	89 e5                	mov    %esp,%ebp
80108744:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108747:	8b 45 10             	mov    0x10(%ebp),%eax
8010874a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010874d:	eb 7f                	jmp    801087ce <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010874f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108752:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108757:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010875a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875d:	83 ec 08             	sub    $0x8,%esp
80108760:	50                   	push   %eax
80108761:	ff 75 08             	pushl  0x8(%ebp)
80108764:	e8 7e ff ff ff       	call   801086e7 <uva2ka>
80108769:	83 c4 10             	add    $0x10,%esp
8010876c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010876f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108773:	75 07                	jne    8010877c <copyout+0x3b>
      return -1;
80108775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010877a:	eb 61                	jmp    801087dd <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010877c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877f:	2b 45 0c             	sub    0xc(%ebp),%eax
80108782:	05 00 10 00 00       	add    $0x1000,%eax
80108787:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010878a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108790:	76 06                	jbe    80108798 <copyout+0x57>
      n = len;
80108792:	8b 45 14             	mov    0x14(%ebp),%eax
80108795:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108798:	8b 45 0c             	mov    0xc(%ebp),%eax
8010879b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010879e:	89 c2                	mov    %eax,%edx
801087a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087a3:	01 d0                	add    %edx,%eax
801087a5:	83 ec 04             	sub    $0x4,%esp
801087a8:	ff 75 f0             	pushl  -0x10(%ebp)
801087ab:	ff 75 f4             	pushl  -0xc(%ebp)
801087ae:	50                   	push   %eax
801087af:	e8 cd cd ff ff       	call   80105581 <memmove>
801087b4:	83 c4 10             	add    $0x10,%esp
    len -= n;
801087b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ba:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801087bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087c0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801087c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c6:	05 00 10 00 00       	add    $0x1000,%eax
801087cb:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801087ce:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801087d2:	0f 85 77 ff ff ff    	jne    8010874f <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801087d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087dd:	c9                   	leave  
801087de:	c3                   	ret    
