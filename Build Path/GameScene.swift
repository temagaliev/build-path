//
//  GameScene.swift
//  Build Path
//
//  Created by Artem Galiev on 20.10.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var backgraundNode = SKSpriteNode()
    var player = SKSpriteNode()
    
    var forwardButton = SKSpriteNode(imageNamed: NameImage.forvard.rawValue)
    var backButton = SKSpriteNode(imageNamed: NameImage.back.rawValue)
    var leftButton = SKSpriteNode(imageNamed: NameImage.left.rawValue)
    var rightButton = SKSpriteNode(imageNamed: NameImage.right.rawValue)
    var playButton = SKSpriteNode(imageNamed: NameImage.play.rawValue)

    var arrayActions: [MovePlayer] = []
    
    var timerMove = Timer()
    var valueMove: Int = 0
    
    var pathPlayerDelegate: GameViewControllerDelegate?
    var pathPlayer: String = ""
    
    var valueObstacleInMap: Int = 60
    var valueKeyInMap: Int = 4
    var arrayObjectOnMap: [SKSpriteNode] = []
    var arrayObctacleOnMap: [SKSpriteNode] = []
    
    var sizeGamePlay: CGFloat = 15
    var sizeMap: Int = 10
    
    var isCollision: Bool = false

    override func didMove(to view: SKView) {
        backgraundNode = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: frame.width, height: frame.height))
        addChild(backgraundNode)
        
        view.scene?.delegate = self
        physicsWorld.contactDelegate = self
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(color: SKColor.white, size: CGSize(width: sizeGamePlay, height: sizeGamePlay))

        player.position = CGPoint(x: 1 * sizeGamePlay + (sizeGamePlay / 2), y: CGFloat(-sizeMap) * sizeGamePlay + (sizeGamePlay / 2))
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = UInt32(BodyType.player)
        player.physicsBody?.contactTestBitMask = UInt32(BodyType.key)
        player.physicsBody?.contactTestBitMask = UInt32(BodyType.enemy)
        player.physicsBody?.contactTestBitMask = UInt32(BodyType.exit)

        addChild(player)
    }
    
    private func setupButton() {
        forwardButton.size = CGSize(width: 50, height: 50)
        forwardButton.position = CGPoint(x: frame.midX, y: frame.minY + 135)
        forwardButton.name = "forwardButton"
        addChild(forwardButton)
        
        backButton.size = CGSize(width: 50, height: 50)
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 65)
        backButton.name = "backButton"
        addChild(backButton)
        
        leftButton.size = CGSize(width: 50, height: 50)
        leftButton.position = CGPoint(x: frame.midX - 55, y: frame.minY + 100)
        leftButton.name = "leftButton"
        addChild(leftButton)
        
        rightButton.size = CGSize(width: 50, height: 50)
        rightButton.position = CGPoint(x: frame.midX + 55, y: frame.minY + 100)
        rightButton.name = "rightButton"
        addChild(rightButton)
        
        playButton.size = CGSize(width: 60, height: 60)
        playButton.position = CGPoint(x: frame.maxX - 60, y: frame.minY + 100)
        playButton.name = "playButton"
        addChild(playButton)
    }
    
    //MARK: - Начало игры
    public func startGame() {
        setupButton()
        setupPlayer()
        pathPlayer = ""
        createMap()
        createObjectOnMap()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let node = self.atPoint(touchLocation)
            
            if node.name == forwardButton.name {
                arrayActions.append(.forvard)
                pathPlayer = pathPlayer + "↑"
                pathPlayerDelegate?.showPathPlayer(path: pathPlayer)
            }
            
            if node.name == backButton.name {
                arrayActions.append(.back)
                pathPlayer = pathPlayer + "↓"
                pathPlayerDelegate?.showPathPlayer(path: pathPlayer)
            }
            
            if node.name == leftButton.name {
                arrayActions.append(.left)
                pathPlayer = pathPlayer + "←"
                pathPlayerDelegate?.showPathPlayer(path: pathPlayer)
            }
            
            if node.name == rightButton.name {
                arrayActions.append(.right)
                pathPlayer = pathPlayer + "→"
                pathPlayerDelegate?.showPathPlayer(path: pathPlayer)
            }
            
            if node.name == playButton.name {
                if arrayActions.count != 0 {
                    movePlayerActions()
                }
            }
        }

    }
    
    private func movePlayerActions() {
        timerMove = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(movePlayer), userInfo: nil, repeats: true)
    }
    
    @objc func movePlayer() {
        
        let move = arrayActions[valueMove]
        
        switch move {
        case .forvard:
            checkCorrectMove(xMove: CGFloat(roundf(Float(player.position.x) * 10) / 10), yMove: (CGFloat(roundf(Float(player.position.y) * 10) / 10)) + sizeGamePlay)
        case .back:
            checkCorrectMove(xMove: CGFloat(roundf(Float(player.position.x) * 10) / 10), yMove: (CGFloat(roundf(Float(player.position.y) * 10) / 10)) - sizeGamePlay)
        case .left:
            checkCorrectMove(xMove: ((CGFloat(roundf(Float(player.position.x) * 10) / 10)) - sizeGamePlay), yMove: CGFloat(roundf(Float(player.position.y) * 10) / 10))
        case .right:
            checkCorrectMove(xMove: ((CGFloat(roundf(Float(player.position.x) * 10) / 10)) + sizeGamePlay), yMove: CGFloat(roundf(Float(player.position.y) * 10) / 10))
        }
        
        pathPlayer.removeFirst()
        pathPlayerDelegate?.showPathPlayer(path: pathPlayer)
        
        if valueMove == arrayActions.count - 1 {
            arrayActions = []
            timerMove.invalidate()
            valueMove = 0
            pathPlayer = ""
        } else {
            valueMove = valueMove + 1
        }
    }
    
    private func checkCorrectMove(xMove: CGFloat, yMove: CGFloat) {
        var isMove: Bool = true
        for node in arrayObctacleOnMap {
            if node.position == CGPoint(x: xMove, y: yMove) {
                isMove = false
                break
            }
        }
        if isMove {
            let action = SKAction.move(to: CGPoint(x: xMove, y: yMove), duration: 0.3)
            player.run(action)
        }
    }
    
    //MARK: - Создание карты
    func createMap() {
        for i in -sizeMap...sizeMap {
            let nodeVertical = SKSpriteNode(color: UIColor.white, size: CGSize(width: 0.5, height: 300))
            nodeVertical.position = CGPoint(x: i * Int(sizeGamePlay), y: 0)
            addChild(nodeVertical)
            let nodeHorizontal = SKSpriteNode(color: UIColor.white, size: CGSize(width: 300, height: 0.5))
            nodeHorizontal.position = CGPoint(x: 0, y: i * Int(sizeGamePlay))
            addChild(nodeHorizontal)
        }
    }
    
    //MARK: - Создание объектов на карте
    func createObjectOnMap() {
        for _ in 0...valueObstacleInMap {
            let position = posititonNodeInMap()
            
            let obstacleNode = SKSpriteNode(color: SKColor.red, size: CGSize(width: sizeGamePlay - 5, height: sizeGamePlay - 5))
            obstacleNode.position = position
            obstacleNode.physicsBody = SKPhysicsBody(rectangleOf: obstacleNode.size)
            obstacleNode.physicsBody?.affectedByGravity = false
            obstacleNode.physicsBody?.isDynamic = false
            obstacleNode.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            obstacleNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)

            arrayObctacleOnMap.append(obstacleNode)
            arrayObjectOnMap.append(obstacleNode)
            addChild(obstacleNode)
        }
        
        for _ in 1...valueKeyInMap {
            let position = posititonNodeInMap()
            
            let keyNode = SKSpriteNode(color: SKColor.blue, size: CGSize(width: sizeGamePlay - 10, height: sizeGamePlay - 10))
            keyNode.position = position
            keyNode.physicsBody = SKPhysicsBody(rectangleOf: keyNode.size)
            keyNode.physicsBody?.affectedByGravity = false
            keyNode.physicsBody?.collisionBitMask = 0
            keyNode.physicsBody?.categoryBitMask = UInt32(BodyType.key)
            keyNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)
            arrayObjectOnMap.append(keyNode)
            addChild(keyNode)
        }
        
        for _ in 1...valueKeyInMap * 2 {
            let position = posititonNodeInMap()

            let mobNode = SKSpriteNode(color: SKColor.orange, size: CGSize(width: sizeGamePlay - 10, height: sizeGamePlay - 10))
            mobNode.position = position
            mobNode.physicsBody = SKPhysicsBody(rectangleOf: mobNode.size)
            mobNode.physicsBody?.affectedByGravity = false
            mobNode.physicsBody?.collisionBitMask = 0
            mobNode.physicsBody?.categoryBitMask = UInt32(BodyType.mob)
            mobNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)
            arrayObjectOnMap.append(mobNode)
            addChild(mobNode)
        }
        
        let exitNode = SKSpriteNode(color: SKColor.green, size: CGSize(width: sizeGamePlay - 5, height: sizeGamePlay - 5))
        exitNode.position = CGPoint(x: CGFloat(sizeMap) * sizeGamePlay - (sizeGamePlay / 2), y: CGFloat(sizeMap) * sizeGamePlay - (sizeGamePlay / 2))
        exitNode.physicsBody = SKPhysicsBody(rectangleOf: exitNode.size)
        exitNode.physicsBody?.affectedByGravity = false
        exitNode.physicsBody?.collisionBitMask = 0
        exitNode.physicsBody?.categoryBitMask = UInt32(BodyType.exit)
        exitNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)
        arrayObjectOnMap.append(exitNode)
        addChild(exitNode)
    }
    
    private func posititonNodeInMap() -> CGPoint {
        var isPositionRepeat = false
        
        var xPosititon: CGFloat = (1 * sizeGamePlay) - (sizeGamePlay / 2)
        var yPosititon: CGFloat = (1 * sizeGamePlay) - (sizeGamePlay / 2)
        
        if arrayObjectOnMap.count != 0 {
            for node in arrayObjectOnMap {
                if node.position.x == xPosititon && node.position.y == yPosititon {
                    isPositionRepeat = true
                    break
                }
            }
            
            while isPositionRepeat {
                isPositionRepeat = false
                
                let randomObstaclePoistionX = Int.random(in: -sizeMap...sizeMap)
                let randpmObstaclePositionY = Int.random(in: -(sizeMap - 1)...sizeMap)
                
                if randomObstaclePoistionX >= 0 {
                    xPosititon = (CGFloat(randomObstaclePoistionX) * sizeGamePlay) - (sizeGamePlay / 2)
                } else {
                    xPosititon = (CGFloat(randomObstaclePoistionX) * sizeGamePlay) + (sizeGamePlay / 2)
                }
                
                if randpmObstaclePositionY >= 0 {
                    yPosititon = (CGFloat(randpmObstaclePositionY) * sizeGamePlay) - (sizeGamePlay / 2)
                } else {
                    yPosititon = (CGFloat(randpmObstaclePositionY) * sizeGamePlay) + (sizeGamePlay / 2)
                }
                for node in arrayObjectOnMap {
                    if node.position.x == xPosititon && node.position.y == yPosititon {
                        isPositionRepeat = true
                        break
                    }
                }
            }
            
            return CGPoint(x: xPosititon, y: yPosititon)

        } else {
            let randomObstaclePoistionX = Int.random(in: -sizeMap...sizeMap)
            let randpmObstaclePositionY = Int.random(in: -(sizeMap - 1)...sizeMap)

            if randomObstaclePoistionX >= 0 {
                xPosititon = (CGFloat(randomObstaclePoistionX) * sizeGamePlay) - (sizeGamePlay / 2)
            } else {
                xPosititon = (CGFloat(randomObstaclePoistionX) * sizeGamePlay) + (sizeGamePlay / 2)
            }
            
            if randpmObstaclePositionY >= 0 {
                yPosititon = (CGFloat(randpmObstaclePositionY) * sizeGamePlay) - (sizeGamePlay / 2)
            } else {
                yPosititon = (CGFloat(randpmObstaclePositionY) * sizeGamePlay) + (sizeGamePlay / 2)
            }
            
            return CGPoint(x: xPosititon, y: yPosititon)
        }
    }
}

//MARK: - SKSceneDelegate
extension GameScene: SKSceneDelegate {
    override func update(_ currentTime: TimeInterval) {

    }
}

//MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    //Столкновения
    func didBegin(_ contact: SKPhysicsContact) {
        //Переменные контакта
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
//        let enemy = UInt32(BodyType.enemy)
        let exit = UInt32(BodyType.exit)
        let player = UInt32(BodyType.player)
        let key = UInt32(BodyType.key)
        let mob = UInt32(BodyType.mob)


        if bodyA == player && bodyB == key {
            contact.bodyB.node?.removeFromParent()
        }
        
        if bodyA == key && bodyB == player {
            contact.bodyA.node?.removeFromParent()
        }
        
        if bodyA == exit && bodyB == player {
            contact.bodyB.node?.removeFromParent()
        }
        
        if bodyA == player && bodyB == exit {
            contact.bodyA.node?.removeFromParent()
        }
        
        if bodyA == player && bodyB == mob || bodyA == mob && bodyB == player {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
    }
}
