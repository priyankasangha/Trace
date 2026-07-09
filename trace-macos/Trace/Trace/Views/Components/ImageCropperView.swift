import SwiftUI
import AppKit

// ==========================================
// CROP ASPECT RATIO
// ==========================================

enum CropAspectRatio {
    case circle       // 1:1 for events (TimelineEventCircle: 200x200)
    case landscape    // ~3:1 for journeys (JourneyCardView: full-width x 115pt)

    var ratio: CGFloat {
        switch self {
        case .circle:    return 1.0
        case .landscape: return 3.0
        }
    }
}

// ==========================================
// REVERSE MASK HELPER
// ==========================================

private extension View {
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask()
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
        )
    }
}

// ==========================================
// INTERACTIVE IMAGE CROPPER
// ==========================================

struct ImageCropperView: View {
    let sourceImage: NSImage
    let aspectRatio: CropAspectRatio
    var onCrop: (NSImage) -> Void
    var onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var containerSize: CGSize = .zero
    @State private var initialized = false

    // The crop region dimensions, computed from container size
    private var cropSize: CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }
        let maxWidth = containerSize.width - 48
        let maxHeight = containerSize.height - 120

        switch aspectRatio {
        case .circle:
            let side = min(maxWidth, maxHeight)
            return CGSize(width: side, height: side)
        case .landscape:
            let width = maxWidth
            let height = width / aspectRatio.ratio
            if height > maxHeight {
                return CGSize(width: maxHeight * aspectRatio.ratio, height: maxHeight)
            }
            return CGSize(width: width, height: height)
        }
    }

    // The image's display size when rendered scaledToFill into the container
    private var imageDisplaySize: CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }
        let imgW = sourceImage.size.width
        let imgH = sourceImage.size.height
        guard imgW > 0, imgH > 0 else { return .zero }

        let containerAspect = containerSize.width / containerSize.height
        let imageAspect = imgW / imgH

        if imageAspect > containerAspect {
            // Image is wider — height fills container
            return CGSize(width: containerSize.height * imageAspect, height: containerSize.height)
        } else {
            // Image is taller — width fills container
            return CGSize(width: containerSize.width, height: containerSize.width / imageAspect)
        }
    }

    // Minimum scale so the image always covers the crop region
    private var minScale: CGFloat {
        guard imageDisplaySize.width > 0, imageDisplaySize.height > 0 else { return 1.0 }
        let widthRatio = cropSize.width / imageDisplaySize.width
        let heightRatio = cropSize.height / imageDisplaySize.height
        return max(widthRatio, heightRatio)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Crop canvas
            GeometryReader { geo in
                ZStack {
                    Color.black

                    // The image layer — receives gestures
                    Image(nsImage: sourceImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageDisplaySize.width * scale, height: imageDisplaySize.height * scale)
                        .offset(offset)
                        .gesture(dragGesture.simultaneously(with: magnifyGesture))

                    // Semi-transparent overlay with crop cutout
                    Rectangle()
                        .fill(Color.black.opacity(0.55))
                        .reverseMask {
                            cropCutout
                                .frame(width: cropSize.width, height: cropSize.height)
                        }
                        .allowsHitTesting(false)

                    // Crop region border
                    cropBorder
                        .frame(width: cropSize.width, height: cropSize.height)
                        .allowsHitTesting(false)
                }
                .clipped()
                .onAppear {
                    containerSize = geo.size
                }
                .onChange(of: geo.size) { _, newSize in
                    containerSize = newSize
                }
            }

            // Button bar
            Divider().opacity(0.2)

            HStack(spacing: 12) {
                Spacer()

                Button("Cancel") { onCancel() }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)

                Button("Done") { performCrop() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.roseGoldDark)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppTheme.primaryBackground)
        }
        .background(Color.black)
        .onChange(of: containerSize) { _, _ in
            if !initialized && containerSize.width > 0 {
                initialized = true
                scale = minScale
                lastScale = minScale
            }
        }
    }

    // MARK: - Crop Shape

    @ViewBuilder
    private var cropCutout: some View {
        switch aspectRatio {
        case .circle:
            Circle()
        case .landscape:
            RoundedRectangle(cornerRadius: 8)
        }
    }

    @ViewBuilder
    private var cropBorder: some View {
        switch aspectRatio {
        case .circle:
            Circle()
                .stroke(AppTheme.roseGoldLight.opacity(0.6), lineWidth: 1.5)
        case .landscape:
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.roseGoldLight.opacity(0.6), lineWidth: 1.5)
        }
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                clampOffset()
                lastOffset = offset
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = max(minScale, min(newScale, 5.0))
            }
            .onEnded { _ in
                scale = max(minScale, min(scale, 5.0))
                clampOffset()
                lastScale = scale
                lastOffset = offset
            }
    }

    // MARK: - Clamping

    private func clampOffset() {
        let scaledW = imageDisplaySize.width * scale
        let scaledH = imageDisplaySize.height * scale

        let maxOffsetX = max(0, (scaledW - cropSize.width) / 2.0)
        let maxOffsetY = max(0, (scaledH - cropSize.height) / 2.0)

        offset.width = max(-maxOffsetX, min(offset.width, maxOffsetX))
        offset.height = max(-maxOffsetY, min(offset.height, maxOffsetY))
    }

    // MARK: - Crop

    private func performCrop() {
        guard let cgImage = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            onCrop(sourceImage)
            return
        }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)

        let scaledDisplayW = imageDisplaySize.width * scale
        let scaledDisplayH = imageDisplaySize.height * scale

        let displayToPixelX = pixelWidth / scaledDisplayW
        let displayToPixelY = pixelHeight / scaledDisplayH

        // The crop region center is at the container center.
        // The image center is at container center + offset.
        // So relative to the image's top-left, the crop center is at:
        //   (scaledDisplayW/2 - offset.width, scaledDisplayH/2 - offset.height)
        let cropCenterX = scaledDisplayW / 2.0 - offset.width
        let cropCenterY = scaledDisplayH / 2.0 - offset.height

        let cropRectInPixels = CGRect(
            x: (cropCenterX - cropSize.width / 2.0) * displayToPixelX,
            y: (cropCenterY - cropSize.height / 2.0) * displayToPixelY,
            width: cropSize.width * displayToPixelX,
            height: cropSize.height * displayToPixelY
        )

        // Clamp to image bounds
        let clampedRect = cropRectInPixels.intersection(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))

        guard !clampedRect.isEmpty, let croppedCG = cgImage.cropping(to: clampedRect) else {
            onCrop(sourceImage)
            return
        }

        let croppedImage = NSImage(cgImage: croppedCG, size: NSSize(
            width: clampedRect.width,
            height: clampedRect.height
        ))

        onCrop(croppedImage)
    }
}
