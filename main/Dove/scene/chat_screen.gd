extends Node2D

# ระบบจัดการหลายแชท
var chat_sessions = {}  # เก็บข้อมูลแชทแต่ละคน
var current_chat_id = ""  # แชทที่กำลังเปิดอยู่
var is_typing = false
var typing_speed = 0.05

func _ready():
	$Chat/chat_detail.hide()
	$Chat/Answer.hide()
	
	# สร้างข้อมูลตัวอย่าง
	setup_example_chats()
	
	# สร้าง UI รายการแชท
	spawn_chat("มานี", "แม่", "chat_001")
	spawn_chat("สมชาย", "เพื่อน", "chat_002")
	spawn_chat("นางสาวใส", "คนแปลกหน้า", "chat_003")

# ตั้งค่าข้อมูลแชทตัวอย่าง
func setup_example_chats():
	# แชท 1: มานี (แม่)
	chat_sessions["chat_001"] = {
		"name": "มานี",
		"role": "แม่",
		"avatar_path": "res://avatars/mom.png",
		"current_index": 0,
		"history": [
			{"speaker": "npc", "text": "ลูก กินข้าวแล้วหรือยัง?"},
			{"speaker": "user_choice", "choices": [
				{"text": "กินแล้วครับ", "next": 3},
				{"text": "ยังครับ รอสักครู่", "next": 5}
			]},
			{"speaker": "npc", "text": "ดีแล้ว อย่าลืมดื่มน้ำด้วยนะ"},
			{"speaker": "npc", "text": "แล้วการบ้านทำหรือยัง?"},
			{"speaker": "npc", "text": "เอาละ ไปทำการบ้านก่อนนะ"},  # index 5
			{"speaker": "npc", "text": "เดี๋ยวแม่เตรียมข้าวให้"}
		]
	}
	
	# แชท 2: สมชาย (เพื่อน)
	chat_sessions["chat_002"] = {
		"name": "สมชาย", 
		"role": "เพื่อน",
		"avatar_path": "res://avatars/friend.png",
		"current_index": 0,
		"history": [
			{"speaker": "npc", "text": "เฮ้ย! เที่ยวกันมั้ย?"},
			{"speaker": "user_choice", "choices": [
				{"text": "ไปสิ ไปไหน?", "next": 3},
				{"text": "วันนี้ไม่ว่าง", "next": 5}
			]},
			{"speaker": "npc", "text": "ไปดูหนังกัน มีหนังใหม่"},
			{"speaker": "npc", "text": "เจอกันที่โรงหนังเลย!"},
			{"speaker": "npc", "text": "โอเค เข้าใจ"},  # index 5
			{"speaker": "npc", "text": "เดี๋ยวไปกันคราวหน้านะ"}
		]
	}
	
	# แชท 3: นางสาวใส (คนแปลกหน้า)
	chat_sessions["chat_003"] = {
		"name": "นางสาวใส",
		"role": "คนแปลกหน้า", 
		"avatar_path": "res://avatars/stranger.png",
		"current_index": 0,
		"history": [
			{"speaker": "npc", "text": "สวัสดีครับ คุณช่วยอะไรผมได้ไหม"},
			{"speaker": "user_choice", "choices": [
				{"text": "แน่นอนครับ!", "next": 3},
				{"text": "ขอโทษครับ ผมไม่ว่าง", "next": 8}
			]},
			{"speaker": "npc", "text": "ขอบคุณมาก!"},
			{"speaker": "npc", "text": "ผมทำของหายครับ แถว ๆ ตลาด"},
			{"speaker": "user_choice", "choices": [
				{"text": "ไปช่วยตอนนี้เลย", "next": 6},
				{"text": "ขอรายละเอียดก่อนได้ไหม", "next": 7}
			]},
			{"speaker": "npc", "text": "ขอบคุณจริง ๆ ครับ! คุณใจดีมาก"},  # index 6
			{"speaker": "npc", "text": "ของที่ผมหายเป็นกระเป๋าสีดำ มีเอกสารสำคัญอยู่"},  # index 7
			{"speaker": "npc", "text": "ไม่เป็นไรครับ ไว้คราวหน้า"}  # index 8
		]
	}

#สร้างข้อมูลใส่ Chatlist
var ProblemScene := preload("res://Dove/scene/chatlist_template.tscn")

