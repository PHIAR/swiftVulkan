import vulkan
import Foundation

public final class VulkanPipeline {
    private let device: VkDevice
    private let pipeline: VkPipeline

    public init(device: VkDevice,
                pipeline: VkPipeline) {
        self.device = device
        self.pipeline = pipeline
    }

    deinit {
        vkDestroyPipeline(self.device, self.pipeline, nil)
    }

    public func getPipeline() -> VkPipeline {
        return self.pipeline
    }
}
