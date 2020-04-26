import vulkan
import Foundation

public enum VulkanFormat {
    case bgra8Unorm

    internal func toVkFormat() -> VkFormat {
        switch self {
        case .bgra8Unorm:
            return VK_FORMAT_B8G8R8A8_UNORM
        }
    }
}

public enum VulkanImageType {
    case type1D
    case type2D
    case type3D

    internal func toVkImageType() -> VkImageType {
        switch self {
        case .type1D:
            return VK_IMAGE_TYPE_1D

        case .type2D:
            return VK_IMAGE_TYPE_2D

        case .type3D:
            return VK_IMAGE_TYPE_3D
        }
    }
}

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
}
