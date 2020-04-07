import vulkan

public class VulkanBufferMemoryBarrier: VulkanMemoryBarrier {
    public var srcQueueFamilyIndex: UInt32
    public var dstQueueFamilyIndex: UInt32
    public var buffer: VkBuffer
    public var offset: VkDeviceSize
    public var size: VkDeviceSize

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                srcQueueFamilyIndex: UInt32,
                dstQueueFamilyIndex: UInt32,
                buffer: VkBuffer,
                offset: VkDeviceSize,
                size: VkDeviceSize) {
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.buffer = buffer
        self.offset = offset
        self.size = size
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getBufferMemoryBarrier() -> VkBufferMemoryBarrier {
        var bufferMemoryBarrier = VkBufferMemoryBarrier()

        bufferMemoryBarrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
        bufferMemoryBarrier.srcAccessMask = self.srcAccessMask
        bufferMemoryBarrier.dstAccessMask = self.dstAccessMask
        bufferMemoryBarrier.srcQueueFamilyIndex = self.srcQueueFamilyIndex
        bufferMemoryBarrier.dstQueueFamilyIndex = self.dstQueueFamilyIndex
        bufferMemoryBarrier.buffer = self.buffer
        bufferMemoryBarrier.offset = self.offset
        bufferMemoryBarrier.size = self.size
        return bufferMemoryBarrier
    }
}

public final class VulkanCommandBuffer {
    private let device: VkDevice
    private let commandBuffer: VkCommandBuffer

    public init(device: VkDevice,
                commandBuffer: VkCommandBuffer) {
        self.device = device
        self.commandBuffer = commandBuffer
    }

    public func begin(flags: VkCommandBufferUsageFlags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT.rawValue) {
        var beginInfo = VkCommandBufferBeginInfo()

        beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        beginInfo.flags = flags

        guard vkBeginCommandBuffer(self.commandBuffer, &beginInfo) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func clearColor(image: VulkanImage,
                           imageLayout: VkImageLayout,
                           color: VkClearColorValue,
                           ranges: [VkImageSubresourceRange]) {
        ranges.withUnsafeBytes { _ranges in
            let _image = image.getImage()
            var _color = color

            vkCmdClearColorImage(self.commandBuffer,
                                 _image,
                                 imageLayout,
                                 &_color,
                                 UInt32(ranges.count),
                                 _ranges.baseAddress!.assumingMemoryBound(to: VkImageSubresourceRange.self))
        }
    }

    public func end() {
        guard vkEndCommandBuffer(self.commandBuffer) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func getCommandBuffer() -> VkCommandBuffer {
        return self.commandBuffer
    }

    public func pipelineBarrier(srcStageMask: VkPipelineStageFlags,
                                dstStageMask: VkPipelineStageFlags,
                                dependencyFlags: VkDependencyFlags,
                                memoryBarriers: [VulkanMemoryBarrier],
                                bufferMemoryBarriers: [VulkanBufferMemoryBarrier],
                                imageMemoryBarriers: [VulkanImageMemoryBarrier]) {
        let pipelineMemoryBarriers = memoryBarriers.map { $0.getMemoryBarrier() }
        let pipelineBufferMemoryBarriers = bufferMemoryBarriers.map { $0.getBufferMemoryBarrier() }
        let pipelineImageMemoryBarriers = imageMemoryBarriers.map { $0.getImageMemoryBarrier() }
        let _ = pipelineMemoryBarriers.withUnsafeBytes { _memoryBarriers in
            let _ = pipelineBufferMemoryBarriers.withUnsafeBytes { _bufferMemoryBarriers in
                let _ = pipelineImageMemoryBarriers.withUnsafeBytes { _imageMemoryBarriers in
                    vkCmdPipelineBarrier(self.commandBuffer,
                                         srcStageMask,
                                         dstStageMask,
                                         dependencyFlags,
                                         UInt32(memoryBarriers.count),
                                         _memoryBarriers.baseAddress!.assumingMemoryBound(to: VkMemoryBarrier.self),
                                         UInt32(bufferMemoryBarriers.count),
                                         _bufferMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkBufferMemoryBarrier.self),
                                         UInt32(imageMemoryBarriers.count),
                                         _imageMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkImageMemoryBarrier.self))
                }
            }
        }
    }
}

