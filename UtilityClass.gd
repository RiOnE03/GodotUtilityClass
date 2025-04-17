## A General purpose class filled with a bunch of functions and classes that can be helpful.
class_name Utility extends Object


# /******************************************************************************************************************************
# Description:
#
#
#~~~~~~~~~~~~~~~~~~Static functions (Can be called and used directly)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#
# 1. polar:
#       Detail: 
# 2. generate_timer:
#       Detail: 
#
# 3. mirror: 
#/******************************************************************************************************************************


## This function return 1 if true else -1, however the result is flipped if reverse is true.
## This function is useful for cases like when you want to find the direction where the sprite
## is facing using its flip_h
static func polar(boolean: bool, reverse: bool = false)->int:
	var result: int = 1 if boolean else -1
	return -result if reverse else result

## Creates a timer that can be directly added instead of defining its paramters first in multiple lines
static func generate_timer(duration: int = 1, link: Callable = Callable(), autostart: bool = false, one_shot:bool = true, process_callback:int = Timer.TIMER_PROCESS_PHYSICS)->Timer:
	var timer: Timer = Timer.new()
	timer.process_callback = process_callback
	timer.wait_time = duration
	timer.autostart = autostart
	timer.one_shot = one_shot
	if link.is_valid():
		timer.timeout.connect(link)
	return timer

##Currently only works for 2d scene but will be updated in the future.
##This function can be called to invidually create a mirror for your already pleaced nodes. Like in those artist
##tool where you need to draw half part of your mesh and it immediately copies the same mirror it and paste it on 
##the other side. Recommended to be used with tool script only for now. It will mirror all the children of the node
##you pass it as an argument, create a mirror version of them and add it to the same node.
## [codeblock]
## @tool
## extends Node
## @export var root: Node2D
## @export_tool_button("Mirror") var mirror: Callable = func(): 
##   if is_instance_valid(root): 
##      Utility.mirror(root)
## [/codeblock]
static func mirror(parent:Node2D,child: Node2D = null)->void:
	if !is_instance_valid(child):
		child = parent.duplicate()
		parent.add_child(child)
		child.owner = parent.owner
	child.position.y = -child.position.y
	if child is Sprite2D:
		var d: Sprite2D = child
		d.flip_v = !d.flip_v
	if child is Polygon2D:
		var d: Polygon2D = child
		d.skeleton = ""
		d.texture_scale.y *=-1
		for i in d.polygon.size():
			d.polygon[i].y *=-1
		for i in d.uv.size():
			d.uv[i].y *=-1
	for grand_child in child.get_children():
		grand_child.owner = parent.owner
		mirror(child,grand_child)


 

## This class can be used to create a bool that alternates every time the function flip is called.
## It will alternate between true and false every call. It can be used to create functions related 
## to swtiching like light on and off
## [codeblock]
## func pressed()->void:
##   if flip.flip():
##      turn_on()
##   else:
##      turn_off()
## [/codeblock]
class flip extends RefCounted:
	## Can be accesed to check the next value flip will return. Can be set directly
	var next: bool
	## can pass bool in new() to decide what state the flip starts with
	func _init(initial:bool = true) -> void:
		next = initial
	## Should be called to use the main functionality
	func flip()->bool:
		next = !next
		return !next

## This function will return true only the first time do_once is called and return false every
## other time until reset is called. new(false) can be set to make it start in deactivated state
## Another use case could be when you want to ignore any other call to your function until the 
## current task is completed finishing
## [codeblock]
## func my_function():
##    if d.allow_once():
##        #your current task
##        await finish
##        d.reset()
##        return
## [/codeblock]
class AllowOnce extends RefCounted:
	## Can be accesed to check the current state.
	var active: bool
	
	## can pass bool in new() to decide what state the class starts with
	func _init(is_active: bool = true) -> void:
		active = is_active
	
	## To set the class to active state
	func reset()->void:
		active = true
	
	## Should be called to use the main functionality
	func allow_once()->bool:
		if active:
			active = false
			return true
		return false



## This function works like AllowOnce but returns true the first N times, setN can be used to
## to set the number of times it should return true before returning false, reset to reset the
## current value to the max value and allow_n_times to use it
class AllowNTimes extends RefCounted:
	
	## Can be used to set the maximum times this function will return true before exhaustion.
	var max_value: int:
		set(value):
			if value>1:
				max_value = value
			else:
				max_value = 1
	
	## Can be used to check the current number of times this function will return true before exhaustion.
	var current_value: int:
		set(value):
			current_value = clampi(value,0,max_value)
	
	##  To set the max_value.
	func setN(value: int)->void:
		max_value = value
	
	## First arguments set the max_value and the second arguments decides the initial state.
	func _init(N:int = 1,is_active: bool = true) -> void:
		max_value = N
		if is_active:
			current_value = max_value
		else:
			current_value = 0
	
	## To set the class to max state.
	func reset()->void:
		current_value = max_value
	
	## Should be called to use the main functionality and each use automatically reduce current value by 1.
	func allow_n_times()->bool:
		if current_value:
			current_value -=1
			return true
		return false



