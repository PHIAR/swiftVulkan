import vulkan
import Foundation

public final class VulkanBuffer {
    private let device: VkDevice
    private let buffer: VkBuffer

    public init(device: VkDevice,
                buffer: VkBuffer) {
        self.device = device
        self.buffer = buffer
    }

    deinit {
        vkDestroyBuffer(self.device, self.buffer, nil)
    }

    public func bindBufferMemory(deviceMemory: VulkanDeviceMemory,
                                 offset: Int) {
        guard vkBindBufferMemory(self.device,
                                 self.buffer,
                                 deviceMemory.getDeviceMemory(),
                                 VkDeviceSize(offset)) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func getBuffer() -> VkBuffer {
        return self.buffer
    }

    public func getBufferMemoryRequirements() -> VkMemoryRequirements {
        var memoryRequirements = VkMemoryRequirements()

        vkGetBufferMemoryRequirements(self.device, self.buffer, &memoryRequirements)
        return memoryRequirements
    }
}
