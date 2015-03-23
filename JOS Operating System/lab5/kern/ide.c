#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <kern/pmap.h>
#include <kern/ide.h>
#include <kern/idereg.h>
#include <kern/env.h>
#include <kern/sched.h>

enum { ide_verbose = 0 };

// This is really an IDE channel coupled with one drive
struct ide_channel {
    // Hardware interface
    uint32_t cmd_addr;                             /* command register block */
    uint32_t ctl_addr;                             /* control register block */
    uint32_t bm_addr;                              /* bus master register block */
    uint32_t irq;                                  /* IRQ line */

    // Flags
    bool dma_wait;
    bool irq_wait;

    // Status values
    uint8_t ide_status;
    uint8_t ide_error;
    uint8_t dma_status;

    // Primary/secondary
    uint8_t diskno;

    // size of the disk
    uint32_t dk_bytes;

    // Align to 256 bytes to avoid spanning a 64K boundary.
    // 17 slots is enough for up to 64K data (16 pages), the max for DMA.
#define NPRDSLOTS	17
    /* Bus Master DMA table */
    struct ide_prd bm_prd[NPRDSLOTS] __attribute__((aligned (256)));
};

struct ide_channel *idec = NULL;

static void
ide_select_drive(struct ide_channel *idec)
{
    outb(idec->cmd_addr + IDE_REG_DEVICE, (idec->diskno << 4));
}

static int
ide_wait(struct ide_channel *idec, uint8_t flagmask, uint8_t flagset)
{
    uint64_t ts_start = read_tsc();
    for (;;) {
        idec->ide_status = inb(idec->cmd_addr + IDE_REG_STATUS);//read status
        if ((idec->ide_status & (IDE_STAT_BSY | flagmask)) == flagset)
            break;

        uint64_t ts_diff = read_tsc() - ts_start;
        if (ts_diff > 1024 * 1024 * 1024) {
            cprintf("ide_wait: stuck for %"PRIu64" cycles, status %02x\n",
                    ts_diff, idec->ide_status);
            return -E_BUSY;
        }
    }

    if (idec->ide_status & IDE_STAT_ERR) {
        idec->ide_error = inb(idec->cmd_addr + IDE_REG_ERROR);
        cprintf("ide_wait: error, status %02x error bits %02x\n",
                idec->ide_status, idec->ide_error);
    }

    if (idec->ide_status & IDE_STAT_DF)
        cprintf("ide_wait: data error, status %02x\n", idec->ide_status);

    return 0;
}

/* Two very simple pio read/write functions */
int
ide_pio_read(uint32_t secno, void *dst, size_t nsecs)
{
    int r;
    assert(nsecs <= 256);

    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);

    outb(idec->cmd_addr+IDE_REG_SECTOR_COUNT, nsecs);
    outb(idec->cmd_addr+IDE_REG_LBA_LOW, secno & 0xFF);
    outb(idec->cmd_addr+IDE_REG_LBA_MID, (secno >> 8) & 0xFF);
    outb(idec->cmd_addr+IDE_REG_LBA_HI, (secno >> 16) & 0xFF);
    outb(idec->cmd_addr+IDE_REG_DEVICE, (0xE0 | ((idec->diskno)<<4) | ((secno>>24)&0x0F)));
    outb(idec->cmd_addr+IDE_REG_CMD, IDE_CMD_READ);

    for(; nsecs > 0; nsecs--, dst += SECTSIZE) {
        if((r = ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY)) < 0)
            return r;
        insl(idec->cmd_addr+IDE_REG_DATA, dst, SECTSIZE/4);
    }

    return 0;
}

int __attribute__((__unused__))
ide_pio_write(uint32_t secno, const void *src, size_t nsecs)
{
    int r;
    assert(nsecs <= 256);

    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);

    outb(idec->cmd_addr+IDE_REG_SECTOR_COUNT, nsecs);
    outb(idec->cmd_addr+IDE_REG_LBA_LOW, secno & 0xFF);
    outb(idec->cmd_addr+IDE_REG_LBA_MID, (secno >> 8) & 0xFF);
    outb(idec->cmd_addr+IDE_REG_LBA_HI, (secno >> 16) & 0xFF);
    outb(idec->cmd_addr+IDE_REG_DEVICE, (0xE0 | ((idec->diskno)<<4) | ((secno>>24)&0x0F)));
    outb(idec->cmd_addr+IDE_REG_CMD, IDE_CMD_WRITE);

    for(; nsecs > 0; nsecs--, src += SECTSIZE) {
        if((r = ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY)) < 0)
            return r;
        outsl(idec->cmd_addr+IDE_REG_DATA, src, SECTSIZE/4);
    }

    return 0;
}

