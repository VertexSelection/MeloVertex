using Ryujinx.HLE.HOS.Kernel.Memory;
using Ryujinx.HLE.HOS.Services.Am.AppletAE.AllSystemAppletProxiesService.LibraryAppletCreator;

namespace Ryujinx.HLE.HOS.Services.Am.AppletAE.AllSystemAppletProxiesService.SystemAppletProxy
{
    partial class ILibraryAppletCreator : IpcService
    {
        public ILibraryAppletCreator() { }

        [CommandCmif(0)]
        // CreateLibraryAppletOld(u32, u32) -> object<nn::am::service::ILibraryAppletAccessor>
        public ResultCode CreateLibraryAppletOld(ServiceCtx context)
        {
            AppletId appletId = (AppletId)context.RequestData.ReadInt32();
            int libraryAppletMode = context.RequestData.ReadInt32();

            return CreateLibraryAppletImpl(context, appletId, libraryAppletMode, null);
        }

        [CommandCmif(3)] // 20.0.0+
        // CreateLibraryApplet(u32, u32, u64) -> object<nn::am::service::ILibraryAppletAccessor>
        public ResultCode CreateLibraryApplet(ServiceCtx context)
        {
            AppletId appletId = (AppletId)context.RequestData.ReadInt32();
            int libraryAppletMode = context.RequestData.ReadInt32();
            ulong callerThreadId = context.RequestData.ReadUInt64();

            return CreateLibraryAppletImpl(context, appletId, libraryAppletMode, callerThreadId);
        }

        private ResultCode CreateLibraryAppletImpl(ServiceCtx context, AppletId appletId, int _libraryAppletMode, ulong? _callerThreadId)
        {
            MakeObject(context, new ILibraryAppletAccessor(appletId, context.Device.System));

            return ResultCode.Success;
        }

        [CommandCmif(10)]
        // CreateStorage(u64) -> object<nn::am::service::IStorage>
        public ResultCode CreateStorage(ServiceCtx context)
        {
            long size = context.RequestData.ReadInt64();

            if (size <= 0)
            {
                return ResultCode.ObjectInvalid;
            }

            MakeObject(context, new IStorage(new byte[size]));

            // NOTE: Returns ResultCode.MemoryAllocationFailed if IStorage is null, it doesn't occur in our case.

            return ResultCode.Success;
        }

        [CommandCmif(11)]
        // CreateTransferMemoryStorage(b8, u64, handle<copy>) -> object<nn::am::service::IStorage>
        public ResultCode CreateTransferMemoryStorage(ServiceCtx context)
        {
            bool isReadOnly = (context.RequestData.ReadInt64() & 1) == 0;
            long size = context.RequestData.ReadInt64();
            int handle = context.Request.HandleDesc.ToCopy[0];

            KTransferMemory transferMem = context.Process.HandleTable.GetObject<KTransferMemory>(handle);

            if (size <= 0)
            {
                return ResultCode.ObjectInvalid;
            }

            byte[] data = new byte[transferMem.Size];

            transferMem.Creator.CpuMemory.Read(transferMem.Address, data);

            context.Device.System.KernelContext.Syscall.CloseHandle(handle);

            MakeObject(context, new IStorage(data, isReadOnly));

            return ResultCode.Success;
        }

        [CommandCmif(12)] // 2.0.0+
        // CreateHandleStorage(u64, handle<copy>) -> object<nn::am::service::IStorage>
        public ResultCode CreateHandleStorage(ServiceCtx context)
        {
            long size = context.RequestData.ReadInt64();
            int handle = context.Request.HandleDesc.ToCopy[0];

            KTransferMemory transferMem = context.Process.HandleTable.GetObject<KTransferMemory>(handle);

            if (size <= 0)
            {
                return ResultCode.ObjectInvalid;
            }

            byte[] data = new byte[transferMem.Size];

            transferMem.Creator.CpuMemory.Read(transferMem.Address, data);

            context.Device.System.KernelContext.Syscall.CloseHandle(handle);

            MakeObject(context, new IStorage(data));

            return ResultCode.Success;
        }
    }
}
