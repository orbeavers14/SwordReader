#include "sword_bridge.h"

#include <swversion.h>

const char *SwordBridgeVersion(void) {
    return "SwordKit Bridge 0.1";
}

const char *SwordEngineVersion(void) {
    static sword::SWVersion version;
    return version.getText();
}