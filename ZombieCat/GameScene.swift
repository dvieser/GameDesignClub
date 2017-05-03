/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import CoreMotion

struct PhysicsType  {
  static let none            :UInt32  =   0
  static let player          :UInt32  =   1
  static let wall            :UInt32  =   2
  static let beaker          :UInt32  =   4
  static let explosionRadius :UInt32  =   8
  static let cat             :UInt32  =   16
  static let zombieCat       :UInt32  =   32
}

class GameScene: SKScene {
    
    let motionManager = CMMotionManager()
    
    var pinBeakerToZombieArm: SKPhysicsJointFixed?
    var beakerReady = false
    var explosionTextures = [SKTexture]()
    let sleepyTexture = SKTexture(imageNamed: "cat_sleepy")
    let scaredTexture = SKTexture(imageNamed: "cat_awake")
    var monsters: [SKSpriteNode] = []
    var player: SKSpriteNode?
    var arm: SKSpriteNode?

    var previousThrowPower = 100.0
    var previousThrowAngle = 0.0
    var currentPower = 100.0
    var currentAngle = 0.0
    var powerMeterNode: SKSpriteNode? = nil
    var powerMeterFilledNode: SKSpriteNode? = nil
    
    var beakersLeft = 300
    var catsRemaining = 2
    
    private var panStartLocation:CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        motionManager.startAccelerometerUpdates()
        newProjectile()
        for i in 0...8 {
            explosionTextures.append(SKTexture(imageNamed: "regularExplosion0\(i)"))
        }
        
        for child in self.children {
            if child.name == "monster" {
                if let child = child as? SKSpriteNode {
                    monsters.append(child)
//                    child.physicsBody?.allowsRotation = false
//                    child.physicsBody?.mass = 100.0
                }
            }
        }
        
