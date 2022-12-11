extends Node

var game_speed : float = 1.0 # lower numbers for slowmo, higher number to accelerate time
var stage_manager : Control # responsible for changing scenes. Never use get_tree().change_scene()
var player : KinematicBody2D # player avatar, many things rely on this
var village_location : Vector2 # so creeps know where to go
var current_map : Node2D # for spawning bullets and creeps
var nav_manager : Node # makes changes to nav mesh when placing/removing objects

func pause():
	# this is pretty abrupt and brute force.
	get_tree().set_pause(true)


func resume():
	get_tree().set_pause(false)
