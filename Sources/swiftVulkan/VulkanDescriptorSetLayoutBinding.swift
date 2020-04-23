import vulkan
import Foundation

public struct VulkanDescriptorSetLayoutBinding {
    private let binding: Int
    private let descriptorType: VkDescriptorType
    private let descriptorCount: Int
    private let stageFlags: VkShaderStageFlags
    private let immutableSamplers: UnsafeBufferPointer <VkSampler?>

    public init(binding: Int,
                descriptorType: VkDescriptorType,
                descriptorCount: Int,
                stageFlags: VkShaderStageFlags,
                immutableSamplers: [VulkanSampler]) {
        self.binding = binding
        self.descriptorType = descriptorType
        self.descriptorCount = descriptorCount
        self.stageFlags = stageFlags
        self.immutableSamplers = immutableSamplers.map { $0.getSampler() }.withUnsafeBytes {
            $0.bindMemory(to: VkSampler?.self)
        }
    }

    public func getDescriptorSetLayoutBinding() -> VkDescriptorSetLayoutBinding {
        var descriptorSetLayoutBinding = VkDescriptorSetLayoutBinding()

        descriptorSetLayoutBinding.binding = UInt32(self.binding)
        descriptorSetLayoutBinding.descriptorType = self.descriptorType
        descriptorSetLayoutBinding.descriptorCount = UInt32(self.descriptorCount)
        descriptorSetLayoutBinding.stageFlags = self.stageFlags
        descriptorSetLayoutBinding.pImmutableSamplers = self.immutableSamplers.baseAddress!
        return descriptorSetLayoutBinding
    }
}
