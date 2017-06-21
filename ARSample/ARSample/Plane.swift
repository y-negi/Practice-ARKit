//
//  Plane.swift
//  ARSample
//
//  Created by 根岸裕太 on 2017/06/21.
//  Copyright © 2017年 根岸裕太. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    
    private var planeGeometry: SCNBox!
    
    init(anchor initAnchor: ARPlaneAnchor) {
        super.init()
        
        anchor = initAnchor
        
        planeGeometry = SCNBox(width: CGFloat(initAnchor.extent.x),
                               height: 0.01,
                               length: CGFloat(initAnchor.extent.z),
                               chamferRadius: 0)
        let planeNode = SCNNode(geometry: planeGeometry)
        
        planeNode.position = SCNVector3Make(initAnchor.center.x, 0, initAnchor.center.z)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic,
                                               shape: SCNPhysicsShape(geometry: planeGeometry,
                                                                      options: nil))
        planeNode.name = "plane"
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        planeNode.geometry?.firstMaterial = material
        
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.length = CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        if let node = childNodes.first {
            node.physicsBody = SCNPhysicsBody(type: .kinematic,
                                              shape: SCNPhysicsShape(geometry: planeGeometry,
                                                                     options: nil))
        }
    }
    
}
