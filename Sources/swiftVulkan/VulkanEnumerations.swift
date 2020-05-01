import vulkan

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
