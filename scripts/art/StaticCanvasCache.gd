class_name StaticCanvasCache
extends RefCounted
## Rasterise detailed procedural art only when dirty. The rendering server consumes
## UPDATE_ONCE after a frame (the Node property may still report UPDATE_ONCE).
## No UPDATE_ALWAYS/WHEN_VISIBLE pass is left running every frame.
static func create(owner: Node, bounds: Rect2) -> SubViewport:
	var view: SubViewport = SubViewport.new()
	view.name = "StaticArtCache"
	view.size = Vector2i(bounds.size.ceil())
	view.transparent_bg = true
	view.disable_3d = true
	view.world_2d = World2D.new()
	view.gui_disable_input = true
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.render_target_update_mode = SubViewport.UPDATE_ONCE
	owner.add_child(view)
	view.canvas_transform = Transform2D(0, -bounds.position)
	return view

static func painter(view: SubViewport, original: Node2D, fields: Array[String]) -> Node2D:
	var copy: Node2D = original.get_script().new() as Node2D
	copy.set("_cache_source",true)
	copy.process_mode = Node.PROCESS_MODE_DISABLED
	copy.name = "PaintOnce"
	view.add_child(copy)
	refresh(view,original,fields)
	return copy

static func refresh(view: SubViewport, original: Node2D, fields: Array[String]) -> void:
	var copy: Node2D = view.get_child(0) as Node2D
	for field: String in fields: copy.set(field,original.get(field))
	copy.queue_redraw()
	view.render_target_update_mode = SubViewport.UPDATE_ONCE
