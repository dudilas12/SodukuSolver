IDEAL
MODEL small
STACK 0FFFh
DATASEG
	startscreen db 'h.bmp',0
	notboldv db 'vnotbold.bmp',0
	notboldy db 'ynotbold.bmp',0
	notboldx db 'xnotbold.bmp',0
	boldx db 'xbold.bmp',0
	boldy db 'ybold.bmp',0
	boldv db 'vbold.bmp',0
	stop db 'stop.bmp',0
	restorep db 'restore.bmp',0
	clear db 'clear.bmp',0
	zero db 'zero.bmp',0
	enterp db 'enter.bmp',0
	input db 'input.bmp',0
	empty db 'empty.bmp',0
	yshowp db 'show.bmp',0
	nshowp db 'hide.bmp',0
	startp db 'start.bmp',0
	one db 'one.bmp',0
	two db 'two.bmp',0
	three db 'three.bmp',0
	four db 'four.bmp',0
	five db 'five.bmp',0
	six db 'six.bmp',0
	seven db 'seven.bmp',0
	eight db 'eight.bmp',0
	nine db 'nine.bmp',0
	numspos db 'numspos.bmp',0
	board db 'board.bmp',0
	file dw,0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine dw 320 dup (0)
	ErrorMsg db 'Error', 13, 10 ,'$'
	xlen dw 320
	ylen dw 200
	pos dw ?
	cell_arr dd 81 dup (0)
	restore dd 81 dup(0)
	cell_x dw ?
	cell_y dw ?
	cell_pos dw ?
	index dw ?
	cell_num db ?
	num_to_set db ?
	cell_state db ?
	state_to_set db ?
	in_row db 0
	in_col db 0
	in_box db 0
	start_row_index dw 0
	start_col_index dw 0
	start_box_index dw 0
	given_cell_num db ?
	given_cell_state db ?
	given_cell_index dw ?
	
	;soduku solving
	soduku_index dw ?
	solved db 0
	is_valid db 0
	soduku_counter dw 0
	
	Clock equ es:6Ch
	
	show db 0
	startb db 0
	
	print db 81 dup(0)
	
	inputx dw 1
	inputy dw 1
	inputv dw 0
;uj
CODESEG

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	proc OpenFile
		; Open file
		mov ah, 3Dh
		xor al, al
		mov dx, [file]
		int 21h
		jc openerror
		mov [filehandle], ax
		ret
		openerror :
		mov dx, offset ErrorMsg
		mov ah, 9h
		int 21h
		ret
		endp OpenFile
	proc ReadHeader
		; Read BMP file header, 54 bytes
		mov ah,3fh
		mov bx, [filehandle]
		mov cx,54
		mov dx,offset Header
		int 21h
		ret
	endp ReadHeader
	
	proc ReadPalette
		; Read BMP file color palette, 256 colors * 4 bytes (400h)
		mov ah,3fh
		mov cx,400h
		mov dx,offset Palette
		int 21h
	ret
	endp ReadPalette

	proc CopyPal
		; Copy the colors palette to the video memory
		; The number of the first color should be sent to port 3C8h
		; The palette is sent to port 3C9h
		mov si,offset Palette
		mov cx,256
		mov dx,3C8h
		mov al,0
		; Copy starting color to port 3C8h
		out dx,al
		; Copy palette itself to port 3C9h
		inc dx
		PalLoop:
		; Note: Colors in a BMP file are saved as BGR values rather than RGB .
		mov al,[si+2] ; Get red value .
		shr al,2 ; Max. is 255, but video palette maximal
		; value is 63. Therefore dividing by 4.
		out dx,al ; Send it .
		mov al,[si+1] ; Get green value .
		shr al,2
		out dx,al ; Send it .
		mov al,[si] ; Get blue value .
		shr al,2
		out dx,al ; Send it .
		add si,4 ; Point to next color .
		; (There is a null chr. after every color.)

		loop PalLoop
		ret
	endp CopyPal
	
	
	proc CopyBitmap
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,[ylen]
	PrintBMPLoop :
	push cx
	dec cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	mov dx,[pos]
	add di,dx

	; Read one line
	mov ah,3fh
	mov cx,[xlen]
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[xlen]
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop cx
	loop PrintBMPLoop
	ret
	endp CopyBitmap
	
	
	
	
	
	proc closefile 
     mov bx, [word ptr filehandle]
     mov ah,3eh
     int 21h
     jc error_closefil_12
     ret
     error_closefil_12:
     stc
     ret
