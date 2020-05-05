import vulkan

public enum VulkanAttachmentLoadOp {
    case clear
    case dontCare
    case load
}

public extension VulkanAttachmentLoadOp {
    func toVkAttachmentLoadOp() -> VkAttachmentLoadOp {
        switch self {
        case .clear:
            return VK_ATTACHMENT_LOAD_OP_CLEAR

        case .dontCare:
            return VK_ATTACHMENT_LOAD_OP_DONT_CARE

        case .load:
            return VK_ATTACHMENT_LOAD_OP_LOAD
        }
    }
}

public enum VulkanAttachmentStoreOp {
    case dontCare
    case store
}

public extension VulkanAttachmentStoreOp {
    func toVkAttachmentStoreOp() -> VkAttachmentStoreOp {
        switch self {
        case .dontCare:
            return VK_ATTACHMENT_STORE_OP_DONT_CARE

        case .store:
            return VK_ATTACHMENT_STORE_OP_STORE
        }
    }
}

public enum VulkanCompareOp {
    case always
    case equal
    case greater
    case greaterEqual
    case less
    case lessEqual
    case never
    case notEqual
}

internal extension VulkanCompareOp {
    func toVkCompareOp() -> VkCompareOp {
        switch self {
        case .always:
            return VK_COMPARE_OP_NEVER

        case .equal:
            return VK_COMPARE_OP_LESS

        case .greater:
            return VK_COMPARE_OP_EQUAL

        case .greaterEqual:
            return VK_COMPARE_OP_LESS_OR_EQUAL

        case .less:
            return VK_COMPARE_OP_GREATER

        case .lessEqual:
            return VK_COMPARE_OP_NOT_EQUAL

        case .never:
            return VK_COMPARE_OP_GREATER_OR_EQUAL

        case .notEqual:
            return VK_COMPARE_OP_ALWAYS
        }
    }
}

public enum VulkanCullModeFlags {
    case none
    case front
    case back
    case frontAndBack
}

internal extension VulkanCullModeFlags {
    func toVkCullModeFlags() -> VkCullModeFlags {
        switch self {
        case .back:
            return VK_CULL_MODE_BACK_BIT.rawValue

        case .front:
            return VK_CULL_MODE_FRONT_BIT.rawValue

        case .frontAndBack:
            return VK_CULL_MODE_FRONT_AND_BACK.rawValue

        case .none:
            return VK_CULL_MODE_NONE.rawValue
        }
    }
}

public enum VulkanDynamicState {
    case blendConstants
    case depthBias
    case depthBounds
    case lineWidth
    case scissor
    case stencilCompareMask
    case stencilReference
    case stencilWriteMask
    case viewport
}

internal extension VulkanDynamicState {
    func toVkDynamicState() -> VkDynamicState {
        switch self {
        case .blendConstants:
            return VK_DYNAMIC_STATE_VIEWPORT

        case .depthBias:
            return VK_DYNAMIC_STATE_SCISSOR

        case .depthBounds:
            return VK_DYNAMIC_STATE_LINE_WIDTH

        case .lineWidth:
            return VK_DYNAMIC_STATE_DEPTH_BIAS

        case .scissor:
            return VK_DYNAMIC_STATE_BLEND_CONSTANTS

        case .stencilCompareMask:
            return VK_DYNAMIC_STATE_DEPTH_BOUNDS

        case .stencilReference:
            return VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK

        case .stencilWriteMask:
            return VK_DYNAMIC_STATE_STENCIL_WRITE_MASK

        case .viewport:
            return VK_DYNAMIC_STATE_STENCIL_REFERENCE
        }
    }
}

public enum VulkanFrontFace {
    case clockwise
    case counterClockwise
}

internal extension VulkanFrontFace {
    func toVkFrontFace() -> VkFrontFace {
        switch self {
        case .clockwise:
            return VK_FRONT_FACE_CLOCKWISE

        case .counterClockwise:
            return VK_FRONT_FACE_COUNTER_CLOCKWISE
        }
    }
}


