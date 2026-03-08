import Cocoa
import SwiftUI
import MediaPlayer
import IOKit
import IOKit.ps
import IOKit.pwr_mgt
import CoreAudio
import CoreBluetooth
import Foundation
import AppKit


// Replace the existing MediaRemote declarations with this approach
let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

// Update the pointer declarations to use CFBundleGetFunctionPointerForName
let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
    bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString
)
let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(
    bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString
)
let MRMediaRemoteGetNowPlayingApplicationDisplayNamePointer = CFBundleGetFunctionPointerForName(
    bundle, "MRMediaRemoteGetNowPlayingApplicationDisplayName" as CFString
)
let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(
    bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString
)
let MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(
    bundle, "MRMediaRemoteSendCommand" as CFString
)

// Add MediaRemote types
typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
typealias MRMediaRemoteGetNowPlayingApplicationDisplayNameFunction = @convention(c) (Int, DispatchQueue, @escaping (CFString) -> Void) -> Void
typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
typealias MRMediaRemoteSendCommandFunction = @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Bool

// Add MediaRemote functions
let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
let MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
let MRMediaRemoteGetNowPlayingApplicationDisplayName = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationDisplayNamePointer, to: MRMediaRemoteGetNowPlayingApplicationDisplayNameFunction.self)
let MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)
let MRMediaRemoteSendCommand = unsafeBitCast(MRMediaRemoteSendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)

// Add MediaRemote constants
let kMRMediaRemoteNowPlayingInfoDidChangeNotification = NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
let kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification = NSNotification.Name("kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification")
let kMRMediaRemoteNowPlayingApplicationDidChangeNotification = NSNotification.Name("kMRMediaRemoteNowPlayingApplicationDidChangeNotification")

let kMRMediaRemoteNowPlayingInfoTitle = "kMRMediaRemoteNowPlayingInfoTitle"
let kMRMediaRemoteNowPlayingInfoArtist = "kMRMediaRemoteNowPlayingInfoArtist"
let kMRMediaRemoteNowPlayingInfoAlbum = "kMRMediaRemoteNowPlayingInfoAlbum"
let kMRMediaRemoteNowPlayingInfoArtworkData = "kMRMediaRemoteNowPlayingInfoArtworkData"

let kMRPlay: UInt32 = 0
let kMRPause: UInt32 = 1
let kMRTogglePlayPause: UInt32 = 2
let kMRStop: UInt32 = 3
let kMRNextTrack: UInt32 = 4
let kMRPreviousTrack: UInt32 = 5

let kMRMediaRemoteNowPlayingInfoElapsedTime = "kMRMediaRemoteNowPlayingInfoElapsedTime"
let kMRMediaRemoteNowPlayingInfoDuration = "kMRMediaRemoteNowPlayingInfoDuration"
let kMRMediaRemoteNowPlayingInfoPlaybackProgress = "kMRMediaRemoteNowPlayingInfoPlaybackProgress"

// Add this constant at the top with other MediaRemote constants
let MPNowPlayingInfoPropertyElapsedPlaybackTime = "MPNowPlayingInfoPropertyElapsedPlaybackTime"

// Add these constants if not already present
let kMRNowPlayingPlaybackQueueChangedNotification = "kMRNowPlayingPlaybackQueueChangedNotification"
let kMRPlaybackQueueContentItemsChangedNotification = "kMRPlaybackQueueContentItemsChangedNotification"
let kMRMediaRemoteNowPlayingApplicationClientStateDidChange = "kMRMediaRemoteNowPlayingApplicationClientStateDidChange"

// Add this function at the file level (outside any struct/class)
func getUptime() -> String {
    var boottime = timeval()
    var size = MemoryLayout<timeval>.stride
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    
    if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 {
        let now = Date().timeIntervalSince1970
        let uptime = now - Double(boottime.tv_sec)
        
        let hours = Int(uptime) / 3600
        let minutes = Int(uptime) / 60 % 60
        
        if hours > 0 {
            return "up \(hours) \(hours == 1 ? "hour" : "hours"), \(minutes) \(minutes == 1 ? "minute" : "minutes")"
        } else {
            return "up \(minutes) \(minutes == 1 ? "minute" : "minutes")"
        }
    }
    
    return "uptime unavailable"
}

struct Colors {
    // Backgrounds
    // static var panelBackground = NSColor(hex: "2E3440")!.withAlphaComponent(0.95) // Nord 1 (Polar Night)
    static var panelBackground = NSColor(hex: "2E3440")!.withAlphaComponent(1) // Nord 1 (Polar Night)
    static var cardBackground = NSColor(hex: "3B4252")!.withAlphaComponent(0.95) // Nord 2 (Polar Night)
    static var graphBackground = NSColor(hex: "434C5E")! // Nord 3 (Polar Night)

    // Accents
    static var accent = NSColor(hex: "88C0D0")! // Nord 4 (Snow Storm)
    static var blue = NSColor(hex: "81A1C1")! // Nord 5 (Snow Storm)
    static var green = NSColor(hex: "A3BE8C")! // Nord 6 (Frost)
    static var yellow = NSColor(hex: "EBCB8B")! // Nord 7 (Frost)
    static var orange = NSColor(hex: "D19A66")! // Nord 8 (Frost)
    static var red = NSColor(hex: "BF616A")! // Nord 9 (Frost)

    static func initialize(panelHex: String, cardHex: String) {
        if let panel = NSColor(hex: panelHex) {
            panelBackground = panel
        }
        if let card = NSColor(hex: cardHex) {
            cardBackground = card
        }
    }
}

