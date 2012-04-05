#!/usr/bin/env coffee

fs = require 'fs'
DCPU = require '../src/cpu'
disassemble = require '../src/disassemble'

data = fs.readFileSync (process.argv[2] || '/dev/stdin'), 'utf8'

buff = new ArrayBuffer(0x10000 * 2)
view = new Uint16Array(buff)
data.split('\n').forEach (v, i) ->
  view[i] = parseInt(v, 16)

cpu = new DCPU(buff)

pad = (n) ->
  ('0000' + n.toString(16)).slice(-4)

while true
  # console.log (if cpu.skip then "# " else "") + disassemble(cpu.memory, cpu.pc)
  console.log [cpu.pc, cpu.sp, cpu.ov, if cpu.skip then 1 else 0].concat(cpu.registers).map(pad).join ' '
  cpu.step()