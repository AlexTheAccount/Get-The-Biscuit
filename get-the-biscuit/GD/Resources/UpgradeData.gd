extends Resource
class_name UpgradeData

@export var id : String # unique key
@export var description : String
@export var icon : Texture2D
@export var cost : int 
@export var maxLevel : int = 1 
@export var statType : String 
@export var statIncrement : float # amount to add per level
