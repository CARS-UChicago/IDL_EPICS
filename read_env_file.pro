pro read_env_file, file, pvnames, descriptions

openr, lun, file, /get

line = ""
pvnames = ""
descriptions = ""
while (not eof(lun)) do begin
    ; Read next line from input file
    readf, lun, line
    ; If the first character in the line is a # then skip (comment)
    if (strpos(line, "#") eq 0) then goto, skip
    ; PV name is before blank, description is after
    pos = strpos(line, " ")
    if (pos eq -1) then begin
        pvname = line
        description = ""
        parse_record_name, pvname, pv, field
        status = caget(pv+'.DESC', description)
    endif else begin
        pvname = strmid(line, 0, pos)
        description = strmid(line, pos, 100)
    endelse
    status = caget(pvname, value)
    if (status eq 0) then begin
        print, pvname, ' ', description, ' ', value
        pvnames = [pvnames, pvname]
        descriptions = [descriptions, description]
    endif else begin
        print, pvname, ' ', description, ' NOT FOUND'
    endelse
    skip:
endwhile
free_lun, lun
pvnames = pvnames[1:*]
descriptions = descriptions[1:*]
end
