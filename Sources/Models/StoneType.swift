import SwiftUI
import SceneKit

enum StoneType: String, CaseIterable, Identifiable, Codable {
    case ice
    case roseQuartz = "rose_quartz"
    case obsidian
    case jade

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ice:        return "얼음 수정"
        case .roseQuartz: return "장미 수정"
        case .obsidian:   return "흑요석"
        case .jade:       return "비취"
        }
    }

    var description: String {
        switch self {
        case .ice:        return "차가운 투명함 속에\n고요함이 깃든 돌"
        case .roseQuartz: return "따뜻한 사랑과 위로를\n담은 분홍빛 돌"
        case .obsidian:   return "어둠을 받아들여\n평화를 찾는 검은 돌"
        case .jade:       return "대지의 기운을 담은\n깊은 초록빛 돌"
        }
    }

    // Base diffuse colour
    var baseColor: UIColor {
        switch self {
        case .ice:
            return UIColor(red: 0.82, green: 0.93, blue: 1.00, alpha: 0.88)
        case .roseQuartz:
            return UIColor(red: 0.96, green: 0.76, blue: 0.82, alpha: 1.00)
        case .obsidian:
            return UIColor(red: 0.07, green: 0.07, blue: 0.11, alpha: 1.00)
        case .jade:
            return UIColor(red: 0.22, green: 0.58, blue: 0.40, alpha: 1.00)
        }
    }

    // Secondary highlight colour used in lighting / particle tints
    var glowColor: UIColor {
        switch self {
        case .ice:        return UIColor(red: 0.75, green: 0.92, blue: 1.00, alpha: 1.00)
        case .roseQuartz: return UIColor(red: 1.00, green: 0.72, blue: 0.82, alpha: 1.00)
        case .obsidian:   return UIColor(red: 0.60, green: 0.50, blue: 0.90, alpha: 1.00)
        case .jade:       return UIColor(red: 0.40, green: 0.90, blue: 0.65, alpha: 1.00)
        }
    }

    var accentColor: Color {
        switch self {
        case .ice:        return Color(red: 0.60, green: 0.85, blue: 1.00)
        case .roseQuartz: return Color(red: 0.95, green: 0.62, blue: 0.74)
        case .obsidian:   return Color(red: 0.60, green: 0.50, blue: 0.90)
        case .jade:       return Color(red: 0.30, green: 0.75, blue: 0.52)
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .ice:
            return [Color(red: 0.88, green: 0.95, blue: 1.00), Color(red: 0.74, green: 0.87, blue: 0.97)]
        case .roseQuartz:
            return [Color(red: 1.00, green: 0.92, blue: 0.94), Color(red: 0.96, green: 0.80, blue: 0.87)]
        case .obsidian:
            return [Color(red: 0.10, green: 0.09, blue: 0.16), Color(red: 0.06, green: 0.05, blue: 0.10)]
        case .jade:
            return [Color(red: 0.88, green: 0.96, blue: 0.90), Color(red: 0.72, green: 0.89, blue: 0.79)]
        }
    }

    // PBR material parameters
    var metalness: CGFloat {
        switch self {
        case .ice:        return 0.02
        case .roseQuartz: return 0.12
        case .obsidian:   return 0.45
        case .jade:       return 0.08
        }
    }

    var initialRoughness: CGFloat { 0.78 }
    var polishedRoughness: CGFloat {
        switch self {
        case .ice:        return 0.03
        case .roseQuartz: return 0.06
        case .obsidian:   return 0.02
        case .jade:       return 0.08
        }
    }

    var isTranslucent: Bool { self == .ice }

    // Scale applied to the base SCNSphere to give a flattened worry-stone shape
    var sceneScale: SCNVector3 { SCNVector3(1.35, 0.72, 1.08) }

    // Ambient sparkle birth rate at max polish
    var maxAmbientSparkle: CGFloat {
        switch self {
        case .obsidian: return 6
        case .ice:      return 10
        default:        return 4
        }
    }
}
