import vulkan
import Foundation

public final class VulkanDescriptorSet {
    private let device: VkDevice
    private let descriptorPool: VkDescriptorPool
    private let descriptorSet: VkDescriptorSet

    public init(device: VkDevice,
                descriptorPool: VkDescriptorPool,
                descriptorSet: VkDescriptorSet) {
        self.device = device
        self.descriptorPool = descriptorPool
        self.descriptorSet = descriptorSet
    }

    deinit {
        var descriptorSet: VkDescriptorSet? = self.descriptorSet

        vkFreeDescriptorSets(self.device,
                             self.descriptorPool,
                             1,
                             &descriptorSet)
    }

    public func getDescriptorSet() -> VkDescriptorSet {
        return self.descriptorSet
    }
}
