//
//  AKFrequencyTracker.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/** This tracks the pitch of signal using the AMDF (Average Magnitude Difference
 Function) method of Pitch following. */
public struct AKFrequencyTracker: AKNode {

    // MARK: - Properties

    private var internalAU: AKFrequencyTrackerAudioUnit?
    private var token: AUParameterObserverToken?
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    
    public var amplitude: Double {
        return Double(self.internalAU!.getAmplitude()) / sqrt(2.0) * 2.0
    }
    public var frequency: Double {
        return Double(self.internalAU!.getFrequency()) * 2.0
    }

    // MARK: - Initializers

    /** Initialize this Pitch-detection node */
    public init(_ input: AKNode, minimumFrequency: Double, maximumFrequency: Double) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x616d6466 /*'amdf'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFrequencyTrackerAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKFrequencyTracker",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKFrequencyTrackerAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
            self.internalAU?.setFrequencyLimitsWithMinimum(Float(minimumFrequency/2), maximum: Float(maximumFrequency/2))
        }
    }
}
