#ifndef SWORD_BRIDGE_H
#define SWORD_BRIDGE_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

const char *SwordBridgeVersion(void);
const char *SwordEngineVersion(void);

typedef struct SwordManager SwordManager;

SwordManager *SwordManagerCreate(void);
void SwordManagerDestroy(SwordManager *manager);

size_t SwordManagerModuleCount(const SwordManager *manager);

const char *SwordManagerModuleName(
    const SwordManager *manager,
    size_t index
);

const char *SwordManagerModuleDescription(
    const SwordManager *manager,
    size_t index
);

const char *SwordManagerModuleLanguage(
    const SwordManager *manager,
    size_t index
);

const char *SwordManagerModuleType(
    const SwordManager *manager,
    size_t index
);

#ifdef __cplusplus
}
#endif

#endif