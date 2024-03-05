//
//  ContentView.swift
//  Instafilter
//
//  Created by Paul Hudson on 12/12/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    
    private let context = CIContext()
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var photoItem: PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Spacer()
                
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView {
                        Label("이미지가 없습니다.", systemImage: "photo.badge.plus")
                    } description: {
                        Text("이미지를 추가해주세요.")
                    } actions: {
                        PhotosPicker(selection: $photoItem,
                                     matching: .images) {
                            Text("이미지 추가하기")
                        }
                    }
                }
                
                Spacer()

                HStack {
                    Text("필터 강도")
                    Slider(value: $filterIntensity, in: 0.1...1)
                        .onChange(of: filterIntensity) {
                            applyProcessing()
                        }
                }
                .padding(.vertical)

                HStack {
                    Button("필터 변경하기") {
                        showingFilters = true
                    }
                    
                    Spacer()
                    
                    if let processedImage {
                        ShareLink("공유하기",
                                  item: processedImage,
                                  preview: SharePreview("이미지", image: processedImage))
                    }
                }
                .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Cancel", role: .cancel) { }
                }

            }
            .padding([.horizontal, .bottom])
            .navigationTitle("")
            .onChange(of: photoItem) {
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        Task {
            let imageData = try await photoItem?.loadTransferable(type: Data.self) ?? Data()
            let uiImage = UIImage(data: imageData) ?? UIImage()
            processedImage = Image(uiImage: uiImage)
            
            let ciImage = CIImage(data: imageData)
            currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    private func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }

        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
}

#Preview {
    ContentView()
}
