pro caprobe_help_event, event

common caprobe_help_common, widget_ids

case event.id of

    widget_ids.exit: begin
	monitor_active=0
	widget_control, event.top, /destroy
    end

    else: message, "Unknown button pressed", /continue

endcase

end



PRO caprobe_help, group=group

common caprobe_help_common, widget_ids
@font_common

widget_ids = { $
        help:		0L, $
        exit:		0L $
}
base = widget_base(title='caProbe Help')
widget_control, base, default_font=small_font
col1 = widget_base(base, column=1)
widget_ids.help = widget_label(col1, $
                 value='caProbe Version 1.0 - No help available')
widget_ids.exit = widget_button(col1, value="Exit")
widget_control, base, /REALIZE, /HOURGLASS
xmanager, "caprobe_help", base, group_leader=group
end
