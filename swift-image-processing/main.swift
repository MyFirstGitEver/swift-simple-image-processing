//
//  main.swift
//  swift-image-processing
//
//  Created by Gia Duc on 10/07/2023.
//

import Foundation

let fileManager = FileManager.default
let home = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/Images")
let fileURL = home.appendingPathComponent("test.png")

try ImageProcessor(fileURL).compressUsingKmeans(k: 60, effort: 4)?
    .save(home.appendingPathComponent("compressed.png"))

//try ImageProcessor(home.appendingPathComponent("zelda.png")).draftThisImage()?
//    .save(home.appendingPathComponent("contour.png"))

//try ImageProcessor(fileURL).rotateRight()?.save(home.appendingPathComponent("right.png"))
//try ImageProcessor(fileURL).rotateLeft()?.save(home.appendingPathComponent("left.png"))

//try ImageProcessor(fileURL).eliminateChannels(.RED).save(home.appendingPathComponent("red.png"))
//try ImageProcessor(fileURL).eliminateChannels(.BLUE).save(home.appendingPathComponent("blue.png"))
//try ImageProcessor(fileURL).eliminateChannels(.GREEN).save(home.appendingPathComponent("green.png"))


