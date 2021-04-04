extends KinematicBody2D

export (float) var speed = 300.0
export (float) var rotation_speed = 15

var velocity = Vector2.ZERO 

var closeFlocks = [] 
var steering = Vector2.ZERO  

# Called when the node enters the scene tree for the first time.
func _ready():
	respawn()
	$vision.connect("area_entered", self, "on_area_entered")
	$vision.connect("area_exited", self, "on_area_exited") 

func respawn():
	var viewportSize = get_viewport().size
	var pos = Vector2( ((randi() + 50) % 800) , ((randi() + 50) % int(viewportSize.y) - 50))

	move_and_collide(pos)
	
	velocity = Vector2((randi() + 5) % 10, (randi() + 5) % 10).normalized()

	velocity = velocity.rotated(randf() * PI * 4)

func _physics_process(delta): 

	if not $notifier.is_on_screen():
		var viewportSize = get_viewport().size

		if(position.x < 0):
			global_position.x = viewportSize.x
		elif (position.x > viewportSize.x):
			global_position.x = 0

		if(position.y < 0):
			global_position.y = viewportSize.y
		elif (position.y > viewportSize.y):
			global_position.y = 0 

	calculateRotation()

	velocity = velocity.normalized()
	
	if(steering != Vector2.ZERO):  
		steering *= rotation_speed
		velocity = (velocity  * speed) + steering
	else :
		velocity *= speed
	
	move_and_collide(velocity * delta)
	rotation = velocity.angle() + PI/2 

func on_area_entered(area: Area2D):
	var parent = area.get_parent()
	closeFlocks.append(parent)

func on_area_exited(area: Area2D): 
	var parent = area.get_parent()
	var position = closeFlocks.find(parent)
	closeFlocks.remove(position)

func calculateRotation():
	steering = Vector2.ZERO

	if(closeFlocks.size() == 0):
		return

	var separationVector = Vector2.ZERO
	var flocksCenter = Vector2.ZERO
	var desiredAlignment = Vector2.ZERO

	for flock in closeFlocks: 
		
		#calculate separation 
		separationVector += separationLoop(flock)

		#calculate cohesion
		flocksCenter += cohesionLoop(flock)

		#calculate alignment
		desiredAlignment += alignmentLoop(flock) 

	separationVector = separationCalculate(separationVector)
	var cohesion = cohesionCalculate(flocksCenter)
	var alignment = alignmentCalculate(desiredAlignment) 

	steering = (separationVector * get_parent().separation) + cohesion * get_parent().cohesion + alignment * get_parent().alignment 

	steering = steering.normalized()

func separationLoop(flock) -> Vector2:
	
	var AB = global_position - flock.global_position 
	var radious = global_position.distance_to(flock.global_position) + 0.0001
	var weight = 1 / radious

	return AB * weight  

func separationCalculate(separationVector) -> Vector2:
	return separationVector.normalized() 

func cohesionLoop(flock)-> Vector2:
	return flock.global_position

func cohesionCalculate(flocksCenter: Vector2) -> Vector2: 
	flocksCenter /= closeFlocks.size()
	var AB = flocksCenter - global_position
	return AB.normalized()

func alignmentLoop(flock) -> Vector2: 
	return flock.velocity

func alignmentCalculate(desiredAlignment) -> Vector2:
	desiredAlignment /= closeFlocks.size()
	return (desiredAlignment - velocity).normalized()

func _draw():
	if (!get_parent().showAlignment):
		return
		
	draw_line(Vector2.ZERO, Vector2(0, -100), Color(0, 255, 0), 1 ) 

	# for flock in closeFlocks:

	# 	var vector = global_position - flock.global_position 

	# 	draw_line(Vector2.ZERO, Vector2(-vector.y, vector.x) , Color(255, 0, 0), 1)

func _process(delta):
	update()