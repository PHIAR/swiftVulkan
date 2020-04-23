import vulkan
import Foundation

public final class VulkanPhysicalDevice {
    private let instance: VulkanInstance
    private let physicalDevice: VkPhysicalDevice

    internal init(instance: VulkanInstance,
                  physicalDevice: VkPhysicalDevice) {
        self.instance = instance
        self.physicalDevice = physicalDevice
    }

    public func createDevice(queues: [Int],
                             layerNames: [String],
                             extensions: [String]) -> VulkanDevice {
        precondition(!queues.isEmpty)

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

                return VulkanDevice(physicalDevice: self,
                                    device: device!)
            }(queueCreateInfos,
              enabledLayerNames,
              enabledExtensionNames)

            enabledLayerNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            enabledExtensionNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            return device
        }
    }

    public func getInstance() -> VulkanInstance {
        return self.instance
    }

    public func getPhysicalDeviceMemoryProperties() -> VkPhysicalDeviceMemoryProperties {
        var physicalDeviceMemoryProperties = VkPhysicalDeviceMemoryProperties()

        vkGetPhysicalDeviceMemoryProperties(self.physicalDevice, &physicalDeviceMemoryProperties)
        return physicalDeviceMemoryProperties
    }

    public func getPhysicalDeviceProperties() -> VkPhysicalDeviceProperties {
        var physicalDeviceProperties = VkPhysicalDeviceProperties()

        vkGetPhysicalDeviceProperties(self.physicalDevice, &physicalDeviceProperties)
        return physicalDeviceProperties
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

    public func getSurfaceCapabilities(surface: VulkanSurface) -> VkSurfaceCapabilitiesKHR {
        var surfaceCapabilities = VkSurfaceCapabilitiesKHR()

        guard vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.physicalDevice, surface.getSurface(), &surfaceCapabilities) == VK_SUCCESS else {
            preconditionFailure()
        }

        return surfaceCapabilities
    }

    public func getSurfaceFormats(surface: VulkanSurface) -> [VkSurfaceFormatKHR] {
        var surfaceFormatsCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice, surface.getSurface(), &surfaceFormatsCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var surfaceFormats = Array(repeating: VkSurfaceFormatKHR(),
                                   count: Int(surfaceFormatsCount))

        surfaceFormats.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice,
                                                       surface.getSurface(),
                                                       &surfaceFormatsCount,
                                                       $0.baseAddress!.assumingMemoryBound(to: VkSurfaceFormatKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return surfaceFormats
    }

    public func getSurfacePresentModes(surface: VulkanSurface) -> [VkPresentModeKHR] {
        var presentModeCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice,
                                                        surface.getSurface(),
                                                        &presentModeCount,
                                                        nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var presentModes = Array(repeating: VkPresentModeKHR(0),
                                 count: Int(presentModeCount))

        presentModes.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice,
                                                            surface.getSurface(),
                                                            &presentModeCount,
                                                            $0.baseAddress!.assumingMemoryBound(to: VkPresentModeKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return presentModes
    }

    public func isSurfaceSupported(surface: VulkanSurface,
                                   onQueue queueIndex: Int) -> Bool {
        var supportsPresent = VkBool32(VK_FALSE)

        guard vkGetPhysicalDeviceSurfaceSupportKHR(self.physicalDevice, UInt32(queueIndex), surface.getSurface(), &supportsPresent) == VK_SUCCESS else {
            preconditionFailure()
        }

        return supportsPresent == VK_TRUE
    }
}
