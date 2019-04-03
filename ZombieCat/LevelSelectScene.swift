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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let level1Button: SKNode = childNode(withName: "Level1Button")!
        let level2Button: SKNode = childNode(withName: "Level2Button")!
        let level3Button: SKNode = childNode(withName: "Level3Button")!
        let level4Button: SKNode = childNode(withName: "Level4Button")!
        let level5Button: SKNode = childNode(withName: "Level5Button")!
        let level6Button: SKNode = childNode(withName: "Level6Button")!

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
        }
    }
}
