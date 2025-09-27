//
//  DebugImportViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

#if DEBUG
final class DebugImportViewModel: DebugImportViewModelProtocol {
    
    // MARK: - Properties
    
    private(set) var state: State {
        didSet { onStateChange?(state) }
    }
    
    private let debugImportStorage: DebugImportStoringProtocol
    private let debugImporter: DebugImportingProtocol
    
    var onStateChange: ((State) -> Void)?
    
    // MARK: - Init
    
    init(
        debugImportStorage: DebugImportStoringProtocol,
        debugImporter: DebugImportingProtocol
    ) {
        self.debugImportStorage = debugImportStorage
        self.debugImporter = debugImporter
        let didRun = debugImportStorage.didRunOnce
        let overwrite = debugImportStorage.isOverwriteEnabled
        let version = debugImportStorage.requiredSeedVersion
        self.state = State(
            hasRunBefore: didRun,
            isEnabledFlag: SeedConfig.isEnabled,
            overwrite: overwrite,
            seedVersion: version
        )
    }
    
    // MARK: - Public Methods
    
    func setImporterEnabled(_ isOn: Bool) {
        SeedConfig.isEnabled = isOn
        state.isEnabledFlag = isOn
        refreshDerivedState()
        append("⚙️ DebugImporter.enabled = \(isOn)")
    }
    
    func setOverwrite(_ isOn: Bool) {
        state.overwrite = isOn
        debugImportStorage.isOverwriteEnabled = isOn
        append("⚙️ Overwrite = \(isOn)")
    }

    /// Установить требуемую версию сид-данных (сохранится в UserDefaults).
    func setSeedVersion(_ version: Int) {
        let newValue = max(1, version)
        debugImportStorage.requiredSeedVersion = newValue
        state.seedVersion = newValue
        append("🏷️ Версия сид-данных = \(newValue)")
    }

    /// Инкремент/декремент версии (для степпера).
    func bumpSeedVersion(by delta: Int) {
        setSeedVersion(state.seedVersion + delta)
    }
    
    func runImport() {
        guard !state.isRunning else { return }
        state.isRunning = true
        append("⏳ Запуск импорта…")

        Task { [weak self] in
            guard let self else { return }
            // фоновая часть
            await self.debugImporter.runIfNeeded(
                overwrite: self.state.overwrite,
                checksumNamespace: SeedConfig.checksumNamespace,
                pruneMissing: true
            )

            // обновление UI строго на главном
            await MainActor.run {
                self.refreshDerivedState()
                self.state.isRunning = false
                self.append("✅ Завершено. Маркер: \(self.state.hasRunBefore ? "установлен" : "не установлен"). Смотри консоль Xcode для подробного лога.")
            }
        }
    }
    
    func resetMarkers() {
        debugImporter.resetMarkers()
        refreshDerivedState()
        append("🔄 Маркеры импорта сброшены (можно запускать снова).")
    }
    
    // MARK: - Private Methods
    
    private func append(_ line: String) {
        let prefix = state.log.isEmpty ? "" : "\n"
        state.log.append("\(prefix)\(line)")
    }

    /// Обновляет вычисляемые поля из стораджа в локальном состоянии.
    private func refreshDerivedState() {
        state.hasRunBefore = debugImportStorage.didRunOnce
        state.isEnabledFlag = SeedConfig.isEnabled
        state.overwrite = debugImportStorage.isOverwriteEnabled
        state.seedVersion = debugImportStorage.requiredSeedVersion
        state.hasRunBefore = debugImportStorage.didRunOnce && state.isEnabledFlag
    }
}
#endif
