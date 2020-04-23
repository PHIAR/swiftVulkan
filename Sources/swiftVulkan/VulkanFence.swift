import vulkan
import Foundation

public final class VulkanFence {
    private let device: VkDevice
    private let fence: VkFence

    public init(device: VkDevice,
                fence: VkFence) {
        self.device = device
        self.fence = fence
    }

    deinit {
        vkDestroyFence(self.device, self.fence, nil)
    }

    public func getFence() -> VkFence {
        return self.fence
    }
}