func spawn_chat(name_text: String, role: String, chat_id: String):
	var case_instance = ProblemScene.instantiate()

	# ตั้งค่าข้อความ
	case_instance.get_node("name").text = name_text
	case_instance.get_node("role").text = "ความสัมพันธ์ : %s" % role

	# จัดการปุ่ม - เชื่อมกับฟังก์ชันเปิดแชท
	var button_node = case_instance.get_node("Button")
	if button_node:
		button_node.pressed.connect(open_chat.bind(chat_id))

	# เพิ่มเข้า VBoxContainer
	$Chat/chatlist/VBoxContainer.add_child(case_instance)

# ฟังก์ชันเปิดแชทตาม ID
func open_chat(chat_id: String):
	if not chat_sessions.has(chat_id):
		print("❌ ไม่พบแชท ID: ", chat_id)
		return
	
	current_chat_id = chat_id
	
	# ซ่อน chatlist แสดง chat_detail
	$Chat/chatlist.hide()
	$Chat/chat_detail.show()
	$Chat/Answer.show()
	
	# ล้างข้อความเก่า
	clear_chat_bubbles()
	
	# โหลดประวัติแชท (ถ้ามี)
	load_chat_history(chat_id)
	
	# แสดงบทสนทนา
	show_dialog()

# ล้างข้อความแชท
func clear_chat_bubbles():
	var chat_container = $Chat/chat_detail/VBoxContainer
	for child in chat_container.get_children():
		child.queue_free()
	
	var choice_container = $Chat/Answer/ScrollContainer/Choice_VBoxContainer
	for child in choice_container.get_children():
		child.queue_free()

# โหลดประวัติแชท (ถ้ามีข้อความที่คุยไปแล้ว)
func load_chat_history(chat_id: String):
	var session = chat_sessions[chat_id]
	
	# ถ้ามีประวัติการสนทนาแล้ว ให้แสดงขึ้นมา
	if session.has("chat_history"):
		for bubble_data in session["chat_history"]:
			if bubble_data["type"] == "npc":
				add_npc_bubble_instant(bubble_data["text"])
			elif bubble_data["type"] == "user":
				add_user_bubble_instant(bubble_data["text"])

# ฟังก์ชันกลับไปหน้า chatlist
func back_to_chatlist():
	$Chat/chatlist.show()
	$Chat/chat_detail.hide()
	$Chat/Answer.hide()
	current_chat_id = ""

# ฟังก์ชัน Dialog System
func show_dialog():
	if current_chat_id == "":
		return
	
	var session = chat_sessions[current_chat_id]
	
	if session["current_index"] >= session["history"].size():
		print("End of dialog for chat: ", current_chat_id)
		return
	
	# หยุดถ้ากำลังพิมพ์อยู่
	if is_typing:
		return
		
	var entry = session["history"][session["current_index"]]
	
	if entry["speaker"] == "npc":
		add_npc_bubble(entry["text"])
		session["current_index"] += 1
	elif entry["speaker"] == "user":
		add_user_bubble(entry["text"])
		session["current_index"] += 1
	elif entry["speaker"] == "user_choice":
		show_choices(entry["choices"])

func show_choices(choices):
	var choice_template := preload("res://Dove/scene/choice_button_template.tscn")
	var choice_container = $Chat/Answer/ScrollContainer/Choice_VBoxContainer
	
	# ล้างตัวเลือกเก่า
	for child in choice_container.get_children():
		child.queue_free()
	
	for choice in choices:
		var case_instance = choice_template.instantiate()
		var button_node = case_instance.get_node("Button")
		var label_button_node = case_instance.get_node("Choice")
		
		if button_node == null:
			print("❌ ไม่พบปุ่ม Button ใน template")
			continue
			
		label_button_node.text = choice["text"]
		button_node.pressed.connect(func():
			var session = chat_sessions[current_chat_id]
			session["current_index"] = choice["next"]
			
			# ล้างปุ่มเลือก
			for child in choice_container.get_children():
				child.queue_free()
			
			add_user_bubble(choice["text"])
		)
		choice_container.add_child(case_instance)
	
	scroll_to_bottom()

