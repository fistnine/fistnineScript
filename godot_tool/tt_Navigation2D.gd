extends CharacterBody2D
#寻路脚本
#鼠标右键点击寻路
@onready var nga2d :NavigationAgent2D
@onready var timer :Timer
@onready var line2d :Line2D

var _speed = 300 #移动速度
var _movebox = 50 #键盘移动
var _interval = 0.1 #防止重复点击的时间间隔
var _minbox = 10 #防止鼠标点击距离过近的距离

func _init():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

	nga2d = NavigationAgent2D.new()
	nga2d.target_location = position
	nga2d.path_desired_distance = 5
	add_child(nga2d)

	line2d = Line2D.new()
	line2d.width = 2
	add_child(line2d)

func _process(delta):
	if timer.is_stopped():
		if Input.is_action_pressed("ui_left"):
			timer.start(_interval)
			nga2d.target_location = position - Vector2(_movebox,0)
		if Input.is_action_pressed("ui_right"):
			timer.start(_interval)
			nga2d.target_location = position + Vector2(_movebox,0)
		if Input.is_action_pressed("ui_up"):
			timer.start(_interval)
			nga2d.target_location = position - Vector2(0,_movebox)
		if Input.is_action_pressed("ui_down"):
			timer.start(_interval)
			nga2d.target_location = position + Vector2(0,_movebox)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if get_global_mouse_position()-position >= Vector2(_minbox,_minbox) || position-get_global_mouse_position() >= Vector2(_minbox,_minbox):
				timer.start(_interval)
				nga2d.target_location = get_global_mouse_position()
	pass

func _physics_process(delta):
	if nga2d.is_navigation_finished(): #导航到指定目的就return
		line2d.points = PackedVector2Array()
		velocity = Vector2()
		move_and_slide()
		nga2d.target_location = position
		return
	var pv2a :PackedVector2Array = nga2d.get_nav_path()
	for i in pv2a.size():
		pv2a[i] = pv2a[i] - position
	line2d.points = pv2a #以相对路径绘制路线
	nga2d.get_next_location()
	velocity = global_position.direction_to(nga2d.get_next_location()) * _speed
	move_and_slide()
	queue_redraw()
	pass
