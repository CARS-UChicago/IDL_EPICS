; This is a test program for CaWave. It excercises most of the routines
; in CaWave.pro. To run this program modify the list of process variable
; names below to match the names of PVs which exist in your system.

; The names of two soft analog input records. These must be passively scanned.
ai_pvs = ['idl_test:ai1', 'idl_test:ai2']
; The names of two valc records. These records must produce a new value each
; time they are processed, for example adding one to themselves. The .SCAN
; fields of these records will be modified by this program.
calc_pvs = ['idl_test:calc1', 'idl_test:calc2']
; The name of a waveform record. This record can be a waveform of any
; data type and any length.
wf_pv = 'idl_test:wf1'

; Test caPut and CaGet on scalars
test_value = 12345
y = caput(ai_pvs(0), test_value)
if (y eq 0) then print, 'caPut: OK' $
            else print, 'caPut: FAILED'

y = caget(ai_pvs(0))
if (y eq test_value) then print, 'caGet: OK' $
                     else print, 'caGet: FAILED'

y = caget(ai_pvs(0), /VSS)
if (y(0) eq test_value) then print, 'caGet,/VSS: OK' $
			else print, 'caGet,/VSS: FAILED'

; Test caPut and CaGet on arrays
test_values = [1,2]
y = caput(ai_pvs, test_values)
if (y eq 0) then print, 'caPut (list of pvs): OK' $
            else print, 'caPut (list of pvs): FAILED'

y = caget(ai_pvs)
if min((y eq test_values) eq 1) then print, 'caGet (list of pvs): OK' $
                                else print, 'caGet (list of pvs): FAILED'

y = caget(ai_pvs, /VSS)
if min((y(0,*) eq test_values) eq 1) $
                  then print, 'caGet,/VSS (list of pvs): OK' $
	          else print, 'caGet,/VSS (list of pvs): FAILED'

pv = ai_pvs(0)+'.DESC'
test_value = 'Test analog input record'
y = caput(pv, test_value)
if (y eq 0) then print, 'caPut (string value): OK' $
            else print, 'caPut (string value): FAILED'
y = caget(pv)
if (y eq test_value) then print, 'caGet (string value): OK' $
                     else print, 'caGet (string value): FAILED'
print, '  String = ', y

pvs = ai_pvs+'.DESC'
test_values = ['Test analog input 1', 'Test analog input 2']
y = caput(pvs, test_values)
if (y eq 0) then print, 'caPut (list of string values): OK' $
            else print, 'caPut (list of string values): FAILED'
y = caget(pvs)
if min((y eq test_values) eq 1) $
                      then print, 'caGet (list of string values): OK' $
                      else print, 'caGet (list of string values): FAILED'

; Test waveforms
n = cagetcount(wf_pv)
if (n gt 1) then print, 'caGetCount: OK' $
            else print, 'caGetCount: FAILED'
type = cagettype(wf_pv)
print, 'Channel access data type of waveform = ', type(0)
print, 'PV-WAVE or IDL data type of waveform = ', type(1)
test_values = lindgen(n) 
y = caput(wf_pv, test_values)
if (y eq 0) then print, 'caPut (waveform): OK' $
            else print, 'caPut (waveform): FAILED'
y = caget(wf_pv)
if min((y eq test_values) eq 1) then print, 'caGet (waveform): OK' $
                                else print, 'caGet (waveform): FAILED'
print, 'PV-WAVE or IDL information on returned waveform (y):'
help, y

; Test error handling and reporting
y = caget('xxxxxx')
if (y ne 0) then print, 'caGet (non-existant pv): OK' $
            else print, 'caGet (non-existant pv): FAILED'
y = caerror()
if (y eq -1) then print, 'caError: OK' $
             else print, 'caError: FAILED'

print, 'Debugging turned on:'
cadebug,1
print, 'Calling caPendEvent, time=.01'
capendevent, time=0.01
print, 'Calling caPendIO, time=0.3'
capendio, time=0.3
print, 'Calling caPendIO, list_time=3.0'
capendio, list_time=3.0
print, 'Debugging turned off:'
cadebug,0

y = casearch(ai_pvs)
if (y eq 0) then print, 'caSearch: OK' $
            else print, 'caSearch: FAILED'

print,'caInfo(ai_pvs(0)) = ', cainfo(ai_pvs(0))

; Test Monitor functions
y = caAddMonitor(calc_pvs)
if (y eq 0) then print, 'caAddMonitor: OK' $
            else print, 'caAddMonitor: FAILED'
pvs = calc_pvs
scan_rate = '.1 second'
scan_rate = replicate(scan_rate, 2)
y = caPut(pvs+'.SCAN', scan_rate)
if (y eq 0) then print, 'caPut (".1 second" to .SCAN field): OK' $
            else print, 'caPut (".1 second" to .SCAN field): FAILED'
y = caPut(pvs+'.VAL', [0,10])
if (y eq 0) then print, 'caPut ([0,10] to .VAL fields): OK' $
            else print, 'caPut ([0,10] to .VAL fields): FAILED'
capendevent
y = caCheckMonitor(pvs)
y = caWaitMonitor(1.0, pvs(0))
if (y eq 0) then print, 'caWaitMonitor (single channel): OK' $
            else print, 'caWaitMonitor (single channel): FAILED'
y = caGet(pvs, /monitor)
print, 'Values prior to caWaitMonitor: ', y
y = caCheckMonitor(pvs)
y = caWaitMonitor(1.0, pvs)
if (y eq 0) then print, 'caWaitMonitor (list of channels): OK' $
            else print, 'caWaitMonitor (list of channels): FAILED'
y = caGet(pvs, /monitor)
print, 'Values after caWaitMonitor: ', y
y = caCheckMonitor(pvs)
wait, 1.0
capendevent
y = caCheckMonitor(pvs)
if min((y eq [1,1]) eq 1) $
                 then print, 'caCheckMonitor (list of channels): OK' $
                 else print, 'caCheckMonitor (list of channels): FAILED'
print,'caGet,/monitor,/vss: ' & print,caGet(pvs(0),/monitor,/vss)
y = caClearMonitor(pvs)
if (y eq 0) then print, 'caClearMonitor (list of channels): OK' $
            else print, 'caClearMonitor (list of channels): FAILED'
scan_rate = 'Passive'
scan_rate = replicate(scan_rate, 2)
y = caPut(pvs+'.SCAN', scan_rate)
if (y eq 0) then print, 'caPut ("Passive" to .SCAN field): OK' $
            else print, 'caPut ("Passive" to .SCAN field): FAILED'

end
