

.data
    hello:
        .asciz "Hello, assembly!\n"

.text
.global main
.align 2

main:
  stp x16, x30, [sp, #-16]!
   // Load the address of the string into register x0
  ldr x0, =hello
  bl printf

  mov x0, #41
  add x0, x0, #1 // Increment

  ldp x16, x30, [sp], 16
  ret

