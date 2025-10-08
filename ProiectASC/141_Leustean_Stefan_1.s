.data
    memory: .space 0x100000
    maxSize: .long 0x100000
    O: .space 4
    N: .space 4
    case: .space 4
    temp1: .space 4
    temp2: .space 4
    file_name: .space 4

    fd: .space 4
    dirstream: .space 4
    fStat: .space 200
    folder_path: .space 200
    rel_file_name: .space 4
    inputFormat: .asciz "%d"
    inputFormatChar: .asciz "%s"

    outputSingleInt: .asciz "%d\n"
    outputFormat1: .asciz "((%d, %d), (%d, %d))\n"
    outputFormat2: .asciz "%d: ((%d, %d), (%d, %d))\n"
.text

IDto_start:
    # cum e mentionat la DEFRAG_LINE primesc un start care trebuie sa-l mut la end(inclusiv) unde start > end
    # cand dau de un alt id ( / != 0) atunci ma pot opri mai devreme
    push %ebp 
    mov %esp, %ebp 

    push %edi 
    mov 8(%ebp), %edi 
    mov 12(%ebp), %ecx
    mov 16(%ebp), %edx
    xor %eax, %eax 

IDto_start_loop:
    cmp %edx, %ecx 
    je IDto_start_exit
      
    decl %ecx
    cmpb (%edi, %ecx, 1), %al
    jne IDto_start_exit

    incl %ecx
    movb (%edi, %ecx, 1), %al 
    decl %ecx
    movb %al, (%edi, %ecx, 1)
    xor %eax, %eax
    incl %ecx 
    movb %al, (%edi, %ecx, 1)
    decl %ecx

    jmp IDto_start_loop
IDto_start_exit:
    pop %edi
    pop %ebp 
    ret
# IDto_start

DEFRAG_LINE:
    # primesc (vector, start, end)
    # cred ca o s-o fac ca de fiecare data cand inalnesc un id sa-l put cat mai la stanga
    # va trebui o functie separata sa zice IDto_start(vector, start, end) !! in care start > end si e cu pas invers iar end inclusiv de aceasta data
    push %ebp
    mov %esp, %ebp 

    push %edi 
    mov 8(%ebp), %edi 
    mov 12(%ebp), %ecx 
    mov 16(%ebp), %edx 
    xor %eax, %eax 

DEFRAG_LINE_loop:
    cmp %ecx, %edx 
    je DEFRAG_LINE_exit

    cmpb (%edi, %ecx, 1), %al 
    je DEFRAG_LINE_loop_c
    
    push %eax 
    push %edx 
    push 12(%ebp)
    push %ecx 
    push %edi 
    call IDto_start
    addl $4, %esp
    pop %ecx 
    addl $4, %esp
    pop %edx 
    pop %eax

DEFRAG_LINE_loop_c:
    incl %ecx 
    jmp DEFRAG_LINE_loop

DEFRAG_LINE_exit:
    pop %edi 
    pop %ebp
    ret
# DEFRAG_LINE

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

    cmp $-1, %eax 
    je find_space_loop_4

    push %ecx 
    push %eax 
    push %edx
    mov %ecx, %eax 
    xor %edx, %edx
    mov $1024, %ecx 
    divl %ecx
    mov %edx, %ecx 
    pop %edx  
    pop %eax

    cmpl $1023, %ecx 
    jne find_space_loop_3_1
    mov $-1, %eax 
find_space_loop_3_1:
    pop %ecx 

find_space_loop_4:
    
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
    mov 12(%ebp), %eax 
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

get_nextID:
    # functie primeste (vector, start, end)
    # returneaza eax - start interval / -1, ecx - end interval, edx - file_name
    push %ebp
    mov %esp, %ebp 

    push %edi
    push %ebx 
    mov 8(%ebp), %edi
    mov 12(%ebp), %ecx
    mov 16(%ebp), %edx 

    movl $-1, %eax 
    xor %ebx, %ebx

