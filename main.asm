
;
;====================================================================
;	- Trabalho de Programação 3
;====================================================================
;
	.model		small
	.stack
		
CR		equ		0dh
LF		equ		0ah
UN		equ		240d
LN		equ		0Fh


	.data
FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleSrc	dw		0				; Handler do arquivo origem
FHSrcNoEx	dw		0				; Handler do arquivo origem sem extensao
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo

MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgPedeArquivoDst	db	"Nome do arquivo destino: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgBytes		db	"Bytes: ", 0
MsgSoma			db	"Soma: ", 0
MsgCRLF			db	CR, LF, 0
MsgSpc			db	" ", 0
MsgTest			db	" This is a test ", 0
char_aux		db	0	;caracter menos significativo
conta_4			db	0	
ult_col			db	0
col1			db	0
col2			db	0
col3			db	0
col4			db	0
flags_aux		db	0
conta_byte		db	0
buff_dl			db	0


MAXSTRING	equ		200
String	db		MAXSTRING dup (?)		; Usado na funcao gets

	.code
	.startup

	;GetFileNameSrc();	// Pega o nome do arquivo de origem -> FileNameSrc
	call	GetFileNameSrc

	;if (fopen(FileNameSrc)) {
	;	printf("Erro na abertura do arquivo.\r\n")
	;	exit(1)
	;}
	;FileHandleSrc = BX
	lea		dx,FileNameSrc
	call	fopen
	mov		FileHandleSrc,bx
	jnc		Continua1
	lea		bx, MsgErroOpenFile
	call	printf_s
	.exit	1
Continua1:

	;GetFileNameDst();	// Pega o nome do arquivo de origem -> FileNameDst
	call	GetFileNameDst
	
	;if (fcreate(FileNameDst)) {
	;	fclose(FileHandleSrc);
	;	printf("Erro na criacao do arquivo.\r\n")
	;	exit(1)
	;}
	;FileHandleDst = BX
	lea		dx,FileNameDst
	call	fcreate
	mov		FileHandleDst,bx
	jnc		Continua2
	mov		bx,FileHandleSrc
	call	fclose
	lea		bx, MsgErroCreateFile
	call	printf_s
	.exit	1
Continua2:

	;do {
	;	if ( (CF,DL,AX = getChar(FileHandleSrc)) ) {
	;		printf("");
	;		fclose(FileHandleSrc)
	;		fclose(FileHandleDst)
	;		exit(1)
	;	}
	mov		bx,FileHandleSrc
	call	getChar
	jnc		Continua3
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc
	call	fclose
	mov		bx,FileHandleDst
	call	fclose
	.exit	1
Continua3:
	;	if (AX==0) break;
	cmp		ax,0
	jz		TerminouArquivo
	cmp		dl,0Dh	;Checa se eh CR
	jz		Continua3_1
	cmp		dl,0Ah	;Checa se eh LF
	jz		Continua3_1
	cmp		dl,20h	;Checa se eh caracter visivel
	jb		Continua4
	cmp		dl,7Eh
	ja		Continua4
Continua3_1:
	inc		conta_byte
	mov		char_aux, dl
	and		dl, UN	;Colocar o upper nibble em baixo
	SHR		dl,1
	SHR		dl,1
	SHR		dl,1
	SHR		dl,1
	cmp		dl,10d	;Checa se o nibble eh A-F
	jb		Continua3_2
	add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua3_2:
	add		dl, 30h	;Se for um numero de 0-9, soma so 30
	mov		bx,FileHandleDst
	call		setChar
	mov		dl, char_aux ;Insere novamente td o valor em dl
	and		dl, LN	;Limpa o upper nibble
	cmp		dl, 10d	;Checa se o nibble eh A-F
	jb		Continua3_3
	add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua3_3:
	add		dl, 30h	;Se for um numero de 0-9, soma so 30
Continua4:
	;	if ( setChar(FileHandleDst, DL) == 0) continue;
	mov		bx,FileHandleDst
	call	setChar
	LAHF	
	mov	flags_aux, AH	;Coloca as flags do setChar em flags_aux
	inc	conta_4
	cmp	conta_4,04d	;Se for o caracter multiplo de 4...
	jnz	Continua4_1	
	mov	conta_4,0d	;Zera o contador
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
	mov	dl, char_aux
	add	col4, dl	;Adiciona esse valor no somatorio da coluna 4
	mov	ult_col,4		
Continua4_1:
	cmp	conta_4,03d	;Se for o caracter multiplo de 4...
	jnz	Continua4_2	
	mov	dl, char_aux
	add	col3, dl	;Adiciona esse valor no somatorio da coluna 6
	mov	ult_col,3
	jmp	Continua5
Continua4_2:
	cmp	conta_4,02d	;Se for o caracter multiplo de 4...
	jnz	Continua4_3	
	mov	dl, char_aux
	add	col2, dl	;Adiciona esse valor no somatorio da coluna 2
	mov	ult_col,2
	jmp	Continua5
Continua4_3:
	cmp	conta_4,01d	;Se for o caracter multiplo de 4...
	jnz	Continua5	
	mov	dl, char_aux
	add	col1, dl	;Adiciona esse valor no somatorio da coluna 1
	mov	ult_col,1
Continua5:
	mov	AH, flags_aux
	sahf
	jnc		Continua2	

	;	printf ("Erro na escrita....;)")
	;	fclose(FileHandleSrc)
	;	fclose(FileHandleDst)
	;	exit(1)
	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandleSrc		; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	.exit	1
	
	;} while(1);
		
