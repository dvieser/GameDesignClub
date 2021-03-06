/**
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

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  var won = false
  
  override func didMove(to view: SKView) {
    if won {
      let winNode = SKSpriteNode(imageNamed: "You-Win")
      winNode.anchorPoint = CGPoint.zero
      addChild(winNode)
    } else {
      let loseNode = SKSpriteNode(imageNamed: "YouLose")
      loseNode.anchorPoint = CGPoint.zero
      addChild(loseNode)
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tapRecognizer)

    let wait = SKAction.wait(forDuration: 2.0)
    let block = SKAction.run {
      if let myScene = GameScene(fileNamed: "LevelSelectScene") {
        myScene.scaleMode = self.scaleMode
        self.view?.presentScene(myScene)
      }
    }
    //run(SKAction.sequence([wait, block]))
  }
    
    @objc func handleTap(recognizer:UIPanGestureRecognizer) {
        if let myScene = GameScene(fileNamed: "LevelSelectScene") {
            myScene.scaleMode = self.scaleMode
            self.view?.presentScene(myScene)
        }
    }

}
