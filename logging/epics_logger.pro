;+
; NAME:
;   EPICS_LOGGER
;
; PURPOSE:
;   This procedure logs EPICS process variables to a GUI window and to a
;   disk file.
;
; CATEGORY:
;   EPICS data acquisition.
;
; CALLING SEQUENCE:
;   EPICS_LOGGER
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;   INPUT_FILE:
;       The name of an input file containing the list of EPICS process
;       variables (PV) to be logged.  The format of this file is one line per
;       PV.  Each line has the following format:
;
;           PVName | PVFormat | Description | DescriptionFormat
;
;       "PVName" is the name of the EPICS PV.
;
;       "PVFormat" is the format with which the PV should be displayed on the
;       screen and written to the disk file, e.g. F10.3 or E12.4.
;
;       "Description" is a string which describes this PV. It is displayed at
;       the top of the screen.  Any character except "|" can be used in this 
;       field, including white space.
;
;       "DescriptionFormat" is the format with which the description string
;       should be displayed on the screen and in the disk file, e.g. A15.
;       This format should specify the same field width (e.g. 15 characters) as
;       the PVformat for this PV to make things line up properly on the screen.
;
;       If INPUT_FILE is not present then the input file can be selected later
;       from the "File" menu in the procedure.
;
;   OUTPUT_FILE:
;       The name of the output file to which the logging data will be written.
;       If OUTPUT_FILE is not present then the output file can be selected later
;       from the "File" menu in the procedure.
;
;       The output is an ASCII file with 3 types of lines in it.  Lines
;       beginning with "PVS:" list the process variables which follow in the
;       file. Lines beginning with "DESCRIPTION:" list the descriptions of the
;       PVs.  Finally, lines beginning with "DATA:" list the date and time, and
;       then the values of all of the PVs.  Each value on a line is separated
;       from the next by a vertical bar ("|").
;       The following is an example of the first few lines from an output file:
;          PVS:|Date and time|13BMD:DMM1Ch1_calc.VAL|13BMD:DMM1Ch3_calc.VAL
;          DESCRIPTION:|Date and time|Load, Tons|Ram Ht, mm
;          DATA:|10-Jul-1999 09:35:44|91.42843|8.244
;          DATA:|10-Jul-1999 09:35:45|91.42777|8.244
;          DATA:|10-Jul-1999 09:35:46|91.42398|8.244
;          DATA:|10-Jul-1999 09:35:47|91.38756|8.244
;       These data files can be read into IDL with the function READ_EPICS_LOG.
;       They can easily be read into spreadsheets such as Excel, by specifying
;       that the input is "Delimited" with a delimiter character of "|".
;       The date format in the file is recognized by Excel as a valid data/time
;       field.
;
;   TIME:
;       The time interval for logging, in floating point seconds.  The default
;       is 10 seconds.
;
;   FONT:
;       The font to be used for the descriptions and the logging output.  The
;       default is the font returned from GET_FONT_NAME(/COURIER, /LARGE)
;
;   XSIZE:
;       The width of the text output window in pixels.  The default is 600.
;       The window can be resized with the mouse when the program is running.
;
;   YSIZE:
;       The height of the text output window in pixels.  The default is 300.
;       The window can be resized with the mouse when the program is running.
;
;   MAX_LINES
;       The maximum number of lines which the text window will retain for
;       vertical scrolling.  The default is 1000.
;
;   MAX_PVS
;       The maximum number of process variables in an input file.
;       The default is 100.
;
;   START:
;       Set this flag to start logging immediately when the procedure begins.
;       By default the user must press the "Start" button to begin logging.
;
; OUTPUTS:
;   None.
;
; SIDE EFFECTS:
;   This procedure places EPICS monitors on all of the PVs for efficiency.
;   It writes a disk file of logging results.
;
; RESTRICTIONS:
;   Placing monitors on all PVs is not efficient when the PVs change
;   rapidly and the logging period is long.
;   This procedure does not gracefully handle the case when PVs cannot be
;   accessed, such as when a crate is rebooted.
;
; EXAMPLE:
;   EPICS_LOGGER, input_file='xrf_pvs.inp', output_file='xrf_pvs.log', time=2
;
; MODIFICATION HISTORY:
;       Written by:     Mark Rivers, July 10, 1999.
;       Mark Rivers, July 20, 2000  Changed today() to systime(/julian),
;       because today() does not exist in IDL 5.3.
;-

