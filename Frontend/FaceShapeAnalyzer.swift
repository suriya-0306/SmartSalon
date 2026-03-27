//
//  FaceShapeAnalyzer.swift
//  Smart Salon
//
//  Created by SAIL on 23/12/25.
//


import MediaPipeTasksVision
import CoreGraphics

struct FaceShapeAnalyzer {

    static func detect(from landmarks: [NormalizedLandmark]) -> String {

        func p(_ i: Int) -> CGPoint {
            CGPoint(x: CGFloat(landmarks[i].x),
                    y: CGFloat(landmarks[i].y))
        }

        let leftCheek = p(234)
        let rightCheek = p(454)
        let chin = p(152)
        let forehead = p(10)

        let faceWidth = abs(rightCheek.x - leftCheek.x)
        let faceHeight = abs(chin.y - forehead.y)

        let ratio = faceHeight / faceWidth

        if ratio > 1.35 {
            return "Oval"
        } else if ratio < 1.1 {
            return "Round"
        } else if abs(faceWidth - faceHeight) < 0.05 {
            return "Square"
        } else {
            return "Diamond"
        }
    }
}
