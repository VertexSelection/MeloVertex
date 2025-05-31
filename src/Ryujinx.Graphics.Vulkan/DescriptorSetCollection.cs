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

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
            }
        }


        public unsafe void UpdateBuffers(int setIndex, int baseBinding, ReadOnlySpan<DescriptorBufferInfo> bufferInfo, DescriptorType type)
        {
            for (int i = 0; i < bufferInfo.Length; i++)
            {
                fixed (DescriptorBufferInfo* pBufferInfo = &bufferInfo[i])
                {
                    var writeDescriptorSet = new WriteDescriptorSet
                    {
                        SType = StructureType.WriteDescriptorSet,
                        DstSet = _descriptorSets[setIndex],
                        DstBinding = (uint)(baseBinding + i),
                        DescriptorType = type,
                        DescriptorCount = 1,
                        PBufferInfo = pBufferInfo
                    };

                    _holder.Api.UpdateDescriptorSets(_holder.Device, 1, writeDescriptorSet, 0, null);
                }
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

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
            }
        }

        public unsafe void UpdateImages(int setIndex, int baseBinding, ReadOnlySpan<DescriptorImageInfo> imageInfo, DescriptorType type)
        {
            for (int i = 0; i < imageInfo.Length; i++)
            {
                fixed (DescriptorImageInfo* pImageInfo = &imageInfo[i])
                {
                    var writeDescriptorSet = new WriteDescriptorSet
                    {
                        SType = StructureType.WriteDescriptorSet,
                        DstSet = _descriptorSets[setIndex],
                        DstBinding = (uint)(baseBinding + i),
                        DescriptorType = type,
                        DescriptorCount = 1,
                        PImageInfo = pImageInfo,
                    };

                    _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
                }
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
                        var writeDescriptorSet = new WriteDescriptorSet
                        {
                            SType = StructureType.WriteDescriptorSet,
                            DstSet = _descriptorSets[setIndex],
                            DstBinding = (uint)(baseBinding + i),
                            DescriptorType = type,
                            DescriptorCount = 1,
                            PImageInfo = pImageInfo + i,
                        };


                        _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
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

                _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
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
                for (int i = 0; i < texelBufferView.Length; i++)
                {
                    if (texelBufferView[i].Handle != 0UL)
                    {
                        var writeDescriptorSet = new WriteDescriptorSet
                        {
                            SType = StructureType.WriteDescriptorSet,
                            DstSet = _descriptorSets[setIndex],
                            DstBinding = (uint)baseBinding + (uint)i,
                            DescriptorType = type,
                            DescriptorCount = 1,  
                            PTexelBufferView = pTexelBufferView + i,
                        };

                        _holder.Api.UpdateDescriptorSets(_holder.Device, 1, in writeDescriptorSet, 0, null);
                    }
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