pro new_input_file, file, state
    state.input_valid = 0
    catch, error
    if (error ne 0) then return
    openr, lun, /get, file
    line = ""
    state.num_pvs = 0
    ; Get the current size of the scroll base
    scroll_base_size = widget_info(state.widgets.scroll_base, /geometry)
    while (not eof(lun)) do begin
        readf, lun, line
        words = str_sep(line, '|', /trim)
        pv = words[0]
        format = '(' + words[1] + ')'
        state.pvs[state.num_pvs] = pv
        state.data_format[state.num_pvs] = format
        state.description[state.num_pvs] = words[2]
        format = '(' + words[3] + ')'
        state.description_format[state.num_pvs] = format
        status = caSetMonitor(pv)
        state.num_pvs = state.num_pvs + 1
    endwhile
    output_line = string(' ', format='(A20)')
    for i=0, state.num_pvs-1 do begin
       data = string(state.pvs[i], format=state.description_format[i])
       output_line = output_line + ' ' + data
    endfor
    widget_control, state.widgets.pvs, set_value=output_line
    output_line = string('Date and time', format='(A20)')
    for i=0, state.num_pvs-1 do begin
       data = string(state.description[i], format=state.description_format[i])
       output_line = output_line + ' ' + data
    endfor
    widget_control, state.widgets.description, set_value=output_line
    if (state.output_valid) then print_output_headers, state

    geometry = widget_info(state.widgets.pvs, /geometry)
    widget_control, state.widgets.output, scr_xsize=geometry.scr_xsize+30
    ; This preserves the size of the scroll window
    widget_control, state.widgets.scroll_base, $
                    scr_xsize=scroll_base_size.scr_xsize
    widget_control, state.widgets.scroll_base, $
                    scr_ysize=scroll_base_size.scr_ysize

    free_lun, lun
    state.input_valid = 1
end

pro print_output_headers, state
    output_line = 'PVS:|Date and time'
    for i=0, state.num_pvs-1 do begin
        output_line = output_line + '|' + strtrim(state.pvs[i],2)
    endfor
    printf, state.output_lun, output_line
    output_line = 'DESCRIPTION:|Date and time'
    for i=0, state.num_pvs-1 do begin
        output_line = output_line + '|' + strtrim(state.description[i],2)
    endfor
    printf, state.output_lun, output_line
end


pro new_output_file, file, state
    state.output_valid = 0
    catch, error
    if (error ne 0) then return
    if (state.output_valid) then free_lun, state.output_lun
    openw, lun, file, /get, /append
    state.output_lun = lun
    state.output_valid = 1
    if (not state.input_valid) then return
    print_output_headers, state
end

pro epics_logger_event, event
    widget_control, event.top, get_uvalue=state
    widgets = state.widgets
    case event.id of

        widgets.base: begin
            if tag_names(event, /structure_name) eq $
                    'WIDGET_KILL_REQUEST' then begin
                if (state.output_valid) then free_lun, state.output_lun
                widget_control, event.top, /destroy
                return
            endif
            ; This must be a resize event
            deltax = event.x - state.xsize
            deltay = event.y - state.ysize
            ; Change the size of the text output window by deltay
            geometry = widget_info(widgets.output, /geometry)
            widget_control, widgets.output, $
                            scr_ysize=(geometry.scr_ysize+deltay)
            ; Change the size of the scroll base by deltax and deltay
            geometry = widget_info(widgets.scroll_base, /geometry)
            widget_control, widgets.scroll_base, $
                            scr_ysize=(geometry.scr_ysize+deltay)
            widget_control, widgets.scroll_base, $
                            scr_xsize=(geometry.scr_xsize+deltax)
            ; Save the new overall window size
            widget_control, widgets.base, tlb_get_size=geometry
            state.xsize = geometry[0]
            state.ysize = geometry[1]
        end

        widgets.timer: begin
            widget_control, widgets.timer, timer=state.update_time
            if (not state.logging_enabled) then goto, done
            if (not state.input_valid) then goto, done
            time = string(systime(/julian), format= $
                '(C(CDI2.2,"-",CMoA,"-",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))')
            output_line = time
            for i=0, state.num_pvs-1 do begin
                status = caget(state.pvs[i], data)
                data = string(data, format=state.data_format[i])
                output_line = output_line + ' ' + data
            endfor
            widget_control, widgets.output, get_value=text
            text = [text, output_line]
            nlines = n_elements(text)
            if (nlines gt state.max_lines) then $
                text=text[(nlines-state.max_lines) : *]
            nlines = n_elements(text)
            geometry = widget_info(widgets.output, /geometry)
            widget_control, widgets.output, set_value=text
            widget_control, widgets.output, $
                        set_text_top_line = nlines - geometry.ysize + 2
            if (state.output_valid) then begin
                output_line = 'DATA:|' + time
                for i=0, state.num_pvs-1 do begin
                    status = caget(state.pvs[i], data)
                    data = string(data, format=state.data_format[i])
                    output_line = output_line + '|' + strtrim(data,2)
                endfor
                printf, state.output_lun, output_line
            endif
            widget_control, widgets.timer, timer=state.update_time
        end

        widgets.time: begin
            state.update_time = event.value
            ; Repaint with correct format
            widget_control, widgets.time, set_value=event.value
            ; Submit request to run timer event again
            widget_control, widgets.timer, timer=state.update_time
        end

        widgets.input_file: begin
            file = dialog_pickfile(/must_exist)
            if (file eq "") then goto, done
            new_input_file, file, state
        end

        widgets.output_file: begin
            file = dialog_pickfile(/write)
            if (file eq "") then goto, done
            new_output_file, file, state
        end

        widgets.exit: begin
            if (state.output_valid) then free_lun, state.output_lun
            widget_control, event.top, /destroy
            return
        end

        widgets.start: begin
            state.logging_enabled = 1
            widget_control, state.widgets.start, sensitive=0
            widget_control, state.widgets.stop, sensitive=1
        end

        widgets.stop: begin
            state.logging_enabled = 0
            widget_control, state.widgets.start, sensitive=1
            widget_control, state.widgets.stop, sensitive=0
        end

        else: begin
            print, 'Unknown event'
        end

    endcase

    done:
    widget_control, event.top, set_uvalue=state