## Ever struggled with tween? I know I know... me too. Well I hope this helps..........
## [codeblock]
## func pressed():
##    if tween.is_ready():
##        tween.tween().tween_property(...)
## [/codeblock]
## Note: Only use the gets that are provided by the class itself. Don't use any getter functions using tween() otherwise it might crash or thorugh errors. 
class NTween extends RefCounted:
	## Do not try to read it, there is not use for that. Setting it is aslso not recommended but can set it if want to change the node tween binds to.
	var owner: Node
	
	## Do not use this or access this.            
	var tw: Tween
	
	## Triggers every time a tween has finished all its tween.
	signal finished
	
	## Only works when set_loop is used. It will trigger at the end of each loop except the last which will be emitted but previous finished signal.
	signal loop_finished(loop_count: int)
	
	## The only argument is a node reference which generally should be "self". However can change it to show the node that the tween will always bind to.
	func _init(ref: Node) -> void:
		owner = ref
	
	## This is the tween you should be using. A bit hactic but for now this is the way.
	func tween()->Tween:
		if is_instance_valid(tw) and tw.is_valid() and tw.is_running():
			return tw
		else:
			if is_stopped(): tw.kill()
			tw = owner.create_tween()
			tw.finished.connect(func(): finished.emit())
			tw.loop_finished.connect(func(count): loop_finished.emit(count))
			return tw
	
	## Returns true only if the tween was once running and was stopped otherwise always return false
	func is_stopped()->bool:
		return tw and tw.is_valid() and !tw.is_running()
	
	## Return true if the tween hasn't been used yet and is ready to be used.
	func is_ready():
		return !(tw and tw.is_valid())
	## Return true if the tween is under processing and already is performing a tween. Make sure to not add any tweener calls if the tween is already 
	## running always check before adding new tween calls.
	func is_running()->bool:
		return tw.is_running() if tw and tw.is_valid() else false
	
	## Returns the number of loops left if the set_loop was fed value. Return -1 if infinite loops and 0 if no loop was set.
	func get_loops_left()->int:
		if tw and tw.is_valid():
			return tw.get_loops_left()
		else:
			return 0
	
	## Returns the time elapsed since the tween started and returns 0 if the tween is in ready state.
	func get_total_time_elapsed()->float:
		if tw and tw.is_valid():
			return tw.get_total_elapsed_time()
		else:
			return 0
	
	## If a tween is running it will kill it and set to ready state otherwise won't do anything.
	func kill()->void:
		if tw and tw.is_valid():
			tw.kill()


## A simple class that can be used to detect long press of either mouse click or key press. Can be useful for delayed input
## can be used as separate inputs from the immediate ones.
## [codeblock]
## extends Button
## var LP: Utility.LongPress = Utility.LongPress.new(2,triggered)
## func triggered():
##    print("triggered")
## func _ready()->void: # 1st use case. This will only work if the 2nd use case is not in use
##    button_down.connect(func(): LP.is_pressed = true)
##    button_up.connect(func(): LP.is_pressed = false)
## func _process(delta: float) -> void:
##    LP.is_pressed = Input.is_action_pressed("ui_accept") # 2nd use case. For UI inputs, could still work even if the 1st use case is in use
##    LP.process(delta)
class LongPress extends RefCounted:
	## Interally counts the time for long press trigger. Should ideally not be altered from outside
	var count: float
	## The max duration for which the long press is proccessed. Can be set directly from outside for change in limit.
	var limit: float
	## For internal use only and must not be altered
	var can_trigger: bool = true
	## The main function that decides the state of the input. Is true then it active else its in inactive state.
	var is_pressed: bool = false:
		set(value):
			is_pressed = value
			if !is_pressed: 
				can_trigger = true
				count = 0.0
	
	## The out signal that fires when the duration is reached
	signal long_press_triggered
	## Takes the duration for long press check and the callable to call when the long press is limit is reached, both inputs can be ingored and set separately.
	func _init(duration: float = 1.0,listener: Callable = Callable())->void:
		limit = duration
		if listener.is_valid():
			long_press_triggered.connect(listener)
	
	## The main process that internally calculates. Should be set up within the _process or _physics_process functions like in the example.
	func process(_delta:float):
		if is_pressed and can_trigger and count<=limit:
			count = clampf(count+_delta,0,limit)
			if count == limit:
				long_press_triggered.emit()
				can_trigger = false
