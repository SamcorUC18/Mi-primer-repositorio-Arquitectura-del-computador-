.data 		#parte donde estan los datos
holamundo: .asciiz "hola mundo \n"

.text		#parte donde estan los codigos
li $v0, 4
la $a0, holamundo
syscall 

li   $v0, 10
syscall 
