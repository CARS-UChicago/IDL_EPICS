pro caprobe_info_event, event

common caprobe_info_common, widget_ids

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



PRO caprobe_info, pv, group=group

common caprobe_info_common, widget_ids
@font_common

widget_ids = { $
        info:		0L, $
        exit:		0L $
}
base = widget_base(title='caProbe Info')
widget_control, base, default_font=small_font
col1 = widget_base(base, column=1)
status = caGetStatus(pv, timestamp, status, severity)
text = "Name: "+pv+" status: "+string(status)+" severity: "+string(severity)
widget_ids.info = widget_label(col1, $
      		value=text)
widget_ids.exit = widget_button(col1, value="Exit")
widget_control, base, /realize, /hourglass
xmanager, "caprobe_info", base, group_leader=group
end
