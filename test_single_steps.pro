; Program to move a motor in small steps
pro test_single_steps, motor, steps, size

  if (n_elements(steps) eq 0) then steps=400
  if (n_elements(size) eq 0) then size = 1

  t = caget(motor+'.RVAL', rval)
  t = caget(motor+'.DESC', desc, /string)
  t = caget(motor+'.RRBV', initial_rrbv)
  print
  print, 'Testing motor ' + motor + '  description="' + desc + '", initial position= ' + strtrim(initial_rrbv, 2) + ' steps=', strtrim(steps, 2)


  t0 = systime(1)
  t = caget(motor+'.RVAL', rval)
  for j=0, steps-1 do begin
    rval += size
    t = caput(motor+'.RVAL', rval, /wait)
    if ((j mod 100) eq 0) then print, 'Step='+strtrim(j,2)
  endfor
  t = caget(motor+'.RRBV', final_rrbv)
  print, 'End move, RRBV= ', final_rrbv
  print, 'Distance moved= ', final_rrbv-initial_rrbv
  elapsed_time = systime(1)-t0
  print,  'Elapsed time= ', elapsed_time
end