extension NSColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .contentBackground // Use a less intense material
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active // Enable the blur effect
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

enum PanelType: String {
    case menu = "menu"
    case calendar = "date"
    
    static func from(string: String?) -> PanelType {
        guard let str = string else { 
            print("DEBUG: No string provided, defaulting to menu")
            return .menu 
        }
        let panel = PanelType(rawValue: str) ?? .menu
        print("DEBUG: Parsed panel type: \(str) -> \(panel)")
        return panel
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var currentPanel: PanelType = .menu
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Debug print arguments
        print("DEBUG: All arguments:", ProcessInfo.processInfo.arguments)
        
        let args = ProcessInfo.processInfo.arguments
        if let panelArg = args.dropFirst().first {
            let cleanArg = panelArg.replacingOccurrences(of: "app=", with: "")
            print("DEBUG: Panel argument after cleaning:", cleanArg)
            currentPanel = PanelType.from(string: cleanArg)
        }
        
        print("DEBUG: Selected panel type:", currentPanel)
        
        // Choose content view based on panel type
        let contentView: AnyView
        switch currentPanel {
        case .menu:
            print("DEBUG: Creating menu panel")
            contentView = AnyView(ContentView())
        case .calendar:
            print("DEBUG: Creating calendar panel")
            contentView = AnyView(CalendarPanelView())
        }
        
        // Rest of your existing window setup code...
        let yabaiTask = Process()
        yabaiTask.launchPath = "/usr/bin/env"
        yabaiTask.arguments = ["yabai", "-m", "query", "--displays", "--display"]
        
        let yabaiPipe = Pipe()
        yabaiTask.standardOutput = yabaiPipe
        yabaiTask.launch()
        
        let yabaiData = yabaiPipe.fileHandleForReading.readDataToEndOfFile()
        yabaiTask.waitUntilExit()
                
        // Get item position from SketchyBar
        let sketchyTask = Process()
        sketchyTask.launchPath = "/usr/bin/env"
        sketchyTask.arguments = ["sketchybar", "--query", currentPanel == .menu ? "apple.logo" : "date"]
        
        let sketchyPipe = Pipe()
        sketchyTask.standardOutput = sketchyPipe
        sketchyTask.launch()
        
        let sketchyData = sketchyPipe.fileHandleForReading.readDataToEndOfFile()
        sketchyTask.waitUntilExit()
                
        // Get bar height from sketchybar
        let barTask = Process()
        barTask.launchPath = "/usr/bin/env"
        barTask.arguments = ["sketchybar", "--query", "bar"]
        
        let barPipe = Pipe()
        barTask.standardOutput = barPipe
        barTask.launch()
        
        let barData = barPipe.fileHandleForReading.readDataToEndOfFile()
        barTask.waitUntilExit()
        
        // Parse bar height from sketchybar data
        var barHeight: CGFloat = 25  // Default height
        if let barInfo = try? JSONSerialization.jsonObject(with: barData, options: []) as? [String: Any],
           let height = barInfo["height"] as? Double {
            barHeight = CGFloat(height)
        }
                
        // Get yabai window gaps
        let gapsTask = Process()
        gapsTask.launchPath = "/usr/bin/env"
        gapsTask.arguments = ["yabai", "-m", "config", "window_gap"]
        
        let gapsPipe = Pipe()
        gapsTask.standardOutput = gapsPipe
        gapsTask.launch()
        
        let gapsData = gapsPipe.fileHandleForReading.readDataToEndOfFile()
        gapsTask.waitUntilExit()
        
        // Parse the gaps value
        let gapSize = Int(String(data: gapsData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0") ?? 0
        
        // Calculate total offset (bar height + gap)
        let topOffset = barHeight + CGFloat(gapSize)
        
        // Parse responses and position window
        if let yabaiInfo = try? JSONSerialization.jsonObject(with: yabaiData, options: []) as? [String: Any],
            let displayIndex = yabaiInfo["index"] as? Int,
            let frame = yabaiInfo["frame"] as? [String: Double],
            let itemInfo = try? JSONSerialization.jsonObject(with: sketchyData, options: []) as? [String: Any],
            let boundingRects = itemInfo["bounding_rects"] as? [String: Any],
            let displayRect = boundingRects["display-\(displayIndex)"] as? [String: Any],
            let _ = displayRect["origin"] as? [Double] {
            
            let displayX = frame["x"] ?? 0
            let displayWidth = frame["w"] ?? 0
            let displayHeight = frame["h"] ?? 0
            let windowWidth: CGFloat = displayWidth * 0.20  // 20% of screen width
            
            // Position at top edge of screen for both menu and calendar
            let windowY = displayHeight - topOffset
            let windowX: CGFloat
            if currentPanel == .menu {
                windowX = displayX + CGFloat(gapSize - 1)
            } else {
                // For calendar panel, position at right edge of screen
                windowX = displayX + displayWidth - windowWidth - CGFloat(gapSize - 1)
            }
            
            window = NSWindow(
                contentRect: NSRect(
                    x: windowX,  // Use calculated windowX
                    y: windowY - (windowY / 1.7) + CGFloat(2),  // Adjust y to position at top
                    width: windowWidth,
                    height: (windowY / 1.7) - CGFloat(gapSize)
                ),
                styleMask: [],  // Empty style mask prevents all window controls including resizing
                backing: .buffered,
                defer: false
            )
            
            // Force the window size
            window?.setContentSize(NSSize(width: windowWidth, height: (windowY / 1.7)))
            
            // Add size constraint
            if let window = window {
                window.maxSize = NSSize(width: windowWidth, height: (windowY / 1.7) - CGFloat(gapSize))
                window.minSize = NSSize(width: windowWidth, height: (windowY / 1.7) - CGFloat(gapSize))
            }
        }
                
        window?.contentView = NSHostingView(rootView: contentView)
        window?.backgroundColor = .clear
        window?.isMovableByWindowBackground = false
        window?.level = .floating
        window?.hasShadow = false
        
        if let contentView = window?.contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true
            contentView.layer?.backgroundColor = NSColor.clear.cgColor
            contentView.layer?.opacity = 0.0
            
            // Set initial position based on panel type
            let initialTranslation = currentPanel == .menu ? 
                -window!.frame.width :  // Slide from left for menu
                window!.frame.width     // Slide from right for calendar
            contentView.layer?.transform = CATransform3DMakeTranslation(initialTranslation, 0, 0)
        }
        
        window?.makeKeyAndOrderFront(nil)
        
        // Simple slide animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            window?.contentView?.layer?.animate(
                keyPath: "transform.translation.x",
                from: currentPanel == .menu ? 
                    -window!.frame.width :  // Slide from left for menu
                    window!.frame.width,    // Slide from right for calendar
                to: 0,
                duration: context.duration
            )
            
            window?.contentView?.layer?.animate(
                keyPath: "opacity",
                from: 0.0,
                to: 1.0,
                duration: context.duration
            )
        }
        
