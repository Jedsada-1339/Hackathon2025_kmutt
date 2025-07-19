extends Node2D

# ตัวแปรสำหรับจัดการ windows
var active_window = null
var window_z_index = 0

# ตัวแปรสำหรับการลาก
var dragging_window = null
var drag_offset = Vector2()

func _ready():
	# ตั้งค่าเริ่มต้นสำหรับทุก window
	setup_windows()

func setup_windows():
	# หา Case_windows node และตั้งค่า
	var case_windows = get_node("Case_windows")
	if case_windows:
		print("กำลังตั้งค่า Case_windows: ", case_windows.get_class())
		setup_window_dragging(case_windows)
	else:
		print("ไม่พบ Case_windows node")
	
	# หา windows node และตั้งค่า (ถ้ามี)  
	if has_node("windows"):
		var windows = get_node("windows")
		print("กำลังตั้งค่า windows children")
		for child in windows.get_children():
			if child is Area2D or child is Control:
				setup_window_dragging(child)

func setup_window_dragging(window_node):
	print("กำลังตั้งค่า node: ", window_node.name, " ประเภท: ", window_node.get_class())
	
	# ตั้งค่าให้ window สามารถรับ input ได้
	if window_node is Area2D:
		window_node.input_pickable = true
		# เชื่อมต่อ signals
		if not window_node.is_connected("input_event", _on_window_input_event):
			window_node.connect("input_event", _on_window_input_event.bind(window_node))
		if not window_node.is_connected("mouse_entered", _on_window_mouse_entered):
			window_node.connect("mouse_entered", _on_window_mouse_entered.bind(window_node))
		if not window_node.is_connected("mouse_exited", _on_window_mouse_exited):
			window_node.connect("mouse_exited", _on_window_mouse_exited.bind(window_node))
		print("ตั้งค่า Area2D เสร็จแล้ว")
	
	elif window_node is Control:
		# สำหรับ Control nodes
		window_node.mouse_filter = Control.MOUSE_FILTER_PASS
		if not window_node.is_connected("gui_input", _on_window_gui_input):
			window_node.connect("gui_input", _on_window_gui_input.bind(window_node))
		print("ตั้งค่า Control เสร็จแล้ว")
	
	else:
		print("Node ประเภท ", window_node.get_class(), " ไม่รองรับ")

func _on_window_input_event(viewport, event, shape_idx, window_node):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# เริ่มการลาก
				start_dragging(window_node, event.global_position)
			else:
				# หยุดการลาง
				stop_dragging()

func _on_window_gui_input(event, window_node):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# เริ่มการลาก
				start_dragging(window_node, event.global_position)
			else:
				# หยุดการลาก
				stop_dragging()

func start_dragging(window_node, mouse_pos):
	dragging_window = window_node
	drag_offset = window_node.global_position - mouse_pos
	
	# ทำให้ window ที่กำลังลากอยู่ข้างหน้าสุด
	bring_to_front(window_node)
	
	# เปลี่ยน cursor
	Input.set_default_cursor_shape(Input.CURSOR_MOVE)
	
	print("เริ่มลาก window: ", window_node.name)

func stop_dragging():
	if dragging_window:
		print("หยุดลาก window: ", dragging_window.name)
		dragging_window = null
		
		# เปลี่ยน cursor กลับ
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func bring_to_front(window_node):
	# เพิ่ม z_index เพื่อให้ window อยู่ข้างหน้า
	window_z_index += 1
	window_node.z_index = window_z_index
	active_window = window_node

func _process(delta):
	# อัพเดทตำแหน่ง window ขณะลาก
	if dragging_window:
		dragging_window.global_position = get_global_mouse_position() + drag_offset

func _on_window_mouse_entered(window_node):
	# เปลี่ยน cursor เมื่อเมาส์เข้า window
	if not dragging_window:
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
	print("เมาส์เข้า window: ", window_node.name)

func _on_window_mouse_exited(window_node):
	# เปลี่ยน cursor กลับเมื่อเมาส์ออกจาก window
	if not dragging_window:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	print("เมาส์ออก window: ", window_node.name)

# ฟังก์ชันเพิ่มเติมสำหรับจัดการ windows
func close_window(window_node):
	if window_node == active_window:
		active_window = null
	window_node.queue_free()

func minimize_window(window_node):
	# ซ่อน window (สามารถปรับแต่งได้)
	window_node.visible = false

func restore_window(window_node):
	# แสดง window กลับมา
	window_node.visible = true
	bring_to_front(window_node)

# ฟังก์ชันสำหรับสร้าง window ใหม่
func create_new_window(window_scene_path: String, position: Vector2 = Vector2.ZERO):
	var new_window = load(window_scene_path).instantiate()
	add_child(new_window)
	
	if position != Vector2.ZERO:
		new_window.global_position = position
	
	setup_window_dragging(new_window)
	bring_to_front(new_window)
	
	return new_window
