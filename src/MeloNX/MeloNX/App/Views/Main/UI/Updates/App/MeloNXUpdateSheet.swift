//
//  MeloNXUpdateSheet.swift
//  MeloNX
//
//  Created by Stossy11 and Bella on 12/03/2025.
//

import SwiftUI

struct MeloNXUpdateSheet: View {
    let updateInfo: LatestVersionResponse
    @Binding var isPresented: Bool
    
    var body: some View {
        iOSNav {
            VStack {
                Text("Version \(updateInfo.version_number) is available. You are currently on Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown").")
                
                VStack {
                    Text("Changelog:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    
                    ScrollView {
                        Text(updateInfo.changelog)
                            .padding()
                    }
                    .frame(maxHeight: 400)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 15)
                
                
                Spacer()
                if #available(iOS 15.0, *) {
                    Button(action: {
                        if let url = URL(string: updateInfo.download_link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Download Now")
                            .font(.title3)
                            .bold()
                            .frame(width: 300, height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(alignment: .bottom)
                } else {
                    Button(action: {
                        if let url = URL(string: updateInfo.download_link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Download Now")
                            .font(.title3)
                            .bold()
                            .frame(width: 300, height: 40)
                    }
                    .frame(alignment: .bottom)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Version \(updateInfo.version_number) Available!")
            .toolbar {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                }
            }
        }
    }
}
