import vulkan
import Foundation

public final class VulkanPipelineMultisampleState {
    private let rasterizationSamples: VkSampleCountFlagBits
    private let sampleShadingEnable: Bool
    private let minSampleShading: Float
    private let sampleMask: [VkSampleMask]
    private let alphaToCoverageEnable: Bool
    private let alphaToOneEnable: Bool

    private lazy var sampleMaskBuffer: UnsafeBufferPointer <VkSampleMask> = self.sampleMask.withUnsafeBytes { $0.bindMemory(to: VkSampleMask.self) }

    public init(rasterizationSamples: VkSampleCountFlagBits,
                sampleShadingEnable: Bool,
                minSampleShading: Float,
                sampleMask: [VkSampleMask],
                alphaToCoverageEnable: Bool,
                alphaToOneEnable: Bool) {
        self.rasterizationSamples = rasterizationSamples
        self.sampleShadingEnable = sampleShadingEnable
        self.minSampleShading = minSampleShading
        self.sampleMask = sampleMask
        self.alphaToCoverageEnable = alphaToCoverageEnable
        self.alphaToOneEnable = alphaToOneEnable
    }

    public func getPipelineMultisampleStateCreateInfo() -> VkPipelineMultisampleStateCreateInfo {
        var pipelineMultisampleStateCreateInfo = VkPipelineMultisampleStateCreateInfo()

        pipelineMultisampleStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
        pipelineMultisampleStateCreateInfo.rasterizationSamples = self.rasterizationSamples
        pipelineMultisampleStateCreateInfo.sampleShadingEnable = VkBool32(self.sampleShadingEnable ? VK_TRUE : VK_FALSE)
        pipelineMultisampleStateCreateInfo.minSampleShading = self.minSampleShading
        pipelineMultisampleStateCreateInfo.pSampleMask = self.sampleMaskBuffer.baseAddress!
        pipelineMultisampleStateCreateInfo.alphaToCoverageEnable = VkBool32(self.alphaToCoverageEnable ? VK_TRUE : VK_FALSE)
        pipelineMultisampleStateCreateInfo.alphaToOneEnable = VkBool32(self.alphaToOneEnable ? VK_TRUE : VK_FALSE)
        return pipelineMultisampleStateCreateInfo
    }
}
