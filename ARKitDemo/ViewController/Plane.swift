//
//  Plane.swift
//  ARKitDemo
//
//  Created by Влад Живаев on 09.04.2024.
//

import ARKit
import Foundation

final class Plane: SCNNode {
    
    //MARK: Initialization
    
    init(planeAnchor: ARPlaneAnchor) {
        super.init()
        createPlane(anchor: planeAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Internal
        
    func update(anchor: ARPlaneAnchor) {
        guard let plane = geometry as? SCNPlane else {
            return
        }
        let width = CGFloat(anchor.planeExtent.width)
        let height = CGFloat(anchor.planeExtent.height)
        
        plane.width = width
        plane.height = height
        
        let x = CGFloat(anchor.center.x)
        let y = CGFloat(anchor.center.y)
        let z = CGFloat(anchor.center.z)
        
        position = SCNVector3(x, y, z)
    }
    
    //MARK: Private
        
    private func createPlane(anchor: ARPlaneAnchor) {
        let width = CGFloat(anchor.planeExtent.width)
        let height = CGFloat(anchor.planeExtent.height)
        let plane = SCNPlane(width: width, height: height)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.6)
        
        plane.materials = [material]
        
        let x = CGFloat(anchor.center.x)
        let y = CGFloat(anchor.center.y)
        let z = CGFloat(anchor.center.z)
        
        geometry = plane
        position = SCNVector3(x, y, z)
        eulerAngles.x = -.pi / 2
    }
}
