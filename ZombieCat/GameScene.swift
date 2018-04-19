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

struct LevelDetail {
    let background: String
    let music: String
    let throwables: String
    let time: UInt
}

class GameScene: SKScene {
    
//    public convenience init(fileNamed: String, levelDetail: LevelDetail) {
//        super.init(fileNamed: fileNamed)!
//        self.levelDetail = levelDetail
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    var levelDetail: LevelDetail = LevelDetail(background: "", music: "", throwables: "", time: 0)
    
    let motionManager = CMMotionManager()
    
    var pinBeakerToZombieArm: SKPhysicsJointFixed?
    var beakerReady = false
    var explosionTextures = [SKTexture]()
    let hitTexture = SKTexture(imageNamed: "purple")
    var monsters: [SKSpriteNode] = []
    var player: SKSpriteNode?
    var arm: SKSpriteNode?
    var currentBeaker: SKSpriteNode?
    var playerStartX: CGFloat?
    
    var previousThrowPower = 100.0
    var previousThrowAngle = 0.0
    var currentPower = 100.0
    var currentAngle = 0.0
    
    var timeRemaining: UInt = 0
    var catsRemaining = 0
    
    var throwables : [String] = []
    
    private var panStartLocation:CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        timeRemaining = levelDetail.time
        
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("\(levelDetail.throwables).bundle")
        let contents = try! fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
        throwables = contents.map { $0.lastPathComponent }

        constrainCamera()
        motionManager.startAccelerometerUpdates()
        
        let backgroundMusic = SKAudioNode(fileNamed: levelDetail.music)
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        
        for child in self.children {
            if child.name == "monster" {
                if let child = child as? SKSpriteNode {
                    monsters.append(child)
                    child.physicsBody?.allowsRotation = true
//                    child.physicsBody?.mass = 100.0
                }
            }
        }
        
        catsRemaining = monsters.count
        self.updateLabels()

//        let reloadTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleReload))
//        view.addGestureRecognizer(reloadTapRecognizer)

        
        player = childNode(withName: "player") as? SKSpriteNode
//        player?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 400))
        player?.physicsBody?.isDynamic = true
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.mass = 1.0
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        playerStartX = player?.position.x
        
        physicsWorld.add(SKPhysicsJointSliding.joint(withBodyA: self.physicsBody!, bodyB: (player?.physicsBody)!, anchor: CGPoint.zero, axis: CGVector.init(dx: 1, dy: 0)))
        
        arm = player?.childNode(withName: "arm") as? SKSpriteNode
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -50)
                
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panRecognizer)
        
        newProjectile()
        for i in 0...8 {
            explosionTextures.append(SKTexture(imageNamed: "regularExplosion0\(i)"))
        }
        updateClock()

    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
