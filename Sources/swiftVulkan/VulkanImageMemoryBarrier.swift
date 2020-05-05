import vulkan
import Foundation

public final class VulkanImageMemoryBarrier: VulkanMemoryBarrier {
    public var oldLayout: VkImageLayout
    public var newLayout: VkImageLayout
    public var srcQueueFamilyIndex: Int
    public var dstQueueFamilyIndex: Int
    public var image: VulkanImage
    public var subresourceRange: VkImageSubresourceRange

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                oldLayout: VulkanImageLayout,
                newLayout: VulkanImageLayout,
                srcQueueFamilyIndex: Int,
                dstQueueFamilyIndex: Int,
                image: VulkanImage,
                subresourceRange: VkImageSubresourceRange) {
        self.oldLayout = oldLayout.toVkImageLayout()
        self.newLayout = newLayout.toVkImageLayout()
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.image = image
        self.subresourceRange = subresourceRange
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getImageMemoryBarrier() -> VkImageMemoryBarrier {
        var imageMemoryBarrier = VkImageMemoryBarrier()

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
        imageMemoryBarrier.srcAccessMask = self.srcAccessMask
        imageMemoryBarrier.dstAccessMask = self.dstAccessMask
        imageMemoryBarrier.oldLayout = self.oldLayout
        imageMemoryBarrier.newLayout = self.newLayout
        imageMemoryBarrier.srcQueueFamilyIndex = UInt32(self.srcQueueFamilyIndex)
        imageMemoryBarrier.dstQueueFamilyIndex = UInt32(self.dstQueueFamilyIndex)
        imageMemoryBarrier.image = self.image.getImage()
        imageMemoryBarrier.subresourceRange = self.subresourceRange
        return imageMemoryBarrier
    }
}
