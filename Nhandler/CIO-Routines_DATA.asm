
cio_relocate100			
RELOC_SCREEN_KEYBOARD_DEV	.WORD	SCREEN_KEYBOARD_DEV

cio_relocate101			
RELOC_WAITING			.WORD 	WAITING

cio_relocate102			
RELOC_WAIT_BUFFER		.WORD	WAIT_BUFFER

cio_relocate103			
RELOC_HEX_BUFFER		.WORD	HEX_BUFFER

   	
SCREEN_KEYBOARD_CHANNEL 	.BYTE 	$FF   	
SCREEN_KEYBOARD_DEV: 		.BYTE 	'E:',$9B
HEX_BUFFER:			.BYTE 	$00,$00
HEX_ENDING:			.BYTE 	$9B
EOL_ENDING			.BYTE 	$9B
WAITING				.BYTE 	'press RETURN to continue',$9B
WAIT_BUFFER			.DS	WAIT_BUFSIZE

										