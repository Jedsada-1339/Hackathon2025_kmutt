extends Node2D

func _ready():
	spawn_chat("มานี","แม่")
	spawn_chat("มานี","แม่")
	spawn_chat("มานี","แม่")

#สร้างข้อมูลใส่ Chatlist
var ProblemScene := preload("res://Dove/scene/chatlist_template.tscn")

func spawn_chat(name_text: String, role: String):
	var case_instance = ProblemScene.instantiate()

	# ตั้งค่าข้อความ
	case_instance.get_node("name").text = name_text
	case_instance.get_node("role").text = "ความสัมพันธ์ : %s" % role

	# เปลี่ยน Avatar (TextureRect)
	#var avatar_node = case_instance.get_node("TextureRect")
	#var new_texture = load(avatar_path)
	#if avatar_node and new_texture:
		#avatar_node.texture = new_texture
		
	# จัดการปุ่ม
	var button_node = case_instance.get_node("Button")
	#if button_node:
		#button_node.pressed.connect(show_chat.bind(chat_detail))

	# เพิ่มเข้า VBoxContainer
	$Chat/chatlist/VBoxContainer.add_child(case_instance)
