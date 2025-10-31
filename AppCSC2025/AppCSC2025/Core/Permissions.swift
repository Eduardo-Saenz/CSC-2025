//
//  Permissions.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import AVFAudio
import Speech

enum AppPermissionError: Error { case micDenied, speechDenied }

struct Permissions {
    static func requestAll() async throws {
        let micGranted = await AVAudioApplication.requestRecordPermission()
        guard micGranted else { throw AppPermissionError.micDenied }

        var speechAuthorized = false
        let semaphore = DispatchSemaphore(value: 0)

        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized { speechAuthorized = true }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        guard speechAuthorized else { throw AppPermissionError.speechDenied }
    }
}
