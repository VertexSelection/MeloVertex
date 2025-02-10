//
//  IsJITEnabled.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//



func isJITEnabled() -> Bool {
    var flags: Int = 0
    
    csops(getpid(), 0, &flags, sizeof(flags))
    return (Int32(flags) & CS_DEBUGGED) != 0;
}

func sizeof<T>(_ value: T) -> Int {
    return MemoryLayout<T>.size
}