static void
ide_dma_irqack(struct ide_channel *idec)
{
    outb(idec->bm_addr + IDE_BM_STAT_REG,
         inb(idec->bm_addr + IDE_BM_STAT_REG));
}

static void
ide_intr(void *arg)
{
    struct ide_channel *idec = arg;

    if(ide_verbose)
        cprintf("ide_intr\n");
        //irq_setmask_8259A(irq_mask_8259A);
        ide_dma_irqack(idec);
        //inb(idec->cmd_addr + IDE_REG_STATUS);
        outb(IO_PIC2,0x20);
    if (idec->irq_wait == 0) {
        if(ide_verbose) {
            cprintf("idec->irq_wait=%d: just return\n",
                    idec->irq_wait);
        }
        assert((inb(idec->ctl_addr) & (IDE_CTL_NIEN)) == 0);
        //outb(idec->bm_addr+IDE_BM_STAT_REG,IDE_BM_STAT_INTR);
        //outb(idec->bm_addr+IDE_BM_CMD_REG,0);
        envs[1].env_tf.tf_padding2 = 0;
        
        return;
    }
    /*challenge
    else{
        if(ide_verbose) {
            cprintf("idec->irq_wait=%d: just return\n",
                    idec->irq_wait);
        }
        assert((inb(idec->ctl_addr) & (IDE_CTL_NIEN)) == 0);
        idec->dma_wait --;
    }*/
//? no use???????????
    panic("dma_wait and irq_wait not implemented\n");

    // Lab5: Your code here.
    
    return;
}

/* Two simple dma read/write functions. Currently in JOS, however, read
   and write are blocking and at block granularity(4KB), so our DMA is
   oversimplified -- the transfer size is always 4KB. */
int
ide_dma_read(uint32_t secno, void *dst, size_t nsecs)
{//may be there's no problem,but maybe i assume that one page.

    // Lab5: Your code here.
    // 
    //cprintf("at the head of the ide_dma_read\n");
    int r;
    assert(nsecs <= 256);
    int curslot = 0;
    /*
    challenge code:
    size_t left = nsecs;

    while(left > BLKSECTS) {
        struct ide_prd *prd = &(idec->bm_prd[curslot]);
        idec->irq_wait = 0;
        pte_t* pte_store;
        struct Page *pg = page_lookup(curenv->env_pgdir,dst,&pte_store);
        prd->addr = PTE_ADDR(*pte_store);
        prd->count = (nsecs*SECTSIZE);
        struct Page *prdpg = page_lookup(curenv->env_pgdir,prd,&pte_store);
        curslot++;
        left -= BLKSECTS;
        dst += PGSIZE;
    }
    idec->dma_wait = curslot -1; 
    */
    /*4k*/
    struct ide_prd *prd = &(idec->bm_prd[curslot]);
    idec->irq_wait = 0;
    pte_t* pte_store;
    struct Page *pg = page_lookup(curenv->env_pgdir,dst,&pte_store);
    prd->addr = PTE_ADDR(*pte_store);
    prd->count = (nsecs*SECTSIZE)|IDE_PRD_EOT;//EOT
    struct Page *prdpg = page_lookup(curenv->env_pgdir,prd,&pte_store);
    /*4k*/

    //cprintf("prd's va:%x,addr va:%x\n",prd,dst);
    //cprintf("the pg transfer address:%x\n",prd->addr);
    //cprintf("the prdpg address:%x;size is %x\n",PTE_ADDR(*pte_store)|PGOFF(prd),prd->count);
    //ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    /*set BM*/
    outb(idec->bm_addr+IDE_BM_CMD_REG,0);//stop the former transfer if any. maybe this is no use.
    outb(idec->bm_addr+IDE_BM_STAT_REG,IDE_BM_STAT_INTR|IDE_BM_STAT_ERROR);/*clear the interrupt and err*/
    outl(idec->bm_addr+IDE_BM_PRDT_REG,PTE_ADDR(*pte_store)|PGOFF(prd));/*set the address of descriptor of cache*/
    //outb(idec->bm_addr+IDE_BM_CMD_REG,8);/*set read*/
    
    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    //outb(idec->cmd_addr+IDE_REG_DEVICE,0);//reset the DEV
    //ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    //outb(idec->ctl_addr,0);//open interrupt
    /*set ATA*/
    outb(idec->cmd_addr+IDE_REG_FEATURES,0);
    outb(idec->cmd_addr+IDE_REG_SECTOR_COUNT, nsecs);//set sector count
    outb(idec->cmd_addr+IDE_REG_LBA_LOW, secno & 0xFF);//LBA's 0~7
    outb(idec->cmd_addr+IDE_REG_LBA_MID, (secno >> 8) & 0xFF);//LBA's 8~15
    outb(idec->cmd_addr+IDE_REG_LBA_HI, (secno >> 16) & 0xFF);//LBA's 16~23
    outb(idec->cmd_addr+IDE_REG_DEVICE, (0xE0 | ((idec->diskno)<<4) | ((secno>>24)&0x0F)));//obs LBA obs DEV LBA's 24~27
    outb(idec->cmd_addr+IDE_REG_CMD, IDE_CMD_READ_DMA);
    /*start the transfer*/
    //cprintf("interrup bit before transfer:%d",(inb(idec->bm_addr+IDE_BM_STAT_REG)&4));
    outb(idec->ctl_addr, 0);
    outb(idec->bm_addr+IDE_BM_CMD_REG,IDE_BM_CMD_START);/*set the command in the BM:read and start*/
    //maybe wrong because of the interrupt and err bit.how to response interrupt
    //cprintf("at the tail of the ide_dma_read\n");
    //while(!(inb(idec->bm_addr+IDE_BM_STAT_REG)&4)) {
        //cprintf("waiting!!!!!!\n");
    //}
    return 0;
}

