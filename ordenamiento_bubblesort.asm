.data
array:   .word 77, 22, 11, 44, 99, 33, 55, 88, 66, 11  # Arreglo de enteros a ordenar
N:      .word 10                                     # Tamaño del arreglo (10 elementos)
newline: .asciiz "\n"                                 # Carácter de nueva línea para imprimir

.text
.globl main

main:
    # --- Configuración inicial ---
    la   $a0, array     # Carga la dirección base del arreglo en $a0 (puntero al arreglo)
    lw   $a1, N         # Carga el tamaño N del arreglo en $a1

    jal  bubbleSort     # Llama a la subrutina bubbleSort

    # --- Imprimir el arreglo ordenado ---
    la   $s0, array     # Vuelve a cargar la dirección base del arreglo en $s0 para imprimir
    lw   $s1, N         # Carga el tamaño N en $s1
    li   $s2, 0         # $s2 = i (contador para el bucle de impresión)

print_loop:
    beq  $s2, $s1, exit_print_loop  # Si i == N, sale del bucle de impresión

    sll  $t0, $s2, 2        # $t0 = i * 4 (calcula el offset en bytes)
    add  $t1, $s0, $t0      # $t1 = dirección_base + offset (dirección de array[i])
    lw   $a0, 0($t1)        # Carga array[i] en $a0 para imprimir
    li   $v0, 1             # Servicio para imprimir un entero
    syscall

    li   $v0, 4             # Servicio para imprimir una cadena
    la   $a0, newline       # Carga la dirección del carácter de nueva línea
    syscall

    addi $s2, $s2, 1        # i++
    j    print_loop         # Salta de nuevo al bucle de impresión

exit_print_loop:
    # --- Finalizar el programa ---
    li   $v0, 10            # Código de servicio para salir del programa
    syscall

# -----------------------------------------------------------------------
# Subrutina bubbleSort(int arr[], int n)
# Argumentos:
#   $a0: dirección base del arreglo (arr)
#   $a1: tamaño del arreglo (n)
#
# Registros usados y salvados (convención):
#   $s0: n (tamaño del arreglo)
#   $s1: i (contador del bucle externo)
#   $s2: j (contador del bucle interno)
#   $s3: dirección base del arreglo
#   $ra: dirección de retorno (salvado por jal y restaurado antes de jr)
# -----------------------------------------------------------------------
bubbleSort:
    addi $sp, $sp, -20      # Reserva espacio en la pila para 5 registros ($s0-$s3, $ra)
    sw   $s0, 0($sp)        # Guarda $s0 en la pila
    sw   $s1, 4($sp)        # Guarda $s1 en la pila
    sw   $s2, 8($sp)        # Guarda $s2 en la pila
    sw   $s3, 12($sp)       # Guarda $s3 en la pila
    sw   $ra, 16($sp)       # Guarda $ra (dirección de retorno) en la pila

    move $s0, $a1           # $s0 = n (copia el tamaño del arreglo)
    move $s3, $a0           # $s3 = dirección base del arreglo (arr)

    li   $s1, 0             # Inicializa i = 0 (bucle externo)

outer_loop:
    # Condición del bucle externo: for (i < n - 1)
    subi $t0, $s0, 1        # $t0 = n - 1
    bge  $s1, $t0, end_outer_loop # Si i >= n - 1, termina el bucle externo (sale)

    li   $s2, 0             # Inicializa j = 0 (bucle interno)

inner_loop:
    # Condición del bucle interno: for (j < n - i - 1)
    sub  $t0, $s0, $s1      # $t0 = n - i
    subi $t0, $t0, 1        # $t0 = n - i - 1
    bge  $s2, $t0, end_inner_loop # Si j >= n - i - 1, termina el bucle interno (sale)

    # --- Acceso a arr[j] ---
    sll  $t1, $s2, 2        # $t1 = j * 4 (offset en bytes para arr[j])
    add  $t2, $s3, $t1      # $t2 = dirección de arr[j]
    lw   $t3, 0($t2)        # $t3 = arr[j]

    # --- Acceso a arr[j+1] ---
    addi $t1, $t1, 4        # $t1 = (j + 1) * 4 (offset en bytes para arr[j+1])
    add  $t5, $s3, $t1      # $t5 = dirección de arr[j+1]
    lw   $t6, 0($t5)        # $t6 = arr[j+1]

    # --- Comparación: if (arr[j] > arr[j+1]) ---
    ble  $t3, $t6, end_if   # Si arr[j] <= arr[j+1], no hay intercambio, salta a end_if

    # --- Intercambio (Swap) ---
    # temp = arr[j] (ya está en $t3)
    # arr[j] = arr[j+1]
    sw   $t6, 0($t2)        # Almacena arr[j+1] ($t6) en la posición de arr[j] ($t2)

    # arr[j+1] = temp
    sw   $t3, 0($t5)        # Almacena arr[j] ($t3) en la posición de arr[j+1] ($t5)

end_if:
    addi $s2, $s2, 1        # j++ (incrementa el contador del bucle interno)
    j    inner_loop         # Salta de nuevo al inicio del bucle interno

end_inner_loop:
    addi $s1, $s1, 1        # i++ (incrementa el contador del bucle externo)
    j    outer_loop         # Salta de nuevo al inicio del bucle externo

end_outer_loop:
    # --- Restaurar registros y retornar ---
    lw   $s0, 0($sp)        # Restaura $s0 de la pila
    lw   $s1, 4($sp)        # Restaura $s1 de la pila
    lw   $s2, 8($sp)        # Restaura $s2 de la pila
    lw   $s3, 12($sp)       # Restaura $s3 de la pila
    lw   $ra, 16($sp)       # Restaura $ra de la pila
    addi $sp, $sp, 20       # Libera el espacio en la pila
    jr   $ra                # Regresa al llamador (main)