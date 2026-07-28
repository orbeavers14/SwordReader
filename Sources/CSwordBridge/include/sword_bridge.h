#ifndef SWORD_BRIDGE_H
#define SWORD_BRIDGE_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

const char *SwordBridgeVersion(void);
const char *SwordEngineVersion(void);

typedef struct SwordManager SwordManager;
typedef struct SwordModuleHandle SwordModuleHandle;

SwordManager *SwordManagerCreate(void);
void SwordManagerDestroy(SwordManager *manager);

size_t SwordManagerModuleCount(const SwordManager *manager);

SwordModuleHandle *SwordManagerOpenModule(
    const SwordManager *manager,
    size_t index
);

void SwordModuleDestroy(SwordModuleHandle *module);

const char *SwordModuleName(
    const SwordModuleHandle *module
);

const char *SwordModuleDescription(
    const SwordModuleHandle *module
);

const char *SwordModuleLanguage(
    const SwordModuleHandle *module
);

const char *SwordModuleType(
    const SwordModuleHandle *module
);

int SwordModuleSetKey(
    SwordModuleHandle *module,
    const char *reference
);

const char *SwordModuleCurrentKey(
    SwordModuleHandle *module
);

const char *SwordModuleRenderText(
    SwordModuleHandle *module
);

#ifdef __cplusplus
}
#endif

#endif
