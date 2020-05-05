import vulkan
import Foundation

public final class VulkanStencilOpState {
    private let stencilOpState: VkStencilOpState

    public init(failOp: VulkanStencilOp,
                passOp: VulkanStencilOp,
                depthFailOp: VulkanStencilOp,
                compareOp: VulkanCompareOp,
                compareMask: UInt32,
                writeMask: UInt32,
                reference: UInt32) {
        self.stencilOpState = VkStencilOpState(failOp: failOp.toVkStencilOp(),
                                               passOp: passOp.toVkStencilOp(),
                                               depthFailOp: depthFailOp.toVkStencilOp(),
                                               compareOp: compareOp.toVkCompareOp(),
                                               compareMask: compareMask,
                                               writeMask: writeMask,
                                               reference: reference)
    }

    internal func toVkStencilOpState() -> VkStencilOpState {
        return self.stencilOpState
    }
}

public final class VulkanPipelineDepthStencilState {
    private let pipelineDepthStencilStateCreateInfo: VkPipelineDepthStencilStateCreateInfo

    public init(depthTestEnable: Bool,
                depthWriteEnable: Bool,
                depthCompareOp: VulkanCompareOp,
                depthBoundsTestEnable: Bool,
                stencilTestEnable: Bool,
                front: VulkanStencilOpState,
                back: VulkanStencilOpState,
                minDepthBounds: Float,
                maxDepthBounds: Float) {
        self.pipelineDepthStencilStateCreateInfo = VkPipelineDepthStencilStateCreateInfo(sType: VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
                                                                                         pNext: nil,
                                                                                         flags: 0,
                                                                                         depthTestEnable: VkBool32(depthTestEnable ? VK_TRUE : VK_FALSE),
                                                                                         depthWriteEnable: VkBool32(depthWriteEnable ? VK_TRUE : VK_FALSE),
                                                                                         depthCompareOp: depthCompareOp.toVkCompareOp(),
                                                                                         depthBoundsTestEnable: VkBool32(depthBoundsTestEnable ? VK_TRUE : VK_FALSE),
                                                                                         stencilTestEnable: VkBool32(stencilTestEnable ? VK_TRUE : VK_FALSE),
                                                                                         front: front.toVkStencilOpState(),
                                                                                         back: back.toVkStencilOpState(),
                                                                                         minDepthBounds: minDepthBounds,
                                                                                         maxDepthBounds: maxDepthBounds)
    }

    public func getPipelineDepthStencilStateCreateInfo() -> VkPipelineDepthStencilStateCreateInfo {
        return self.pipelineDepthStencilStateCreateInfo
    }
}