        // Add these window properties
        if let window = window {
            window.isMovableByWindowBackground = false
            window.level = .floating
        }
        
        // Add click handler for detecting clicks outside the window
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
            if let window = self.window {
                let screenLocation = event.locationInWindow
                
                // Convert window frame to screen coordinates
                let windowFrame = window.frame
                
                // Check if click is outside the window
                if !windowFrame.contains(screenLocation) {
                    // Send SIGUSR1 to self to close the window
                    kill(getpid(), SIGUSR1)
                }
            }
        }
    }
    
    func handleGracefulClose() {
        animateWindowClose {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func animateWindowClose(completion: @escaping () -> Void) {
        guard let contentView = window?.contentView,
              let windowWidth = window?.frame.width else {
            completion()
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            contentView.layer?.animate(
                keyPath: "transform.translation.x",
                from: 0,
                to: currentPanel == .menu ? 
                    -windowWidth :  // Slide to left for menu
                    windowWidth,    // Slide to right for calendar
                duration: context.duration
            )
            
            contentView.layer?.animate(
                keyPath: "opacity",
                from: 1.0,
                to: 0.0,
                duration: context.duration
            )
        }, completionHandler: completion)
    }
}

// Add MouseTrackingView and MouseTrackingViewRepresentable (same as media player)
class MouseTrackingView: NSView {
    var onMouseEntered: (() -> Void)?
    var onMouseExited: (() -> Void)?
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let existingTrackingArea = trackingArea {
            removeTrackingArea(existingTrackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        onMouseEntered?()
    }
    
    override func mouseExited(with event: NSEvent) {
        onMouseExited?()
    }
}

struct MouseTrackingViewRepresentable: NSViewRepresentable {
    let onMouseEntered: () -> Void
    let onMouseExited: () -> Void
    
    func makeNSView(context: Context) -> MouseTrackingView {
        let view = MouseTrackingView()
        view.onMouseEntered = onMouseEntered
        view.onMouseExited = onMouseExited
        return view
    }
    
    func updateNSView(_ nsView: MouseTrackingView, context: Context) {}
}

// Update CircularProgressView
struct CircularProgressView: View {
    let progress: Double
    let icon: String
    let color: Color
    var iconSize: CGFloat = 15 // Default icon size
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            .padding(.top, 10)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(color)
                .padding(.bottom, 5)
        }
        .frame(width: 110, height: 110)
        .background(Color(Colors.cardBackground))
        .cornerRadius(12)
    }
}

// Update Card struct to handle EdgeInsets
struct Card: View {
    let content: AnyView
    let backgroundColor: Color
    let padding: EdgeInsets
    let backgroundImage: NSImage?
    let gradientOpacity: Double  // Added parameter for gradient opacity
    
    init(content: AnyView, backgroundColor: Color, padding: EdgeInsets, backgroundImage: NSImage?, gradientOpacity: Double = 0.8) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.backgroundImage = backgroundImage
        self.gradientOpacity = gradientOpacity
    }
    
    var body: some View {
        ZStack {
            if let image = backgroundImage {
                GeometryReader { geometry in
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height)
                        .position(x: geometry.size.width * 0.25, y: geometry.size.height / 2)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(gradientOpacity),
                                    Color.black.opacity(gradientOpacity * 0.8),
                                    Color.black.opacity(gradientOpacity * 0.6)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                }
            }
            
            content
                .padding(padding)
                .frame(maxWidth: .infinity)
        }
        .background(backgroundImage == nil ? backgroundColor : Color.clear)
        .cornerRadius(12)
    }
}

// Add Bundle extension for app icon lookup
extension Bundle {
    func bundleIdentifier(forAppNamed appName: String) -> String? {
        switch appName {
        case "Music":
            return "com.apple.Music"
        case "Spotify":
            return "com.spotify.client"
        case "Brave Browser":
            return "com.brave.Browser"
        case "Safari":
            return "com.apple.safari"
        case "Zen Browser":
            return "org.mozilla.com.zen.browser"
        case "Firefox":
            return "org.mozilla.firefox"
        case "Firefox Developer Edition":
            return "org.mozilla.firefoxdeveloperedition"
        default:
            return nil
        }
    }
}

