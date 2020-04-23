import vulkan
import Foundation

public final class VulkanInstance {
    public typealias vkCmdDrawIndexedIndirectCountPointer = @convention (c) (_ commandBuffer: VkCommandBuffer,
                                                                             _ buffer: VkBuffer,
                                                                             _ offset: VkDeviceSize,
                                                                             _ countBuffer: VkBuffer,
                                                                             _ countBufferOffset: VkDeviceSize,
                                                                             _ maxDrawCount: UInt32,
                                                                             _ stride: UInt32) -> Void

    private let instance: VkInstance

    public lazy var vkCmdDrawIndexedIndirectCount: vkCmdDrawIndexedIndirectCountPointer? = {
        var pointer = unsafeBitCast(self.getProcAddress(name: "vkCmdDrawIndexedIndirectCount"),
                                    to: vkCmdDrawIndexedIndirectCountPointer?.self)

        guard pointer == nil else {
            return pointer
        }

        pointer = unsafeBitCast(self.getProcAddress(name: "vkCmdDrawIndexedIndirectCountAMD"),
                                to: vkCmdDrawIndexedIndirectCountPointer?.self)

        guard pointer == nil else {
            return pointer
        }

        return unsafeBitCast(self.getProcAddress(name: "vkCmdDrawIndexedIndirectCountKHR"),
                             to: vkCmdDrawIndexedIndirectCountPointer?.self)
    }()

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

        return physicalDevices.map { VulkanPhysicalDevice(instance: self,
                                                          physicalDevice: $0!) }
    }

    public func getProcAddress(name: String) -> @convention (c) () -> Void {
        return name.withCString { vkGetInstanceProcAddr(self.instance, $0) }
    }
}
