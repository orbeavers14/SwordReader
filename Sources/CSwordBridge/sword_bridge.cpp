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

const char *SwordManagerModuleName(
    const SwordManager *manager,
    size_t index
) {
    if (manager == nullptr || index >= manager->modules.size()) {
        return "";
    }

    return safeCString(manager->modules[index]->getName());
}

const char *SwordManagerModuleDescription(
    const SwordManager *manager,
    size_t index
) {
    if (manager == nullptr || index >= manager->modules.size()) {
        return "";
    }

    return safeCString(manager->modules[index]->getDescription());
}

const char *SwordManagerModuleLanguage(
    const SwordManager *manager,
    size_t index
) {
    if (manager == nullptr || index >= manager->modules.size()) {
        return "";
    }

    return safeCString(manager->modules[index]->getLanguage());
}

const char *SwordManagerModuleType(
    const SwordManager *manager,
    size_t index
) {
    if (manager == nullptr || index >= manager->modules.size()) {
        return "";
    }

    return safeCString(manager->modules[index]->getType());
}

} // extern "C"