TerminouArquivo:
	;Printa o contador de bytes na tela
	lea		bx, MsgBytes
	call		printf_s	
	mov		dl, conta_byte
	and		dl, UN	;Colocar o upper nibble em baixo
	SHR		dl,1
	SHR		dl,1
	SHR		dl,1
	SHR		dl,1
	add		dl, 30h	;Se for um numero de 0-9, soma so 30
	mov 		ah,2
	int		21h
	mov		dl, conta_byte ;Insere novamente td o valor em dl
	and		dl, LN	;Limpa o upper nibble
	add		dl, 30h	;Se for um numero de 0-9, soma so 30
	mov 		ah,2
	int		21h
	lea		bx, MsgCRLF
	call	printf_s
	
	;Printa o valor da soma
	lea		bx, MsgSoma
	call	printf_s
	

	cmp	ult_col	,4d	;Se for o caracter multiplo de 4...
	jne	Continua6_0	
	mov	ult_col,00d	;Zera o contador
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
Continua6_0:
	mov		dl,'0'	;Printa 0 antes de cada nibble
	mov		bx,FileHandleDst
	call		setChar
	mov 	dl, col1
		and		dl, UN	;Colocar o upper nibble em baixo
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		cmp		dl,10d	;Checa se o nibble eh A-F
		jb		Continua6_1
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_1:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
			inc 	ult_col
			cmp	ult_col	,4d	;Se for o caracter multiplo de 4...
			jne	Continua6_1_1	
			mov	ult_col,00d	;Zera o contador
			mov	dl,0Dh
			mov	bx,FileHandleDst	
			call	setChar		;Coloca CR no arquivo
			mov	dl,0Ah
			mov	bx,FileHandleDst
			call	setChar		;Coloca LF no arquivo
Continua6_1_1:
		mov		dl,'0'	;Printa 0 antes de cada nibble
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, col1;Insere novamente td o valor em dl
		and		dl, LN	;Limpa o upper nibble
		cmp		dl, 10d	;Checa se o nibble eh A-F
		jb		Continua6_2
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_2:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		;	if ( setChar(FileHandleDst, DL) == 0) continue;
		mov		buff_dl, dl
		mov		bx,FileHandleDst
		call	setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
		lea		bx, MsgSpc
		call	printf_s
		


	inc	ult_col	
	cmp	ult_col	,04h	;Se for o caracter multiplo de 4...
	jne	Continua6_2_0	
	mov	ult_col	,0d	;Zera o contador
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
Continua6_2_0:
	mov		dl,'0'	;Printa 0 antes de cada nibble
	mov		bx,FileHandleDst
	call		setChar
	mov 	dl, col2
		and		dl, UN	;Colocar o upper nibble em baixo
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		cmp		dl,10d	;Checa se o nibble eh A-F
		jb		Continua6_3
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_3:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		mov		bx,FileHandleDst
		call		setChar

			inc ult_col
			cmp	ult_col	,04h	;Se for o caracter multiplo de 4...
			jne	Continua6_3_1	
			mov	ult_col,0d	;Zera o contador
			mov	dl,0Dh
			mov	bx,FileHandleDst	
			call	setChar		;Coloca CR no arquivo
			mov	dl,0Ah
			mov	bx,FileHandleDst
			call	setChar		;Coloca LF no arquivo
