import vulkan
import Foundation

public final class VulkanDevice {
    private let physicalDevice: VulkanPhysicalDevice
    private let device: VkDevice

    public init(physicalDevice: VulkanPhysicalDevice,
                device: VkDevice) {
        self.physicalDevice = physicalDevice
        self.device = device
    }

    deinit {
        vkDestroyDevice(self.device, nil)
    }

    public func allocateDescriptorSets(descriptorPool: VulkanDescriptorPool,
                                       setLayouts: [VulkanDescriptorSetLayout]) -> [VulkanDescriptorSet] {
        let descriptorSetLayouts = setLayouts.map { $0.getDescriptorSetLayout() }

        return descriptorSetLayouts.withUnsafeBytes { _setLayouts in
            var allocateInfo = VkDescriptorSetAllocateInfo()

            allocateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO
            allocateInfo.descriptorPool = descriptorPool.getDescriptorPool()
            allocateInfo.descriptorSetCount = UInt32(setLayouts.count)
            allocateInfo.pSetLayouts = _setLayouts.baseAddress!.assumingMemoryBound(to: VkDescriptorSetLayout?.self)

            var descriptorSets: [VkDescriptorSet?] = Array(repeating: nil,
                                                          count: setLayouts.count)

            descriptorSets.withUnsafeMutableBytes { _descriptorSets in
                guard vkAllocateDescriptorSets(self.device,
                                               &allocateInfo,
                                               _descriptorSets.baseAddress!.assumingMemoryBound(to: VkDescriptorSet?.self)) == VK_SUCCESS else {
                    preconditionFailure()
                }
            }

            return descriptorSets.map { VulkanDescriptorSet(device: self.device,
                                                            descriptorPool: descriptorPool.getDescriptorPool(),
                                                            descriptorSet: $0!) }
        }
    }

    public func allocateMemory(size: Int,
                               memoryTypeIndex: Int) -> VulkanDeviceMemory {
        var allocateInfo = VkMemoryAllocateInfo()

        allocateInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
        allocateInfo.allocationSize = VkDeviceSize(size)
        allocateInfo.memoryTypeIndex = UInt32(memoryTypeIndex)

        var deviceMemory: VkDeviceMemory? = nil

        guard vkAllocateMemory(self.device, &allocateInfo, nil, &deviceMemory) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanDeviceMemory(device: self.device,
                                  deviceMemory: deviceMemory!)
    }

    public func createBuffer(size: Int,
                             usage: VkBufferUsageFlags,
                             sharingMode: VkSharingMode = VK_SHARING_MODE_EXCLUSIVE,
                             queueFamilies: [Int]) -> VulkanBuffer {
        return queueFamilies.map { UInt32($0) }.withUnsafeBytes { _queueFamilies in
            var bufferCreateInfo = VkBufferCreateInfo()

            bufferCreateInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
            bufferCreateInfo.size = VkDeviceSize(size)
            bufferCreateInfo.usage = usage
            bufferCreateInfo.sharingMode = sharingMode
            bufferCreateInfo.queueFamilyIndexCount = UInt32(queueFamilies.count)
            bufferCreateInfo.pQueueFamilyIndices = _queueFamilies.baseAddress!.assumingMemoryBound(to: UInt32.self)

            var buffer: VkBuffer? = nil

            guard vkCreateBuffer(self.device, &bufferCreateInfo, nil, &buffer) == VK_SUCCESS else {
                preconditionFailure()
            }

            return VulkanBuffer(device: self.device,
                                buffer: buffer!)
        }
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

        return VulkanCommandPool(device: self,
                                 commandPool: commandPool!)
    }

    public func createComputePipeline(pipelineCache: VulkanPipelineCache? = nil,
                                      flags: VkPipelineCreateFlags = 0,
                                      stage: VulkanPipelineShaderStage,
                                      layout: VulkanPipelineLayout,
                                      basePipelineHandle: VulkanPipeline? = nil,
                                      basePipelineIndex: Int = 0) -> VulkanPipeline {
        var computePipelineCreateInfo = VkComputePipelineCreateInfo()

        computePipelineCreateInfo.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO
        computePipelineCreateInfo.flags = flags
        computePipelineCreateInfo.stage = stage.getPipelineShaderStageCreateInfo()
        computePipelineCreateInfo.layout = layout.getPipelineLayout()
        computePipelineCreateInfo.basePipelineHandle = basePipelineHandle?.getPipeline()
        computePipelineCreateInfo.basePipelineIndex = Int32(basePipelineIndex)

        var pipeline: VkPipeline? = nil

        guard vkCreateComputePipelines(self.device,
                                       pipelineCache?.getPipelineCache(),
                                       1,
                                       &computePipelineCreateInfo,
                                       nil,
                                       &pipeline) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanPipeline(device: self.device,
                              pipeline: pipeline!)
    }

