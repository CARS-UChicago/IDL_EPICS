t1 = .5
k = 0
prefix = 'test:'

Freq=10
print,'Freq:',Freq
temp='sour1:FREQ '+string(Freq)+'MHZ'
status=caput(prefix+'gpib1.AOUT',temp)
print,status,temp

wait, t1
Cycles=1000
print,'Cycles:',Cycles
temp='sour1:burs:ncyc '+string(Cycles)
status=caput(prefix+'gpib1.AOUT',temp)
print,status,temp

;wait,t1
;status=caput(Prefix+'gpib1.ADDR','11')
;if (status ne 0) then begin
;  print,k,Prefix+'gpib1.ADDR',' Status is ',status
;  wavegenstat=1
;endif
k=k+1
wait,t1
status=caput(Prefix+'gpib1.AOUT','OUTP1:STATe on')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif
k=k+1
wait,.75
status=caput(Prefix+'gpib1.AOUT','sour1:burs:STATe on')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif
k=k+1
wait,.75
status=caput(Prefix+'gpib1.AOUT',':sour1:FREQ 62MHz;:sour1:burs:NCYC 5')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif
k=k+1
wait,.75
status=caput(Prefix+'gpib1.AOUT',':sour1:VOLT:AMPL 3.')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif
k=k+1
wait,.75
status=caput(Prefix+'gpib1.AOUT','TRIG:SEQ:SOUR INT')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif
k=k+1
wait,.75
status=caput(Prefix+'gpib1.AOUT','TRIG:SEQ:SLOP POS')
if (status ne 0) then begin
  print,k,Prefix+'gpib1.AOUT',' Status is ',status
  wavegenstat=1
endif

end
