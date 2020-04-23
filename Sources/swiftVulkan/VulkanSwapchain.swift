import vulkan
import Foundation

public final class VulkanSwapchain {
    private let device: VkDevice
    private let swapchain: VkSwapchainKHR

    public init(device: VkDevice,
                swapchain: VkSwapchainKHR) {
        self.device = device
        self.swapchain = swapchain
    }

    deinit {
        vkDestroySwapchainKHR(self.device, self.swapchain, nil)
    }

    public func acquireNextImage(timeout: UInt64,
                                 semaphore: VulkanSemaphore? = nil,
                                 fence: VulkanFence? = nil) -> Int {
        let _semaphore = semaphore?.getSemaphore()
        let _fence = fence?.getFence()
        var imageIndex = UInt32(0)

        guard vkAcquireNextImageKHR(self.device, self.swapchain, timeout, _semaphore, _fence, &imageIndex) == VK_SUCCESS else {
            preconditionFailure()
        }

        return Int(imageIndex)
    }

    public func getImages() -> [VulkanImage] {
        var imageCount = UInt32(0)

        guard vkGetSwapchainImagesKHR(self.device, self.swapchain, &imageCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var images: [VkImage?] = Array(repeating: nil,
                                       count: Int(imageCount))

        images.withUnsafeMutableBytes {
            guard vkGetSwapchainImagesKHR(self.device,
                                          self.swapchain,
                                          &imageCount,
                                          $0.baseAddress!.assumingMemoryBound(to: VkImage?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return images.map { VulkanImage(device: self.device,
                                        image: $0!) }
    }

    public func getSwapchain() -> VkSwapchainKHR {
        return self.swapchain
    }
}
