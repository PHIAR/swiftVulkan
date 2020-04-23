import vulkan
import Foundation

#if os(Android)

import vulkan.android

extension VulkanInstance {
    public func createAndroidSurface(window: OpaquePointer) -> VulkanSurface {
        var androidSurfaceCreateInfo = VkAndroidSurfaceCreateInfoKHR()

        androidSurfaceCreateInfo.sType = VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR
        androidSurfaceCreateInfo.window = window

        var surface: VkSurfaceKHR? = nil

        guard vkCreateAndroidSurfaceKHR(self.getInstance(), &androidSurfaceCreateInfo, nil, &surface) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSurface(instance: self.getInstance(),
                             surface: surface!)
    }
}

#endif
