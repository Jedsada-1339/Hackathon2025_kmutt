extends Control

@onready var vbox = $ScrollContainer/VBoxContainer
@onready var case_template = preload("res://Oak/Scene/case_list.tscn")  # แก้ path ให้ตรงกับของคุณ
# หากยังไม่ได้ ให้ลองเปลี่ยน path เหล่านี้ตามโครงสร้างจริงของคุณ:
@onready var name_display_label = $name  # หรือ $Box_detail/name หรือ path อื่นที่ถูกต้อง
@onready var detail_display_label = $detail  # หรือ $Box_detail/detail หรือ path อื่นที่ถูกต้อง
@onready var type_display_label = $type  # Label ใหม่สำหรับแสดงประเภท

# ทางเลือกอื่น - ถ้าอยู่ในโครงสร้างที่ซับซ้อนกว่า:
# @onready var name_display_label = $VBoxContainer/name
# @onready var detail_display_label = $VBoxContainer/detail
# @onready var type_display_label = $VBoxContainer/type

func _ready():
	# เพิ่มรายการผ่านโค้ดทันที
	add_case("สมชาย", "website", "นาย สมชาย ใจดี อายุ 35 ปี ทำงานในแผนก IT มานาน 8 ปี มีความเชี่ยวชาญด้านการพัฒนาซอฟต์แวร์ และการจัดการระบบเครือข่าย เป็นคนที่มีความรับผิดชอบสูงและเป็นมิตรกับเพื่อนร่วมงานทุกคน")
	add_case("แอนนา", "deepfake", "คุณ แอนนา สมิธ ลูกค้า VIP ของบริษัท ใช้บริการมานานกว่า 3 ปี มักจะสั่งซื้อสินค้าในปริมาณมาก เป็นคนใจดี และให้ความร่วมมือในการทดสอบสินค้าใหม่เป็นอย่างดี มีความต้องการพิเศษในเรื่องการจัดส่งสินค้า")
	add_case("ก้อง", "deepfake", "พี่ ก้อง รุ่นพี่ในมหาวิทยาลัย คณะวิศวกรรมศาสตร์ จบการศึกษามาแล้ว 5 ปี ปัจจุบันทำงานในบริษัทเอกชนขนาดใหญ่ เป็นคนที่ให้คำแนะนำดีๆ เสมอ และคอยช่วยเหลือน้องๆ ทั้งในเรื่องงานและชีวิต")

func add_case(name_text: String, relation_text: String, detailed_info: String):
	var new_case = case_template.instantiate()
	
	# เข้าถึง node ภายใน case_list
	var name_label = new_case.get_node("name")
	var detail_label_case = new_case.get_node("detail")
	var button = new_case.get_node("Button")  # เข้าถึง Button ใน case_list
	
	# ตั้งค่าข้อความ
	name_label.text = name_text
	detail_label_case.text = relation_text
	
	# เพิ่ม case ใหม่เข้าไปใน VBoxContainer
	vbox.add_child(new_case)
	
	# เชื่อมต่อสัญญาณของ Button พร้อมส่งข้อมูลรายละเอียด
	button.pressed.connect(_on_case_selected.bind(name_text, relation_text, detailed_info))

func _on_case_selected(name_text: String, relation_text: String, detailed_info: String):
	show_case_detail(name_text, relation_text, detailed_info)

func show_case_detail(name_text: String, relation_text: String, detailed_info: String):
	# วิธีปลอดภัย - ลองหลาย path
	var name_display = null
	var detail_display = null
	var type_display = null
	
	# ลอง path ต่างๆ สำหรับ name
	if has_node("name"):
		name_display = get_node("name")
	elif has_node("Box_detail/name"):
		name_display = get_node("Box_detail/name")
	
	# ลอง path ต่างๆ สำหรับ detail
	if has_node("detail"):
		detail_display = get_node("detail")
	elif has_node("Box_detail/detail"):
		detail_display = get_node("Box_detail/detail")
	
	# ลอง path ต่างๆ สำหรับ type
	if has_node("type"):
		type_display = get_node("type")
	elif has_node("Box_detail/type"):
		type_display = get_node("Box_detail/type")
	
	# แสดงข้อมูล
	if name_display:
		name_display.text = name_text
	if detail_display:
		detail_display.text = detailed_info
	if type_display:
		type_display.text = relation_text  # แสดงประเภทความสัมพันธ์
