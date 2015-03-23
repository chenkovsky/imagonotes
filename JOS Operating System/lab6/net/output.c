#include "ns.h"
#include <inc/syscall.h>
void
output(envid_t ns_envid) {
	int32_t req;
	envid_t whom;
	int perm;

	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	
	while (1) {
		//cprintf("output prepared to recieve request\n");
		perm = 0;
		req = ipc_recv((int32_t *) &whom, (void *) REQVA, &perm);
		//if (debug)
			//cprintf("output req %d from %08x [page %08x: %s]\n",
				//req, whom, vpt[VPN(REQVA)], REQVA);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
				whom);
			continue; // just leave it hanging...
		}

		if(req == NSREQ_OUTPUT) {
			struct jif_pkt *packet = (struct jif_pkt *)REQVA;
                        //cprintf("in the output.c the size is %d\n",packet->jp_len);
			sys_send_packet(packet->jp_data,packet->jp_len);
			//cprintf("packet send ok\n");
		}
		sys_page_unmap(0, (void*) REQVA);
		//cprintf("request deal ok\n");
	}
}
