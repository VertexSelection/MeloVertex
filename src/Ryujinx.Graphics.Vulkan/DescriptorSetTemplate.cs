using Ryujinx.Graphics.GAL;
using Silk.NET.Vulkan;
using System;
using System.Numerics;
using System.Runtime.CompilerServices;

namespace Ryujinx.Graphics.Vulkan
{
    class DescriptorSetTemplate : IDisposable
    {
        /// <summary>
        /// Renderdoc seems to crash when doing a templated uniform update with count > 1 on a push descriptor.
        /// When this is true, consecutive buffers are always updated individually.
        /// </summary>
        private const bool RenderdocPushCountBug = true;

        private readonly VulkanRenderer _gd;
        private readonly Device _device;

        public readonly DescriptorUpdateTemplate Template;
        public readonly int Size;

        public unsafe DescriptorSetTemplate(
            VulkanRenderer gd,
            Device device,
            ResourceBindingSegment[] segments,
            PipelineLayoutCacheEntry plce,
            PipelineBindPoint pbp,
            int setIndex)
        {
            _gd = gd;
            _device = device;

            // Calculate total number of individual descriptors
            int totalDescriptors = 0;
            for (int seg = 0; seg < segments.Length; seg++)
            {
                totalDescriptors += segments[seg].Count;
            }

            
            DescriptorUpdateTemplateEntry* entries = stackalloc DescriptorUpdateTemplateEntry[totalDescriptors];
            int entryIndex = 0;
            nuint structureOffset = 0;

            for (int seg = 0; seg < segments.Length; seg++)
            {
                ResourceBindingSegment segment = segments[seg];

                int binding = segment.Binding;
                int count = segment.Count;
                DescriptorType descriptorType = segment.Type.Convert();

                // Create separate entries for each descriptor in this segment
                for (int i = 0; i < count; i++)
                {
                    nuint stride;
                    if (IsBufferType(segment.Type))
                    {
                        stride = (nuint)Unsafe.SizeOf<DescriptorBufferInfo>();
                    }
                    else if (IsBufferTextureType(segment.Type))
                    {
                        stride = (nuint)Unsafe.SizeOf<BufferView>();
                    }
                    else
                    {
                        stride = (nuint)Unsafe.SizeOf<DescriptorImageInfo>();
                    }

                    entries[entryIndex] = new DescriptorUpdateTemplateEntry()
                    {
                        DescriptorType = descriptorType,
                        DstBinding = (uint)(binding + i),
                        DescriptorCount = 1, // Always 1 descriptor per entry
                        Offset = structureOffset,
                        Stride = stride
                    };

                    structureOffset += stride;
                    entryIndex++;
                }
            }

            Size = (int)structureOffset;

            var info = new DescriptorUpdateTemplateCreateInfo()
            {
                SType = StructureType.DescriptorUpdateTemplateCreateInfo,
                DescriptorUpdateEntryCount = (uint)totalDescriptors,
                PDescriptorUpdateEntries = entries,

                TemplateType = DescriptorUpdateTemplateType.DescriptorSet,
                DescriptorSetLayout = plce.DescriptorSetLayouts[setIndex],
                PipelineBindPoint = pbp,
                PipelineLayout = plce.PipelineLayout,
                Set = (uint)setIndex,
            };

            DescriptorUpdateTemplate result;
            gd.Api.CreateDescriptorUpdateTemplate(device, &info, null, &result).ThrowOnError();

            Template = result;
        }

        public unsafe DescriptorSetTemplate(
            VulkanRenderer gd,
            Device device,
            ResourceDescriptorCollection descriptors,
            long updateMask,
            PipelineLayoutCacheEntry plce,
            PipelineBindPoint pbp,
            int setIndex)
        {
            _gd = gd;
            _device = device;

            // Create a template from the set usages. Assumes the descriptor set is updated in segment order then binding order.
            int segmentCount = BitOperations.PopCount((ulong)updateMask);

            DescriptorUpdateTemplateEntry* entries = stackalloc DescriptorUpdateTemplateEntry[segmentCount];
            int entry = 0;
            nuint structureOffset = 0;

            foreach (ResourceDescriptor descriptor in descriptors.Descriptors)
            {
                for (int i = 0; i < descriptor.Count; i++)
                {
                    int binding = descriptor.Binding + i;

                    if ((updateMask & (1L << binding)) != 0)
                    {
                        entries[entry] = new DescriptorUpdateTemplateEntry()
                        {
                            DescriptorType = DescriptorType.UniformBuffer,
                            DstBinding = (uint)binding,
                            DescriptorCount = 1, // Always 1 descriptor per entry
                            Offset = structureOffset,
                            Stride = (nuint)Unsafe.SizeOf<DescriptorBufferInfo>()
                        };

                        structureOffset += (nuint)Unsafe.SizeOf<DescriptorBufferInfo>();
                        entry++;
                    }
                }
            }

            Size = (int)structureOffset;

            var info = new DescriptorUpdateTemplateCreateInfo()
            {
                SType = StructureType.DescriptorUpdateTemplateCreateInfo,
                DescriptorUpdateEntryCount = (uint)entry,
                PDescriptorUpdateEntries = entries,

                TemplateType = DescriptorUpdateTemplateType.PushDescriptorsKhr,
                DescriptorSetLayout = plce.DescriptorSetLayouts[setIndex],
                PipelineBindPoint = pbp,
                PipelineLayout = plce.PipelineLayout,
                Set = (uint)setIndex,
            };

            DescriptorUpdateTemplate result;
            gd.Api.CreateDescriptorUpdateTemplate(device, &info, null, &result).ThrowOnError();

            Template = result;
        }

        private static bool IsBufferType(ResourceType type)
        {
            return type == ResourceType.UniformBuffer || type == ResourceType.StorageBuffer;
        }

        private static bool IsBufferTextureType(ResourceType type)
        {
            return type == ResourceType.BufferTexture || type == ResourceType.BufferImage;
        }

        public unsafe void Dispose()
        {
            _gd.Api.DestroyDescriptorUpdateTemplate(_device, Template, null);
        }
    }
}
