import vulkan
import Foundation

public final class VulkanSampler {
    private let device: VkDevice
    private let sampler: VkSampler

    public init(device: VkDevice,
                sampler: VkSampler) {
        self.device = device
        self.sampler = sampler
    }

    deinit {
        vkDestroySampler(self.device, self.sampler, nil)
    }

    public func getSampler() -> VkSampler {
        return self.sampler
    }
}