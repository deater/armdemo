
# Syscalls
.equ SYSCALL_EXIT,     1
.equ SYSCALL_WRITE,    4

#
.equ STDIN,0
.equ STDOUT,1
.equ STDERR,2

	.globl _start
_start:
	# Note, on Linux x86 all registers but esp are 0 on start
	# See arch/x86/include/asm/elf.h

next_frame:
#	mov	$out_buffer,%edi
#	mov	$65535,%ecx
#	mov	$0x13,%al	# mode 13h, 320x200 pixels, 256 colors
B:
#	cwd			# erase DX for pixel setting (AH = 0x0C/0x00)
#	int	$0x10		# set graphic mode (AH = 0x00), set pixel (AH = 0x0C)
	# want to set out_buffer[cx] to al
#	stosb
	mov	%al,out_buffer(%ecx)
X:
	mov	$0xd,%bl	# start ray depth at 14
L:
	mov	$0xcccc,%ax	# "Rrrola constant" to convert screen pointer to coordinates
	mul	%cx		# Getting X,Y in DL,DH
	mov	%dh,%al		# getting Y into AL
	mul	%bl		# multiply Y by current depth (into AH)
	xchg	%edx,%eax		# store Y' into DH, get X into AL
	sub	%bl,%al		# curve X by the current depth
	jc	W		# if left of the curve, jump to "sky"
	mul	%bl		# multiply X by current depth (into AH)
	mov	%dh,%al		# get Y' in AL (now AL,AH = Y',X')
	or	%ah,%al		# OR for geometry and texture pattern
	lea	(%ebx,%esi),%edx	# get (current depth) + (current frame count) in DX (DL)
	inc	%ebx		# (increment depth by one)
	and	%dl,%al		# mask geometry/texture by time shifted depth...
	test	$16,%al		# ... to create "gaps"
	jz	L		# if ray did not hit, repeat pixel loop
	jmp	Q		# jump over the sky ^^
W:
	mov	$27,%al		# is both the star color and palette offset into sky
	add	%cl,%dl		# pseudorandom multiplication leftover DL added to
	jz	Q		# truncated pixel count, 1 in 256 chance to be a star *
A:
	shld	$4,%cx,%ax	# if not, shift the starcolor and add scaled pixel count
Q:
	mov	$0x0C,%ah	# AH = 0xC sets a pixel when int 10h is called
	loopw	B		# repeat for 64k pixels
	inc	%esi		# increment frame counter
#	jmp	next_frame	# rinse and repeat



	#================================
	# WRITE_STDOUT
	#================================
	# eax = syscall
	# ebx = stdout (1)
	# ecx = pointer
	# edx = length

write_stdout:
        push    $SYSCALL_WRITE          # put 4 in eax (write syscall)
        pop     %eax                    # in 3 bytes of code

        xor     %ebx,%ebx               # put 1 in ebx (stdout)
        inc     %ebx                    # in 3 bytes of code

	mov	$out_buffer,%ecx
	mov	$65536,%edx

	int     $0x80             	# and exit

	#================================
	# Exit
	#================================
exit:
	xor     %ebx,%ebx
	xor	%eax,%eax
	inc	%eax	 		# put exit syscall number (1) in eax
	int     $0x80             	# and exit



	##############################
	# num_to_ascii
	##############################
	# ax = value to print
	# edi points to where we want it

num_to_ascii:
	push    $10
	pop     %ebx
	xor     %ecx,%ecx       # clear ecx
div_by_10:
	cdq                     # clear edx
	div     %ebx            # divide
	push    %edx            # save for later
	inc     %ecx            # add to length counter
	or      %eax,%eax       # was Q zero?
	jnz     div_by_10       # if not divide again

write_out:
	pop     %eax            # restore in reverse order
	add     $0x30, %al      # convert to ASCII
	stosb                   # save digit
	loop    write_out       # loop till done
	ret

#===========================================================================
#	section .data
#===========================================================================
.data

#============================================================================
#	section .bss
#============================================================================
.bss

.lcomm	out_buffer,65536

#.lcomm	disk_buffer,4096	# we cheat!!!!