    public func createDescriptorPool(flags: VkDescriptorPoolCreateFlags = 0,
                                     maxSets: Int,
                                     poolSizes: [VkDescriptorPoolSize]) -> VulkanDescriptorPool {
        return poolSizes.withUnsafeBytes { _poolSizes in
            var descriptorPoolCreateInfo = VkDescriptorPoolCreateInfo()

            descriptorPoolCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
            descriptorPoolCreateInfo.flags = flags
            descriptorPoolCreateInfo.maxSets = UInt32(maxSets)
            descriptorPoolCreateInfo.poolSizeCount = UInt32(poolSizes.count)
            descriptorPoolCreateInfo.pPoolSizes = _poolSizes.baseAddress!.assumingMemoryBound(to: VkDescriptorPoolSize.self)

            var descriptorPool: VkDescriptorPool? = nil

            guard vkCreateDescriptorPool(self.device,
                                         &descriptorPoolCreateInfo,
                                         nil,
                                         &descriptorPool) == VK_SUCCESS else {
                preconditionFailure()
            }

            return VulkanDescriptorPool(device: self.device,
                                        descriptorPool: descriptorPool!)
        }
    }

    public func createDescriptorSetLayout(flags: VkDescriptorSetLayoutCreateFlags = 0,
                                          bindings: [VulkanDescriptorSetLayoutBinding]) -> VulkanDescriptorSetLayout {
        let descriptorBindings = bindings.map { $0.getDescriptorSetLayoutBinding() }

        return descriptorBindings.withUnsafeBytes { _bindings in
            var descriptorSetLayoutCreateInfo = VkDescriptorSetLayoutCreateInfo()

            descriptorSetLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
            descriptorSetLayoutCreateInfo.flags = flags
            descriptorSetLayoutCreateInfo.bindingCount = UInt32(bindings.count)
            descriptorSetLayoutCreateInfo.pBindings = _bindings.baseAddress!.assumingMemoryBound(to: VkDescriptorSetLayoutBinding.self)

            var descriptorSetLayout: VkDescriptorSetLayout? = nil

            guard vkCreateDescriptorSetLayout(self.device,
                                            &descriptorSetLayoutCreateInfo,
                                            nil,
                                            &descriptorSetLayout) == VK_SUCCESS else {
                preconditionFailure()
            }

            return VulkanDescriptorSetLayout(device: self.device,
                                            descriptorSetLayout: descriptorSetLayout!)
        }
    }

