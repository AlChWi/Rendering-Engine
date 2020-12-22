//
//  ModelPreview.swift
//  Rendering Engine
//
//  Created by user on 17.12.2020.
//

import Cocoa
import QuickLook
import QuickLookThumbnailing

class ModelPreview: NSCollectionViewItem {    
    func configure(with model: Model) {
        textField?.stringValue = model.name
        let modelURLwithScheme = URL(fileURLWithPath: model.modelURL.absoluteString)
        let generateRequest = QLThumbnailGenerator.Request(fileAt: modelURLwithScheme,
                                                           size: CGSize(width: 100, height: 100),
                                                           scale: NSScreen.main?.backingScaleFactor ?? 1,
                                                           representationTypes: .thumbnail)
        QLThumbnailGenerator().generateRepresentations(for: generateRequest) { [weak self] (thumbnail, thumbnailType, error) in
            DispatchQueue.main.async {
                guard self?.textField?.stringValue == model.name else { return }
                self?.imageView?.image = thumbnail?.nsImage
            }
        }
    }
}
