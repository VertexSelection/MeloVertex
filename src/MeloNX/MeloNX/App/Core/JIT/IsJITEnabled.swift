//
//  IsJITEnabled.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation

func checkMemoryPermissions(at address: UnsafeRawPointer) -> Bool {
    var region: vm_address_t = vm_address_t(UInt(bitPattern: address))
    var regionSize: vm_size_t = 0
    var info = vm_region_basic_info_64()
    var infoCount = mach_msg_type_number_t(MemoryLayout<vm_region_basic_info_64>.size / MemoryLayout<integer_t>.size)
    var objectName: mach_port_t = UInt32(MACH_PORT_NULL)
    
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) {
            vm_region_64(mach_task_self_, &region, &regionSize, VM_REGION_BASIC_INFO_64, $0, &infoCount, &objectName)
        }
    }
    
    if result != KERN_SUCCESS {
        print("Failed to reach \(address)")
        return false
    }
    
    return info.protection & VM_PROT_EXECUTE != 0
}

func isJITEnabled() -> Bool {
    let pageSize = sysconf(_SC_PAGESIZE)
    let code: [UInt32] = [0x52800540, 0xD65F03C0]
    
    guard let jitMemory = mmap(nil, pageSize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0), jitMemory != MAP_FAILED else {
        return false
    }
    
    defer {
        munmap(jitMemory, pageSize)
    }
    
    
    memcpy(jitMemory, code, code.count)
    
    if mprotect(jitMemory, pageSize, PROT_READ | PROT_EXEC) != 0 {
        return false
    }
    
    let checkMem = checkMemoryPermissions(at: jitMemory)
    
    return checkMem
}
