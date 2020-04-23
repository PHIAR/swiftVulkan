import vulkan
import Foundation

public final class VulkanSurface {
    private let instance: VkInstance
    private let surface: VkSurfaceKHR

    public init(instance: VkInstance,
                surface: VkSurfaceKHR) {
        self.instance = instance
        self.surface = surface
    }

    deinit {
        vkDestroySurfaceKHR(self.instance, self.surface, nil)
    }

    public func getSurface() -> VkSurfaceKHR {
        return self.surface
    }
}
