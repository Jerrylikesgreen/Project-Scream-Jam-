class_name PlayerController extends Node

signal sprite_change(animation:String)

@onready var player: Player = $"../.."

enum State{DASH_INITIAL,DASHING,WALKING,HIDING,INTERACTION, IDLE};
var _current_state:State = State.WALKING;
@onready var action_area: Area2D = %ActionArea
@onready var player_sprite: AnimatedSprite2D = $"../PlayerSprite"

#——————————————Variables——————————————————
@onready var staminaBar:ProgressBar = $"Stamina Bar Canvas/MarginContainer/Stamina Bar"
##A PlayerController node gets added as a child to a CharacterBody2D,
##and handles the movement of the character.
@onready var player_body :CharacterBody2D = get_parent();
var KILLER_COLLISION_LAYER:int = 2;
var SELF_COLLISION_LAYER:int = 1;

##The player's speed (pixels/second)
##when not dashing.
@export var regular_speed:float = 80;

##The player's speed (pixels/second) when dashing
@export var dash_speed:float = 160;

##The number of seconds after which dash can be used again
##once dash has been fully depleted
@export var dash_cooldown:float = 5.;

##The maximum amount of stamina the player can have.
##If this value is lowered for any reason, the current
##stamina will be lowered as well if it is over the new
##cap.
@export var stamina_cap:float = 100.:
	set(val):
		stamina_cap = val;
		_current_stamina = min(_current_stamina,stamina_cap);
		return;

##The speed (units/second) at which stamina regenerates;
@export var stamina_regen:float = 5.;
		
##The speed (units/second) at which the player's stamina
##depletes while using their dash
@export var stamina_deplete:float = 20.;

##The amout of time (seconds) at the beginning of a dash during which
##the player will be invulnerabe
@export var invuln_time:float = 0.5;
var _invuln_time_remaining:float = invuln_time;

##Dictates the minimum stamina a player needs to dash.
##If we don't have this, then the player can get
##a consistent speed boost by holding down the dash button,
##since every frame, stamina regenerates slightly.
@export var min_dash_stamina:float = 20.;

##The player's current speed
var _current_speed:float = regular_speed;

var _walkin_signal:bool = false
var _idle_signal:bool = false
##The player's current stamina
var _current_stamina:float = stamina_cap:
	set(val):
		_current_stamina = val;
		staminaBar.value = val;

##private var dictating whether the player can move;
var _can_move:bool = true;

##Defines whether the player is hiding
var hiding:bool = false;
##Function for accessing hiding functionality from outside
##of this object.
func enter_hiding()->void:
	_switch_state_to(State.HIDING);

##defines whether the player will die if the killer
##touches them. Generally true, but not in initial
##stages of dash, or when hiding.
var _killer_touch_fatal:bool = true;

## Acceleration factor (how fast you reach max speed)
var accel = 1000

## Friction factor (how fast you slow down when no input)
var friction = 300

## speed it will take to complete action, determined by object. 
var action_speed:float

func _physics_process(delta: float) -> void:
	_do_state(_current_state, delta)

	var input_vector = Input.get_vector("left", "right", "up", "down")

	# X-axis movement
	if input_vector.x != 0 and _can_move:
		player_body.velocity.x = move_toward(player_body.velocity.x, input_vector.x * _current_speed, accel * delta)
		# Flip sprite based on direction
		player_sprite.flip_h = input_vector.x < 0
	else:
		player_body.velocity.x = move_toward(player_body.velocity.x, 0, friction * delta)

	# Y-axis movement
	if input_vector.y != 0 and _can_move:
		player_body.velocity.y = move_toward(player_body.velocity.y, input_vector.y * _current_speed, accel * delta)
	else:
		player_body.velocity.y = move_toward(player_body.velocity.y, 0, friction * delta)

	# Move the player
	player_body.move_and_slide()

	# Animation handling
	if input_vector.length() > 0 and _can_move:
		emit_signal("sprite_change", "Moving")
		_idle_signal = false
		print("Signal Emit Moving")
	else:
		if _idle_signal == true:
			return
		emit_signal("sprite_change", "Idle")
		_idle_signal = true





func _switch_state_to(state:State)->void:
	_exit_state(_current_state);
	_current_state = state;
	_enter_state(_current_state);
	return;

