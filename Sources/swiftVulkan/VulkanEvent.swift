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

    public func getEventStatus() -> Bool {
        return vkGetEventStatus(self.device, self.event) == VK_EVENT_SET
    }

    public func getEvent() -> VkEvent {
        return self.event
    }

    public func resetEvent() {
        vkResetEvent(self.device, self.event)
    }

    public func setEvent() {
        vkSetEvent(self.device, self.event)
    }
}