get_nextID_loop:
    cmp %ecx, %edx 
    je get_nextID_loop_exit 

    cmp $-1, %eax 
    jne get_nextID_loop_1
    
    cmpb (%edi, %ecx, 1), %bl
    je get_nextID_loop_c

    mov %ecx, %eax 
    movb (%edi, %ecx, 1), %bl
    jmp get_nextID_loop_c

get_nextID_loop_1:
    cmpb (%edi, %ecx, 1), %bl 
    jne get_nextID_loop_exit

get_nextID_loop_c:
    incl %ecx
    jmp get_nextID_loop 

get_nextID_loop_exit:
    decl %ecx
    mov %ebx, %edx 
    pop %ebx 
    pop %edi 
    pop %ebp
    ret
# get_nextID

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

    movl %ebx, file_name
    mov %eax, %ebx
    mov %ecx, %eax 
    xor %edx, %edx
    mov $1024, %ecx
    divl %ecx 
    push %edx 
    push %eax

    mov %ebx, %eax
    xor %edx, %edx
    mov $1024, %ecx 
    divl %ecx
    push %edx 
    push %eax

    push file_name
    push $outputFormat2
    call printf
    add $24, %esp
    
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
    push $0
    push $0
    push file_name
    push $outputFormat2
    call printf
    add $24, %esp 
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

    mov %eax, %ebx
    mov %ecx, %eax 
    xor %edx, %edx
    mov $1024, %ecx
    divl %ecx 
    push %edx 
    push %eax

    mov %ebx, %eax
    xor %edx, %edx
    mov $1024, %ecx 
    divl %ecx
    push %edx 
    push %eax

    push file_name
    push $outputFormat2
    call printf
    add $24, %esp

ADD_loop_FN:

    pop %ecx
    inc %ecx
    jmp ADD_loop

ADD_loop_exit:
    jmp COMEBACK 

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
    push $0
    push $0
    push $outputFormat1
    call printf
    add $20, %esp
    jmp GET_2
GET_1:
    mov %eax, %ebx
    mov %ecx, %eax
    xor %edx, %edx 
    movl $1024, %ecx 
    div %ecx 
    push %edx
    push %eax 

    mov %ebx, %eax 
    xor %edx, %edx 
    movl $1024, %ecx 
    div %ecx
    push %edx
    push %eax 

    push $outputFormat1
    call printf
    add $20, %esp
GET_2:
    jmp COMEBACK

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
    jmp COMEBACK

DEFRAGMENTATION:
    xor %ecx, %ecx 
    movl $0, case
    # DEFRAGMENTATION IDEEA: -> defragmentez normal linia de parca ar fi unidimensional
    # caut urmt ID, si dau get de 0 pe linia curenta
    # daca ID are loc in 0 atunci da add si reface acelasi lucru 
    # daca ID nu are loc inseamna ca programu poate sa treaca la urmt linie
    # ecx o sa mearga 0 -> 1024 -> 2048 .... -> 1024x1024 - 1024
    # functii de care am nevoie: -> DEFRAG_LINE(vector, start, end) get_byID(vector, id, start, end) get_nextID(vector, start, end) AFISARE_ACTIV(vector, start, end)
    # fill_space(vector, id, start, end) delete_file(vector, id, start, end)
    # ATENTIE FILL_SPACE TREBUIE SA FIE FOLOSIT CU FIND_SPACE
    # Ca idee loop ecx 0, 1024x1024, +1024