struct ContentView: View {
    @StateObject private var statsController = StatsController()
    @StateObject private var mediaController = MediaController()
    @StateObject private var weatherController = WeatherController()
    @State private var isMouseInside = false
    @State private var uptime: String = getUptime()
    let username: String = NSFullUserName()
        
    // Timer to update the uptime
    let uptimeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

       // Function to load the user profile image
    private func getUserProfileImage() -> NSImage? {
        let username = NSUserName()
        
        // Check for custom profile picture
        if let imagePath = try? FileManager.default.contentsOfDirectory(atPath: "/Users/\(username)/Library/UserPictures").first {
            return NSImage(contentsOfFile: "/Users/\(username)/Library/UserPictures/\(imagePath)")
        }
        
        return nil
    } 

    private var profileSection: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                // Profile image and name
                HStack(spacing: 4) {
                    // Profile Image
                    if let profileImage = getUserProfileImage() {
                        Image(nsImage: profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                    } else {
                        // Fallback Circle
                        Circle()
                            .fill(Color(Colors.accent))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                            )
                    }
                    
                        // Username with dynamic adjustments
                    Text(username)
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .semibold)) // Adjust font size based on length
                        .multilineTextAlignment(.leading)
                        .lineLimit(2) // Limit to two lines if necessary
                        .frame(maxWidth: .infinity, alignment: .leading) // Allow full width usage
                }
                
                Spacer()

                // Action buttons
                HStack(spacing: 8) {
                    ActionButton(icon: "power", color: Color(Colors.red)) {
                        powerOff()
                    }
                    
                    ActionButton(icon: "arrow.counterclockwise", color: Color(Colors.orange)) {
                        restart()
                    }
                    
                    ActionButton(icon: "lock.fill", color: Color(Colors.green)) {
                        lock()
                    }
                    
                    ActionButton(icon: "rectangle.portrait.and.arrow.right", color: Color(Colors.blue)) {
                        logout()
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .padding(.top, 25)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
        }
    }

    private var mediaPlayerSection: some View {
        Card(
            content: AnyView(
                ZStack {
                    // Blurred background artwork
                    if let artwork = mediaController.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .blur(radius: 10)
                            .opacity(0.3)
                    }
                    
                    // Content
                    HStack(spacing: 12) {
                        // Album artwork
                        if let artwork = mediaController.artwork {
                            Image(nsImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 82, height: 82)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Title and artist
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mediaController.title)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .lineLimit(1)
                            
                            Text(mediaController.artist)
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                        
                        // Spacer()
                        
                        // Media controls
                        HStack(spacing: 20) {
                            MediaControlButton(systemName: "backward.end.fill") {
                                mediaController.previous()
                            }
                            MediaControlButton(systemName: mediaController.isPlaying ? "pause.fill" : "play.fill") {
                                mediaController.togglePlayPause()
                            }
                            MediaControlButton(systemName: "forward.end.fill") {
                                mediaController.next()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 110) 
            ),
            backgroundColor: Color(Colors.cardBackground),
            padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            backgroundImage: nil
        )
        .padding(.horizontal, 30)
    }


    var body: some View {
        ZStack {
            // Blurred background using VisualEffectView
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                profileSection
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(Colors.cardBackground).opacity(0.5))
                            .blur(radius: 15)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                mediaPlayerSection
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(Colors.cardBackground).opacity(0.5))
                            .blur(radius: 15)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15), // Adjust spacing as needed
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 20) { // Adjust vertical spacing as needed
                    CircularProgressView(
                        progress: statsController.batteryLevel,
                        icon: batteryIcon(level: statsController.batteryLevel, isCharging: statsController.isCharging),
                        color: Color(Colors.green)
                    )
                    CircularProgressView(
                        progress: statsController.volumeLevel,
                        icon: volumeIcon(level: statsController.volumeLevel, isMuted: statsController.isMuted),
                        color: Color(Colors.blue)
                    )
                    CircularProgressView(
                        progress: statsController.memoryUsage,
                        icon: "memorychip",
                        color: Color(Colors.yellow)
                    )

                    CircularProgressView(
                        progress: statsController.cpuUsage,
                        icon: "cpu",
                        color: Color(Colors.orange)
                    )
                    // CircularProgressView(
                    //     progress: statsController.diskUsage,
                    //     icon: "internaldrive",
                    //     color: Color(Colors.red)
                    // )
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Colors.cardBackground).opacity(0.5))
                        .blur(radius: 15)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }

            mouseTrackingOverlay
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(Colors.green), lineWidth: 4)
        )
        .onReceive(uptimeTimer) { _ in
            uptime = getUptime()
        }
    }
    
    private var mouseTrackingOverlay: some View {
        MouseTrackingViewRepresentable(
            onMouseEntered: {
                isMouseInside = true
            },
            onMouseExited: {
                isMouseInside = false
            }
        )
        .allowsHitTesting(false)
    }
    
    private func volumeIcon(level: Double, isMuted: Bool) -> String {
        if isMuted {
            return "speaker.slash.fill"
        }
        
        let percentage = level * 100
        switch percentage {
        case 0:
            return "speaker.fill"
        case 0.1...33:
            return "speaker.wave.1.fill"
        case 33.1...66:
            return "speaker.wave.2.fill"
        default:
            return "speaker.wave.3.fill"
        }
    }

    private func batteryIcon(level: Double, isCharging: Bool) -> String {
        if isCharging {
            return "battery.100.bolt"
        } else {
            switch level {
            case 0..<0.25:
                return "battery.25"
            case 0.25..<0.5:
                return "battery.50"
            case 0.5..<0.75:
                return "battery.75"
            default:
                return "battery.100"
            }
        }
}
}

