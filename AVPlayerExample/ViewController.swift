//
//  ViewController.swift
//  AVPlayerExample
//
//  Created by Ryosuke Ito on 2022/12/23.
//

import AVFoundation
import UIKit

final class ViewController: UIViewController {
    let videoURL = URL(string: "my-https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
    private let player = AVPlayer()
    private weak var playerLayer: AVPlayerLayer!

    override func loadView() {
        super.loadView()
        let playerLayer = AVPlayerLayer(player: player)
        self.playerLayer = playerLayer
        view.layer.addSublayer(playerLayer)
        playerLayer.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let asset = AVURLAsset(url: videoURL)
        asset.resourceLoader.setDelegate(self, queue: .main)
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            DispatchQueue.main.async { [weak self] in
                self?.player.play()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
    }
}

extension ViewController: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("loading request: \(loadingRequest.request.url)")

        var host = loadingRequest.request.url!.host!
        var path = loadingRequest.request.url!.pathComponents.dropFirst().joined(separator: "/")
        let actualURL = URL(string: "https://\(host)/\(path)?hoge=hogehoge")!

        print("replaced request: \(actualURL)")

        var request = URLRequest(url: actualURL)
        request.httpMethod = loadingRequest.request.httpMethod

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                return
            } else if let data {
                let string = String(data: data, encoding: .utf8)
                print(string)
                loadingRequest.response = response
                loadingRequest.dataRequest?.respond(with: data)
            }
            loadingRequest.finishLoading()
        }
        task.resume()
        return true
    }
}
