pro caprobe_hist_event, event

common caprobe_hist_common, widget_ids

case event.id of

   widget_ids.exit: begin
	monitor_active=0
	widget_control, event.top, /destroy
   end

   else: begin
	message, "Unknown button pressed", /continue
   end

endcase

end



PRO caprobe_hist, hist_text, group=group

common caprobe_hist_common, widget_ids
@font_common

widget_ids = { $
        hist:		0L, $
        exit:		0L $
}
base = widget_base(title='caProbe History')
widget_control, base, default_font=small_font
col1 = widget_base(base, column=1)
widget_ids.hist = widget_text(col1, value=hist_text(0), /scroll, $
				xsize=80, ysize=10)
for i=1,n_elements(hist_text)-1 do begin
   widget_control, widget_ids.hist, set_value=hist_text(i), /append
endfor
widget_ids.exit = widget_button(col1, value="Exit")
widget_control, base, /realize, /hourglass
xmanager, "caprobe_hist", base, group_leader=group
end