        player = childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 400))
        player?.physicsBody?.isDynamic = true
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.mass = 1.5
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -50)
        
        powerMeterNode = childNode(withName: "powerMeter") as? SKSpriteNode
        powerMeterFilledNode = powerMeterNode?.childNode(withName: "powerMeterFilled") as? SKSpriteNode
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panRecognizer)
        
        self.powerMeterNode?.isHidden = true
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
//        updateMonsters()
    }

    func newProjectile () {
        let beaker = SKSpriteNode(imageNamed: "beaker")
        beaker.name = "beaker"
        beaker.zPosition = 5
        beaker.position = CGPoint(x: 120, y: 625)
        let beakerBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        beakerBody.mass = 0.5
        beakerBody.categoryBitMask = PhysicsType.beaker
        beakerBody.collisionBitMask = PhysicsType.wall | PhysicsType.cat | PhysicsType.zombieCat
        beaker.physicsBody = beakerBody
        addChild(beaker)
        
        //TODO: Add Beaker to Player Movement
//        if let armBody = childNode(withName: "player")?.childNode(withName: "arm")?.physicsBody {
//            pinBeakerToZombieArm = SKPhysicsJointFixed.joint(withBodyA: armBody, bodyB: beakerBody, anchor: CGPoint.zero)
//            physicsWorld.add(pinBeakerToZombieArm!)
//            beakerReady = true
//        }
        
        let cloud = SKSpriteNode(imageNamed: "regularExplosion00")
        cloud.name = "cloud"
        cloud.setScale(0)
        cloud.zPosition = 1
        beaker.addChild(cloud)
        
        let explosionRadius = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 200, height: 200))
        explosionRadius.name = "explosionRadius"
        
        let explosionRadiusBody = SKPhysicsBody(circleOfRadius: 200)
        explosionRadiusBody.mass = 0.01
        explosionRadiusBody.pinned = true
        explosionRadiusBody.categoryBitMask = PhysicsType.explosionRadius
        explosionRadiusBody.collisionBitMask = PhysicsType.none
        explosionRadiusBody.contactTestBitMask = PhysicsType.cat
        
        explosionRadius.physicsBody = explosionRadiusBody
        beaker.addChild(explosionRadius)
    }

    func tossBeaker(strength: CGVector) {
        if beakerReady == true {
            if let beaker = childNode(withName: "beaker") {
                if let arm = childNode(withName: "player")?.childNode(withName: "arm") {
                    let toss = SKAction.run() {
                        self.physicsWorld.remove(self.pinBeakerToZombieArm!)
                        beaker.physicsBody?.applyImpulse(strength)
                        beaker.physicsBody?.applyAngularImpulse(0.1125)
                        self.beakerReady = false
                    }
                    // Change the zombies swing based on the vector
                    // sum the vector and cap at a minimum of 100 and max of 5000, then normalize
                    let totalStrength = (max(100, min(5000.0, fabs(strength.dx) + fabs(strength.dy))) / 5000.0)
                    // invert strength and stretch time to max of current wait time (fuse + reset)
                    let time = max(0.1, 1.0 - Double(totalStrength)) * 1.3 // <- 1.3 = total time of fuse and reset
                    // only make swing backwards if move down and left
                    let direction:CGFloat = strength.dx > 0.0 && strength.dy > 0.0 ? -6.28318 : 6.218318
                    let followTrough = SKAction.rotate(byAngle: direction, duration: time)
                    
                    arm.run(SKAction.sequence([toss, followTrough]))
                }
                
                if let cloud = beaker.childNode(withName: "cloud"),
                    let explosionRadius = beaker.childNode(withName: "explosionRadius") {
                    
                    // 1
                    let fuse = SKAction.wait(forDuration: 1.2)
                    let expandCloud = SKAction.scale(to: 3.5, duration: 0.25)
                    let contractCloud = SKAction.scale(to: 0, duration: 0.25)
                    previousThrowPower = currentPower
                    previousThrowAngle = currentAngle
                    
                    if let sparkNode = SKEmitterNode(fileNamed: "BeakerSparkTrail") {
                        beaker.addChild(sparkNode)
                    }
                    
                    if let smokeNode = SKEmitterNode(fileNamed: "BeakerSmoke") {
                        smokeNode.targetNode = self
                        beaker.addChild(smokeNode)
                    }
                    
                    // 2
                    let removeBeaker = SKAction.run() {
                        beaker.removeFromParent()
                    }
                    //let boom = SKAction.sequence([fuse, expandCloud, contractCloud, removeBeaker])
                    let animate = SKAction.animate(with: explosionTextures, timePerFrame: 0.056)
                    
                    let greenColor = SKColor(red: 57.0/255.0, green: 250.0/255.0, blue: 146.0/255.0, alpha: 1.0)
                    let turnGreen = SKAction.colorize(with: greenColor, colorBlendFactor: 0.7, duration: 0.3)
                    
                    let zombifyContactedCat = SKAction.run() {
                        if let physicsBody = explosionRadius.physicsBody {
                            for contactedBody in physicsBody.allContactedBodies() {
                                if (physicsBody.contactTestBitMask & contactedBody.categoryBitMask) != 0  ||
                                    (contactedBody.contactTestBitMask & physicsBody.categoryBitMask) != 0  {
                                    if let catNode = contactedBody.node as? SKSpriteNode {
                                        catNode.texture = self.sleepyTexture
                                    }
                                    contactedBody.node?.run(turnGreen)
                                    self.catsRemaining -= 1
                                    contactedBody.categoryBitMask = PhysicsType.zombieCat
                                }
                            }
                        }
                    }
                    
                    let expandContractCloud = SKAction.sequence([expandCloud, zombifyContactedCat, contractCloud])
                    let animateCloud = SKAction.group([animate, expandContractCloud])
                    
                    let boom = SKAction.sequence([fuse, animateCloud, removeBeaker])
                    
                    // 3
                    let respawnBeakerDelay = SKAction.wait(forDuration: 0.1)
                    let respawnBeaker = SKAction.run() {
                        self.newProjectile()
                    }
                    let reload = SKAction.sequence([respawnBeakerDelay, respawnBeaker])
                    
                    // 4
                    cloud.run(boom) {
                        self.beakersLeft -= 1
                        self.run(reload)
                        self.updateLabels()
                        self.checkEndGame()
                    }
                }
            }
        }
    }
    
