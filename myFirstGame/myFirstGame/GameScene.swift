//
//  GameScene.swift
//  myFirstGame
//
//  Created by Jordan Weaver on 7/14/15.
//  Copyright (c) 2015 Jordan Weaver. All rights reserved.
//



//Notes to work on
    /*Things that need to be worked on



HUD - Only timer....  FINISHED
        
        Fuzz balls still collide. Need them to disapper without affecting the player - FINSIHED

        Change sizes of blocks - EASY

        Optimize pinning feature to happen only when contact is happening


        Optimize Jumping - Just delete old jumping function


        SAVING HIGHSCORE - Almost

        Level transition. - NEED GRAPHICS

        Death/reset level - ALMOST DONE




    */


// use childNode to check if ball is touching any landings to use pinned function

import SpriteKit
import CoreMotion

var motionManager = CMMotionManager()
var destX:CGFloat  = 0.0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //Layered Nodes
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    var scaleFactor: CGFloat!
    
    var ballNode:PlayerNode!
    
    let motionManager: CMMotionManager = CMMotionManager();
    
    var contentCreated = false;
    
    let kBallSize = CGSize(width: 24, height: 16);
    let kBallName = "ball";
    
    var gameOver = false;
    
    //HUD
    var labelTime: SKLabelNode!
    
    var time: NSTimer!
    var counter = 0;
    
    
    //May need this if I don't want them to fall off the screen. This may have been causing the Screen movement glitch
    
    let kContactCategory: UInt32 = 0x1 << 11;
    
    
    
    //makeObjects
    
    func makeBall(colorOfBall: String, BallColor ballColor: Color) -> PlayerNode{
        let ball = PlayerNode(imageNamed: colorOfBall);
        
        ball.ballColor = ballColor;
            
        ball.texture = SKTexture(imageNamed: colorOfBall);
            
        ball.name = kBallName;
        
        ball.size = CGSize(width: ball.frame.size.width / 4, height: ball.frame.size.height / 4);
        
        println(ball.size)
        
        ball.zPosition = 0;
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.height / 2);
        ball.physicsBody?.usesPreciseCollisionDetection = true;
        ball.physicsBody?.dynamic = true;
        ball.physicsBody?.affectedByGravity = true;
        ball.physicsBody?.mass = 0.05;
        
        ball.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player;
        ball.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Landing;
        ball.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Fuzz | CollisionCategoryBitmask.Landing | CollisionCategoryBitmask.Finish;
        
        return ball;
    }
    
    
    //Create Content
    
    func createContent(){
        
        func setupBackground(){
            let background = SKSpriteNode(imageNamed: "newbackground_01");
            
            background.size = CGSize(width: size.width, height: size.height);
            background.anchorPoint = CGPoint(x: 0, y: 0);
            background.zPosition = -1;
            
            addChild(background);
        }
        
        gameOver = false;
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame);
        physicsBody!.categoryBitMask = kContactCategory;
        
        scaleFactor = self.size.width / 320.0;
        
        backgroundNode = createBackgroundNode();
        addChild(backgroundNode);
        
        //HUD
        hudNode = SKNode();
        addChild(hudNode);
        
        foregroundNode = SKNode();
        addChild(foregroundNode);
        
        //Timer
        
        time = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true);
        
        let startSound = SKAction.playSoundFileNamed("starting.wav", waitForCompletion: false);

        runAction(startSound);
        
        //Create HUD
        //Score
        labelTime = SKLabelNode(fontNamed: "ChalkboardSE-Bold");
        labelTime.fontSize = 30;
        labelTime.fontColor = SKColor.redColor();
        labelTime.position = CGPoint(x: self.size.width - 30, y: self.size.height - 35);
        labelTime.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right;
        
        labelTime.text = String(counter);
        hudNode.addChild(labelTime);
        
        if levels == 1 {
            levelOneSetup();
        } else if levels == 2 {
            levelTwo();
        }
    }
    
    override func didMoveToView(view: SKView) {
        
        if(!self.contentCreated){
            self.createContent();
            self.contentCreated = true;
            motionManager.startAccelerometerUpdates();
            userInteractionEnabled = true;
            physicsWorld.contactDelegate = self;
        }
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -4.9);
        
        motionManager.startAccelerometerUpdates();
        
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "processTapContacts:");
        
        self.view!.addGestureRecognizer(tapGesture);
        
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:");
        
        gesture.minimumPressDuration = 0.15;
        
        self.view!.addGestureRecognizer(gesture);
        
        
        
    }
    
    
    //Create Background
    func createBackgroundNode() -> SKNode {
        
        let backgroundNode = SKNode();
        let ySpacing = 64.0 * scaleFactor;
        
        for index in 0...2 {
            
            let node = SKSpriteNode(imageNamed: String(format: "newbackground_%02d", index + 1));
            
            node.setScale(scaleFactor);
            node.anchorPoint = CGPoint(x: 0.0, y: 0.0);
            node.size = CGSize(width: size.width, height: size.height);
            
            //Use this to set tile backgrounds for movement!!
            
            if index == 1 {
                node.position = CGPoint(x: 0.0, y: frame.size.height);
            } else if index == 2 {
                node.position = CGPoint(x: 0.0, y: -frame.size.height);
            }
            
            backgroundNode.addChild(node);
            
        }
        
        return backgroundNode;
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        if gameOver {
            return
        }
        
        processUserMotions(currentTime);
        
        
        //Moves the map. Glitchy, but not 100% sure why.
        if let player = ballNode {
            
            if player.position.y > 270 {
                backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0) / 10));
                foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0));
            } else if player.position.y < 220 {
                backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0) / 10));
                foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0));
            }
            
            
        }
        
        //Death to player
        if Int(ballNode!.position.y) < 80 - 800 {
            endGame();
        }
    }
    
    
    
    // Update functions
    
    func processUserMotions(currentTime: CFTimeInterval){
        if let ball = foregroundNode.childNodeWithName(kBallName) as! SKSpriteNode!{
            
            if let data = motionManager.accelerometerData {
                //Use this to determine when the ball should begin momevment.
                if(fabs(data.acceleration.y)>0.2){
                    
                    ballNode.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.y), 0));
                    
                }
            }
        }
    }
    
    //Taps
    func processTapContacts(tapPress: UITapGestureRecognizer){
        
        if(jump <= 2){
            contactHappening = false;
            let jumpSound = SKAction.playSoundFileNamed("jumping.wav", waitForCompletion: false);
                
            if let data = motionManager.accelerometerData {
                    
                    
                    //Fix this so that the ball stays fluid when jumping
                runAction(jumpSound){
                    self.ballNode.physicsBody?.velocity = CGVectorMake(60.0 * CGFloat(data.acceleration.y), 0);
                    self.ballNode.physicsBody?.applyForce(CGVectorMake(0, 1000));
                }
            }
        }
    }
    
    
    //Time
    func updateCounter() {
        if let label = labelTime {
            label.text = String(counter++)
        }
    }
    
    // User Taps
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        jump++;
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
       
    }
    
    
    //Process Gesture taps
    
    //Long press function
    func longPressed(longPress: UIGestureRecognizer) {
        
        if (longPress.state == UIGestureRecognizerState.Ended) {
            motionManager.startAccelerometerUpdates();
            ballNode.physicsBody!.pinned = false;
            println("Ended")
            
        }else if (longPress.state == UIGestureRecognizerState.Began) {
            
            if contactHappening {
                
//                SET PINNING CONTRAINT
                
                if ballNode.physicsBody?.velocity.dy > -1 {
                    motionManager.stopAccelerometerUpdates();
                    ballNode.physicsBody?.pinned = true;
                }
            }
            
            println("Began")
            
        }
        
    }
    
    
    
    //Physics Contact
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var runAndCheck = false;
        
        let whichNode = (contact.bodyA.node != ballNode) ? contact.bodyA.node : contact.bodyB.node;
        println(whichNode);
        
        let other = whichNode as! ObjectNode;
        
        runAndCheck = other.collisionWithPlayer(ballNode);
        
        if runAndCheck {
                let reveal = SKTransition.fadeWithDuration(0.5);
                let gameScene = GameScene(size: self.size);
                self.view!.presentScene(gameScene, transition: reveal);
            
        }
        
    }
    
    
    func endGame() {
        gameOver = true;
        
        GameState.sharedInstance.saveState();
        
        let reveal = SKTransition.fadeWithDuration(0.5);
        let endGameScene = GameOver(size: self.size);
        self.view!.presentScene(endGameScene, transition: reveal);
    }
    
    
    
    
    
    
    
    //Level One. Move to other class. Optimize by creating pList;
    
    func levelOneSetup(){
        
        ballNode = makeBall("red_ball_07", BallColor: Color.Red);
        
        ballNode!.position = CGPoint(x: sqrt(frame.size.width), y: frame.size.width * 0.6);
        
        
        let startingBlockX: CGFloat = sqrt(frame.size.height);
        let startingBlockY: CGFloat = frame.size.width;
        
        
        //Start block
        let startNode = LandingNode();
        startNode.position = CGPoint(x: startingBlockX, y: startingBlockY * 0.5);
        startNode.name = "GREY_LANDING";
        
        let startBlock = SKSpriteNode(imageNamed: "startblock_02");
        startBlock.size = CGSize(width: startBlock.frame.size.width / 1.5, height: startBlock.frame.size.height / 1.5);
        
        startNode.addChild(startBlock);
        
        startNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: startBlock.frame.width / 2, height: startBlock.frame.height / 2));
        startNode.physicsBody!.dynamic = false;
        
        startNode.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        startNode.physicsBody!.collisionBitMask = 0;
        
        
        //Red block
        let redLanding = LandingNode();
        redLanding.position = CGPoint(x: startingBlockX * 8, y: startingBlockY * 0.4);
        redLanding.name = "LANDING_NODE";
        
        redLanding.landingColor = Color.Red;
        
        let redBlock = SKSpriteNode(imageNamed: "redblock_09");
        redBlock.size = CGSize(width: redBlock.frame.size.width / 1.5, height: redBlock.frame.size.height / 1.5);
        
        redLanding.addChild(redBlock);
        
        redLanding.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: redBlock.frame.size.width, height: redBlock.frame.size.height - 2));
        redLanding.physicsBody!.dynamic = false;
        
        redLanding.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        redLanding.physicsBody!.collisionBitMask = 0;
    
        
        
        //Blue Block
        let blueLanding = LandingNode();
        blueLanding.position = CGPoint(x: startingBlockX * 17, y: startingBlockY * 0.3);
        blueLanding.name = "LANDING_NODE";
        
        blueLanding.landingColor = Color.Blue;
        
        let blueBlock = SKSpriteNode(imageNamed: "blue_block_14");
        blueBlock.size = CGSize(width: blueBlock.frame.size.width / 1.5, height: blueBlock.frame.size.height / 2);
        
        blueLanding.addChild(blueBlock);
        
        blueLanding.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: blueBlock.frame.size.width, height: blueBlock.frame.size.height - 10));
        
        blueLanding.physicsBody!.dynamic = false;
        
        blueLanding.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        blueLanding.physicsBody!.collisionBitMask = 0;
        
        //BlueFuzz
        let blueFuzzNode = FuzzNode();
        blueFuzzNode.position = CGPoint(x: startingBlockX * 15, y: startingBlockY * 0.55);
        blueFuzzNode.name = "FUZZ_NODE";
        
        blueFuzzNode.fuzzColor = Color.Blue;
        
        let blueFuzz = SKSpriteNode(imageNamed: "blue_fuzzball_05");
        blueFuzz.size = CGSize(width: blueFuzz.frame.size.width / 1.5, height: blueFuzz.frame.size.height / 1.5);
        
        blueFuzzNode.addChild(blueFuzz);
        
        blueFuzzNode.physicsBody = SKPhysicsBody(circleOfRadius: blueFuzz.size.width / 2);
        
        blueFuzzNode.physicsBody?.dynamic = false;
        
        blueFuzzNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Fuzz;
        blueFuzzNode.physicsBody?.collisionBitMask = 0;
        
        
        
        
        
        //127.25 pt
        
        //Green Block
        let greenLanding = LandingNode();
        greenLanding.position = CGPoint(x: startingBlockX * 20, y: startingBlockY * 0.2);
        greenLanding.name = "LANDING_NODE";
        
        greenLanding.landingColor = Color.Green;
        
        let greenBlock = SKSpriteNode(imageNamed: "greenblock_22");
        greenBlock.size = CGSize(width: greenBlock.frame.size.width / 2, height: greenBlock.frame.size.height / 2);
        
        greenLanding.addChild(greenBlock);
        
        greenLanding.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: greenBlock.frame.size.width, height: greenBlock.frame.size.height - 2));
        greenLanding.physicsBody!.dynamic = false;
        
        greenLanding.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        greenLanding.physicsBody!.collisionBitMask = 0;
        
        
        //Green Fuzz
        let greenFuzzNode = FuzzNode();
        greenFuzzNode.position = CGPoint(x: startingBlockX * 18, y: startingBlockY * 0.27);
        greenFuzzNode.name = "FUZZ_NODE";
        
        greenFuzzNode.fuzzColor = Color.Green;
        
        let greenFuzz = SKSpriteNode(imageNamed: "green_fuzzball_17");
        greenFuzz.size = CGSize(width: greenFuzz.frame.size.width / 2, height: greenFuzz.frame.size.height / 2);
        
        greenFuzzNode.addChild(greenFuzz);
        
        greenFuzzNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: greenFuzz.frame.size.width, height: greenFuzz.frame.size.height));
        
        greenFuzzNode.physicsBody?.dynamic = false;
        
        greenFuzzNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Fuzz;
        greenFuzzNode.physicsBody?.collisionBitMask = 0;
        
        
        //Finish Line
        let finishNode = FinishNode();
        finishNode.position = CGPoint(x: startingBlockX * 24, y: startingBlockY * 0.1);
        finishNode.name = "FINISH_NODE";
        
        let finish = SKSpriteNode(imageNamed: "finish_21");
        finish.size = CGSize(width: finish.frame.size.width / 4 + 4, height: finish.frame.size.height / 4 + 4);
        
        finishNode.addChild(finish);
        
        finishNode.thePosition = finishNode.position;
        
        finishNode.physicsBody = SKPhysicsBody(circleOfRadius: finish.size.width / 2);
        
        finishNode.physicsBody?.dynamic = false;
        
        finishNode.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Finish;
        finishNode.physicsBody!.collisionBitMask = 0;
        
        
        
        foregroundNode.addChild(startNode);
        foregroundNode.addChild(redLanding);
        foregroundNode.addChild(blueLanding);
        foregroundNode.addChild(blueFuzzNode);
        foregroundNode.addChild(greenLanding);
        foregroundNode.addChild(greenFuzzNode);
        foregroundNode.addChild(finishNode);
        foregroundNode.addChild(ballNode!);
    }
    
    
    
    func levelTwo(){
        
        let startingBlockX: CGFloat = sqrt(frame.size.height);
        let startingBlockY: CGFloat = frame.size.width;
        
        ballNode = makeBall("red_ball_07", BallColor: Color.Red);
        
        ballNode!.position = CGPoint(x: startingBlockX * 6, y: startingBlockY * 0.5);
        
        //Start block
        let startNode = LandingNode();
        startNode.position = CGPoint(x: startingBlockX * 6, y: startingBlockY * 0.4);
        startNode.name = "GREY_LANDING";
        
        let startBlock = SKSpriteNode(imageNamed: "startblock_02");
        startBlock.size = CGSize(width: startBlock.frame.size.width / 2, height: startBlock.frame.size.height / 2);
        
        startNode.addChild(startBlock);
        
        startNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: startBlock.frame.width / 2, height: startBlock.frame.height / 2));
        startNode.physicsBody!.dynamic = false;
        
        startNode.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        startNode.physicsBody!.collisionBitMask = 0;
        
        
        //BlueFuzz
        let blueFuzzNode = FuzzNode();
        blueFuzzNode.position = CGPoint(x: startingBlockX * 8.5, y: startingBlockY * 0.38);
        blueFuzzNode.name = "FUZZ_NODE";
        
        blueFuzzNode.fuzzColor = Color.Blue;
        
        let blueFuzz = SKSpriteNode(imageNamed: "blue_fuzzball_05");
        blueFuzz.size = CGSize(width: blueFuzz.frame.size.width / 2, height: blueFuzz.frame.size.height / 2);
        
        blueFuzzNode.addChild(blueFuzz);
        
        blueFuzzNode.physicsBody = SKPhysicsBody(circleOfRadius: blueFuzz.size.width / 2);
        
        blueFuzzNode.physicsBody?.dynamic = false;
        
        blueFuzzNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Fuzz;
        blueFuzzNode.physicsBody?.collisionBitMask = 0;
        
        
        
        //Blue Block
        let blueLanding = LandingNode();
        blueLanding.position = CGPoint(x: startingBlockX * 11.5, y: startingBlockY * 0.3);
        blueLanding.name = "LANDING_NODE";
        
        blueLanding.landingColor = Color.Blue;
        
        let blueBlock = SKSpriteNode(imageNamed: "blue_block_14");
        blueBlock.size = CGSize(width: blueBlock.frame.size.width / 2, height: blueBlock.frame.size.height / 2);
        
        blueLanding.addChild(blueBlock);
        
        blueLanding.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: blueBlock.frame.size.width - 10, height: blueBlock.frame.size.height - 10));
        
        blueLanding.physicsBody!.dynamic = false;
        
        blueLanding.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        blueLanding.physicsBody!.collisionBitMask = 0;
        
        
        //Solids
        let solidNode = LandingNode();
        solidNode.position = CGPoint(x: startingBlockX * 15, y: startingBlockY * 0.375);
        solidNode.name = "GREY_LANDING";
        
        let solidBlock = SKSpriteNode(imageNamed: "startblock_02");
        solidBlock.size = CGSize(width: startBlock.frame.size.width / 3, height: startBlock.frame.size.height * 10);
        
        solidNode.addChild(solidBlock);
        
        solidNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: solidBlock.frame.width / 2, height: solidBlock.frame.height / 2));
        solidNode.physicsBody!.dynamic = false;
        
        solidNode.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        solidNode.physicsBody!.collisionBitMask = 0;
        
        
        //Solids
        let solidNode2 = LandingNode();
        solidNode2.position = CGPoint(x: startingBlockX * 15.5, y: startingBlockY * 0.53);
        solidNode2.name = "GREY_LANDING";
        
        let solidBlock2 = SKSpriteNode(imageNamed: "startblock_02");
        solidBlock2.size = CGSize(width: startBlock.frame.size.width * 3, height: startBlock.frame.size.height);
        
        solidNode2.addChild(solidBlock2);
        
        solidNode2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: solidBlock2.frame.width / 2, height: solidBlock2.frame.height / 2));
        solidNode2.physicsBody!.dynamic = false;
        
        solidNode2.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        solidNode2.physicsBody!.collisionBitMask = 0;
        
        
        //Green Fuzz
        let greenFuzzNode = FuzzNode();
        greenFuzzNode.position = CGPoint(x: startingBlockX * 16, y: startingBlockY * 0.45);
        greenFuzzNode.name = "FUZZ_NODE";
        
        greenFuzzNode.fuzzColor = Color.Green;
        
        let greenFuzz = SKSpriteNode(imageNamed: "green_fuzzball_17");
        greenFuzz.size = CGSize(width: greenFuzz.frame.size.width / 2, height: greenFuzz.frame.size.height / 2);
        
        greenFuzzNode.addChild(greenFuzz);
        
        greenFuzzNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: greenFuzz.frame.size.width, height: greenFuzz.frame.size.height));
        
        greenFuzzNode.physicsBody?.dynamic = false;
        
        greenFuzzNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Fuzz;
        greenFuzzNode.physicsBody?.collisionBitMask = 0;
        
        
        //Green Block
        let greenLanding = LandingNode();
        greenLanding.position = CGPoint(x: startingBlockX * 21, y: startingBlockY * 0.2);
        greenLanding.name = "LANDING_NODE";
        
        greenLanding.landingColor = Color.Green;
        
        let greenBlock = SKSpriteNode(imageNamed: "greenblock_22");
        greenBlock.size = CGSize(width: greenBlock.frame.size.width / 2, height: greenBlock.frame.size.height / 2);
        
        greenLanding.addChild(greenBlock);
        
        greenLanding.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: greenBlock.frame.size.width, height: greenBlock.frame.size.height - 2));
        greenLanding.physicsBody!.dynamic = false;
        
        greenLanding.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Landing;
        greenLanding.physicsBody!.collisionBitMask = 0;
        
        
        //Finish Line
        let finishNode = FinishNode();
        finishNode.position = CGPoint(x: startingBlockX * 27, y: startingBlockY * 0.3);
        finishNode.name = "FINISH_NODE";
        
        let finish = SKSpriteNode(imageNamed: "finish_21");
        finish.size = CGSize(width: finish.frame.size.width / 4 + 4, height: finish.frame.size.height / 4 + 4);
        
        finishNode.addChild(finish);
        
        finishNode.thePosition = finishNode.position;
        
        finishNode.physicsBody = SKPhysicsBody(circleOfRadius: finish.size.width / 2);
        
        finishNode.physicsBody?.dynamic = false;
        
        finishNode.physicsBody!.categoryBitMask = CollisionCategoryBitmask.Finish;
        finishNode.physicsBody!.collisionBitMask = 0;
        
        
        foregroundNode.addChild(startNode);
        foregroundNode.addChild(blueFuzzNode);
        foregroundNode.addChild(blueLanding);
        foregroundNode.addChild(solidNode);
        foregroundNode.addChild(solidNode2);
        foregroundNode.addChild(greenFuzzNode);
        foregroundNode.addChild(greenLanding);
        foregroundNode.addChild(finishNode);
        
        
        foregroundNode.addChild(ballNode!);
        
    }

    
}
