pro caprobe_event, event
common caprobe_main_common, widget_ids
@caprobe_common

widget_control, widget_ids.pv, get_uvalue=pv

case event.id of

widget_ids.monitor: begin
    caprobe_update_value, pv
end
	
widget_ids.pv: begin
    t = cawidgetclearmonitor(pv, widget_ids.monitor) 
    hist_text = ' '
    widget_control, widget_ids.pv, get_value=pv
    pv = strtrim(pv(0), 2)
    status = caGetCountAndType(pv, count, type)
    if status eq 0 then begin
       widget_control, widget_ids.pv, set_uvalue=pv
       widget_control, widget_ids.name, set_value=pv
       caprobe_update_value, pv
       sens=1
    endif else begin
       widget_control, widget_ids.name, set_value='Invalid channel name!'
       caprobe_update_value
       sens=0
    endelse
    widget_control, widget_ids.start, sensitive=sens
    widget_control, widget_ids.stop, sensitive=0
    widget_control, widget_ids.adjust, sensitive=sens
    widget_control, widget_ids.hist, sensitive=sens
    widget_control, widget_ids.info, sensitive=sens
end

widget_ids.start: begin
    t = caWidgetSetMonitor(pv, widget_ids.monitor)
    widget_control, widget_ids.start, sensitive=0
    widget_control, widget_ids.stop, sensitive=1
end

widget_ids.stop: begin
    t = caWidgetClearMonitor(pv, widget_ids.monitor) 
    widget_control, widget_ids.start, sensitive=1
    widget_control, widget_ids.stop, sensitive=0
end

widget_ids.adjust: begin
    t = caWidgetSetMonitor(pv, widget_ids.monitor)
    widget_control, widget_ids.start, sensitive=0
    widget_control, widget_ids.stop, sensitive=1
    caWidgetAdjust, pv, group=widget_ids.base
end

widget_ids.format: begin
    caprobe_format, group=widget_ids.base
end

widget_ids.help: begin
    caprobe_help, group=widget_ids.base
end

widget_ids.info: begin
    caprobe_info, pv, group=widget_ids.base
end

widget_ids.hist: begin
    caprobe_hist, hist_text, group=widget_ids.base
end

widget_ids.quit: begin
    t = caWidgetClearMonitor(pv, widget_ids.monitor)
    widget_control, event.top, /destroy
end

else: message, 'Unknown button pressed', /continue
endcase

end


pro caprobe_update_value, pv
common caprobe_main_common, widget_ids
@caprobe_common

   if (n_elements(pv) ne 0) then begin
	status = caGetCountAndType(pv, count, type)
	type = type(0)
	if ((type eq 0) or (type eq 3)) then status = caGet(pv, value, /string) $
	   else status = caget(pv, value, max=1)
	on_ioerror, bad_format
	case type of
	0:	text = value
	1:	text = string(value, format='(i)')
	2:	text = string(value, format='('+probe_format+')')
	3:	text = value
	4:	text = string(value, format='(i)')
	5:	text = string(value, format='(i)')
	6:	text = string(value, format='('+probe_format+')')
	endcase
	temp = pv+': '+systime()+'   Value: '+text
	if (n_elements(hist_text) lt 100) then start=0 else start=1
	hist_text = [hist_text(start:*), temp]
   endif else text=' '
   widget_control, widget_ids.value, set_value=text
   return
bad_format: probe_format='f10.4'
end


pro caprobe

common caprobe_main_common, widget_ids
@font_common
@caprobe_common

widget_ids = { $
	base:		0L, $
	value:		0L, $
        pv:             0L, $
        monitor:	0L, $
        name:		0L, $
        status:		0L, $
        start:		0L, $
        stop:		0L, $
        help:		0L, $
        quit:		0L, $
        adjust:		0L, $
        hist:		0L, $
        info:		0L, $
        format:		0L $
}

;small_font = '10x20'
;medium_font = '*times-bold*--18*'
;big_font = '*helvetica-bold*--24*'
base = widget_base(title='Channel Access Probe')
font_init
widget_control, base, default_font=medium_font
widget_ids.base = base
widget_ids.monitor = base
col1 = widget_base(base, column=1)
widget_ids.name   = widget_label(col1, value='Channel name ')
widget_ids.value  = widget_label(col1, value='Channel value ', font=large_font)
widget_ids.status = widget_label(col1, value='Status ', font=small_font)
widget_ids.pv     = widget_text(col1, value=' ', xsize=20, /edit)
widget_control, widget_ids.pv, set_uvalue=' '
row = widget_base(col1, row=1)
widget_ids.start   = widget_button(row, value='Start ')
widget_ids.stop    = widget_button(row, value='Stop  ')
widget_ids.help    = widget_button(row, value='Help  ')
widget_ids.quit    = widget_button(row, value='Quit  ')
row = widget_base(col1, row=1)
widget_ids.adjust  = widget_button(row, value='Adjust')
widget_ids.hist    = widget_button(row, value='Hist  ')
widget_ids.info    = widget_button(row, value='Info  ')
widget_ids.format  = widget_button(row, value='Format')
widget_control, widget_ids.start, sens=0
widget_control, widget_ids.stop, sens=0
widget_control, widget_ids.adjust, sens=0
widget_control, widget_ids.hist, sens=0
widget_control, widget_ids.info, sens=0
widget_control, base, /realize, /hourglass
probe_format = 'f10.4'
hist_text = ' '
xmanager, 'caprobe', base
end
