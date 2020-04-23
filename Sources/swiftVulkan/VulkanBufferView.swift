import vulkan
import Foundation

public final class VulkanBufferView {
    private let device: VkDevice
    private let bufferView: VkBufferView

    public init(device: VkDevice,
                bufferView: VkBufferView) {
        self.device = device
        self.bufferView = bufferView
    }

    deinit {
        vkDestroyBufferView(self.device, self.bufferView, nil)
    }

    public func getBufferView() -> VkBufferView {
        return self.bufferView
    }
}
