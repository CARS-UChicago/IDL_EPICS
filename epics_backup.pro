pro epics_backup, request_file, save_file, timeout=timeout, retry=retry

old_timeout = cagettimeout()
old_retry = cagetretrycount()

if (n_elements(timeout) eq 0) then timeout=.01
if (n_elements(retry) eq 0) then retry=5
casettimeout, timeout
casetretrycount, retry

openr, request_lun, request_file, /get
openw, save_lun, save_file, /get

line = ""
while (not eof(request_lun)) do begin
    ; Read next line from input file
    readf, request_lun, line
    ; If the first character in the line is a # then skip (comment)
    if (strpos(line, "#") eq 0) then goto, skip
    ; pvname is the first string on the input line, up to a blank if any
    pvname = (str_sep(line, ' ', /trim))[0]
    status = caget(pvname, value)
    if (status eq 0) then begin
        printf, save_lun, pvname, ' ', value
    endif else begin
        printf, save_lun, '#', pvname, ' NOT FOUND'
    endelse
    skip:
endwhile
free_lun, request_lun
free_lun, save_lun
casettimeout, old_timeout
casetretrycount, old_retry
end
