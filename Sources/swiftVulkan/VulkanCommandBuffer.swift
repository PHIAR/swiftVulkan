import vulkan
import Foundation

public enum VulkanPipelineBindPoint {
    case compute
    case graphics
}

internal extension VulkanPipelineBindPoint {
    func toVkPipelineBindPoint() -> VkPipelineBindPoint {
        switch self {
        case .compute:
            return VK_PIPELINE_BIND_POINT_COMPUTE

        case .graphics:
            return VK_PIPELINE_BIND_POINT_GRAPHICS
        }
    }
}

public final class VulkanCommandBuffer {
    private let device: VulkanDevice
    private let commandBuffer: VkCommandBuffer

    public init(device: VulkanDevice,
                commandBuffer: VkCommandBuffer) {
        self.device = device
        self.commandBuffer = commandBuffer
    }

    public func begin(flags: VkCommandBufferUsageFlags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT.rawValue) {
        var beginInfo = VkCommandBufferBeginInfo()

        beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        beginInfo.flags = flags

        guard vkBeginCommandBuffer(self.commandBuffer, &beginInfo) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func beginRenderPass(renderPass: VulkanRenderPass,
                                framebuffer: VulkanFramebuffer,
                                renderArea: VkRect2D,
                                clearValues: [VkClearValue],
                                contents: VkSubpassContents = VK_SUBPASS_CONTENTS_INLINE) {
        clearValues.withUnsafeBytes { _clearValues in
            var renderPassBeginInfo = VkRenderPassBeginInfo()

            renderPassBeginInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
            renderPassBeginInfo.renderPass = renderPass.getRenderPass()
            renderPassBeginInfo.framebuffer = framebuffer.getFramebuffer()
            renderPassBeginInfo.clearValueCount = UInt32(clearValues.count)
            renderPassBeginInfo.pClearValues = _clearValues.baseAddress!.assumingMemoryBound(to: VkClearValue.self)
            renderPassBeginInfo.renderArea = renderArea

            vkCmdBeginRenderPass(self.commandBuffer, &renderPassBeginInfo, contents)
        }
    }

    public func bindDescriptorSets(pipelineBindPoint: VulkanPipelineBindPoint,
                                   pipelineLayout: VulkanPipelineLayout,
                                   firstSet: Int = 0,
                                   descriptorSets: [VulkanDescriptorSet],
                                   dynamicOffsets: [Int] = []) {
        let bindDescriptorSets = descriptorSets.map { $0.getDescriptorSet() }
        let bindDynamicOffsets = dynamicOffsets.map { UInt32($0) }

        bindDescriptorSets.withUnsafeBytes { _descriptorSets in
            bindDynamicOffsets.withUnsafeBytes { _dynamicOffsets in
                vkCmdBindDescriptorSets(self.commandBuffer,
                                        pipelineBindPoint.toVkPipelineBindPoint(),
                                        pipelineLayout.getPipelineLayout(),
                                        UInt32(firstSet),
                                        UInt32(descriptorSets.count),
                                        _descriptorSets.baseAddress!.assumingMemoryBound(to: VkDescriptorSet?.self),
                                        UInt32(dynamicOffsets.count),
                                        _dynamicOffsets.baseAddress!.assumingMemoryBound(to: UInt32.self))
            }
        }
    }

    public func bindIndexBuffer(buffer: VulkanBuffer,
                                offset: Int,
                                indexType: VulkanIndexType) {
        vkCmdBindIndexBuffer(self.commandBuffer,
                             buffer.getBuffer(),
                             VkDeviceSize(offset),
                             indexType.toVkIndexType())
    }

    public func bindPipeline(pipelineBindPoint: VulkanPipelineBindPoint,
                             pipeline: VulkanPipeline) {
        vkCmdBindPipeline(self.commandBuffer,
                          pipelineBindPoint.toVkPipelineBindPoint(),
                          pipeline.getPipeline())
    }

    public func bindVertexBuffers(firstBinding: Int,
                                  buffers: [VulkanBuffer?],
                                  offsets: [Int]) {
        precondition(buffers.count == offsets.count, "Buffer and offset counts do not match.")

        let bindingBuffers = buffers.map { $0?.getBuffer() }
        let bindingOffsets = offsets.map { VkDeviceSize($0) }

        bindingBuffers.withUnsafeBytes { _buffers in
            bindingOffsets.withUnsafeBytes { _offsets in
                vkCmdBindVertexBuffers(self.commandBuffer,
                                       UInt32(firstBinding),
                                       UInt32(buffers.count),
                                       _buffers.baseAddress!.assumingMemoryBound(to: VkBuffer?.self),
                                       _offsets.baseAddress!.assumingMemoryBound(to: VkDeviceSize.self))
            }
        }
    }

    public func blitImage(srcImage: VulkanImage,
                          srcImageLayout: VkImageLayout,
                          dstImage: VulkanImage,
                          dstImageLayout: VkImageLayout,
                          regions: [VkImageBlit],
                          filter: VkFilter) {
        regions.withUnsafeBytes { _regions in
            vkCmdBlitImage(self.commandBuffer,
                           srcImage.getImage(),
                           srcImageLayout,
                           dstImage.getImage(),
                           dstImageLayout,
                           UInt32(regions.count),
                           _regions.baseAddress!.assumingMemoryBound(to: VkImageBlit.self),
                           filter)
        }
    }

    public func clearColor(image: VulkanImage,
                           imageLayout: VulkanImageLayout,
                           color: VkClearColorValue,
                           ranges: [VkImageSubresourceRange]) {
        ranges.withUnsafeBytes { _ranges in
            let _image = image.getImage()
            var _color = color

            vkCmdClearColorImage(self.commandBuffer,
                                 _image,
                                 imageLayout.toVkImageLayout(),
                                 &_color,
                                 UInt32(ranges.count),
                                 _ranges.baseAddress!.assumingMemoryBound(to: VkImageSubresourceRange.self))
        }
    }

    public func copyBuffer(srcBuffer: VulkanBuffer,
                           dstBuffer: VulkanBuffer,
                           regions: [VkBufferCopy]) {
        regions.withUnsafeBytes { _regions in
            vkCmdCopyBuffer(self.commandBuffer,
                            srcBuffer.getBuffer(),
                            dstBuffer.getBuffer(),
                            UInt32(regions.count),
                            _regions.baseAddress!.assumingMemoryBound(to: VkBufferCopy.self))
        }
    }

    public func copyBufferToImage(srcBuffer: VulkanBuffer,
                                  dstImage: VulkanImage,
                                  dstImageLayout: VulkanImageLayout,
                                  regions: [VkBufferImageCopy]) {
        regions.withUnsafeBytes { _regions in
            vkCmdCopyBufferToImage(self.commandBuffer,
                                   srcBuffer.getBuffer(),
                                   dstImage.getImage(),
                                   dstImageLayout.toVkImageLayout(),
                                   UInt32(regions.count),
                                  _regions.baseAddress!.assumingMemoryBound(to: VkBufferImageCopy.self))
        }
    }

    public func copyImage(srcImage: VulkanImage,
                          srcImageLayout: VulkanImageLayout,
                          dstImage: VulkanImage,
                          dstImageLayout: VulkanImageLayout,
                          regions: [VkImageCopy]) {
        regions.withUnsafeBytes { _regions in
            vkCmdCopyImage(self.commandBuffer,
                           srcImage.getImage(),
                           srcImageLayout.toVkImageLayout(),
                           dstImage.getImage(),
                           dstImageLayout.toVkImageLayout(),
                           UInt32(regions.count),
                           _regions.baseAddress!.assumingMemoryBound(to: VkImageCopy.self))
        }
    }

    public func copyImageToBuffer(srcImage: VulkanImage,
                                  srcImageLayout: VulkanImageLayout,
                                  dstBuffer: VulkanBuffer,
                                  regions: [VkBufferImageCopy]) {
        regions.withUnsafeBytes { _regions in
            vkCmdCopyImageToBuffer(self.commandBuffer,
                                   srcImage.getImage(),
                                   srcImageLayout.toVkImageLayout(),
                                   dstBuffer.getBuffer(),
                                   UInt32(regions.count),
                                   _regions.baseAddress!.assumingMemoryBound(to: VkBufferImageCopy.self))
        }
    }

    public func dispatch(groupCountX: Int,
                         groupCountY: Int,
                         groupCountZ: Int) {
        vkCmdDispatch(self.commandBuffer,
                      UInt32(groupCountX),
                      UInt32(groupCountY),
                      UInt32(groupCountZ))
    }

    public func dispatchBase(baseGroupX: Int,
                             baseGroupY: Int,
                             baseGroupZ: Int,
                             groupCountX: Int,
                             groupCountY: Int,
                             groupCountZ: Int) {
        let vkCmdDispatchBase = self.device.getPhysicalDevice().getInstance().vkCmdDispatchBase!

        vkCmdDispatchBase(self.commandBuffer,
                          UInt32(baseGroupX),
                          UInt32(baseGroupY),
                          UInt32(baseGroupZ),
                          UInt32(groupCountX),
                          UInt32(groupCountY),
                          UInt32(groupCountZ))
    }

    public func dispatchIndirect(buffer: VulkanBuffer,
                                 offset: Int) {
        vkCmdDispatchIndirect(self.commandBuffer,
                              buffer.getBuffer(),
                              VkDeviceSize(offset))
    }

    public func draw(vertexCount: Int,
                     instanceCount: Int,
                     firstVertex: Int,
                     firstInstance: Int) {
        vkCmdDraw(self.commandBuffer,
                  UInt32(vertexCount),
                  UInt32(instanceCount),
                  UInt32(firstVertex),
                  UInt32(firstInstance))
    }

    public func drawIndexed(indexCount: Int,
                            instanceCount: Int,
                            firstIndex: Int,
                            vertexOffset: Int,
                            firstInstance: Int) {
        vkCmdDrawIndexed(self.commandBuffer,
                         UInt32(indexCount),
                         UInt32(instanceCount),
                         UInt32(firstIndex),
                         Int32(vertexOffset),
                         UInt32(firstInstance))
    }

    public func drawIndexedIndirect(buffer: VulkanBuffer,
                                    offset: Int,
                                    drawCount: Int,
                                    stride: Int) {
        vkCmdDrawIndexedIndirect(self.commandBuffer,
                                 buffer.getBuffer(),
                                 VkDeviceSize(offset),
                                 UInt32(drawCount),
                                 UInt32(stride))
    }

    public func drawIndexedIndirectCount(buffer: VulkanBuffer,
                                         offset: Int,
                                         countBuffer: VulkanBuffer,
                                         countBufferOffset: Int,
                                         maxDrawCount: Int,
                                         stride: Int) {
        let vkCmdDrawIndexedIndirectCount = self.device.getPhysicalDevice().getInstance().vkCmdDrawIndexedIndirectCount!

        vkCmdDrawIndexedIndirectCount(self.commandBuffer,
                                      buffer.getBuffer(),
                                      VkDeviceSize(offset),
                                      countBuffer.getBuffer(),
                                      VkDeviceSize(countBufferOffset),
                                      UInt32(maxDrawCount),
                                      UInt32(stride))
    }

    public func end() {
        guard vkEndCommandBuffer(self.commandBuffer) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func endRenderPass() {
        vkCmdEndRenderPass(self.commandBuffer)
    }

    public func fillBuffer(dstBuffer: VulkanBuffer,
                           dstOffset: Int,
                           size: Int,
                           data: UInt32) {
        vkCmdFillBuffer(self.commandBuffer,
                        dstBuffer.getBuffer(),
                        VkDeviceSize(dstOffset),
                        VkDeviceSize(size),
                        data)
    }

    public func getCommandBuffer() -> VkCommandBuffer {
        return self.commandBuffer
    }

    public func pipelineBarrier(srcStageMask: VkPipelineStageFlags,
                                dstStageMask: VkPipelineStageFlags,
                                dependencyFlags: VkDependencyFlags,
                                memoryBarriers: [VulkanMemoryBarrier],
                                bufferMemoryBarriers: [VulkanBufferMemoryBarrier],
                                imageMemoryBarriers: [VulkanImageMemoryBarrier]) {
        let pipelineMemoryBarriers = memoryBarriers.map { $0.getMemoryBarrier() }
        let pipelineBufferMemoryBarriers = bufferMemoryBarriers.map { $0.getBufferMemoryBarrier() }
        let pipelineImageMemoryBarriers = imageMemoryBarriers.map { $0.getImageMemoryBarrier() }
        let _ = pipelineMemoryBarriers.withUnsafeBytes { _memoryBarriers in
            let _ = pipelineBufferMemoryBarriers.withUnsafeBytes { _bufferMemoryBarriers in
                let _ = pipelineImageMemoryBarriers.withUnsafeBytes { _imageMemoryBarriers in
                    vkCmdPipelineBarrier(self.commandBuffer,
                                         srcStageMask,
                                         dstStageMask,
                                         dependencyFlags,
                                         UInt32(memoryBarriers.count),
                                         _memoryBarriers.baseAddress!.assumingMemoryBound(to: VkMemoryBarrier.self),
                                         UInt32(bufferMemoryBarriers.count),
                                         _bufferMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkBufferMemoryBarrier.self),
                                         UInt32(imageMemoryBarriers.count),
                                         _imageMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkImageMemoryBarrier.self))
                }
            }
        }
    }

