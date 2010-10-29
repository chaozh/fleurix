puts %{
; generated by intr.S.rb
; do not edit

[section .text]
[global _hwint_restore_regs]
[extern hwint_common]

;; 
;; this routine is called on each isr & irq is raised. store the current cpu state on the kernel stack.
;; kernel stack is pointed by the esp0 field inside tss.
;; 
;; the routine _int_restore_regs is just called from *swtch*. 
_hwint_common_stub:
    pusha
    push dword ds
    push dword es
    push dword fs
    push dword gs
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, esp
    push eax                        ; esp is just the pointer to struct regs *.
    mov eax, hwint_common
    call eax
    pop eax                         ; esp ignored
_hwint_restore_regs:
    pop dword gs
    pop dword fs
    pop dword es
    pop dword ds
    popa
    add esp, 8
    sti
    iret

}

NINT = 128
0.upto(NINT) do |i|
  puts %{
    _hwint#{i}:
      cli
      #{'push  dword 0' if i!=17 and (i<8 or i>14)}
      push  dword #{i}
      jmp   _hwint_common_stub
  }
end

# generate the vector table
puts %{
; vector table
[section .data]
[global  _hwint]

_hwint:
}
0.upto(NINT) do |i|
  puts "  dd _hwint#{i}"
end
