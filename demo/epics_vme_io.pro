pro epics_vme_io, record, data, vme_address=vme_address, data_size=data_size, $
                  address_mode=address_mode, write=write

if n_elements(vme_address) ne 0 then t = caput(record+'.ADDR', vme_address)
if n_elements(data_size) ne 0 then t = caput(record+'.DSIZ', data_size)
if n_elements(address_mode) ne 0 then t = caput(record+'.AMOD', address_mode)
if keyword_set(write) then begin
    t = caput(record+'.RDWT', 'Write')
    t = caput(record+'.VAL', data)
endif else begin
    t = caput(record+'.RDWT', 'Read')
    t = caput(record+'.PROC', 1)
    t = caget(record+'.VAL', data)
endelse
end
