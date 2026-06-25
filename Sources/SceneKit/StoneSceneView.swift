import SwiftUI
import SceneKit

// MARK: - UIViewRepresentable wrapper

struct StoneSceneView: UIViewRepresentable {

    let stoneType: StoneType
    @Binding var rubIntensity: Double
    var onRub: ((Double) -> Void)?   // passes pan distance

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.scene              = StoneScene(stone: stoneType)
        view.allowsCameraControl   = false
        view.backgroundColor       = .clear
        view.antialiasingMode      = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.rendersContinuously   = true

        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        view.addGestureRecognizer(pan)

        context.coordinator.scnView = view
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.applyPolish(intensity: rubIntensity)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(stoneType: stoneType, onRub: onRub)
    }

    // MARK: Coordinator
    final class Coordinator: NSObject {

        let stoneType: StoneType
        var onRub: ((Double) -> Void)?
        weak var scnView: SCNView?

        private var isRubbing = false
        private var lastIntensity: Double = 0
        private let haptic = UIImpactFeedbackGenerator(style: .light)

        init(stoneType: StoneType, onRub: ((Double) -> Void)?) {
            self.stoneType = stoneType
            self.onRub     = onRub
            super.init()
            haptic.prepare()
        }

        // MARK: Gesture
        @objc func handlePan(_ g: UIPanGestureRecognizer) {
            guard let view = scnView,
                  let stone = view.scene?.rootNode.childNode(withName: "stone", recursively: false)
            else { return }

            let t = g.translation(in: view)
            let distance = sqrt(t.x * t.x + t.y * t.y)
            g.setTranslation(.zero, in: view)

            switch g.state {
            case .began:
                isRubbing = true
                stone.removeAction(forKey: "idleRotate")
                setSparkle(active: true, on: stone)

            case .changed:
                // Rotate stone to follow finger — feels like rolling the stone
                stone.eulerAngles.x += Float(t.y) * 0.012
                stone.eulerAngles.y += Float(t.x) * 0.012

                haptic.impactOccurred(intensity: min(CGFloat(distance) / 60.0, 1.0))
                onRub?(distance)

            case .ended, .cancelled, .failed:
                isRubbing = false
                setSparkle(active: false, on: stone)
                resumeIdleRotation(on: stone)

            default: break
            }
        }

        // MARK: Polish
        func applyPolish(intensity: Double) {
            lastIntensity = intensity
            guard let view = scnView,
                  let stone = view.scene?.rootNode.childNode(withName: "stone", recursively: false),
                  let mat   = stone.geometry?.firstMaterial
            else { return }

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.4
            mat.roughness.contents = roughness(for: intensity)
            SCNTransaction.commit()

            let ambient = stoneType.maxAmbientSparkle * CGFloat(intensity)
            stone.particleSystems?.first?.birthRate = isRubbing ? ambient + 25 : ambient
        }

        // MARK: Private helpers
        private func roughness(for intensity: Double) -> CGFloat {
            let hi = stoneType.initialRoughness
            let lo = stoneType.polishedRoughness
            return CGFloat(hi - intensity * (hi - lo))
        }

        private func setSparkle(active: Bool, on stone: SCNNode) {
            guard let ps = stone.particleSystems?.first else { return }
            let ambient = stoneType.maxAmbientSparkle * CGFloat(lastIntensity)
            ps.birthRate = active ? ambient + 25 : ambient
        }

        private func resumeIdleRotation(on stone: SCNNode) {
            let action = SCNAction.repeatForever(
                .rotateBy(x: 0, y: .pi * 2, z: 0, duration: 22)
            )
            stone.runAction(action, forKey: "idleRotate")
        }
    }
}

// MARK: - Scene builder

private final class StoneScene: SCNScene {

