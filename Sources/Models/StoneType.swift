import SwiftUI
import SceneKit

enum StoneType: String, CaseIterable, Identifiable, Codable {
    case jade       // 투명한 옥색
    case amethyst   // 투명한 자수정
    case glass      // 투명 유리
    case obsidian   // 빛나는 흑요석

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .jade:     return "옥"
        case .amethyst: return "자수정"
        case .glass:    return "수정"
        case .obsidian: return "흑요석"
        }
    }

    var description: String {
        switch self {
        case .jade:     return "맑은 초록빛 투명함 속에\n평온함이 깃든 돌"
        case .amethyst: return "깊은 보랏빛 안에\n신비로움이 담긴 돌"
        case .glass:    return "투명한 빛처럼\n모든 것을 비추는 돌"
        case .obsidian: return "어둠 속에 빛나는\n강인한 검은 돌"
        }
    }

    var baseColor: UIColor {
        switch self {
        case .jade:     return UIColor(red: 0.18, green: 0.72, blue: 0.50, alpha: 0.82)
        case .amethyst: return UIColor(red: 0.60, green: 0.35, blue: 0.88, alpha: 0.82)
        case .glass:    return UIColor(red: 0.88, green: 0.96, blue: 1.00, alpha: 0.55)
        case .obsidian: return UIColor(red: 0.05, green: 0.05, blue: 0.09, alpha: 1.00)
        }
    }

    var glowColor: UIColor {
        switch self {
        case .jade:     return UIColor(red: 0.30, green: 0.92, blue: 0.62, alpha: 1.00)
        case .amethyst: return UIColor(red: 0.78, green: 0.52, blue: 1.00, alpha: 1.00)
        case .glass:    return UIColor(red: 0.80, green: 0.95, blue: 1.00, alpha: 1.00)
        case .obsidian: return UIColor(red: 0.55, green: 0.44, blue: 0.92, alpha: 1.00)
        }
    }

    var accentColor: Color {
        switch self {
        case .jade:     return Color(red: 0.22, green: 0.76, blue: 0.53)
        case .amethyst: return Color(red: 0.68, green: 0.42, blue: 0.92)
        case .glass:    return Color(red: 0.60, green: 0.86, blue: 1.00)
        case .obsidian: return Color(red: 0.55, green: 0.44, blue: 0.90)
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .jade:
            return [Color(red: 0.88, green: 0.97, blue: 0.92), Color(red: 0.72, green: 0.90, blue: 0.80)]
        case .amethyst:
            return [Color(red: 0.94, green: 0.90, blue: 0.98), Color(red: 0.84, green: 0.76, blue: 0.96)]
        case .glass:
            return [Color(red: 0.90, green: 0.96, blue: 1.00), Color(red: 0.78, green: 0.90, blue: 0.98)]
        case .obsidian:
            return [Color(red: 0.10, green: 0.09, blue: 0.16), Color(red: 0.06, green: 0.05, blue: 0.10)]
        }
    }

    var metalness: CGFloat {
        switch self {
        case .jade:     return 0.05
        case .amethyst: return 0.08
        case .glass:    return 0.02
        case .obsidian: return 0.72
        }
    }

    var initialRoughness: CGFloat { 0.72 }
    var polishedRoughness: CGFloat {
        switch self {
        case .jade:     return 0.05
        case .amethyst: return 0.04
        case .glass:    return 0.01
        case .obsidian: return 0.01
        }
    }

    var isTranslucent: Bool { self != .obsidian }

    var transparency: CGFloat {
        switch self {
        case .jade:     return 0.22
        case .amethyst: return 0.20
        case .glass:    return 0.48
        case .obsidian: return 0.00
        }
    }

    var sceneScale: SCNVector3 { SCNVector3(1.0, 1.0, 1.0) }

    var maxAmbientSparkle: CGFloat {
        switch self {
        case .obsidian: return 8
        case .glass:    return 14
        case .amethyst: return 10
        case .jade:     return 6
        }
    }
}
