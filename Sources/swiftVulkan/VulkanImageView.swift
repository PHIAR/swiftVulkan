import vulkan
import Foundation

public final class VulkanImageView {
    private let device: VkDevice
    private let imageView: VkImageView

    public init(device: VkDevice,
                imageView: VkImageView) {
        self.device = device
        self.imageView = imageView
    }

    deinit {
        vkDestroyImageView(self.device, self.imageView, nil)
    }

    public func getImageView() -> VkImageView {
        return self.imageView
    }
}
