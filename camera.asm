; Author:  Samantha Caneer

.386

.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE debug.h
INCLUDE sqrt.h
INCLUDE io.h

CR      EQU     0dh     ; carriage return character
LF      EQU     0ah     ; line feed

.STACK  4096

.DATA

; declare the variables

eye_x       WORD    ?
eye_y       WORD    ?
eye_z       WORD    ?

at_x        WORD    ?
at_y        WORD    ?
at_z        WORD    ?

up_x        WORD    ?
up_y        WORD    ?
up_z        WORD    ?

n_x         WORD    ?
n_y         WORD    ?
n_z         WORD    ?

space       BYTE CR, LF, 0

string  BYTE    40 DUP (?)

first_par   WORD    "("
last_par    WORD    ")"
comma       WORD    ","
slash       WORD    "/"
sp1         WORD    " "


ndotn 		WORD	?
ndotn1    WORD  ?
ndotn2    WORD  ?
ndotn3    WORD  ?

v_up_dotn 		WORD	?
v_up_dotn1    WORD  ?
v_up_dotn2    WORD  ?
v_up_dotn3    WORD  ?


v1        WORD  ?
v2        WORD  ?
v3        WORD  ?

u1        WORD  ?
u2        WORD  ?
u3        WORD  ?

temp1     WORD  ?
temp2     WORD  ?
temp3     WORD  ?

u_length  WORD  ?
v_length  WORD  ?
n_length  WORD  ?

eyexprompt      BYTE    "Enter the x-coordinate of the camera eyepoint:  ", 0
eyeyprompt      BYTE    "Enter the y-coordinate of the camera eyepoint:  ", 0
eyezprompt      BYTE    "Enter the z-coordinate of the camera eyepoint:  ", 0

at_xprompt      BYTE    "Enter the x-coordinate of the camera at point:   ", 0
at_yprompt      BYTE    "Enter the y-coordinate of the camera at point:   ", 0
at_zprompt      BYTE    "Enter the z-coordinate of the camera at point:   ", 0

up_xprompt      BYTE    "Enter the x-coordinate of the camera up point:   ", 0
up_yprompt      BYTE    "Enter the y-coordinate of the camera up point:   ", 0
up_zprompt      BYTE    "Enter the z-coordinate of the camera up point:   ", 0


display        		BYTE    50 DUP (?), 0 ; the text to display in (x, y, z) format
output_u        	BYTE    "u: ", 0
output_v          BYTE    "v: ", 0
output_n          BYTE    "n: ", 0

							; define the end of line

.CODE

macro_for_IO MACRO prompt1, prompt2, prompt3, x1, x2, x3
                  macro_for_Coordinate prompt1, x1
                  macro_for_Coordinate prompt2, x2
                  macro_for_Coordinate prompt3, x3

                  macro_for_printing_Point x1, x2, x3
                ENDM

macro_for_Coordinate    MACRO   prompt, var

                ;output  prompt          ; prompt for number
                ;input   string, 40      ; read ASCII characters
                ;atod    string          ; convert to integer
                ;mov     var, ax         ; store in memory
                ;mov     ax, 0
                inputW prompt, var
                output space

            ENDM

macro_for_printing_Point  MACRO   xvar, yvar, zvar

                output space
                output first_par
                output sp1
                itoa text, xvar
                output text
                output comma
                output sp1
                itoa text, yvar
                output text
                output comma
                output sp1
                itoa text, zvar
                output text
                output last_par
                output space


            ENDM

printNormPoint  MACRO  xvar, yvar, zvar, len

                output space
                output first_par
                output sp1
                itoa text, xvar
                output text
                output slash
                itoa text, len
                output text
                output comma
                output sp1
                itoa text, yvar
                output text
                output slash
                itoa text, len
                output text
                output comma
                output sp1
                itoa text, zvar
                output text
                output slash
                itoa text, len
                output text
                output last_par
                output space

            ENDM

; computes the dot product of two vectors
; if something is wrong, insert more variables so as not to overwrite x1, y1, z1
dot_product MACRO   x1, y1, z1, x2, y2, z2, x3, y3, z3, result

            mov ax, x1
            mov bx, x2
            imul bx
            mov x3, ax

            mov ax, y1
            mov bx, y2
            imul bx
            mov y3, ax

            mov ax, z1
            mov bx, z2
            imul bx
            mov z3, ax

            mov ax, x3
            add ax, y3
            add ax, z3
            mov result, ax

            ENDM

; computes the cross product of two vectors
cross_product MACRO   x1, y1, z1, x2, y2, z2, x3, y3, z3, tempx, tempy

