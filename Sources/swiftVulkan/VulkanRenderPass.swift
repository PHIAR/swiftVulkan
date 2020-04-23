import vulkan
import Foundation

public final class VulkanRenderPass {
    private let device: VkDevice
    private let renderPass: VkRenderPass

    public init(device: VkDevice,
                renderPass: VkRenderPass) {
        self.device = device
        self.renderPass = renderPass
    }

    deinit {
        vkDestroyRenderPass(self.device, self.renderPass, nil)
    }

    func getRenderPass() -> VkRenderPass {
        return self.renderPass
    }
}
