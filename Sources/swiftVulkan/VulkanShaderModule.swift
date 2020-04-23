import vulkan
import Foundation

public final class VulkanShaderModule {
    private let device: VkDevice
    private let shaderModule: VkShaderModule

    public init(device: VkDevice,
                shaderModule: VkShaderModule) {
        self.device = device
        self.shaderModule = shaderModule
    }

    deinit {
        vkDestroyShaderModule(self.device, self.shaderModule, nil)
    }

    public func getShaderModule() -> VkShaderModule {
        return self.shaderModule
    }
}
