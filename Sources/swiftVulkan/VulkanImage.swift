import vulkan
import Foundation

public final class VulkanImage {
    private let device: VkDevice
    private let image: VkImage

    public init(device: VkDevice,
                image: VkImage) {
        self.device = device
        self.image = image
    }

    deinit {
        vkDestroyImage(self.device, self.image, nil)
    }

    public func bindImageMemory(deviceMemory: VulkanDeviceMemory,
                                offset: Int) {
        guard vkBindImageMemory(self.device,
                                self.image,
                                deviceMemory.getDeviceMemory(),
                                VkDeviceSize(offset)) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func getImage() -> VkImage {
        return self.image
    }

    public func getImageMemoryRequirements() -> VkMemoryRequirements {
        var memoryRequirements = VkMemoryRequirements()

        vkGetImageMemoryRequirements(self.device,
                                     self.image,
                                     &memoryRequirements)
        return memoryRequirements
    }
}
