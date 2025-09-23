import Foundation
import Combine
import SwiftUI

@MainActor
final class ModelManager: ObservableObject {
    enum LoadState {
        case idle
        case loading
        case loaded(ModelInfo)
        case failed(String)
    }

    struct ModelInfo: Codable, Hashable {
        let architectures: [String]?
        let modelType: String?
        let hiddenSize: Int?
        let vocabSize: Int?
        let quantization: QuantizationInfo?

        enum CodingKeys: String, CodingKey {
            case architectures
            case modelType = "model_type"
            case hiddenSize = "hidden_size"
            case vocabSize = "vocab_size"
            case quantization
        }
    }

    struct QuantizationInfo: Codable, Hashable {
        let groupSize: Int?
        let bits: Int?

        enum CodingKeys: String, CodingKey {
            case groupSize = "group_size"
            case bits
        }
    }

    @Published private(set) var state: LoadState = .idle

    private let modelURL: URL

    init(modelDirectory: URL = ModelManager.defaultModelDirectory) {
        self.modelURL = modelDirectory
    }

    static var defaultModelDirectory: URL {
        URL(fileURLWithPath: "/Users/abhijeetanand/.lmstudio/models/lmstudio-community/DeepSeek-R1-0528-Qwen3-8B-MLX-4bit", isDirectory: true)
    }

    func loadModelMetadata() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            let configURL = modelURL.appendingPathComponent("config.json")
            let data = try Data(contentsOf: configURL)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let info = try decoder.decode(ModelInfo.self, from: data)
            state = .loaded(info)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func readableModelName() -> String {
        modelURL.lastPathComponent.replacingOccurrences(of: "-", with: " ")
    }

    func metadataSummary() -> String {
        switch state {
        case .loaded(let info):
            var components: [String] = []
            if let architecture = info.architectures?.first {
                components.append(architecture)
            } else if let type = info.modelType {
                components.append(type)
            }
            if let hiddenSize = info.hiddenSize {
                components.append("Hidden Size \(hiddenSize)")
            }
            if let vocab = info.vocabSize {
                components.append("Vocab \(vocab)")
            }
            if let bits = info.quantization?.bits {
                components.append("Quantized \(bits)-bit")
            }
            return components.isEmpty ? "Metadata loaded." : components.joined(separator: "  •  ")
        case .failed(let message):
            return "Failed to read metadata: \(message)"
        case .loading:
            return "Loading model metadata…"
        case .idle:
            return "Model metadata not loaded yet."
        }
    }

    func generateResponse(for prompt: String) async -> String {
        let info: String
        switch state {
        case .loaded(let infoValue):
            let architecture = infoValue.architectures?.first ?? infoValue.modelType ?? "Model"
            let bits = infoValue.quantization?.bits.map { "\($0)-bit" } ?? ""
            info = [architecture, bits].filter { !$0.isEmpty }.joined(separator: " • ")
        case .failed(let message):
            info = "Metadata unavailable (\(message))"
        case .loading:
            info = "Loading model"
        case .idle:
            info = readableModelName()
        }

        try? await Task.sleep(nanoseconds: 350_000_000)

        return "\(info) placeholder response:\n\n\(prompt)"
    }
}
