//
//  GameOver.swift
//  myFirstGame
//
//  Created by Jordan Weaver on 7/28/15.
//  Copyright (c) 2015 Jordan Weaver. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(size: CGSize) {
        super.init(size: size);
        
        //Try Again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold");
        lblTryAgain.fontSize = 30;
        lblTryAgain.fontColor = SKColor.whiteColor();
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50);
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center;
        lblTryAgain.text = "Tap To Try Again";
        addChild(lblTryAgain);

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let reveal = SKTransition.fadeWithDuration(0.5);
        let gameScene = GameScene(size: self.size);
        self.view!.presentScene(gameScene, transition: reveal);
        
    }
}