DEFRAGMENTATION_main_loop:
    cmpl %ecx, maxSize
    je DEFRAGMENTATION_main_loop_exit

    mov %ecx, %eax  
    addl $1024, %eax 
    push %eax 
    push %ecx
    push $memory
    call DEFRAG_LINE
    add $4, %esp
    pop %ecx
    pop %eax 

    # salvez in temp1, temp2 raspunsurile la primul get_byID($memory, 0, %ecx, %eax)
    push %eax
    push %ecx 
    push $0
    push $memory
    call get_byID
    add $8, %esp
    movl %eax, temp1
    movl %ecx, temp2
    pop %ecx
    pop %eax 

    cmpl $-1, temp1
    je DEFRAGMENTATION_main_loop_continue_2
    # punem in ebx diferenta/spatiul liber

    movl temp2, %ebx 
    subl temp1, %ebx 
    incl %ebx

    movl %ecx, temp1
    movl %eax, temp2

    push maxSize
    push temp2
    push $memory
    call get_nextID # am vrea sa returneze eax - start interval, ecx - end interval si edx- filename
    add $12, %esp

    cmp $-1, %eax 
    je DEFRAGMENTATION_main_loop_exit

    movl %edx, file_name
    mov %ecx, %edx
    sub %eax, %edx
    incl %edx 

    cmp %edx, %ebx
    jl DEFRAGMENTATION_main_loop_continue
    
    movl $1, case 

    # delete_file(vector, id, start, end)
    push %edx
    incl %ecx 
    push %ecx
    push %eax 
    push file_name
    push $memory
    call delete_file
    add $16, %esp
    pop %edx

    # find_space primeste (vector, size, start, end)

    push temp2
    push temp1
    push %edx 
    push $memory
    call find_space
    add $16, %esp 

    # fill_space(vector, id, start, end)
    push %ecx
    push %eax  
    push file_name
    push $memory
    call fill_space
    add $16, %esp


DEFRAGMENTATION_main_loop_continue:
    movl temp1, %ecx
DEFRAGMENTATION_main_loop_continue_2:

    cmpl $1, case
    je DEFRAGMENTATION_main_loop_repeat
    addl $1024, %ecx

DEFRAGMENTATION_main_loop_repeat:
    movl $0, case
    jmp DEFRAGMENTATION_main_loop

DEFRAGMENTATION_main_loop_exit:
    push maxSize
    push $0
    push $memory
    call AFISARE_ACTIV
    add $12, %esp
    jmp COMEBACK

CONCRETE:
    # So o sa am un loop in care tot citesc fisiere cum e de asteptat
    # functii de care voi avea nevoie vor fi cele de la add:
    # find_space + fill_space 
    # si functia get_byID ca sa verificam existenta unui id

    # FOLOSESTE GODBOT
    # cate am inteles pana acum struct e pur si simplu un space mai mare pot sa-i dau 200
    # cand dau fstat dau adresa acestui termen
    # la +16 se afla size-ul in forma de int (4 bytes)
    # open am sa-l dau cu .string si va trebui sa-l citesc cu modul explicit
    # acel O_READONLY e defapt 0
    # si in continuare e doar folosire de functii ADD   

    # REVISION, nu merge alta idee, folosind opendir() si readdir()
    # treceme prin elementele directoriului
    # problema va fi cum sa le deschidem
    # PROPUNERE: folosim fchdir() ca sa schimbam directory-ul ca sa putem dupa deschide direct
    # cu relative name-ul si sa nu trebuiasca sa adaugam la path-ul absolut
    push $folder_path
    push $inputFormatChar
    call scanf
    add $8, %esp

    movl $12, %eax
    movl $folder_path, %ebx
    int $0x80

    xor %eax, %eax 
    push $folder_path
    call opendir
    add $4, %esp 

    mov %eax, dirstream

