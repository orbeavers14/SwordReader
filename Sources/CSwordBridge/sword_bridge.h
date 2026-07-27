#ifndef SWORD_BRIDGE_H
#define SWORD_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

/// Returns the version of the SwordKit bridge.
/// This lets us verify the bridge is connected before
/// exposing the full SWORD API.
const char *SwordBridgeVersion(void);

#ifdef __cplusplus
}
#endif

#endif
