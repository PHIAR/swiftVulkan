import vulkan
import Foundation

public final class VulkanDeviceMemory {
    private let device: VkDevice
    private let deviceMemory: VkDeviceMemory

    public init(device: VkDevice,
                deviceMemory: VkDeviceMemory) {
        self.device = device
        self.deviceMemory = deviceMemory
    }

    deinit {
        vkFreeMemory(self.device, self.deviceMemory, nil)
    }

    public func getDeviceMemory() -> VkDeviceMemory {
        return self.deviceMemory
    }

    public func map(offset: Int = 0,
                    size: Int = 0) -> UnsafeMutableRawPointer {
        var pointer: UnsafeMutableRawPointer? = nil

        guard vkMapMemory(self.device,
                          self.deviceMemory,
                          VkDeviceSize(offset),
                          (size == 0) ? VK_WHOLE_SIZE : VkDeviceSize(size),
                          0,
                          &pointer) == VK_SUCCESS else {
            preconditionFailure()
        }

        return pointer!
    }

    public func unmap() {
        vkUnmapMemory(self.device, self.deviceMemory)
    }
}
