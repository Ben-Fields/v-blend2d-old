module main

import blend2d

import gg
import gx
import sokol.sapp

struct App {
	mut:
	g			&gg.Context = voidptr(0)
	blimg		&blend2d.Image = voidptr(0)
	ggimg		&gg.Image = voidptr(0)
	// b			&blend2d.Context = voidptr(0)
	codec		&blend2d.ImageCodec = voidptr(0)
}

fn on_event(e &gg.Event, mut app App) {
	if e.typ == .key_down {
		//game.key_down(e.key_code)
	}
}

fn frame(mut app App) {
	app.g.begin()

	update_img(mut app)

	dat, len := app.blimg.write_to_memory(app.codec) or {
		println("Could not get resources to write image to memory.")
		println(err)
		return
	}

	println(int(len))
	println(dat)

	// app.ggimg = app.g.create_image_from_memory(app.blimg.impl.pixelData, 400*400)
	new_img := app.g.create_image_from_memory(dat, int(len))
	// app.ggimg = &new_img
	// app.g.draw_image(0,0,400,400,app.ggimg)
	app.g.draw_image(0,0,400,400,new_img)

	app.g.end()
}

[console]
fn main() {
	println('Begin main.')
	mut app := &App {
		g: 0
	}
	app.g = gg.new_context({
		bg_color: gx.black
		width: 200
		height: 100
		use_ortho: true 
		create_window: true
		window_title: 'V Graphics Base Test' 
		user_data: app
		init_fn: init_img
		frame_fn: frame
		event_fn: on_event
		font_path: '../fake/path' 
	})
	app.g.run()
	println('End main.')
}

fn init_img(mut app App) {
	app.blimg = blend2d.new_image(480, 480, .prgb32) or {
		println("Error: Could not create image.")
		println(err)
		return
	}
	// app.b = blend2d.new_context(app.blimg) or {
	// 	println("Error: Could not create context")
	// 	println(err)
	// 	return
	// }

	app.codec = blend2d.new_codec_by_name('BMP') or {
		println("Error: Could not create codec.")
		println(err)
		return
	}
}

fn update_img(mut app App) {
	// img := blend2d.new_image(480, 480, .prgb32)?

	// Attach a rendering context into `img`.
	b := blend2d.new_context(app.blimg) or {
		println("Context creation: $err")
		return
	}

	// Clear the image.
	b.set_comp_op(.src_copy)
	b.fill_all()

	// Fill some path.
	path := blend2d.new_path()
	path.move_to(26, 31)
	path.cubic_to(642, 132, 587, -136, 25, 464)
	path.cubic_to(882, 404, 144, 267, 27, 31)

	b.set_comp_op(.src_over)
	b.set_fill_style(blend2d.new_rgba32(0xFFFFFFFF))
	b.fill_path(path)

	// Detach the rendering context from `img`.
	b.end()
}