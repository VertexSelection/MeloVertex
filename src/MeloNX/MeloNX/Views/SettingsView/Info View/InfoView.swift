//
//  InfoView.swift
//  MeloNX
//
//  Created by Tech Guy on 12/31/24.
//


import SwiftUI

struct InfoView: View {
    @AppStorage("entitlementExists") private var entitlementExists: Bool = false
    @AppStorage("increaseddebugmem") private var increaseddebugmem: Bool = false
    @AppStorage("extended-virtual-addressing") private var extended: Bool = false
    @State var gd = false
    let infoDictionary = Bundle.main.infoDictionary
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to MeloNX!")
                    .font(.largeTitle)
                Divider()
                Text("Entitlements:")
                    .font(.title)
                    .font(Font.headline.weight(.bold))
                Spacer()
                    .frame(height: 10)
                Group {
                    Text("Required:")
                        .font(.title2)
                        .foregroundColor(.red)
                        .font(Font.headline.weight(.bold))
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Memory Limit: \(String(describing: entitlementExists))")
                    Spacer()
                        .frame(height: 10)
                }
                Group {
                    Spacer()
                        .frame(height: 10)
                    Text("Reccomended (paid):")
                        .font(.title2)
                        .font(Font.headline.weight(.bold))
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Debugging Memory Limit: \(String(describing: increaseddebugmem))")
                        .padding()
                    Text("Extended Virtual Addressing: \(String(describing: extended))")
                }
                
                Divider()
                Text("Memory:")
                    .font(.title)
                    .font(Font.headline.weight(.bold))
                Spacer()
                    .frame(height: 10)
                Group {
                    Text("Current:")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .font(Font.headline.weight(.bold))
                    Spacer()
                        .frame(height: 10)
                    Text(String(DeviceMemory.totalRAM) + "GB")
                    Spacer()
                        .frame(height: 10)
                }
                
            }
            .padding()
            
            HStack {
                Text("Version: \(getAppVersion())")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .onTapGesture {
                        gd.toggle()
                    }
                if getAppVersion() == "2.2", gd {
                    Text("Geometry Dash????? ;)")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 5))
                }
            }
        }
    }
    func getAppVersion() -> String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
}
