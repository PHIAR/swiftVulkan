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

    public func getCounterValue() -> UInt64 {
        var counterValue = UInt64(0)

    #if false
        vkGetSemaphoreCounterValue(self.device, self.semaphore, &counterValue)
    #endif
        return counterValue
    }

    public func getSemaphore() -> VkSemaphore {
        return self.semaphore
    }
}
