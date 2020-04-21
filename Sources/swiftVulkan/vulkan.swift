import vulkan
import Foundation

public class VulkanBufferMemoryBarrier: VulkanMemoryBarrier {
    public var srcQueueFamilyIndex: UInt32
    public var dstQueueFamilyIndex: UInt32
    public var buffer: VkBuffer
    public var offset: VkDeviceSize
    public var size: VkDeviceSize

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                srcQueueFamilyIndex: UInt32,
                dstQueueFamilyIndex: UInt32,
                buffer: VkBuffer,
                offset: VkDeviceSize,
                size: VkDeviceSize) {
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.buffer = buffer
        self.offset = offset
        self.size = size
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getBufferMemoryBarrier() -> VkBufferMemoryBarrier {
        var bufferMemoryBarrier = VkBufferMemoryBarrier()

        bufferMemoryBarrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
        bufferMemoryBarrier.srcAccessMask = self.srcAccessMask
        bufferMemoryBarrier.dstAccessMask = self.dstAccessMask
        bufferMemoryBarrier.srcQueueFamilyIndex = self.srcQueueFamilyIndex
        bufferMemoryBarrier.dstQueueFamilyIndex = self.dstQueueFamilyIndex
        bufferMemoryBarrier.buffer = self.buffer
        bufferMemoryBarrier.offset = self.offset
        bufferMemoryBarrier.size = self.size
        return bufferMemoryBarrier
    }
}

public final class VulkanCommandBuffer {
    private let device: VkDevice
    private let commandBuffer: VkCommandBuffer

