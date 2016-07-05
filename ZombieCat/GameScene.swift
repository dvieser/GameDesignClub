//
//  GameScene.swift
//  ZombieCat
//
//  Created by Brian Broom on 7/5/16.
//  Copyright (c) 2016 raywenderlich.com. All rights reserved.
//

import SpriteKit

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

  override func didMoveToView(view: SKView) {

  }
    
}
