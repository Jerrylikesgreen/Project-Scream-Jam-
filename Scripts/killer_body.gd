## Movement / Action logic. 
class_name Killerbody extends CharacterBody2D


@export var speed:int = 100

## Killer State Machine
enum KillerState{ IDLE, STUNNED, EXPLORING, CHASING, ATTACK, ACTION }
var killer_state: KillerState = KillerState.IDLE
