extends RefCounted


func test_from_string() -> bool:
	var NSObject = ObjCClass.from_string("NSObject")
	assert(NSObject != null)
	return true
	
	
func test_invalid_class() -> bool:
	var should_be_null = ObjCClass.from_string("invalid-class-name")
	assert(should_be_null == null)
	return true
		
		
func test_class_name() -> bool:
	var NSObject = ObjCClass.from_string("NSObject")
	assert(str(NSObject) == "NSObject")
	return true
