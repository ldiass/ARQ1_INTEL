
;
;====================================================================
;	- Trabalho de Programa��o 3
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
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo

MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgPedeArquivoDst	db	"Nome do arquivo destino: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF			db	CR, LF, 0
char_aux		db	0	;caracter menos significativo
conta_4			db	0	
col1			db	0
col2			db	0
col3			db	0
col4			db	0
flags_aux		db	0


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
	jnz	Continua5	
	mov	conta_4,0d	;Zera o contado
	mov	dl,0Dh
	mov	bx,FileHandleDst	
	call	setChar		;Coloca CR no arquivo
	mov	dl,0Ah
	mov	bx,FileHandleDst
	call	setChar		;Coloca LF no arquivo
	add	col4, char_aux	;Adiciona esse valor no somatorio da coluna 4
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
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst
;--------------------------------------------------------------------
GetFileNameDst	proc	near
	;printf("Nome do arquivo destino: ");
	lea		bx, MsgPedeArquivoDst
	call	printf_s
	
	;gets(FileNameDst);
	lea		bx, FileNameDst
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameDst	endp

;--------------------------------------------------------------------
;Fun��o	Abre o arquivo cujo nome est� no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
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
;Fun��o Cria o arquivo cujo nome est� no string apontado por DX
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
;Fun��o	Le um caractere do arquivo identificado pelo HANLDE BX
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

	mov		ah,0ah						; L� uma linha do teclado
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
; A partir daqui, est�o as fun��es j� desenvolvidas
;	1) printf_s
;====================================================================
	
;--------------------------------------------------------------------
;Fun��o Escrever um string na tela
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


	



