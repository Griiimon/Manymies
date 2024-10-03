extends Node

const ENEMY_COLLISION_LAYER= 2
const OBSTACLE_COLLISION_LAYER= 4

const TILE_SIZE= 32

var player: Player
var enemies: Node2D
var obstacle_tile_map: TileMapLayer
var pathfinder: Pathfinder