func add_npc_bubble(text):
	var bubble = preload("res://Dove/scene/npc_chat_template.tscn").instantiate()
	var label = bubble.get_node("MarginContainer/MarginContainer/Label")
	label.text = text
	$Chat/chat_detail/VBoxContainer.add_child(bubble)
	
	# บันทึกประวัติ
	save_bubble_to_history("npc", text)
	
	scroll_to_bottom()
	start_typing_animation(label)

func add_user_bubble(text):
	var bubble = preload("res://Dove/scene/user_chat_template.tscn").instantiate()
	var label = bubble.get_node("MarginContainer/MarginContainer/Label")
	label.text = text
	$Chat/chat_detail/VBoxContainer.add_child(bubble)
	
	# บันทึกประวัติ
	save_bubble_to_history("user", text)
	
	scroll_to_bottom()
	start_typing_animation(label)

# เพิ่มข้อความแบบทันที (ไม่มี animation) สำหรับโหลดประวัติ
func add_npc_bubble_instant(text):
	var bubble = preload("res://Dove/scene/npc_chat_template.tscn").instantiate()
	var label = bubble.get_node("MarginContainer/MarginContainer/Label")
	label.text = text
	label.visible_ratio = 1.0
	$Chat/chat_detail/VBoxContainer.add_child(bubble)

func add_user_bubble_instant(text):
	var bubble = preload("res://Dove/scene/user_chat_template.tscn").instantiate()
	var label = bubble.get_node("MarginContainer/MarginContainer/Label")
	label.text = text
	label.visible_ratio = 1.0
	$Chat/chat_detail/VBoxContainer.add_child(bubble)

# บันทึกข้อความลงประวัติ
func save_bubble_to_history(type: String, text: String):
	if current_chat_id == "":
		return
	
	var session = chat_sessions[current_chat_id]
	if not session.has("chat_history"):
		session["chat_history"] = []
	
	session["chat_history"].append({
		"type": type,
		"text": text
	})

func start_typing_animation(label: Label):
	is_typing = true
	label.visible_ratio = 0.0
	
	var tween = create_tween()
	var text_length = label.text.length()
	var duration = text_length * typing_speed
	
	tween.tween_property(label, "visible_ratio", 1.0, duration)
	tween.tween_callback(func():
		is_typing = false
		if current_chat_id != "":
			var session = chat_sessions[current_chat_id]
			var current_entry = session["history"][session["current_index"] - 1]
			if current_entry["speaker"] in ["npc", "user"]:
				show_dialog()
	)

func skip_typing():
	if is_typing:
		var tweens = get_tree().get_nodes_in_group("typing_tweens")
		for tween in tweens:
			if tween.is_valid():
				tween.kill()
		
		var chat_container = $Chat/chat_detail/VBoxContainer
		if chat_container.get_child_count() > 0:
			var last_bubble = chat_container.get_child(chat_container.get_child_count() - 1)
			var label = last_bubble.get_node("MarginContainer/MarginContainer/Label")
			label.visible_ratio = 1.0
		
		is_typing = false
		show_dialog()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			skip_typing()
		elif event.keycode == KEY_ESCAPE:
			back_to_chatlist()

func scroll_to_bottom():
	await get_tree().process_frame
	
	var scroll_container = $Chat/chat_detail
	if scroll_container is ScrollContainer:
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	
	var alt_scroll = $Chat/Answer/ScrollContainer
	if alt_scroll and alt_scroll is ScrollContainer:
		alt_scroll.scroll_vertical = alt_scroll.get_v_scroll_bar().max_value

# ฟังก์ชันเพิ่ม: เพิ่มแชทใหม่แบบไดนามิก
func add_new_chat(chat_id: String, name: String, role: String, dialog_history: Array):
	chat_sessions[chat_id] = {
		"name": name,
		"role": role,
		"avatar_path": "res://avatars/default.png",
		"current_index": 0,
		"history": dialog_history
	}
	spawn_chat(name, role, chat_id)

# ฟังก์ชันเซฟ/โหลดข้อมูลแชท (เพิ่มเติม)
func save_all_chats_to_file():
	var file = FileAccess.open("user://chat_data.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(chat_sessions))
		file.close()
		print("✅ บันทึกข้อมูลแชทแล้ว")

func load_chats_from_file():
	var file = FileAccess.open("user://chat_data.save", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			chat_sessions = json.data
			print("✅ โหลดข้อมูลแชทแล้ว")
		else:
			print("❌ ไม่สามารถโหลดข้อมูลแชท")
