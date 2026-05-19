import Foundation
import SwiftUI
import os
#if canImport(Translation)
import Translation
#endif

/// Bridges Apple's SwiftUI-only `TranslationSession` into the actor world the
/// rest of the app uses. A SwiftUI host view (see `AppleTranslationSessionHost`)
/// owns the `.translationTask` modifier and keeps the session alive in a sleep
/// loop so callers can issue multiple translations without re-triggering the
/// task on every call.
@available(iOS 18.0, *)
@MainActor
public final class AppleTranslationSessionBridge: ObservableObject {

    @Published public var configuration: TranslationSession.Configuration?

    private var activeSession: TranslationSession?
    private var activePair: PairKey?
    private var pending: CheckedContinuation<TranslationSession, Error>?
    private var pendingTimeout: Task<Void, Never>?
    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "translation_bridge")

    /// Seconds to wait for SwiftUI to deliver a session before we throw timeout.
    public var timeoutSeconds: Double = 15

    public init() {}

    /// Request a session for the given language pair. Returns the cached session
    /// instantly if the pair hasn't changed; otherwise updates the SwiftUI
    /// `.translationTask` binding and awaits delivery.
    public func session(
        source: Locale.Language?,
        target: Locale.Language
    ) async throws -> TranslationSession {
        let requested = PairKey(source: source, target: target)
        if let existing = activeSession, activePair == requested {
            logger.debug("reusing live session for \(requested.description, privacy: .public)")
            return existing
        }

        // Pair changed (or first call) — cancel any in-flight wait and ask
        // SwiftUI for a fresh session.
        cancelPending(with: TranslationError.providerUnavailable)
        activeSession = nil
        activePair = requested

        logger.debug("requesting new session for \(requested.description, privacy: .public)")
        configuration = TranslationSession.Configuration(source: source, target: target)

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<TranslationSession, Error>) in
            self.pending = cont
            let timeout = self.timeoutSeconds
            self.pendingTimeout = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                await self?.fireTimeoutIfStillPending()
            }
        }
    }

    /// Called by `AppleTranslationSessionHost` on every new SwiftUI task body.
    /// We register the session, resume any pending caller, then stay parked here
    /// — sleeping in a loop — so the session lifetime extends beyond a single
    /// translate call. Returning here would end the session per Apple's docs.
    public func runSession(_ session: TranslationSession) async {
        logger.debug("session delivered by .translationTask")
        activeSession = session
        pendingTimeout?.cancel()
        pendingTimeout = nil
        pending?.resume(returning: session)
        pending = nil

        // Park here until SwiftUI cancels us (configuration changed, view gone).
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        if activeSession === session {
            activeSession = nil
            activePair = nil
        }
        logger.debug("session task cancelled — cleaned up")
    }

    /// Pre-fetch a language pack without performing a real translation. Useful
    /// from the Language packs screen.
    public func prepare(source: Locale.Language?, target: Locale.Language) async throws {
        let session = try await self.session(source: source, target: target)
        try await session.prepareTranslation()
    }

    private func fireTimeoutIfStillPending() {
        guard pending != nil else { return }
        logger.error("session timed out after \(self.timeoutSeconds, privacy: .public)s")
        cancelPending(with: TranslationError.timeout)
    }

    private func cancelPending(with error: Error) {
        pendingTimeout?.cancel()
        pendingTimeout = nil
        pending?.resume(throwing: error)
        pending = nil
    }

    private struct PairKey: Equatable, CustomStringConvertible {
        let source: String?
        let target: String

        init(source: Locale.Language?, target: Locale.Language) {
            self.source = source?.minimalIdentifier
            self.target = target.minimalIdentifier
        }

        var description: String { "\(source ?? "auto") → \(target)" }
    }
}

/// Hidden SwiftUI view that owns the `.translationTask` modifier. Renders as a
/// 1×1 transparent pixel — `.frame(0,0)` would get optimised out of the layout
/// in extension contexts. The task body parks itself via `runSession(_:)` so
/// the delivered `TranslationSession` stays valid across multiple translate
/// calls.
@available(iOS 18.0, *)
public struct AppleTranslationSessionHost: View {

    @ObservedObject public var bridge: AppleTranslationSessionBridge

    public init(bridge: AppleTranslationSessionBridge) {
        self.bridge = bridge
    }

    public var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .translationTask(bridge.configuration) { session in
                await bridge.runSession(session)
            }
    }
}