; key:
; x1 = a_x, y1 = a_y, z1 = a_z
; x2 = b_x, y2 = b_y, z2 = b_z
; x3, y3, z3 = resulting vector

            mov ax, y1
            mov bx, z2
            imul bx
            mov  tempx, ax

            mov ax, z1
            mov bx, y2
            imul bx
            mov tempy, ax

            mov ax, tempx
            ;mov bx, tempy
            sub ax, tempy
            neg ax
            mov x3, ax

            ; calculate 1st coordinate ^

            mov ax, z1
            mov bx, x2
            imul bx
            mov tempx, ax

            mov ax, x1
            mov bx, z2
            imul bx
            mov tempy, ax

            mov ax, tempx
            ;mov bx, tempy
            sub ax, tempy
            neg ax
            mov y3, ax

            ; calculate 2nd coordinate ^

            mov ax, x1
            mov bx, y2
            imul bx
            mov tempx, ax

            mov ax, y1
            mov bx, x2
            imul bx
            mov tempy, ax

            mov ax, tempx
            ;mov bx, tempy
            sub ax, tempy
            neg ax
            mov z3, ax

            ; calculate 3rd coordinate ^


            ENDM

; performs point-point subtraction to obtain a vector
point_subtract MACRO x1, y1, z1, x2, y2, z2, vx, vy, vz

              mov ax, x1
              sub ax, x2
              mov vx, ax

              mov ax, y1
              sub ax, y2
              mov vy, ax

              mov ax, z1
              sub ax, z2
              mov vz, ax

               ENDM

; performs point-vector addition to obtain a new point
point_vector_add MACRO vx, vy, vz, xn, yn, zn, x, y, z

              mov ax, vx
              add ax, xn
              mov x, ax

              mov ax, vy
              add ax, yn
              mov y, ax

              mov ax, vz
              add ax, zn
              mov z, ax

                ENDM

compute_n MACRO a_x, a_y, a_z, b_x, b_y, b_z, x_r, y_r, z_r

      point_subtract a_x, a_y, a_z, b_x, b_y, b_z, x_r, y_r, z_r

            ENDM

vector_length	MACRO x1, y1, z1, x2, y2, z2, x3, y3, z3, length

        dot_product x1, y1, z1, x2, y2, z2, x3, y3, z3, length
        sqrt length
        mov length, ax

                ENDM

normalize       MACRO x, y, z, length

        mov ax, x
        mov bx, length
        idiv bx
        mov x, ax

        mov ax, y
        mov bx, length
        idiv bx
        mov y, ax

        mov ax, z
        mov bx, length
        idiv bx
        mov z, ax

                ENDM




_start:

          macro_for_IO eyexprompt, eyeyprompt, eyezprompt, eye_x, eye_y, eye_z
          output space
          macro_for_IO at_xprompt, at_yprompt, at_zprompt, at_x, at_y, at_z
          output space
          macro_for_IO up_xprompt, up_yprompt, up_zprompt, up_x, up_y, up_z
          output space

          ; calculate n
          compute_n eye_x, eye_y, eye_z, at_x, at_y, at_z, n_x, n_y, n_z

          ; define ndotn
          dot_product up_x, up_y, up_z, n_x, n_y, n_z, v_up_dotn1, v_up_dotn2, v_up_dotn3, v_up_dotn

          ; find (n.n)v = -(vup.n)n + (n.n)vup
          mov ax, v_up_dotn
          mov bx, n_x
          imul bx
          neg ax
          mov v_up_dotn1, ax

          mov ax, v_up_dotn
          mov bx, n_y
          imul bx
          neg ax
          mov v_up_dotn2, ax

          mov ax, v_up_dotn
          mov bx, n_z
          imul bx
          neg ax
          mov v_up_dotn3, ax

          ; compute (n.n)vup

          dot_product n_x, n_y, n_z, n_x, n_y, n_z, ndotn1, ndotn2, ndotn3, ndotn

          mov ax, ndotn
          mov bx, up_x
          imul bx
          mov ndotn1, ax

          mov ax, ndotn
          mov bx, up_y
          imul bx
          mov ndotn2, ax

          mov ax, ndotn
          mov bx, up_z
          imul bx
          mov ndotn3, ax


          ; compute -(vup.n)n and add to previous

          point_vector_add v_up_dotn1, v_up_dotn2, v_up_dotn3, ndotn1, ndotn2, ndotn3, v1, v2, v3

          ; calculate cross_product of v and n to get u

          cross_product n_x, n_y, n_z, v1, v2, v3, u1, u2, u3, temp1, temp2
          ;dot_product

          ; calculate the vector lengths of u, v and n

          vector_length u1, u2, u3, u1, u2, u3, temp1, temp2, temp3, u_length
          vector_length v1, v2, v3, v1, v2, v3, temp1, temp2, temp3, v_length
          vector_length n_x, n_y, n_z, n_x, n_y, n_z, temp1, temp2, temp3, n_length

          ;normalize u1, u2, u3, u_length
          ;normalize v1, v2, v3, v_length
          ;normalize n_x, n_y, n_z, n_length

          output space
          output space
          output output_u
          printNormPoint u1, u2, u3, u_length
          output output_v
          printNormPoint v1, v2, v3, v_length
          output output_n
          printNormPoint n_x, n_y, n_z, n_length
          ;macro_for_printing_Point  n_x, n_y, n_z

          ;printNormPoint u1, u2, u3, u_length



        INVOKE  ExitProcess, 0  ; exit with return code 0

PUBLIC _start                   ; make entry point public

END                             ; end of source code
