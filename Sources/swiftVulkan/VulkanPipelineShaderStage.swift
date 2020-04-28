import vulkan
import Foundation

public final class VulkanPipelineShaderStage {
    private let flags: VkPipelineShaderStageCreateFlags
    private let stage: VkShaderStageFlagBits
    private let shaderModule: VulkanShaderModule
    private let name: UnsafeMutablePointer <CChar>
    private let specializationConstants: [VkSpecializationMapEntry]
    private let _specializationConstants: UnsafeBufferPointer <VkSpecializationMapEntry>
    private let specializationData: UnsafeRawBufferPointer?
    private let specializationInfo: [VkSpecializationInfo]
    private let _specializationInfo: UnsafeBufferPointer <VkSpecializationInfo>?

    public init(flags: VkPipelineShaderStageCreateFlags = 0,
                stage: VkShaderStageFlagBits,
                shaderModule: VulkanShaderModule,
                name: String,
                specializationConstants: [VkSpecializationMapEntry] = [],
                specializationData: UnsafeRawBufferPointer? = nil) {
        let _specializationConstants = specializationConstants.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkSpecializationMapEntry.self ),
                                                                                                     count: specializationConstants.count) }
        var specializationInfo = VkSpecializationInfo()

        specializationInfo.mapEntryCount = UInt32(specializationConstants.count)
        specializationInfo.pMapEntries = _specializationConstants.baseAddress!
        specializationInfo.dataSize = specializationData?.count ?? 0
        specializationInfo.pData = specializationData?.baseAddress

        self.flags = flags
        self.stage = stage
        self.shaderModule = shaderModule
        self.name = name.withCString { strdup($0) }
        self.specializationConstants = specializationConstants
        self._specializationConstants = _specializationConstants
        self.specializationData = specializationData

        if specializationConstants.isEmpty {
            self.specializationInfo = []
            self._specializationInfo = nil
        } else {
            let _specializationInfo = [ specializationInfo ]

            self.specializationInfo = _specializationInfo
            self._specializationInfo = _specializationInfo.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkSpecializationInfo.self ),
                                                                                                 count: 1) }
        }
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
        pipelineShaderStageCreateInfo.pSpecializationInfo = self._specializationInfo?.baseAddress
        return pipelineShaderStageCreateInfo
    }
}