    public func pushConstants(layout: VulkanPipelineLayout,
                              stageFlags: VkShaderStageFlags,
                              offset: Int,
                              values: UnsafeRawBufferPointer) {
        vkCmdPushConstants(self.commandBuffer,
                           layout.getPipelineLayout(),
                           stageFlags,
                           UInt32(offset),
                           UInt32(values.count),
                           values.baseAddress!)
    }

    public func reset(flags: VkCommandBufferResetFlags = VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT.rawValue) {
        vkResetCommandBuffer(self.commandBuffer,
                             flags)
    }

    public func set(blendConstants: [Float]) {
        precondition(blendConstants.count == 4)

        vkCmdSetBlendConstants(self.commandBuffer, blendConstants)
    }

    public func set(depthBiasConstantFactor: Float,
                    depthBiasClamp: Float,
                    depthBiasSlopeFactor: Float) {
        vkCmdSetDepthBias(self.commandBuffer,
                          depthBiasConstantFactor,
                          depthBiasClamp,
                          depthBiasSlopeFactor)
    }

    public func set(deviceMask: UInt32) {
        vkCmdSetDeviceMask(self.commandBuffer,
                           deviceMask)
    }

    public func set(lineWidth: Float) {
        vkCmdSetLineWidth(self.commandBuffer,
                          lineWidth)
    }

