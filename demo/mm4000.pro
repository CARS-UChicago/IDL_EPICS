pro mm4000, command, response, rec=rec
common mm4000_common, record

if (n_elements(record) eq 0) then record = '13LAB:gpib1'
if (n_elements(rec) ne 0) then record=rec

cr = string('0d'xb)
command = command + cr
print, command
if (n_elements(response) ne 0) then begin
  t = caput(record+'.TMOD','Write/Read')
  t = caput(record+'.AOUT',command)
  t = caget(record+'.AINP',response)
  print,response
endif else begin
  t = caput(record+'.TMOD','Write')
  t = caput(record+'.AOUT',command)
endelse

end
