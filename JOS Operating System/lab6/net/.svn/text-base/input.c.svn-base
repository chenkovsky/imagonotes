#include "ns.h"

void
input(envid_t ns_envid) {
	int req;

	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server

    while (1) {
		int r = sys_page_alloc(0, (void *)REQVA, PTE_U|PTE_W|PTE_P);
		if(r) {
			panic("input err");
		}
		struct jif_pkt *packet = (struct jif_pkt *)REQVA;
		packet->jp_len = 0;
		
		//cprintf("packet->jp_data addr:%x,packet->jp_len addr:%x\n",packet->jp_data,&(packet->jp_len));
		if(sys_recv_packet(packet->jp_data,&(packet->jp_len))) {
			//cprintf("in the input.c, start to ipc packet\n");
			ipc_send(ns_envid, NSREQ_INPUT, (void *)REQVA, PTE_U|PTE_W|PTE_P);
		}
		sys_page_unmap(0, (void*) REQVA);
	}
}
