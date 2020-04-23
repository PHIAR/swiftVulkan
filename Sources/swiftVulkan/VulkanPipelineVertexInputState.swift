import vulkan
import Foundation

public final class VulkanPipelineVertexInputState {
    public init() {
    }

    public func getPipelineVertexInputStateCreateInfo() -> VkPipelineVertexInputStateCreateInfo {
        var pipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo()

        pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
        return pipelineVertexInputStateCreateInfo
    }
}
