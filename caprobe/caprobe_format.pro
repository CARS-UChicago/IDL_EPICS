pro caprobe_format_event, event
common caprobe_format_common, widget_ids
@caprobe_common

case event.id of
   widget_ids.format: begin
    	   widget_control, event.id, get_value=temp
	   probe_format=temp(0)
   end

   widget_ids.exit: begin
	widget_control, event.top, /destroy
   end
endcase

end



PRO caprobe_format, group=group
common caprobe_format_common, widget_ids
@caprobe_common
@font_common

widget_ids = { $
        format:		0L, $
        exit:		0L $
}
base = widget_base(title='caProbe format')
widget_control, base, default_font=small_font
col1 = widget_base(base, column=1)
widget_ids.format = widget_text(col1, value=probe_format, /edit)
widget_ids.exit = widget_button(col1, value="Exit")
widget_control, base, /realize, /hourglass
xmanager, "caprobe_format", base, group_leader=group
end
