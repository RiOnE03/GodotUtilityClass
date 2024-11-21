class_name Utility extends Object


# /******************************************
# Description:
#
#
#~~~~~~~~~~~~~~~~~~Static functions (Can be called and used directly)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#
# 1. polar:
#       Detail: This function return 1 if true else -1 however the result is flipped if reverse is true.
#               This function is useful for cases like when you want to find the direction where the sprite
#               is facing using its flip_h
# 2. generate_timer:
#       Detail: Creates a timer that can be directly added instead of defining its paramters first in multiple lines
#
#
#
#~~~~~~~~~~~~~~~~~~~Classes (needs to create an instance before using)~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#    If there is (!) in front of any variable that function should not be set directly and 
#    if there is (N), then that variable should neither be set nor used to read directly
#
# 1. flip:
#       Detail: This class can be used to create an alternative bool every time the function flip will be
#               used it will provide alternate result between true and false. It can be used to create functions 
#               related to swtiching like light on and off
#       Example: func pressed()->void:
#                   if flip.flip():
#                      turn_on()
#                   else:
#                      turn_off()
#               Variables:
#                    next: Can be accesed to check the next value flip will return
#               functions:
#                    new(): can pass bool in new() to decide what state the flip starts with
#                    flip(): Should be called to use the main functionality
# 2. AllowOnce:
#       Detail: This function is return true only the first time do_once is called and return false every
#               other time until reset is called, new(false) can be set to make it start in deactivated state
#               Another use case could be when you want to ignore any other call to your function until the 
#               current task is completed finishing
#       Example: func my_function():
#                  if d.allow_once():
#                     #your current task
#                     await finish
#                     d.reset()
#               Variables:
#                    active: Can be accesed to check the current state.
#               functions:
#                    new(): can pass bool in new() to decide what state the class starts with
#                    reset(): To set the class to active state
#                    AllowOnce(): Should be called to use the main functionality
# 3. AllowNTimes:
#       Detail: This function works like AllowOnce but returns true the first N times, setN can be used to
#               to set the number of times it should return true before returning false, reset to reset the
#               current value to the max value and allow_n_times to use it
#               Variables:
#                    max_value: Can be used to set the maximum times this function will return true before exhaustion. 
#                    current_value: Can be used to check the current number of times this function will return true before exhaustion. 
#               functions:
#                    new(): First arguments set the max_value and the second arguments decides the initial state.
#                    SetN(): To set the max_value.
#                    reset(): To set the class to max state.
#                    AllowNTimes(): Should be called to use the main functionality and each use automatically reduce current value by 1.
# 4. NTween:
#       Detail: Ever struggled with tween? I know I know... me too. Well I hope this helps..........
#       Example: func pressed():
#                  if !tween.is_running:
#                     tween.tween().tween_property(...)
#               Variables:
#                (N) owner: Do not try to read it, there is not use for that. Setting it is aslso not recommended but can set it if want to change the node tween binds to. 
#                (N) tw: Do not use this or access this. 
#               Signals:
#                    finished: Triggers every time a tween has finished all its tween.
#                    loop_finished: Only works when set_loop is used. It will trigger at the end of each loop except the last which will be emitted but previous finished signal.
#               functions:
#                    new(): The only argument is a node reference which generally should be "self". However can change it to show the node that the tween will always bind to.
#                    tween(): This is the tween you should be using. A bit hactic but for now this is the way.
#                    is_running(): Do not use the original tween's is_running, use this instead it will through errors.    
# /******************************************




static func polar(boolean: bool, reverse: bool = false)->int:
	var result: int = 0
	if boolean:
		result = 1
	else:
		result = -1
	return -result if reverse else result


static func generate_timer(duration: int = 1, link: Callable = Callable(), autostart: bool = false, one_shot:bool = true)->Timer:
	var timer: Timer = Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = duration
	timer.autostart = autostart
	timer.one_shot = one_shot
	if link.is_valid():
		timer.timeout.connect(link)
	return timer



class flip extends RefCounted:
	var next: bool
	func _init(initial:bool = true) -> void:
		next = initial
	func flip()->bool:
		next = !next
		return !next


class AllowOnce extends RefCounted:
	var active: bool
	func _init(is_active: bool = true) -> void:
		active = is_active
	func reset()->void:
		active = true
	func allow_once()->bool:
		if active:
			active = false
			return true
		return false


class AllowNTimes extends RefCounted:
	var max_value: int:
		set(value):
			if value>1:
				max_value = value
			else:
				max_value = 1
	var current_value: int:
		set(value):
			current_value = clampi(value,0,max_value)
	func setN(value: int)->void:
		max_value = value
	func _init(N:int = 1,is_active: bool = true) -> void:
		max_value = N
		if is_active:
			current_value = max_value
		else:
			current_value = 0
	func reset()->void:
		current_value = max_value
	func allow_n_times()->bool:
		if current_value:
			current_value -=1
			return true
		return false

class NTween extends RefCounted:
	var owner: Node                            # (N)
	var tw: Tween                              # (N)
	
	signal finished
	signal loop_finished(loop_count: int)

	func _init(ref: Node) -> void:
		owner = ref
	
	func tween()->Tween:
		if tw and tw.is_valid():
			return tw
		else:
			tw = owner.create_tween()
			tw.finished.connect(func(): finished.emit())
			tw.loop_finished.connect(func(count): loop_finished.emit(count))
			return tw      
	func is_running()->bool:
		return tw.is_running() if tw and tw.is_valid() else false
	
