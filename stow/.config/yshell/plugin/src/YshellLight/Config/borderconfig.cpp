#include "borderconfig.hpp"

#include <algorithm>

namespace yshell_light::shell::config {

int BorderConfig::minThickness() {
    return 2;
}

int BorderConfig::clampedThickness() const {
    return std::max(minThickness(), m_thickness);
}

} // namespace yshell_light::shell::config
