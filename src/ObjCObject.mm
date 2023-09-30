/**
 * Copyright (C) 2023 Gil Barbosa Reis.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the “Software”), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include "ObjCObject.hpp"

#include "objc_invocation.hpp"

#include <Foundation/Foundation.h>
#include <objc/runtime.h>

#include <godot_cpp/core/error_macros.hpp>

extern "C" id objc_retain(id);
extern "C" void objc_release(id);

namespace objcgdextension {

ObjCObject::ObjCObject() : obj() {}

ObjCObject::ObjCObject(id obj) {
	if (obj) {
		this->obj = objc_retain(obj);
	}
	else {
		obj = nil;
	}
}

ObjCObject::~ObjCObject() {
	if (obj) {
		objc_release(obj);
	}
}

Variant ObjCObject::perform_selector(const String& selector) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	SEL sel = to_selector(selector);
	if ([obj respondsToSelector:sel]) {
		@try {
			return invoke(obj, sel);
		}
		@catch (NSException *ex) {
			ERR_FAIL_V_MSG(Variant(), ex.description.UTF8String);
		}
	}
	else {
		ERR_FAIL_V_EDMSG(Variant(), String("%s does not respond to selector '%s'") % Array::make(class_getName([obj class]), selector));
	}
}

void ObjCObject::_bind_methods() {
	ClassDB::bind_method(D_METHOD("perform_selector"), &ObjCObject::perform_selector);
}

bool ObjCObject::_get(const StringName& name, Variant& r_value) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	@try {
		NSString *key = nsstring_with_string(name);
		r_value = to_variant((NSObject *) [obj valueForKey:key]);
		return true;
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(false, ex.description.UTF8String);
	}
}

String ObjCObject::_to_string() {
	if (obj) {
		return [obj description].UTF8String;
	}
	else {
		return Variant().stringify();
	}
}

}
