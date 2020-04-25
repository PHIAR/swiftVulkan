import vulkan
import Foundation

public final class VulkanQueue {
    private let queue: VkQueue

    public init(queue: VkQueue) {
        self.queue = queue
    }

    public func present(waitSemaphores: [VulkanSemaphore],
                        swapchains: [VulkanSwapchain],
                        imageIndices: [Int]) {
        let semaphores = waitSemaphores.map { $0.getSemaphore() }
        let presentSwapchains = swapchains.map { $0.getSwapchain() }
        let presentImageIndices = imageIndices.map { UInt32($0) }
        let _ = semaphores.withUnsafeBytes { _waitSemaphores in
            let _ = presentSwapchains.withUnsafeBytes { _swapchains in
                let _ = presentImageIndices.withUnsafeBytes { _imageIndices in

                    var presentInfo = VkPresentInfoKHR()

                    presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
                    presentInfo.waitSemaphoreCount = UInt32(waitSemaphores.count)
                    presentInfo.pWaitSemaphores = _waitSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)
                    presentInfo.swapchainCount = UInt32(swapchains.count)
                    presentInfo.pSwapchains = _swapchains.baseAddress!.assumingMemoryBound(to: VkSwapchainKHR?.self)
                    presentInfo.pImageIndices = _imageIndices.baseAddress!.assumingMemoryBound(to: UInt32.self)

                    guard vkQueuePresentKHR(self.queue, &presentInfo) == VK_SUCCESS else {
                        preconditionFailure()
                    }
                }
            }
        }
    }

    public func submit(waitSemaphoresValues: [UInt64] = [],
                       semaphoresValues: [UInt64] = [],
                       waitSemaphores: [VulkanSemaphore],
                       waitDstStageMask: [VkPipelineStageFlags],
                       commandBuffers: [VulkanCommandBuffer],
                       signalSemaphores: [VulkanSemaphore],
                       fence: VulkanFence? = nil) {
        let submitWaitSemaphores = waitSemaphores.map { $0.getSemaphore() }
        let submitCommandBuffers = commandBuffers.map { $0.getCommandBuffer() }
        let submitSignalSemaphores = signalSemaphores.map { $0.getSemaphore() }
        let _ = submitWaitSemaphores.withUnsafeBytes { _waitSemaphores in
            let _ = submitSignalSemaphores.withUnsafeBytes { _signalSemaphores in
                let _ = submitCommandBuffers.withUnsafeBytes { _commandBuffers in
                    let _ = waitDstStageMask.withUnsafeBytes { _waitDstStageMask in
                        var submitInfo = VkSubmitInfo()

                        submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
                        submitInfo.waitSemaphoreCount = UInt32(waitSemaphores.count)
                        submitInfo.pWaitSemaphores = _waitSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)
                        submitInfo.pWaitDstStageMask = _waitDstStageMask.baseAddress!.assumingMemoryBound(to: VkPipelineStageFlags.self)
                        submitInfo.commandBufferCount = UInt32(commandBuffers.count)
                        submitInfo.pCommandBuffers = _commandBuffers.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self)
                        submitInfo.signalSemaphoreCount = UInt32(signalSemaphores.count)
                        submitInfo.pSignalSemaphores = _signalSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)

                        guard vkQueueSubmit(self.queue, 1, &submitInfo, fence?.getFence()) == VK_SUCCESS else {
                            preconditionFailure()
                        }
                    }
                }
            }
        }
    }
}
