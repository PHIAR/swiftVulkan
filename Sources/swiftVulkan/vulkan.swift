import vulkan

public final class VulkanCommandBuffer {
    private let device: VkDevice
    private let commandBuffer: VkCommandBuffer

    public init(device: VkDevice,
                commandBuffer: VkCommandBuffer) {
        self.device = device
        self.commandBuffer = commandBuffer
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
        let _ = commandBuffers.withUnsafeMutableBytes {
            vkAllocateCommandBuffers(self.device, &commandBufferAllocInfo, $0.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self));
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

        vkCreateCommandPool(self.device, &commandPoolCreateInfo, nil, &commandPool)
        return VulkanCommandPool(device: self.device,
                                 commandPool: commandPool!)
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
}

public final class VulkanInstance {
    private let instance: VkInstance

    public init(instance: VkInstance) {
        self.instance = instance
    }

    public func getPhysicalDevices() -> [VulkanPhysicalDevice] {
        var physicalDeviceCount = UInt32(0)

        vkEnumeratePhysicalDevices(instance, &physicalDeviceCount, nil)

        var physicalDevices: [VkPhysicalDevice?] = Array(repeating: nil,
                                                         count: Int(physicalDeviceCount))
        let _ = physicalDevices.withUnsafeMutableBytes {
           vkEnumeratePhysicalDevices(instance, &physicalDeviceCount, $0.baseAddress!.assumingMemoryBound(to: VkPhysicalDevice?.self))
        }

        return physicalDevices.map { VulkanPhysicalDevice(physicalDevice: $0!) }
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
                    vkQueuePresentKHR(self.queue, &presentInfo)
                }
            }
        }
    }

    public func submit(waitSemaphores: [VulkanSemaphore],
                       commandBuffers: [VulkanCommandBuffer],
                       signalSemaphores: [VulkanSemaphore]) {
        /*let submitWaitSemaphores = waitSemaphores.map { $0.getSemaphore() }
        let submitCommandBuffers = commandBuffers.map { $0.getCommandBuffer() }
        let submitSignalSemaphores = signalSemaphores.map { $0.getSemaphore() }
        let _ = submitWaitSemaphores.withUnsafeBytes { _waitSemaphores in
            let _ = submitSignalSemaphores.withUnsafeBytes { _signalSemaphores in
                let _ = _imageIndices.withUnsafeBytes {*/
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
        let _ = queueFamilyProperties.withUnsafeMutableBytes {
            vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevice, &queueFamilyPropertiesCount, $0.baseAddress!.assumingMemoryBound(to: VkQueueFamilyProperties.self))
        }

        return queueFamilyProperties
    }

    public func getSurfaceCapabilities(surface: VkSurfaceKHR) -> VkSurfaceCapabilitiesKHR {
        var surfaceCapabilities = VkSurfaceCapabilitiesKHR()

        vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.physicalDevice, surface, &surfaceCapabilities)
        return surfaceCapabilities
    }

    public func getSurfaceFormats(surface: VkSurfaceKHR) -> [VkSurfaceFormatKHR] {
        var surfaceFormatsCount = UInt32(0)

        vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice, surface, &surfaceFormatsCount, nil)

        var surfaceFormats = Array(repeating: VkSurfaceFormatKHR(),
                                   count: Int(surfaceFormatsCount))
        let _ = surfaceFormats.withUnsafeMutableBytes {
            vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice, surface, &surfaceFormatsCount, $0.baseAddress!.assumingMemoryBound(to: VkSurfaceFormatKHR.self))
        }

        return surfaceFormats
    }

    public func getSurfacePresentModes(surface: VkSurfaceKHR) -> [VkPresentModeKHR] {
        var presentModeCount = UInt32(0)

        vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice, surface, &presentModeCount, nil)

        var presentModes = Array(repeating: VkPresentModeKHR(0),
                                 count: Int(presentModeCount))
        let _ = presentModes.withUnsafeMutableBytes {
            vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice, surface, &presentModeCount, $0.baseAddress!.assumingMemoryBound(to: VkPresentModeKHR.self))
        }

        return presentModes
    }

    public func isSurfaceSupported(surface: VkSurfaceKHR,
                                   onQueue queueIndex: Int) -> Bool {
        var supportsPresent = VkBool32(VK_FALSE)

        vkGetPhysicalDeviceSurfaceSupportKHR(self.physicalDevice, UInt32(queueIndex), surface, &supportsPresent)
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

    public func getImages() -> [VulkanImage] {
        var imageCount = UInt32(0)

        guard vkGetSwapchainImagesKHR(self.device, self.swapchain, &imageCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var images: [VkImage?] = Array(repeating: nil,
                                       count: Int(imageCount))
        let _ = images.withUnsafeMutableBytes {
            vkGetSwapchainImagesKHR(self.device, self.swapchain, &imageCount, $0.baseAddress!.assumingMemoryBound(to: VkImage?.self))
        }

        return images.map { VulkanImage(device: self.device,
                                        image: $0!) }
    }

    public func getSwapchain() -> VkSwapchainKHR {
        return self.swapchain
    }
}

