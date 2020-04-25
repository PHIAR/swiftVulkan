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

        vkGetSemaphoreCounterValue(self.device, self.semaphore, &counterValue)
        return counterValue
    }

    public func getSemaphore() -> VkSemaphore {
        return self.semaphore
    }

    public func signal(value: UInt64) {
        var signalInfo = VkSemaphoreSignalInfo()

        signalInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO
        signalInfo.semaphore = self.semaphore
        signalInfo.value = value
        vkSignalSemaphore(self.device, &signalInfo)
    }
}
