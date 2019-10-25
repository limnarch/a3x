#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

extern BuildEBus
extern BuildLimn1k
extern BuildMemory

procedure BuildPlatform (* -- *)
	DeviceNew
		"platform" DSetName
	
		"LIMNstation,1" "platform" DAddProperty

		BuildLimn1k

		BuildMemory

		BuildEBus
	DeviceExit
end

var PlatformClockPath 0
public PlatformClockPath

var PlatformDiskBusPath 0
public PlatformDiskBusPath

var PlatformDMAPath 0
public PlatformDMAPath

var PlatformKeyboardPath 0
public PlatformKeyboardPath

var PlatformMousePath 0
public PlatformMousePath

var PlatformScreenPath 0
public PlatformScreenPath

var PlatformSerialPath 0
public PlatformSerialPath

var PlatformCPUPath 0
public PlatformCPUPath

var PlatformMemoryPath 0
public PlatformMemoryPath

var PlatformDefaultScreenBG 0
public PlatformDefaultScreenBG

var PlatformDefaultScreenFG 0
public PlatformDefaultScreenFG

procedure PlatformInit (* -- *)
	"/platform/ebus/platformboard/citron/clock" PlatformClockPath!
	"/platform/ebus/platformboard/citron/dks" PlatformDiskBusPath!
	"/platform/ebus/dma" PlatformDMAPath!
	"/platform/ebus/platformboard/citron/amanatsu/kbd/0" PlatformKeyboardPath!
	"/platform/ebus/platformboard/citron/amanatsu/mouse/0" PlatformMousePath!
	"/platform/ebus/kinnow3" PlatformScreenPath!
	"/platform/ebus/platformboard/citron/serial" PlatformSerialPath!
	"/platform/limn1k" PlatformCPUPath!
	"/platform/memory" PlatformMemoryPath!

	"15" PlatformDefaultScreenBG!
	"255" PlatformDefaultScreenFG!
end