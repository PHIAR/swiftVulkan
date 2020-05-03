import vulkan
import Foundation

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

    public func toVkFormat() -> VkFormat {
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

public enum VulkanImageType {
    case type1D
    case type2D
    case type3D

    internal func toVkImageType() -> VkImageType {
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

    public func bindImageMemory(deviceMemory: VulkanDeviceMemory,
                                offset: Int) {
        guard vkBindImageMemory(self.device,
                                self.image,
                                deviceMemory.getDeviceMemory(),
                                VkDeviceSize(offset)) == VK_SUCCESS else {
            preconditionFailure()
        }
    }

    public func getImage() -> VkImage {
        return self.image
    }
}
