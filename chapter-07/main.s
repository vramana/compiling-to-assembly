.section .data
hello_string:
    .asciz "Hello, World\n"   // Null-terminated string

    .balign 4
message:
    .asciz "This is a message from ARM Linux\n"   // Null-terminated string

    .balign 4

.global main
.section .text
main:
    // Save the frame pointer and link register
    stp x29, x30, [sp, #-16]! // Create stack frame
    mov x29, sp               // Set frame pointer

    // Set up the arguments for printf
    ldr x0, =hello_string     // First argument: pointer to the string
    // Call printf
    bl printf                 // Branch to printf

    ldr x0, =message     // First argument: pointer to the string
    // Call printf
    bl printf                 // Branch to printf

    // Restore the frame pointer and link register
    ldp x29, x30, [sp], #16   // Restore stack frame
    ret                       // Return from main

