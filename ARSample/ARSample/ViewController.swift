//
//  ViewController.swift
//  ARSample
//
//  Created by 根岸裕太 on 2017/06/21.
//  Copyright © 2017年 根岸裕太. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    private var cubes = Array<SCNNode>()
    private var planes = Array<Plane>()

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func sceneViewTapped(_ recognizer: UITapGestureRecognizer) {
        
        // sceneView上のタップ箇所を取得
        let tapPoint = recognizer.location(in: sceneView)
        
        // scneView上の座標?を取得
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        
        guard let hitResult = results.first else { return }
        
        // 箱を生成
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.name = "cube"
        
        // 箱の判定を追加
        let cubeShape = SCNPhysicsShape(geometry: cube, options: nil)
        cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: cubeShape)
        
        // sceneView上のタップ座標のどこに箱を出現させるかを指定
        cubeNode.position = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                           hitResult.worldTransform.columns.3.y + 0.1,
                                           hitResult.worldTransform.columns.3.z)
        
        // ノードを追加
        sceneView.scene.rootNode.addChildNode(cubeNode)
        cubes.append(cubeNode)
    }
    
    @IBAction func sceneViewLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began { return }
        
        // sceneView上のタップ箇所を取得
        let tapPoint = recognizer.location(in: sceneView)
        
        // scneView上の座標?を取得
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        
        if let anchor = results.first?.anchor,
            let hitNode = sceneView.node(for: anchor) {
//            print("root???")
//            print(sceneView.scene.rootNode.name)
//            print("oya")
//            print(hitNode.name ?? "ない")
//            print("---")
//            hitNode.childNodes.forEach { print($0.name ?? "ない") }
//            if hitNode {
//                hitNode.runAction(SCNAction.removeFromParentNode())
//            }
        }
        
        cubes.forEach { $0.removeFromParentNode() }
        cubes.removeAll()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // デバッグ時用オプション
        // ARKitが感知しているところに「+」がいっぱい出てくるようになる
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
        sceneView.scene.rootNode.name = "root"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // ARKit用。平面を感知するように指定
        configuration.planeDetection = .horizontal
        // 現実の環境光に合わせてレンダリングしてくれるらしい
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 平面を生成
        let plane = Plane(anchor: planeAnchor)
        
        // ノードを追加
        node.addChildNode(plane)
        
        // 管理用配列に追加
        planes.append(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // updateされた平面ノードと同じidのものの情報をアップデート
        for plane in planes {
            if plane.anchor.identifier == anchor.identifier,
                let planeAnchor = anchor as? ARPlaneAnchor {
                plane.update(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // updateされた平面ノードと同じidのものの情報を削除
        for (index, plane) in planes.enumerated().reversed() {
            if plane.anchor.identifier == anchor.identifier {
                planes.remove(at: index)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
