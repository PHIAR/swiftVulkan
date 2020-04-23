import vulkan
import Foundation

public final class VulkanPipelineCache {
    private let device: VkDevice
    private let pipelineCache: VkPipelineCache

    public init(device: VkDevice,
                pipelineCache: VkPipelineCache) {
        self.device = device
        self.pipelineCache = pipelineCache
    }

    deinit {
        vkDestroyPipelineCache(self.device, self.pipelineCache, nil)
    }

    public func getPipelineCache() -> VkPipelineCache {
        return self.pipelineCache
    }
}