// Add this extension for layer animations
extension CALayer {
    func animate(keyPath: String, from: CGFloat, to: CGFloat, duration: CGFloat) {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        add(animation, forKey: keyPath)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

class StatsController: ObservableObject {
    @Published private(set) var memoryUsage: Double = 0.0
    // @Published private(set) var diskUsage: Double = 0.0
    @Published private(set) var cpuUsage: Double = 0.0
    @Published private(set) var batteryLevel: Double = 0.0
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var volumeLevel: Double = 0.0
    @Published private(set) var isMuted: Bool = false
    
    private var generalTimer: Timer? // Declare the general timer
    private var cpuTimer: Timer? // Declare the CPU timer
    private var previousTicks: (user: Float, system: Float, idle: Float, nice: Float)?

    
       init() {
        // General stats updated every second
        generalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateGeneralStats()
        }
        updateGeneralStats()

        // CPU usage updated more frequently
        cpuTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateCPUUsage()
        }
        updateCPUUsage()
    }

    private func updateGeneralStats() {
        updateMemoryUsage()
        // updateDiskUsage()
        updateBatteryStatus()
        updateVolumeLevel()
    }

    private func updateMemoryUsage() {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { pointer in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, pointer, &size)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = vm_kernel_page_size // Memory page size in bytes
            let total = Double(stats.active_count + stats.inactive_count + stats.wire_count + stats.free_count) * Double(pageSize)
            let used = Double(stats.active_count + stats.wire_count) * Double(pageSize) // Consider only active and wired memory as "used"
            
            DispatchQueue.main.async {
                self.memoryUsage = used / total // Used as a fraction of total
            }
        } else {
            print("Failed to fetch VM statistics, error code: \(result)")
        }
    } 

    // private func updateDiskUsage() {
    //     let fileURL = URL(fileURLWithPath: "/")
    //     do {
    //         let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
    //         if let total = values.volumeTotalCapacity,
    //            let available = values.volumeAvailableCapacity {
    //             let used = Double(total - available)
    //             let usage = used / Double(total)
    //             
    //             DispatchQueue.main.async {
    //                 self.diskUsage = usage
    //             }
    //         }
    //     } catch {
    //         print("Error getting disk usage: \(error)")
    //     }
    // }

    private func updateCPUUsage() {
        var hostInfo = host_cpu_load_info()
        var size = mach_msg_type_number_t(MemoryLayout.size(ofValue: hostInfo) / MemoryLayout<Int32>.size)
        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        
        if result == KERN_SUCCESS {
            let user = Float(hostInfo.cpu_ticks.0)
            let system = Float(hostInfo.cpu_ticks.1)
            let idle = Float(hostInfo.cpu_ticks.2)
            let nice = Float(hostInfo.cpu_ticks.3)
            
            if let previous = previousTicks {
                let userDiff = user - previous.user
                let systemDiff = system - previous.system
                let idleDiff = idle - previous.idle
                let niceDiff = nice - previous.nice
                
                let totalDiff = userDiff + systemDiff + idleDiff + niceDiff
                
                if totalDiff > 0 {
                    let usage = (userDiff + systemDiff + niceDiff) / totalDiff
                    DispatchQueue.main.async {
                        self.cpuUsage = Double(usage)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.cpuUsage = 0.0 // Default value when no usage can be calculated
                    }
                }
            }
            
            // Save the current values for the next calculation
            previousTicks = (user: user, system: system, idle: idle, nice: nice)
        } else {
            print("Failed to fetch CPU statistics: \(result)")
        }
    }

    private func updateBatteryStatus() {
        if let powerSource = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let sources = IOPSCopyPowerSourcesList(powerSource)?.takeRetainedValue() as? [CFTypeRef] {
            
            for source in sources {
                if let description = IOPSGetPowerSourceDescription(powerSource, source)?.takeUnretainedValue() as? [String: Any] {
                    DispatchQueue.main.async {
                        self.batteryLevel = (description[kIOPSCurrentCapacityKey] as? Double ?? 0) / 100.0
                        self.isCharging = description[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
                    }
                }
            }
        }
    }
    
    private func updateVolumeLevel() {
        var deviceSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var defaultOutputDevice = kAudioObjectUnknown
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Get default output device
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &deviceSize,
            &defaultOutputDevice
        )
        
        // Get volume
        propertyAddress.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput
        
        var volume: Float32 = 0.0
        deviceSize = UInt32(MemoryLayout<Float32>.size)
        
        AudioObjectGetPropertyData(
            defaultOutputDevice,
            &propertyAddress,
            0,
            nil,
            &deviceSize,
            &volume
        )
        
        // Get mute status
        propertyAddress.mSelector = kAudioDevicePropertyMute
        
        var isMuted: UInt32 = 0
        deviceSize = UInt32(MemoryLayout<UInt32>.size)
        
        AudioObjectGetPropertyData(
            defaultOutputDevice,
            &propertyAddress,
            0,
            nil,
            &deviceSize,
            &isMuted
        )
        
        DispatchQueue.main.async {
            self.volumeLevel = Double(volume)
            self.isMuted = isMuted == 1
        }
    }
    
    deinit {
        generalTimer?.invalidate()
        cpuTimer?.invalidate()
    }
}

class MediaController: ObservableObject {
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var album: String = ""
    @Published var isPlaying: Bool = false
    @Published var artwork: NSImage?
    @Published var currentApp: String = ""
    @Published var elapsedTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published private(set) var lastArtwork: NSImage?
    
