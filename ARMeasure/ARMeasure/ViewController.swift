//
//  ViewController.swift
//  ARMeasure
//
//  Created by 根岸裕太 on 2017/07/01.
//  Copyright © 2017年 根岸裕太. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet private weak var lengthLabel: UILabel!
    
    var drawingNode: SCNNode?
    var drawingHitResult: ARHitTestResult?
    var drawingLengthTextNode: SCNNode?
    
    var timer = Timer()
    
    @IBAction private func mainTapGesture(_ recognizer: UITapGestureRecognizer) {
        
        let tapPoint = CGPoint(x: sceneView.frame.width / 2,
                               y: sceneView.frame.height / 2)
        
        // scneView上の座標?を取得
        let results = sceneView.hitTest(tapPoint, types: .featurePoint)
        guard let hitResult = results.first else { return }
        
        if let _ = drawingHitResult {
            
            timer.invalidate()
            
            drawingNode = nil
            drawingHitResult = nil
            drawingLengthTextNode = nil
            
            return
            
        } else {
            
            print("start")
            
            // 箱を生成
            let cube = SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0)
            let node = SCNNode(geometry: cube)
            node.name = "cube"
            
            // sceneView上のタップ座標のどこに箱を出現させるかを指定
            node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                           hitResult.worldTransform.columns.3.y,
                                           hitResult.worldTransform.columns.3.z)
            
            let text = SCNText(string: "0.0cm", extrusionDepth: 0.1)
            text.font = UIFont.systemFont(ofSize: 1)
            text.firstMaterial?.diffuse.contents = UIColor.black
            let textNode = SCNNode(geometry: text)
            textNode.position = node.position
            textNode.scale = SCNVector3(0.015, 0.015, 0.015)
            
            if let unwrappedRotation = sceneView.pointOfView?.rotation {
                node.rotation = unwrappedRotation
                textNode.rotation = unwrappedRotation
            }
            
            // ノードを追加
            sceneView.scene.rootNode.addChildNode(node)
            sceneView.scene.rootNode.addChildNode(textNode)
            drawingNode = node
            drawingHitResult = hitResult
            drawingLengthTextNode = textNode
            
            timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(drawUpdate(_:)),
                                         userInfo: nil,
                                         repeats: true)
            
            return
            
        }
        
    }
    
    @objc private func drawUpdate(_ timer: Timer) {
        
        let tapPoint = CGPoint(x: sceneView.frame.width / 2,
                               y: sceneView.frame.height / 2)
        
        // scneView上の座標?を取得
        let results = sceneView.hitTest(tapPoint, types: .featurePoint)
        guard let hitResult = results.first else { return }
        
        if let unwrappedDrawingNode = drawingNode,
            let unwrappedDrawingText = drawingLengthTextNode,
            let unwrappedDrawingHitResult = drawingHitResult {
            
            let plusX = hitResult.worldTransform.columns.3.x - unwrappedDrawingHitResult.worldTransform.columns.3.x
            let plusY = hitResult.worldTransform.columns.3.y - unwrappedDrawingHitResult.worldTransform.columns.3.y
            let plusZ = hitResult.worldTransform.columns.3.z - unwrappedDrawingHitResult.worldTransform.columns.3.z
            
            unwrappedDrawingNode.position = SCNVector3(x: (hitResult.worldTransform.columns.3.x + unwrappedDrawingHitResult.worldTransform.columns.3.x) / 2,
                                                       y: (hitResult.worldTransform.columns.3.y + unwrappedDrawingHitResult.worldTransform.columns.3.y) / 2,
                                                       z: (hitResult.worldTransform.columns.3.z + unwrappedDrawingHitResult.worldTransform.columns.3.z) / 2)
            
            unwrappedDrawingText.position = unwrappedDrawingNode.position
            
            if let unwrappedRotation = sceneView.pointOfView?.rotation {
                unwrappedDrawingNode.rotation = unwrappedRotation
                unwrappedDrawingText.rotation = unwrappedRotation
            }
            
            let movedLength = sqrt(pow(plusX, 2.0) + pow(plusY, 2.0) + pow(plusZ, 2.0))
            
            unwrappedDrawingNode.geometry = SCNBox(width: CGFloat(0.005 + movedLength),
                                                   height: 0.005,//CGFloat(0.05 + plusY),
                                                   length: 0.005,//CGFloat(0.05 + plusZ),
                                                   chamferRadius: 0)
            
//            0.125 = 8cm = 80mm
//            0.015 = 1cm = 10mm
//
//            0.0686298 = 6cm = 60mm
//            0.0114383 = 1cm = 10mm
//
//            0.0915415 = 12cm = 120mm
//            0.00762846 = 1cm = 10mm
            
            // 上みたいな感じで結構ばらけるので、とりあえず「0.01 = 1cm」とする。
            
            var cm = (0.005 + movedLength) * 1000
            cm = round(cm) / 10
            
            lengthLabel.text = String("\(cm)cm")
            
            let text = SCNText(string: "\(cm)cm", extrusionDepth: 0.1)
            text.font = UIFont.systemFont(ofSize: 1)
            text.firstMaterial?.diffuse.contents = UIColor.black
            unwrappedDrawingText.geometry = text
            unwrappedDrawingText.scale = SCNVector3(0.015, 0.015, 0.015)
            
//
//            let indices: [Int32] = [0, 1]
//
//            let vector1 = SCNVector3Make(unwrappedDrawingHitResult.worldTransform.columns.3.x,
//                                         unwrappedDrawingHitResult.worldTransform.columns.3.y,
//                                         unwrappedDrawingHitResult.worldTransform.columns.3.z)
//            let vector2 = SCNVector3Make(hitResult.worldTransform.columns.3.x,
//                                         hitResult.worldTransform.columns.3.y,
//                                         hitResult.worldTransform.columns.3.z)
//
//            let source = SCNGeometrySource(vertices: [vector1, vector2])
//            let element = SCNGeometryElement(indices: indices, primitiveType: .line)
//
//            let line = SCNGeometry(sources: [source], elements: [element])
//
//            drawingNode?.geometry = line
            
            
            
        }
        
    }
    
    @IBAction private func mainPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        // sceneView上のタップ箇所を取得
        let tapPoint = recognizer.location(in: sceneView)
        
        // scneView上の座標?を取得
        let results = sceneView.hitTest(tapPoint, types: .featurePoint)
        guard let hitResult = results.first else { return }
        
        if recognizer.state == .began {
            
            print("panBegan")
            
            // 箱を生成
            let cube = SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0)
            let node = SCNNode(geometry: cube)
            node.name = "cube"
            
            // sceneView上のタップ座標のどこに箱を出現させるかを指定
            node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                           hitResult.worldTransform.columns.3.y,
                                           hitResult.worldTransform.columns.3.z)
            
            // ノードを追加
            sceneView.scene.rootNode.addChildNode(node)
            drawingNode = node
            drawingHitResult = hitResult
            
            return
        } else if recognizer.state == .ended {
            
            drawingNode = nil
            drawingHitResult = nil
            
            return
        }
        
        if let unwrappedDrawingHitResult = drawingHitResult {
            let indices: [Int32] = [0, 1]
            
            let vector1 = SCNVector3Make(unwrappedDrawingHitResult.worldTransform.columns.3.x,
                                         unwrappedDrawingHitResult.worldTransform.columns.3.y,
                                         unwrappedDrawingHitResult.worldTransform.columns.3.z)
            let vector2 = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                         hitResult.worldTransform.columns.3.y,
                                         hitResult.worldTransform.columns.3.z)
            
            let source = SCNGeometrySource(vertices: [vector1, vector2])
            let element = SCNGeometryElement(indices: indices, primitiveType: .line)
            
            let line = SCNGeometry(sources: [source], elements: [element])
            
            drawingNode?.geometry = line
            
