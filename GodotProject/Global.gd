extends Node

var game_speed : float = 1.0 # lower numbers for slowmo, higher number to accelerate time
var stage_manager : Control # responsible for changing scenes. Never use get_tree().change_scene()
var player : KinematicBody2D # player avatar, many things rely on this
var village_location : Vector2 # so creeps know where to go
var current_map : Node2D # for spawning bullets and creeps



