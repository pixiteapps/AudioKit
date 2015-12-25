//
//  AKAmplitudeTracker.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** Performs a "root-mean-square" on a signal to get overall amplitude of a signal.
 The output signal looks similar to that of a classic VU meter. */
public struct AKAmplitudeTracker: AKNode {

    // MARK: - Properties

    private var internalAU: AKAmplitudeTrackerAudioUnit?
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
        
    private var token: AUParameterObserverToken?

    private var halfPowerPointParameter: AUParameter?

    /** Half-power point (in Hz) of internal lowpass filter. */
    public var halfPowerPoint: Double = 10 {
        didSet {
            halfPowerPointParameter?.setValue(Float(halfPowerPoint), originator: token!)
        }
    }
    
    public var amplitude: Double {
        return Double(self.internalAU!.getAmplitude()) / sqrt(2.0) * 2.0
    }

    // MARK: - Initializers

    /** Initialize this amplitude node */
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 10) {

        self.halfPowerPoint = halfPowerPoint

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x726d7371 /*'rmsq'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKAmplitudeTrackerAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKAmplitudeTracker",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKAmplitudeTrackerAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
        }

        guard let tree = internalAU?.parameterTree else { return }

        halfPowerPointParameter = tree.valueForKey("halfPowerPoint") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.halfPowerPointParameter!.address {
                    self.halfPowerPoint = Double(value)
                }
            }
        }
        halfPowerPointParameter?.setValue(Float(halfPowerPoint), originator: token!)
    }
}
