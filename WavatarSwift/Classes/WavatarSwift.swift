//
//  WavatarSwift.swift
//  WavatarSwift
//
//  Created by anton.serebryakov on 25/09/2017.
//  Copyright © 2017. All rights reserved.
//

import UIKit.UIImage
import QuartzCore

public protocol WavatarSwiftMD5 {
    
    static func md5(_ string: String) -> String
    
}

open class WavatarSwift {
    
    public static var maxSize: Int {
        return WavatarSwift.WAVATAR_SIZE
    }
    
    public typealias Completion = ((String, UIImage?) -> ())
    
    open class func generate(string: String, size: Int = maxSize) -> UIImage? {
        var result: UIImage? = nil
        generate(inBackground: false, from: string, with: size) {
            string, image in
            result = image
        }
        return result
    }
    
    open class func generate(string: String, size: Int = maxSize, completion: @escaping Completion) {
        generate(inBackground: true, from: string, with: size, completion: completion)
    }
    
    open class func hash(_ string: String) -> String? {
        guard let md5 = self as? WavatarSwiftMD5.Type else {
            print("Extend \"WavatarSwift\" with \"WavatarSwiftMD5\" protocol!")
            return nil
        }
        let hash = md5.md5(md5.md5(string).lowercased()).lowercased()
        return (hash as NSString).substring(with: NSRange(location: 1, length: neededHexStringLength))
    }
    
    
    // MARK: - Inner
    
    private static var neededHexStringLength: Int = 16
    
    private class func generate(inBackground: Bool, from string: String, with size: Int, completion: @escaping Completion) {
        guard let hash: String = self.hash(string),
            hash.lengthOfBytes(using: .utf8) >= neededHexStringLength else {
                completion(string, nil)
                return
        }
        if inBackground {
            DispatchQueue.global().async {
                let result = generate(hash: hash, size: size)
                DispatchQueue.main.async {
                    completion(string, result)
                }
            }
        } else {
            let result = generate(hash: hash, size: size)
            completion(string, result)
        }
    }
    
    
    // MARK: - Core algorythm
    
    private static let WAVATAR_SIZE =        80
    private static let WAVATAR_BACKGROUNDS = 4
    private static let WAVATAR_FACES =       11
    private static let WAVATAR_BROWS =       8
    private static let WAVATAR_EYES =        13
    private static let WAVATAR_PUPILS =      11
    private static let WAVATAR_MOUTHS =      19
    
    private class func generate(hash: String, size: Int) -> UIImage? {
        guard size > 1 else {
            return nil
        }
        let size = min(size, maxSize)
        let ctxRect = CGRect(x: 0, y: 0, width: WAVATAR_SIZE, height: WAVATAR_SIZE)
        UIGraphicsBeginImageContextWithOptions(ctxRect.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -ctxRect.size.height)
        let face =      1 + wavatar_hexdec(hash,  0) % WAVATAR_FACES
        let bg_color =      wavatar_hexdec(hash,  2) % 240
        let fade =      1 + wavatar_hexdec(hash,  4) % WAVATAR_BACKGROUNDS
        let wav_color =     wavatar_hexdec(hash,  6) % 240
        let brow =      1 + wavatar_hexdec(hash,  8) % WAVATAR_BROWS
        let eyes =      1 + wavatar_hexdec(hash, 10) % WAVATAR_EYES
        let pupil =     1 + wavatar_hexdec(hash, 12) % WAVATAR_PUPILS
        let mouth =     1 + wavatar_hexdec(hash, 14) % WAVATAR_MOUTHS
        wavatar_hsl(CGFloat(bg_color), 240, 50).setFill()
        ctx.fill(ctxRect)
        wavatar_apply_image(ctx, "fade\(fade)")
        wavatar_apply_image(ctx, "mask\(face)", colorize: wavatar_hsl(CGFloat(wav_color), 240, 170))
        wavatar_apply_image(ctx, "shine\(face)")
        wavatar_apply_image(ctx, "brow\(brow)")
        wavatar_apply_image(ctx, "eyes\(eyes)")
        wavatar_apply_image(ctx, "pupils\(pupil)")
        wavatar_apply_image(ctx, "mouth\(mouth)")
        if size != WAVATAR_SIZE {
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
            image?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private class func wavatar_hexdec(_ hash: String, _ location: Int) -> Int {
        let hash = hash as NSString
        let string = hash.substring(with: NSRange(location: location, length: 2))
        return Int(string, radix: 16) ?? 0
    }
    
    private class func wavatar_apply_image(_ ctx: CGContext, _ part: String, colorize color: UIColor? = nil) {
        let frameworkBundle = Bundle(for: self)
        if  let bundleName = frameworkBundle.infoDictionary?["CFBundleName"] as? String,
            let bundleURL = frameworkBundle.url(forResource: bundleName, withExtension: "bundle"),
            let frameworkMainBundle = Bundle(url: bundleURL),
            let partsBundleURL = frameworkMainBundle.url(forResource: "Parts", withExtension: "bundle"),
            let partsBundle = Bundle(url: partsBundleURL),
            let imagePath = partsBundle.path(forResource: part, ofType: "png"),
            let image = UIImage(contentsOfFile: imagePath),
            let cgImage = image.cgImage {
            let area = CGRect(origin: .zero, size: image.size)
            if  let color = color {
                ctx.saveGState()
                ctx.clip(to: area, mask: cgImage)
                color.setFill()
                ctx.fill(area)
                ctx.setBlendMode(.plusDarker)
                ctx.draw(cgImage, in: area)
                ctx.restoreGState()
            } else {
                ctx.draw(cgImage, in: area)
            }
        }
    }
    
    private class func wavatar_hsl(_ h: CGFloat, _ s: CGFloat, _ l: CGFloat) -> UIColor {
        if (h>240 || h<0 || s>240 || s<0 || l>240 || l<0) { return .black }
        var R: CGFloat
        var G: CGFloat
        var B: CGFloat
        if (h<=40) {
            R=255
            G=(h/40*256)
            B=0
        } else if (h>40 && h<=80) {
            R=(1-(h-40)/40)*256
            G=255
            B=0
        } else if (h>80 && h<=120) {
            R=0
            G=255
            B=(h-80)/40*256
        } else if (h>120 && h<=160) {
            R=0
            G=(1-(h-120)/40)*256
            B=255
        } else if (h>160 && h<=200) {
            R=(h-160)/40*256
            G=0
            B=255
        } else if (h>200) {
            R=255
            G=0
            B=(1-(h-200)/40)*256
        } else {
            R=0
            G=0
            B=0
        }
        R=R+(240-s)/240*(128-R)
        G=G+(240-s)/240*(128-G)
        B=B+(240-s)/240*(128-B)
        if (l<120) {
            R=(R/120)*l
            G=(G/120)*l
            B=(B/120)*l
        } else {
            R=l*((256-R)/120)+2*R-256
            G=l*((256-G)/120)+2*G-256
            B=l*((256-B)/120)+2*B-256
        }
        if (R<0) { R=0 }
        if (R>255) { R=255 }
        if (G<0) { G=0 }
        if (G>255) { G=255 }
        if (B<0) { B=0 }
        if (B>255) { B=255 }
        return UIColor(red: R/255, green: G/255, blue: B/255, alpha: 1)
    }
    
    private init() {}
    
}
