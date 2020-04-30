#include <vulkan/vulkan.h>

#if defined(__linux) && !defined(__ANDROID__)
#include <xcb/xcb.h>
#include <X11/Xlib.h>
#include <vulkan/vulkan_xcb.h>
#include <vulkan/vulkan_xlib.h>
#endif