    public func set(minDepthBounds: Float,
                    maxDepthBounds: Float) {
        vkCmdSetDepthBounds(self.commandBuffer,
                            minDepthBounds,
                            maxDepthBounds)
    }

    public func set(event: VulkanEvent,
                    stage: VkPipelineStageFlags = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT.rawValue) {
        vkCmdSetEvent(self.commandBuffer,
                      event.getEvent(),
                      stage)
    }

    public func setScissor(firstScissor: Int = 0,
                           scissors: [VkRect2D]) {
        scissors.withUnsafeBytes { _scissors in
            vkCmdSetScissor(self.commandBuffer,
                            UInt32(firstScissor),
                            UInt32(scissors.count),
                            _scissors.baseAddress!.assumingMemoryBound(to: VkRect2D.self))
        }
    }

    public func setStencilCompareMask(faceMask: VkStencilFaceFlags,
                                      compareMask: UInt32) {
        vkCmdSetStencilCompareMask(self.commandBuffer,
                                   faceMask,
                                   compareMask)
    }

    public func setStencilReference(faceMask: VkStencilFaceFlags,
                                    reference: UInt32) {
        vkCmdSetStencilReference(self.commandBuffer,
                                 faceMask,
                                 reference)
    }

    public func setStencilReference(faceMask: VkStencilFaceFlags,
                                    writeMask: UInt32) {
        vkCmdSetStencilWriteMask(self.commandBuffer,
                                 faceMask,
                                 writeMask)
    }

