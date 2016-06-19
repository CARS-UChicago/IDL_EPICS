; This program loads the calculations for type S thermocouples into a Keithley DMM
; Note that because the calculation string is very long it uses the calc fields from
; 2 inputs.  So the first input is where the thermocouple is connected, the second
; is used only for calculation, its input is not used in the calculation
; This is a 4'th order polynomial, assuming the internal temperature of the Keithley
; is 33C (offset = 191 microvolts)

DMM = '13BMD:DMM3'
ch1 = 'Ch2'
ch2 = 'Ch3'
ch3 = 'Ch4'

coeffs = [9.27763167e-1, $
          1.69526515e5, $
          -3.156836394e7, $
          8.990730663e9, $
          -1.63565e12,$
          1.88027e14,$
          -1.37241e16, $
          6.17501e17,$
          -1.56105e19,$
          1.69535e20]

offset = 191.e-6  ; Assume Keithley internal temp is 33C = .191 mV

t = caput(DMM+ch1+'_calc.INPA', DMM+ch1+'_raw.VAL NPP NMS')
t = caput(DMM+ch1+'_calc.B',    offset)
t = caput(DMM+ch1+'_calc.CALC', 'A+B')

t = caput(DMM+ch2+'_calc.INPA', DMM+ch1+'_calc.VAL NPP NMS')
t = caput(DMM+ch2+'_calc.B',    coeffs[0])
t = caput(DMM+ch2+'_calc.C',    coeffs[1])
t = caput(DMM+ch2+'_calc.D',    coeffs[2])
t = caput(DMM+ch2+'_calc.E',    coeffs[3])
t = caput(DMM+ch2+'_calc.F',    coeffs[4])
t = caput(DMM+ch2+'_calc.G',    coeffs[5])
t = caput(DMM+ch2+'_calc.CALC', 'B+C*A+D*A**2+E*A**3+F*A**4+G*A**5')

t = caput(DMM+ch3+'_calc.INPA', DMM+ch1+'_calc.VAL NPP NMS')
t = caput(DMM+ch3+'_calc.INPB', DMM+ch2+'_calc.VAL NPP NMS')
t = caput(DMM+ch3+'_calc.C',    coeffs[6])
t = caput(DMM+ch3+'_calc.D',    coeffs[7])
t = caput(DMM+ch3+'_calc.E',    coeffs[8])
t = caput(DMM+ch3+'_calc.F',    coeffs[9])
t = caput(DMM+ch3+'_calc.CALC', 'B+C*A**6+D*A**7+E*A**8+F*A**9')
end

