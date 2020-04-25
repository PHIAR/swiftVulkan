import vulkan
import Foundation

public final class VulkanSemaphore {
    private let device: VkDevice
    private let semaphore: VkSemaphore

    public init(device: VkDevice,
                semaphore: VkSemaphore) {
        self.device = device
        self.semaphore = semaphore
    }

    deinit {
        vkDestroySemaphore(self.device, self.semaphore, nil)
    }

    public getCounterValue() -> UInt64 {
        var counterValue = UInt64(0)

        vkGetSemaphoreCounterValue(self.device, self.semaphore, &counterValue)
    }

    public func getSemaphore() -> VkSemaphore {
        return self.semaphore
    }
}