    private var initialTime: TimeInterval = 0
    private var playbackStartTime: Date?
    private var playbackSpeed: Double = 1.0
    private var progressTimer: Timer?
    
    init() {
        // Add this at the start of init()
        NSEvent.addLocalMonitorForEvents(matching: .systemDefined) { event in
            if event.subtype.rawValue == 8 { // Remote control event
                return nil
            }
            return event
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)

        // Get initial playback state and time
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] info in
            DispatchQueue.main.async {
                
                if let elapsed = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
                    self?.initialTime = elapsed
                    self?.elapsedTime = elapsed
                    
                    // If we're currently playing, set up the timer with the correct initial time
                    if self?.isPlaying == true {
                        self?.playbackStartTime = Date()
                        self?.startTimer()
                    }
                }
                
                if let total = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
                    self?.duration = total
                }
            }
        }

        MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] playing in
            DispatchQueue.main.async {
                self?.isPlaying = playing
                if playing {
                    // Only start the timer if we have a valid elapsed time
                    if self?.elapsedTime ?? 0 > 0 {
                        self?.playbackStartTime = Date()
                        self?.startTimer()
                    }
                }
            }
        }

        // Add observers for changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaChange),
            name: kMRMediaRemoteNowPlayingInfoDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayingChange),
            name: kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification,
            object: nil
        )

        updateNowPlaying()
    }
    
    private func startTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            if let startTime = self.playbackStartTime {
                let timePassed = -startTime.timeIntervalSinceNow * self.playbackSpeed
                let newElapsed = self.initialTime + timePassed
                self.elapsedTime = min(newElapsed, self.duration) // Ensure we don't exceed duration
            }
        }
    }
    
    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        // Store the current time as initial time for next playback
        initialTime = elapsedTime
        playbackStartTime = nil
    }

    func togglePlayPause() {
        if currentApp != "Music" {
            if isPlaying {
                if MRMediaRemoteSendCommand(kMRPause, nil) {
                    isPlaying = false
                    stopTimer()
                }
            } else {
                if MRMediaRemoteSendCommand(kMRPlay, nil) {
                    isPlaying = true
                    startTimer()
                }
            }
        }
    }

    func updateNowPlayingTime() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] info in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let elapsed = info[kMRMediaRemoteNowPlayingInfoElapsedTime] as? TimeInterval {
                    self.elapsedTime = elapsed
                }
                if let total = info[kMRMediaRemoteNowPlayingInfoDuration] as? TimeInterval {
                    self.duration = total
                }
            }
        }
    }

    @objc func handlePlayingChange(_ notification: Notification) {
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] playing in
            DispatchQueue.main.async {
                self?.isPlaying = playing
                if playing {
                    // Only start the timer if we have a valid elapsed time
                    if self?.elapsedTime ?? 0 > 0 {
                        self?.playbackStartTime = Date()
                        self?.startTimer()
                    }
                }
            }
        }
    }

    @objc func handleMediaChange(_ notification: Notification) {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] info in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Get the new title
                let newTitle = info[kMRMediaRemoteNowPlayingInfoTitle] as? String ?? ""
                
                // Check if the song has changed
                if newTitle != self.title {
                    // For song changes, get the new elapsed time
                    if let elapsed = info[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? Double {
                        self.initialTime = elapsed
                        self.elapsedTime = elapsed
                    } else {
                        self.resetPlaybackTimer()
                    }
                }
                
                // Update basic info
                self.title = newTitle
                self.artist = info[kMRMediaRemoteNowPlayingInfoArtist] as? String ?? ""
                self.album = info[kMRMediaRemoteNowPlayingInfoAlbum] as? String ?? ""
                
                // Update artwork if available
                if let artworkData = info[kMRMediaRemoteNowPlayingInfoArtworkData] as? Data {
                    if let image = NSImage(data: artworkData) {
                        self.artwork = image
                        self.lastArtwork = image // Store the artwork
                    }
                }
                
                // If no current artwork but we have last artwork and title isn't empty
                if self.artwork == nil && !self.title.isEmpty {
                    self.artwork = self.lastArtwork
                }
                
                // Always update duration and playback speed
                if let total = info[kMRMediaRemoteNowPlayingInfoDuration] as? Double {
                    self.duration = total
                }
                if let speed = info["kMRMediaRemoteNowPlayingInfoPlaybackSpeed"] as? Double {
                    self.playbackSpeed = speed
                }
            }
        }
    }

    func updateNowPlaying() {
        handleMediaChange(Notification(name: kMRMediaRemoteNowPlayingInfoDidChangeNotification))
    }

    func next() {
        if currentApp != "Music" {
            if MRMediaRemoteSendCommand(kMRNextTrack, nil) {
                // Reset timer on track change
                resetPlaybackTimer()
                updateNowPlaying()
            }
        }
    }

    func previous() {
        if currentApp != "Music" {
            if MRMediaRemoteSendCommand(kMRPreviousTrack, nil) {
                // Reset timer on track change
                resetPlaybackTimer()
                updateNowPlaying()
            }
        }
    }

    private func resetPlaybackTimer() {
        stopTimer()
        initialTime = 0
        elapsedTime = 0
        playbackStartTime = Date()
        if isPlaying {
            startTimer()
        }
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(elapsedTime / duration, 1.0)
    }
}

