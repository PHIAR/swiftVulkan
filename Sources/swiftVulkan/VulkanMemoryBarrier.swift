import vulkan
import Foundation

public class VulkanMemoryBarrier {
    public var srcAccessMask: VkAccessFlags
    public var dstAccessMask: VkAccessFlags

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags) {
        self.srcAccessMask = srcAccessMask
        self.dstAccessMask = dstAccessMask
    }

    public func getMemoryBarrier() -> VkMemoryBarrier {
        var memoryBarrier = VkMemoryBarrier()

        memoryBarrier.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER
        memoryBarrier.srcAccessMask = self.srcAccessMask
        memoryBarrier.dstAccessMask = self.dstAccessMask
        return memoryBarrier
    }
}