public final class VulkanCommandPool {
    private let device: VkDevice
    private let commandPool: VkCommandPool

    public init(device: VkDevice,
                commandPool: VkCommandPool) {
        self.device = device
        self.commandPool = commandPool
    }

    deinit {
        vkDestroyCommandPool(self.device, self.commandPool, nil)
    }

    public func allocateCommandBuffers(count: Int) -> [VulkanCommandBuffer] {
        var commandBufferAllocInfo = VkCommandBufferAllocateInfo()

        commandBufferAllocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
        commandBufferAllocInfo.commandPool = self.commandPool
        commandBufferAllocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
        commandBufferAllocInfo.commandBufferCount = UInt32(count)

        var commandBuffers: [VkCommandBuffer?] = Array(repeating: nil,
                                                       count: count)

        commandBuffers.withUnsafeMutableBytes {
            guard vkAllocateCommandBuffers(self.device, &commandBufferAllocInfo, $0.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return commandBuffers.map { VulkanCommandBuffer(device: self.device,
                                                        commandBuffer: $0!) }
    }
}

public final class VulkanDevice {
    private let device: VkDevice

    public init(device: VkDevice) {
        self.device = device
    }

    deinit {
        vkDestroyDevice(self.device, nil)
    }

    public func createCommandPool(queue: Int) -> VulkanCommandPool {
        var commandPoolCreateInfo = VkCommandPoolCreateInfo()

        commandPoolCreateInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        commandPoolCreateInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue
        commandPoolCreateInfo.queueFamilyIndex = UInt32(queue)

        var commandPool: VkCommandPool? = nil

        guard vkCreateCommandPool(self.device, &commandPoolCreateInfo, nil, &commandPool) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanCommandPool(device: self.device,
                                 commandPool: commandPool!)
    }

    public func createFence(flags: VkFenceCreateFlags = VK_FENCE_CREATE_SIGNALED_BIT.rawValue) -> VulkanFence {
        var fenceCreateInfo = VkFenceCreateInfo()

        fenceCreateInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
        fenceCreateInfo.flags = flags

        var fence: VkFence? = nil

        guard vkCreateFence(self.device, &fenceCreateInfo, nil, &fence) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanFence(device: device,
                           fence: fence!)
    }

    public func createSemaphore() -> VulkanSemaphore {
        var semaphoreCreateInfo = VkSemaphoreCreateInfo()

        semaphoreCreateInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO

        var semaphore: VkSemaphore? = nil

        guard vkCreateSemaphore(self.device, &semaphoreCreateInfo, nil, &semaphore) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSemaphore(device: device,
                               semaphore: semaphore!)
    }

    public func createSwapchain(surface: VkSurfaceKHR,
                                surfaceFormat: VkSurfaceFormatKHR,
                                surfaceCapabilities: VkSurfaceCapabilitiesKHR,
                                presentMode: VkPresentModeKHR) -> VulkanSwapchain {
        let swapchainImageCount = surfaceCapabilities.maxImageCount
        let swapchainExtent = surfaceCapabilities.currentExtent
        let swapchainImageFormat = (surfaceFormat.format == VK_FORMAT_UNDEFINED) ? VK_FORMAT_B8G8R8A8_UNORM :
                                                                                   surfaceFormat.format
        var swapchainCreateInfo = VkSwapchainCreateInfoKHR()

        swapchainCreateInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCreateInfo.surface = surface
        swapchainCreateInfo.minImageCount = swapchainImageCount
        swapchainCreateInfo.imageFormat = swapchainImageFormat
        swapchainCreateInfo.imageColorSpace = surfaceFormat.colorSpace
        swapchainCreateInfo.imageExtent = swapchainExtent
        swapchainCreateInfo.imageArrayLayers = 1
        swapchainCreateInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue |
                                         VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue
        swapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
        swapchainCreateInfo.preTransform = surfaceCapabilities.currentTransform
        swapchainCreateInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        swapchainCreateInfo.presentMode = presentMode
        swapchainCreateInfo.clipped = VkBool32(VK_TRUE)

        var swapchain: VkSwapchainKHR? = nil

        guard vkCreateSwapchainKHR(self.device, &swapchainCreateInfo, nil, &swapchain) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSwapchain(device: self.device,
                               swapchain: swapchain!)
    }

    public func resetFences(fences: [VulkanFence]) {
        let resetFences = fences.map { $0.getFence() }

        resetFences.withUnsafeBytes { _fences in
            guard vkResetFences(self.device,
                                UInt32(fences.count),
                                _fences.baseAddress!.assumingMemoryBound(to: VkFence?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }
    }

    public func waitIdle() {
        guard vkDeviceWaitIdle(self.device) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func waitForFences(fences: [VulkanFence],
                              waitAll: Bool = true,
                              timeout: UInt64 = .max) {
        let waitFences = fences.map { $0.getFence() }

        waitFences.withUnsafeBytes { _fences in
            guard vkWaitForFences(self.device,
                                  UInt32(fences.count),
                                  _fences.baseAddress!.assumingMemoryBound(to: VkFence?.self),
                                  VkBool32(waitAll ? VK_TRUE : VK_FALSE),
                                  timeout) == VK_SUCCESS else {
                preconditionFailure()
            }

        }
    }
}

public final class VulkanFence {
    private let device: VkDevice
    private let fence: VkFence

    public init(device: VkDevice,
                fence: VkFence) {
        self.device = device
        self.fence = fence
    }

    deinit {
        vkDestroyFence(self.device, self.fence, nil)
    }

    public func getFence() -> VkFence {
        return self.fence
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

    public func getImage() -> VkImage {
        return self.image
    }
}

public class VulkanImageMemoryBarrier: VulkanMemoryBarrier {
    public var oldLayout: VkImageLayout
    public var newLayout: VkImageLayout
    public var srcQueueFamilyIndex: UInt32
    public var dstQueueFamilyIndex: UInt32
    public var image: VulkanImage
    public var subresourceRange: VkImageSubresourceRange

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                oldLayout: VkImageLayout,
                newLayout: VkImageLayout,
                srcQueueFamilyIndex: UInt32,
                dstQueueFamilyIndex: UInt32,
                image: VulkanImage,
                subresourceRange: VkImageSubresourceRange) {
        self.oldLayout = oldLayout
        self.newLayout = newLayout
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.image = image
        self.subresourceRange = subresourceRange
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getImageMemoryBarrier() -> VkImageMemoryBarrier {
        var imageMemoryBarrier = VkImageMemoryBarrier()

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
        imageMemoryBarrier.srcAccessMask = self.srcAccessMask
        imageMemoryBarrier.dstAccessMask = self.dstAccessMask
        imageMemoryBarrier.oldLayout = self.oldLayout
        imageMemoryBarrier.newLayout = self.newLayout
        imageMemoryBarrier.srcQueueFamilyIndex = self.srcQueueFamilyIndex
        imageMemoryBarrier.dstQueueFamilyIndex = self.dstQueueFamilyIndex
        imageMemoryBarrier.image = self.image.getImage()
        imageMemoryBarrier.subresourceRange = self.subresourceRange
        return imageMemoryBarrier
    }
}

public final class VulkanInstance {
    private let instance: VkInstance

    public init(instance: VkInstance) {
        self.instance = instance
    }

    public func getPhysicalDevices() -> [VulkanPhysicalDevice] {
        var physicalDeviceCount = UInt32(0)

        guard vkEnumeratePhysicalDevices(instance, &physicalDeviceCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var physicalDevices: [VkPhysicalDevice?] = Array(repeating: nil,
                                                         count: Int(physicalDeviceCount))

        physicalDevices.withUnsafeMutableBytes {
           guard vkEnumeratePhysicalDevices(instance,
                                            &physicalDeviceCount,
                                            $0.baseAddress!.assumingMemoryBound(to: VkPhysicalDevice?.self)) == VK_SUCCESS else {
               preconditionFailure()
           }
        }

        return physicalDevices.map { VulkanPhysicalDevice(physicalDevice: $0!) }
    }
}

public class VulkanMemoryBarrier {
    public var srcAccessMask: VkAccessFlags
    public var dstAccessMask: VkAccessFlags

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags) {
        self.srcAccessMask = srcAccessMask
        self.dstAccessMask = dstAccessMask
    }

    public func getMemoryBarrier() -> VkMemoryBarrier {
        var memoryBarrier = VkMemoryBarrier()

        memoryBarrier.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER
        memoryBarrier.srcAccessMask = self.srcAccessMask
        memoryBarrier.dstAccessMask = self.dstAccessMask
        return memoryBarrier
    }
}

public final class VulkanQueue {
    private let queue: VkQueue

    public init(queue: VkQueue) {
        self.queue = queue
    }

    public func present(semaphores: [VulkanSemaphore],
                        swapchains: [VulkanSwapchain],
                        imageIndices: [Int]) {
        let waitSemaphores = semaphores.map { $0.getSemaphore() }
        let presentSwapchains = swapchains.map { $0.getSwapchain() }
        let _imageIndices = imageIndices.map { UInt32($0) }
        let _ = waitSemaphores.withUnsafeBytes { _semaphores in
            let _ = presentSwapchains.withUnsafeBytes { _swapchains in
                let _ = _imageIndices.withUnsafeBytes {
                    var presentInfo = VkPresentInfoKHR()

                    presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
                    presentInfo.waitSemaphoreCount = UInt32(semaphores.count)
                    presentInfo.pWaitSemaphores = _semaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)
                    presentInfo.swapchainCount = UInt32(presentSwapchains.count)
                    presentInfo.pSwapchains = _swapchains.baseAddress!.assumingMemoryBound(to: VkSwapchainKHR?.self)
                    presentInfo.pImageIndices = $0.baseAddress!.assumingMemoryBound(to: UInt32.self)

                    guard vkQueuePresentKHR(self.queue, &presentInfo) == VK_SUCCESS else {
                        preconditionFailure()
                    }
                }
            }
        }
    }

    public func submit(waitSemaphores: [VulkanSemaphore],
                       commandBuffers: [VulkanCommandBuffer],
                       signalSemaphores: [VulkanSemaphore],
                       waitDstStageMask: [VkPipelineStageFlags],
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

public final class VulkanPhysicalDevice {
    private let physicalDevice: VkPhysicalDevice

    internal init(physicalDevice: VkPhysicalDevice) {
        self.physicalDevice = physicalDevice
    }

    public func createDevice(queues: [Int],
                             layerNames: [String],
                             extensions: [String]) -> VulkanDevice {
        let queuePriorities = Array(repeating: Float(1.0),
                                    count: queues.count)

        return queuePriorities.withUnsafeBytes { _queuePriorities in
            let queueCreateInfos: [VkDeviceQueueCreateInfo] = queues.map {
                var queueCreateInfo = VkDeviceQueueCreateInfo()

                queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                queueCreateInfo.queueFamilyIndex = UInt32($0)
                queueCreateInfo.queueCount = UInt32(queuePriorities.count)
                queueCreateInfo.pQueuePriorities = _queuePriorities.baseAddress!.assumingMemoryBound(to: Float.self)
                return queueCreateInfo
            }

            let enabledLayerNames = layerNames.map { UnsafePointer(strdup($0.withCString { $0 })) }
            let enabledExtensionNames = extensions.map { UnsafePointer(strdup($0.withCString { $0 })) }
            let device: VulkanDevice = { (queueCreateInfos: UnsafePointer <VkDeviceQueueCreateInfo>,
                                          enabledLayerNames: UnsafePointer <UnsafePointer <CChar>?>,
                                          enabledExtensionNames: UnsafePointer <UnsafePointer <CChar>?>) in
                var deviceCreateInfo = VkDeviceCreateInfo()

                deviceCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
                deviceCreateInfo.queueCreateInfoCount = UInt32(queues.count)
                deviceCreateInfo.pQueueCreateInfos = queueCreateInfos
                deviceCreateInfo.enabledLayerCount = UInt32(layerNames.count)
                deviceCreateInfo.ppEnabledLayerNames = enabledLayerNames
                deviceCreateInfo.enabledExtensionCount = UInt32(extensions.count)
                deviceCreateInfo.ppEnabledExtensionNames = enabledExtensionNames

                var device: VkDevice? = nil

                guard vkCreateDevice(self.physicalDevice, &deviceCreateInfo, nil, &device) == VK_SUCCESS else {
                    preconditionFailure()
                }

                return VulkanDevice(device: device!)
            }(queueCreateInfos,
              enabledLayerNames,
              enabledExtensionNames)

            enabledLayerNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            enabledExtensionNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            return device
        }
    }

    public func getQueueFamilyProperties() -> [VkQueueFamilyProperties] {
        var queueFamilyPropertiesCount = UInt32(0)

        vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevice, &queueFamilyPropertiesCount, nil)

        var queueFamilyProperties = Array(repeating: VkQueueFamilyProperties(),
                                          count: Int(queueFamilyPropertiesCount))

        queueFamilyProperties.withUnsafeMutableBytes {
            vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevice,
                                                     &queueFamilyPropertiesCount,
                                                     $0.baseAddress!.assumingMemoryBound(to: VkQueueFamilyProperties.self))
        }

        return queueFamilyProperties
    }

    public func getSurfaceCapabilities(surface: VkSurfaceKHR) -> VkSurfaceCapabilitiesKHR {
        var surfaceCapabilities = VkSurfaceCapabilitiesKHR()

        guard vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.physicalDevice, surface, &surfaceCapabilities) == VK_SUCCESS else {
            preconditionFailure()
        }

        return surfaceCapabilities
    }

    public func getSurfaceFormats(surface: VkSurfaceKHR) -> [VkSurfaceFormatKHR] {
        var surfaceFormatsCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice, surface, &surfaceFormatsCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var surfaceFormats = Array(repeating: VkSurfaceFormatKHR(),
                                   count: Int(surfaceFormatsCount))

        surfaceFormats.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice,
                                                       surface,
                                                       &surfaceFormatsCount,
                                                       $0.baseAddress!.assumingMemoryBound(to: VkSurfaceFormatKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return surfaceFormats
    }

    public func getSurfacePresentModes(surface: VkSurfaceKHR) -> [VkPresentModeKHR] {
        var presentModeCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice, surface, &presentModeCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var presentModes = Array(repeating: VkPresentModeKHR(0),
                                 count: Int(presentModeCount))

        presentModes.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice,
                                                            surface,
                                                            &presentModeCount,
                                                            $0.baseAddress!.assumingMemoryBound(to: VkPresentModeKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return presentModes
    }

    public func isSurfaceSupported(surface: VkSurfaceKHR,
                                   onQueue queueIndex: Int) -> Bool {
        var supportsPresent = VkBool32(VK_FALSE)

        guard vkGetPhysicalDeviceSurfaceSupportKHR(self.physicalDevice, UInt32(queueIndex), surface, &supportsPresent) == VK_SUCCESS else {
            preconditionFailure()
        }

        return supportsPresent == VK_TRUE
    }
}

public final class VulkanSemaphore {
    private let device: VkDevice
    private let semaphore: VkSemaphore

    public init(device: VkDevice,
                semaphore: VkSemaphore) {
        self.device = device
        self.semaphore = semaphore
    }

    deinit {
        vkDestroySemaphore(self.device, self.semaphore, nil)
    }

    public func getSemaphore() -> VkSemaphore {
        return self.semaphore
    }
}

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
