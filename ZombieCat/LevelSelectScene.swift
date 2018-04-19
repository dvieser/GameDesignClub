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

        if level1Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "GameScene") {
                myScene.levelDetail = LevelDetail(background: "background", music: "background", throwables: "throwables", time: 50)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        } else if level2Button.contains(touch.location(in: self)) {
            if let myScene = GameScene(fileNamed: "GameScene2") {
                myScene.levelDetail = LevelDetail(background: "background", music: "background", throwables: "throwables", time: 50)
                myScene.scaleMode = self.scaleMode
                self.view?.presentScene(myScene)
            }
        }
    }
}
