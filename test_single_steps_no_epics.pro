; Program to move a motor in single steps with direct socket communication, no EPICS
pro test_single_steps_no_epics, ip_address, axis, steps
  if (n_elements(steps) eq 0) then steps=400

  ks = 1
  wait_time = .1
  socket, lun, /get_lun, ip_address, 23
  printf, lun, 'MT' + axis + '=-2'  ; Motor type -2
  printf, lun, 'KS' + axis + '=' + strtrim(ks,2)  ; Step smoothing 16
  printf, lun, 'LD' + axis + '=3'  ; Disable both limits
    
  print
  print, 'Testing motor ' + axis + ' steps=', strtrim(steps, 2)

  t0 = systime(1)
  if (steps gt 0) then step=1 else step=-1
  step = strtrim(step,2)
  for j=0, abs(steps)-1 do begin
    printf, lun, 'IP' + axis + '=' + step
    wait, wait_time
    if ((j mod 100) eq 0) then print, 'Step='+strtrim(j,2)
  endfor
  elapsed_time = systime(1)-t0
  print,  'Elapsed time= ', elapsed_time
end