public enum VulkanFormat {
    case undefined
    case a2r10g10b10SNormPack32
    case a2r10g10b10UNormPack32
    case b8g8r8a8UNorm
    case r8SInt
    case r8g8SInt
    case r8g8b8SInt
    case r8g8b8a8SInt
    case r8SNorm
    case r8g8SNorm
    case r8g8b8SNorm
    case r8g8b8a8SNorm
    case r32SFloat
    case r32g32SFloat
    case r32g32b32SFloat
    case r32g32b32a32SFloat
    case r16SFloat
    case r16g16SFloat
    case r16g16b16SFloat
    case r16g16b16a16SFloat
    case r32SInt
    case r32g32SInt
    case r32g32b32SInt
    case r32g32b32a32SInt
    case r16SInt
    case r16g16SInt
    case r16g16b16SInt
    case r16g16b16a16SInt
    case r16SNorm
    case r16g16SNorm
    case r16g16b16SNorm
    case r16g16b16a16SNorm
    case r8UInt
    case r8g8UInt
    case r8g8b8UInt
    case r8g8b8a8UInt
    case r8UNorm
    case r8g8UNorm
    case r8g8b8UNorm
    case r8g8b8a8UNorm
    case r32UInt
    case r32g32UInt
    case r32g32b32UInt
    case r32g32b32a32UInt
    case r16UInt
    case r16g16UInt
    case r16g16b16UInt
    case r16g16b16a16UInt
    case r16UNorm
    case r16g16UNorm
    case r16g16b16UNorm
    case r16g16b16a16UNorm
}

public extension VulkanFormat {
    func toVkFormat() -> VkFormat {
        switch self {
        case .undefined:
            return VK_FORMAT_UNDEFINED

        case .a2r10g10b10SNormPack32:
            return VK_FORMAT_A2R10G10B10_SNORM_PACK32

        case .a2r10g10b10UNormPack32:
            return VK_FORMAT_A2R10G10B10_UNORM_PACK32

        case .b8g8r8a8UNorm:
            return VK_FORMAT_B8G8R8A8_UNORM

        case .r8SInt:
            return VK_FORMAT_R8_SINT

        case .r8g8SInt:
            return VK_FORMAT_R8G8_SINT

        case .r8g8b8SInt:
            return VK_FORMAT_R8G8B8_SINT

        case .r8g8b8a8SInt:
            return VK_FORMAT_R8G8B8A8_SINT

        case .r8SNorm:
            return VK_FORMAT_R8_SNORM

        case .r8g8SNorm:
            return VK_FORMAT_R8G8_SNORM

        case .r8g8b8SNorm:
            return VK_FORMAT_R8G8B8_SNORM

        case .r8g8b8a8SNorm:
            return VK_FORMAT_R8G8B8A8_SNORM

        case .r32SFloat:
            return VK_FORMAT_R32_SFLOAT

        case .r32g32SFloat:
            return VK_FORMAT_R32G32_SFLOAT

        case .r32g32b32SFloat:
            return VK_FORMAT_R32G32B32_SFLOAT

        case .r32g32b32a32SFloat:
            return VK_FORMAT_R32G32B32A32_SFLOAT

        case .r16SFloat:
            return VK_FORMAT_R16_SFLOAT

        case .r16g16SFloat:
            return VK_FORMAT_R16G16_SFLOAT

        case .r16g16b16SFloat:
            return VK_FORMAT_R16G16B16_SFLOAT

        case .r16g16b16a16SFloat:
            return VK_FORMAT_R16G16B16A16_SFLOAT

        case .r32SInt:
            return VK_FORMAT_R32_SINT

        case .r32g32SInt:
            return VK_FORMAT_R32G32_SINT

        case .r32g32b32SInt:
            return VK_FORMAT_R32G32B32_SINT

        case .r32g32b32a32SInt:
            return VK_FORMAT_R32G32B32A32_SINT

        case .r16SInt:
            return VK_FORMAT_R16_SINT

        case .r16g16SInt:
            return VK_FORMAT_R16G16_SINT

        case .r16g16b16SInt:
            return VK_FORMAT_R16G16B16_SINT

        case .r16g16b16a16SInt:
            return VK_FORMAT_R16G16B16A16_SINT

        case .r16SNorm:
            return VK_FORMAT_R16_SNORM

        case .r16g16SNorm:
            return VK_FORMAT_R16G16_SNORM

        case .r16g16b16SNorm:
            return VK_FORMAT_R16G16B16_SNORM

        case .r16g16b16a16SNorm:
            return VK_FORMAT_R16G16B16A16_SNORM

        case .r8UInt:
            return VK_FORMAT_R8_UINT

        case .r8g8UInt:
            return VK_FORMAT_R8G8_UINT

        case .r8g8b8UInt:
            return VK_FORMAT_R8G8B8_UINT

        case .r8g8b8a8UInt:
            return VK_FORMAT_R8G8B8A8_UINT

        case .r8UNorm:
            return VK_FORMAT_R8_UNORM

        case .r8g8UNorm:
            return VK_FORMAT_R8G8_UNORM

        case .r8g8b8UNorm:
            return VK_FORMAT_R8G8B8_UNORM

        case .r8g8b8a8UNorm:
            return VK_FORMAT_R8G8B8A8_UNORM

        case .r32UInt:
            return VK_FORMAT_R32_UINT

        case .r32g32UInt:
            return VK_FORMAT_R32G32_UINT

        case .r32g32b32UInt:
            return VK_FORMAT_R32G32B32_UINT

        case .r32g32b32a32UInt:
            return VK_FORMAT_R32G32B32A32_UINT

        case .r16UInt:
            return VK_FORMAT_R16_UINT

        case .r16g16UInt:
            return VK_FORMAT_R16G16_UINT

        case .r16g16b16UInt:
            return VK_FORMAT_R16G16B16_UINT

        case .r16g16b16a16UInt:
            return VK_FORMAT_R16G16B16A16_UINT

        case .r16UNorm:
            return VK_FORMAT_R16_UNORM

        case .r16g16UNorm:
            return VK_FORMAT_R16G16_UNORM

        case .r16g16b16UNorm:
            return VK_FORMAT_R16G16B16_UNORM

        case .r16g16b16a16UNorm:
            return VK_FORMAT_R16G16B16A16_UNORM
        }
    }
}

