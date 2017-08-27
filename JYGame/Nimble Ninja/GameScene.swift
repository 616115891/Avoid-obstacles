//
//  GameScene.swift
//  Nimble Ninja
//
//  Created by Michael Leech on 1/21/15.
//  Copyright (c) 2015 CrashCourseCode. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var movingGround: MLMovingGround!
    var hero: MLHero!
    var cloudGenerator: MLCloudGenerator!
    var wallGenerator: MLWallGenerator!
    
    var isStarted = false
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 159.0/255.0, green: 201.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        
        addMovingGround()
        addHero()
        addCloudGenerator()
        addWallGenerator()
        addTapToStartLabel()
        addPointsLabels()
        addPhysicsWorld()
        loadHighscore()
        
    }
    
    func addMovingGround() {
        movingGround = MLMovingGround(size: CGSize(width: view!.frame.width, height: kMLGroundHeight))
        movingGround.position = CGPoint(x: 0, y: view!.frame.size.height/2)
        addChild(movingGround)
    }
    
    func addHero() {
        hero = MLHero()
        hero.position = CGPoint(x: 70, y: movingGround.position.y + movingGround.frame.size.height/2 + hero.frame.size.height/2)
        addChild(hero)
        hero.breathe()
    }
    
    func addCloudGenerator() {
        cloudGenerator = MLCloudGenerator(color: UIColor.clear, size: view!.frame.size)
        cloudGenerator.position = view!.center
        addChild(cloudGenerator)
        cloudGenerator.populate(7)
        cloudGenerator.startGeneratingWithSpawnTime(5)
    }
    
    func addWallGenerator() {
        wallGenerator = MLWallGenerator(color: UIColor.clear, size: view!.frame.size)
        wallGenerator.position = view!.center
        addChild(wallGenerator)
    }
    
    func addTapToStartLabel() {
        let tapToStartLabel = SKLabelNode(text: "Tap to start!")
        tapToStartLabel.name = "tapToStartLabel"
        tapToStartLabel.position.x = view!.center.x
        tapToStartLabel.position.y = view!.center.y + 40
        tapToStartLabel.fontName = "Helvetica"
        tapToStartLabel.fontColor = UIColor.black
        tapToStartLabel.fontSize = 22.0
        addChild(tapToStartLabel)
        tapToStartLabel.run(blinkAnimation())
    }
    
    func addPointsLabels() {
        let pointsLabel = MLPointsLabel(num: 0)
        pointsLabel.position = CGPoint(x: 20.0, y: view!.frame.size.height - 35)
        pointsLabel.name = "pointsLabel"
        addChild(pointsLabel)
        
        let highscoreLabel = MLPointsLabel(num: 0)
        highscoreLabel.name = "highscoreLabel"
        highscoreLabel.position = CGPoint(x: view!.frame.size.width - 20, y: view!.frame.size.height - 35)
        addChild(highscoreLabel)
        
        let highscoreTextLabel = SKLabelNode(text: "High")
        highscoreTextLabel.fontColor = UIColor.black
        highscoreTextLabel.fontSize = 14.0
        highscoreTextLabel.fontName = "Helvetica"
        highscoreTextLabel.position = CGPoint(x: 0, y: -20)
        highscoreLabel.addChild(highscoreTextLabel)
    }
    
    func addPhysicsWorld() {
        physicsWorld.contactDelegate = self
    }
    
    func loadHighscore() {
        let defaults = UserDefaults.standard
        
        let highscoreLabel = childNode(withName: "highscoreLabel") as! MLPointsLabel
        highscoreLabel.setTo(defaults.integer(forKey: "highscore"))
    }
    
    // MARK: - Game Lifecycle
    func start() {
        isStarted = true
        
        let tapToStartLabel = childNode(withName: "tapToStartLabel")
        tapToStartLabel?.removeFromParent()
        
        hero.stop()
        hero.startRunning()
        movingGround.start()
        
        wallGenerator.startGeneratingWallsEvery(1)
    }
    
    func gameOver() {
        isGameOver = true
        
        // stop everything
        hero.fall()
        wallGenerator.stopWalls()
        movingGround.stop()
        hero.stop()
        
        // create game over label
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontColor = UIColor.black
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.position.x = view!.center.x
        gameOverLabel.position.y = view!.center.y + 40
        gameOverLabel.fontSize = 22.0
        addChild(gameOverLabel)
        gameOverLabel.run(blinkAnimation())
        
        
        // save current points label value
        let pointsLabel = childNode(withName: "pointsLabel") as! MLPointsLabel
        let highscoreLabel = childNode(withName: "highscoreLabel") as! MLPointsLabel
        
        if highscoreLabel.number < pointsLabel.number {
            highscoreLabel.setTo(pointsLabel.number)
            
            let defaults = UserDefaults.standard
            defaults.set(highscoreLabel.number, forKey: "highscore")
        }
    }
    
    func restart() {
        cloudGenerator.stopGenerating()
        
        let newScene = GameScene(size: view!.bounds.size)
        newScene.scaleMode = .aspectFill
        
        view!.presentScene(newScene)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restart()
        } else if !isStarted {
            start()
        } else {
            hero.flip()
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        
        if wallGenerator.wallTrackers.count > 0 {
        
            let wall = wallGenerator.wallTrackers[0] as MLWall
            
            let wallLocation = wallGenerator.convert(wall.position, to: self)
            if wallLocation.x < hero.position.x {
                wallGenerator.wallTrackers.remove(at: 0)
                
                let pointsLabel = childNode(withName: "pointsLabel") as! MLPointsLabel
                pointsLabel.increment()
                
                
            }
        }
        
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if !isGameOver {
            gameOver()
        }
    }
    
    // MARK: - Animations
    func blinkAnimation() -> SKAction {
        let duration = 0.4
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatForever(blink)
    }
}
