//
//  PhotoUtils.swift
//  ThanksFrog
//
//  Created by Juan Garcia on 8/2/15.
//  Copyright (c) 2015 Tek3. All rights reserved.
//

import AVFoundation
import Foundation
import Alamofire
import UIKit

class PhotoUtils{
    
    class func getImageFromSampleBuffer(sampleBuffer:  CMSampleBuffer) -> UIImage {
        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
        let dataProvider = CGDataProviderCreateWithCFData(imageData)
        let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
        let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
        return image
    }
    
    class func cropImage(imageToCrop: UIImage, toRect: CGRect) -> UIImage {
        let imageRef: CGImage = CGImageCreateWithImageInRect(imageToCrop.CGImage, toRect)!
        let imageCropped: UIImage = UIImage(CGImage: imageRef)
        return imageCropped
    }
    
    class func cropImageForLandscape(imageToCrop: UIImage, toRect: CGRect) -> UIImage {
        let newRect = CGRectMake(toRect.origin.y, toRect.origin.x, toRect.size.height, toRect.size.width)
        let imageRef: CGImage = CGImageCreateWithImageInRect(imageToCrop.CGImage, newRect)!
        let imageCropped: UIImage = UIImage(CGImage: imageRef)
        return imageCropped
    }
    
    class func cropImageForPortrait(imageToCrop: UIImage, toRect: CGRect) -> UIImage {
    
        let newRect = CGRectMake(toRect.origin.y, toRect.origin.x, toRect.size.height, toRect.size.width)
        let croppedImage: UIImage = cropImage(imageToCrop, toRect: newRect)
        let rotatedImage: UIImage = UIImage(CGImage: croppedImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return rotatedImage
    
    }
    
    class func cropAndRotateImage(imageToCrop: UIImage, toRect: CGRect, orientation: UIImageOrientation) -> UIImage {
        let imageRef: CGImage = CGImageCreateWithImageInRect(imageToCrop.CGImage, toRect)!
        let imageCropped: UIImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: orientation)
        return imageCropped
    }
    
    class func rotateImage(imageToRotate: UIImage, orientation: UIImageOrientation) -> UIImage {
        return UIImage(CGImage: imageToRotate.CGImage!, scale: 1.0, orientation: orientation)
    }
    
    class func getSquareFilledSize(image: UIImage) -> CGRect {
        let size: CGSize = image.size
        let side: CGFloat = fmin(size.width, size.height)
        let croppingRect: CGRect = CGRectMake((size.width - side) / 2, (size.height - side) / 2, side, side)
        return croppingRect
    }
    
    class func getCoverPhotoFilledSize(image: UIImage) -> CGRect {
        let size: CGSize = image.size
        let side: CGFloat = size.width
        let croppingRect: CGRect = CGRectMake(size.width - side, (size.height - (side * (6 / 11))) / 2, side, side * (6 / 11))
        return croppingRect
    }
    
    class func getCoverPhotoFilledSizeForLandScape(image: UIImage) -> CGRect {
        let size: CGSize = image.size
        let side: CGFloat = size.height
        let croppingRect: CGRect = CGRectMake(size.height - side, (size.width - (side * (6 / 11))) / 2, side, side * (6 / 11))
        return croppingRect
    }
    
    class func savePhotoToGallery(imageToSave: UIImage) {
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
    }
    
    class func getRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180)
    }
    
    class func getImageFromURL(url: String) -> UIImage? {
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOfURL: url){
                return UIImage(data: data)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
	
	// MARK:- Cropping methods
	
	class func calculatePhotoPosition(photoToCrop: UIImageView, scrollView: UIScrollView) -> CGRect {
		
		// Setting scale aspect
		photoToCrop.contentMode = UIViewContentMode.ScaleAspectFill
		
		// Getting photo dimensions
		let photoWidth = photoToCrop.frame.size.width
		let photoHeight = photoToCrop.frame.size.height
		let photoRatio = photoHeight / photoWidth
		
		// Getting scrollview dimensions
		let scrollWidth = scrollView.frame.size.width
		
		// Defining crop region
		return CGRectMake(0, 0, scrollWidth, scrollWidth * photoRatio)
		
	}
	
	class func cropImage(photoToCrop: UIImageView, cropReferenceView: UIView, scrollView: UIScrollView) -> UIImage {
		
		// Getting width of the frame to crop
		let croppingWidth = cropReferenceView.frame.size.width
		
		// Calculating the width scale factor between the UIImageView and the UIImage inside
		let widthFactor = (photoToCrop.image!.size.width / photoToCrop.frame.size.width)
		
		// Getting height of the frame to crop
		let croppingHeight = cropReferenceView.frame.size.height
		
		// Calculating the heigth scale factor between the UIImageView and the UIImage inside
		let heightFactor = (photoToCrop.image!.size.height / photoToCrop.frame.size.height)
		
		// Calculating offset factors between the scroll content size and the UImage to crop
		let contentOffsetFactorX = scrollView.contentSize.width / photoToCrop.image!.size.width
		let contentOffsetFactorY = scrollView.contentSize.height / photoToCrop.image!.size.height
		
		// Calculating area to be cropped, represented as a CGRect
		let croppingArea = CGRectMake(scrollView.contentOffset.x / contentOffsetFactorX, scrollView.contentOffset.y / contentOffsetFactorY,
			croppingWidth * widthFactor, croppingHeight * heightFactor)
		
		// Setting UIImage instance to be crop
		let imageToCrop = photoToCrop.image!
		
		// Cropping image
		return cropImage(imageToCrop, toRect: croppingArea)
		
	}
	
	private func cropImage(imageToCrop: UIImage, toRect: CGRect) -> UIImage {
		let imageRef: CGImage = CGImageCreateWithImageInRect(imageToCrop.CGImage, toRect)!
		let imageCropped: UIImage = UIImage(CGImage: imageRef)
		return imageCropped
	}
	
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    class func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
		
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
		
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}