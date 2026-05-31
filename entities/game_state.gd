class_name GameState
extends Node

signal get_figures_data(username: String)
signal refresh_state()
signal session_joined()


var players: Dictionary[int,Player]  = {} # Data is peer ID, Player information
