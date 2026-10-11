import Foundation

/// Reads how the app and its widget were signed on this phone, for the Signing section.
struct SigningInfo: Identifiable {
    let id: String          // "App" or "Widget"
    let bundleID: String
    let profileAppID: String?   // "TEAMID.bundle.id" from embedded.mobileprovision
    let profileName: String?
    let extensionPoint: String?

    /// True if the provisioning profile actually covers this bundle ID.
    var profileMatches: Bool {
        guard let appID = profileAppID else { return false }
        guard let dot = appID.firstIndex(of: ".") else { return false }
        let pattern = String(appID[appID.index(after: dot)...])
        if pattern == "*" { return true }
        if pattern.hasSuffix(".*") { return bundleID.hasPrefix(String(pattern.dropLast())) }
        return pattern == bundleID
    }

    static func load(_ label: String, at url: URL) -> SigningInfo? {
        guard let bundle = Bundle(url: url) else { return nil }

        var appID: String?
        var name: String?
        if let data = try? Data(contentsOf: url.appendingPathComponent("embedded.mobileprovision")),
           let start = data.range(of: Data("<?xml".utf8)),
           let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex),
           let plist = try? PropertyListSerialization.propertyList(
               from: data.subdata(in: start.lowerBound..<end.upperBound), format: nil) as? [String: Any] {
            name = plist["Name"] as? String
            appID = (plist["Entitlements"] as? [String: Any])?["application-identifier"] as? String
        }

        let ext = (bundle.infoDictionary?["NSExtension"] as? [String: Any])?["NSExtensionPointIdentifier"] as? String
        return SigningInfo(id: label, bundleID: bundle.bundleIdentifier ?? "(none)",
                           profileAppID: appID, profileName: name, extensionPoint: ext)
    }

    static func all() -> [SigningInfo] {
        var result: [SigningInfo] = []
        if let app = load("App", at: Bundle.main.bundleURL) { result.append(app) }
        if let plugins = Bundle.main.builtInPlugInsURL,
           let items = try? FileManager.default.contentsOfDirectory(atPath: plugins.path) {
            for item in items where item.hasSuffix(".appex") {
                if let info = load("Widget", at: plugins.appendingPathComponent(item)) { result.append(info) }
            }
        }
        return result
    }
}
