//
//  ContentView.swift
//  Mouse Don't Sleep!
//
//  Created by Tk on 2025/5/21.
//

import SwiftUI
import SwiftData
import IOKit.pwr_mgt
import CoreGraphics

struct ContentView: View {
    @AppStorage("preventSystemSleep") private var preventSystemSleep = false
    @AppStorage("simulateMouse") private var simulateMouse = false
    @AppStorage("simulateInterval") private var simulateInterval: Double = 60 {
        didSet { simulateInterval = min(max(simulateInterval, 30), 120) }
    }
    
    @State private var sleepAssertion: IOPMAssertionID = 0
    @State private var mouseTimer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("防止系统休眠（屏幕和电脑不自动睡眠）", isOn: $preventSystemSleep)
                .padding(.horizontal)
                .onChange(of: preventSystemSleep) { _, newValue in
                    newValue ? startPreventingSystemSleep() : stopPreventingSystemSleep()
                }
            
            Toggle("模拟鼠标微小移动（防止鼠标自身休眠）", isOn: $simulateMouse)
                .padding(.horizontal)
                .onChange(of: simulateMouse) { _, newValue in
                    newValue ? startMouseSimulation() : stopMouseSimulation()
                }
            
            HStack(spacing: 15) {
                Text("模拟间隔：\(Int(simulateInterval)) 秒")
                Stepper("调整间隔", value: $simulateInterval, in: 10...60, step: 5)
                    .disabled(!simulateMouse)
                    .onChange(of: simulateInterval) { _, _ in
                        guard simulateMouse else { return }
                        stopMouseSimulation()
                        startMouseSimulation()
                    }
            }
            .padding(.horizontal)
            
            Spacer()
        }
//        .onAppear { checkAccessibilityPermission() }
        .onDisappear { stopAllFunctions() }
    }
    
    private func startPreventingSystemSleep() {
        var assertionID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "MouseAntiSleep: Prevent system sleep" as CFString,
            &assertionID
        )
        if result == kIOReturnSuccess {
            sleepAssertion = assertionID
            showAlert(title: "提示", message: "已阻止系统休眠（屏幕和电脑将保持唤醒）")
        } else {
            showAlert(title: "错误", message: "阻止休眠失败（请检查系统权限）")
            preventSystemSleep = false
        }
    }
    
    private func stopPreventingSystemSleep() {
        guard sleepAssertion != 0 else { return }
        IOPMAssertionRelease(sleepAssertion)
        sleepAssertion = 0
        showAlert(title: "提示", message: "已恢复系统休眠（屏幕和电脑将按设置睡眠）")
    }
    
    private func startMouseSimulation() {
        stopMouseSimulation()
        mouseTimer = Timer.scheduledTimer(withTimeInterval: simulateInterval, repeats: true) { _ in
            let currentPosition = NSEvent.mouseLocation
            let newPosition = CGPoint(x: currentPosition.x + 1, y: currentPosition.y + 1)
            sendMouseMoveEvent(to: newPosition)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                sendMouseMoveEvent(to: currentPosition)
            }
        }
        showAlert(title: "提示", message: "已启动鼠标模拟（每\(Int(simulateInterval))秒移动一次）")
    }
    
    private func stopMouseSimulation() {
        mouseTimer?.invalidate()
        mouseTimer = nil
    }
    
    private func sendMouseMoveEvent(to position: CGPoint) {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        CGEvent(
            mouseEventSource: eventSource,
            mouseType: .mouseMoved,
            mouseCursorPosition: position,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)
    }
    
    private func checkAccessibilityPermission() {
        guard AXIsProcessTrusted() else {
            showAlert(
                title: "需要辅助功能权限",
                message: "请前往「系统设置→隐私与安全性→辅助功能」，勾选「鼠标防休眠助手」"
            )
            return
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
    private func stopAllFunctions() {
        stopPreventingSystemSleep()
        stopMouseSimulation()
    }
}

#Preview {
    ContentView()
}