//        updateMonsters()
        
        camera?.position = CGPoint(x: max((player?.position.x)!,-2400.0), y: 0.0)
        if let playerStartX = playerStartX, let playerPositionX = player?.position.x {
            if playerPositionX < playerStartX {
                player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player?.position.x = playerStartX
            }
        }
    }

    func newProjectile () {
        let randomIndex = Int(arc4random_uniform(UInt32(throwables.count)))
        let image = throwables[randomIndex]
        let beaker = SKSpriteNode(imageNamed: "\(levelDetail.throwables).bundle/\(image)")
        beaker.size = CGSize(width: 80, height: 80)
        
        beaker.name = "beaker"
        beaker.zPosition = 5
        let beakerBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        beaker.zRotation = arm?.zRotation ?? 0.0
        beaker.position = (self.player?.convert(CGPoint(x: (self.arm?.position.x ?? 0.0) - 120.0, y: (self.arm?.position.y ?? 0) + 160.0), to: self.scene!)) ?? CGPoint.zero  //CGPoint(x: 0.0, y: 200)
        beakerBody.mass = 0.0
        beakerBody.affectedByGravity = true
        beakerBody.mass = 1.0
        beakerBody.categoryBitMask = PhysicsType.beaker
        beakerBody.collisionBitMask = PhysicsType.wall | PhysicsType.cat | PhysicsType.zombieCat

        beaker.physicsBody = beakerBody
        addChild(beaker)
        
        //TODO: Add Beaker to Player Movement
        if let armBody = arm?.physicsBody {
            pinBeakerToZombieArm = SKPhysicsJointFixed.joint(withBodyA: armBody, bodyB: beakerBody, anchor: CGPoint.zero)
            physicsWorld.add(pinBeakerToZombieArm!)
            currentBeaker = beaker
        }
        
        let cloud = SKSpriteNode(imageNamed: "regularExplosion00")
        cloud.name = "cloud"
//        cloud.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.0, height: 0.0))
//        cloud.physicsBody?.collisionBitMask = PhysicsType.none
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
        if let beaker = currentBeaker {

            if let arm = arm {
                let toss = SKAction.run() {
                    self.physicsWorld.remove(self.pinBeakerToZombieArm!)
                    if let beakerBody = beaker.physicsBody {
                        beakerBody.applyImpulse(strength)
                        beakerBody.applyAngularImpulse(0.1125)
                    }
                    self.currentBeaker = nil
                }
                
                let release = SKAction.run() {
                    if let beakerBody = beaker.physicsBody {
                        beakerBody.affectedByGravity = true
                        beakerBody.mass = 0.3
                    }
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

                let sfx = SKAction.playSoundFileNamed("yee.mp3", waitForCompletion: false)
                
                let zombifyContactedCat = SKAction.run() {
                    if let physicsBody = explosionRadius.physicsBody {
                        for contactedBody in physicsBody.allContactedBodies() {
                            if (physicsBody.contactTestBitMask & contactedBody.categoryBitMask) != 0  ||
                                (contactedBody.contactTestBitMask & physicsBody.categoryBitMask) != 0  {
                                if let catNode = contactedBody.node as? SKSpriteNode {
                                    catNode.texture = self.hitTexture
                                }
                                contactedBody.node?.run(turnGreen)
                                self.catsRemaining -= 1
                                self.updateLabels()
                                contactedBody.categoryBitMask = PhysicsType.zombieCat
                                
                                self.run(sfx)
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
//                    self.beakersLeft -= 1
                    self.run(reload)
                    self.updateLabels()
                    self.checkEndGame()
                }
            }
        }
    }
    
    func constrainCamera() {
        // get the scene size as scaled by `scaleMode = .AspectFill`
        let cameraNode = childNode(withName: "cameraNode")!
        let scaledSize = CGSize(width: size.width * cameraNode.xScale, height: size.height * cameraNode.yScale)
        
        // get the frame of the entire level contents
        let boardNode = childNode(withName: levelDetail.background)!
        let boardContentRect = boardNode.calculateAccumulatedFrame()
        
        // inset that frame from the edges of the level
        // inset by `scaledSize / 2 - 100` to show 100 pt of black around the level
        // (no need for `- 100` if you want zero padding)
        // use min() to make sure we don't inset too far if the level is small
        let xInset = min((scaledSize.width / 2) - 650, boardContentRect.width / 2)
        let yInset = min((scaledSize.height / 2) - 650, boardContentRect.height / 2)
        let insetContentRect = boardContentRect.insetBy(dx: xInset, dy: yInset)
        
        // use the corners of the inset as the X and Y range of a position constraint
        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        levelEdgeConstraint.referenceNode = boardNode
        camera?.constraints = [levelEdgeConstraint]
    }
    
    func updateClock() {
        var leadingZero = ""
//        var leadingZeroMin = ""
//        var timeMin = Int()
        let actionwait = SKAction.wait(forDuration: 1.0)
        var timesecond = 50
        if let clockText: SKLabelNode = childNode(withName: "cameraNode")?.childNode(withName: "timeRemainingLabel") as? SKLabelNode {
            let actionrun = SKAction.run() {
                timesecond = timesecond - 1
                if timesecond == 0 {
                    self.lose()
                }
                //            if timesecond == 60 {timesecond = 0}
                //            if timeMin  / 60 <= 9 { leadingZeroMin = "0" } else { leadingZeroMin = "" }
                if timesecond <= 9 { leadingZero = "0" } else { leadingZero = "" }
                
                clockText.text = "\(leadingZero)\(timesecond)"
            }
            run(SKAction.repeatForever(SKAction.sequence([actionwait,actionrun])))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let camera: SKCameraNode = childNode(withName: "cameraNode") as! SKCameraNode

        if camera.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "LevelSelectScene") {
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        }
    }
    
//    func handleReload(recognizer:UIPanGestureRecognizer) {
//        
//        let camera: SKCameraNode = childNode(withName: "cameraNode") as! SKCameraNode
//        let reload: SKSpriteNode = camera.childNode(withName: "reload") as! SKSpriteNode
//
//        let touchLocation = recognizer.location(in: self.view)
//
//        let cameraTouchLocation = scene!.convert(touchLocation, to: camera)
//        
//        let touchedNode = childNode(withName: "cameraNode")!.atPoint(cameraTouchLocation)
//
//        if touchedNode is SKSpriteNode {
//            if touchedNode.isEqual(to: reload) {
//                if let myScene = GameScene(fileNamed: "GameScene") {
//                    myScene.scaleMode = self.scaleMode
//                    self.view?.presentScene(myScene)
//                }
//            }
//        }
//        
//    }
    
//    func updateMonsters() {
//        for monster in monsters {
//            let velocotyX = player?.position.x ?? 0 < monster.position.x ? -75 : 75
//            let newVelocity = CGVector(dx: velocotyX, dy: 0)
//            monster.physicsBody!.velocity = newVelocity;
//        }
//    }
    
//    func updatePowerMeter(translation: CGPoint) {
//        // 1
//        let changeInPower = translation.x
//        let changeInAngle = translation.y
//        // 2
//        let powerScale = 2.0
//        let angleScale = -150.0
//        // 3
//        var power = Float(previousThrowPower) + Float(changeInPower) / Float(powerScale)
//        var angle = Float(previousThrowAngle) + Float(changeInAngle) / Float(angleScale)
//        // 4
//        power = min(power, 100)
//        power = max(power, 0)
//        angle = min(angle, Float(M_PI_2))
//        angle = max(angle, 0)
//        // 5
//        powerMeterFilledNode?.xScale = CGFloat(power/100.0)
//        powerMeterNode?.zRotation = CGFloat(angle)
//        // 6
//        currentPower = Double(power)
//        currentAngle = Double(angle)
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        tossBeaker(strength: CGVector(dx: 1400, dy: 1150))
//    }
    func updateLabels() {
//        if let beakerLabel = childNode(withName: "beakersLeftLabel") as? SKLabelNode {
//            beakerLabel.text = "\(beakersLeft)"
//        }
        if let catsLabel = childNode(withName: "cameraNode")?.childNode(withName: "catsRemainingLabel") as? SKLabelNode {
            catsLabel.text = "\(catsRemaining)"
        }
    }
    
    func lose() {
        print("you lose")
        removeAllActions()
        if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
            gameOverScene.scaleMode = scaleMode
            view?.presentScene(gameOverScene)
        }
    }
    
    func win() {
        print("you win")
        removeAllActions()
        if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
            gameOverScene.scaleMode = scaleMode
            gameOverScene.won = true
            view?.presentScene(gameOverScene)
        }
        
    }
    
    func checkEndGame() {
        if catsRemaining == 0 {
            win()
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
//                    print("LEFT: \(data.acceleration.y)")
                    player.physicsBody?.applyForce(CGVector(dx: -1500, dy: 0))
                } else if data.acceleration.y > 0.2 {
//                    print("RIGHT: \(data.acceleration.y)")
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
    
//    func didBegin(_ contact: SKPhysicsContact) {
//        if (contact.bodyA.categoryBitMask == PhysicsType.cat) {
//            if let catNode = contact.bodyA.node as? SKSpriteNode {
//                catNode.texture = hitTexture
//            }
//        }
//        
//        if (contact.bodyB.categoryBitMask == PhysicsType.cat) {
//            if let catNode = contact.bodyB.node as? SKSpriteNode {
//                catNode.texture = hitTexture
//            }
//        }
//    }
    
//    func didEnd(_ contact: SKPhysicsContact) {
//        if (contact.bodyA.categoryBitMask == PhysicsType.cat) {
//            if let catNode = contact.bodyA.node as? SKSpriteNode {
//                catNode.texture = sleepyTexture
//            }
//        }
//        
//        if (contact.bodyB.categoryBitMask == PhysicsType.cat) {
//            if let catNode = contact.bodyB.node as? SKSpriteNode {
//                catNode.texture = sleepyTexture
//            }
//        }
//    }
}
