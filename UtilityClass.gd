class_name Utility extends Object



## This function return 1 if true else -1 however the result is flipped if reverse is true. 
## This function is useful for cases like when you want to find the direction where the sprite
## is facing using its flip_h
static func polar(boolean: bool, reverse: bool = false)->int:
	var result: int = 0
	if boolean:
		result = 1
	else:
		result = -1
	return -result if reverse else result

## Creates a timer that can be directly added instead of defining its paramters first in multiple lines
static func generate_timer(duration: int = 1, link: Callable = Callable(), autostart: bool = false, one_shot:bool = true)->Timer:
	var timer: Timer = Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = duration
	timer.autostart = autostart
	timer.one_shot = one_shot
	if link.is_valid():
		timer.timeout.connect(link)
	return timer


## This class can be used to create an alternative bool every time the function flip will be
## used it will provide alternate result between true and false. It can be used to create functions 
## related to swtiching like light on and off
## func pressed()->void:
##	if flip.flip():
##		turn_on()
##	else:
##		turn_off()
class flip extends RefCounted:
	var current: bool
	func _init(initial:bool = true) -> void:
		current = initial
	func flip()->bool:
		current = !current
		return !current

## This function is return true only the first time do_once is called and return false every
## other time until reset is called, new(false) can be set to make it start in deactivated state
## Another use case could be when you want to ignore any other call to your function until the 
## current task is completed finishing
## Example:
## func my_function():
##	if d.allow_once():
##		#your current task
##		await finish
##		d.reset()
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

## This function works like AllowOnce but returns true the first N times, setN can be used to
## to set the number of times it should return true before returning false, reset to reset the
## current value to the max value and allow_n_times to use it
class AllowNTimes extends RefCounted:
	var max_value: int:
		set(value):
			if value>1:
				max_value = value
			else:
				max_value = 1
	var current_value: int
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