public enum VulkanImageLayout {
    case undefined
    case general
    case colorAttachmentOptimal
    case depthStencilAttachmentOptimal
    case depthStencilReadOnlyOptimal
    case shaderReadOnlyOptimal
    case transferSrcOptimal
    case transferDstOptimal
    case preinitialized
    case depthReadOnlyStencilAttachmentOptimal
    case depthAttachmentStencilReadOnlyOptimal
    case presentSrcKHR
    case sharedPresentKHR
}

internal extension VulkanImageLayout {
    func toVkImageLayout() -> VkImageLayout {
        switch self {
        case .undefined:
            return VK_IMAGE_LAYOUT_UNDEFINED

        case .general:
            return VK_IMAGE_LAYOUT_GENERAL

        case .colorAttachmentOptimal:
            return VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

        case .depthStencilAttachmentOptimal:
            return VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL

        case .depthStencilReadOnlyOptimal:
            return VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL

        case .shaderReadOnlyOptimal:
            return VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL

        case .transferSrcOptimal:
            return VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL

        case .transferDstOptimal:
            return VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL

        case .preinitialized:
            return VK_IMAGE_LAYOUT_PREINITIALIZED

        case .depthReadOnlyStencilAttachmentOptimal:
            return VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL

        case .depthAttachmentStencilReadOnlyOptimal:
            return VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL

        case .presentSrcKHR:
            return VK_IMAGE_LAYOUT_PRESENT_SRC_KHR

        case .sharedPresentKHR:
            return VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR

        }
    }
}

public enum VulkanImageType {
    case type1D
    case type2D
    case type3D
}

internal extension VulkanImageType {
    func toVkImageType() -> VkImageType {
        switch self {
        case .type1D:
            return VK_IMAGE_TYPE_1D

        case .type2D:
            return VK_IMAGE_TYPE_2D

        case .type3D:
            return VK_IMAGE_TYPE_3D
        }
    }
}

