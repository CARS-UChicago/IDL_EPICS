; Program to measure the delay between a current pulse to the TetrAMM and the gate pulse to measure the signal.

curr1_PV = 'QE1:TetrAMM:Current1:MeanValue_RBV'

delay_PV = 'USB1808:WaveGen1PulseDelay'

start_delay = 350e-6
delay_inc = 5e-6
num_delay = 60
num_average = 10
current = fltarr(num_delay)
delay = findgen(num_delay)*delay_inc + start_delay

for i=0, num_delay-1 do begin
  t = caput(delay_PV, delay[i])
  sum = 0.
  wait, .2
  for j=0, num_average-1 do begin
    wait, .02
    t = caget(curr1_PV, val)
    sum = sum + val
  endfor
  current[i] = sum/num_average
  print, 'Delay=' + strtrim(delay[i],2) + ' current=' + strtrim(current[i], 2)
endfor

p = plot(delay*1e6, current/1000., xtitle='Delay time (microseconds)', symbol='+', ytitle='Current (microamps)', $
         title='Test of gate delay vs measured current for TetrAMM')

end