// Helper function to format time
func formatTime(seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let seconds = Int(seconds) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

// Add these functions to handle system actions
func powerOff() {
    let source = """
    tell application "System Events"
        shut down
    end tell
    """
    runAppleScript(source)
}

func restart() {
    let source = """
    tell application "System Events"
        restart
    end tell
    """
    runAppleScript(source)
}

func lock() {
    let source = """
    tell application "System Events"
        keystroke "q" using {command down, control down}
    end tell
    """
    runAppleScript(source)
}

func logout() {
    let source = """
    tell application "System Events"
        log out
    end tell
    """
    runAppleScript(source)
}

func runAppleScript(_ source: String) {
    if let script = NSAppleScript(source: source) {
        var error: NSDictionary?
        script.executeAndReturnError(&error)
    }
}

// Add a new ActionButton component
struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 13))
                .frame(width: 30, height: 30)
                .background(Color(Colors.cardBackground))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// Add Color extension for hex support if not already present
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

// Add a MediaControl button component
struct MediaControlButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))  // Reduced from 16 to 12
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// Weather Controller using OpenWeatherMap API
class WeatherController: ObservableObject {
    @Published var currentTemp: Double = 0
    @Published var feelsLike: Double = 0
    @Published var condition: String = ""
    @Published var humidity: Int = 0
    @Published var weatherIcon: String = "sun.max.fill"
    @Published var forecast: [(day: String, high: Double, low: Double, icon: String)] = []
    
    private var timer: Timer?
    private let weatherIconMap: [String: String] = [
        "01d": "sun.max.fill",         // Clear sky day
        "01n": "moon.stars.fill",      // Clear sky night
        "02d": "cloud.sun.fill",       // Few clouds day
        "02n": "cloud.moon.fill",      // Few clouds night
        "03d": "cloud.fill",           // Scattered clouds
        "03n": "cloud.fill",
        "04d": "smoke.fill",           // Broken clouds
        "04n": "smoke.fill",
        "09d": "cloud.drizzle.fill",   // Shower rain
        "09n": "cloud.drizzle.fill",
        "10d": "cloud.rain.fill",      // Rain
        "10n": "cloud.rain.fill",
        "11d": "cloud.bolt.rain.fill", // Thunderstorm
        "11n": "cloud.bolt.rain.fill",
        "13d": "cloud.snow.fill",      // Snow
        "13n": "cloud.snow.fill",
        "50d": "cloud.fog.fill",       // Mist
        "50n": "cloud.fog.fill"
    ]
    
    init() {
        updateWeather()
        // Update weather every 30 minutes
        timer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.updateWeather()
        }
    }
    
    private func updateWeather() {
        // Get the absolute path to the .env file
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let envPath = homeDirectory.appendingPathComponent(".config/sketchybar/helpers/event_providers/.env").path
        
        print("Looking for .env file at:", envPath)
        
        guard let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) else {
            print("Error: Could not load .env file from \(envPath)")
            return
        }
        
        // Parse API key and city from .env file
        let lines = envContent.components(separatedBy: .newlines)
        var apiKey = ""
        var city = ""
        
        for line in lines {
            if line.starts(with: "OPEN_WEATHER_API_KEY=") {
                apiKey = String(line.dropFirst("OPEN_WEATHER_API_KEY=".count))
            } else if line.starts(with: "CITY=") {
                city = String(line.dropFirst("CITY=".count))
            }
        }
        
        guard !apiKey.isEmpty, !city.isEmpty else {
            print("Error: Missing API key or city in .env file")
            return
        }
        
        // URL encode the city name
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: Could not encode city name")
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            print("Error: Could not create URL from string")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(OpenWeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if let currentWeather = weatherData.list.first {
                        self?.currentTemp = currentWeather.main.temp
                        self?.feelsLike = currentWeather.main.feels_like
                        self?.humidity = currentWeather.main.humidity
                        self?.condition = currentWeather.weather.first?.description.capitalized ?? ""
                        
                        // Update weather icon
                        if let iconCode = currentWeather.weather.first?.icon,
                           let iconName = self?.weatherIconMap[iconCode] {
                            self?.weatherIcon = iconName
                        }
                        
                        // Process 5-day forecast
                        // Group forecasts by day and get min/max temperatures
                        var dailyForecasts: [String: (min: Double, max: Double, icon: String)] = [:]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        for forecast in weatherData.list {
                            let date = Date(timeIntervalSince1970: Double(forecast.dt))
                            let dateString = dateFormatter.string(from: date)
                            
                            let temp = forecast.main.temp
                            let icon = forecast.weather.first?.icon ?? "01d"
                            
                            if let existing = dailyForecasts[dateString] {
                                dailyForecasts[dateString] = (
                                    min: min(existing.min, temp),
                                    max: max(existing.max, temp),
                                    icon: icon
                                )
                            } else {
                                dailyForecasts[dateString] = (min: temp, max: temp, icon: icon)
                            }
                        }
                        
                        // Convert to array and sort by date
                        self?.forecast = dailyForecasts
                            .sorted { $0.key < $1.key }
                            .prefix(5)
                            .map { (day: $0.key, high: $0.value.max, low: $0.value.min,
                                   icon: self?.weatherIconMap[$0.value.icon] ?? "sun.max.fill") }
                    }
                }
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }.resume()
    }
}

// Add WeatherView
struct WeatherView: View {
    @ObservedObject var weatherController: WeatherController
    