Continua6_3_1:
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
		mov		dl,'0'	;Printa 0 antes de cada nibble
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, col2;Insere novamente td o valor em dl
		and		dl, LN	;Limpa o upper nibble
		cmp		dl, 10d	;Checa se o nibble eh A-F
		jb		Continua6_4
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_4:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		;	if ( setChar(FileHandleDst, DL) == 0) continue;
		mov		bx,FileHandleDst
		call	setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
		lea		bx, MsgSpc
		call	printf_s




	inc	ult_col
	cmp	ult_col	,04h	;Se for o caracter multiplo de 4...
	jne	Continua6_4_0	
	mov	ult_col	,0d	;Zera o contador
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
Continua6_4_0:
	mov		dl,'0'	;Printa 0 antes de cada nibble
	mov		bx,FileHandleDst
	call		setChar
	mov 	dl, col3
		and		dl, UN	;Colocar o upper nibble em baixo
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		cmp		dl,10d	;Checa se o nibble eh A-F
		jb		Continua6_5
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_5:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h

			inc ult_col
			cmp	ult_col	,4d	;Se for o caracter multiplo de 4...
			jne	Continua6_5_1	
			mov	ult_col,00d	;Zera o contador
			mov	dl,0Dh
			mov	bx,FileHandleDst	
			call	setChar		;Coloca CR no arquivo
			mov	dl,0Ah
			mov	bx,FileHandleDst
			call	setChar		;Coloca LF no arquivo
Continua6_5_1:
		mov		dl,'0'	;Printa 0 antes de cada nibble
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, col3;Insere novamente td o valor em dl
		and		dl, LN	;Limpa o upper nibble
		cmp		dl, 10d	;Checa se o nibble eh A-F
		jb		Continua6_6
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_6:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		;	if ( setChar(FileHandleDst, DL) == 0) continue;
		mov		bx,FileHandleDst
		call	setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
		lea		bx, MsgSpc
		call	printf_s

	inc	ult_col
	cmp	ult_col	,04h	;Se for o caracter multiplo de 4...
	jne	Continua6_6_0
	mov	ult_col,00d	;Zera o contador
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
Continua6_6_0:

	mov		dl,'0'	;Printa 0 antes de cada nibble
	mov		bx,FileHandleDst
	call		setChar
	mov 	dl, col4
		and		dl, UN	;Colocar o upper nibble em baixo
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		SHR		dl,1
		cmp		dl,10d	;Checa se o nibble eh A-F
		jb		Continua6_7
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_7:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h
			inc ult_col
			cmp	ult_col	,4d	;Se for o caracter multiplo de 4...
			jne	Continua6_7_1	
			mov	ult_col,00d	;Zera o contador
			mov	dl,0Dh
			mov	bx,FileHandleDst	
			call	setChar		;Coloca CR no arquivo
			mov	dl,0Ah
			mov	bx,FileHandleDst
			call	setChar		;Coloca LF no arquivo
Continua6_7_1:

		mov		dl,'0'	;Printa 0 antes de cada nibble
		mov		bx,FileHandleDst
		call		setChar
		mov		dl, col4;Insere novamente td o valor em dl
		and		dl, LN	;Limpa o upper nibble
		cmp		dl, 10d	;Checa se o nibble eh A-F
		jb		Continua6_8
		add		dl, 7h	;Se for, soma 7h p pegar o codigo ascii correspondente
Continua6_8:
		add		dl, 30h	;Se for um numero de 0-9, soma so 30
		mov		buff_dl, dl
		;	if ( setChar(FileHandleDst, DL) == 0) continue;
		mov		bx,FileHandleDst
		call	setChar
		mov		dl, buff_dl
		mov 		ah,2
		int		21h



	;fclose(FileHandleSrc)
	;fclose(FileHandleDst)
	;exit(0) 
	mov		bx,FileHandleSrc	; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst	; Fecha arquivo destino
	call	fclose
	.exit	0

		
;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de origem salva-o em FileNameSrc
;--------------------------------------------------------------------
GetFileNameSrc	proc	near
	;printf("Nome do arquivo origem: ")
	lea		bx, MsgPedeArquivoSrc
	call	printf_s

	;gets(FileNameSrc);
	lea		bx, FileNameSrc
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameSrc	endp


;--------------------------------------------------------------------
;Monta o nome do arquivo de saida a partir da entrada e add .res no fim
;--------------------------------------------------------------------
GetFileNameDst	proc	near

	lea		bx, FileNameDst

	;Pega nome do arquivo s extensao
	lea si, FileNameSrc
	lea di, FileNameDst
	cpy_nxt:
		mov bl,[si]
		cmp bl,'.' ;Add teste de caracter de fim de str
		je fim_string
		mov [di],bl
		inc si
		inc di
		jmp cpy_nxt
	fim_string:	;Encontro o ponto, add .res no nome
		mov	byte ptr es:[di],'.'
		inc	di
		mov	byte ptr es:[di],'r'
		inc	di
		mov	byte ptr es:[di],'e'
		inc	di
		mov	byte ptr es:[di],'s'
		inc	di	
	ret
GetFileNameDst	endp

;--------------------------------------------------------------------
;Função	Abre o arquivo cujo nome está no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arq uivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Função Cria o arquivo cujo nome está no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Função	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp
		
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; Lê uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp

;====================================================================
; A partir daqui, estão as funções já desenvolvidas
;	1) printf_s
;====================================================================
	
;--------------------------------------------------------------------
;Função Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp


;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------


	




