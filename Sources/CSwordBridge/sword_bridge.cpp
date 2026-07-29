#include "sword_bridge.h"

#include <algorithm>
#include <regex.h>
#include <string>
#include <vector>

#include <swmgr.h>
#include <swmodule.h>
#include <swversion.h>

#include <listkey.h>
#include <versekey.h>

namespace {

const char *safeCString(const char *value) {
    return value != nullptr ? value : "";
}

} // namespace

struct SwordManager {
    sword::SWMgr manager;
    std::vector<sword::SWModule *> modules;

    SwordManager() {
        const auto &installedModules = manager.getModules();

        modules.reserve(installedModules.size());

        for (const auto &entry : installedModules) {
            if (entry.second != nullptr) {
                modules.push_back(entry.second);
            }
        }

        std::sort(
            modules.begin(),
            modules.end(),
            [](const sword::SWModule *lhs, const sword::SWModule *rhs) {
                return std::string(safeCString(lhs->getName()))
                    < std::string(safeCString(rhs->getName()));
            }
        );
    }
};

struct SwordModuleHandle {
    sword::SWModule *module;
    std::string currentKey;
    std::string renderedText;
    
    std::vector<std::string> parsedReferences;
    std::string parsedReferenceBuffer;

    std::vector<std::string> searchResultReferences;
    std::vector<long> searchResultScores;
    std::string searchResultReferenceBuffer;

    explicit SwordModuleHandle(sword::SWModule *module)
        : module(module) {}
};

extern "C" {

size_t SwordModuleParseReferenceCount(
    SwordModuleHandle *module,
    const char *reference
) {
    if (
        module == nullptr
        || module->module == nullptr
        || reference == nullptr
        || reference[0] == '\0'
    ) {
        return 0;
    }

    module->parsedReferences.clear();
    module->parsedReferenceBuffer.clear();

    try {
        sword::VerseKey parser;

        sword::ListKey references = parser.parseVerseList(
            reference,
            module->module->getKeyText(),
            true
        );

        const int count = references.getCount();

        if (count <= 0) {
            return 0;
        }

        module->parsedReferences.reserve(
            static_cast<size_t>(count)
        );

        for (int index = 0; index < count; ++index) {
            const sword::SWKey *key =
                references.getElement(index);

            if (key == nullptr) {
                continue;
            }

            const char *text = key->getText();

            if (text == nullptr || text[0] == '\0') {
                continue;
            }

            module->parsedReferences.emplace_back(text);
        }

        return module->parsedReferences.size();
    } catch (...) {
        module->parsedReferences.clear();
        module->parsedReferenceBuffer.clear();
        return 0;
    }
}

const char *SwordModuleParsedReference(
    SwordModuleHandle *module,
    size_t index
) {
    if (
        module == nullptr
        || index >= module->parsedReferences.size()
    ) {
        return "";
    }

    try {
        module->parsedReferenceBuffer =
            module->parsedReferences[index];

        return module->parsedReferenceBuffer.c_str();
    } catch (...) {
        module->parsedReferenceBuffer.clear();
        return "";
    }
}

void SwordModuleClearParsedReferences(
    SwordModuleHandle *module
) {
    if (module == nullptr) {
        return;
    }

    module->parsedReferences.clear();
    module->parsedReferenceBuffer.clear();
}

size_t SwordModuleSearchCount(
    SwordModuleHandle *module,
    const char *query,
    int searchType,
    int caseSensitive
) {
    if (
        module == nullptr
        || module->module == nullptr
        || query == nullptr
        || query[0] == '\0'
        || (
            searchType != sword::SWModule::SEARCHTYPE_PHRASE
            && searchType != sword::SWModule::SEARCHTYPE_MULTIWORD
            && searchType != sword::SWModule::SEARCHTYPE_REGEX
            && searchType != sword::SWModule::SEARCHTYPE_ENTRYATTR
        )
        || (caseSensitive != 0 && caseSensitive != 1)
    ) {
        return 0;
    }

    module->searchResultReferences.clear();
    module->searchResultScores.clear();
    module->searchResultReferenceBuffer.clear();

    try {
        std::string searchQuery = query;

        if (
            searchType == sword::SWModule::SEARCHTYPE_ENTRYATTR
        ) {
            searchQuery =
                "Word//Lemma./" + searchQuery + "/";
        }

        sword::ListKey results = module->module->search(
            searchQuery.c_str(),
            searchType,
            caseSensitive ? 0 : REG_ICASE
        );

        const int count = results.getCount();

        if (count <= 0) {
            return 0;
        }

        module->searchResultReferences.reserve(
            static_cast<size_t>(count)
        );
        module->searchResultScores.reserve(
            static_cast<size_t>(count)
        );

        for (int index = 0; index < count; ++index) {
            const sword::SWKey *key = results.getElement(index);

            if (key == nullptr) {
                continue;
            }

            const char *reference = key->getText();

            if (reference == nullptr || reference[0] == '\0') {
                continue;
            }

            module->searchResultReferences.emplace_back(reference);
            module->searchResultScores.push_back(
                static_cast<long>(key->userData)
            );
        }

        return module->searchResultReferences.size();
    } catch (...) {
        module->searchResultReferences.clear();
        module->searchResultScores.clear();
        module->searchResultReferenceBuffer.clear();
        return 0;
    }
}

const char *SwordModuleSearchResultReference(
    SwordModuleHandle *module,
    size_t index
) {
    if (
        module == nullptr
        || index >= module->searchResultReferences.size()
    ) {
        return "";
    }

    try {
        module->searchResultReferenceBuffer =
            module->searchResultReferences[index];

        return module->searchResultReferenceBuffer.c_str();
    } catch (...) {
        module->searchResultReferenceBuffer.clear();
        return "";
    }
}

long SwordModuleSearchResultScore(
    const SwordModuleHandle *module,
    size_t index
) {
    if (
        module == nullptr
        || index >= module->searchResultScores.size()
    ) {
        return 0;
    }

    return module->searchResultScores[index];
}

void SwordModuleClearSearchResults(
    SwordModuleHandle *module
) {
    if (module == nullptr) {
        return;
    }

    module->searchResultReferences.clear();
    module->searchResultScores.clear();
    module->searchResultReferenceBuffer.clear();
}

const char *SwordBridgeVersion(void) {
    return "0.1.0";
}

const char *SwordEngineVersion(void) {
    static sword::SWVersion version;
    return version.getText();
}

SwordManager *SwordManagerCreate(void) {
    try {
        return new SwordManager();
    } catch (...) {
        return nullptr;
    }
}

void SwordManagerDestroy(SwordManager *manager) {
    delete manager;
}

size_t SwordManagerModuleCount(const SwordManager *manager) {
    if (manager == nullptr) {
        return 0;
    }

    return manager->modules.size();
}

SwordModuleHandle *SwordManagerOpenModule(
    const SwordManager *manager,
    size_t index
) {
    if (manager == nullptr || index >= manager->modules.size()) {
        return nullptr;
    }

    try {
        return new SwordModuleHandle(manager->modules[index]);
    } catch (...) {
        return nullptr;
    }
}

void SwordModuleDestroy(SwordModuleHandle *module) {
    delete module;
}

const char *SwordModuleName(
    const SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }

    return safeCString(module->module->getName());
}

