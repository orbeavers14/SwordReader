#include "sword_bridge.h"

#include <string>

#include <swmgr.h>
#include <swversion.h>

const char *SwordBridgeVersion(void) {
    return "SwordKit Bridge 0.1";
}

const char *SwordEngineVersion(void) {
    static sword::SWVersion version;
    return version.getText();
}

const char *SwordInstalledModuleNames(void) {
    static thread_local std::string moduleNames;
    moduleNames.clear();

    sword::SWMgr manager;
    const auto &modules = manager.getModules();

    for (const auto &entry : modules) {
        if (!moduleNames.empty()) {
            moduleNames += '\n';
        }

        moduleNames += entry.first.c_str();
    }

    return moduleNames.c_str();
}