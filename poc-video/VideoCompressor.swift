import AVFoundation
import UIKit

// Enum para o resultado da compressão
public enum CompressionResult {
    case onStart
    case onSuccess(URL)
    case onFailure(CompressionError)
}

// Struct para erros
public struct CompressionError: Error {
    public let description: String
}
    
public func compressVideo(source: URL, destination: URL, completion: @escaping (CompressionResult) -> ()) -> Void {
    completion(.onStart)

    // Criação do asset, para permitir a manipulação
    let videoAsset = AVURLAsset(url: source)

    // Criando uma exportSession a partir do asset, utilizando um preset LowQuality para diminuir a qualidade do arquivo
    let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)
    exportSession?.outputURL = destination
    exportSession?.outputFileType = .mp4

    // Chamando a função
    exportSession?.exportAsynchronously {
        // Tratativa de erros de acordo com o resultado
        switch exportSession?.status {
        case .completed:
            completion(.onSuccess(destination))
        case .failed:
            let error = CompressionError(description: exportSession?.error?.localizedDescription ?? "Erro desconhecido")
            completion(.onFailure(error))
        default:
            break
        }
    }
}
