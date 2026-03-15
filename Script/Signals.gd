extends Node

@warning_ignore("unused_signal")
signal update_life(l:int)

@warning_ignore("unused_signal")
signal update_score(s:int)

@warning_ignore("unused_signal")
signal show_start_screen()

@warning_ignore("unused_signal")
signal show_end_screen(s:int)

@warning_ignore("unused_signal")
signal hide_info_screen()

# Audio signals
@warning_ignore("unused_signal")
signal block_hit(destroyed: bool)

@warning_ignore("unused_signal")
signal powerup_collected()
