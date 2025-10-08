.data
    memory: .space 1024
    maxSize: .long 1024
    O: .space 4
    N: .space 4
    case: .space 4
    temp1: .space 4
    temp2: .space 4
    file_name: .space 4

    inputFormat: .asciz "%d"
    outputFormat1: .asciz "(%d, %d)\n"
    outputFormat2: .asciz "%d: (%d, %d)\n"
.text

move_0_to_end:
    # primeste (vector, start, end)
    push %ebp
    mov %esp, %ebp

    push %edi
    push %ebx
    mov 8(%ebp), %edi
    mov 12(%ebp), %ecx 
    mov 16(%ebp), %edx 
    dec %edx 

move_0_to_end_loop:
    cmp %ecx, %edx 
    je move_0_to_end_exit
    
    movb (%edi, %ecx, 1), %al
    inc %ecx 
    movb (%edi, %ecx, 1), %bl
    movb %al, (%edi, %ecx, 1)
    dec %ecx
    movb %bl, (%edi, %ecx, 1)
    
    inc %ecx
    jmp move_0_to_end_loop

move_0_to_end_exit:
    pop %ebx
    pop %edi 
    pop %ebp
    ret   
# move_0_to_end

delete_file:
    # primeste (vector, id, start, end)
    push %ebp
    mov %esp, %ebp

    push %edi
    push %ebx
    mov 8(%ebp), %edi 
    mov 12(%ebp), %eax
    mov 16(%ebp), %ecx
    mov 20(%ebp), %edx
    xor %ebx, %ebx
delete_loop:
    cmp %ecx, %edx 
    je delete_loop_end

    cmpb (%edi, %ecx, 1), %al 
    jne delete_1
    movb %bl, (%edi, %ecx, 1)

delete_1:
    inc %ecx 
    jmp delete_loop
    
delete_loop_end:
    pop %ebx
    pop %edi 
    pop %ebp 
    ret
# delete_loop

find_space:
    # primeste (vector, size, start, end)
    push %ebp
    mov %esp,  %ebp 
    sub $4, %esp

    push %ebx
    push %edi

    mov 8(%ebp), %edi 
    mov 12(%ebp), %eax
    mov %eax, -4(%ebp)
    mov 16(%ebp), %ecx 
    mov 20(%ebp), %edx 

    mov $-1, %eax

find_space_loop:
    cmp %ecx, %edx 
    je find_space_loop_exit_false

    cmp $-1, %eax
    jne find_space_loop_1
    movb (%edi, %ecx, 1), %bl
    cmpb $0, %bl
    jne find_space_loop_1
    mov %ecx, %eax
find_space_loop_1:

    cmp $-1, %eax
    je find_space_loop_2
    movb (%edi, %ecx, 1), %bl
    cmpb $0, %bl
    jne find_space_loop_2
    
    mov %ecx, %ebx
    sub %eax, %ebx
    inc %ebx
    cmp -4(%ebp), %ebx
    je find_space_loop_exit_true
find_space_loop_2:

    movb (%edi, %ecx, 1), %bl
    cmpb $0, %bl
    je find_space_loop_3
    mov $-1, %eax
find_space_loop_3:
    
    inc %ecx
    jmp find_space_loop

find_space_loop_exit_false:
    mov $-1, %eax 
find_space_loop_exit_true:
    pop %edi 
    pop %ebx 
    add $4, %esp
    pop %ebp
    ret
# find_space

fill_space:
    # primeste (vector, id, start, end)
    push %ebp
    mov %esp, %ebp 

    push %edi
    mov 8(%ebp), %edi
    mov 12(%ebp), %al 
    mov 16(%ebp), %ecx
    mov 20(%ebp), %edx 

fill_space_loop:
    cmp %edx, %ecx 
    jg fill_space_exit

    movb %al, (%edi, %ecx, 1)

    inc %ecx
    jmp fill_space_loop
fill_space_exit: 
    pop %edi 
    pop %ebp
    ret
# fill_space