int __attribute__((__unused__))
ide_dma_write(uint32_t secno, const void *src, size_t nsecs)
{

    // Lab5: Your code here.
    int r;
    assert(nsecs <= 256);
    //cprintf("at the head of the ide_dma_write\n");
    struct ide_prd *prd = &(idec->bm_prd[0]);
    pte_t* pte_store;
    struct Page *pg = page_lookup(curenv->env_pgdir,(void*)src,&pte_store);
    prd->addr = PTE_ADDR(*pte_store);
    prd->count = (nsecs*SECTSIZE)|IDE_PRD_EOT;//EOT
    struct Page *prdpg = page_lookup(curenv->env_pgdir,prd,&pte_store);
    //ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    /*set BM*/
    outl(idec->bm_addr+IDE_BM_CMD_REG,0);//stop the former transfer if any. maybe this is no use.
    outb(idec->bm_addr+IDE_BM_STAT_REG,6);/*clear the interrupt and err*/
    //outb(idec->bm_addr+IDE_BM_STAT_REG,7<<5);//set simplex D1DC,D0DC
    outl(idec->bm_addr+IDE_BM_PRDT_REG,PTE_ADDR(*pte_store)|PGOFF(prd));/*set the address of descriptor of cache*/
    outb(idec->bm_addr+IDE_BM_CMD_REG,IDE_BM_CMD_WRITE);/*set write*/
    /*set ATA*/
    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    outb(idec->cmd_addr+IDE_REG_SECTOR_COUNT, nsecs);//set sector count
    outb(idec->cmd_addr+IDE_REG_LBA_LOW, secno & 0xFF);//LBA's 0~7
    outb(idec->cmd_addr+IDE_REG_LBA_MID, (secno >> 8) & 0xFF);//LBA's 8~15
    outb(idec->cmd_addr+IDE_REG_LBA_HI, (secno >> 16) & 0xFF);//LBA's 16~23
    outb(idec->cmd_addr+IDE_REG_DEVICE, (0xE0 | ((idec->diskno)<<4) | ((secno>>24)&0x0F)));//obs LBA obs DEV LBA's 24~27
    outb(idec->cmd_addr+IDE_REG_CMD, IDE_CMD_WRITE_DMA);
    /*start the transfer*/
    //cprintf("interrup bit before transfer:%d",(inb(idec->bm_addr+IDE_BM_STAT_REG)&4));
    outb(idec->ctl_addr, 0);
    outb(idec->bm_addr+IDE_BM_CMD_REG,IDE_BM_CMD_START);/*set the command in the BM:write and start*/
    //while(!(inb(idec->bm_addr+IDE_BM_STAT_REG)&4)) {
        //cprintf("waiting!!!!!!\n");
    //}
    //cprintf("we have interrupt\n");
    return 0;
}

