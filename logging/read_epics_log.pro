;+
; NAME:
;   READ_EPICS_LOG
;
; PURPOSE:
;   This function reads an EPICS log file into an IDL structure.
;
; CATEGORY:
;   EPICS data acquisition.
;
; CALLING SEQUENCE:
;   Result = READ_EPICS_LOG(Filename)
;
; INPUTS:
;   Filename:
;       The name of the EPICS log file to read.  These files are created
;       with EPICS_LOGGER.  If the filename is not specified then the
;       user will be presented with a file selection dialog box.
;
; OUTPUTS:
;   This function returns a structure of the following type:
;      { file:
;        pvs:
;        description:
;        data:
;        time_string:
;        julian_time:
;        num_pvs:
;        num_points:
;    }
;   These fields are defined as follows:
;       .file is a string containing the name of the input log file
;       .num_pvs is the number of EPICS process variables in the file
;       .pvs[num_pvs] is a string array containing the names of the EPICS
;           process variables.
;       .description[num_pvs] is a string array containing the descriptions of
;           the process variables which were contained in the input file for
;           EPICS_LOGGER.
;       .num_points is the number of data points in the file.
;       .data[num_pvs, num_points] is a double precision array containing the
;           data for each PV at each time point.
;       .time_string[num_points] is a string containing the date and time when
;           each data point was collected.
;       .julian_time[num_points] is a double precision array containing the
;           Julian time when each data point was collected.  This is useful for
;           plotting.  The units of julian_time are days since some day in
;           about 4000BC.
;
; RESTRICTIONS:
;   This function assumes that all of the PVs in the log file are numbers, it
;   will not work if any of them are non-numeric strings.
;
; EXAMPLE:
;   result = READ_EPICS_LOG('xrf_pvs.log')
;   plot, result.data[0,*]
;
; MODIFICATION HISTORY:
;   Written by:     Mark Rivers, July 9, 1999
;-

function read_epics_log, file

    if (n_elements(file) eq 0) then file = dialog_pickfile(/must_exist)
    if (file eq "") then return, 0
    openr, lun, file, /get

    MAX_PVS = 100
    BUFFER_SIZE = 1000  ; Number of lines to pre-allocate in buffer
    data = dblarr(MAX_PVS,BUFFER_SIZE)
    time_string = strarr(BUFFER_SIZE)
    julian_time = dblarr(BUFFER_SIZE)
    buff_size = BUFFER_SIZE
    num_points = 0
    line = ""

    on_ioerror, skip_data
    while (not eof(lun)) do begin
        readf, lun, line
        tokens = str_sep(line, '|', /trim)
        type = tokens[0]
        case type of

            'PVS:': begin
                num_pvs = n_elements(tokens) - 2
                pvs = tokens[2:*]
            end

            'DESCRIPTION:': begin
                description = tokens[2:*]
            end

            'DATA:': begin
                if (num_points eq buff_size) then begin
                ; The current input buffer is full, make it bigger
                    data = [[data], [dblarr(MAX_PVS,BUFFER_SIZE)]]
                    time_string = [time_string, strarr(BUFFER_SIZE)]
                    julian_time = [julian_time, dblarr(BUFFER_SIZE)]
                    buff_size = buff_size + BUFFER_SIZE
                endif
                time_string[num_points] = tokens[1]
                time = 0.0d0
                reads, tokens[1], time, format= $
                    '(C(CDI,X,CMoA,X,CYI,X,CHI2,X,CMI2,X,CSI2))'
                julian_time[num_points] = time
                data[0,num_points] = double(tokens[2:*])
                skip_data:
                num_points = num_points + 1
            end

            else: begin
                print, 'Unexpected token in input file'
            end
        endcase
    endwhile
    pvs = pvs[0:num_pvs-1]
    description = description[0:num_pvs-1]
    data = data[0:num_pvs-1, 0:num_points-1]
    time_string = time_string[0:num_points-1]
    julian_time = julian_time[0:num_points-1]
    epics_log = $
        {file: file, $
        pvs: pvs, $
        description: description, $
        data: data, $
        time_string: time_string, $
        julian_time: julian_time, $
        num_pvs: num_pvs, $
        num_points: num_points $
    }
    return, epics_log
end
