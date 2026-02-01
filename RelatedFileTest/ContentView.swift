//
//  ContentView.swift
//  RelatedFileTest
//
//  Created by Volker Runkel on 01.02.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @State private var importPresented: Bool = false
    @State private var hasMainContent: Bool = false
    @State private var hasSideContent: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Related files and Sandbox!")
            Toggle("Main content loaded", isOn: $hasMainContent)
                .disabled(true)
            Toggle("Side content loaded", isOn: $hasSideContent)
                .disabled(true)
            Button("Load sound") {
                importPresented.toggle()
            }
        }
        .fileImporter(isPresented: $importPresented, allowedContentTypes: [.audio, UTType(filenameExtension: "raw")!], onCompletion: { result in
            switch result {
            case .success(let url):
                let gotAccess = url.startAccessingSecurityScopedResource()
                if !gotAccess { return }
                if let fileString = try? String(contentsOf: url, encoding: .macOSRoman) {
                    let gotAccess = url.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    
                    if let audioContent = try? String(contentsOf: url, encoding: .macOSRoman) {
                        hasMainContent = true
                    } else {
                        hasMainContent = false
                    }
                    
                    let callsSidecar = CallsSidecar(with: url)
                    let data = callsSidecar.readData()
                    if data?.isEmpty ?? true {
                        hasSideContent = false
                    } else {
                        hasSideContent = true
                    }
                } else {
                    print("No soundcontainer")
                }
                url.stopAccessingSecurityScopedResource()
            case .failure(let error):
                // handle error
                print(error)
            }
        })
        .padding()
    }
}

class CallsSidecar: NSObject, NSFilePresenter {
    lazy var presentedItemOperationQueue = OperationQueue.main
    var primaryPresentedItemURL: URL?
    var presentedItemURL: URL?
    init(with url: URL) {
        primaryPresentedItemURL = url
        presentedItemURL = url.deletingPathExtension().appendingPathExtension("bcCalls")
    }
    func readData() -> Data? {
        var data: Data?
        var error: NSError?
        
        NSFileCoordinator.addFilePresenter(self)
        let coordinator = NSFileCoordinator.init(filePresenter: self)
        coordinator.coordinate(readingItemAt: presentedItemURL!, options: [], error: &error) {
            url in
            data = try? Data.init(contentsOf: url)
        }
        return data
    }
}


#Preview {
    ContentView()
}