get_byID:
    # primeste (vector, id, start, end)
    push %ebp
    mov %esp, %ebp 
    
    push %edi
    push %ebx
    mov 8(%ebp), %edi 
    mov 12(%ebp), %eax 
    movb %al, %bl
    mov 16(%ebp), %ecx
    mov 20(%ebp), %edx

    mov $-1, %eax 
get_byID_loop:
    cmp %ecx, %edx
    je get_byID_loop_exit

    cmp $-1, %eax 
    jne get_byID_loop_1
    cmpb (%edi, %ecx, 1), %bl
    jne get_byID_loop_1
    mov %ecx, %eax
get_byID_loop_1:

    cmp $-1, %eax
    je get_byID_loop_2
    cmp (%edi, %ecx, 1), %bl 
    je get_byID_loop_2
    jmp get_byID_loop_exit
get_byID_loop_2:

    inc %ecx 
    jmp get_byID_loop
get_byID_loop_exit:
    dec %ecx
    pop %ebx
    pop %edi
    pop %ebp
    ret
# get_byID

AFISARE_ACTIV:
    # primeste (vector, start, end )
    push %ebp
    mov %esp, %ebp 

    push %edi
    push %ebx 
    xor %ebx, %ebx
    mov 8(%ebp), %edi 
    mov 12(%ebp), %ecx 
    mov 16(%ebp), %edx
    xor %eax, %eax

AFISARE_ACTIV_loop:
    cmp %ecx, %edx
    je AFISARE_ACTIV_loop_exit

    cmpb (%edi, %ecx, 1), %bl
    je AFISARE_ACTIV_loop_2

    cmpb $0, %bl
    jne AFISARE_ACTIV_loop_1
    movb (%edi, %ecx, 1), %bl 
    mov %ecx, %eax
    jmp AFISARE_ACTIV_loop_2

AFISARE_ACTIV_loop_1:
    dec %ecx
    push %edx
    push %ecx
    push %eax
    push %ebx
    push $outputFormat2
    call printf 
    add $4, %esp
    pop %ebx 
    pop %eax
    pop %ecx
    pop %edx
    inc %ecx

    movb (%edi, %ecx, 1), %bl
    cmp $0, %bl
    je AFISARE_ACTIV_loop_2
    mov %ecx, %eax

AFISARE_ACTIV_loop_2:
    inc %ecx
    jmp AFISARE_ACTIV_loop

AFISARE_ACTIV_loop_exit:
    dec %ecx
    cmpb $0, %bl 
    je AFISARE_ACTIV_edge_case
    push %ecx
    push %eax
    push %ebx 
    push $outputFormat2
    call printf
    add $16, %esp

AFISARE_ACTIV_edge_case: 
    pop %ebx 
    pop %edi
    pop %ebp 
    ret
# AFISARE_ACTIV

.global main

ADD:
    push $N 
    push $inputFormat
    call scanf
    add $8, %esp 

    xor %ecx, %ecx 
ADD_loop:
    cmp N, %ecx 
    je ADD_loop_exit
    push %ecx
    
    push $temp1
    push $inputFormat 
    call scanf 
    add $8, %esp 
    push $temp2 
    push $inputFormat
    call scanf
    add $8, %esp 

    mov temp1, %eax 
    mov %eax, file_name

    xor %edx, %edx 
    mov temp2, %eax 
    mov $8, %ecx
    div %ecx

    cmp $0, %edx
    je ADD_loop_1
    inc %eax
ADD_loop_1:
    cmp $2, %eax 
    jge ADD_loop_2 
    mov $2, %eax

ADD_loop_2:
   
   # file_name -> id-ul fisierului
   # eax -> size-ul fisierului
   # Implementam functia search care returneaza in eax si ecx un interval inchis cu spatiul necesar
   # daca in %eax e returnat -1 atunci spunem ca nu are spatiu si returnam (0, 0)
    push maxSize
    push $0
    push %eax 
    push $memory
    call find_space
    add $16, %esp 

    cmp $-1, %eax 
    jne ADD_loop_F   

    # Caz nu gasim spatiu afisam id: (0, 0)
    push $0
    push $0
    push file_name
    push $outputFormat2
    call printf
    add $16, %esp 
    jmp ADD_loop_FN
