; This is a simple benchmark program which measures the time to do a "scan"
; which involves writing one analogue output, and reading 8 long inputs.

iter=100
output='epics_bm:mono1'
inputs = [ 'epics_bm:scaler1', $ 
	   'epics_bm:scaler2', $ 
	   'epics_bm:scaler3', $ 
	   'epics_bm:scaler4', $ 
	   'epics_bm:scaler5', $ 
	   'epics_bm:scaler6', $ 
	   'epics_bm:scaler7', $ 
	   'epics_bm:scaler8'] 
data = dblarr(8, iter)
t = caaddmonitor(output)
t = caget(output,/monitor)
in = dblarr(8)

t0 = systime(1)
for i=0, iter-1 do begin
;  t = call_cawave('CaWavePutValue', double(i), output)
  t = caput(output, i)
  t = cawaitmonitor(1.d0, output)
  t = caget(output,/monitor)
;  t = call_cawave('CaWaveGetValueArray', 8, in, inputs)
  in = caget(inputs)
  data(0, i) = in
endfor
t1 = systime(1)
print, 'Time per scan point = ', (t1-t0)/iter
end

