import vulkan
import Foundation

public final class VulkanPipelineViewportState {
    private let viewports: [VkViewport]
    private let scissors: [VkRect2D]

    private lazy var viewportsBuffer: UnsafeBufferPointer <VkViewport> = self.viewports.withUnsafeBytes { $0.bindMemory(to: VkViewport.self) }
    private lazy var scissorsBuffer: UnsafeBufferPointer <VkRect2D> = self.scissors.withUnsafeBytes { $0.bindMemory(to: VkRect2D.self) }

    public init(viewports: [VkViewport],
                scissors: [VkRect2D]) {
        self.viewports = viewports
        self.scissors = scissors
    }

    public func getPipelineViewportStateCreateInfo() -> VkPipelineViewportStateCreateInfo {
        var pipelineViewportStateCreateInfo = VkPipelineViewportStateCreateInfo()

        pipelineViewportStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
        pipelineViewportStateCreateInfo.viewportCount = UInt32(max(1, self.viewports.count))
        pipelineViewportStateCreateInfo.pViewports = self.viewportsBuffer.baseAddress!
        pipelineViewportStateCreateInfo.scissorCount = UInt32(max(1, self.scissors.count))
        pipelineViewportStateCreateInfo.pScissors = self.scissorsBuffer.baseAddress!
        return pipelineViewportStateCreateInfo
    }
}
