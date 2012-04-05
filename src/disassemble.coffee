# From https://gist.github.com/2300590

hex = (n) ->
  "0x" + n.toString(16)

module.exports = (code, PC) ->
  operand = (bits) ->
    reg_names = [ "A", "B", "C", "X", "Y", "Z", "I", "J" ]
    return reg_names[bits]  if bits <= 0x07
    return "[" + reg_names[bits - 0x08] + "]"  if bits <= 0x0f
    return "[" + hex(code[++PC]) + " + " + reg_names[bits - 0x10] + "]"  if bits <= 0x17
    switch bits
      when 0x18
        return "POP"
      when 0x19
        return "PEEK"
      when 0x1a
        return "PUSH"
      when 0x1b
        return "SP"
      when 0x1c
        return "PC"
      when 0x1d
        return "O"
      when 0x1e
        return "[" + hex(code[++PC]) + "]"
      when 0x1f
        return hex(code[++PC])
    hex bits - 0x20

  basic_op = [ "SET", "ADD", "SUB", "MUL", "DIV", "MOD", "SHL", "SHR", "AND", "BOR", "XOR", "IFE", "IFN", "IFG", "IFB" ]
  inst = code[PC]
  if (inst & 0xf) is 0
    "JSR " + operand(inst >> 10)  if ((inst >> 4) & 0x3f) is 0x01
  else
    basic_op[inst & 0xf - 1] + " " + operand((inst >> 4) & 0x3f) + ", " + operand(inst >> 10)