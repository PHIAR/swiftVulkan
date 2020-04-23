import vulkan
import Foundation

public final class VulkanFramebuffer {
    private let device: VkDevice
    private let framebuffer: VkFramebuffer

    public init(device: VkDevice,
                framebuffer: VkFramebuffer) {
        self.device = device
        self.framebuffer = framebuffer
    }

    deinit {
        vkDestroyFramebuffer(self.device, self.framebuffer, nil)
    }

    public func getFramebuffer() -> VkFramebuffer {
        return self.framebuffer
    }
}
