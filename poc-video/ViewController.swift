import UIKit
import AVFoundation

class ViewController: UIViewController {
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var fileURL: URL!
    var compressedSize: Int!
    var isCompressed: Bool!
    var destinationURL: URL!
    var playerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("file not found")
            return
        }
        fileURL = videoURL
        
        setupView()
        
        playerItem = AVPlayerItem(url: fileURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Configurando o AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 300)
        playerLayer.videoGravity = .resizeAspect
        self.view.layer.addSublayer(playerLayer)
    }
    
    lazy var uncompressedSizeLabel = UILabel(frame: .zero)
    lazy var playButton = UIButton(frame: .zero)
    lazy var pauseButton = UIButton(frame: .zero)
    lazy var compressButton = UIButton(frame: .zero)
    lazy var compressedSizeLabel = UILabel(frame: .zero)
    
    func setupView() {
        isCompressed = false
        view.backgroundColor = .lightGray
    
        let asset = AVURLAsset(url: fileURL)
    
        uncompressedSizeLabel.text = "Tamanho não comprimido: \(Double(asset.fileSize ?? 0) / (1024*1024)) megabytes"
        uncompressedSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uncompressedSizeLabel)
    
        playButton.setTitle("▶️", for: .normal)
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = .systemBlue
        view.addSubview(playButton)
        
        
        pauseButton.setTitle("⏸️", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseVideo), for: .touchUpInside)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.backgroundColor = .systemRed
        view.addSubview(pauseButton)
    
        compressButton.setTitle("Comprimir", for: .normal)
        compressButton.addTarget(self, action: #selector(startCompression), for: .touchUpInside)
        compressButton.translatesAutoresizingMaskIntoConstraints = false
        compressButton.backgroundColor = .systemYellow
        view.addSubview(compressButton)
    
        compressedSizeLabel.text = "Tamanho comprimido: \(0) bytes"
        compressedSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(compressedSizeLabel)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 450),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            uncompressedSizeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uncompressedSizeLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 50), // Adjusted for spacing
            compressButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            compressButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 20),
            compressedSizeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            compressedSizeLabel.topAnchor.constraint(equalTo: compressButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func playVideo() {
        guard isCompressed == true else {
            player.play()
            return
        }
        
        playerItem = AVPlayerItem(url: destinationURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        
        player.play()
    }
    
    @objc func pauseVideo() {
        guard isCompressed == true else {
            player.pause()
            return
        }
        
        playerItem = AVPlayerItem(url: destinationURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        
        player.pause()
    }
    
    @objc func startCompression() {
        // Definindo a URL de destino
        destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")

        // Chamando a função para comprimir o arquivo
        compressVideo(source: fileURL, destination: destinationURL) { result in
            switch result {
            case .onStart:
                print("Compressão iniciada")
            case .onSuccess(let url):
                self.isCompressed = true
                
                let asset = AVURLAsset(url: url)
                
                DispatchQueue.main.async {
                    self.compressedSizeLabel.text = "Tamanho comprimido: \(Double(asset.fileSize ?? 0) / (1024*1024)) megabytes"
                }
                
                print("Compressão sucedida, arquivo salvo em: \(url.path)")
            case .onFailure(let error):
                self.compressedSizeLabel.text = "Falha na compressão"
                print("Compressão falhou, erro: \(error.description)")
            }
        }
    }
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}


