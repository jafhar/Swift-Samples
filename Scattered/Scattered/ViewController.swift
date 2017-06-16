//
//  ViewController.swift
//  Scattered
//
//  Created by jafharsharief.b on 08/05/17.
//  Copyright © 2017 Exilant. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private var textLayer:CATextLayer!
    private var text: String? {
        didSet {
            let font = NSFont.systemFont(ofSize: textLayer.fontSize)
            let attributes = [NSFontAttributeName: font]
            var size = text?.size(withAttributes: attributes) ?? CGSize.zero
            
            //Ensure that the size is in whole numbers:
            size.width = ceil(size.width)
            size.height = ceil(size.height)
            textLayer.bounds = CGRect(origin:CGPoint.zero, size: size)
            textLayer.superlayer?.bounds = CGRect(x: 0, y: 0, width: size.width + 16, height: size.height + 20)
            textLayer.string = text
            
            
        }
    }
    
    //MARK: Add images from desktop pictures
    private func addImagesFromFolder(folderURL: NSURL) {
        
        let t0 = NSDate.timeIntervalSinceReferenceDate
        let fileManager = FileManager()
        let directoryEnumerator = fileManager.enumerator(at: folderURL as URL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(rawValue: 0), errorHandler: nil)!
        var allowedFiles = 10
        
        while let url = directoryEnumerator.nextObject() as? NSURL {
            //skip directories
            
            var isDirectoryValue: AnyObject?
            do {
               try url.getResourceValue(&isDirectoryValue, forKey: URLResourceKey.isDirectoryKey)
            }catch let error{
                print("Error : \(error.localizedDescription)")
            }
            if let isDirectory = isDirectoryValue as? NSNumber, isDirectory.boolValue == false {
                let image = NSImage.init(contentsOf: url as URL)
                if let image = image {
                    allowedFiles = allowedFiles - 1
                    if allowedFiles < 0 {
                        break
                    }
                    let thumbImage = thumbImageFromImage(image: image)
                    presentImage(image: thumbImage)
                    let t1 = NSDate.timeIntervalSinceReferenceDate
                    let interval = t1 - t0
                    text = String.init(format: "%0.1fs", interval)
                }
            }
        }
    }
    
    //MARK: Presenting the image
    private func presentImage(image: NSImage) {
        let superLayerBounds = view.layer?.bounds
        let center = CGPoint(x:(superLayerBounds?.midX)!, y:(superLayerBounds?.midY)!)
        let imageBounds = CGRect.init(origin: CGPoint.zero, size: image.size)
        let randomPoint = CGPoint.init(x: CGFloat(arc4random_uniform(UInt32((superLayerBounds?.maxX)!))),
            y: CGFloat(arc4random_uniform(UInt32((superLayerBounds?.maxY)!))))
        let timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let positionAnimation = CABasicAnimation()
        positionAnimation.fromValue = NSValue.init(point: center)
        positionAnimation.duration = 1.5
        positionAnimation.timingFunction = timingFunction
        
        let boundsAnimation = CABasicAnimation()
        boundsAnimation.fromValue = NSValue(rect: CGRect.zero)
        boundsAnimation.duration = 1.5
        boundsAnimation.timingFunction = timingFunction
        
        let layer = CALayer()
        layer.contents = image
        layer.actions = [Constant.positionKey : positionAnimation, Constant.boundsKey : boundsAnimation]
        CATransaction.begin()
        
        view.layer?.addSublayer(layer)
        layer.position = randomPoint
        layer.bounds = imageBounds
        CATransaction.commit()
        
    }
    
    //MARK: Getting smaller image
    private func thumbImageFromImage(image: NSImage) -> NSImage {
        let targetHeight: CGFloat = 200.0
        let imageSize = image.size
        let smallerSize = NSSize(width: targetHeight * imageSize.width / imageSize.height, height: targetHeight)
        
        let smallerImage = NSImage(size: smallerSize, flipped:false) {
            (rect) -> Bool in
            image.draw(in: rect)
            return true
        }
        return smallerImage
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set view to be layer-hosting:
        view.layer = CALayer()
        view.wantsLayer = true
        
        let textContainer = CALayer()
        textContainer.anchorPoint = CGPoint.zero
        textContainer.position = CGPoint.init(x: 10, y: 10)
        textContainer.zPosition = 100
        textContainer.backgroundColor = NSColor.black.cgColor
        textContainer.borderColor = NSColor.white.cgColor
        textContainer.borderWidth = 2
        textContainer.cornerRadius = 15
        textContainer.shadowOpacity = 0.5
        view.layer?.addSublayer(textContainer)
        
        let textLayer = CATextLayer()
        textLayer.anchorPoint = CGPoint.init(x: 10, y: 6)
        textLayer.zPosition = 100
        textLayer.fontSize = 24
        textLayer.foregroundColor = NSColor.white.cgColor
        self.textLayer = textLayer
        
        textContainer.addSublayer(textLayer)
        
        
        //Rely on text's didSet to update text's bound
        text = Constant.defaultText
        
        let url = NSURL(fileURLWithPath:Constant.imagesPath)
        addImagesFromFolder(folderURL: url)
    }    
}

