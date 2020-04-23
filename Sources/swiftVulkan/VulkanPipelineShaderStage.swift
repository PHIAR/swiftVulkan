import vulkan
import Foundation

public final class VulkanPipelineShaderStage {
    private let flags: VkPipelineShaderStageCreateFlags
    private let stage: VkShaderStageFlagBits
    private let shaderModule: VulkanShaderModule
    private let name: UnsafeMutablePointer <CChar>

    public init(flags: VkPipelineShaderStageCreateFlags = 0,
                stage: VkShaderStageFlagBits,
                shaderModule: VulkanShaderModule,
                name: String) {
        self.flags = flags
        self.stage = stage
        self.shaderModule = shaderModule
        self.name = name.withCString { strdup($0) }
    }

    deinit {
        free(self.name)
    }

    public func getPipelineShaderStageCreateInfo() -> VkPipelineShaderStageCreateInfo {
        var pipelineShaderStageCreateInfo = VkPipelineShaderStageCreateInfo()

        pipelineShaderStageCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        pipelineShaderStageCreateInfo.stage = self.stage
        pipelineShaderStageCreateInfo.module = self.shaderModule.getShaderModule()
        pipelineShaderStageCreateInfo.pName = UnsafeRawPointer(self.name).assumingMemoryBound(to: CChar.self)
        return pipelineShaderStageCreateInfo
    }
}
