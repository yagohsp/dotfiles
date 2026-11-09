#pragma once

#include "common.hpp"
#include "objectnode.hpp"
#include "settingsfile.hpp"

namespace yshell_light::shell::settings {

class RootNode : public ObjectNode {
    Q_OBJECT

    Q_PROPERTY(QList<yshell_light::shell::settings::Diagnostic> diagnostics READ diagnostics NOTIFY diagnosticsChanged)

public:
    explicit RootNode(bool watch, const QString& path, RootNode* fallback, QObject* parent = nullptr);

    [[nodiscard]] QList<Diagnostic> diagnostics() const;

    void load();

signals:
    void diagnosticsChanged();
    void treeLoaded(yshell_light::shell::settings::RootNode* self);
    void treeLoadFailed(yshell_light::shell::settings::RootNode* self, const QString& error);
    void treeSaveFailed(yshell_light::shell::settings::RootNode* self, const QString& error);

private:
    SettingsFile* const m_file;
    QList<Diagnostic> m_diagnostics;

    void reloadFromFile();
    void saveToFile();
};

} // namespace yshell_light::shell::settings
