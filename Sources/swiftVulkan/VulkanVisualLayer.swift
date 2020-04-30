import vulkan
import Dispatch
import Foundation

open class VulkanVisualView {
    private let device: VulkanDevice
    private let deviceQueue: VulkanQueue
    private let queueFamilyIndex: Int
    private let surface: VulkanSurface
    private let swapchain: VulkanSwapchain
    private let swapchainImages: [VulkanImage]
    private var swapchainIndex = 0

    public init(device: VulkanDevice,
                queueFamilyIndex: Int,
                queueIndex: Int,
                surface: VulkanSurface,
                swapchainImageCount: Int = 2) {
        let deviceQueue = device.getDeviceQueue(queueFamily: queueFamilyIndex,
                                                queue: queueIndex)
        let physicalDevice = device.getPhysicalDevice()
        let surfaceFormat = physicalDevice.getSurfaceFormats(surface: surface)[0]
        let surfaceCapabilities = physicalDevice.getSurfaceCapabilities(surface: surface)
        let swapchainImageCount = min(swapchainImageCount, Int(surfaceCapabilities.minImageCount))
        let presentMode = physicalDevice.getSurfacePresentModes(surface: surface)[0]
        let swapchain = device.createSwapchain(surface: surface,
                                               surfaceFormat: surfaceFormat,
                                               surfaceCapabilities: surfaceCapabilities,
                                               swapchainImageCount: swapchainImageCount,
                                               presentMode: presentMode)
        let swapchainImages = swapchain.getImages()

        self.device = device
        self.deviceQueue = deviceQueue
        self.queueFamilyIndex = queueFamilyIndex
        self.surface = surface
        self.swapchain = swapchain
        self.swapchainImages = swapchainImages
    }
}
