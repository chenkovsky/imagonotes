#ifndef JOS_KERN_IDE_H
#define JOS_KERN_IDE_H

#include <dev/pci.h>
#include <kern/picirq.h>

#define SECTSIZE	512			// bytes per disk sector

/* These macros should be discarded */
#define BLKSIZE     4096        // one page
#define BLKSECTS	(BLKSIZE / SECTSIZE)	// sectors per block
#define IDE_IRQ     14          // PCI IRQ routing is too complicated

extern irq_op_t disk_irq_op;

int ide_pio_read(uint32_t secno, void *dst, size_t nsecs);
int __attribute__((__unused__)) ide_pio_write(uint32_t secno, const void *src, size_t nsecs);
int ide_dma_read(uint32_t secno, void *dst, size_t nsecs);
int __attribute__((__unused__)) ide_dma_write(uint32_t secno, const void *src, size_t nsecs);
int ide_init(struct pci_func *pcif);

#endif
