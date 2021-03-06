// LAB 6: Your driver code here
#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <kern/pmap.h>
#include <dev/e100.h>
#include <dev/idereg.h>
#include <kern/env.h>
#include <kern/sched.h>
#define TCB_MAX_DATA_SIZE 1518
struct head {
    volatile uint16_t status;
    volatile uint16_t cmd;
    uint32_t link;
};
struct tcbbody {
    uint32_t tbd_array_addr;
    volatile uint16_t size;
    volatile uint8_t thrs;
    volatile uint8_t tbd_count;
    volatile uint8_t data[TCB_MAX_DATA_SIZE];
};
struct rfdbody {
    uint32_t reserved;
    uint16_t actualcount;
    uint16_t size;
    volatile uint8_t data[TCB_MAX_DATA_SIZE];//may be padding is not ok
};
union body_t {
    struct tcbbody tcb;
    struct rfdbody rfd;
};
struct cb {
    struct head head;
    union body_t body;
};
struct nic_t {
    uint32_t csr_io;
    uint32_t gen_ptr;
    uint32_t port;
    uint8_t irq;
#define CB_LINK_SIZE 8
#define RB_LINK_SIZE 8
    uint32_t cbtail;
    uint32_t cbhead;
    uint32_t rbtail;
    uint32_t rbhead;
    struct cb * cbl[CB_LINK_SIZE];
    struct cb * rbl[RB_LINK_SIZE];
};
struct nic_t *nic;
enum port {
    software_reset  = 0x0000,
    selftest        = 0x0001,
    selective_reset = 0x0002,
};
enum scb_cmd_lo {
    cuc_nop        = 0x00,
    ruc_start      = 0x01,
    ruc_load_base  = 0x06,
    cuc_start      = 0x10,
    cuc_resume     = 0x20,
    cuc_dump_addr  = 0x40,
    cuc_dump_stats = 0x50,
    cuc_load_base  = 0x60,
    cuc_dump_reset = 0x70,
};
static void
delay(void)
{//seems like 10us
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
static struct cb* alloc_free_tcb(struct nic_t *nic);
static void free_tcb(struct nic_t *nic);
static void clean_rb(struct cb *rb);
static void net_reset(struct nic_t *nic){
    /*put cu and ru into idle with a selective reset to get device off of PCI bus*/
    outl(nic->port,selective_reset);
//cprintf("after selecttive_reset\n");
    //inb(nic->scb.status);//flush
//cprintf("after flush\n");
    delay();
    outl(nic->port,software_reset);//no need
//cprintf("after software_reset\n");
    //inb(nic->scb.status);//flush
//cprintf("after flush\n");
    delay();
    //outb(&nic->csr->scb.cmd_hi,irq_mask_all);//disable irq
}
static void set_tcb(struct cb *tcb,void *addr,size_t size){
    if (tcb) {
//cprintf("set size:%d\n",size);
        assert(size <= TCB_MAX_DATA_SIZE);
        memcpy((void*)tcb->body.tcb.data,addr,size);
        tcb->body.tcb.size = size;
    }
}
static void executeCmd(struct nic_t *nic,uint32_t dma_addr,uint8_t cmd){
    if(cmd != cuc_resume){
	outl(nic-> gen_ptr, dma_addr);
	//cprintf("set gen_ptr:%x\n",dma_addr);
	outb(nic->csr_io+CMD,cuc_load_base);
    }
    outb(nic->csr_io+CMD,cmd);
}
static void cbl_init(struct nic_t *nic){
    /* form a cycle ring
     *
     */
    void* addr;
    //pte_t *pte_store;
//cprintf("we are in the head of cbl_init\n");
    //memset(nic->cbl,0,sizeof(struct cb)*CB_LINK_SIZE);
//cprintf("after memset of cbl_init\n");
    int i;
    for (i = 0;i<CB_LINK_SIZE;i++) {
        struct Page *pp;
        int r = page_alloc(&pp);
        //cprintf("r[%d] addr is %x\n",i,PADDR(page2kva(pp)));
        if (r < 0)
            panic("no mem for cbl\n");
        nic->cbl[i] = page2kva(pp);//alloc page for the rbl,every block a page
        memset(nic->cbl[i],0,PGSIZE);
    }
    for (i = 0;i<CB_LINK_SIZE;i++) {
        struct tcbbody *body= &(nic->cbl[i]->body.tcb);
        body->tbd_array_addr = 0xFFFFFFFF;
        body->thrs = 0xE0;
        body->tbd_count = 0;
        addr = nic->cbl[(i+1)%CB_LINK_SIZE];
        //cprintf("addr:%x,page_lookup addr:%x\n,curenv->pdfir:%x\n",addr,&page_lookup,boot_pgdir);
        //cprintf("after page_lookup of cbl_init in cycle\n");
        nic->cbl[i]->head.link = PADDR(addr);
        //cprintf("cbl[%d]'s link is %x\n",i,PADDR(addr));
    }
    nic->cbhead = 0;
    nic->cbtail = CB_LINK_SIZE-1;
    //nic->cbl[0].head.cmd |= EL;
    //page_lookup(boot_pgdir,nic->cbl[0],&pte_store);PTE_ADDR(*pte_store)|PGOFF(nic->cbl[0])
    //cprintf("after page_lookup of cbl_init,first block physical addr:%x\n",PADDR(nic->cbl[0]));
    outl( nic->gen_ptr,PADDR(nic->cbl[0]));//set the dma_addr to the gen_ptr
    outb(nic->csr_io+CMD,cuc_load_base);
    //outb(nic->csr_io+CMD,cuc_start);
}
static void rbl_init(struct nic_t *nic){
    /* form a cycle ring
     *
     */
    void* addr;
    //pte_t *pte_store;
//cprintf("we are in the head of cbl_init\n");
    //memset(nic->rbl,0,sizeof(struct cb)*CB_LINK_SIZE);
//cprintf("after memset of cbl_init\n");
    int i;
    for (i = 0;i<RB_LINK_SIZE;i++) {
        struct Page *pp;
        int r = page_alloc(&pp);
        //cprintf("r[%d] addr is %x\n",i,PADDR(page2kva(pp)));
        if (r < 0)
            panic("no mem for rbl\n");
        nic->rbl[i] = page2kva(pp);//alloc page for the rbl,every block a page
        memset(nic->rbl[i],0,PGSIZE);
    }
    for (i = 0;i<RB_LINK_SIZE;i++) {
        struct rfdbody *body= &(nic->rbl[i]->body.rfd);
        body->size = TCB_MAX_DATA_SIZE;
        body->actualcount = 0;
        addr = nic->rbl[(i+1)%RB_LINK_SIZE];
        //cprintf("addr:%x,page_lookup addr:%x\n,curenv->pdfir:%x\n",addr,&page_lookup,boot_pgdir);
        //page_lookup(boot_pgdir,addr,&pte_store);
        //cprintf("after page_lookup of cbl_init in cycle\n");
        nic->rbl[i]->head.link = PADDR(addr);//wrong must be physical addr
        //cprintf("cbl[%d]'s link is %x\n",i,PADDR(addr));
    }
    nic->rbhead = 0;
    nic->rbtail = RB_LINK_SIZE-1;
    //nic->rbl[RB_LINK_SIZE-1]->head.cmd |= EL;//???????????????????????????????????????????????
    //page_lookup(boot_pgdir,nic->rbl[0],&pte_store);PTE_ADDR(*pte_store)|PGOFF(nic->rbl[0])
    //cprintf("after page_lookup of rbl_init,first block physical addr:%x\n",PADDR(nic->rbl[0]));
    outl( nic->gen_ptr,PADDR(nic->rbl[0]));//set the dma_addr to the gen_ptr//no!!!!!
    outb(nic->csr_io+CMD,ruc_start);
}
static void
net_intr(void *arg){
    //must set cbtail,if any wrong maybe the link is not ok,no
}
int net_init (struct pci_func *pcif){
    struct Page *pp;
    int r = page_alloc(&pp);
    if (r < 0)
        return r;
    nic = page2kva(pp);
    //cprintf("nic size %d\n",sizeof(struct nic_t));
    pci_func_enable(pcif);
    //config.irq_line = pcif->irq_line;
    cprintf("  net_init: reg_base[0]: 0x%x, reg_base[1]: 0x%x, reg_base[2]: 0x%x\n,reg_base[3]:%x\nirq line:0x%x\n",
            pcif->reg_base[0], pcif->reg_base[1],pcif->reg_base[2],pcif->reg_base[3],pcif->irq_line);
    nic->csr_io = pcif->reg_base[1];
    nic->gen_ptr = pcif->reg_base[1]+4;
    nic->port = pcif->reg_base[1]+8;
    nic->irq = NET_IRQ;
    //cprintf("after init nic\n");
    net_reset(nic);
    cprintf("  net_init: irq: %d\n", nic->irq);
    cbl_init(nic);
    rbl_init(nic);
    // Enable IDE irq
    cprintf("	Setup NET interrupt via 8259A\n");
    irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_NET));
    cprintf("	unmasked NET interrupt\n");

    // Set the irq op
    net_irq_op.arg = nic;

    return 1;
}
int send_packet(void* addr,size_t size){
    assert(size <= TCB_MAX_DATA_SIZE);
    size_t leftsize = size;
    struct cb *cbtmp;
    struct cb *first = NULL;
    struct cb *last = NULL;
    int ret = 0;
    free_tcb(nic);
    //cprintf("at the start of the send_packet, size:%d\n",size);
    /**if larger than one block   */
//int i = 0; !!!attention the struct is changed
    /*for (leftsize = size;leftsize >TCB_MAX_DATA_SIZE;leftsize-= TCB_MAX_DATA_SIZE,addr+= TCB_MAX_DATA_SIZE) {//may be no use
cprintf("packet i:%d",i);
i++;
        if ((cbtmp = alloc_free_tcb(nic))) {
		if(first == NULL){
			first = cbtmp;
		}
            last = cbtmp;
            cbtmp->head.cmd = CU_CMD_TRANS;//set command
            set_tcb(cbtmp,addr,TCB_MAX_DATA_SIZE);
        } else {
            //no enough tcb
            ret = -ERR_NO_TCB;
            break;//return -ERR_NO_TCB;
        }
    }*/
    /**if larger than one block   */
    /**less than one block   */
    if ((cbtmp = alloc_free_tcb(nic))) {
	//if(first == NULL){
		//first = cbtmp;
	//}
        //last = cbtmp;
//cprintf("send the left packet addr packet:%x\n",nic->cbl[0]);
        cbtmp->head.cmd = CU_CMD_TRANS;//set command
        set_tcb(cbtmp,addr,leftsize);
    //if (last) {
//cprintf("set EL\n");
        cbtmp->head.cmd |= EL;//set the cb as the last block
    //}
    //cprintf("just before start e100,cmd is %x,data addr:%x\n",cbtmp->head.cmd, cbtmp->body.tcb.data);
    executeCmd(nic,PADDR(cbtmp),cuc_start);//when it's in active state, it's wrong
    //outb(nic->csr_io+CMD,cuc_resume);//start maybe should see its state firstly!!!!!!!!!!!!!!!!!!!!!!maybe use resume is ok
    //cprintf("at the end of the send_packet\n");
    }
    return ret;
}//must set the EL before the first added block.
int recv_packet(void* addr,size_t *size_store){
    size_t actualcount;
    struct cb *cbtmp;
    int ret = 0;
    //no free?
    //int i;
    int actualbit;
    int cur = (nic->rbtail+1)%RB_LINK_SIZE;
    //cprintf("recv_packet here,addr:%x,size_store:%x\n",addr,size_store);
    if((nic->rbl[cur]->head.status & CU_STATUS_C)&&(nic->rbl[cur]->head.status & CU_STATUS_OK)) {
        //cprintf("received rfa[%d]\n",cur);
        actualcount = (nic->rbl[cur]->body.rfd.actualcount)&~(F|EOF);
	//cprintf("the actual count is %d\n",actualcount);
        if(size_store) {
	//cprintf("size store:%x\n",size_store);
            *size_store = actualcount;
        }
	//cprintf("after set the size\n");
        memcpy(addr,(void *)(nic->rbl[cur]->body.rfd.data),actualcount);
	//cprintf("after memcpy\n");
        clean_rb(nic->rbl[cur]);
        nic->rbtail = cur;
        ret = 1;
    }
    return ret;
}
static void clean_rb(struct cb *rb){
    rb->head.cmd = 0;
    rb->head.status = 0;
    rb->body.rfd.actualcount = 0;
}
static struct cb* alloc_free_tcb(struct nic_t *nic) {
    //set the cbtail at interrupt
    if (nic->cbhead == nic->cbtail) {
        return NULL;
    } else {
        struct cb *cbtmp= nic->cbl[nic->cbhead];
        //cprintf("alloc cbl[%d]\n",nic->cbhead);
        nic->cbhead = (nic->cbhead+1)%CB_LINK_SIZE;
        return cbtmp;
    }
}
static void printtbl(struct nic_t *nic){
    int i;
    struct cb** tcb = nic->cbl;
    int cur;
    for (i = 0;i<CB_LINK_SIZE;i++) {
        cur = (nic->cbtail+1)%CB_LINK_SIZE;
        cprintf("tcb[%d]->head.status=%d,when & C is %d, when &OK is %d\n",i,tcb[i]->head.status,(tcb[i]->head.status&CU_STATUS_C),(tcb[i]->head.status & CU_STATUS_OK));
    }
}
static void free_tcb(struct nic_t *nic){
    int i;
    struct cb** tcb = nic->cbl;
    int cur;
    //printtbl(nic);
    for (i = 0;i<CB_LINK_SIZE;i++) {
        cur = (nic->cbtail+1)%CB_LINK_SIZE;
        //cprintf("tcb[%d]->head.status=%d,when & C is %d, when &OK is %d\n",cur,tcb[cur]->head.status,(tcb[cur]->head.status&CU_STATUS_C),(tcb[cur]->head.status & CU_STATUS_OK));
        if ((tcb[cur]->head.status&CU_STATUS_C) &&(tcb[cur]->head.status & CU_STATUS_OK)) {
            nic->cbtail = cur;
            tcb[cur]->head.status = 0;//tcb[cur]->head.status & ~CU_STATUS_C & ~CU_STATUS_OK;
            //cprintf("tcb[%d] is freed\n",cur);
        } else {
            break;
        }
    }
}
irq_op_t net_irq_op = {
    .irq = NET_IRQ,
    .handler = net_intr,
    .arg = NULL,
};//no use
