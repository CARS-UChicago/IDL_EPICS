pro vme_mem_probe, record, address, a16=a16, a24=a24, a32=a32, $
                                    d8=d8,   d16=d16, d32=d32

; This procedure probes a VME memory address using the VME record.
;
; It requires as input the name of a VME record which must exist in the IOC to
; be tested.  

; Set the value of NUSE (number to actually use) to 1
t = caput(record+'.NUSE', 1)

; Set the address mode
if (keyword_set(A16)) then address_mode='A16' $
else if (keyword_set(A24)) then address_mode='A24' $
else address_mode='A32'
t = caput(record+'.AMOD', address_mode)

; Set the data size
if (keyword_set(D8)) then data_size='D8' $
else if (keyword_set(D32)) then data_size='D32' $
else data_size='D16'
t = caput(record+'.DSIZ', data_size)

; Set the address
t = caput(record+'.ADDR', address)
; Process the record
t = caput(record+'.PROC', 1)
t = caget(record+'.SARR', status)

if (status[0] eq 0) then print, 'OK, Valid VME address' else $
                      print, 'ERROR, Invalid VME address
end
