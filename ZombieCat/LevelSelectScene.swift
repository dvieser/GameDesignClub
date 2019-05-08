//
//  LevelSelectScene.swift
//  EmojiSplat
//
//  Created by David Vieser on 4/5/18.
//  Copyright © 2018 Hays CISD. All rights reserved.
//

import Foundation
import SpriteKit

class LevelSelectScene: SKScene {
    
    let keyname = "introPlayed"
    let closeButton = SKLabelNode(text: "X")
    var videoNode = SKVideoNode(url: URL(fileURLWithPath: Bundle.main.path(forResource: "1 How to Play Emoji Splat", ofType: "mp4")!))
    var isPlaying = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let level1Button: SKNode = childNode(withName: "Level1Button")!
        let level2Button: SKNode = childNode(withName: "Level2Button")!
        let level3Button: SKNode = childNode(withName: "Level3Button")!
        let level4Button: SKNode = childNode(withName: "Level4Button")!
        let level5Button: SKNode = childNode(withName: "Level5Button")!
        let level6Button: SKNode = childNode(withName: "Level6Button")!
        let aboutButton: SKNode = childNode(withName: "aboutButton")!
        let helpButton: SKNode = childNode(withName: "helpButton")!

        if (helpButton.contains(touch.location(in: self)) || UserDefaults.standard.bool(forKey: keyname) != true) {
            playIntroVideo()
            return
        }
        
        if closeButton.contains(touch.location(in: self)) {
            closeButton.removeFromParent()
            videoNode.removeFromParent()
            isPlaying = false
            return
        } else if videoNode.contains(touch.location(in: self)) && isPlaying {
            return
        }
        
        
        if level1Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level1") {
                myScene.levelDetail = LevelDetail(background: "", music: "background1", throwables: "food", time: 99, pinPoint: CGPoint.zero)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level2Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level2") {
                myScene.levelDetail = LevelDetail(background: "", music: "background2", throwables: "furniture", time: 70, pinPoint: CGPoint.zero)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level3Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level3") {
                myScene.levelDetail = LevelDetail(background: "", music: "background3", throwables: "furniture", time: 60, pinPoint: CGPoint.zero)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level4Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level4") {
                myScene.levelDetail = LevelDetail(background: "", music: "background4", throwables: "food", time: 60, pinPoint: CGPoint.zero)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level5Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level5") {
                myScene.levelDetail = LevelDetail(background: "", music: "background5", throwables: "food", time: 60, pinPoint: CGPoint.zero)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level6Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "Level6") {
                myScene.levelDetail = LevelDetail(background: "", music: "background6", throwables: "food", time: 60, pinPoint: CGPoint(x:1, y:0))
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if aboutButton.contains(touch.location(in: self)) {
            UIApplication.shared.open(URL(string: "https://www.hayscisd.net/Page/5419")!)
        }
    }
    
    func playIntroVideo() {
        videoNode = SKVideoNode(url: URL(fileURLWithPath: Bundle.main.path(forResource: "1 How to Play Emoji Splat", ofType: "mp4")!))

//            let videoNode = SKVideoNode(url: url)
        videoNode.position = CGPoint(x: 0, y: 0)
        videoNode.size = CGSize(width: self.size.height - 250, height: self.size.width - 180)
        videoNode.zPosition = 1
        //        let reload: SKSpriteNode = camera.childNode(withName: "reload") as! SKSpriteNode

        closeButton.fontSize = 36
        closeButton.fontColor = UIColor.black
        closeButton.position = CGPoint(x: -320, y:220)
        closeButton.zPosition = 5
        
        addChild(videoNode)
        videoNode.addChild(closeButton)

        UserDefaults.standard.set(true, forKey: keyname)
        isPlaying = true
        videoNode.play()

    }
}
