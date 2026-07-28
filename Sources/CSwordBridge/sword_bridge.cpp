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

} // extern "C"
