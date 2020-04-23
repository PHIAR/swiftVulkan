import vulkan
import Foundation

public final class VulkanPipelineColorBlendState {
    private let logicOpEnable: Bool
    private let attachments: [VkPipelineColorBlendAttachmentState]

    private lazy var attachmentsBuffer: UnsafeBufferPointer <VkPipelineColorBlendAttachmentState> = self.attachments.withUnsafeBytes { $0.bindMemory(to: VkPipelineColorBlendAttachmentState.self) }

    public init(logicOpEnable: Bool,
                attachments: [VkPipelineColorBlendAttachmentState]) {
        self.logicOpEnable = logicOpEnable
        self.attachments = attachments
    }

    public func getPipelineColorBlendStateCreateInfo() -> VkPipelineColorBlendStateCreateInfo {
        var pipelineColorBlendStateCreateInfo = VkPipelineColorBlendStateCreateInfo()

        pipelineColorBlendStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
        pipelineColorBlendStateCreateInfo.logicOpEnable = VkBool32(self.logicOpEnable ? VK_TRUE : VK_FALSE)
        pipelineColorBlendStateCreateInfo.attachmentCount = UInt32(self.attachments.count)
        pipelineColorBlendStateCreateInfo.pAttachments = self.attachmentsBuffer.baseAddress!
        return pipelineColorBlendStateCreateInfo
    }
}
