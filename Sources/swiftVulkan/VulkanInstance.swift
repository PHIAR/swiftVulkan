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

    public convenience init(applicationInfo: VkApplicationInfo = VkApplicationInfo(),
                            layerNames: [String] = [],
                            extensions: [String] = []) {
        var _applicationInfo = applicationInfo
        let _layerNames = layerNames.map { $0.withCString { UnsafePointer(strdup($0)) }}
        let _extensions = extensions.map { $0.withCString { UnsafePointer(strdup($0)) }}
        let instance: VkInstance = { (pApplicationInfo: UnsafePointer <VkApplicationInfo>,
                                      layerNames: UnsafePointer <UnsafePointer <CChar>?>,
                                      layerCount: Int,
                                      extensions: UnsafePointer <UnsafePointer <CChar>?>,
                                      extensionCount: Int) in
            var info = VkInstanceCreateInfo()

            info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
            info.pApplicationInfo = pApplicationInfo
            info.enabledLayerCount = UInt32(layerCount)
            info.ppEnabledLayerNames = layerNames
            info.enabledExtensionCount = UInt32(extensionCount)
            info.ppEnabledExtensionNames = extensions

            var instance: VkInstance? = nil

            guard vkCreateInstance(&info, nil, &instance) == VK_SUCCESS else {
                preconditionFailure()
            }

            return instance!
        }(&_applicationInfo,
          _layerNames,
          layerNames.count,
          _extensions,
          extensions.count)

        for _extension in _extensions {
            free(UnsafeMutableRawPointer(mutating: _extension))
        }

        for _layerName in _layerNames {
            free(UnsafeMutableRawPointer(mutating: _layerName))
        }

        self.init(instance: instance)
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
