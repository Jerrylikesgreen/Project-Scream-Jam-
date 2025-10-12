class_name InvContents extends Resource
var contents:Array[Item] = [];
var multiplicity:PackedInt32Array = [];

@export var max_len = 20;

signal item_update(index:int);
func _init() -> void:
	contents.resize(max_len);
	multiplicity.resize(max_len);

##Check whether a space in the inventory is empty
func empty(index:int)->bool:
	return contents[index] == null || multiplicity[index] == 0;

##Check whether a space in the inventory is full;
func full(index:int)->bool:
	return contents[index] != null && multiplicity[index] == contents[index].max_in_inv_slot;

##Check whether we can add n of the given item to the given index.
func _can_add(item:Item,index:int,n:int = 1)->bool:
	if(index < 0 || index >= max_len):
		return false;
	return empty(index) || (contents[index] == item && multiplicity[index] <= item.max_in_inv_slot - n);

##How many items of type item can fit in the given slot?
func _remaining_capacity(index:int,item:Item)->int:
	if empty(index):
		return item.max_in_inv_slot;
	elif contents[index] != item:
		return 0;
	else:
		return item.max_in_inv_slot - multiplicity[index];

##Sets the specified index to have item with multiplicity n.
func setInd(index:int,item:Item,n:int = 1)->bool:
	if n > item.max_in_inv_slot:
		return false;
	contents[index] = item;
	multiplicity[index] = n;
	item_update.emit(index);
	return true

##Attempts to add n items to the inventory at index.
##Returns true if successful, false otherwise.
func addInd(item:Item,index:int,n:int = 1)->bool:
	if(_can_add(item,index,n)):
		return setInd(index,item,multiplicity[index] + n);
	else:
		return false;

##Switches the items at ind_1 and ind_2
func switch(ind_1:int,ind_2:int)->void:
	var tmp_item:Item = contents[ind_1];
	var tmp_mult:int = multiplicity[ind_1];
	setInd(ind_1,contents[ind_2],multiplicity[ind_2]);
	setInd(ind_2,tmp_item,tmp_mult);
	return;

##Entirely removes everything in a given inventory slot.
func remove(index:int)->void:
	contents[index] = null;
	multiplicity[index] = 0;
	item_update.emit(index);
	return;

##Removes n of an item from a slot.
func deplete(index:int,n:int)->bool:
	if(index == null || n > multiplicity[index]):
		return false;
	else:
		multiplicity[index] -= n;
		if(multiplicity[index]) == 0:
			remove(index);
		return true;

##Attempts to add an item in the first available slot
func add(item:Item,n:int = 1)->int:
	var i:int = 0;
	while n > 0 && i < max_len:
		var max_n = min(_remaining_capacity(i,item),n);
		if max_n > 0:
			addInd(item,i,max_n);
		n -= max_n;
		i += 1;
	#returns the number of remaining items after storing as many as possible.
	return n;

signal item_used(item:Item);
##Uses an item, removes it if it's consumable, sends a
##signal to notify that the item has been used.
func use(index:int,n:int = 1):
	if(contents[index]==null):
		return false;
	item_used.emit(contents[index]);
	if(contents[index].consumable):
		var depleted:bool = deplete(index,n);
		if depleted:
			pass
		return depleted;
	return true;
	
