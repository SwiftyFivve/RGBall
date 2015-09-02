//
//  GameState.swift
//  
//
//  Created by Jordan Weaver on 7/28/15.
//
//

import Foundation

class GameState {
    var level: Int
    var gameTime: Int
    var highTime: Int
    
    class var sharedInstance: GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance;
    }
    
    
    init(){
        gameTime = 0;
        level = 1;
        highTime = 0;
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        highTime = defaults.integerForKey (String(format: "%02d_gameTime", level));
        
    }
    
    func saveState(){
        highTime = min(gameTime, highTime);
        
        let defaults = NSUserDefaults.standardUserDefaults();
        defaults.setInteger(highTime, forKey: String(format: "%02d_gameTime", level));
        NSUserDefaults.standardUserDefaults().synchronize();
        
    }
}