CONCRETE_loop:
    xor %eax, %eax 
    push dirstream
    call readdir
    add $4, %esp

    cmp $0, %eax 
    je CONCRETE_loop_exit

    mov (%eax), %ebx 
    mov 4(%eax), %ecx
    
    add $11, %eax
    mov %eax, %edi 
    
    cmpb $46, (%edi)
    je CONCRETE_loop

    movl $5, %eax 
    movl %edi, %ebx 
    movl $0, %ecx 
    movl $0777, %edx 
    int $0x80

    movl %eax, fd
    
    movl $28, %eax
    movl fd, %ebx
    mov $fStat, %ecx 
    int $0x80

    mov $fStat, %ecx 
    movl 16(%ecx), %ebx 
    movl %ebx, temp1

    movl $6, %eax # sys_close
    movl %edi, %ebx
    int $0x80

    # nu voi mai infrumuseti codu de mai sus ca de abia merge lol
    # DE TINUT MINTE
    # fd -> file descriptorul (real)
    # temp1 -> size-ul fisierului (bytes)
    # trebuie sa facem conversii
    # (real -> (fd%255 + 1))
    # (size -> bytes/1024 + min(1, bytes%1024))

    xor %eax, %eax
    xor %edx, %edx 
    movl fd, %eax 
    movl $255, fd 
    divl fd
    incl %edx
    movl %edx, fd
    # Conversia pentru fd terminata

    push fd
    push $outputSingleInt
    call printf 
    add $8, %esp 

    xor %edx, %edx 
    movl temp1, %eax 
    addl $1023, %eax 
    movl $1024, temp1 
    divl temp1 
    movl %eax, temp1
    # Conversia pentru size verificata
    cmpl $2, temp1 
    jge CONCRETE_loop_1
    movl $2, temp1  

CONCRETE_loop_1:    
    push temp1
    push $outputSingleInt
    call printf
    add $8, %esp 

    # Acum verificam daca file descriptorul exista deja sau nu folosind get_byID

    # get_byID(vector, id, start, end)
    push maxSize
    push $0
    push fd 
    push $memory
    call get_byID
    add $16, %esp 

    cmpl $-1, %eax 
    je CONCRETE_loop_2

    # CAZUL IN CARE EXISTA DEJA
    push $0
    push $0
    push $0
    push $0
    push fd
    push $outputFormat2
    call printf
    add $24, %esp
    jmp CONCRETE_loop_3

CONCRETE_loop_2:

    # CAZUL IN CARE NU EXISTA

    # find_space(vector, size, start, end)

    push maxSize
    push $0
    push temp1
    push $memory
    call find_space
    add $16, %esp 

    cmp $-1, %eax 
    jne CONCRETE_loop_2_1
    # cazul in care nu exista fd dar nu are spatiu
    push $0
    push $0
    push $0
    push $0
    push fd
    push $outputFormat2
    call printf
    add $24, %esp
    jmp CONCRETE_loop_3

CONCRETE_loop_2_1:
    # cazul complicat, exista fd si are si spatiu

    push %ecx
    push %eax 
    push fd
    push $memory
    call fill_space
    add $8, %esp 
    pop %eax
    pop %ecx

    mov %eax, %ebx
    mov %ecx, %eax 
    xor %edx, %edx
    mov $1024, %ecx
    divl %ecx 
    push %edx 
    push %eax

    mov %ebx, %eax
    xor %edx, %edx
    mov $1024, %ecx 
    divl %ecx
    push %edx 
    push %eax
    push fd
    push $outputFormat2
    call printf
    add $24, %esp

CONCRETE_loop_3:
    jmp CONCRETE_loop

CONCRETE_loop_exit:

# /home/stefanleustean/LabASC/ProiectASC/testfolder TEST_STRING
    # movl %eax, fd
    # movl $28, %eax
    # movl fd, %ebx
    # mov $fStat, %ecx 
    # int $0x80

    # mov $fStat, %edi 
    # movl 16(%edi), %ebx 
    # movl %ebx, temp1

    # movl $6, %eax # sys_close
    # movl $folder_path, %ebx
    # $0x80
    jmp COMEBACK

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
    cmp $2, %ebx
    je GET 
    cmp $3, %ebx 
    je DELETE 
    cmp $4, %ebx 
    je DEFRAGMENTATION
    cmp $5, %ebx
    je CONCRETE
COMEBACK:
    
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
