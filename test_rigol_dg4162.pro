; This program tests the Rigol DG4162 AWG

prefix = '13DG4162_1:AWG:'

data1 = dblarr(2048)
data1[0:1023] = findgen(1024)/1023.
data1[1024:1536] = 1
data1[1536:2047] = 1 - findgen(512)/511.

data2 = 0.5*sin(findgen(2048)/2047.*2*!pi)
data2 = data2 + 0.5*cos(findgen(2048)/2047.*3*!pi)

t = caput(prefix + 'Ch1:UserWF', data1)
t = caput(prefix + 'Ch2:UserWF', data2)

end
