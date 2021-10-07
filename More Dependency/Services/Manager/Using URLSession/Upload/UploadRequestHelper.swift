//
//  UploadRequestHelper.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
    func appendData(_ data: Data) {
        self.append(data)
    }
}

struct UploadRequestHelper {
    
    func convertFileData(fieldName: String, fileName: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        let mimeType = getMimeType(for: fileData, fileName: fileName)
        let fileName = getFileName(for: fileData, fileName: fileName)
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(mimeType)\"\r\n")
        data.appendString("Content-Type: \(fileName)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    func convertMultipleFileData(fieldName: String, fileUrlPaths: [String], using boundary: String)  throws -> Data {
        let data = NSMutableData()
        
        for path in fileUrlPaths {
            let url = URL(fileURLWithPath: path)
            let fileData = try Data(contentsOf: url)
            let fileName = url.pathComponents.last ?? ""
            let mimeType = try getMimeType(for: path)
            
            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"\(fieldName)[]\"; filename=\"\(mimeType)\"\r\n")
            data.appendString("Content-Type: \(fileName)\r\n\r\n")
            data.append(fileData)
            data.appendString("\r\n")
        }
        
        
        return data as Data
    }
    
    func convertFileFieldData(named name: String, value: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        data.append(value)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    func getMimeType(for data: Data, fileName:String) -> String {
        
        var mimeType = ""
        let array = [UInt8](data)
        
        switch (array[0]) {
        case 0xFF: // .jpeg
            mimeType = "image/jpeg;base64"
        case 0x89: //.png
            mimeType = "image/png;base64"
        case 0x47: // .gif
            mimeType = "image/gif;base64"
        case 0x49, 0x4D : // .tiff
            mimeType = "image/tiff;base64"
        default:
            break
        }
        return mimeType
    }
    
    func getFileName(for data: Data, fileName:String) -> String {
        
        let dateTimeStamp = Int(Date().timeIntervalSince1970)
        var name = fileName+"_\(dateTimeStamp)"
        
        let array = [UInt8](data)
        switch (array[0]) {
        case 0xFF: // .jpeg
            name = name+".jpeg"
        case 0x89: //.png
            name = name+".png"
        case 0x47: // .gif
            name = name+".gif"
        case 0x49, 0x4D : // .tiff
            name = name+".tiff"
        default:
            break
        }
        return name
    }
    
    func getMimeType(for path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        let dataType = url.pathExtension
        
        var mimeType = "image/png"
        switch dataType {
        case "pdf":
            mimeType = "application/pdf"
        case "doc", "docx":
            mimeType = "application/msword"
        case "xls", "xlsx":
            mimeType = "application/vnd.ms-excel"
        case "ppt", "pptx":
            mimeType = "application/mspowerpoint"
        case "png":
            mimeType = "image/png"
        case "jpeg", "jpg":
            mimeType = "image/jpeg;image/jp2"
        case "csv":
            mimeType = "application/csv"
        case "txt":
            mimeType = "application/txt"
        default:
            break
        }
        return mimeType
    }

    
}
