import vulkan
import Foundation

public final class VulkanPipelineVertexInputState {
    private let attributes: [VkVertexInputAttributeDescription]
    private let bindings: [VkVertexInputBindingDescription]

    public init(attributes: [VkVertexInputAttributeDescription],
                bindings: [VkVertexInputBindingDescription]) {
        self.attributes = attributes
        self.bindings = bindings
    }

    public func getPipelineVertexInputStateCreateInfo() -> VkPipelineVertexInputStateCreateInfo {
        return self.attributes.withUnsafeBytes { _attributes in
            self.bindings.withUnsafeBytes { _bindings in
                var pipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo()

                pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
                pipelineVertexInputStateCreateInfo.vertexBindingDescriptionCount = UInt32(self.attributes.count)
                pipelineVertexInputStateCreateInfo.pVertexBindingDescriptions = _attributes.baseAddress!.assumingMemoryBound(to: VkVertexInputBindingDescription.self)
                pipelineVertexInputStateCreateInfo.vertexAttributeDescriptionCount = UInt32(self.bindings.count)
                pipelineVertexInputStateCreateInfo.pVertexAttributeDescriptions = _bindings.baseAddress!.assumingMemoryBound(to: VkVertexInputAttributeDescription.self)
                return pipelineVertexInputStateCreateInfo
            }
        }
    }
}
