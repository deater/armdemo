@ some defines

@ I/O base on Pi1 models
@ this is different on Pi2/Pi3/Pi4

IO_BASE		= 0x20000000

@===================
@ Mailbox Addresses
@===================
MAILBOX_BASE	= IO_BASE+0xB880
MAILBOX_READ	= IO_BASE+0xB880
MAILBOX_POLL	= IO_BASE+0xB890
MAILBOX_SENDER	= IO_BASE+0xB894
MAILBOX_STATUS	= IO_BASE+0xB898
MAILBOX_CONFIG	= IO_BASE+0xB89C
MAILBOX_WRITE	= IO_BASE+0xB8A0

OFFSET_MAILBOX_READ	= 0x00
OFFSET_MAILBOX_STATUS	= 0x18
OFFSET_MAILBOX_WRITE	= 0x20

MAILBOX_FULL	= 0x80000000
MAILBOX_EMPTY	= 0x40000000

