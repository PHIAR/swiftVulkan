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
                                   bufferInfos: [VkDescriptorBufferInfo] = [],
                                   imageInfos: [VkDescriptorImageInfo] = []) {
        let descriptorCount: UInt32

        switch descriptorType {
        case VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
            descriptorCount = UInt32(imageInfos.count)

        case VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
            descriptorCount = UInt32(bufferInfos.count)

        default:
            preconditionFailure()
        }

        bufferInfos.withUnsafeBytes { _descriptorSets in
            imageInfos.withUnsafeBytes { _imageInfos in
                var writeDescriptorSet = VkWriteDescriptorSet()

                writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET
                writeDescriptorSet.dstSet = self.getDescriptorSet()
                writeDescriptorSet.dstBinding = UInt32(dstBinding)
                writeDescriptorSet.descriptorCount = descriptorCount
                writeDescriptorSet.descriptorType = descriptorType
                writeDescriptorSet.pBufferInfo = _descriptorSets.baseAddress!.assumingMemoryBound(to: VkDescriptorBufferInfo.self)
                vkUpdateDescriptorSets(self.device, 1, &writeDescriptorSet, 0, nil)
            }
        }
    }
}
