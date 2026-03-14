extends Node

enum GameStates{
	RUN, STOP, GAME_OVER
}

var game_state: GameStates = GameStates.STOP

var ball_counter: int = 0
var points: int = 0