    init(stone: StoneType) {
        super.init()
        setupStone(stone)
        setupLighting(stone)
        setupCamera()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Stone node
    private func setupStone(_ stone: StoneType) {
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 72

        let node = SCNNode(geometry: sphere)
        node.name  = "stone"
        node.scale = stone.sceneScale

        // PBR material
        let mat = SCNMaterial()
        mat.lightingModel       = .physicallyBased
        mat.diffuse.contents    = stone.baseColor
        mat.metalness.contents  = stone.metalness
        mat.roughness.contents  = stone.initialRoughness
        mat.isDoubleSided       = stone.isTranslucent

        if stone.isTranslucent {
            mat.transparency            = 0.18
            mat.transparencyMode        = .dualLayer
            mat.blendMode               = .alpha
        }

        sphere.firstMaterial = mat
        rootNode.addChildNode(node)

        // Gentle floating animation
        let up   = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 2.8).eased(.easeInEaseOut)
        let down = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 2.8).eased(.easeInEaseOut)
        node.runAction(.repeatForever(.sequence([up, down])))

        // Idle slow rotation
        let rotate = SCNAction.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 22))
        node.runAction(rotate, forKey: "idleRotate")

        // Sparkle particle system
        node.addParticleSystem(makeSparkle(for: stone))
    }

    // MARK: Particle system
    private func makeSparkle(for stone: StoneType) -> SCNParticleSystem {
        let ps = SCNParticleSystem()
        ps.birthRate                = 0
        ps.birthRateVariation       = 0
        ps.emitterShape             = SCNSphere(radius: 1.05)
        ps.particleLifeSpan         = 0.7
        ps.particleLifeSpanVariation = 0.3
        ps.particleSize             = 0.05
        ps.particleSizeVariation    = 0.02
        ps.particleColor            = stone.glowColor
        ps.particleColorVariation   = SCNVector4(0.15, 0.15, 0.15, 0)
        ps.blendMode                = .additive
        ps.isAffectedByGravity      = false
        ps.isAffectedByPhysicsFields = false
        ps.particleVelocity         = 0.25
        ps.particleVelocityVariation = 0.15
        ps.loops                    = true
        ps.speedFactor              = 1.0
        ps.name                     = "sparkle"
        return ps
    }

    // MARK: Lighting
    private func setupLighting(_ stone: StoneType) {
        // Key light (warm spot from upper-right)
        let key       = SCNNode()
        key.light     = SCNLight()
        key.light!.type      = .spot
        key.light!.intensity = 900
        key.light!.color     = UIColor(white: 1.0, alpha: 1.0)
        key.light!.spotInnerAngle = 25
        key.light!.spotOuterAngle = 55
        key.light!.castsShadow    = false
        key.position  = SCNVector3(3.5, 5, 5)
        key.look(at: .init(0, 0, 0))
        rootNode.addChildNode(key)

        // Fill / ambient
        let fill           = SCNNode()
        fill.light         = SCNLight()
        fill.light!.type   = .ambient
        fill.light!.intensity = 180
        fill.light!.color  = stone.isTranslucent
            ? UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 1.0)
            : UIColor(white: 0.88, alpha: 1.0)
        rootNode.addChildNode(fill)

        // Rim / back light gives that 3-D pop
        let rim           = SCNNode()
        rim.light         = SCNLight()
        rim.light!.type   = .directional
        rim.light!.intensity = 350
        rim.light!.color  = UIColor(cgColor: stone.glowColor.cgColor.copy(alpha: 0.7)!)
        rim.position      = SCNVector3(-4, -2, -4)
        rim.look(at: .init(0, 0, 0))
        rootNode.addChildNode(rim)
    }

    // MARK: Camera
    private func setupCamera() {
        let cam           = SCNNode()
        cam.camera        = SCNCamera()
        cam.camera!.fieldOfView     = 38
        cam.camera!.zNear           = 0.1
        cam.camera!.zFar            = 50
        cam.position      = SCNVector3(0, 0, 5.2)
        rootNode.addChildNode(cam)
    }
}

// MARK: - SCNAction easing helper
private extension SCNAction {
    func eased(_ mode: SCNActionTimingMode) -> SCNAction {
        timingMode = mode
        return self
    }
}
