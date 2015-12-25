//
//  AKFFT.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/24/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** FFT Calculation for any node */
@objc public class AKFFT: NSObject, EZAudioFFTDelegate {
    
    internal let bufferSize: UInt32 = 512
    internal var fft: EZAudioFFT?
    
    /// Array of FFT data
    public var fftData = [Double](count: 512, repeatedValue: 0.0)
    
    /** Initialze the FFT calculation on a given node
     - parameter input: Node on whose output the FFT will be computed
     */
    public init(_ input: AKNode) {
        super.init()
        fft = EZAudioFFT.fftWithMaximumBufferSize(vDSP_Length(bufferSize), sampleRate: 44100.0, delegate: self)
        input.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AKManager.format) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData[0];
                strongSelf.fft!.computeFFTWithBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
            }
        }
    }
    
    /// Callback function for FFT computation
    @objc public func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            for i in 0...511 {
                self.fftData[i] = Double(fftData[i])
            }
        }
    }
}
