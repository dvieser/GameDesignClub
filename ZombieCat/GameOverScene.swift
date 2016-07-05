//
//  GameOverScene.swift
//  MonsterIslandClone
//
//  Created by Brian Broom on 6/20/16.
//  Copyright © 2016 Brian Broom. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  var won = false
  
  override func didMoveToView(view: SKView) {
    if let messageLabel = childNodeWithName("message") as? SKLabelNode {
      if won {
        messageLabel.text = "You Win!"
      } else {
        messageLabel.text = "You Lose!"
      }
      
      let wait = SKAction.waitForDuration(2.0)
      let block = SKAction.runBlock {
        if let myScene = GameScene(fileNamed: "GameScene") {
          myScene.scaleMode = self.scaleMode
          self.view?.presentScene(myScene)
        }
      }
      runAction(SKAction.sequence([wait, block]))
    }
  }
}