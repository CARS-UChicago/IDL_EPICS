; This is a simple benchmark program which measures the time to do a "scan"
; which involves writing one analogue output, and reading 8 long inputs.

iter=100
mono_outputs=['epics_bm:mono1', $
              'epics_bm:mono2', $
              'epics_bm:mono3', $
              'epics_bm:mono4', $
              'epics_bm:mono5', $
              'epics_bm:mono6', $
              'epics_bm:mono7', $
              'epics_bm:mono8', $
              'epics_bm:mono9', $
              'epics_bm:mono10', $
              'epics_bm:mono11', $
              'epics_bm:mono12']

huber_outputs=['epics_bm:huber1', $
               'epics_bm:huber2', $
               'epics_bm:huber3', $
               'epics_bm:huber4', $
               'epics_bm:huber5', $
               'epics_bm:huber6']

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
t = caaddmonitor(mono_outputs)
t = caaddmonitor(huber_outputs)
mono_vals = dindgen(n_elements(mono_outputs))
huber_vals = dindgen(n_elements(huber_outputs))
capendio, time=2

t0 = systime(1)
for i=0, iter-1 do begin
;  t = call_cawave('CaWavePutArray', 12, double(mono_vals+i), mono_outputs)
;  t = call_cawave('CaWavePutArray', 6, double(huber_vals-i), huber_outputs)
  t = caput(mono_outputs, (mono_vals+i))
  t = caput(huber_outputs, (huber_vals-i))
  t = cawaitmonitor(1.d0, mono_outputs)
  t = cawaitmonitor(1.d0, huber_outputs)
;  t = call_cawave('CaWaveGetValueArray', 8, in, inputs)
  in= caget(inputs)
  data(0, i) = in
;  t = call_cawave('CaWaveGetWF', array, array_input)
  array = caget(array_input)
endfor
t1 = systime(1)
print, 'Time per scan point = ', (t1-t0)/iter
end