static void
ide_string_shuffle(char *s, int len)
{
    int i;
    for (i = 0; i < len; i += 2) {
        char c = s[i+1];
        s[i+1] = s[i];
        s[i] = c;
    }

    s[len-1] = '\0';            /* force the string to end... */
}

static int
ide_pio_in(struct ide_channel *idec, void *buf, uint32_t num_sectors)
{//read the status
    char *cbuf = (char *) buf;

    for (; num_sectors > 0; num_sectors--, cbuf += SECTSIZE) {
        int r = ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
        if (r < 0)
            return r;

        if ((idec->ide_status & (IDE_STAT_DF | IDE_STAT_ERR)))
            return -E_IO;

        insl(idec->cmd_addr + IDE_REG_DATA, cbuf, SECTSIZE/4);
    }

    return 0;
}

static int __attribute__((__unused__))
ide_pio_out(struct ide_channel *idec, const void *buf, uint32_t num_sectors)
{
    const char *cbuf = (const char *) buf;

    for (; num_sectors > 0; num_sectors--, cbuf += SECTSIZE) {
        int r = ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
        if (r < 0)
            return r;

        if ((idec->ide_status & (IDE_STAT_DF | IDE_STAT_ERR)))
            return -E_IO;

        outsl(idec->cmd_addr + IDE_REG_DATA, cbuf, SECTSIZE / 4);
    }

    return 0;
}

static union {
    struct identify_device id;
    char buf[512];
} identify_buf;

static int
idec_init(struct ide_channel *idec)
{
    int i;
    outb(idec->cmd_addr + IDE_REG_DEVICE, idec->diskno << 4);
    outb(idec->cmd_addr + IDE_REG_CMD, IDE_CMD_IDENTIFY);
    /* on the ATA's pdf page 127 
     * command returns media status bit WP,MC,MCR,NM. 
     * if the media disabled,return 0; 
     */
    cprintf("Probing IDE disk %d..\n", idec->diskno);
    if (ide_pio_in(idec, &identify_buf, 1) < 0)
        return -E_INVAL;

    ide_string_shuffle(identify_buf.id.serial,
                       sizeof(identify_buf.id.serial));
    ide_string_shuffle(identify_buf.id.model,
                       sizeof(identify_buf.id.model));
    ide_string_shuffle(identify_buf.id.firmware,
                       sizeof(identify_buf.id.firmware));

    // Identify the Ultra DMA mode (1-5)    
    // Lab5: Your code here. 
    int16_t udma_mode = -1;
    if((identify_buf.id.udma_mode & 1<<5)) {
        //cprintf("5\n");
        udma_mode = 5;
    }else if((identify_buf.id.udma_mode & 1<<4)){
        //cprintf("4\n");
        udma_mode = 4;
    }else if((identify_buf.id.udma_mode & 1<<3)){
        //cprintf("3\n");
        udma_mode = 3;
    }else if((identify_buf.id.udma_mode & 1<<2)){
        //cprintf("2\n");
        udma_mode = 2;
    }else if((identify_buf.id.udma_mode & 1<<1)){
        //cprintf("1\n");
        udma_mode = 1;
    }
    cprintf("udma mode:%d\n",udma_mode);
    if (ide_verbose)
        cprintf("IDE device (%d sectors, UDMA %d%s): %1.40s\n",
                identify_buf.id.lba_sectors, udma_mode,
                idec->bm_addr ? ", bus-master" : "",
                identify_buf.id.model);

    if (!(identify_buf.id.hwreset & IDE_HWRESET_CBLID)) {
        cprintf("IDE: 80-pin cable absent, not enabling UDMA\n");
        udma_mode = -1;
    }

    if (udma_mode >= 0) {
        outb(idec->cmd_addr + IDE_REG_DEVICE, idec->diskno << 4);
        outb(idec->cmd_addr + IDE_REG_FEATURES, IDE_FEATURE_XFER_MODE);
        outb(idec->cmd_addr + IDE_REG_SECTOR_COUNT, IDE_XFER_MODE_UDMA | udma_mode);
        outb(idec->cmd_addr + IDE_REG_CMD, IDE_CMD_SETFEATURES);

        ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
        if ((idec->ide_status & (IDE_STAT_DF | IDE_STAT_ERR)))
            cprintf("IDE: Unable to enable UDMA\n");
    }

    // Enable write-caching
    outb(idec->cmd_addr + IDE_REG_DEVICE, idec->diskno << 4);
    outb(idec->cmd_addr + IDE_REG_FEATURES, IDE_FEATURE_WCACHE_ENA);
    outb(idec->cmd_addr + IDE_REG_CMD, IDE_CMD_SETFEATURES);

    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    if ((idec->ide_status & (IDE_STAT_DF | IDE_STAT_ERR)))
        cprintf("IDE: Unable to enable write-caching\n");

    // Enable read look-ahead
    outb(idec->cmd_addr + IDE_REG_DEVICE, idec->diskno << 4);
    outb(idec->cmd_addr + IDE_REG_FEATURES, IDE_FEATURE_RLA_ENA);
    outb(idec->cmd_addr + IDE_REG_CMD, IDE_CMD_SETFEATURES);

    ide_wait(idec, IDE_STAT_DRDY, IDE_STAT_DRDY);
    if ((idec->ide_status & (IDE_STAT_DF | IDE_STAT_ERR)))
        cprintf("IDE: Unable to enable read look-ahead\n");

    // The disk size
    idec->dk_bytes = identify_buf.id.lba_sectors * 512;

    uint8_t bm_status = inb(idec->bm_addr + IDE_BM_STAT_REG);
    if (bm_status & IDE_BM_STAT_SIMPLEX)
        cprintf("Simplex-mode IDE bus master, potential problems later..\n");

    // Enable interrupts (clear the IDE_CTL_NIEN bit)
    outb(idec->ctl_addr, 0);

    // Final note: irq is initialized statically...
    return 0;
}

