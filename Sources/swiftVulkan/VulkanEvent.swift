import vulkan
import Foundation

public final class VulkanEvent {
    private let device: VkDevice
    private let event: VkEvent

    public init(device: VkDevice,
                event: VkEvent) {
        self.device = device
        self.event = event
    }

    deinit {
        vkDestroyEvent(self.device, self.event, nil)
    }

    public func getFence() -> VkEvent {
        return self.event
    }
}