//            sceneView.scene.rootNode.addChildNode(lineNode)
            
        }
        
//        if let unwrappedDrawingNode = drawingNode,
//            let unwrappedDrawingHitResult = drawingHitResult {
//            let plusX = hitResult.worldTransform.columns.3.x - unwrappedDrawingHitResult.worldTransform.columns.3.x
//            let plusY = hitResult.worldTransform.columns.3.y - unwrappedDrawingHitResult.worldTransform.columns.3.y
//            let plusZ = hitResult.worldTransform.columns.3.z - unwrappedDrawingHitResult.worldTransform.columns.3.z
//
//            unwrappedDrawingNode.position = SCNVector3(x: (hitResult.worldTransform.columns.3.x + unwrappedDrawingHitResult.worldTransform.columns.3.x) / 2,
//                                                       y: (hitResult.worldTransform.columns.3.y + unwrappedDrawingHitResult.worldTransform.columns.3.y) / 2,
//                                                       z: (hitResult.worldTransform.columns.3.z + unwrappedDrawingHitResult.worldTransform.columns.3.z) / 2)
//
//            unwrappedDrawingNode.geometry = SCNBox(width: CGFloat(0.05 + plusX),
//                                                   height: 0.005,//CGFloat(0.05 + plusY),
//                                                   length: 0.005,//CGFloat(0.05 + plusZ),
//                                                   chamferRadius: 0)
//
//            if (fabs(plusX) > fabs(plusY) && fabs(plusX) > fabs(plusZ)) {
//
//                unwrappedDrawingNode.rotation = SCNVector4(x: 1,
//                                                           y: 0,
//                                                           z: 0,
//                                                           w: Float(M_PI / 180 * angle(aX: Double(unwrappedDrawingHitResult.worldTransform.columns.3.y),
//                                                                                       aY: Double(unwrappedDrawingHitResult.worldTransform.columns.3.z),
//                                                                                       bX: Double(hitResult.worldTransform.columns.3.y),
//                                                                                       bY: Double(hitResult.worldTransform.columns.3.z))))
//
//            } else if (fabs(plusY) > fabs(plusX) && fabs(plusY) > fabs(plusZ)) {
//
//                unwrappedDrawingNode.rotation = SCNVector4(x: 0,
//                                                           y: 1,
//                                                           z: 0,
//                                                           w: Float(M_PI / 180 * angle(aX: Double(unwrappedDrawingHitResult.worldTransform.columns.3.x),
//                                                                                       aY: Double(unwrappedDrawingHitResult.worldTransform.columns.3.z),
//                                                                                       bX: Double(hitResult.worldTransform.columns.3.x),
//                                                                                       bY: Double(hitResult.worldTransform.columns.3.z))))
//
//            } else if (fabs(plusZ) > fabs(plusX) && fabs(plusZ) > fabs(plusY)) {
//
//                unwrappedDrawingNode.rotation = SCNVector4(x: 0,
//                                                           y: 0,
//                                                           z: 1,
//                                                           w: Float(M_PI / 180 * angle(aX: Double(unwrappedDrawingHitResult.worldTransform.columns.3.x),
//                                                                                       aY: Double(unwrappedDrawingHitResult.worldTransform.columns.3.y),
//                                                                                       bX: Double(hitResult.worldTransform.columns.3.x),
//                                                                                       bY: Double(hitResult.worldTransform.columns.3.y))))
//
//            }
//
//        }
        
    }
    
    func angle(aX: Double, aY: Double, bX: Double, bY: Double) -> Double {
        var r = atan2(bY - aY, bX - aX)
        if r < 0 {
            r = r + 2 * M_PI
        }
        return floor(r * 360 / (2 * M_PI))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // デバッグ時用オプション
        // ARKitが感知しているところに「+」がいっぱい出てくるようになる
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]//, ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
        sceneView.scene.rootNode.name = "root"
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // ARKit用。平面を感知するように指定
        configuration.planeDetection = .horizontal
        // 現実の環境光に合わせてレンダリングしてくれるらしい
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
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
