pro vme_mem_map, record

; This procedure prints a table of the VME A16 address space using the
; VME record.
;
; It requires as input the name of a VME record which must exist in the IOC to
; be tested.  For efficiency this record should have a reasonably large value
; of NMAX, but one which is smaller than the channel access transfer limit.
; 2048 is a good value to use.  The name of the record must be passed without 
; a trailing period or field name, i.e. 'test_vme1'.

; Determine maximum number of VME cycles which can be done in a single record
; processing operation
t = caget(record+'.NMAX', n)

; Set the value of NUSE (number to actually use) to this value
t = caput(record+'.NUSE', n)

; Set the address mode to A16
t = caput(record+'.AMOD', 'A16')

; Set the data size to D16
t = caput(record+'.DSIZ', 'D16')

; Set the address increment to 2
t = caput(record+'.AINC', 2)

; Make arrays to hold data and status return info
ntot = 2L^16/2
data = lonarr(ntot)
status = bytarr(ntot)

; Compute addresses of each point
address = 2*lindgen(ntot)

for i=0L, ntot-1, n do begin
   ; Set the base address
   t = caput(record+'.ADDR', address(i))
   ; Process the record
   t = caput(record+'.PROC', 1)
   t = caget(record+'.VAL', d)    ; This copies n values into data()
   data(i)=d
   t = caget(record+'.SARR', d) ; This copies n values into status()
   status(i) = d
endfor

; Print addresses which responded
valid = 0
for i=0L, ntot-1 do begin
   if (valid) then begin
      if (status(i) ne 0) then begin
        ; We have a transition from valid address to invalid.
        print, address(start), data(start), address(i-1), data(i-1), $
            format="(z4, '( ', z8,') --- ', z4, ' (', z8, ')')"
        valid = 0
      endif else if (i eq ntot-1) then begin
        ; We have valid addresses to the end
        print, address(start), data(start), address(i), data(i), $
            format="(z4, '( ', z8,') --- ', z4, ' (', z8, ')')"
      endif
   endif else begin
      if (status(i) eq 0) then begin
        ; We have a transition from invalid address to valid address
        start = i
        valid = 1
      endif
   endelse
endfor
end