    var body: some View {
        Card(
            content: AnyView(
                HStack {
                    // Left side - Weather icon
                    Image(systemName: weatherController.weatherIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Right side - Temperature and condition
                    VStack(alignment: .trailing, spacing: 4) {
                        // Changed °C to °F
                        Text("\(Int(weatherController.currentTemp))°C")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Condition text
                        Text(weatherController.condition)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            ),
            backgroundColor: Color(Colors.cardBackground),
            padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            backgroundImage: nil
        )
        .padding(.horizontal, 20)
    }
}

// OpenWeatherMap API Response Structures
struct OpenWeatherResponse: Codable {
    let list: [WeatherData]
}

struct WeatherData: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherCondition]
}

struct MainWeather: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}


// First, let's separate the calendar content into a simpler view
struct CalendarContentView: View {
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    let date: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Month and Year
            Text(date.formatted(.dateTime.month(.wide).year()))
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
            
            // Week days
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12))
                        .foregroundColor(day == "S" ? Color(Colors.red) : Color.white)
                        .frame(width: 20)
                }
            }
            
            // Calendar grid
            CalendarGridView(date: date)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 15)
    }
}

// Separate grid view
struct CalendarGridView: View {
    let date: Date
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<6) { row in
                HStack(spacing: 8) {
                    ForEach(0..<7) { column in
                        let index = row * 7 + column
                        if index < days.count {
                            DayCell(day: days[index])
                        } else {
                            Text("")
                                .frame(width: 20)
                        }
                    }
                }
            }
        }
    }
    
    private var days: [DayItem] {
        generateDaysInMonth()
    }
    
    private func generateDaysInMonth() -> [DayItem] {
        var days: [DayItem] = []
        let calendar = Calendar.current
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
        
        // Previous month days
        // for day in (daysInPreviousMonth - firstWeekday + 1)...daysInPreviousMonth {
        //     days.append(DayItem(number: "\(day)", isCurrentMonth: false, isToday: false))
        // }

        // Previous month days
        if firstWeekday > 0 {
            let startDay = max(1, daysInPreviousMonth - firstWeekday + 1)
            for day in startDay...daysInPreviousMonth {
                days.append(DayItem(number: "\(day)", isCurrentMonth: false, isToday: false))
            }
        }
        
        // Current month days
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        let currentDay = calendar.component(.day, from: date)
        
        for day in 1...daysInMonth {
            days.append(DayItem(number: "\(day)", 
                              isCurrentMonth: true, 
                              isToday: day == currentDay))
        }
        
        // Next month days
        let remainingDays = 42 - days.count
        for day in 1...remainingDays {
            days.append(DayItem(number: "\(day)", isCurrentMonth: false, isToday: false))
        }
        
        return days
    }
}

// Simplified day cell
struct DayCell: View {
    let day: DayItem
    
    var body: some View {
        Text(day.number)
            .font(.system(size: 12))
            .foregroundColor(
                day.isCurrentMonth 
                    ? (day.isToday ? .white : .white.opacity(0.7)) 
                    : .white.opacity(0.3)
            )
            .frame(width: 20)
            .fontWeight(day.isToday ? .bold : .regular)
    }
}

// Day item model
struct DayItem {
    let number: String
    let isCurrentMonth: Bool
    let isToday: Bool
}

struct CalendarView: View {
    @State private var date: Date = Date()

    var body: some View {
        CalendarContentView(date: date)
            .onAppear(perform: fetchDate)
    }

    private func fetchDate() {
        self.date = Date()
    }
}

struct ClockView: View {
    @State private var currentTime = ""

    var body: some View {
        Card(
            content: AnyView(
                HStack {
                    // Left side - Clock icon with padding
                    Image(systemName: "clock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .padding(.leading, -20) // Add padding to move it towards the border

                    Spacer()

                    // Right side - Current time with padding
                    Text(currentTime)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.trailing, -20) // Add padding to move it towards the border
                }
            ),
            backgroundColor: Color(Colors.cardBackground),
            padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
            backgroundImage: nil
        )
        .padding(.horizontal, 20)
        .onAppear(perform: updateTime)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTime()
        }
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
}

// Add this new strict for panel titles
struct PanelTitle: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(Colors.red))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top, 25)
                .padding(.bottom, 10)
            
            // Grey divider
            Rectangle()
                .fill(Color.gray.opacity(0.5)) // Set the color and opacity of the divider
                .frame(height: 1) // Set height of the divider
                .padding(.horizontal, 30) // Add horizontal padding to align with title
        }
    }
}

struct CalendarPanelView: View {
    @StateObject private var weatherController = WeatherController()
    @State private var isMouseInside = false

    var body: some View {
        ZStack {
            // Blurred background using VisualEffectView
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                PanelTitle(title: "Date And Weather Info")

                // Calendar section with blur and shadow
                Card(
                    content: AnyView(
                        CalendarView()
                            .frame(maxWidth: .infinity)
                    ),
                    backgroundColor: Color(Colors.cardBackground),
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    backgroundImage: nil
                )
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Colors.cardBackground).opacity(0.5))
                        .blur(radius: 10)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                // Clock section with blur and shadow
                Card(
                    content: AnyView(ClockView()),
                    backgroundColor: Color(Colors.cardBackground),
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    backgroundImage: nil
                )
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Colors.cardBackground).opacity(0.5))
                        .blur(radius: 10)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                // Weather section with shadow
                WeatherView(weatherController: weatherController)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(Colors.cardBackground).opacity(0.5))
                            .blur(radius: 10)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                Spacer()
            }
            mouseTrackingOverlay
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(Colors.green), lineWidth: 4)
        )
    }

    private var mouseTrackingOverlay: some View {
        MouseTrackingViewRepresentable(
            onMouseEntered: { isMouseInside = true },
            onMouseExited: { isMouseInside = false }
        )
        .allowsHitTesting(false)
    }
}

// Custom VisualEffectView
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
