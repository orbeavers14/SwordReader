#include "sword_bridge.h"

#include <algorithm>
#include <string>
#include <vector>

#include <swmgr.h>
#include <swmodule.h>
#include <swversion.h>

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

    explicit SwordModuleHandle(sword::SWModule *module)
        : module(module) {}
};

extern "C" {

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
