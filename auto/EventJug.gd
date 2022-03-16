extends Node

signal score_add(num)
signal score_set_max(val)
signal score_show(val)
signal health_update(val)

signal not_enough_fuel()
signal open_exit()
signal win_game()
signal lose_game()
signal zombie_killed()

signal load_next_level()
signal show_stats(level, zombies)
