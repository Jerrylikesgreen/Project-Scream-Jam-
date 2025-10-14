class_name KeyResource extends ItemResource


## If item is a key, this ID will determin which lock can be oppened. Skeleton Key ID = 0
@export var key_uid:int 
 
var range = clampi(key_uid, 0, 999)
