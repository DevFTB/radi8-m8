extends StaticBody2D

export (String) var resourceName
export (int) var completionAmount

var currentAmount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Node2D/Label.set_text(resourceName + "\n" + str(currentAmount) + " out of " + str(completionAmount))
	pass # Replace with function body.


func update_text():
		
	if(currentAmount > completionAmount):
		$Node2D/Label.set_text("Completed!")
	else:
		$Node2D/Label.set_text(resourceName + "\n" + str(currentAmount) + " out of " + str(completionAmount))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_entered(area):
	
	pass # Replace with function body.


func _on_body_entered(body):
	print("entered area")
	var addAmount = 0
	if(body.has_method("consume_resource")):
		addAmount = body.consume_resource(resourceName, completionAmount - currentAmount)
	currentAmount += addAmount

	update_text()
	pass # Replace with function body.
