//
//  GameViewController.swift
//  Build Path
//
//  Created by Artem Galiev on 20.10.2023.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameViewControllerDelegate {
    func showPathPlayer(path: String)
}

extension GameViewController: GameViewControllerDelegate {
    func showPathPlayer(path: String) {
        pathLabel.text = path
    }
}

class GameViewController: UIViewController {
    
    let pathLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let skScene: GameScene = SKScene(fileNamed: "GameScene") as! GameScene
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let skView = SKView(frame: view.frame)
        view.addSubview(skView)
        
        skScene.size = CGSize(width: view.frame.width, height: view.frame.height)
        skScene.scaleMode = .aspectFill
        skView.presentScene(skScene)  
        
        view.addSubview(pathLabel)
        
        pathLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        pathLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        pathLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        skScene.pathPlayerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        skScene.startGame()
    }

}
