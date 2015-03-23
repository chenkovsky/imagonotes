#ifndef JOS_DEV_E100_H
#define JOS_DEV_E100_H 1
#include <dev/pci.h>
#include <kern/picirq.h>

#define NET_IRQ     10
#define EL          1<<15//if set, the block is the last one on the CBL
#define S           1<<14//if set, CU will be suspend after the completion of this CB
#define I           1<<13//if set, device generate an interrupt after execution of the CB finished
/*only transmit use*/
#define CID         1<<12//CNA interrupt delay
#define NC          1<<4//if set, CRC and source address are no inserted by controller
#define SF          1<<3//Flexible Mode
/*only transmit use*/

#define CU_STATUS_C 1<<15//completed until last bit
#define CU_STATUS_X 1<<14//
#define CU_STATUS_OK    1<<13//execute no err
#define CU_STATUS_U 1<<12//one or more underrun encounter,.....

#define CMD  2
//#define CU_CMD  24
#define SI      9
#define M       8
//EOF not checked.
#define CU_CMD_NOP  0
#define CU_CMD_ADDRSET  1//used to load the device with the individual address.
/*no use?*/
#define CU_CMD_CONFIG   2//load the device with its operating parameters
#define CU_CMD_MULTICASTSETUP   3//load multicast IDs into the device for filtering purpose
/*no use?*/
#define CU_CMD_TRANS    4
#define CU_CMD_LOADMICROCODE    5
#define CU_CMD_DUMP 6
#define CU_CMD_DIAGNOSE 7


#define ERR_NO_TCB  1
/*recieve*/
#define H   1<<4//set if current RFD is a header RFD
#define C   1<<15//completion of frame reception.set by device
#define EOF 1<<15
#define F   1<<14//device update actual count field.
#define COUNT_MASK ~(3<<14)
extern irq_op_t net_irq_op;
int net_init (struct pci_func *pcif);
int send_packet(void* addr,size_t size);
int recv_packet(void* addr,size_t *size_store);
#endif	// !JOS_DEV_E100_H
