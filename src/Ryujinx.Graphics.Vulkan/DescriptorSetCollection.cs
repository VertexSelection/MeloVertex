using Silk.NET.Vulkan;
using System;
using VkBuffer = Silk.NET.Vulkan.Buffer;

namespace Ryujinx.Graphics.Vulkan
{
    struct DescriptorSetCollection : IDisposable
    {
        private DescriptorSetManager.DescriptorPoolHolder _holder;
        private readonly DescriptorSet[] _descriptorSets;
        public readonly int SetsCount => _descriptorSets.Length;

        public DescriptorSetCollection(DescriptorSetManager.DescriptorPoolHolder holder, DescriptorSet[] descriptorSets)
        {
            _holder = holder;
            _descriptorSets = descriptorSets;
        }

        public void InitializeBuffers(int setIndex, int baseBinding, int count, DescriptorType type, VkBuffer dummyBuffer)
        {
            Span<DescriptorBufferInfo> infos = stackalloc DescriptorBufferInfo[count];

            infos.Fill(new DescriptorBufferInfo
            {
                Buffer = dummyBuffer,
                Range = Vk.WholeSize,
            });

            UpdateBuffers(setIndex, baseBinding, infos, type);
        }

        public unsafe void UpdateBuffer(int setIndex, int bindingIndex, DescriptorBufferInfo bufferInfo, DescriptorType type)
        {
            if (bufferInfo.Buffer.Handle != 0UL)
            {
                var writeDescriptorSet = new WriteDescriptorSet
                {
                    SType = StructureType.WriteDescriptorSet,
                    DstSet = _descriptorSets[setIndex],
                    DstBinding = (uint)bindingIndex,
                    DescriptorType = type,
                    DescriptorCount = 1,
                    PBufferInfo = &bufferInfo,
                };

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
            }
        }

        public unsafe void UpdateBuffers(int setIndex, int baseBinding, ReadOnlySpan<DescriptorBufferInfo> bufferInfo, DescriptorType type)
{

    // DEBUG: Validate inputs
    if (bufferInfo.Length == 0)
    {
        Console.WriteLine("bufferInfo is empty.");
        return;
    }

    // DEBUG: Check if _descriptorSets and _holder.Device are properly initialized
    if (_descriptorSets == null || _descriptorSets.Length <= setIndex)
    {
        throw new Exception("Descriptor set at the specified index is null or out of range.");
    }

    if (_holder?.Device == null)
    {
        throw new Exception("_holder.Device is null or uninitialized.");
    }

    // DEBUG: Check each DescriptorBufferInfo in the span
    foreach (var info in bufferInfo)
    {
        if (info.Buffer.Handle == 0)
        {
            return;
            // throw new Exception("One of the buffers in bufferInfo is null or uninitialized.");
        }
    }

    // Proceed if all checks pass
    fixed (DescriptorBufferInfo* pBufferInfo = bufferInfo)
    {
        var writeDescriptorSet = new WriteDescriptorSet
        {
            SType = StructureType.WriteDescriptorSet,
            DstSet = _descriptorSets[setIndex],
            DstBinding = (uint)baseBinding,
            DescriptorType = type,
            DescriptorCount = (uint)bufferInfo.Length,
            PBufferInfo = pBufferInfo
        };

        // Update descriptor sets
        _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
    }
}

        public unsafe void UpdateImage(int setIndex, int bindingIndex, DescriptorImageInfo imageInfo, DescriptorType type)
        {
            if (imageInfo.ImageView.Handle != 0UL)
            {
            
                var writeDescriptorSet = new WriteDescriptorSet
                {
                    SType = StructureType.WriteDescriptorSet,
                    DstSet = _descriptorSets[setIndex],
                    DstBinding = (uint)bindingIndex,
                    DescriptorType = type,
                    DescriptorCount = 1,
                    PImageInfo = &imageInfo,
                };

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
            }
        }

