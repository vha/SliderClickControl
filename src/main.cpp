#include "main.hpp"

#include "HMUI/TextSlider.hpp"
#include "UnityEngine/EventSystems/PointerEventData.hpp"

static modloader::ModInfo modInfo{MOD_ID, VERSION, 0};

constexpr float kClickStepFraction = 0.10f;

MAKE_HOOK_MATCH(TextSlider_UpdateDrag, &HMUI::TextSlider::UpdateDrag,
    void, HMUI::TextSlider* self,
    ::UnityEngine::EventSystems::PointerEventData* eventData) {

    float currentValue = self->get_normalizedValue();

    TextSlider_UpdateDrag(self, eventData);

    float targetValue = self->get_normalizedValue();

    if (currentValue != targetValue) {
        float newValue = currentValue + kClickStepFraction * (targetValue - currentValue);
        self->SetNormalizedValue(newValue, true);
    }
}

extern "C" __attribute__((visibility("default"))) void setup(CModInfo* info) {
    *info = modInfo.to_c();
    Paper::Logger::RegisterFileContextId(MOD_ID);
    SliderClickControl::Logger.info("Setup complete");
}

extern "C" __attribute__((visibility("default"))) void late_load() {
    il2cpp_functions::Init();
    custom_types::Register::AutoRegister();

    INSTALL_HOOK(SliderClickControl::Logger, TextSlider_UpdateDrag);
    SliderClickControl::Logger.info("Hooks installed");
}
