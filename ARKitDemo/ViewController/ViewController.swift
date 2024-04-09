//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Heads&Hands on 31.03.2024.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
        
        sceneView.showsStatistics = true
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configuration.planeDetection = [.horizontal, .vertical]
        let tapGestureRecognzer = UITapGestureRecognizer(target: self, action: #selector(sceneDidTap))
        sceneView.addGestureRecognizer(tapGestureRecognzer)
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: Private
    
    private let configuration = ARWorldTrackingConfiguration()
    
    private var planesIds = [UUID]()
    
    private var selectedARItem: ARItem = .cube
    
    private lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray.withAlphaComponent(0.8)
        button.setTitle("Пауза", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var chooseObjectsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray.withAlphaComponent(0.8)
        button.setTitle("Куб", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(chooseObject), for: .touchUpInside)
        return button
    }()
    
    private lazy var cleanObjectsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(
            "Удалить модели",
            attributes: .init([.foregroundColor: UIColor.white])
        )
        config.baseBackgroundColor = .red.withAlphaComponent(0.8)
        config.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 0)
        button.configuration = config
        config.titleLineBreakMode = .byClipping
        button.configuration = config
        button.addTarget(self, action: #selector(cleanObjects), for: .touchUpInside)
        return button
    }()
    
    private func makeAnimationNode(path: String, scale: SCNVector3, position: SCNVector3) -> SCNNode? {
        guard let loadedScene = SCNScene(named: path) else {
            return nil
        }
        
        let node = SCNNode()
        
        loadedScene.rootNode.childNodes.forEach {
            node.addChildNode($0 as SCNNode)
        }
        
        node.scale = scale
        node.position = position
        
        return node
    }
    
    private func makeCubeNode(size: CGFloat, position: SCNVector3, texture: Any?) -> SCNNode {
        // Создаем геометрию
        let geometry = SCNBox(
            width: size,
            height: size,
            length: size,
            chamferRadius: 0
        )

        // Создаем набор атрибутов, которые будут влиять на внешний вид объекта
        let material = SCNMaterial()
        material.diffuse.contents = texture
        
        // Создаем элемент сцены. К нему можно прикрепить геометрию или другой отображаемый контент
        let node = SCNNode(geometry: geometry)
        node.geometry?.materials = [material]
        node.position = position
        
        return node
    }
    
    private func addCubeBuTouch(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .any),
              let result = sceneView.session.raycast(query).first
        else {
            return
        }
        
        let logoTexture = UIImage(named: "logo.png")
        let position = SCNVector3(
            x: result.worldTransform.columns.3.x,
            y: result.worldTransform.columns.3.y + 0.07,
            z: result.worldTransform.columns.3.z
        )
        let node = makeCubeNode(size: 0.2, position: position, texture: logoTexture)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func addWolfByTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .any),
              let result = sceneView.session.raycast(query).first
        else {
            return
        }
        
        let position = SCNVector3(
            x: result.worldTransform.columns.3.x,
            y: result.worldTransform.columns.3.y + 0.07,
            z: result.worldTransform.columns.3.z
        )
        
        guard let node = makeAnimationNode(path: "art.scnassets/Wolf/Wolf_dae.dae", scale: .init(x: 0.4, y: 0.4, z: 0.4), position: position) else {
            return
        }
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    @objc
    private func pauseAction() {
        if pauseButton.currentTitle == "Пауза" {
            pauseButton.setTitle("Старт", for: .normal)
            sceneView.session.pause()
        } else {
            pauseButton.setTitle("Пауза", for: .normal)
            sceneView.session.run(configuration)
        }
    }
    
    @objc
    private func sceneDidTap(gesture: UITapGestureRecognizer) {
        switch selectedARItem {
        case .cube:
            addCubeBuTouch(gesture: gesture)
        case .wolf:
            addWolfByTap(gesture: gesture)
        }
    }
    
    @objc
    private func chooseObject() {
        let alert = UIAlertController(title: "Выбери объект", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Куб Heads and Hands", style: .default, handler: { [weak self] _ in
            guard self?.selectedARItem != .cube else { return }
            self?.selectedARItem = .cube
            self?.chooseObjectsButton.setTitle("Куб", for: .normal)
        }))
        alert.addAction(.init(title: "Волк", style: .default, handler: { [weak self] _ in
            guard self?.selectedARItem != .wolf else { return }
            self?.selectedARItem = .wolf
            self?.chooseObjectsButton.setTitle("Волк", for: .normal)
        }))
        self.present(alert, animated: true)
    }
    
    @objc
    private func cleanObjects() {
        let objectNodes = sceneView.scene.rootNode.childNodes.filter { !($0 is Plane) }
        objectNodes.forEach {
            $0.removeFromParentNode()
        }
    }
    
    private func configureSubviews() {
        view.addSubview(sceneView)
        sceneView.addSubview(pauseButton)
        sceneView.addSubview(chooseObjectsButton)
        sceneView.addSubview(cleanObjectsButton)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pauseButton.widthAnchor.constraint(equalToConstant: 80),
            pauseButton.heightAnchor.constraint(equalToConstant: 44),
            pauseButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -24),
            pauseButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            
            chooseObjectsButton.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 16),
            chooseObjectsButton.trailingAnchor.constraint(equalTo: pauseButton.leadingAnchor, constant: -12),
            chooseObjectsButton.bottomAnchor.constraint(equalTo: pauseButton.bottomAnchor),
            chooseObjectsButton.heightAnchor.constraint(equalToConstant: 44),
            
            cleanObjectsButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
            cleanObjectsButton.bottomAnchor.constraint(equalTo: pauseButton.bottomAnchor),
            cleanObjectsButton.heightAnchor.constraint(equalToConstant: 44),
            cleanObjectsButton.leadingAnchor.constraint(equalTo: pauseButton.trailingAnchor, constant: 12),
        ])
    }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, !planesIds.contains(planeAnchor.identifier) else {
            return
        }
        
        let planeNode = Plane(planeAnchor: planeAnchor)
        planesIds.append(planeAnchor.identifier)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = node.childNodes.first(where: { $0 is Plane }) as? Plane
        else {
            return
        }
        planeNode.update(anchor: planeAnchor)
    }
}