public enum VulkanImageViewType {
    case type1D
    case type1DArray
    case type2D
    case type2DArray
    case type3D
    case typeCube
    case typeCubeArray
}

internal extension VulkanImageViewType {
    func toVkImageViewType() -> VkImageViewType {
        switch self {
        case .type1D:
            return VK_IMAGE_VIEW_TYPE_1D

        case .type1DArray:
            return VK_IMAGE_VIEW_TYPE_1D_ARRAY

        case .type2D:
            return VK_IMAGE_VIEW_TYPE_2D

        case .type2DArray:
            return VK_IMAGE_VIEW_TYPE_2D_ARRAY

        case .type3D:
            return VK_IMAGE_VIEW_TYPE_3D

        case .typeCube:
            return VK_IMAGE_VIEW_TYPE_CUBE

        case .typeCubeArray:
            return VK_IMAGE_VIEW_TYPE_CUBE_ARRAY
        }
    }
}

public enum VulkanIndexType {
    case uInt16
    case uInt32
}

internal extension VulkanIndexType {
    func toVkIndexType() -> VkIndexType {
        switch self {
        case .uInt16:
            return VK_INDEX_TYPE_UINT16

        case .uInt32:
            return VK_INDEX_TYPE_UINT32
        }
    }
}

public enum VulkanPolygonMode {
    case fill
    case fillRectangle
    case line
    case point
}

internal extension VulkanPolygonMode {
    func toVkPolygonMode() -> VkPolygonMode {
        switch self {
        case .fill:
            return VK_POLYGON_MODE_FILL

        case .fillRectangle:
            return VK_POLYGON_MODE_FILL_RECTANGLE_NV

        case .line:
            return VK_POLYGON_MODE_LINE

        case .point:
            return VK_POLYGON_MODE_POINT
        }
    }
}

public enum VulkanPrimitiveTopology {
    case lineList
    case lineListWithAdjacency
    case lineStrip
    case lineStripWithAdjacency
    case pointList
    case triangleList
    case triangleListWithAdjacency
    case triangleFan
    case triangleStrip
    case triangleStripWithAdjacency
}

internal extension VulkanPrimitiveTopology {
    func toVkPrimitiveTopology() -> VkPrimitiveTopology {
        switch self {
        case .lineList:
            return VK_PRIMITIVE_TOPOLOGY_LINE_LIST

        case .lineListWithAdjacency:
            return VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY

        case .lineStrip:
            return VK_PRIMITIVE_TOPOLOGY_LINE_STRIP

        case .lineStripWithAdjacency:
            return VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY

        case .pointList:
            return VK_PRIMITIVE_TOPOLOGY_POINT_LIST

        case .triangleList:
            return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST

        case .triangleListWithAdjacency:
            return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY

        case .triangleFan:
            return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN

        case .triangleStrip:
            return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP

        case .triangleStripWithAdjacency:
            return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY
        }
    }
}

public enum VulkanStencilOp {
    case decrementAndClamp
    case decrementAndWrap
    case keep
    case incrementAndClamp
    case incrementAndWrap
    case invert
    case replace
    case zero
}

internal extension VulkanStencilOp {
    func toVkStencilOp() -> VkStencilOp {
        switch self {
        case .decrementAndClamp:
            return VK_STENCIL_OP_KEEP

        case .decrementAndWrap:
            return VK_STENCIL_OP_ZERO

        case .keep:
            return VK_STENCIL_OP_REPLACE

        case .incrementAndClamp:
            return VK_STENCIL_OP_INCREMENT_AND_CLAMP

        case .incrementAndWrap:
            return VK_STENCIL_OP_DECREMENT_AND_CLAMP

        case .invert:
            return VK_STENCIL_OP_INVERT

        case .replace:
            return VK_STENCIL_OP_INCREMENT_AND_WRAP

        case .zero:
            return VK_STENCIL_OP_DECREMENT_AND_WRAP
        }
    }
}

