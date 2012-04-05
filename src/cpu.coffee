module.exports = class DCPU
  OP_REG = 1
  OP_MEM = 2
  OP_PC  = 3
  OP_SP  = 4
  OP_OV  = 5
  OP_LIT = 6
  constructor: (mem = new ArrayBuffer(0x10000 * 2)) ->
    @memory = new Uint16Array(mem)
    @registers = [0, 0, 0, 0, 0, 0, 0, 0]
    @pc = 0 # Program Counter
    @sp = 0xFFFF # Stack Pointer
    @ov = 0 # Overflow
    @skip = false
  
  step: ->
    pcv = @memory[@pc++]
    op = pcv & 0xF
    if op is 0
      switch (pcv >> 4) & 0x3F
        when 0x01
          if @skip
            @skip = false
          else
            @memory[--@sp] = @pc
          return
        else
          throw new Error("Invalid opcode #{pcv.toString(16)}")
    a = (pcv >> 4) & 0x3F
    av = @decode(a)
    b = pcv >> 10
    bv = @decode(b)
    switch op
      when 0x1
        res = @read(bv)
      when 0x2
        res = @read(av) + @read(bv)
      when 0x3
        res = @read(av) - @read(bv)
      when 0x4
        res = @read(av) * @read(bv)
      when 0x5
        abv = @read(bv)
        res = if abv then @read(av) / abv else 0
      when 0x6
        abv = @read(bv)
        res = if abv then @read(av) % abv else 0
      when 0x7
        res = @read(av) << @read(bv)
      when 0x8
        res = @read(av) >> @read(bv)
      when 0x9
        res = @read(av) & @read(bv)
      when 0xA
        res = @read(av) | @read(bv)
      when 0xB
        res = @read(av) ^ @read(bv)
      when 0xC
        @skip = @read(av) != @read(bv)
      when 0xD
        @skip = @read(av) == @read(bv)
      when 0xE
        @skip = @read(av) <= @read(bv)
      when 0xF
        @skip = (@read(av) & @read(bv)) == 0
      else
        throw new Error("Invalid opcode #{pcv.toString(16)}")
    if res?
      if @skip
        @skip = false
      else
        @write(av, res)
        @ov = res >> 16

  decode: (op) ->
    switch
      when op < 0x08
        [OP_REG, op]
      when op < 0x10
        [OP_MEM, @registers[op]]
      when op < 0x18
        [OP_MEM, @memory[@pc++] + @registers[op]]
      when op is 0x18
        [OP_MEM, @sp++]
      when op is 0x19
        [OP_MEM, @sp]
      when op is 0x1A
        [OP_MEM, --@sp]
      when op is 0x1B
        [OP_SP]
      when op is 0x1C
        [OP_PC]
      when op is 0x1D
        [OP_OV]
      when op is 0x1E
        [OP_MEM, @memory[@pc++]]
      when op is 0x1f
        [OP_MEM, @pc++]
      else
        [OP_LIT, op - 0x20]

  read: (op) ->
    [op, val] = op
    switch op
      when OP_MEM
        @memory[val]
      when OP_REG
        @registers[val]
      when OP_PC
        @pc
      when OP_SP
        @sp
      when OP_OV
        @ov
      when OP_LIT
        val
  write: (op, value) ->
    [op, val] = op
    switch op
      when OP_MEM
        @memory[val] = value
      when OP_REG
        @registers[val] = value
      when OP_PC
        @pc = value
      when OP_SP
        @sp = value
      when OP_OV
        @ov = value