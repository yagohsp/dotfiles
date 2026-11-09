#pragma once

#include <optional>

namespace yshell_light::shell::services::sensorslib {

void ensureInit();

[[nodiscard]] std::optional<double> cpuPackageTemp();
[[nodiscard]] std::optional<double> gpuPciAverageTemp();

} // namespace yshell_light::shell::services::sensorslib
