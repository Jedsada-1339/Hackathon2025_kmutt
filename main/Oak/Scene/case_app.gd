extends Node2D

# ตัวแปรสำหรับการลาก Area2D
var dragging_area = null
var drag_offset = Vector2()

func _ready():
	# หา Area2D nodes ทั้งหมดใน scene และเชื่อมต่อ signals
	setup_draggable_areas()

func setup_draggable_areas():
	# หา Area2D nodes ทั้งหมด
	var areas = get_tree().get_nodes_in_group("draggable")
	if areas.is_empty():
		# ถ้าไม่มี group ให้หา Area2D ทั้งหมด
		areas = find_children("*", "Area2D")
	
	# เชื่อมต่อ signals สำหรับแต่ละ Area2D
	for area in areas:
		if area.has_signal("input_event"):
			area.input_event.connect(_on_area_input_event.bind(area))
		if area.has_signal("mouse_entered"):
			area.mouse_entered.connect(_on_area_mouse_entered.bind(area))
		if area.has_signal("mouse_exited"):
			area.mouse_exited.connect(_on_area_mouse_exited.bind(area))

func _on_area_input_event(area: Area2D, viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# เริ่มลาก Area2D นี้
				start_dragging(area)
			else:
				# หยุดลาก
				stop_dragging()

func start_dragging(area: Area2D):
	dragging_area = area
	drag_offset = area.global_position - get_global_mouse_position()
	print("เริ่มลาก: ", area.name)

func stop_dragging():
	if dragging_area:
		print("หยุดลาก: ", dragging_area.name)
	dragging_area = null

func _process(delta):
	if dragging_area:
		# อัปเดตตำแหน่งของ Area2D ที่กำลังลาก
		dragging_area.global_position = get_global_mouse_position() + drag_offset

func _on_area_mouse_entered(area: Area2D):
	# เปลี่ยน cursor เป็น hand
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _on_area_mouse_exited(area: Area2D):
	# คืน cursor เป็นปกติ ถ้าไม่กำลังลาก
	if dragging_area != area:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# ฟังก์ชันสำหรับสร้าง Area2D ใหม่ (ถ้าต้องการ)
func create_draggable_area(pos: Vector2, size: Vector2 = Vector2(100, 100)):
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	
	# ตั้งค่า shape
	rect_shape.size = size
	collision.shape = rect_shape
	area.add_child(collision)
	
	# เพิ่ม visual (สี่เหลี่ยมสีแดง)
	var color_rect = ColorRect.new()
	color_rect.size = size
	color_rect.position = -size / 2
	color_rect.color = Color.RED
	color_rect.color.a = 0.5
	area.add_child(color_rect)
	
	# ตั้งตำแหน่ง
	area.global_position = pos
	area.name = "DraggableArea_" + str(get_child_count())
	
	# เพิ่มเข้า scene
	add_child(area)
	
	# เชื่อมต่อ signals
	area.input_event.connect(_on_area_input_event.bind(area))
	area.mouse_entered.connect(_on_area_mouse_entered.bind(area))
	area.mouse_exited.connect(_on_area_mouse_exited.bind(area))
	
	return area

# ตัวอย่างการใช้งาน - สร้าง Area2D ใหม่เมื่อกด Space
func _input(event):
	if event.is_action_pressed("ui_accept"): # Space key
		var mouse_pos = get_global_mouse_position()
		create_draggable_area(mouse_pos)
