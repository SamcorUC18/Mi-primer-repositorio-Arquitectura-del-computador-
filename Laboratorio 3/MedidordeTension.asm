.data
    # Direcciones de memoria mapeadas para los registros del dispositivo de tensi�n arterial
    TensionControl:  .word 0x10000010 # Ejemplo de direcci�n para el registro de control
    TensionEstado:   .word 0x10000014 # Ejemplo de direcci�n para el registro de estado
    TensionSistol:   .word 0x10000018 # Ejemplo de direcci�n para la tensi�n sist�lica
    TensionDiastol:  .word 0x1000001C # Ejemplo de direcci�n para la tensi�n diast�lica

    # Mensajes para la salida 
    msg_inicio_medicion: .asciiz "Iniciando medici�n de tensi�n arterial...\n"
    msg_esperando:       .asciiz "Esperando resultados de la medici�n...\n"
    msg_medicion_lista:  .asciiz "Medici�n de tensi�n completada.\n"
    msg_sistolica:       .asciiz "Tensi�n Sist�lica: "
    msg_diastolica:      .asciiz "Tensi�n Diast�lica: "
    newline:             .asciiz "\n"

.text
.globl main

main:
    # Imprimir mensaje de inicio
    li $v0, 4
    la $a0, msg_inicio_medicion
    syscall

    # Llamar al procedimiento controlador_tension
    jal controlador_tension

    # Los valores de tensi�n sist�lica y diast�lica est�n ahora en $v0 y $v1.
    # Los moveremos a registros "s" para que no se pierdan al usar $v0 para syscalls,
    move $s0, $v0 # $s0 guarda la tensi�n sist�lica
    move $s1, $v1 # $s1 guarda la tensi�n diast�lica

    # Imprimir resultados
    li $v0, 4
    la $a0, msg_medicion_lista
    syscall

    # Imprimir tensi�n sist�lica
    li $v0, 4
    la $a0, msg_sistolica
    syscall
    li $v0, 1          # C�digo para imprimir entero
    move $a0, $s0      # Cargar el valor de tensi�n sist�lica desde $s0 a $a0 para syscall
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Imprimir tensi�n diast�lica
    li $v0, 4
    la $a0, msg_diastolica
    syscall
    li $v0, 1          # C�digo para imprimir entero
    move $a0, $s1      # Cargar el valor de tensi�n diast�lica desde $s1 a $a0 para syscall
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Terminar el programa
    li $v0, 10
    syscall

# -----------------------------------------------------------------------------
# Procedimiento: controlador_tension
# Descripci�n: Inicia la medici�n, espera los resultados y los retorna.
# Retorno:
#   $v0: Valor de tensi�n sist�lica
#   $v1: Valor de tensi�n diast�lica
# -----------------------------------------------------------------------------
controlador_tension:
    # 1. Iniciar la medici�n: Escribir 1 en TensionControl
    li $t0, 1           # Carga el valor 1
    sw $t0, TensionControl # Escribe 1 en el registro de control

    # Imprimir mensaje de espera (para una mejor comprension)
    li $v0, 4
    la $a0, msg_esperando
    syscall

    # 2. Esperar a que TensionEstado tenga el valor de 1 (Polling)
wait_for_measurement:
    lw $t1, TensionEstado # Lee el valor del registro de estado
    li $t2, 0             # Carga el valor 0 para comparar
    beq $t1, $t2, wait_for_measurement # Si TensionEstado es 0, sigue esperando
    # Si llegamos aqu�, TensionEstado es 1 y los resultados est�n listos

    # 3. Leer los resultados: TensionSistol y TensionDiastol
    lw $v0, TensionSistol  # Carga el valor de la tensi�n sist�lica en $v0
    lw $v1, TensionDiastol # Carga el valor de la tensi�n diast�lica en $v1

    jr $ra # Retorna al llamador