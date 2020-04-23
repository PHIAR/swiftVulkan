import vulkan
import Foundation

public final class VulkanInstance {
    private let instance: VkInstance

    public convenience init() {
        var createInfo = VkInstanceCreateInfo()
        var instance: VkInstance? = nil

        guard vkCreateInstance(&createInfo, nil, &instance) == VK_SUCCESS else {
            preconditionFailure()
        }

        self.init(instance: instance!)
    }

    public init(instance: VkInstance) {
        self.instance = instance
    }

    public func getInstance() -> VkInstance {
        return self.instance
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