const char *SwordModuleDescription(
    const SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }

    return safeCString(module->module->getDescription());
}

const char *SwordModuleLanguage(
    const SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }

    return safeCString(module->module->getLanguage());
}

const char *SwordModuleType(
    const SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }

    return safeCString(module->module->getType());
}

int SwordModuleSetKey(
    SwordModuleHandle *module,
    const char *reference
) {
    if (
        module == nullptr
        || module->module == nullptr
        || reference == nullptr
        || reference[0] == '\0'
    ) {
        return -1;
    }

    try {
        const char status = module->module->setKey(reference);

        module->currentKey = safeCString(
            module->module->getKeyText()
        );

        module->renderedText.clear();

        return static_cast<int>(status);
    } catch (...) {
        module->currentKey.clear();
        module->renderedText.clear();
        return -1;
    }
}

const char *SwordModuleCurrentKey(
    SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }

    try {
        module->currentKey = safeCString(
            module->module->getKeyText()
        );

        return module->currentKey.c_str();
    } catch (...) {
        module->currentKey.clear();
        return "";
    }
}

const char *SwordModuleRenderText(
    SwordModuleHandle *module
                                  ) {
    if (module == nullptr || module->module == nullptr) {
        return "";
    }
    
    try {
        module->renderedText =
        module->module->renderText().c_str();
        
        return module->renderedText.c_str();
    } catch (...) {
        module->renderedText.clear();
        return "";
    }
}

void SwordModuleIncrement(
    SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return;
    }

    try {
        module->module->increment();

        module->currentKey =
            safeCString(module->module->getKeyText());

        module->renderedText.clear();
    }
    catch (...) {
    }
}

void SwordModuleDecrement(
    SwordModuleHandle *module
) {
    if (module == nullptr || module->module == nullptr) {
        return;
    }

    try {
        module->module->decrement();

        module->currentKey =
            safeCString(module->module->getKeyText());

        module->renderedText.clear();
    }
    catch (...) {
    }
}

} // extern "C"
