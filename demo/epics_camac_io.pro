pro epics_camac_io, record, b, c, n, a, f, data, q

castartgroup
t = caput(record+'.B', b)
t = caput(record+'.C', c)
t = caput(record+'.N', n)
t = caput(record+'.A', a)
t = caput(record+'.F', f)
t = caput(record+'.TMOD', 0)
t = caput(record+'.NUSE', 1)
t = caput(record+'.PROC', 1)
if ((f ge 16) and (f le 23)) then begin
    t = caput(record+'.VAL', data)
    t = caendgroup()
endif else begin
    t = caput(record+'.PROC', 1)
    t = caendgroup()
    t = caget(record, max=1, data)
endelse
if (n_params() eq 8) then t = caget(record+'.Q', q)
end
