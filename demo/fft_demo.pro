pro fft_demo_event, event
; This is the event routine, called whenever a widget event or a timer
; event is received.

@fft_demo_common

case event.id of

   widget_ids.timer: begin
        n = n_elements(line_data)
        t = caput(pv_names.proc, 1)		; Collect a new data point
	t = caget(pv_names.data, data)

	!p = ranges.plot_p			; Plot the time history
        wset, windows.plot
        !x = ranges.plot_x
	!y = ranges.plot_y
        oplot, line_data, color=0
        line_data = [line_data(1:*),data]
        oplot, line_data

	!p = ranges.fft_p			; Plot the 1-D FFT
        wset, windows.fft_plot
        !x = ranges.fft_x
	!y = ranges.fft_y
        oplot, fft_data, color=0
	fft_data = alog(abs(fft(line_data, -1)))
	fft_data = fft_data(0:n/2-1)
        oplot, fft_data
        
	counter = counter + 1
        if (counter eq n) then begin		; After one row is collected...
	   counter=0
           image_data = shift(image_data, 0, 1)	; Display the time series image
           image_data(0,0) = line_data
           wset, windows.image
           tvscl, rebin(image_data, window_size, window_size)
           xyouts, /normal, align=0.5, size=1.5, .5, .9, '2-D Time Series'
           t = abs(alog(fft(image_data, -1)))	; Display the 2-D FFT image
           t = rebin(shift(t, n/2, n/2), window_size, window_size)
           wset, windows.fft_image
           tvscl, t
           xyouts, /normal, align=0.5, size=1.5, .5, .9, '2-D FFT'
        endif
      widget_control, event.id, timer=dwell_time
   end

   widget_ids.freq: caWidgetAdjust, pv_names.freq, min=0, max=4.5, $
			label='Frequency', group=widget_ids.base

   widget_ids.noise: caWidgetAdjust, pv_names.noise, min=0, max=2, $
			label='Noise amplitude', group=widget_ids.base

   widget_ids.colors: xloadct

   widget_ids.dwell_time: widget_control, event.id, get_value=dwell_time

   widget_ids.exit: widget_control, event.top, /destroy

   else: message, "Unknown button pressed", /continue
endcase

end


pro fft_demo
@fft_demo_common
@font_common

widget_ids = { $
	base:		0L, $
	timer:		0L, $
	plot:		0L, $
	fft_plot:	0L, $
	image:		0L, $
	fft_image:	0L, $
        freq:		0L, $
	noise:		0L, $
	dwell_time:	0L, $
        colors:		0L, $
	exit:		0L $
}

n = 64
counter = 0
window_size = n*5
base = widget_base(title="FFT Demo", /row)
font_init
widget_control, base, default_font=medium_font
widget_ids.base = base
widget_ids.timer = base
tbase = widget_base(base, /column)
dwell_time = .05
widget_ids.dwell_time = cw_fslider(tbase, min=0.001, max=1, /drag, /edit, $
                                   title='Dwell time', /frame, value=dwell_time)
widget_ids.freq = widget_button(tbase, value="Frequency")
widget_ids.noise = widget_button(tbase, value="Noise Amplitude")
widget_ids.colors = widget_button(tbase, value="Colors")
widget_ids.exit = widget_button(tbase, value="Exit")
tbase = widget_base(base, /column)
widget_ids.plot = widget_draw(tbase, xsize=window_size, ysize=window_size)
widget_ids.image = widget_draw(tbase, xsize=window_size, ysize=window_size)
tbase = widget_base(base, /column)
widget_ids.fft_plot = widget_draw(tbase, xsize=window_size, ysize=window_size)
widget_ids.fft_image = widget_draw(tbase, xsize=window_size, ysize=window_size)
widget_control, base, /realize
widget_control, widget_ids.timer, timer=dwell_time

windows = { $
	plot:		0L, $
	fft_plot:	0L, $
	image:		0L, $
	fft_image:	0L $
}

widget_control, widget_ids.plot, get_value=t
windows.plot = t
widget_control, widget_ids.fft_plot, get_value=t
windows.fft_plot = t
widget_control, widget_ids.image, get_value=t
windows.image = t
widget_control, widget_ids.fft_image, get_value=t
windows.fft_image = t

pv_names = { $
	data:	'fft_sin.VAL', $
        proc:   'fft_counter.PROC', $
	freq:	'fft_freq.VAL', $
	noise:	'fft_noise.VAL' $
}

ranges = { $
        plot_p:		!p, $
	plot_x:		!x, $
	plot_y:		!y, $
        fft_p:		!p, $
	fft_x:		!x, $
	fft_y:		!y $
}
line_data = dindgen(n) * 0.001		; Create time series data array
image_data = dblarr(n, n)
fft_data = alog(abs(fft(line_data, -1))) ; Create 1-D FFT array
fft_data = fft_data(0:n/2-1)
wset, windows.plot			; Create time series plot, labels, etc.
plot, line_data, xrange=[-1, n], yrange=[-2,2], xstyle=1, $
	title='Time series'
ranges.plot_p = !p
ranges.plot_x = !x
ranges.plot_y = !y
wset, windows.fft_plot			; Create 1-D FFT plot, labels, etc.
plot, fft_data, xrange=[-1,n/2], yrange=[-10,0], xstyle=1, $
	title='1-D FFT'
ranges.fft_p = !p
ranges.fft_x = !x
ranges.fft_y = !y

xmanager, "fft_demo", base
end
