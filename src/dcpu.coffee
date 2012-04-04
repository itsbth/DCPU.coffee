module.exports = class DCPU
  constructor: (mem = new ArrayBuffer(0x10000 * 2)) ->
    @memory = new Uint16Array(mem)
    @registers = [0, 0, 0, 0, 0, 0, 0, 0]
    @pc = 0 # Program Counter
    @sp = 0xFFFF # Stack Pointer
    @ov = 0 # Overflow
  
  step: ->
    pcv = @memory[@pc++]
    op = pcv & 0xF
    a = (op >> 4) & 0x3F
    av = @read(a)
    b = op >> 10
    bv = @read(b)
    switch op
      when 0x1
        res = bv
      when 0x2
        res = av + bv
      when 0x3
        res = av - bv
      when 0x4
        res = av * bv
      when 0x5
        res = if bv then av / bv else 0
      when 0x6
        res = if bv then av % bv else 0
      when 0x7
        res = av << bv
      when 0x8
        res = av >> bv
      when 0x9
        res = av & bv
      when 0xA
        res = av | bv
      when 0xB
        res = av ^ bv
      when 0xC
        @skip = av != bv
      when 0xD
        @skip = av == bv
      when 0xE
        @skip = av <= bv
      when 0xF
        @skip = (av & bv) == 0
    if res
      @write(a, res)
      @ov = res >> 16

  read: (op) ->
    switch
      when op < 0x08
        @registers[op]
      when op < 0x10
        @memory[@registers[op]]
      when op < 0x18
        @memory[@memory[@pc++] + @registers[op]]
      when op == 0x18
        @memory[@sp++]
      when op == 0x19
        @memory[@sp]
      when op == 0x1A
        @memory[--@sp]
      when op == 0x1B
        @sp
      when op == 0x1C
        @pc
      when op == 0x1D
        @ov
      when op == 0x1E
        @memory[@memory[@pc++]]
      when op == 0x1f
        @memory[@pc++]
      else
        op - 0x20
  write: (op, val) ->
    switch
      when op < 0x08
        @registers[op] = val
      when op < 0x10
        @memory[@registers[op]] = val
      when op < 0x18
        @memory[@memory[@pc++] + @registers[op]] = val
      when op == 0x18
        @memory[@sp++] = val
      when op == 0x19
        @memory[@sp] = val
      when op == 0x1A
        @memory[--@sp] = val
      when op == 0x1B
        @sp = val
      when op == 0x1C
        @pc = val
      when op == 0x1D
        @ov = val
      when op == 0x1E
        @memory[@memory[@pc++]] = val
      when op == 0x1f
        @memory[@pc++] = val