        public unsafe void UpdateImages(int setIndex, int baseBinding, ReadOnlySpan<DescriptorImageInfo> imageInfo, DescriptorType type)
        {

            // DEBUG: Check if imageInfo is Empty
            if (imageInfo.Length == 0)
            {
                
                Console.WriteLine("Error: imageInfo is empty.");
                return;
            }

            // DEBUG: Check the values inside imageInfo
            foreach (var info in imageInfo)
            {
                Console.WriteLine($"Buffer Handle: {info.ImageView.Handle}");
            }
            Console.WriteLine($"BaseBinding: {baseBinding}, Type: {type}, ImageInfo Length: {imageInfo.Length}");


            fixed (DescriptorImageInfo* pImageInfo = imageInfo)
            {
                var writeDescriptorSet = new WriteDescriptorSet
                {
                    SType = StructureType.WriteDescriptorSet,
                    DstSet = _descriptorSets[setIndex],
                    DstBinding = (uint)baseBinding,
                    DescriptorType = type,
                    DescriptorCount = (uint)imageInfo.Length,
                    PImageInfo = pImageInfo,
                };

                

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
            }
        }

        public unsafe void UpdateImagesCombined(int setIndex, int baseBinding, ReadOnlySpan<DescriptorImageInfo> imageInfo, DescriptorType type)
        {
            if (imageInfo.Length == 0)
            {
                return;
            }

            fixed (DescriptorImageInfo* pImageInfo = imageInfo)
            {
                for (int i = 0; i < imageInfo.Length; i++)
                {
                    bool nonNull = imageInfo[i].ImageView.Handle != 0 && imageInfo[i].Sampler.Handle != 0;
                    if (nonNull)
                    {
                        int count = 1;

                        while (i + count < imageInfo.Length &&
                            imageInfo[i + count].ImageView.Handle != 0 &&
                            imageInfo[i + count].Sampler.Handle != 0)
                        {
                            count++;
                        }

                        var writeDescriptorSet = new WriteDescriptorSet
                        {
                            SType = StructureType.WriteDescriptorSet,
                            DstSet = _descriptorSets[setIndex],
                            DstBinding = (uint)(baseBinding + i),
                            DescriptorType = DescriptorType.CombinedImageSampler,
                            DescriptorCount = (uint)count,
                            PImageInfo = pImageInfo,
                        };

                        _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);

                        i += count - 1;
                    }
                }
            }
        }

        public unsafe void UpdateBufferImage(int setIndex, int bindingIndex, BufferView texelBufferView, DescriptorType type)
        {
            if (texelBufferView.Handle != 0UL)
            {
                var writeDescriptorSet = new WriteDescriptorSet
                {
                    SType = StructureType.WriteDescriptorSet,
                    DstSet = _descriptorSets[setIndex],
                    DstBinding = (uint)bindingIndex,
                    DescriptorType = type,
                    DescriptorCount = 1,
                    PTexelBufferView = &texelBufferView,
                };

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
            }
        }

        public unsafe void UpdateBufferImages(int setIndex, int baseBinding, ReadOnlySpan<BufferView> texelBufferView, DescriptorType type)
        {
            if (texelBufferView.Length == 0)
            {
                return;
            }

            fixed (BufferView* pTexelBufferView = texelBufferView)
            {
                for (uint i = 0; i < texelBufferView.Length;)
                {
                    uint count = 1;

                    if (texelBufferView[(int)i].Handle != 0UL)
                    {
                        while (i + count < texelBufferView.Length && texelBufferView[(int)(i + count)].Handle != 0UL)
                        {
                            count++;
                        }

                        var writeDescriptorSet = new WriteDescriptorSet
                        {
                            SType = StructureType.WriteDescriptorSet,
                            DstSet = _descriptorSets[setIndex],
                            DstBinding = (uint)baseBinding + i,
                            DescriptorType = type,
                            DescriptorCount = count,
                            PTexelBufferView = pTexelBufferView + i,
                        };

                        _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
                    }

                    i += count;
                }
            }
        }

        public readonly DescriptorSet[] GetSets()
        {
            return _descriptorSets;
        }

        public void Dispose()
        {
            _holder?.FreeDescriptorSets(this);
            _holder = null;
        }
    }
}
