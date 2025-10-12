class_name PlayerController extends Node
@onready var player: Player = $"../.."

enum State{DASH_INITIAL,DASHING,WALKING,HIDING,INTERACTION, IDLE};
var _current_state:State = State.WALKING;
@onready var action_area: Area2D = %ActionArea

#——————————————Variables——————————————————
@onready var staminaBar:ProgressBar = $"Stamina Bar Canvas/MarginContainer/Stamina Bar"
##A PlayerController node gets added as a child to a CharacterBody2D,
##and handles the movement of the character.
@onready var player_body :CharacterBody2D = get_parent();


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



##The player's current stamina
var _current_stamina:float = stamina_cap:
	set(val):
		_current_stamina = val;
		staminaBar.value = val;

##private var dictating whether the player can move;
var _can_move:bool = true;

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
		
	if Input.is_action_just_pressed("action"):
		_switch_state_to(State.INTERACTION, delta)
	
	var input_vector = Input.get_vector("left","right","up","down")
	
	# X-axis
	if input_vector.x != 0 and _can_move:
		player_body.velocity.x = move_toward(player_body.velocity.x, input_vector.x * _current_speed, accel * delta)
	else:
		player_body.velocity.x = move_toward(player_body.velocity.x, 0, friction * delta)
	
	# Y-axis
	if input_vector.y != 0 and _can_move:
		player_body.velocity.y = move_toward(player_body.velocity.y, input_vector.y * _current_speed, accel * delta)
	else:
		player_body.velocity.y = move_toward(player_body.velocity.y, 0, friction * delta)
	
	player_body.move_and_slide()





func _switch_state_to(state:State, delta)->void:
	_exit_state(_current_state);
	_current_state = state;
	_enter_state(_current_state, delta);
	return;

func _enter_state(state:State, delta)->void:
	match state:
		State.DASH_INITIAL:
			if(_current_stamina < min_dash_stamina):
				_switch_state_to(State.WALKING, delta);
				return;
			_current_speed = dash_speed;
			_invuln_time_remaining = invuln_time;
		State.DASHING:
			if(_current_stamina < min_dash_stamina):
				_switch_state_to(State.WALKING, delta);
				return;
			_current_speed = dash_speed;
		State.WALKING:
			_current_speed = regular_speed;
		State.HIDING:
			_killer_touch_fatal = false;
			_can_move = false;
		State.INTERACTION:
			action_area.set_visible(true);
			var objs = action_area.get_overlapping_bodies()
			var obj = objs[0]
			action_speed = obj.action_speed
			_can_move = false;
			_do_state(State.INTERACTION, delta)


##Defines the behaviour while the state is a certain state;
func _do_state(state:State,delta:float)->void:
	match state:
		State.DASH_INITIAL:
			#The beginning of a dash lasts a set amount of time.
			#Once that time is over, move to normal dash.
			#End early if stamina runs out.
			_deplete_stamina(delta)
			var dash_pressed:bool = Input.is_action_pressed("dash");
			if(_current_stamina <= 0 || !dash_pressed):
				_switch_state_to(State.WALKING, delta);
			_invuln_time_remaining -= delta;
			if(_invuln_time_remaining <= 0):
				_switch_state_to(State.DASHING, delta);
		State.DASHING:
			_deplete_stamina(delta);
			#should never be <, but just in case.
			if (_current_stamina <= 0):
				_switch_state_to(State.WALKING, delta);
		State.WALKING:
			##Let stamina regen
			_regen_stamina(delta);
			var dash_pressed:bool = Input.is_action_pressed("dash");
			if(dash_pressed):
				_switch_state_to(State.DASH_INITIAL, delta);
		State.HIDING:
			_regen_stamina(delta);
			#Placeholder. Unsure what the desired behaviour is currently.
			pass
		State.INTERACTION:
			var int_obj = action_area.get_overlapping_bodies();
			for obj in int_obj:
				obj.action();
				await get_tree().create_timer(action_speed).timeout;
				action_area.set_visible(false);
				_exit_state(State.INTERACTION)
				



##Defines any special behaviour to do in a state before exiting;
func _exit_state(state:State):
	match state:
		State.DASH_INITIAL:
			pass
		State.DASHING:
			pass
		State.WALKING:
			pass
		State.HIDING:
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
