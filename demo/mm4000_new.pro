pro mm4000_new, command, read=read, binary=binary, response, rec=rec
common mm4000_common, record

if (n_elements(record) eq 0) then record = '13IDC:ser2'
if (n_elements(rec) ne 0) then record=rec

cr = string('0d'xb)
command = command + cr
print, command
if (keyword_set(read)) then begin
  t = caput(record+'.TMOD','Write/Read')
  if (keyword_set(binary)) then begin
    t = caput(record+'.IFMT','Binary')
    t = caput(record+'.IDEL', -1)
  endif else begin
    t = caput(record+'.IFMT','ASCII')
    t = caput(record+'.IDEL', 13)
  endelse
  t = caput(record+'.AOUT',command)
  t = caget(record+'.NORD', n)
  if (keyword_set(binary)) then begin
     t = caget(record+'.BINP',response, max=n)
  endif else begin
     t = caget(record+'.AINP',response)
  endelse
  print,'len=', n, ', response= ', response
endif else begin
  t = caput(record+'.TMOD','Write')
  t = caput(record+'.AOUT',command)
endelse


end
