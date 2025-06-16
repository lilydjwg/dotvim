#!/usr/bin/env swift

// Based on https://github.com/mnewt/dotemacs/blob/master/bin/dark-mode-notifier.swift (Unlicense license)

import Cocoa
import Darwin

setbuf(stdout, nil); // don't buffer the output

var isAppearanceDark: Bool {
	if #available(macOS 11.0, *) {
		return NSAppearance.currentDrawing().bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
	} else {
		return NSAppearance.current.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
	}
}

func printAppearance() {
	print(isAppearanceDark ? "Dark_" : "Light")
}

if CommandLine.arguments.dropFirst(1).first == "get" {
	printAppearance()
	exit(0)
}

DistributedNotificationCenter.default.addObserver(
		forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
		object: nil,
		queue: nil) { _ in
	printAppearance()
}

NSApplication.shared.run()
