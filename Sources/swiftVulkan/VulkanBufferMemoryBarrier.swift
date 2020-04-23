import vulkan
import Foundation

public final class VulkanBufferMemoryBarrier: VulkanMemoryBarrier {
    public var srcQueueFamilyIndex: UInt32
    public var dstQueueFamilyIndex: UInt32
    public var buffer: VkBuffer
    public var offset: VkDeviceSize
    public var size: VkDeviceSize

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                srcQueueFamilyIndex: UInt32,
                dstQueueFamilyIndex: UInt32,
                buffer: VkBuffer,
                offset: VkDeviceSize,
                size: VkDeviceSize) {
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.buffer = buffer
        self.offset = offset
        self.size = size
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getBufferMemoryBarrier() -> VkBufferMemoryBarrier {
        var bufferMemoryBarrier = VkBufferMemoryBarrier()

        bufferMemoryBarrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
        bufferMemoryBarrier.srcAccessMask = self.srcAccessMask
        bufferMemoryBarrier.dstAccessMask = self.dstAccessMask
        bufferMemoryBarrier.srcQueueFamilyIndex = self.srcQueueFamilyIndex
        bufferMemoryBarrier.dstQueueFamilyIndex = self.dstQueueFamilyIndex
        bufferMemoryBarrier.buffer = self.buffer
        bufferMemoryBarrier.offset = self.offset
        bufferMemoryBarrier.size = self.size
        return bufferMemoryBarrier
    }
}
