//
//  ObjectNode.swift
//  myFirstGame
//
//  Created by Jordan Weaver on 7/29/15.
//  Copyright (c) 2015 Jordan Weaver. All rights reserved.
//

import SpriteKit

var contactHappening = false;

var jump = 0;

var finsished = false;

var levels = 1;

//Collision Category
struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00;
    static let Fuzz: UInt32 = 0x01;
    static let Landing: UInt32 = 0x02;
    static let Finish: UInt32 = 0x03;
}

//enum
enum Color: String {
    case Red = "red"
    case Blue = "blue"
    case Green = "green"
    case Yellow = "yellow"
    case Violet = "violet"
    case Grey = "neutral"
    
}

class ObjectNode: SKNode {
    
    func collisionWithPlayer(player: PlayerNode) -> Bool {
        return false;
    }
    
}

class FuzzNode: ObjectNode {
    var fuzzColor: Color!
    
    override func collisionWithPlayer(player: PlayerNode) -> Bool {
        
        let fuzzSound = SKAction.playSoundFileNamed("fuz.wav", waitForCompletion: false);
        
        runAction(fuzzSound);
        
        if fuzzColor == .Red {
            
            player.texture = SKTexture(imageNamed: "red_ball_07");
            player.ballColor = Color.Red;
            
        } else if fuzzColor == .Blue {
            
            player.ballColor = Color.Blue;
            player.texture = SKTexture(imageNamed: "ball_ball_12");
            
        } else if fuzzColor == .Green {
            
            player.ballColor = Color.Green;
            println("Line 55: Turned .Green");
            player.texture = SKTexture(imageNamed: "green_ball_18");
            return false;
            
        } else if fuzzColor == .Yellow {
            
            player.texture = SKTexture(imageNamed: "yellow_ball_04");
            player.ballColor = Color.Yellow;
            
        } else if fuzzColor == .Violet {
            
            player.texture = SKTexture(imageNamed: "purple_ball_17");
            player.ballColor = Color.Violet;
            
        }
        
        return false;
    }
}

class LandingNode: ObjectNode {
    var landingColor: Color!
    
    override func collisionWithPlayer(player: PlayerNode) -> Bool {
    
        if let landColor = landingColor {
            contactHappening = true;
            
            if landColor == .Red && player.ballColor != .Red {
                return true;
            } else if landColor == .Blue && player.ballColor != .Blue {
                return true;
            } else if landColor == .Green && player.ballColor != .Green {
                println("Line 86: Touched .Green Name: \(player.ballColor.rawValue)");
                return true;
            } else if landColor == .Yellow && player.ballColor != .Yellow {
                return true;
            } else if landColor == .Violet && player.ballColor != .Violet {
                return true;
            } else {
                jump = 0;	
                return false;
            }
        }
        
        jump = 0;
        
        return false;
    }
}



class FinishNode: ObjectNode {
    var thePosition: CGPoint!
    
    override func collisionWithPlayer(player: PlayerNode) -> Bool {
        
        let endSound = SKAction.playSoundFileNamed("start.wav", waitForCompletion: false);
        runAction(endSound);
        //Transition to next level
        
        //Spin ball or something
        player.physicsBody?.applyForce(CGVector(dx: 0.0, dy: 20));
        player.position = thePosition;
        player.physicsBody?.pinned = true;
        
        finsished = true;
        
        if levels == 1 {
            levels++
        } else if levels == 2 {
            levels--
        }
        
        
        
        return true;
    }
    
}

class PlayerNode: SKSpriteNode {
    var ballColor: Color!
}