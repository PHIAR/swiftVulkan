import vulkan
import Dispatch
import Foundation

open class VulkanVisualLayer {
    private let device: VulkanDevice
    private let deviceQueue: VulkanQueue
    private let queueFamilyIndex: Int
    private let surface: VulkanSurface
    private let swapchain: VulkanSwapchain
    private let swapchainImages: [VulkanImage]
    private var swapchainIndex = 0
    private let renderFinishedSemaphores: [VulkanSemaphore]
    private let imageAvailableSemaphores: [VulkanSemaphore]
    private let frameFences: [VulkanFence]

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
        var renderFinishedSemaphores: [VulkanSemaphore] = []
        var imageAvailableSemaphores: [VulkanSemaphore] = []
        var frameFences: [VulkanFence] = []

        (0..<swapchainImageCount).forEach { _ in
            renderFinishedSemaphores.append(device.createSemaphore())
            imageAvailableSemaphores.append(device.createSemaphore())
            frameFences.append(device.createFence())
        }

        self.device = device
        self.deviceQueue = deviceQueue
        self.queueFamilyIndex = queueFamilyIndex
        self.surface = surface
        self.swapchain = swapchain
        self.swapchainImages = swapchainImages
        self.renderFinishedSemaphores = renderFinishedSemaphores
        self.imageAvailableSemaphores = imageAvailableSemaphores
        self.frameFences = frameFences
    }

    public func getNextSwapchainImageIndex() -> Int {
        dispatchPrecondition(condition: .onQueue(.main))

        let swapchainIndex = self.swapchainIndex

        self.swapchainIndex += 1
        return swapchainIndex
    }

    public func present(index: Int) {
        dispatchPrecondition(condition: .onQueue(.main))
    }
}
