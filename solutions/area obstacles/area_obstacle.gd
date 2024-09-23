extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var enemy: SimpleAreaSeparationEnemy= (area as Node2D)

	enemy.obstacle_query.transform= enemy.transform
	
	# run the enemies obstacle query, which will give us detailed collision
	# info against any obstacle it currently overlaps with
	var result= get_world_2d().direct_space_state.get_rest_info(enemy.obstacle_query)

	enemy.handle_obstacle_collision(result.normal)
	
