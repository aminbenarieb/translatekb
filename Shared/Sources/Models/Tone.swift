import Foundation

/// The tone the user wants the translated text rewritten in.
public enum Tone: String, Codable, CaseIterable, Sendable {
    case neutral
    case casual
    case formal
    case business
    case friendly

    public var displayName: String {
        switch self {
        case .neutral:  return "Neutral"
        case .casual:   return "Casual"
        case .formal:   return "Formal"
        case .business: return "Business"
        case .friendly: return "Friendly"
        }
    }

    public var symbol: String {
        switch self {
        case .neutral:  return "circle"
        case .casual:   return "bubble.left"
        case .formal:   return "person.crop.square"
        case .business: return "briefcase"
        case .friendly: return "heart"
        }
    }

    /// Instruction for an LLM-backed ToneAdapter. Empty for `.neutral` (pass-through).
    public var prompt: String {
        switch self {
        case .neutral:  return ""
        case .casual:   return "Rewrite in a casual, informal tone, as if texting a friend."
        case .formal:   return "Rewrite in a formal, polite tone, suitable for official communication."
        case .business: return "Rewrite in a concise, professional business tone."
        case .friendly: return "Rewrite in a warm, friendly tone."
        }
    }
}
