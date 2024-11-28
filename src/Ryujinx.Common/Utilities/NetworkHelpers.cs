using System;
using System.Buffers.Binary;
using System.Net;
using System.Net.NetworkInformation;

namespace Ryujinx.Common.Utilities
{
    public static class NetworkHelpers
    {
        private static (IPInterfaceProperties, UnicastIPAddressInformation) GetLocalInterface(NetworkInterface adapter, bool isPreferred)
        {
            IPInterfaceProperties properties = adapter.GetIPProperties();

            // Skip problematic checks on non-Windows and iOS platforms
            if (isPreferred || OperatingSystem.IsWindows() || properties.UnicastAddresses.Count > 0)
            {
                foreach (UnicastIPAddressInformation info in properties.UnicastAddresses)
                {
                    // Only accept an IPv4 address
                    if (info.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                    {
                        return (properties, info);
                    }
                }
            }

            return (null, null);
        }

        public static (IPInterfaceProperties, UnicastIPAddressInformation) GetLocalInterface(string lanInterfaceId = "0")
        {
            if (!NetworkInterface.GetIsNetworkAvailable())
            {
                return (null, null);
            }

            IPInterfaceProperties targetProperties = null;
            UnicastIPAddressInformation targetAddressInfo = null;

            NetworkInterface[] interfaces = NetworkInterface.GetAllNetworkInterfaces();

            string guid = lanInterfaceId;
            bool hasPreference = guid != "0";

            foreach (NetworkInterface adapter in interfaces)
            {
                bool isPreferred = adapter.Id == guid;

                // Ignore loopback and ensure the adapter supports IPv4
                if (isPreferred || 
                   (targetProperties == null && adapter.NetworkInterfaceType != NetworkInterfaceType.Loopback && adapter.Supports(NetworkInterfaceComponent.IPv4)))
                {
                    (IPInterfaceProperties properties, UnicastIPAddressInformation info) = GetLocalInterface(adapter, isPreferred);

                    if (properties != null)
                    {
                        targetProperties = properties;
                        targetAddressInfo = info;

                        if (isPreferred || !hasPreference)
                        {
                            break;
                        }
                    }
                }
            }

            return (targetProperties, targetAddressInfo);
        }

        public static uint ConvertIpv4Address(IPAddress ipAddress)
        {
            return BinaryPrimitives.ReadUInt32BigEndian(ipAddress.GetAddressBytes());
        }

        public static uint ConvertIpv4Address(string ipAddress)
        {
            return ConvertIpv4Address(IPAddress.Parse(ipAddress));
        }

        public static IPAddress ConvertUint(uint ipAddress)
        {
            return new IPAddress(new byte[] 
            { 
                (byte)((ipAddress >> 24) & 0xFF), 
                (byte)((ipAddress >> 16) & 0xFF), 
                (byte)((ipAddress >> 8) & 0xFF), 
                (byte)(ipAddress & 0xFF) 
            });
        }
    }
}
