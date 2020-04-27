import vulkan
import Foundation

public final class VulkanDescriptorSet {
    private let device: VkDevice
    private let descriptorPool: VkDescriptorPool
    private let descriptorSet: VkDescriptorSet

    public init(device: VkDevice,
                descriptorPool: VkDescriptorPool,
                descriptorSet: VkDescriptorSet) {
        self.device = device
        self.descriptorPool = descriptorPool
        self.descriptorSet = descriptorSet
    }

    deinit {
        var descriptorSet: VkDescriptorSet? = self.descriptorSet

        vkFreeDescriptorSets(self.device,
                             self.descriptorPool,
                             1,
                             &descriptorSet)
    }

    public func getDescriptorSet() -> VkDescriptorSet {
        return self.descriptorSet
    }

    public func writeDescriptorSet(dstBinding: Int,
                                   descriptorType: VkDescriptorType,
                                   bufferInfos: [VkDescriptorBufferInfo]) {
        bufferInfos.withUnsafeBytes { _descriptorSets in
            var writeDescriptorSet = VkWriteDescriptorSet()

            writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET
            writeDescriptorSet.dstSet = self.getDescriptorSet()
            writeDescriptorSet.dstBinding = UInt32(dstBinding)
            writeDescriptorSet.descriptorCount = UInt32(bufferInfos.count)
            writeDescriptorSet.descriptorType = descriptorType
            writeDescriptorSet.pBufferInfo = _descriptorSets.baseAddress!.assumingMemoryBound(to: VkDescriptorBufferInfo.self)
            vkUpdateDescriptorSets(self.device, 1, &writeDescriptorSet, 0, nil)
        }
    }
}