    public func createEvent() -> VulkanEvent {
        var eventCreateInfo = VkEventCreateInfo()

        eventCreateInfo.sType = VK_STRUCTURE_TYPE_EVENT_CREATE_INFO

        var event: VkEvent? = nil

        guard vkCreateEvent(self.device, &eventCreateInfo, nil, &event) == VK_SUCCESS else {
            preconditionFailure()
        }

        return VulkanEvent(device: device,
                           event: event!)
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

    public func createGraphicsPipeline(pipelineCache: VulkanPipelineCache? = nil,
                                       stages: [VulkanPipelineShaderStage],
                                       vertexInputState: VulkanPipelineVertexInputState,
                                       inputAssemblyState: VulkanPipelineInputAssemblyState,
                                       viewportState: VulkanPipelineViewportState,
                                       rasterizationState: VulkanPipelineRasterizationState,
                                       multisampleState: VulkanPipelineMultisampleState,
                                       colorBlendState: VulkanPipelineColorBlendState,
                                       dynamicStates: [VulkanDynamicState],
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
        let piplelineDynamicStates = dynamicStates.map { $0.toVkDynamicState() }
        let addressOf: (UnsafeRawPointer) -> UnsafeRawPointer = { $0 }

        pipelineStages.withUnsafeBytes { _stages in
            piplelineDynamicStates.withUnsafeBytes { _dynamicStates in
                var dynamicStateCreateInfo = VkPipelineDynamicStateCreateInfo()

                dynamicStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
                dynamicStateCreateInfo.dynamicStateCount = UInt32(dynamicStates.count)
                dynamicStateCreateInfo.pDynamicStates = _dynamicStates.baseAddress!.assumingMemoryBound(to: VkDynamicState.self)

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
                graphicsPipelineCreateInfo.pDynamicState = addressOf(&dynamicStateCreateInfo).assumingMemoryBound(to: VkPipelineDynamicStateCreateInfo.self)
                graphicsPipelineCreateInfo.layout = pipelineLayout.getPipelineLayout()
                graphicsPipelineCreateInfo.renderPass = renderPass.getRenderPass()
                graphicsPipelineCreateInfo.subpass = UInt32(subpass)
                graphicsPipelineCreateInfo.basePipelineHandle = basePipelineHandle?.getPipeline()
                graphicsPipelineCreateInfo.basePipelineIndex = Int32(basePipelineIndex)

                guard vkCreateGraphicsPipelines(device, _pipelineCache, 1, &graphicsPipelineCreateInfo, nil, &pipeline) == VK_SUCCESS else {
                    preconditionFailure()
                }
            }
        }

        return VulkanPipeline(device: self.device,
                              pipeline: pipeline!)
    }

    public func createImage(flags: VkImageCreateFlags,
                            imageType: VulkanImageType,
                            format: VulkanFormat,
                            extent: VkExtent3D,
                            mipLevels: Int,
                            arrayLayers: Int,
                            samples: VkSampleCountFlagBits = VK_SAMPLE_COUNT_1_BIT,
                            tiling: VkImageTiling = VK_IMAGE_TILING_OPTIMAL,
                            usage: VkImageUsageFlags,
                            sharingMode: VkSharingMode = VK_SHARING_MODE_EXCLUSIVE,
                            queueFamilies: [Int],
                            initialLayout: VkImageLayout = VK_IMAGE_LAYOUT_UNDEFINED) -> VulkanImage {
        return queueFamilies.map { UInt32($0) }.withUnsafeBytes { _queueFamilies in
            var imageCreateInfo = VkImageCreateInfo()

            imageCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
            imageCreateInfo.flags = flags
            imageCreateInfo.imageType = imageType.toVkImageType()
            imageCreateInfo.format = format.toVkFormat()
            imageCreateInfo.extent = extent
            imageCreateInfo.mipLevels = UInt32(mipLevels)
            imageCreateInfo.arrayLayers = UInt32(arrayLayers)
            imageCreateInfo.samples = samples
            imageCreateInfo.tiling = tiling
            imageCreateInfo.usage = usage
            imageCreateInfo.sharingMode = sharingMode
            imageCreateInfo.queueFamilyIndexCount = UInt32(queueFamilies.count)
            imageCreateInfo.pQueueFamilyIndices = _queueFamilies.baseAddress!.assumingMemoryBound(to: UInt32.self)
            imageCreateInfo.initialLayout = initialLayout

            var image: VkImage? = nil

            guard vkCreateImage(self.device, &imageCreateInfo, nil, &image) == VK_SUCCESS else {
                preconditionFailure()
            }

            return VulkanImage(device: self.device,
                                image: image!)
        }
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

    public func createPipelineLayout(descriptorSetLayouts: [VulkanDescriptorSetLayout],
                                     pushConstantRanges: [VkPushConstantRange] = []) -> VulkanPipelineLayout {
        let pipelineDescriptorSetLayouts = descriptorSetLayouts.map { $0.getDescriptorSetLayout() }
        return pipelineDescriptorSetLayouts.withUnsafeBytes { _descriptorSetLayouts in
            pushConstantRanges.withUnsafeBytes { _pushConstantRanges in
                var pipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo()

                pipelineLayoutCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
                pipelineLayoutCreateInfo.setLayoutCount = UInt32(descriptorSetLayouts.count)
                pipelineLayoutCreateInfo.pSetLayouts = _descriptorSetLayouts.baseAddress!.assumingMemoryBound(to: VkDescriptorSetLayout?.self)
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

    public func createSwapchain(surface: VulkanSurface,
                                surfaceFormat: VkSurfaceFormatKHR,
                                surfaceCapabilities: VkSurfaceCapabilitiesKHR,
                                swapchainImageCount: Int,
                                presentMode: VkPresentModeKHR) -> VulkanSwapchain {
        let swapchainExtent = surfaceCapabilities.currentExtent
        let swapchainImageFormat = (surfaceFormat.format == VK_FORMAT_UNDEFINED) ? VK_FORMAT_B8G8R8A8_UNORM :
                                                                                   surfaceFormat.format
        var swapchainCreateInfo = VkSwapchainCreateInfoKHR()

        swapchainCreateInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCreateInfo.surface = surface.getSurface()
        swapchainCreateInfo.minImageCount = UInt32(swapchainImageCount)
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

    public func getDevice() -> VkDevice {
        return self.device
    }

    public func getDeviceQueue(queueFamily: Int,
                               queue: Int) -> VulkanQueue {
        var _queue: VkQueue? = nil

        vkGetDeviceQueue(self.device, UInt32(queueFamily), UInt32(queue), &_queue)
        return VulkanQueue(queue: _queue!)
    }

    public func getPhysicalDevice() -> VulkanPhysicalDevice {
        return self.physicalDevice
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