ADD_loop_F:
    # Caz ca gasim spatiu -> dam fill dupa afisam
    push %ecx
    push %eax 
    push file_name
    push $memory
    call fill_space
    add $8, %esp 
    pop %eax
    pop %ecx

    push %ecx
    push %eax
    push file_name
    push $outputFormat2
    call printf
    add $16, %esp
ADD_loop_FN:

    pop %ecx
    inc %ecx
    jmp ADD_loop

ADD_loop_exit:
    jmp ADD_COMEBACK 

GET:
    push $temp1 
    push $inputFormat
    call scanf
    add $8, %esp

    # functie care primeste vectorul ca parametru cu maxsize si returneaza in eax si ecx intervalul acelui numar
    # daca eax e -1 la intoarcere inseamna ca nu a fost gasit un astfel de interval    
    push maxSize
    push $0
    push temp1
    push $memory
    call get_byID
    add $16, %esp 

    cmp $-1, %eax 
    jne GET_1

    push $0
    push $0
    push $outputFormat1
    call printf
    add $12, %esp
    jmp GET_2
GET_1:
    push %ecx
    push %eax 
    push $outputFormat1
    call printf
    add $12, %esp
GET_2:
    jmp GET_COMEBACK

DELETE:
    push $temp1
    push $inputFormat
    call scanf
    add $8, %esp

    push maxSize
    push $0
    push temp1
    push $memory
    call delete_file
    add $16, %esp

    push maxSize
    push $0
    push $memory
    call AFISARE_ACTIV
    add $12, %esp
    jmp DELETE_COMEBACK

DEFRAGMENTATION:
    xor %ecx, %ecx 

DEFRAGMENTATION_loop:
    # idee pentru cand ma intorc
    # in loc sa fac asa pot verifica daca nu mai este niciun 0 de mutat facand
    # get 0 si daca raspunsul are eax -1 sau ecx -> maxSize -1 inseamna ca ori nu exista 0
    # ori toti 0 se afla la sfarsitul vectorului
    push %ecx
    push maxSize
    push $0
    push $0
    push $memory
    call get_byID
    add $16, %esp
    mov %ecx, %edx 
    pop %ecx
    
    cmp $-1, %eax 
    je DEFRAGMENTATION_loop_exit
    inc %edx 
    cmp maxSize, %edx
    je DEFRAGMENTATION_loop_exit


    xor %eax, %eax
    cmpb (%edi, %ecx, 1), %al
    jne DEFRAGMENTATION_loop_1
    push maxSize
    push %ecx 
    push %edi 
    call move_0_to_end
    pop %edi 
    pop %ecx
    add $4, %esp
    dec %ecx 

DEFRAGMENTATION_loop_1:
    inc %ecx
    jmp DEFRAGMENTATION_loop

DEFRAGMENTATION_loop_exit:
    push maxSize
    push $0
    push $memory
    call AFISARE_ACTIV
    add $12, %esp
    jmp DEFRAGMENTATION_COMEBACK

main:
    mov $memory, %edi 

    push $O 
    push $inputFormat
    call scanf
    add $8, %esp

    xor %ecx, %ecx 
main_loop:
    cmp O, %ecx 
    je main_loop_exit

    push %ecx 
    push $case 
    push $inputFormat
    call scanf 
    add $8, %esp

    mov case, %ebx 
    cmp $1, %ebx
    je ADD
ADD_COMEBACK:
    cmp $2, %ebx
    je GET 
GET_COMEBACK:
    cmp $3, %ebx 
    je DELETE 
DELETE_COMEBACK:
    cmp $4, %ebx 
    je DEFRAGMENTATION
DEFRAGMENTATION_COMEBACK:
    
    pop %ecx
    inc %ecx 
    jmp main_loop
    
main_loop_exit:
    pushl $0
    call fflush
    popl %eax
    
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
