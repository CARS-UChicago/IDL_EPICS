pro epics_restore, save_file

openr, save_lun, save_file, /get

line = ""
while (not eof(save_lun)) do begin
    ; Read next line from save file
    readf, save_lun, line
    ; If the first character in the line is a # then skip (comment)
    if (strpos(line, "#") eq 0) then goto, skip
    ; pvname is the first string on the input line
    pos = strpos(line, ' ')
    if (pos le 0) then goto, skip  ; This line has PV but no value
    pvname = strmid(line, 0, pos)
    value = strmid(line, pos+1, 1000)
    status = caput(pvname, value)
    if (status ne 0) then begin
        print, 'Unable to restore ', pvname
    endif
    skip:
endwhile
free_lun, save_lun
end
