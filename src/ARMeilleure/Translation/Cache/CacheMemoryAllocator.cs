using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;

namespace ARMeilleure.Translation.Cache
{
    class CacheMemoryAllocator
    {
        private readonly struct MemoryBlock : IComparable<MemoryBlock>
        {
            public int Offset { get; }
            public int Size { get; }

            public MemoryBlock(int offset, int size)
            {
                Offset = offset;
                Size = size;
            }

            public int CompareTo([AllowNull] MemoryBlock other)
            {
                return Offset.CompareTo(other.Offset);
            }
        }

        private readonly List<MemoryBlock> _blocks = new();

        public CacheMemoryAllocator(int capacity)
        {
            _blocks.Add(new MemoryBlock(0, capacity));
        }

        public int Allocate(ref int size, int alignment)
        {
            int alignM1 = alignment - 1;
            for (int i = 0; i < _blocks.Count; i++)
            {
                MemoryBlock block = _blocks[i];
                int misAlignment = ((block.Offset + alignM1) & (~alignM1)) - block.Offset;
                int alignedSize = size + misAlignment;

                if (block.Size > alignedSize)
                {
                    size = alignedSize;
                    _blocks[i] = new MemoryBlock(block.Offset + alignedSize, block.Size - alignedSize);
                    return block.Offset + misAlignment;
                }
                else if (block.Size == alignedSize)
                {
                    size = alignedSize;
                    _blocks.RemoveAt(i);
                    return block.Offset + misAlignment;
                }
            }

            // We don't have enough free memory to perform the allocation.
            return -1;
        }

        public void Free(int offset, int size)
        {
            Insert(new MemoryBlock(offset, size));
        }

        private void Insert(MemoryBlock block)
        {
            int index = _blocks.BinarySearch(block);

            if (index < 0)
            {
                index = ~index;
            }

            if (index < _blocks.Count)
            {
                MemoryBlock next = _blocks[index];

                int endOffs = block.Offset + block.Size;

                if (next.Offset == endOffs)
                {
                    block = new MemoryBlock(block.Offset, block.Size + next.Size);
                    _blocks.RemoveAt(index);
                }
            }

            if (index > 0)
            {
                MemoryBlock prev = _blocks[index - 1];

                if (prev.Offset + prev.Size == block.Offset)
                {
                    block = new MemoryBlock(block.Offset - prev.Size, block.Size + prev.Size);
                    _blocks.RemoveAt(--index);
                }
            }

            _blocks.Insert(index, block);
        }
    }
}
