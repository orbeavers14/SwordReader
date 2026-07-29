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

void SwordModuleIncrement(
    SwordModuleHandle *module
);

void SwordModuleDecrement(
    SwordModuleHandle *module
);

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

size_t SwordModuleParseReferenceCount(
    SwordModuleHandle *module,
    const char *reference
);

const char *SwordModuleParsedReference(
    SwordModuleHandle *module,
    size_t index
);

void SwordModuleClearParsedReferences(
    SwordModuleHandle *module
);

size_t SwordModuleSearchCount(
    SwordModuleHandle *module,
    const char *query,
    const char *scope,
    int searchType,
    int attributeType,
    int caseSensitive
);

const char *SwordModuleSearchResultReference(
    SwordModuleHandle *module,
    size_t index
);

long SwordModuleSearchResultScore(
    const SwordModuleHandle *module,
    size_t index
);

void SwordModuleClearSearchResults(
    SwordModuleHandle *module
);

void SwordModuleTerminateSearch(
    SwordModuleHandle *module
);

#ifdef __cplusplus
}
#endif

#endif