int
ide_init(struct pci_func *pcif)
{
    struct Page *pp;
    int r = page_alloc(&pp);
    if (r < 0)
        return r;

    idec = page2kva(pp);
    memset(idec, 0, sizeof(struct ide_channel));
    static_assert(PGSIZE >= sizeof(*idec));/* one page is allocated for idec*/
    pci_func_enable(pcif);//seemly read the configure to the pcif
    if(ide_verbose)
        cprintf("  ide_init: pcif->reg_base[0]: 0x%x, pcif->reg_base[1]: 0x%x\n",
                pcif->reg_base[0], pcif->reg_base[1]+2);

    // Use the first IDE channel on the IDE controller
    idec->cmd_addr = pcif->reg_size[0] ? pcif->reg_base[0] : 0x1f0;//if read configure ok,then set the value read,else set it with the default value?
    idec->ctl_addr = pcif->reg_size[1] ? pcif->reg_base[1] + 2 : 0x3f6;
    idec->bm_addr = pcif->reg_base[4];
    idec->irq = IDE_IRQ;

    cprintf("  ide_init: cmd_addr: 0x%x, ctl_addr: 0x%x, bm_addr: 0x%x, irq: %d\n",
            idec->cmd_addr, idec->ctl_addr, idec->bm_addr, idec->irq);

    // Enable IDE irq
	cprintf("	Setup IDE interrupt via 8259A\n");
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_IDE));
	cprintf("	unmasked IDE interrupt\n");

    // Set the irq op
    disk_irq_op.arg = idec;//ide channel is the argument of the irq handler

    // Try to initialize the second IDE drive (secondary) first
    cprintf("in the ide_init before idec_init disk1\n");
    idec->diskno = 1;
    if (idec_init(idec) >= 0)
        return 1;
//why?
    cprintf("in the ide_init after idec_init disk1\n");
    // Try the primary drive instead..
    idec->diskno = 0;
    if (idec_init(idec) >= 0)
        return 1;
    cprintf("in the ide_init after idec_init disk1\n");
    // Doesn't seem to work
    page_free(pp);
    return 0;
}

irq_op_t disk_irq_op = {
    .irq = IDE_IRQ,
    .handler = ide_intr,
    .arg = NULL,
};
