pro read_tds200, record, data, start=start, stop=stop, chan=chan

; This procedure reads waveforms from the Tektronix TDS200 series scopes
; Mark Rivers
; Modifications:
;     March 7,  2001 Correctly put record in Write and Write/Read modes.
;     Dec. 7,   2001 Set timeout to 2 seconds before read.
;     March 30, 2004 Change IFMT from Binary to Hybrid, other fixes.

if (n_elements(start) eq 0) then start=1
if (n_elements(stop) eq 0) then stop=2500
if (n_elements(chan) eq 0) then chan=1
chan = 'CH'+strtrim(chan,2)

aout = record + '.AOUT'
binp = record + '.BINP'
tmod = record + '.TMOD'
ifmt = record + '.IFMT'
binp = record + '.BINP'
nord = record + '.NORD'
tmot = record + '.TMOT'
oeos = record + '.OEOS'
ieos = record + '.IEOS'

; Set the terminators to newline (assumes scope is set up this way)
t = caput(oeos, '\n', /wait)
t = caput(ieos, '\n', /wait)

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

; Set the input mode to hybrid. Large buffer but line-feed terminator
t = caput(ifmt, 'Hybrid', /wait)

; Set the transfer mode to write/read
t = caput(tmod, 'Write/Read', /wait)

; Empirically the timeout needs to be about 5 seconds for 
; 1024 channels with RS-232
t = caput(tmot, 2.0)

; Read the scope
t = caput(aout, 'Curve?', /wait)

; Get the data
t = caget(binp, data)

; Check the number of bytes read.  See if it's what's expected
n_data = stop-start+1
n_header = 2 + strlen(strtrim(n_data, 2))
n_checksum = 1
n_expected = n_header + n_data + n_checksum
t = caget(nord, n)
if (n ne n_expected) then print, 'Scope returned:', n, ' bytes, expected: ', n_expected

; The first n_header bytes are header, the last byte is checksum.  Data are offset by
; 127, convert to long
data = data[n_header:n-2] - 127L

return
end
