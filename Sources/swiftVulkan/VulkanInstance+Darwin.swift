import vulkan
import Foundation

#if os(macOS)

extension VulkanInstance {
    public func createMacOSSurface(view: OpaquePointer) -> VulkanSurface {
        var macOSSurfaceCreateInfo = VkMacOSSurfaceCreateInfoMVK()

        macOSSurfaceCreateInfo.sType = VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK
        macOSSurfaceCreateInfo.pView = UnsafeRawPointer(view)

        var surface: VkSurfaceKHR? = nil

        guard vkCreateMacOSSurfaceMVK(self.getInstance(), &macOSSurfaceCreateInfo, nil, &surface) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSurface(instance: self.getInstance(),
                             surface: surface!)
    }
}

#endif
