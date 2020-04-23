import vulkan
import Foundation

public final class VulkanDescriptorPool {
    private let device: VkDevice
    private let descriptorPool: VkDescriptorPool

    public init(device: VkDevice,
                descriptorPool: VkDescriptorPool) {
        self.device = device
        self.descriptorPool = descriptorPool
    }

    deinit {
        vkDestroyDescriptorPool(self.device, self.descriptorPool, nil)
    }

    public func getDescriptorPool() -> VkDescriptorPool {
        return self.descriptorPool
    }
}
