#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

var DevTree 0
public DevTree

var DevCurrent 0
public DevCurrent

extern DevRootBuild

var DevStack 0 (* we can go 64 layers deep *)
var DevStackPtr 0

procedure private DevStackPUSH (* v -- *)
	DevStack@ DevStackPtr@ + !
	DevStackPtr@ 4 + DevStackPtr!
end

procedure private DevStackPOP (* -- v *)
	DevStackPtr@ 4 - dup DevStackPtr!
	DevStack@ + @
end

(* TODO: find out why when this is used as a call, the path string is
   occasionally corrupted with a zero *)
procedure DevTreeWalk { path -- cnode }
	DevTree@ TreeRoot cnode!

	auto pcomp
	256 Calloc pcomp!

	while (path@ 0 ~=)
		path@ pcomp@ '/' 255 strntok path!

		if (pcomp@ strlen 0 ==)
			pcomp@ Free

			return
		end

		auto tnc
		cnode@ TreeNodeChildren tnc!

		auto n
		tnc@ ListHead n!

		auto nnode
		0 nnode!

		while (n@ 0 ~=)
			auto pnode
			n@ ListNodeValue pnode!

			if (pnode@ TreeNodeValue DeviceNode_Name + @ pcomp@ strcmp)
				pnode@ nnode! break
			end

			n@ ListNode_Next + @ n!
		end

		if (nnode@ 0 ==)
			pcomp@ Free
			0 cnode!

			return
		end

		nnode@ cnode!
	end

	pcomp@ Free
end

procedure DeviceParent (* -- *)
	DevCurrent@ DevStackPUSH
	DevCurrent@ TreeNodeParent DevCurrent!
end

procedure DeviceSelectNode (* node -- *)
	DevCurrent@ DevStackPUSH
	DevCurrent!
end

procedure DeviceSelect { path -- }
	DevCurrent@ DevStackPUSH

	path@ DevTreeWalk dup if (0 ~=) DevCurrent! end else drop end
end

procedure DeviceNNew { -- dnode }
	DeviceNode_SIZEOF Calloc dnode!

	ListCreate dnode@ DeviceNode_Methods + !
	ListCreate dnode@ DeviceNode_Properties + !
end

procedure DeviceNNewOMP { ml pl -- dnode }
	DeviceNode_SIZEOF Calloc
	dnode!

	ml@ dnode@ DeviceNode_Methods + !
	pl@ dnode@ DeviceNode_Properties + !
end

(* creates a new unnamed device node, adds it to the
device tree as a child of the current device, sets
itself as the new current device *)
procedure DeviceNew (* -- *)
	DevCurrent@ DevStackPUSH

	DeviceNNew DevCurrent@ DevTree@ TreeInsertChild DevCurrent!
end

procedure DeviceClone { node -- }
	DevCurrent@ DevStackPUSH

	auto ml
	node@ TreeNodeValue DeviceNode_Methods + @ ml!

	auto pl
	node@ TreeNodeValue DeviceNode_Properties + @ pl!

	ml@ pl@ DeviceNNewOMP DevCurrent@ DevTree@ TreeInsertChild DevCurrent!
end

procedure DeviceCloneWalk (* path -- *)
	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ~=)
		dn@ DeviceClone
	end
end

procedure DSetName (* name -- *)
	DevCurrent@ TreeNodeValue DeviceNode_Name + !
end

procedure DAddMethod { method name -- }
	auto mnode
	DeviceMethod_SIZEOF Calloc mnode!

	name@ mnode@ DeviceMethod_Name + !
	method@ mnode@ DeviceMethod_Func + !

	mnode@ DGetMethods ListInsert
end

procedure DSetProperty { value name -- }
	auto plist
	DGetProperties plist!

	auto n
	plist@ ListHead n!

	auto prop
	-1 prop!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceProperty_Name + @ name@ strcmp)
			pnode@ prop!
			break
		end

		n@ ListNodeNext n!
	end

	if (prop@ -1 ==)
		auto mnode
		DeviceProperty_SIZEOF Calloc mnode!

		name@ mnode@ DeviceProperty_Name + !
		value@ mnode@ DeviceProperty_Value + !

		mnode@ DGetProperties ListInsert
	end else
		value@ mnode@ DeviceProperty_Value + !
	end
end

procedure DAddProperty (* prop name -- *)
	DSetProperty
end

procedure DGetProperty { name -- string }
	auto plist
	DGetProperties plist!

	auto n
	plist@ ListHead n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceProperty_Name + @ name@ strcmp)
			pnode@ DeviceProperty_Value + @ string!
			return
		end

		n@ ListNodeNext n!
	end

	0 string!
end

procedure DGetMethod { name -- ptr }
	auto plist
	DGetMethods plist!

	auto n
	plist@ List_Head + @ n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceMethod_Name + @ name@ strcmp)
			pnode@ DeviceMethod_Func + @ ptr!
			return
		end

		n@ ListNodeNext n!
	end

	0 ptr!
end

procedure DCallMethod (* ... name -- ... ok? *)
	auto name
	name!

	auto plist
	DGetMethods plist!

	auto n
	plist@ List_Head + @ n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ DeviceMethod_Name + @ name@ strcmp)
			pnode@ DeviceMethod_Func + @ Call 1 return
		end

		n@ ListNodeNext n!
	end

	0
end

procedure DeviceExit (* -- *)
	DevStackPOP DevCurrent!
end

procedure DGetName (* -- name *)
	DevCurrent@ TreeNodeValue DeviceNode_Name + @
end

procedure DGetMethods (* -- methods *)
	DevCurrent@ TreeNodeValue DeviceNode_Methods + @
end

procedure DGetProperties (* -- properties *)
	DevCurrent@ TreeNodeValue DeviceNode_Properties + @
end


procedure private BuildDeviceTree (* -- *)
	TreeCreate DevTree!

	DeviceNNew DevTree@ TreeSetRoot DevCurrent!

	DevRootBuild
end

procedure DeviceInit (* -- *)
	256 Calloc DevStack!

	BuildDeviceTree
end