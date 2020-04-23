import vulkan
import Foundation

public final class VulkanPipelineDynamicState {
    private let dynamicStates: [VkDynamicState]

    private lazy var dynamicStatesBuffer: UnsafeBufferPointer <VkDynamicState> = self.dynamicStates.withUnsafeBytes { $0.bindMemory(to: VkDynamicState.self) }

    public init(dynamicStates: [VkDynamicState]) {
        self.dynamicStates = dynamicStates
    }

    public func getPipelineDynamicStateCreateInfo() -> VkPipelineDynamicStateCreateInfo {
        var pipelineDynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo()

        pipelineDynamicStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
        pipelineDynamicStateCreateInfo.dynamicStateCount = UInt32(self.dynamicStates.count)
        pipelineDynamicStateCreateInfo.pDynamicStates = self.dynamicStatesBuffer.baseAddress!
        return pipelineDynamicStateCreateInfo
    }
}
