pro read_tds200, record, data, start=start, stop=stop, chan=chan

; This procedure reads waveforms from the Tektronix TDS200 series scopes
; Mark Rivers
; Modified March 7, 2001 to correctly put record in Write and Write/Read modes.

if (n_elements(start) eq 0) then start=1
if (n_elements(stop) eq 0) then stop=2500
if (n_elements(chan) eq 0) then chan='CH1'

aout = record + '.AOUT'
binp = record + '.BINP'
tmod = record + '.TMOD'
ifmt = record + '.IFMT'
binp = record + '.BINP'
nord = record + '.NORD'

; Set the transfer mode to write
t = caput(tmod, 'Write', /wait)

; Set the encoding to positive binary, start and stop readout channels
; Set the readout range.  Can't do as one command, exceed 40 characters
command = 'DATA:ENC RPB; DATA:START ' + strtrim(start,2)
t = caput(aout, command, /wait)
command = 'DATA:STOP ' + strtrim(stop,2)
t = caput(aout, command, /wait)

;Set DATa:WIDth to 2
;command = 'DATA:WIDTH 2'
;t = caput(aout, command, /wait)

;Set channel number
command = 'DATA:SOURCE '+ strtrim(chan,2)
t = caput(aout, command, /wait)

; Set the input mode to binary
t = caput(ifmt, 'Binary', /wait)

; Set the transfer mode to write/read
t = caput(tmod, 'Write/Read', /wait)

; Read the scope
t = caput(aout, 'Curve?', /wait)

; Get the data
t = caget(binp, data)

; Check the number of bytes read.  It should be stop-start+8
t = caget(nord, n)
if (n ne stop-start+8) then message, 'Scope returned bad data'

; The first 6 bytes are header, the last byte is checksum.  Data are offset by
; 127, convert to long
data = data[6:n-2] - 127L

return
end