endp closefile


	;this proc gets the xlen, the ylen, the first pos, the file of the picture
	;and prints it on the screen
	proc print_pic
		
		call OpenFile
		call ReadHeader
		call ReadPalette
		call CopyPal
		call CopyBitmap
		call closefile
	ret
	endp print_pic
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
		
		
		
		
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	proc print_board
		mov [xlen],200
		mov [ylen],200
		mov [file], offset board
		mov [pos],0
		call print_pic
	ret
	endp print_board
	
	proc print_startscreen
		mov [xlen],320
		mov [ylen],200
		mov [file], offset startscreen
		mov [pos],0
		call print_pic
		ret
	endp print_startscreen
	
	proc print_numspos
		mov [xlen],200
		mov [ylen],200
		mov [file], offset numspos
		mov [pos],0
		call print_pic
	ret
	endp print_numspos
	
	
	proc print_num
		mov [xlen],16
		mov [ylen],16
		mov bx,[index]
		mov ax,[bx]
		mov [pos],ax
		call print_pic
		ret
	endp print_num
	
	proc print_show
		mov [xlen],120
		mov [ylen],32
		mov [pos],200
		mov [file], offset yshowp
		call print_pic
		ret
	endp print_show
	
	proc print_hide
		mov [xlen],120
		mov [ylen],32
		mov [pos],200
		mov [file], offset nshowp
		call print_pic
		ret
	endp print_hide
	
	proc print_start
		mov [xlen],120
		mov [ylen],32
		mov [pos],10440;320*32+200
		mov [file], offset startp
		call print_pic
		ret
	endp print_start
	
	proc print_empty
		mov ax,[index]
		mov bx,4
		mul bx
		mov bx,ax
		add bx, offset cell_arr
		mov ax,[bx]
		
		mov [xlen],16
		mov [ylen],16
		mov [pos],ax
		mov [file], offset empty
		call print_pic
		ret
	endp print_empty
	
	proc print_input
		mov [xlen],120
		mov [ylen],32
		mov [pos],53960;320*168+200
		mov [file], offset input
		call print_pic
		ret
	endp print_input
	
	proc print_input_x
		mov [xlen],16
		mov [ylen],16
		mov [pos],56528;320*168+200 + 8*320 +8
		call print_pic
		ret
	endp print_input_x
	
	proc print_input_y
		mov [xlen],16
		mov [ylen],16
		mov [pos],56568;320*168+200 + 8*320 +48
		call print_pic
		ret
	endp print_input_y
	
	proc print_input_v
		mov [xlen],16
		mov [ylen],16
		mov [pos],56608;320*168+200 + 8*320 +88
		call print_pic
		ret
	endp print_input_v
	
	
	proc print_enter
		mov [xlen],120
		mov [ylen],32
		mov [pos],43720;320*168+200
		mov [file], offset enterp
		call print_pic
		ret
	endp print_enter
	
	proc print_clear
		mov [xlen],120
		mov [ylen],24
		mov [pos],20680;320*168+200
		mov [file], offset clear
		call print_pic
		ret
	endp print_clear
	
	proc print_restore
		mov [xlen],120
		mov [ylen],24
		mov [pos],28360;320*168+200
		mov [file], offset restorep
		call print_pic
		ret
	endp print_restore
	
	proc print_stop
		mov [xlen],120
		mov [ylen],24
		mov [pos],36040;320*168+200
		mov [file], offset stop
		call print_pic
		ret
	endp print_stop
	
	proc print_boldx
		mov [xlen],40
		mov [ylen],32
		mov [pos],53960;320*168+200
		mov [file], offset boldx
		call print_pic
		ret
	endp print_boldx
	
	proc print_boldy
		mov [xlen],40
		mov [ylen],32
		mov [pos],54000;320*168+200
		mov [file], offset boldy
		call print_pic
		ret
	endp print_boldy
	
	proc print_boldv
		mov [xlen],40
		mov [ylen],32
		mov [pos],54040;320*168+200
		mov [file], offset boldv
		call print_pic
		ret
	endp print_boldv
		
	proc print_notboldx
		mov [xlen],40
		mov [ylen],32
		mov [pos],53960;320*168+200
		mov [file], offset notboldx
		call print_pic
		ret
	endp print_notboldx
	
	proc print_notboldy
		mov [xlen],40
		mov [ylen],32
		mov [pos],54000;320*168+200
		mov [file], offset notboldy
		call print_pic
		ret
	endp print_notboldy
	
	proc print_notboldv
		mov [xlen],40
		mov [ylen],32
		mov [pos],54040;320*168+200
		mov [file], offset notboldv
		call print_pic
		ret
	endp print_notboldv
	
	
	
	
	
	
	
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	
	
	 
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	proc print_cells
		xor cx,cx
		print_cells_loop:
			push cx
			mov [index],cx
			mov bx,[index]
			add bx, offset print
			call get_state_by_index
			cmp [cell_state],0
			je fin_print_cells
			;jmp dont_print_current_cell
			
			print_current_cell:
				call print_num_in_index
				;jmp fin_print_cells
			;dont_print_current_cell:
				;mov [word ptr bx],0
				;call print_empty

			fin_print_cells:
				pop cx
				inc cx
				cmp cx,81
				jne print_cells_loop
	
	

	
	ret
	endp print_cells
	
	proc print_num_in_index
		
		call get_num_by_index
		mov bx,[index]
		add bx, offset print
		mov ax,4
		mul [index]
		mov [index],ax
		add [index], offset cell_arr
		
		xor ah,ah
		mov al,[cell_num]
		
		;cmp [byte ptr bx],0
		;jne print_num_in_index_sec 
		;jmp find_num
		
		;print_num_in_index_sec:
			;jmp fin_print_num_in_index_dont
			
		find_num:
			cmp ax,1
			je found_one
			cmp ax,2
			je found_two
			cmp ax,3
			je found_three
			cmp ax,4
			je found_four
			cmp ax,5
			je found_five
			cmp ax,6
			je found_six
			cmp ax,7
			je found_seven
			cmp ax,8
			je found_eight
			cmp ax,9
			je found_nine
			jmp fin_print_num_in_index
			
			
			found_one:
				mov [file],offset one
				jmp fin_print_num_in_index
			found_two:
				mov [file],offset two
				jmp fin_print_num_in_index
			found_three:
				mov [file],offset three
				jmp fin_print_num_in_index
			found_four:
				mov [file],offset four
				jmp fin_print_num_in_index
			found_five:
				mov [file],offset five
				jmp fin_print_num_in_index
			found_six:
				mov [file],offset six
				jmp fin_print_num_in_index
			found_seven:
				mov [file],offset seven
				jmp fin_print_num_in_index
			found_eight:
				mov [file],offset eight
				jmp fin_print_num_in_index
			found_nine:
				mov [file],offset nine
				jmp fin_print_num_in_index
				
		
		
		
		
		
		
		
			fin_print_num_in_index:
		call print_num
			fin_print_num_in_index_dont:
			;mov [word ptr bx],1
			
		
	ret
	endp print_num_in_index
	
	
	
	proc get_num_by_index
		mov ax,4
		mul [index]
		mov bx,ax
		add bx,offset cell_arr
		add bx,2
		mov al, [byte ptr bx]
		mov [cell_num],al
		ret
	endp get_num_by_index
	
	proc set_num_by_index
		mov ax,4
		mul [index]
		mov bx,ax
		add bx,offset cell_arr
		add bx,2
		mov al, [num_to_set]
		mov [byte ptr bx],al
		ret
	endp set_num_by_index
	
	
	
	proc get_state_by_index
		mov ax,4
		mul [index]
		mov bx,ax
		add bx,offset cell_arr
		add bx,3
		mov al, [byte ptr bx]
		mov [cell_state],al
	
	ret
	endp get_state_by_index
	
	proc set_state_by_index
		mov ax,4
		mul [index]
		mov bx,ax
		add bx,offset cell_arr
		add bx,3
		mov al, [state_to_set]
		mov [byte ptr bx],al
	
	
	ret
	endp set_state_by_index
	
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	
	proc dup_in_row
		mov ax,[index]
		mov cx,9
		xor dx,dx
		div cx
		mov cx,9
		mul cx
		mov [start_row_index],ax
		
		call get_num_by_index
		mov al,[cell_num]
		mov [given_cell_num],al
		
		call get_state_by_index
		mov al,[cell_state]
		mov [given_cell_state],al
		
		push [index]
		pop [given_cell_index]
		
		mov cx,0
		cmp [given_cell_state],0
		je not_check_row
		jmp dup_in_row_loop
		
		not_check_row:
		mov cx,9
		
		mov [in_row],0
		dup_in_row_loop:
			cmp cx,9
			je fin_dup_in_row
			
			push [start_row_index]
			pop [index]
			add [index],cx
			
			mov ax,[index]
			cmp ax,[given_cell_index]
			je fin_loop_dup_in_row
			
			
			
			call get_state_by_index
			cmp [cell_state],0
			jne check_row_cell
			jmp fin_loop_dup_in_row
			
			check_row_cell:
				call get_num_by_index
				mov al,[cell_num]
				cmp al,[given_cell_num]
				jne fin_loop_dup_in_row
				
				
				mov [in_row],1
		
		
			
		
			fin_loop_dup_in_row:
				inc cx
				jmp dup_in_row_loop
	
	
		fin_dup_in_row:	
			ret 
			endp dup_in_row
		
		
		
		
	proc dup_in_col
		mov ax,[index]
		mov cx,9
		div cx
		mov [start_col_index],dx
		
		call get_num_by_index
		mov al,[cell_num]
		mov [given_cell_num],al
		
		call get_state_by_index
		mov al,[cell_state]
		mov [given_cell_state],al
		
		push [index]
		pop [given_cell_index]
		
		mov cx,0
		cmp [given_cell_state],0
		je not_check_col
		jmp dup_in_col_loop
		
		not_check_col:
		mov cx,9
		
		mov [in_col],0
		dup_in_col_loop:
			cmp cx,9
			je fin_dup_in_col
			
			push [start_col_index]
			pop [index]
			mov ax,9
			mul cx
			add [index],ax
			
			mov ax,[index]
			cmp ax,[given_cell_index]
			je fin_loop_dup_in_col
			
			
			
			call get_state_by_index
			cmp [cell_state],0
			jne check_col_cell
			jmp fin_loop_dup_in_col
			
			check_col_cell:
				call get_num_by_index
				mov al,[cell_num]
				cmp al,[given_cell_num]
				jne fin_loop_dup_in_col
				
				
				
				mov [in_col],1
		
		
			
		
			fin_loop_dup_in_col:
				inc cx
				jmp dup_in_col_loop
	
	
		fin_dup_in_col:	
			ret 
			endp dup_in_col
	
	
	proc dup_in_box
		
		mov ax,[index]
		mov cx,27
		div cx
		
		mov [start_box_index],27
		mul [start_box_index]
		mov [start_box_index],ax
		
		mov ax,[index]
		mov cx,9
		div cx
		
	    mov ax,dx
		xor dx,dx
		mov bx,3
		div bx
		
		mov bx,3
		mul bx
		add [start_box_index],ax
		

		
		call get_num_by_index
		mov al,[cell_num]
		mov [given_cell_num],al
		
		call get_state_by_index
		mov al,[cell_state]
		mov [given_cell_state],al
		
		push [index]
		pop [given_cell_index]
		
		mov cx,0
		cmp [given_cell_state],0
		je not_check_box
		jmp dup_in_box_loop
		
		not_check_box:
		mov cx,9
		
		mov [in_box],0
		dup_in_box_loop:
			cmp cx,9
			je fin_dup_in_box
			
			push [start_box_index]
			pop [index]
			mov ax,cx
			mov bx,3
			div bx

			add [index],dx
			mov dx,9
			mul dx
			add [index],ax
			
			mov ax,[index]
			cmp ax,[given_cell_index]
			je fin_loop_dup_in_box
			
			
			
			call get_state_by_index
			cmp [cell_state],0
			jne check_box_cell
			jmp fin_loop_dup_in_box
			
			check_box_cell:
				call get_num_by_index
				mov al,[cell_num]
				cmp al,[given_cell_num]
				jne fin_loop_dup_in_box
				
				
				
				mov [in_box],1
		
		
			
		
			fin_loop_dup_in_box:
				inc cx
				jmp dup_in_box_loop
	
	
		fin_dup_in_box:	
			ret 
			endp dup_in_box
	
	
	
	
	proc solve_soduku
		mov [soduku_index],0
		mov [solved],0
		
		call solve_soduku_rec
		ret
	endp solve_soduku
		
		
		
	proc solve_soduku_rec
		
		
		cmp [soduku_index],81
		je turn_solved
		jmp should_check
		
		turn_solved:
			mov [solved],1
			;call print_board
			;call print_cells
			;mov ah,1
			;int 21h
			
			
			jmp ending
			ret
			
		
		
		
		should_check:
			
			push [soduku_index]
			pop [index]
			call get_state_by_index
			cmp [cell_state],0
			je pre_solve_soduku_rec_loop
		
		
		
		inc [soduku_index]
		call solve_soduku_rec
		call update_show
		;cmp [solved],1
		;je l_solve
		dec [soduku_index]
		;l_solve:
		ret
		pre_solve_soduku_rec_loop:
			call update_show
			mov [soduku_counter],9
			push [soduku_index]
			pop [index]
			mov [state_to_set],1
			call set_state_by_index
			
		
		solve_soduku_rec_loop:
			;call frameclock
			call check_stop
			push [soduku_counter]    
			
			
			mov [in_box],0
			mov [in_row],0
			mov [in_col],0
			
			mov [is_valid],0
			mov ax,[soduku_counter]
			mov [num_to_set],al
			mov ax,[soduku_index]
			push [soduku_index]
			pop [index]
			call set_num_by_index
			
			;mov [show],0
			cmp [show],0
			je after_show_board1
			
			show_board1:
				;call frameclock
				;call print_board
				call print_cells
			
			after_show_board1:
			
			push [soduku_index]
			pop [index]
			call dup_in_row
			mov al,[in_row]
			add [is_valid],al
			
			push [soduku_index]
			pop [index]
			call dup_in_col
			mov al,[in_col]
			add [is_valid],al
			
			push [soduku_index]
			pop [index]
			call dup_in_box
			mov al,[in_box]
			add [is_valid],al
			
			cmp [is_valid],0
			je soduku_valid
			jmp fin_solve_soduku_rec_loop
			
			soduku_valid:
				inc [soduku_index]
				call solve_soduku_rec
				;call update_show
				;cmp [solved],1
				;jne fin_solve_soduku_rec_loop
				;ret
				

			fin_solve_soduku_rec_loop:
				pop [soduku_counter]
				dec [soduku_counter]
				cmp [soduku_counter],0
				jne solve_soduku_rec_loop1
				jmp fin_solve_soduku_rec
				
				solve_soduku_rec_loop1:
					jmp solve_soduku_rec_loop
				
		
		fin_solve_soduku_rec:
			push [soduku_index]
			pop [index]
			mov [state_to_set],0
			call set_state_by_index
			dec [soduku_index]	
			
			cmp [show],0
			je after_show_board2
			
			show_board2:
				;call frameclock
				call print_board
				call print_cells
			
			after_show_board2:
			ret
		endp solve_soduku_rec
		
		
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	proc frameclock
		mov ax, 40h
		mov es, ax
		mov ax, [Clock]
		FirstTick :
			cmp ax, [Clock]
			je FirstTick
			; count 0.055 sec
			mov cx, 2h ; 1x0.055sec
		DelayLoop:
			mov ax, [Clock]
			Tick :
				cmp ax, [Clock]
				je Tick
				loop DelayLoop
		ret
	endp frameclock
	
	
	 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj
	proc calc_cells_pos
		call print_numspos
		mov [cell_x],0
		mov [cell_y],1
		mov si, offset cell_arr
		mov cx,81
		cell_loop:
		push cx
		
		mov bh,0h
		mov cx,[cell_x]
		mov dx,[cell_y]
		mov ah,0Dh
		int 10h
		
		cmp al,0h
		je addarr
		jmp fin1
		
		addarr:
			pop cx
			call calc_pos
			mov ax,[cell_pos]
			mov [word ptr si],ax
			add si,4
			dec cx
			push cx
			
		
		
		
		fin1:
			
			call add_to_pos
			pop cx
			cmp cx,0
			jne cell_loop
			
		ret
	endp calc_cells_pos

	proc calc_pos
		mov ax,[cell_y]
		mov [cell_pos],320
		mul [cell_pos]
		add ax,[cell_x]
		mov [cell_pos],ax
		ret
	endp calc_pos
		
	proc add_to_pos
		cmp [cell_x],199
		jne new_col
		
		new_row:
			mov [cell_x],0
			inc [cell_y]
			jmp fin2
		
		new_col:
			inc [cell_x]
		
		
		fin2:
		ret
	endp add_to_pos
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj7

		
	proc update_start
		mov ax,3
		int 33h
		cmp bx,1
		jne dont_start
		cmp cx,400
		jb dont_start
		cmp dx,31
		jna dont_start
		cmp  dx,64
		jnb dont_start
		
		mov [startb],1
		
		dont_start:
		ret
	endp update_start
	
	proc update_show
		mov ax,3
		int 33h
		cmp bx,1
		jne dont_change_show
		cmp cx,400
		jb dont_change_show
		cmp dx,32
		ja dont_change_show
		cmp cx,520
		ja dont_show
		jmp do_show
	
		dont_show:
		call print_hide
		mov [show],0
		ret
		do_show:
		call print_show
		mov [show],1
		ret
	
		dont_change_show:
		ret
	endp update_show
	
	
	proc pressed_enter
	mov ax,3
	int 33h
	cmp bx,1
	jne dont_change_enter_sec
	cmp cx,400
	jb dont_change_enter_sec
	cmp dx,136
	jb dont_change_enter_sec
	cmp dx,168
	ja dont_change_enter_sec
	jmp change_enter
	
	dont_change_enter_sec:
		jmp dont_change_enter
	
	
	change_enter:
	;mov [inputy],2
	;mov [inputx],1
	
	mov bx,9
	mov ax,[inputy]
	dec ax
	mul bx
	add ax,[inputx]
	dec ax
	
	mov [index],ax
	cmp [inputv],0
	jne on_enter
	jmp of_enter
	
		
	on_enter:
	mov [state_to_set],1
	call set_state_by_index
	mov ax,[inputv]
	mov [num_to_set],al
	call set_num_by_index
	
	call print_board
	call print_cells
	jmp dont_change_enter
	
	of_enter:
	mov [state_to_set],0
	call set_state_by_index
	call print_board
	call print_cells
	
	
	
	
	dont_change_enter:
	ret
	endp pressed_enter
	
	
	proc update_board
	mov ax,3
	int 33h
	cmp bx,1
	jne dont_change_input_sec
	cmp cx,400
	jb dont_change_input_sec
	cmp dx,168
	jb dont_change_input_sec
	jmp change_inp
	
	dont_change_input_sec:
		jmp dont_change_input
	
	change_inp:
	
	
	push cx
	push dx
	
	
	
	cmp cx,480
	jb bold_x
	cmp cx,560
	jb bold_y
	jmp bold_v
	
	bold_x:
	call print_boldx
	mov ah, 0 
	int 16h
	sub al,'0'
	push ax
	call print_notboldx
	jmp inp_n
	
	bold_y:
	call print_boldy
	mov ah, 0 
	int 16h
	sub al,'0'
	push ax
	call print_notboldy
	jmp inp_n
	
	bold_v:
	call print_boldv
	mov ah, 0 
	int 16h
	sub al,'0'
	push ax
	call print_notboldv
	jmp inp_n
	
	
	
	
	inp_n:
	pop ax
	pop dx
	pop cx
	
	
	
	find_num1:
		cmp al,1
		je found_one1
		cmp al,2
		je found_two1
		cmp al,3
		je found_three1
		cmp al,4
		je found_four1
		cmp al,5
		je found_five1
		cmp al,6
		je found_six1
		cmp al,7
		je found_seven1
		cmp al,8
		je found_eight1
		cmp al,9
		je found_nine1
		cmp al,0
		je found_zero1
		jmp dont_change_input
	
	
	found_one1:
		mov [file],offset one
		jmp decide_board
	found_two1:
		mov [file],offset two
		jmp decide_board
	found_three1:
		mov [file],offset three
		jmp decide_board
	found_four1:
		mov [file],offset four
		jmp decide_board
	found_five1:
		mov [file],offset five
		jmp decide_board
	found_six1:
		mov [file],offset six
		jmp decide_board
	found_seven1:
		mov [file],offset seven
		jmp decide_board
	found_eight1:
		mov [file],offset eight
		jmp decide_board
	found_nine1:
		mov [file],offset nine
		jmp decide_board
	found_zero1:
		mov [file],offset zero
		jmp decide_board
	
	
	
	
	decide_board:
	xor ah,ah
	cmp cx,480
	jb board_x
	cmp cx,560
	jb board_y
	jmp board_v
	
	
	board_x:
	mov [inputx],ax;ax
	call print_input_x
	jmp fin_change_input
	

	
	board_y:
	mov [inputy],ax;ax
	call print_input_y
	jmp fin_change_input
	

	board_v:
	mov [inputv],ax
	call print_input_v
	jmp fin_change_input

	
	
	
	
	fin_change_input:
		
	
	dont_change_input:
	ret 	
	endp update_board
	
	
	proc do_clear
		mov ax,3
		int 33h
		cmp bx,1
		jne dont_clear
		cmp cx,400
		jb dont_clear
		cmp dx,64
		jb dont_clear
		cmp dx,88
		ja dont_clear
		
		
		cc:
		
		
		mov cx,0
		clear_loop:
		mov [index],cx
		mov [state_to_set],0
		call set_state_by_index
		
		
		inc cx
		cmp cx,81
		jne clear_loop
		
		call print_board
		call print_cells

		
		
		dont_clear:	
		
		ret 
	endp do_clear

	
	
	proc copy_to_restore
		mov bx,offset cell_arr
		mov si, offset restore
		mov cx,324
		copy_to_restore_loop:
		mov al,[byte ptr bx]
		mov [byte ptr si],al
		inc bx
		inc si
		loop copy_to_restore_loop
		ret
	endp copy_to_restore
	
	proc update_restore
		mov ax,3
		int 33h
		cmp bx,1
		jne dont_restore
		cmp cx,400
		jb dont_restore
		cmp dx,88
		jb dont_restore
		cmp dx,112
		ja dont_restore
		
		mov bx,offset cell_arr
		mov si, offset restore
		mov cx,324
		copy_to_restore_loop1:
		mov al,[byte ptr si]
		mov [byte ptr bx],al
		inc bx
		inc si
		loop copy_to_restore_loop1
		
		call print_board
		call print_cells
		
		
		
		
		
		
		dont_restore:
			ret 
	endp update_restore
		
		
		
	proc check_stop
		mov ax,3
		int 33h
		cmp bx,1
		jne dont_stop
		cmp cx,400
		jb dont_stop
		cmp dx,112
		jb dont_stop
		cmp dx,136
		ja dont_stop
		
		
		jmp ending
		
		
		
		dont_stop:
		ret
	endp check_stop
	

	proc do_startscreen
		call print_startscreen
		mov ah,1
		int 21h
		ret
	
	endp do_startscreen
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj7

	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;uj7
	
	start:
	mov ax, @data
	mov ds, ax
	; Graphic mode
	mov ax, 13h
	int 10h

	call do_startscreen
	
	
	mov ax,0h
	int 33h
	mov ax,1
	int 33h
	
	
	
	call print_board
	;calculate the postition of each cell in the board
	call calc_cells_pos
	
	;prints the board
	;call set_board
	call print_board
	call print_cells
	
	
	
	;mouseloop:
	;mov ax,3
	;int 33h
	;cmp bx,1
	;jne mouseloop
	;call print_board
	;call print_cells
	
	
	;;;;;;;
	main_loop:
	
	call print_restore
	call print_clear
	call print_enter
	call print_hide
	call print_start
	call print_input
	call print_stop
	
	mov [show],0
	mov [startb],0
	pre_solve_loop:
	
	call update_restore
	call do_clear
	call pressed_enter
	call update_board
	call update_show
	call update_start
	cmp [startb],0
	je pre_solve_loop
	
	
	call copy_to_restore	
	call solve_soduku

	
	ending:
	mov sp,0
	call print_board
	call print_cells
	
	
	jmp main_loop
	
	
	
	

	; Wait for key press
	mov ah,1
	int 21h
	; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
	exit :
		mov ax, 4c00h
		int 21h
	END start


