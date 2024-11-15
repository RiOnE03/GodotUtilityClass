# GodotUtilityClass
Hey Guys! Ever tired of defining your custom functions just to tackle one problem that persists between different scripts. So you have to keep on copying those functions from script to script just so that one problem can be solved. Ever wished only if Godot had an inbuilt function to solve it. Well you don't have to worry anymore. Godot Utility class comes with some functions and classes made to tackle such problems.   

# How it works?
Godot Utility class has static functions and classes which has the functions already defined.

# How to use it?
Nothing to wokring just add Utility script into your own project and save it. All the functions are statics and can be directly accessed from the class. However instances of the *classes* need to be created to use them.

# Some of the inbuilt functions and classes:
* polar -> it takes a bool and convert false into -1 and true into 1. What might be the test case?You won't need to create a function just to find the sprite's facing direction from its flip_h
* AllowOnce -> Ever wanted your function to ignore all other calls while the current function is under process or awaiting a signal?
* AllowNTimes -> Just like Allow once but only allow first N functions to work until reset.
* flip -> Want to replicate the functionality of a switch? On, off, on, off, on, off. It alternates between true and false every time its called.
