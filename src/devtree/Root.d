#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

extern BuildTree

procedure DevRootBuild (* -- *)
	"antecedent-ebus" DSetName
	"3.1" "version" DAddProperty
	"Will" "author" DAddProperty
	"LIMNstation,1" "platform" DAddProperty
	pointerof ANTEBNS "build" DAddProperty
	pointerof ANTEBDS "buildDate" DAddProperty

	BuildTree
end

asm "

ANTEBNS:
	.static ../build
	.db 0x0

ANTEBDS:
	.ds$ __DATE
	.db 0x0

"