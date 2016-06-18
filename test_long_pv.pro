; This programs tests accessing PVs with lengths longer than 40 characters

short_pv = '13IDA:m1'
long_pv = 'quadEMTest:AH401B:image1:EnableCallbacks_RBV'

v = -1
t = caget(short_pv, v)
print, 't, v=', t, v
v = -1
t = caget(long_pv, v)
print, 't, v=', t, v

pvs = [short_pv, short_pv, short_pv]
t = cagetarray(pvs, values)
print, 't, values=', t, values
 
pvs = [long_pv, long_pv, long_pv]
t = cagetarray(pvs, values)
print, 't, values=', t, values

end
