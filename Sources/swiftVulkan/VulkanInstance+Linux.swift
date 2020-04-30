import vulkan
import Foundation

#if !os(Android) && os(Linux)

import vulkan.linux

extension VulkanInstance {
    public func createXcbSurface(connection: OpaquePointer,
                                 window: xcb_window_t) -> VulkanSurface {
        var xcbSurfaceCreateInfo = VkXcbSurfaceCreateInfoKHR()

        xcbSurfaceCreateInfo.sType = VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR
        xcbSurfaceCreateInfo.connection = connection
        xcbSurfaceCreateInfo.window = window

        var surface: VkSurfaceKHR? = nil

        guard vkCreateXcbSurfaceKHR(self.getInstance(), &xcbSurfaceCreateInfo, nil, &surface) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSurface(instance: self.getInstance(),
                             surface: surface!)
    }

    public func createXlibSurface(display: OpaquePointer,
                                  window: Window) -> VulkanSurface {
        var xlibSurfaceCreateInfo = VkXlibSurfaceCreateInfoKHR()

        xlibSurfaceCreateInfo.sType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
        xlibSurfaceCreateInfo.dpy = display
        xlibSurfaceCreateInfo.window = window

        var surface: VkSurfaceKHR? = nil

        guard vkCreateXlibSurfaceKHR(self.getInstance(), &xlibSurfaceCreateInfo, nil, &surface) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSurface(instance: self.getInstance(),
                             surface: surface!)
    }
}

#endif
