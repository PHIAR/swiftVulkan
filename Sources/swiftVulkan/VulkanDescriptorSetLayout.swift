import vulkan
import Foundation

public final class VulkanDescriptorSetLayout {
    private let device: VkDevice
    private let descriptorSetLayout: VkDescriptorSetLayout

    public init(device: VkDevice,
                descriptorSetLayout: VkDescriptorSetLayout) {
        self.device = device
        self.descriptorSetLayout = descriptorSetLayout
    }

    deinit {
        vkDestroyDescriptorSetLayout(self.device, self.descriptorSetLayout, nil)
    }

    public func getDescriptorSetLayout() -> VkDescriptorSetLayout {
        return self.descriptorSetLayout
    }
}
