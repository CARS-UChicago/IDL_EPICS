; This is a simple benchmark program which measures the time to do a "scan"
; which involves writing four analog outputs, and reading 8 long inputs. It
; can also read a 2048 channel long input array, if the comment character 
; at the beginning of the appropriate line is removed.
; For the fastest performance (~15% faster) use the call_cawave calls, rather
; than caget and caput.

iter=100
outputs=['epics_bm:mono1', $
         'epics_bm:mono2', $
         'epics_bm:mono3', $
         'epics_bm:mono4']

inputs = [ 'epics_bm:scaler1', $ 
	   'epics_bm:scaler2', $ 
	   'epics_bm:scaler3', $ 
	   'epics_bm:scaler4', $ 
	   'epics_bm:scaler5', $ 
	   'epics_bm:scaler6', $ 
	   'epics_bm:scaler7', $ 
	   'epics_bm:scaler8']
array_input = 'epics_bm:MCA1'
 
data = dblarr(8, iter)
in = dblarr(8)
array = lonarr(2048)
t = caaddmonitor(outputs)
t = caget(outputs,/monitor)
out_vals = [1.d0, 1.20, 3.d0, 4.d0]
capendio, time=2

t0 = systime(1)
for i=0, iter-1 do begin
;  t = call_cawave('CaWavePutArray', 4, double(out_vals+i), outputs)
  t = caput(outputs, (out_vals+i))
  t = cawaitmonitor(1.d0, outputs)
  t = caget(outputs,/monitor)
;  t = call_cawave('CaWaveGetValueArray', 8, in, inputs)
  in = caget(inputs)
  data(0, i) = in
;  t = call_cawave('CaWaveGetWF', array, array_input)
endfor
t1 = systime(1)
print, 'Time per scan point = ', (t1-t0)/iter
end

