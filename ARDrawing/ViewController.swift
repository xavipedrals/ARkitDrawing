//
//  ViewController.swift
//  ARDrawing
//
//  Created by Xavier Pedrals on 09/10/2017.
//  Copyright © 2017 Xavier Pedrals. All rights reserved.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
    }
    
    func setupSceneView() {
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let currentPosition = getCurrentPositionVector(transform: pointOfView.transform)
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                self.draw(currentPosition: currentPosition)
            }
            else {
                self.setPointer(currentPosition: currentPosition)
            }
        }
    }
    
    func getCurrentPositionVector(transform: SCNMatrix4) -> SCNVector3 {
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPosition = orientation + location
        return currentPosition
    }
    
    func draw(currentPosition: SCNVector3) {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
        sphereNode.position = currentPosition
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
    
    func setPointer(currentPosition: SCNVector3) {
        let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
        pointer.name = "pointer"
        pointer.position = currentPosition
        removePreviousPointers()
        pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.sceneView.scene.rootNode.addChildNode(pointer)
    }
    
    func removePreviousPointers() {
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
            if node.name == "pointer" {
                node.removeFromParentNode()
            }
        })
    }
}

extension SCNVector3 {
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
}