    public init(device: VkDevice,
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

    public func beginRenderPass(_ renderPass: VulkanRenderPass,
                                  framebuffer: VulkanFramebuffer,
                                  renderArea: VkRect2D,
                                  clearValues: [VkClearValue],
                                  contents: VkSubpassContents) {
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

    public func clearColor(image: VulkanImage,
                           imageLayout: VkImageLayout,
                           color: VkClearColorValue,
                           ranges: [VkImageSubresourceRange]) {
        ranges.withUnsafeBytes { _ranges in
            let _image = image.getImage()
            var _color = color

            vkCmdClearColorImage(self.commandBuffer,
                                 _image,
                                 imageLayout,
                                 &_color,
                                 UInt32(ranges.count),
                                 _ranges.baseAddress!.assumingMemoryBound(to: VkImageSubresourceRange.self))
        }
    }

    public func end() {
        guard vkEndCommandBuffer(self.commandBuffer) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func endRenderPass() {
        vkCmdEndRenderPass(self.commandBuffer)
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
}

public final class VulkanCommandPool {
    private let device: VkDevice
    private let commandPool: VkCommandPool

    public init(device: VkDevice,
                commandPool: VkCommandPool) {
        self.device = device
        self.commandPool = commandPool
    }

    deinit {
        vkDestroyCommandPool(self.device, self.commandPool, nil)
    }

    public func allocateCommandBuffers(count: Int) -> [VulkanCommandBuffer] {
        var commandBufferAllocInfo = VkCommandBufferAllocateInfo()

        commandBufferAllocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
        commandBufferAllocInfo.commandPool = self.commandPool
        commandBufferAllocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
        commandBufferAllocInfo.commandBufferCount = UInt32(count)

        var commandBuffers: [VkCommandBuffer?] = Array(repeating: nil,
                                                       count: count)

        commandBuffers.withUnsafeMutableBytes {
            guard vkAllocateCommandBuffers(self.device, &commandBufferAllocInfo, $0.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return commandBuffers.map { VulkanCommandBuffer(device: self.device,
                                                        commandBuffer: $0!) }
    }
}

public final class VulkanDevice {
    private let device: VkDevice

    public init(device: VkDevice) {
        self.device = device
    }

    deinit {
        vkDestroyDevice(self.device, nil)
    }

    public func createCommandPool(queue: Int) -> VulkanCommandPool {
        var commandPoolCreateInfo = VkCommandPoolCreateInfo()

        commandPoolCreateInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        commandPoolCreateInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue
        commandPoolCreateInfo.queueFamilyIndex = UInt32(queue)

        var commandPool: VkCommandPool? = nil

        guard vkCreateCommandPool(self.device, &commandPoolCreateInfo, nil, &commandPool) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanCommandPool(device: self.device,
                                 commandPool: commandPool!)
    }

    public func createFence(flags: VkFenceCreateFlags = VK_FENCE_CREATE_SIGNALED_BIT.rawValue) -> VulkanFence {
        var fenceCreateInfo = VkFenceCreateInfo()

        fenceCreateInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
        fenceCreateInfo.flags = flags

        var fence: VkFence? = nil

        guard vkCreateFence(self.device, &fenceCreateInfo, nil, &fence) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanFence(device: device,
                           fence: fence!)
    }

    public func createFramebuffer(renderPass: VulkanRenderPass,
                                  imageViews: [VulkanImageView],
                                  width: Int,
                                  height: Int,
                                  layers: Int = 1) -> VulkanFramebuffer {
        var framebuffer: VkFramebuffer? = nil

        imageViews.withUnsafeBytes { _imageViews in
            var framebufferCreateInfo = VkFramebufferCreateInfo()

            framebufferCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
            framebufferCreateInfo.renderPass = renderPass.getRenderPass()
            framebufferCreateInfo.attachmentCount = UInt32(imageViews.count)
            framebufferCreateInfo.pAttachments = _imageViews.baseAddress!.assumingMemoryBound(to: VkImageView?.self)
            framebufferCreateInfo.width = UInt32(width)
            framebufferCreateInfo.height = UInt32(height)
            framebufferCreateInfo.layers = UInt32(layers)

            guard vkCreateFramebuffer(self.device, &framebufferCreateInfo, nil, &framebuffer) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return VulkanFramebuffer(device: self.device,
                                 framebuffer: framebuffer!)
    }

    public func createImageView(image: VulkanImage,
                                viewType: VkImageViewType,
                                format: VkFormat,
                                subresourceRange: VkImageSubresourceRange) -> VulkanImageView {
        var imageView: VkImageView? = nil
        var imageCreateInfo = VkImageViewCreateInfo()

        imageCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
        imageCreateInfo.image = image.getImage()
        imageCreateInfo.viewType = viewType
        imageCreateInfo.format = format
        imageCreateInfo.subresourceRange = subresourceRange

        guard vkCreateImageView(self.device, &imageCreateInfo, nil, &imageView) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanImageView(device: self.device,
                               imageView: imageView!)
    }

    public func createGraphicsPipeline(pipelineCache: VulkanPipelineCache? = nil,
                                       stages: [VulkanPipelineShaderStage],
                                       vertexInputState: VulkanPipelineVertexInputState,
                                       inputAssemblyState: VulkanPipelineInputAssemblyState,
                                       viewportState: VulkanPipelineViewportState,
                                       rasterizationState: VulkanPipelineRasterizationState,
                                       multisampleState: VulkanPipelineMultisampleState,
                                       colorBlendState: VulkanPipelineColorBlendState,
                                       dynamicState: VulkanPipelineDynamicState,
                                       pipelineLayout: VulkanPipelineLayout,
                                       renderPass: VulkanRenderPass,
                                       subpass: Int = 0,
                                       basePipelineHandle: VulkanPipeline? = nil,
                                       basePipelineIndex: Int = 0) -> VulkanPipeline {
        let _pipelineCache = pipelineCache?.getPipelineCache()
        let pipelineStages = stages.map { $0.getPipelineShaderStageCreateInfo() }
        var pipeline: VkPipeline? = nil
        var _vertexInputState = vertexInputState.getPipelineVertexInputStateCreateInfo()
        var _inputAssemblyState = inputAssemblyState.getPipelineInputAssemblyStateCreateInfo()
        var _viewportState = viewportState.getPipelineViewportStateCreateInfo()
        var _rasterizationState = rasterizationState.getPipelineRasterizationStateCreateInfo()
        var _multisampleState = multisampleState.getPipelineMultisampleStateCreateInfo()
        var _colorBlendState = colorBlendState.getPipelineColorBlendStateCreateInfo()
        var _dynamicState = dynamicState.getPipelineDynamicStateCreateInfo()
        let addressOf: (UnsafeRawPointer) -> UnsafeRawPointer = { $0 }

        pipelineStages.withUnsafeBytes { _stages in
            var graphicsPipelineCreateInfo = VkGraphicsPipelineCreateInfo()

            graphicsPipelineCreateInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
            graphicsPipelineCreateInfo.stageCount = UInt32(stages.count)
            graphicsPipelineCreateInfo.pStages = _stages.baseAddress!.assumingMemoryBound(to: VkPipelineShaderStageCreateInfo.self)
            graphicsPipelineCreateInfo.pVertexInputState = addressOf(&_vertexInputState).assumingMemoryBound(to: VkPipelineVertexInputStateCreateInfo.self)
            graphicsPipelineCreateInfo.pInputAssemblyState = addressOf(&_inputAssemblyState).assumingMemoryBound(to: VkPipelineInputAssemblyStateCreateInfo.self)
            graphicsPipelineCreateInfo.pViewportState = addressOf(&_viewportState).assumingMemoryBound(to: VkPipelineViewportStateCreateInfo.self)
            graphicsPipelineCreateInfo.pRasterizationState = addressOf(&_rasterizationState).assumingMemoryBound(to: VkPipelineRasterizationStateCreateInfo.self)
            graphicsPipelineCreateInfo.pMultisampleState = addressOf(&_multisampleState).assumingMemoryBound(to: VkPipelineMultisampleStateCreateInfo.self)
            graphicsPipelineCreateInfo.pColorBlendState = addressOf(&_colorBlendState).assumingMemoryBound(to: VkPipelineColorBlendStateCreateInfo.self)
            graphicsPipelineCreateInfo.pDynamicState = addressOf(&_dynamicState).assumingMemoryBound(to: VkPipelineDynamicStateCreateInfo.self)
            graphicsPipelineCreateInfo.layout = pipelineLayout.getPipelineLayout()
            graphicsPipelineCreateInfo.renderPass = renderPass.getRenderPass()
            graphicsPipelineCreateInfo.subpass = UInt32(subpass)
            graphicsPipelineCreateInfo.basePipelineHandle = basePipelineHandle?.getPipeline()
            graphicsPipelineCreateInfo.basePipelineIndex = Int32(basePipelineIndex)

            guard vkCreateGraphicsPipelines(device, _pipelineCache, 1, &graphicsPipelineCreateInfo, nil, &pipeline) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return VulkanPipeline(device: self.device,
                              pipeline: pipeline!)
    }

    public func createPipelineLayout(pushConstantRanges: [VkPushConstantRange] = []) -> VulkanPipelineLayout {
        return pushConstantRanges.withUnsafeBytes { _pushConstantRanges in
            var pipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo()

            pipelineLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
            pipelineLayoutCreateInfo.pushConstantRangeCount = UInt32(pushConstantRanges.count)
            pipelineLayoutCreateInfo.pPushConstantRanges = _pushConstantRanges.baseAddress!.assumingMemoryBound(to: VkPushConstantRange.self)

            var pipelineLayout: VkPipelineLayout? = nil

            guard vkCreatePipelineLayout(device, &pipelineLayoutCreateInfo, nil, &pipelineLayout) == VK_SUCCESS else {
                preconditionFailure()
            }

            return VulkanPipelineLayout(device: self.device,
                                        pipelineLayout: pipelineLayout!)
        }
    }

    public func createRenderPass(attachments: [VkAttachmentDescription],
                                subpasses: [VkSubpassDescription],
                                dependencies: [VkSubpassDependency]) -> VulkanRenderPass {
        var renderPass: VkRenderPass? = nil

        attachments.withUnsafeBytes { _attachments in
            subpasses.withUnsafeBytes { _subpasses in
                dependencies.withUnsafeBytes { _dependencies in
                    var renderPassCreateInfo = VkRenderPassCreateInfo()

                    renderPassCreateInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
                    renderPassCreateInfo.attachmentCount = UInt32(attachments.count)
                    renderPassCreateInfo.pAttachments = _attachments.baseAddress!.assumingMemoryBound(to: VkAttachmentDescription.self)
                    renderPassCreateInfo.subpassCount = UInt32(subpasses.count)
                    renderPassCreateInfo.pSubpasses = _subpasses.baseAddress!.assumingMemoryBound(to: VkSubpassDescription.self)
                    renderPassCreateInfo.dependencyCount = UInt32(dependencies.count)
                    renderPassCreateInfo.pDependencies = _dependencies.baseAddress!.assumingMemoryBound(to: VkSubpassDependency.self)

                    guard vkCreateRenderPass(device, &renderPassCreateInfo, nil, &renderPass) == VK_SUCCESS else {
                        preconditionFailure()
                    }
                }
            }
        }

        return VulkanRenderPass(device: self.device,
                                renderPass: renderPass!)
    }

    public func createSemaphore() -> VulkanSemaphore {
        var semaphoreCreateInfo = VkSemaphoreCreateInfo()

        semaphoreCreateInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO

        var semaphore: VkSemaphore? = nil

        guard vkCreateSemaphore(self.device, &semaphoreCreateInfo, nil, &semaphore) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSemaphore(device: device,
                               semaphore: semaphore!)
    }

    public func createShaderModule(code: Data) -> VulkanShaderModule {
        var shaderModule: VkShaderModule? = nil

        code.withUnsafeBytes { _code in
            var shaderModuleCreateInfo = VkShaderModuleCreateInfo()

            shaderModuleCreateInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
            shaderModuleCreateInfo.codeSize = code.count
            shaderModuleCreateInfo.pCode = _code.baseAddress!.assumingMemoryBound(to: UInt32.self)

            guard vkCreateShaderModule(self.device, &shaderModuleCreateInfo, nil, &shaderModule) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return VulkanShaderModule(device: self.device,
                                  shaderModule: shaderModule!)
    }

    public func createSwapchain(surface: VkSurfaceKHR,
                                surfaceFormat: VkSurfaceFormatKHR,
                                surfaceCapabilities: VkSurfaceCapabilitiesKHR,
                                presentMode: VkPresentModeKHR) -> VulkanSwapchain {
        let swapchainImageCount = surfaceCapabilities.minImageCount
        let swapchainExtent = surfaceCapabilities.currentExtent
        let swapchainImageFormat = (surfaceFormat.format == VK_FORMAT_UNDEFINED) ? VK_FORMAT_B8G8R8A8_UNORM :
                                                                                   surfaceFormat.format
        var swapchainCreateInfo = VkSwapchainCreateInfoKHR()

        swapchainCreateInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCreateInfo.surface = surface
        swapchainCreateInfo.minImageCount = swapchainImageCount
        swapchainCreateInfo.imageFormat = swapchainImageFormat
        swapchainCreateInfo.imageColorSpace = surfaceFormat.colorSpace
        swapchainCreateInfo.imageExtent = swapchainExtent
        swapchainCreateInfo.imageArrayLayers = 1
        swapchainCreateInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue |
                                         VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue
        swapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
        swapchainCreateInfo.preTransform = surfaceCapabilities.currentTransform
        swapchainCreateInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        swapchainCreateInfo.presentMode = presentMode
        swapchainCreateInfo.clipped = VkBool32(VK_TRUE)

        var swapchain: VkSwapchainKHR? = nil

        guard vkCreateSwapchainKHR(self.device, &swapchainCreateInfo, nil, &swapchain) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanSwapchain(device: self.device,
                               swapchain: swapchain!)
    }

    public func getDeviceQueue(queueFamily: Int,
                               queue: Int) -> VulkanQueue {
        var _queue: VkQueue? = nil

        vkGetDeviceQueue(self.device, UInt32(queueFamily), UInt32(queue), &_queue)
        return VulkanQueue(queue: _queue!)
    }

    public func resetFences(fences: [VulkanFence]) {
        let resetFences = fences.map { $0.getFence() }

        resetFences.withUnsafeBytes { _fences in
            guard vkResetFences(self.device,
                                UInt32(fences.count),
                                _fences.baseAddress!.assumingMemoryBound(to: VkFence?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }
    }

    public func waitForFences(fences: [VulkanFence],
                              waitAll: Bool = true,
                              timeout: UInt64 = .max) {
        let waitFences = fences.map { $0.getFence() }

        waitFences.withUnsafeBytes { _fences in
            guard vkWaitForFences(self.device,
                                  UInt32(fences.count),
                                  _fences.baseAddress!.assumingMemoryBound(to: VkFence?.self),
                                  VkBool32(waitAll ? VK_TRUE : VK_FALSE),
                                  timeout) == VK_SUCCESS else {
                preconditionFailure()
            }

        }
    }

    public func waitIdle() {
        guard vkDeviceWaitIdle(self.device) == VK_SUCCESS else {
            preconditionFailure()
        }
    }
}

public final class VulkanFence {
    private let device: VkDevice
    private let fence: VkFence

    public init(device: VkDevice,
                fence: VkFence) {
        self.device = device
        self.fence = fence
    }

    deinit {
        vkDestroyFence(self.device, self.fence, nil)
    }

    public func getFence() -> VkFence {
        return self.fence
    }
}

public final class VulkanFramebuffer {
    private let device: VkDevice
    private let framebuffer: VkFramebuffer

    public init(device: VkDevice,
                framebuffer: VkFramebuffer) {
        self.device = device
        self.framebuffer = framebuffer
    }

    deinit {
        vkDestroyFramebuffer(self.device, self.framebuffer, nil)
    }

    public func getFramebuffer() -> VkFramebuffer {
        return self.framebuffer
    }
}

public final class VulkanImage {
    private let device: VkDevice
    private let image: VkImage

    public init(device: VkDevice,
                image: VkImage) {
        self.device = device
        self.image = image
    }

    deinit {
        vkDestroyImage(self.device, self.image, nil)
    }

    public func getImage() -> VkImage {
        return self.image
    }
}

public class VulkanImageMemoryBarrier: VulkanMemoryBarrier {
    public var oldLayout: VkImageLayout
    public var newLayout: VkImageLayout
    public var srcQueueFamilyIndex: Int
    public var dstQueueFamilyIndex: Int
    public var image: VulkanImage
    public var subresourceRange: VkImageSubresourceRange

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags,
                oldLayout: VkImageLayout,
                newLayout: VkImageLayout,
                srcQueueFamilyIndex: Int,
                dstQueueFamilyIndex: Int,
                image: VulkanImage,
                subresourceRange: VkImageSubresourceRange) {
        self.oldLayout = oldLayout
        self.newLayout = newLayout
        self.srcQueueFamilyIndex = srcQueueFamilyIndex
        self.dstQueueFamilyIndex = dstQueueFamilyIndex
        self.image = image
        self.subresourceRange = subresourceRange
        super.init(srcAccessMask: srcAccessMask,
                   dstAccessMask: dstAccessMask)
    }

    public func getImageMemoryBarrier() -> VkImageMemoryBarrier {
        var imageMemoryBarrier = VkImageMemoryBarrier()

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
        imageMemoryBarrier.srcAccessMask = self.srcAccessMask
        imageMemoryBarrier.dstAccessMask = self.dstAccessMask
        imageMemoryBarrier.oldLayout = self.oldLayout
        imageMemoryBarrier.newLayout = self.newLayout
        imageMemoryBarrier.srcQueueFamilyIndex = UInt32(self.srcQueueFamilyIndex)
        imageMemoryBarrier.dstQueueFamilyIndex = UInt32(self.dstQueueFamilyIndex)
        imageMemoryBarrier.image = self.image.getImage()
        imageMemoryBarrier.subresourceRange = self.subresourceRange
        return imageMemoryBarrier
    }
}

public final class VulkanImageView {
    private let device: VkDevice
    private let imageView: VkImageView

    public init(device: VkDevice,
                imageView: VkImageView) {
        self.device = device
        self.imageView = imageView
    }

    deinit {
        vkDestroyImageView(self.device, self.imageView, nil)
    }

    public func getImageView() -> VkImageView {
        return self.imageView
    }
}

public final class VulkanInstance {
    private let instance: VkInstance

    public convenience init() {
        var createInfo = VkInstanceCreateInfo()
        var instance: VkInstance? = nil

        guard vkCreateInstance(&createInfo, nil, &instance) == VK_SUCCESS else {
            preconditionFailure()
        }

        self.init(instance: instance!)
    }

    public init(instance: VkInstance) {
        self.instance = instance
    }

    public func getInstance() -> VkInstance {
        return self.instance
    }

    public func getPhysicalDevices() -> [VulkanPhysicalDevice] {
        var physicalDeviceCount = UInt32(0)

        guard vkEnumeratePhysicalDevices(instance, &physicalDeviceCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var physicalDevices: [VkPhysicalDevice?] = Array(repeating: nil,
                                                         count: Int(physicalDeviceCount))

        physicalDevices.withUnsafeMutableBytes {
           guard vkEnumeratePhysicalDevices(instance,
                                            &physicalDeviceCount,
                                            $0.baseAddress!.assumingMemoryBound(to: VkPhysicalDevice?.self)) == VK_SUCCESS else {
               preconditionFailure()
           }
        }

        return physicalDevices.map { VulkanPhysicalDevice(physicalDevice: $0!) }
    }
}

public class VulkanMemoryBarrier {
    public var srcAccessMask: VkAccessFlags
    public var dstAccessMask: VkAccessFlags

    public init(srcAccessMask: VkAccessFlags,
                dstAccessMask: VkAccessFlags) {
        self.srcAccessMask = srcAccessMask
        self.dstAccessMask = dstAccessMask
    }

    public func getMemoryBarrier() -> VkMemoryBarrier {
        var memoryBarrier = VkMemoryBarrier()

        memoryBarrier.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER
        memoryBarrier.srcAccessMask = self.srcAccessMask
        memoryBarrier.dstAccessMask = self.dstAccessMask
        return memoryBarrier
    }
}

public final class VulkanPhysicalDevice {
    private let physicalDevice: VkPhysicalDevice

    internal init(physicalDevice: VkPhysicalDevice) {
        self.physicalDevice = physicalDevice
    }

    public func createDevice(queues: [Int],
                             layerNames: [String],
                             extensions: [String]) -> VulkanDevice {
        precondition(!queues.isEmpty)

        let queuePriorities = Array(repeating: Float(1.0),
                                    count: queues.count)

        return queuePriorities.withUnsafeBytes { _queuePriorities in
            let queueCreateInfos: [VkDeviceQueueCreateInfo] = queues.map {
                var queueCreateInfo = VkDeviceQueueCreateInfo()

                queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                queueCreateInfo.queueFamilyIndex = UInt32($0)
                queueCreateInfo.queueCount = UInt32(queuePriorities.count)
                queueCreateInfo.pQueuePriorities = _queuePriorities.baseAddress!.assumingMemoryBound(to: Float.self)
                return queueCreateInfo
            }

            let enabledLayerNames = layerNames.map { UnsafePointer(strdup($0.withCString { $0 })) }
            let enabledExtensionNames = extensions.map { UnsafePointer(strdup($0.withCString { $0 })) }
            let device: VulkanDevice = { (queueCreateInfos: UnsafePointer <VkDeviceQueueCreateInfo>,
                                          enabledLayerNames: UnsafePointer <UnsafePointer <CChar>?>,
                                          enabledExtensionNames: UnsafePointer <UnsafePointer <CChar>?>) in
                var deviceCreateInfo = VkDeviceCreateInfo()

                deviceCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
                deviceCreateInfo.queueCreateInfoCount = UInt32(queues.count)
                deviceCreateInfo.pQueueCreateInfos = queueCreateInfos
                deviceCreateInfo.enabledLayerCount = UInt32(layerNames.count)
                deviceCreateInfo.ppEnabledLayerNames = enabledLayerNames
                deviceCreateInfo.enabledExtensionCount = UInt32(extensions.count)
                deviceCreateInfo.ppEnabledExtensionNames = enabledExtensionNames

                var device: VkDevice? = nil

                guard vkCreateDevice(self.physicalDevice, &deviceCreateInfo, nil, &device) == VK_SUCCESS else {
                    preconditionFailure()
                }

                return VulkanDevice(device: device!)
            }(queueCreateInfos,
              enabledLayerNames,
              enabledExtensionNames)

            enabledLayerNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            enabledExtensionNames.forEach { free(UnsafeMutableRawPointer(mutating: $0)) }
            return device
        }
    }

    public func getPhysicalDeviceProperties() -> VkPhysicalDeviceProperties {
        var physicalDeviceProperties = VkPhysicalDeviceProperties()

        vkGetPhysicalDeviceProperties(self.physicalDevice, &physicalDeviceProperties)
        return physicalDeviceProperties
    }

    public func getQueueFamilyProperties() -> [VkQueueFamilyProperties] {
        var queueFamilyPropertiesCount = UInt32(0)

        vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevice, &queueFamilyPropertiesCount, nil)

        var queueFamilyProperties = Array(repeating: VkQueueFamilyProperties(),
                                          count: Int(queueFamilyPropertiesCount))

        queueFamilyProperties.withUnsafeMutableBytes {
            vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevice,
                                                     &queueFamilyPropertiesCount,
                                                     $0.baseAddress!.assumingMemoryBound(to: VkQueueFamilyProperties.self))
        }

        return queueFamilyProperties
    }

    public func getSurfaceCapabilities(surface: VkSurfaceKHR) -> VkSurfaceCapabilitiesKHR {
        var surfaceCapabilities = VkSurfaceCapabilitiesKHR()

        guard vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.physicalDevice, surface, &surfaceCapabilities) == VK_SUCCESS else {
            preconditionFailure()
        }

        return surfaceCapabilities
    }

    public func getSurfaceFormats(surface: VkSurfaceKHR) -> [VkSurfaceFormatKHR] {
        var surfaceFormatsCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice, surface, &surfaceFormatsCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var surfaceFormats = Array(repeating: VkSurfaceFormatKHR(),
                                   count: Int(surfaceFormatsCount))

        surfaceFormats.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevice,
                                                       surface,
                                                       &surfaceFormatsCount,
                                                       $0.baseAddress!.assumingMemoryBound(to: VkSurfaceFormatKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return surfaceFormats
    }

    public func getSurfacePresentModes(surface: VkSurfaceKHR) -> [VkPresentModeKHR] {
        var presentModeCount = UInt32(0)

        guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice, surface, &presentModeCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var presentModes = Array(repeating: VkPresentModeKHR(0),
                                 count: Int(presentModeCount))

        presentModes.withUnsafeMutableBytes {
            guard vkGetPhysicalDeviceSurfacePresentModesKHR(self.physicalDevice,
                                                            surface,
                                                            &presentModeCount,
                                                            $0.baseAddress!.assumingMemoryBound(to: VkPresentModeKHR.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return presentModes
    }

    public func isSurfaceSupported(surface: VkSurfaceKHR,
                                   onQueue queueIndex: Int) -> Bool {
        var supportsPresent = VkBool32(VK_FALSE)

        guard vkGetPhysicalDeviceSurfaceSupportKHR(self.physicalDevice, UInt32(queueIndex), surface, &supportsPresent) == VK_SUCCESS else {
            preconditionFailure()
        }

        return supportsPresent == VK_TRUE
    }
}

public final class VulkanPipeline {
    private let device: VkDevice
    private let pipeline: VkPipeline

    public init(device: VkDevice,
                pipeline: VkPipeline) {
        self.device = device
        self.pipeline = pipeline
    }

    deinit {
        vkDestroyPipeline(self.device, self.pipeline, nil)
    }

    public func getPipeline() -> VkPipeline {
        return self.pipeline
    }
}

public final class VulkanPipelineCache {
    private let device: VkDevice
    private let pipelineCache: VkPipelineCache

    public init(device: VkDevice,
                pipelineCache: VkPipelineCache) {
        self.device = device
        self.pipelineCache = pipelineCache
    }

    deinit {
        vkDestroyPipelineCache(self.device, self.pipelineCache, nil)
    }

    public func getPipelineCache() -> VkPipelineCache {
        return self.pipelineCache
    }
}

public final class VulkanPipelineColorBlendState {
    private let logicOpEnable: Bool
    private let attachments: [VkPipelineColorBlendAttachmentState]

    private lazy var attachmentsBuffer: UnsafeBufferPointer <VkPipelineColorBlendAttachmentState> = self.attachments.withUnsafeBytes { $0.bindMemory(to: VkPipelineColorBlendAttachmentState.self) }

    public init(logicOpEnable: Bool,
                attachments: [VkPipelineColorBlendAttachmentState]) {
        self.logicOpEnable = logicOpEnable
        self.attachments = attachments
    }

    public func getPipelineColorBlendStateCreateInfo() -> VkPipelineColorBlendStateCreateInfo {
        var pipelineColorBlendStateCreateInfo = VkPipelineColorBlendStateCreateInfo()

        pipelineColorBlendStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
        pipelineColorBlendStateCreateInfo.logicOpEnable = VkBool32(self.logicOpEnable ? VK_TRUE : VK_FALSE)
        pipelineColorBlendStateCreateInfo.attachmentCount = UInt32(self.attachments.count)
        pipelineColorBlendStateCreateInfo.pAttachments = self.attachmentsBuffer.baseAddress!
        return pipelineColorBlendStateCreateInfo
    }
}

public final class VulkanPipelineDynamicState {
    private let dynamicStates: [VkDynamicState]

    private lazy var dynamicStatesBuffer: UnsafeBufferPointer <VkDynamicState> = self.dynamicStates.withUnsafeBytes { $0.bindMemory(to: VkDynamicState.self) }

    public init(dynamicStates: [VkDynamicState]) {
        self.dynamicStates = dynamicStates
    }

    public func getPipelineDynamicStateCreateInfo() -> VkPipelineDynamicStateCreateInfo {
        var pipelineDynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo()

        pipelineDynamicStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
        pipelineDynamicStateCreateInfo.dynamicStateCount = UInt32(self.dynamicStates.count)
        pipelineDynamicStateCreateInfo.pDynamicStates = self.dynamicStatesBuffer.baseAddress!
        return pipelineDynamicStateCreateInfo
    }
}

public final class VulkanPipelineInputAssemblyState {
    private let topology: VkPrimitiveTopology
    private let primitiveRestartEnable: Bool

    public init(topology: VkPrimitiveTopology,
                primitiveRestartEnable: Bool) {
        self.topology = topology
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

public final class VulkanPipelineLayout {
    private let device: VkDevice
    private let pipelineLayout: VkPipelineLayout

    public init(device: VkDevice,
                pipelineLayout: VkPipelineLayout) {
        self.device = device
        self.pipelineLayout = pipelineLayout
    }

    deinit {
        vkDestroyPipelineLayout(self.device, self.pipelineLayout, nil)
    }

    public func getPipelineLayout() -> VkPipelineLayout {
        return self.pipelineLayout
    }
}

public final class VulkanPipelineMultisampleState {
    private let rasterizationSamples: VkSampleCountFlagBits
    private let sampleShadingEnable: Bool
    private let minSampleShading: Float
    private let sampleMask: [VkSampleMask]
    private let alphaToCoverageEnable: Bool
    private let alphaToOneEnable: Bool

    private lazy var sampleMaskBuffer: UnsafeBufferPointer <VkSampleMask> = self.sampleMask.withUnsafeBytes { $0.bindMemory(to: VkSampleMask.self) }

    public init(rasterizationSamples: VkSampleCountFlagBits,
                sampleShadingEnable: Bool,
                minSampleShading: Float,
                sampleMask: [VkSampleMask],
                alphaToCoverageEnable: Bool,
                alphaToOneEnable: Bool) {
        self.rasterizationSamples = rasterizationSamples
        self.sampleShadingEnable = sampleShadingEnable
        self.minSampleShading = minSampleShading
        self.sampleMask = sampleMask
        self.alphaToCoverageEnable = alphaToCoverageEnable
        self.alphaToOneEnable = alphaToOneEnable
    }

    public func getPipelineMultisampleStateCreateInfo() -> VkPipelineMultisampleStateCreateInfo {
        var pipelineMultisampleStateCreateInfo = VkPipelineMultisampleStateCreateInfo()

        pipelineMultisampleStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
        pipelineMultisampleStateCreateInfo.rasterizationSamples = self.rasterizationSamples
        pipelineMultisampleStateCreateInfo.sampleShadingEnable = VkBool32(self.sampleShadingEnable ? VK_TRUE : VK_FALSE)
        pipelineMultisampleStateCreateInfo.minSampleShading = self.minSampleShading
        pipelineMultisampleStateCreateInfo.pSampleMask = self.sampleMaskBuffer.baseAddress!
        pipelineMultisampleStateCreateInfo.alphaToCoverageEnable = VkBool32(self.alphaToCoverageEnable ? VK_TRUE : VK_FALSE)
        pipelineMultisampleStateCreateInfo.alphaToOneEnable = VkBool32(self.alphaToOneEnable ? VK_TRUE : VK_FALSE)
        return pipelineMultisampleStateCreateInfo
    }
}

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

public final class VulkanPipelineShaderStage {
    private let flags: VkPipelineShaderStageCreateFlags
    private let stage: VkShaderStageFlagBits
    private let shaderModule: VulkanShaderModule
    private let name: UnsafeMutablePointer <CChar>

    public init(flags: VkPipelineShaderStageCreateFlags = 0,
                stage: VkShaderStageFlagBits,
                shaderModule: VulkanShaderModule,
                name: String) {
        self.flags = flags
        self.stage = stage
        self.shaderModule = shaderModule
        self.name = name.withCString { strdup($0) }
    }

    deinit {
        free(self.name)
    }

    public func getPipelineShaderStageCreateInfo() -> VkPipelineShaderStageCreateInfo {
        var pipelineShaderStageCreateInfo = VkPipelineShaderStageCreateInfo()

        pipelineShaderStageCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        pipelineShaderStageCreateInfo.stage = self.stage
        pipelineShaderStageCreateInfo.module = self.shaderModule.getShaderModule()
        pipelineShaderStageCreateInfo.pName = UnsafeRawPointer(self.name).assumingMemoryBound(to: CChar.self)
        return pipelineShaderStageCreateInfo
    }
}

public final class VulkanPipelineVertexInputState {
    public init() {
    }

    public func getPipelineVertexInputStateCreateInfo() -> VkPipelineVertexInputStateCreateInfo {
        var pipelineVertexInputStateCreateInfo = VkPipelineVertexInputStateCreateInfo()

        pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
        return pipelineVertexInputStateCreateInfo
    }
}

public final class VulkanPipelineViewportState {
    private let viewports: [VkViewport]
    private let scissors: [VkRect2D]

    private lazy var viewportsBuffer: UnsafeBufferPointer <VkViewport> = self.viewports.withUnsafeBytes { $0.bindMemory(to: VkViewport.self) }
    private lazy var scissorsBuffer: UnsafeBufferPointer <VkRect2D> = self.scissors.withUnsafeBytes { $0.bindMemory(to: VkRect2D.self) }

    public init(viewports: [VkViewport],
                scissors: [VkRect2D]) {
        self.viewports = viewports
        self.scissors = scissors
    }

    public func getPipelineViewportStateCreateInfo() -> VkPipelineViewportStateCreateInfo {
        var pipelineViewportStateCreateInfo = VkPipelineViewportStateCreateInfo()

        pipelineViewportStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
        pipelineViewportStateCreateInfo.viewportCount = UInt32(max(1, self.viewports.count))
        pipelineViewportStateCreateInfo.pViewports = self.viewportsBuffer.baseAddress!
        pipelineViewportStateCreateInfo.scissorCount = UInt32(max(1, self.scissors.count))
        pipelineViewportStateCreateInfo.pScissors = self.scissorsBuffer.baseAddress!
        return pipelineViewportStateCreateInfo
    }
}

public final class VulkanQueue {
    private let queue: VkQueue

    public init(queue: VkQueue) {
        self.queue = queue
    }

    public func present(waitSemaphores: [VulkanSemaphore],
                        swapchains: [VulkanSwapchain],
                        imageIndices: [Int]) {
        let semaphores = waitSemaphores.map { $0.getSemaphore() }
        let presentSwapchains = swapchains.map { $0.getSwapchain() }
        let presentImageIndices = imageIndices.map { UInt32($0) }
        let _ = semaphores.withUnsafeBytes { _waitSemaphores in
            let _ = presentSwapchains.withUnsafeBytes { _swapchains in
                let _ = presentImageIndices.withUnsafeBytes { _imageIndices in

                    var presentInfo = VkPresentInfoKHR()

                    presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
                    presentInfo.waitSemaphoreCount = UInt32(waitSemaphores.count)
                    presentInfo.pWaitSemaphores = _waitSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)
                    presentInfo.swapchainCount = UInt32(swapchains.count)
                    presentInfo.pSwapchains = _swapchains.baseAddress!.assumingMemoryBound(to: VkSwapchainKHR?.self)
                    presentInfo.pImageIndices = _imageIndices.baseAddress!.assumingMemoryBound(to: UInt32.self)

                    guard vkQueuePresentKHR(self.queue, &presentInfo) == VK_SUCCESS else {
                        preconditionFailure()
                    }
                }
            }
        }
    }

    public func submit(waitSemaphores: [VulkanSemaphore],
                       waitDstStageMask: [VkPipelineStageFlags],
                       commandBuffers: [VulkanCommandBuffer],
                       signalSemaphores: [VulkanSemaphore],
                       fence: VulkanFence? = nil) {
        let submitWaitSemaphores = waitSemaphores.map { $0.getSemaphore() }
        let submitCommandBuffers = commandBuffers.map { $0.getCommandBuffer() }
        let submitSignalSemaphores = signalSemaphores.map { $0.getSemaphore() }
        let _ = submitWaitSemaphores.withUnsafeBytes { _waitSemaphores in
            let _ = submitSignalSemaphores.withUnsafeBytes { _signalSemaphores in
                let _ = submitCommandBuffers.withUnsafeBytes { _commandBuffers in
                    let _ = waitDstStageMask.withUnsafeBytes { _waitDstStageMask in
                        var submitInfo = VkSubmitInfo()

                        submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
                        submitInfo.waitSemaphoreCount = UInt32(waitSemaphores.count)
                        submitInfo.pWaitSemaphores = _waitSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)
                        submitInfo.pWaitDstStageMask = _waitDstStageMask.baseAddress!.assumingMemoryBound(to: VkPipelineStageFlags.self)
                        submitInfo.commandBufferCount = UInt32(commandBuffers.count)
                        submitInfo.pCommandBuffers = _commandBuffers.baseAddress!.assumingMemoryBound(to: VkCommandBuffer?.self)
                        submitInfo.signalSemaphoreCount = UInt32(signalSemaphores.count)
                        submitInfo.pSignalSemaphores = _signalSemaphores.baseAddress!.assumingMemoryBound(to: VkSemaphore?.self)

                        guard vkQueueSubmit(self.queue, 1, &submitInfo, fence?.getFence()) == VK_SUCCESS else {
                            preconditionFailure()
                        }
                    }
                }
            }
        }
    }
}

public final class VulkanRenderPass {
    private let device: VkDevice
    private let renderPass: VkRenderPass

    public init(device: VkDevice,
                renderPass: VkRenderPass) {
        self.device = device
        self.renderPass = renderPass
    }

    deinit {
        vkDestroyRenderPass(self.device, self.renderPass, nil)
    }

    func getRenderPass() -> VkRenderPass {
        return self.renderPass
    }
}

public final class VulkanSemaphore {
    private let device: VkDevice
    private let semaphore: VkSemaphore

    public init(device: VkDevice,
                semaphore: VkSemaphore) {
        self.device = device
        self.semaphore = semaphore
    }

    deinit {
        vkDestroySemaphore(self.device, self.semaphore, nil)
    }

    public func getSemaphore() -> VkSemaphore {
        return self.semaphore
    }
}

public final class VulkanShaderModule {
    private let device: VkDevice
    private let shaderModule: VkShaderModule

    public init(device: VkDevice,
                shaderModule: VkShaderModule) {
        self.device = device
        self.shaderModule = shaderModule
    }

    deinit {
        vkDestroyShaderModule(self.device, self.shaderModule, nil)
    }

    public func getShaderModule() -> VkShaderModule {
        return self.shaderModule
    }
}

public final class VulkanSwapchain {
    private let device: VkDevice
    private let swapchain: VkSwapchainKHR

    public init(device: VkDevice,
                swapchain: VkSwapchainKHR) {
        self.device = device
        self.swapchain = swapchain
    }

    deinit {
        vkDestroySwapchainKHR(self.device, self.swapchain, nil)
    }

    public func acquireNextImage(timeout: UInt64,
                                 semaphore: VulkanSemaphore? = nil,
                                 fence: VulkanFence? = nil) -> Int {
        let _semaphore = semaphore?.getSemaphore()
        let _fence = fence?.getFence()
        var imageIndex = UInt32(0)

        guard vkAcquireNextImageKHR(self.device, self.swapchain, timeout, _semaphore, _fence, &imageIndex) == VK_SUCCESS else {
            preconditionFailure()
        }

        return Int(imageIndex)
    }

    public func getImages() -> [VulkanImage] {
        var imageCount = UInt32(0)

        guard vkGetSwapchainImagesKHR(self.device, self.swapchain, &imageCount, nil) == VK_SUCCESS else {
            preconditionFailure()
        }

        var images: [VkImage?] = Array(repeating: nil,
                                       count: Int(imageCount))

        images.withUnsafeMutableBytes {
            guard vkGetSwapchainImagesKHR(self.device,
                                          self.swapchain,
                                          &imageCount,
                                          $0.baseAddress!.assumingMemoryBound(to: VkImage?.self)) == VK_SUCCESS else {
                preconditionFailure()
            }
        }

        return images.map { VulkanImage(device: self.device,
                                        image: $0!) }
    }

    public func getSwapchain() -> VkSwapchainKHR {
        return self.swapchain
    }
}