end


pro epics_logger, input_file=input_file, output_file=output_file, time=time, $
                  font=font, xsize=xsize, ysize=ysize, max_lines=max_lines, $
                  max_pvs=max_pvs, start=start

    if (n_elements(time) eq 0) then time = 10.
    if (n_elements(font) eq 0) then font=get_font_name(/courier, /large)
    if (n_elements(xsize) eq 0) then xsize = 600
    if (n_elements(ysize) eq 0) then ysize = 300
    if (n_elements(max_lines) eq 0) then max_lines = 1000
    if (n_elements(max_pvs) eq 0) then max_pvs = 100


    widgets = { $
        base: 0L, $
        scroll_base: 0L, $
        input_file: 0L, $
        output_file: 0L, $
        description: 0L, $
        pvs: 0L, $
        time: 0L, $
        output: 0L, $
        timer: 0L, $
        start: 0L, $
        stop: 0L, $
        exit: 0L $
    }

    state = { $
        output_lun: 0L, $
        input_valid: 0L, $
        output_valid: 0L, $
        update_time: 0., $
        num_pvs: 0L, $
        pvs: strarr(max_pvs), $
        data_format: strarr(max_pvs), $
        description: strarr(max_pvs), $
        description_format: strarr(max_pvs), $
        xsize: 0L, $
        ysize: 0L, $
        max_lines: 0L, $
        logging_enabled: 0L, $
        widgets: widgets $
    }

    state.update_time = time
    state.max_lines = max_lines

    base = widget_base(title='EPICS Logger', mbar=mbar, /column, $
                        /base_align_center, $
                        /tlb_size_events, $
                        /tlb_kill_request_events)
    widgets.base = base
    widgets.timer = widget_base(base)  ; Dummy

    file = widget_button(mbar, /menu, value='File')
    widgets.input_file = widget_button(file, value='Input file ...')
    widgets.output_file = widget_button(file, value='Output file ...')
    widgets.exit = widget_button(file, value='Exit')

    scroll_base = widget_base(base, /column, /scroll, /base_align_left)
    widgets.scroll_base = scroll_base
    widgets.pvs = widget_label(scroll_base, font=font, value=" ", $
                                /align_left, /dynamic_resize)
    widgets.description = widget_label(scroll_base, font=font, value=" ", $
                                /align_left, /dynamic_resize)
    widgets.output = widget_text(scroll_base, scr_xsize=xsize, $
                                scr_ysize=ysize, /scroll, font=font)
    row = widget_base(base, /row, /align_left)
    widgets.start = widget_button(row, value='Start', /no_release)
    widgets.stop = widget_button(row, value='Stop', /no_release)
    widgets.time = cw_field(row, title='Update time (seconds)', /row, $
                            /float, /return_events, $
                            value=state.update_time)
    if (keyword_set(start)) then begin
        state.logging_enabled = 1
        widget_control, widgets.start, sensitive=0
    endif else begin
        state.logging_enabled = 0
        widget_control, widgets.stop, sensitive=0
    endelse
    state.widgets = widgets
    if (n_elements(output_file) ne 0) then new_output_file, output_file, state
    if (n_elements(input_file) ne 0) then new_input_file, input_file, state
    widget_control, base, /realize
    ; Need to resize the scroll widget, especially on Motif, where it is very
    ; small initially, even if the xsize or scr_xsize keywords are used when
    ; it is created.  Motif and Windows need different padding for scroll bars.
    version = widget_info(base, /version)
    if (version.style eq "Motif") then begin
        xpad = 10
        ypad = 10
    endif else begin
        xpad = 10
        ypad = 30
    endelse
    ; The vertical size of the scroll widget is the size of the output widget
    ; plus the size of the two label widgets (pvs and description).
    geometry = widget_info(widgets.pvs, /geometry)
    yadd = 2*geometry.scr_ysize
    widget_control, state.widgets.scroll_base, $
                                xsize=xsize+xpad, ysize=ysize+yadd+ypad
    widget_control, widgets.timer, timer=state.update_time
    widget_control, widgets.base, tlb_get_size=geometry
    state.xsize = geometry[0]
    state.ysize = geometry[1]
    widget_control, base, set_uvalue=state
    xmanager, "epics_logger", base, /no_block
end

