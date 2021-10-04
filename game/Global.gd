extends Node

var radpods = 3
var meds = 3
func add_radpods(amount):
	radpods += amount

func consume_radpods(amount):
	if(amount == -1 or amount > radpods):
		var temp = radpods
		radpods = 0
		return temp
	else:
		var temp = radpods
		radpods = 0
		return temp
		
func add_meds(amount):
	meds += amount

func consume_meds(amount):
	if(amount == -1 or amount > meds):
		var temp = radpods
		meds = 0
		return temp
	else:
		var temp = meds
		meds = 0
		return temp
	