    public func setViewport(firstViewport: Int = 0,
                            viewports: [VkViewport]) {
        viewports.withUnsafeBytes { _viewports in
            vkCmdSetViewport(self.commandBuffer,
                             UInt32(firstViewport),
                             UInt32(viewports.count),
                             _viewports.baseAddress!.assumingMemoryBound(to: VkViewport.self))
        }
    }

    public func updateBuffer(dstBuffer: VulkanBuffer,
                             dstOffset: Int,
                             data: UnsafeRawBufferPointer) {
        vkCmdUpdateBuffer(self.commandBuffer,
                          dstBuffer.getBuffer(),
                          VkDeviceSize(dstOffset),
                          VkDeviceSize(data.count),
                          data.baseAddress!)
    }
    public func waitEvents(events: [VulkanEvent],
                           srcStageMask: VkPipelineStageFlags,
                           dstStageMask: VkPipelineStageFlags,
                           memoryBarriers: [VulkanMemoryBarrier],
                           bufferMemoryBarriers: [VulkanBufferMemoryBarrier],
                           imageMemoryBarriers: [VulkanImageMemoryBarrier]) {
        let waitEvents = events.map { $0.getEvent() }
        let waitMemoryBarriers = memoryBarriers.map { $0.getMemoryBarrier() }
        let waitBufferMemoryBarriers = bufferMemoryBarriers.map { $0.getBufferMemoryBarrier() }
        let waitImageMemoryBarriers = imageMemoryBarriers.map { $0.getImageMemoryBarrier() }
        let _ = waitEvents.withUnsafeBytes { _events in
            let _ = waitMemoryBarriers.withUnsafeBytes { _memoryBarriers in
                let _ = waitBufferMemoryBarriers.withUnsafeBytes { _bufferMemoryBarriers in
                    let _ = waitImageMemoryBarriers.withUnsafeBytes { _imageMemoryBarriers in
                        vkCmdWaitEvents(self.commandBuffer,
                                        UInt32(events.count),
                                        _events.baseAddress!.assumingMemoryBound(to: VkEvent?.self),
                                        srcStageMask,
                                        dstStageMask,
                                        UInt32(memoryBarriers.count),
                                        _memoryBarriers.baseAddress!.assumingMemoryBound(to: VkMemoryBarrier.self),
                                        UInt32(bufferMemoryBarriers.count),
                                        _bufferMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkBufferMemoryBarrier.self),
                                        UInt32(imageMemoryBarriers.count),
                                        _imageMemoryBarriers.baseAddress!.assumingMemoryBound(to: VkImageMemoryBarrier.self))
                    }
                }
            }
        }
    }
}
