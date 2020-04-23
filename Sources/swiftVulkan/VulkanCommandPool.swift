import vulkan
import Foundation

public final class VulkanCommandPool {
    private let device: VulkanDevice
    private let commandPool: VkCommandPool

    public init(device: VulkanDevice,
                commandPool: VkCommandPool) {
        self.device = device
        self.commandPool = commandPool
    }

    deinit {
        vkDestroyCommandPool(self.device.getDevice(), self.commandPool, nil)
    }

    public func allocateCommandBuffers(count: Int) -> [VulkanCommandBuffer] {
        var commandBufferAllocInfo = VkCommandBufferAllocateInfo()

        commandBufferAllocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
        commandBufferAllocInfo.commandPool = self.commandPool
        commandBufferAllocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
        commandBufferAllocInfo.commandBufferCount = UInt32(count)

        var commandBuffers: [VkCommandBuffer?] = Array(repeating: nil,
                                                       count: count)

        commandBuffers.withUnsafeMutableBytes {
            guard vkAllocateCommandBuffers(self.device.getDevice(),
                                           &commandBufferAllocInfo,
                                           $0.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return commandBuffers.map { VulkanCommandBuffer(device: self.device,
                                                        commandBuffer: $0!) }
    }
}
