import vulkan
import Foundation

public final class VulkanPipelineLayout {
    private let device: VkDevice
    private let pipelineLayout: VkPipelineLayout

    public init(device: VkDevice,
                pipelineLayout: VkPipelineLayout) {
        self.device = device
        self.pipelineLayout = pipelineLayout
    }

    deinit {
        vkDestroyPipelineLayout(self.device, self.pipelineLayout, nil)
    }

    public func getPipelineLayout() -> VkPipelineLayout {
        return self.pipelineLayout
    }
}
