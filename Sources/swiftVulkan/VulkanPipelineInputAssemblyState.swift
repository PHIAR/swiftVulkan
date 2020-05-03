import vulkan
import Foundation

public final class VulkanPipelineInputAssemblyState {
    private let topology: VkPrimitiveTopology
    private let primitiveRestartEnable: Bool

    public init(topology: VulkanPrimitiveTopology,
                primitiveRestartEnable: Bool) {
        self.topology = topology.toVkPrimitiveTopology()
        self.primitiveRestartEnable = primitiveRestartEnable
    }

    public func getPipelineInputAssemblyStateCreateInfo() -> VkPipelineInputAssemblyStateCreateInfo {
        var pipelineInputAssemblyStateCreateInfo = VkPipelineInputAssemblyStateCreateInfo()

        pipelineInputAssemblyStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
        pipelineInputAssemblyStateCreateInfo.topology = self.topology
        pipelineInputAssemblyStateCreateInfo.primitiveRestartEnable = VkBool32(self.primitiveRestartEnable ? VK_TRUE : VK_FALSE)
        return pipelineInputAssemblyStateCreateInfo
    }
}
