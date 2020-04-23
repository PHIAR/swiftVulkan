import vulkan
import Foundation

public final class VulkanPipelineRasterizationState {
    private let depthClampEnable: Bool
    private let rasterizerDiscardEnable: Bool
    private let polygonMode: VkPolygonMode
    private let cullMode: VkCullModeFlags
    private let frontFace: VkFrontFace
    private let depthBiasEnable: Bool
    private let depthBiasConstantFactor: Float
    private let depthBiasClamp: Float
    private let depthBiasSlopeFactor: Float
    private let lineWidth: Float

    public init(depthClampEnable: Bool,
                rasterizerDiscardEnable: Bool,
                polygonMode: VkPolygonMode,
                cullMode: VkCullModeFlags,
                frontFace: VkFrontFace,
                depthBiasEnable: Bool,
                depthBiasConstantFactor: Float,
                depthBiasClamp: Float,
                depthBiasSlopeFactor: Float,
                lineWidth: Float) {
        self.depthClampEnable = depthClampEnable
        self.rasterizerDiscardEnable = rasterizerDiscardEnable
        self.polygonMode = polygonMode
        self.cullMode = cullMode
        self.frontFace = frontFace
        self.depthBiasEnable = depthBiasEnable
        self.depthBiasConstantFactor = depthBiasConstantFactor
        self.depthBiasClamp = depthBiasClamp
        self.depthBiasSlopeFactor = depthBiasSlopeFactor
        self.lineWidth = lineWidth
    }

    public func getPipelineRasterizationStateCreateInfo() -> VkPipelineRasterizationStateCreateInfo {
        var pipelineRasterizationStateCreateInfo = VkPipelineRasterizationStateCreateInfo()

        pipelineRasterizationStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
        pipelineRasterizationStateCreateInfo.depthClampEnable = VkBool32(self.depthClampEnable ? VK_TRUE : VK_FALSE)
        pipelineRasterizationStateCreateInfo.rasterizerDiscardEnable = VkBool32(self.rasterizerDiscardEnable ? VK_TRUE : VK_FALSE)
        pipelineRasterizationStateCreateInfo.polygonMode = self.polygonMode
        pipelineRasterizationStateCreateInfo.cullMode = self.cullMode
        pipelineRasterizationStateCreateInfo.frontFace = self.frontFace
        pipelineRasterizationStateCreateInfo.depthBiasEnable = VkBool32(self.depthBiasEnable ? VK_TRUE : VK_FALSE)
        pipelineRasterizationStateCreateInfo.depthBiasConstantFactor = self.depthBiasConstantFactor
        pipelineRasterizationStateCreateInfo.depthBiasClamp = self.depthBiasClamp
        pipelineRasterizationStateCreateInfo.depthBiasSlopeFactor = self.depthBiasSlopeFactor
        pipelineRasterizationStateCreateInfo.lineWidth = self.lineWidth
        return pipelineRasterizationStateCreateInfo
    }
}