//    func updateMonsters() {
//        for monster in monsters {
//            let velocotyX = player?.position.x ?? 0 < monster.position.x ? -75 : 75
//            let newVelocity = CGVector(dx: velocotyX, dy: 0)
//            monster.physicsBody!.velocity = newVelocity;
//        }
//    }
    
    func updatePowerMeter(translation: CGPoint) {
        // 1
        let changeInPower = translation.x
        let changeInAngle = translation.y
        // 2
        let powerScale = 2.0
        let angleScale = -150.0
        // 3
        var power = Float(previousThrowPower) + Float(changeInPower) / Float(powerScale)
        var angle = Float(previousThrowAngle) + Float(changeInAngle) / Float(angleScale)
        // 4
        power = min(power, 100)
        power = max(power, 0)
        angle = min(angle, Float(M_PI_2))
        angle = max(angle, 0)
        // 5
        powerMeterFilledNode?.xScale = CGFloat(power/100.0)
        powerMeterNode?.zRotation = CGFloat(angle)
        // 6
        currentPower = Double(power)
        currentAngle = Double(angle)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        tossBeaker(strength: CGVector(dx: 1400, dy: 1150))
//    }
    func updateLabels() {
        if let beakerLabel = childNode(withName: "beakersLeftLabel") as? SKLabelNode {
            beakerLabel.text = "\(beakersLeft)"
        }
        
        if let catsLabel = childNode(withName: "catsRemainingLabel") as? SKLabelNode {
            catsLabel.text = "\(catsRemaining)"
        }
    }
    
    func checkEndGame() {
        if catsRemaining == 0 {
            print("you win")
            if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
                gameOverScene.scaleMode = scaleMode
                gameOverScene.won = true
                view?.presentScene(gameOverScene)
            }
            return
        }
        
        if beakersLeft == 0 {
            print("you lose")
            if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
                gameOverScene.scaleMode = scaleMode
                view?.presentScene(gameOverScene)
            }
        }
    }
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            self.panStartLocation = recognizer.location(in: self.view)
        }
        
        if recognizer.state == UIGestureRecognizerState.changed {
            // the position of the drag has moved
//            let translation = recognizer.translation(in: self.view)
//            print(translation)
//            updatePowerMeter(translation: translation)
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            let current = recognizer.location(in: self.view)
            let velocity = recognizer.velocity(in: self.view)
            
            var vectorX = current.x - self.panStartLocation.x
            var vectorY = current.y - self.panStartLocation.y
            let normal = max(fabs(vectorX), fabs(vectorY))
            vectorX = fabs(vectorX / normal)
            vectorY = fabs(vectorY / normal)

            let power = CGVector(dx: vectorX * velocity.x, dy: vectorY * -velocity.y)
            tossBeaker(strength: power)
        }
    }
    
    // Update
    
    override func update(_ currentTime: TimeInterval) {
        processUserMotion(forUpdate: currentTime)
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let player = childNode(withName: "player") as? SKSpriteNode {
            if let data = motionManager.accelerometerData {
                if data.acceleration.y < -0.2  {
                    print("LEFT: \(data.acceleration.y)")
                    player.physicsBody?.applyForce(CGVector(dx: -1500, dy: 0))
                } else if data.acceleration.y > 0.2 {
                    print("RIGHT: \(data.acceleration.y)")
                    player.physicsBody?.applyForce(CGVector(dx: 1500, dy: 0))
                } else {
                    player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsType.cat) {
            if let catNode = contact.bodyA.node as? SKSpriteNode {
                catNode.texture = scaredTexture
            }
        }
        
        if (contact.bodyB.categoryBitMask == PhysicsType.cat) {
            if let catNode = contact.bodyB.node as? SKSpriteNode {
                catNode.texture = scaredTexture
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsType.cat) {
            if let catNode = contact.bodyA.node as? SKSpriteNode {
                catNode.texture = sleepyTexture
            }
        }
        
        if (contact.bodyB.categoryBitMask == PhysicsType.cat) {
            if let catNode = contact.bodyB.node as? SKSpriteNode {
                catNode.texture = sleepyTexture
            }
        }
    }
}
