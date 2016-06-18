pro modbus_transact, asyn_record, funct, start_address, length, data

   ; This procedure uses an asyn record that is connected to port 502 of a modbus server to 
   ; read or write
   ; data.  It reads "length" words (orstarting at address "start_address"
   ; It returns the words read from the PLC in "response".

   ; On the DL205 the following Modbus addresses should be used
       I/O         Function Code     Modbus address
   ; X inputs           2               2048
   ; Y outputs          1               2048
   ; CR control relays  1               3072     

   rec = asyn_record

   ; Connect to the server in case it has timed out
   t = caput(rec + '.CNCT', 1)

   ; Put the record in binary output and binary input modes
   t = caput(rec + '.OFMT', 'Binary')
   t = caput(rec + '.IFMT', 'Binary')

   ; Construct the packet to request the read.
   packet = bytarr(12)
   ; The first 2 bytes are the transaction identifier = 00 01
   packet[0]=0 & packet[1]=1
   ; The next 2 bytes are the protocol identifier = 00 00
   packet[2]=0 & packet[3]=0
   ; The next 2 bytes are the length of the following parts of the message = 00 06
   packet[4]=0 & packet[5]=6
   ; The next byte is the unit identifier = 255
   packet[6] = 255
   ; The next byte is the function code.
   packet[7] = funct
   ; The next 2 bytes are the starting Modbus address
   address = swap_endian(start_address, /swap_if_little_endian)
   packet[8] = byte(address,0)
   packet[9] = byte(address,1)
   len = swap_endian(length, /swap_if_little_endian)
   packet[10] = byte(len,0)
   packet[11] = byte(len,1)

   ; The number of bytes to write is 12
   t = caput(rec + '.NOWT', 12)
   ; The number of bytes to read is the echoed command (12) + 2*length
   t = caput(rec + '.NRRD', 12+2*length)

   ; The transaction mode is Write/Read
   t = caput(rec + '.TMOD', 'Write/Read')

   ; Write to the .BOUT field, which will cause the record to process
   ; Use ca_put_callback to wait for completion
   t = caput(rec + '.BOUT', packet, /wait)

   ; Get the data from the .NORD and .BINP fields
   t = caget(rec + '.NORD', nord)
   if (nord eq 0) then return
   t = caget(rec + '.BINP', response, max=nord)

   ; Trim the response to the number of bytes actually read
   response = response[0:nord-1]

   ; Check if the exception bit is set.  If so, then print exception and return
   if (response[7] and '80'x) then begin
      print, 'Error reading, exception=', response[8]
      return
   endif

   ; Get the response length from the header
   len = response[8]

   ; Interpret the response depending on the function
   switch funct of
      1:
      2: begin
            response = byte(response, 9, len)
            break
         end
      3: 
      4: begin
            ; Convert from bytes to words
            len = len/2
            ; Convert the data from bytes to 16-bit words
            response = fix(response, 9, len)
            ; Swap the byte order of the words if necessary
            response = swap_endian(response, /swap_if_little_endian)
            break;
         end
   endswitch

   ; Return the data
   data = response

end