func _enter_state(state:State)->void:
	match state:
		State.DASH_INITIAL:
			player_body.set_collision_mask_value(KILLER_COLLISION_LAYER,false);
			player_body.set_collision_layer_value(SELF_COLLISION_LAYER,false);
			if(_current_stamina < min_dash_stamina):
				_switch_state_to(State.WALKING);
				return;
			_current_speed = dash_speed;
			_invuln_time_remaining = invuln_time;
		State.DASHING:
			_current_speed = dash_speed;
		State.WALKING:
			_current_speed = regular_speed;
		State.HIDING:
			player_body.hiding = true;
			player.hide();
			player_body.set_collision_mask_value(KILLER_COLLISION_LAYER,false);
			player_body.set_collision_layer_value(SELF_COLLISION_LAYER,false);
			_killer_touch_fatal = false;
			_can_move = false;
		State.INTERACTION:
			var objs = action_area.get_overlapping_bodies()
			if objs.is_empty():
				_switch_state_to(State.WALKING);
				return
			action_area.set_visible(true);
			var obj = objs[0];
			if obj is HideableObject:
				var cannot_hide:bool = await KillerManager.player_in_line_of_sight(player_body);
				if !cannot_hide:
					_switch_state_to(State.HIDING);
				return;
			#this ensures the player won't get stuck trying to
			#do an action that's already done.
			action_speed = obj.action_speed if obj.active else 0;
			_can_move = false;
			var int_obj = action_area.get_overlapping_bodies();
			for ob in int_obj:
				if obj is HideableObject:
					var cannot_hide:bool = await KillerManager.player_in_line_of_sight(player_body);
					if !cannot_hide:
						_switch_state_to(State.HIDING);
						return;
				ob.action();
				ob.player_triggered = true
				action_area.set_visible(false);
				await get_tree().create_timer(action_speed).timeout;
				
			_switch_state_to(State.WALKING);


##Defines the behaviour while the state is a certain state;
func _do_state(state:State,delta:float)->void:
	match state:
		State.DASH_INITIAL:
			if Input.is_action_just_released("action"):
				_switch_state_to(State.INTERACTION);
				return
			#The beginning of a dash lasts a set amount of time.
			#Once that time is over, move to normal dash.
			#End early if stamina runs out.
			_deplete_stamina(delta)
			var dash_pressed:bool = Input.is_action_pressed("dash");
			if(_current_stamina <= 0 || !dash_pressed):
				_switch_state_to(State.WALKING);
			_invuln_time_remaining -= delta;
			if(_invuln_time_remaining <= 0):
				_switch_state_to(State.DASHING);
		State.DASHING:
			if Input.is_action_just_released("action"):
				_switch_state_to(State.INTERACTION);
				return;
			var dash_pressed:bool = Input.is_action_pressed("dash");
			if(!dash_pressed):
				_switch_state_to(State.WALKING);
				return;
			_deplete_stamina(delta);
			#should never be <, but just in case.
			if (_current_stamina <= 0):
				_switch_state_to(State.WALKING);
		State.WALKING:
			if Input.is_action_just_released("action"):
				_switch_state_to(State.INTERACTION);
				return;
			##Let stamina regen
			_regen_stamina(delta);
			var dash_pressed:bool = Input.is_action_pressed("dash");
			if(dash_pressed):
				_switch_state_to(State.DASH_INITIAL);
		State.HIDING:
			if Input.is_action_just_released("action"):
				_switch_state_to(State.WALKING);
			_regen_stamina(delta);
			#Placeholder. Unsure what the desired behaviour is currently.
			pass
		State.INTERACTION:
			pass
			#var int_obj = action_area.get_overlapping_bodies();
			#for obj in int_obj:
				#obj.action();
				#await get_tree().create_timer(action_speed).timeout;
				#action_area.set_visible(false);
				#_exit_state(State.INTERACTION)
				



##Defines any special behaviour to do in a state before exiting;
func _exit_state(state:State):
	match state:
		State.DASH_INITIAL:
			player_body.set_collision_mask_value(KILLER_COLLISION_LAYER,true);
			player_body.set_collision_layer_value(SELF_COLLISION_LAYER,true);
		State.DASHING:
			pass
		State.WALKING:
			pass
		State.HIDING:
			player_body.hiding = false;
			player.show();
			player_body.set_collision_mask_value(KILLER_COLLISION_LAYER,true);
			player_body.set_collision_layer_value(SELF_COLLISION_LAYER,true);
			_killer_touch_fatal = true;
			_can_move = true;
		State.INTERACTION:
			_can_move = true;


func _deplete_stamina(delta:float)->void:
	if _current_stamina > 0:
		_current_stamina = move_toward(_current_stamina,0,stamina_deplete*delta)

func _regen_stamina(delta:float)->void:
	if _current_stamina < 100:
		_current_stamina = move_toward(_current_stamina,100.,stamina_regen*delta);
