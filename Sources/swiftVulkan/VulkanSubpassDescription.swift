import vulkan
import Foundation

public final class VulkanSubpassDescription {
    private let flags: VkSubpassDescriptionFlags
    private let pipelineBindPoint: VulkanPipelineBindPoint
    private let inputAttachments: [VkAttachmentReference]
    private let _inputAttachments: UnsafeBufferPointer <VkAttachmentReference>
    private let colorAttachments: [VkAttachmentReference]
    private let _colorAttachments: UnsafeBufferPointer <VkAttachmentReference>
    private let resolveAttachments: [VkAttachmentReference]
    private let _resolveAttachments: UnsafeBufferPointer <VkAttachmentReference>
    private let depthStencilAttachment: [VkAttachmentReference]
    private let _depthStencilAttachment: UnsafeBufferPointer <VkAttachmentReference>
    private let preserveAttachments: [UInt32]
    private let _preserveAttachments: UnsafeBufferPointer <UInt32>

    public init(flags: VkSubpassDescriptionFlags,
                pipelineBindPoint: VulkanPipelineBindPoint,
                inputAttachments: [VkAttachmentReference] = [],
                colorAttachments: [VkAttachmentReference] = [],
                resolveAttachment: VkAttachmentReference? = nil,
                depthStencilAttachment: VkAttachmentReference? = nil,
                preserveAttachments: [UInt32] = []) {
        self.flags = flags
        self.pipelineBindPoint = pipelineBindPoint
        self.inputAttachments = inputAttachments
        self._inputAttachments = self.inputAttachments.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkAttachmentReference.self),
                                                                                             count: inputAttachments.count) }
        self.colorAttachments = colorAttachments
        self._colorAttachments = self.colorAttachments.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkAttachmentReference.self),
                                                                                             count: colorAttachments.count) }
        self.resolveAttachments = (resolveAttachment == nil) ? [] : [ resolveAttachment! ]
        self._resolveAttachments = self.resolveAttachments.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkAttachmentReference.self),
                                                                                                count: 1) }
        self.depthStencilAttachment = (depthStencilAttachment == nil) ? [] : [ depthStencilAttachment! ]
        self._depthStencilAttachment = self.depthStencilAttachment.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: VkAttachmentReference.self),
                                                                                                         count: 1) }
        self.preserveAttachments = preserveAttachments
        self._preserveAttachments = self.preserveAttachments.withUnsafeBytes { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: UInt32.self),
                                                                                                   count: preserveAttachments.count) }
    }

    public func getVkSubpassDescription() -> VkSubpassDescription {
        var subpassDescription = VkSubpassDescription()

        subpassDescription.flags = self.flags
        subpassDescription.pipelineBindPoint = self.pipelineBindPoint.toVkPipelineBindPoint()
        subpassDescription.inputAttachmentCount = UInt32(self.inputAttachments.count)
        subpassDescription.pInputAttachments = self._inputAttachments.baseAddress!
        subpassDescription.colorAttachmentCount = UInt32(self.colorAttachments.count)
        subpassDescription.pColorAttachments = self._colorAttachments.baseAddress!
        subpassDescription.pResolveAttachments = self.resolveAttachments.isEmpty ? nil : self._resolveAttachments.baseAddress!
        subpassDescription.pDepthStencilAttachment = self.depthStencilAttachment.isEmpty ? nil : self._depthStencilAttachment.baseAddress!
        subpassDescription.preserveAttachmentCount = UInt32(self.preserveAttachments.count)
        subpassDescription.pPreserveAttachments = self._preserveAttachments.baseAddress!
        return subpassDescription
    }
}
