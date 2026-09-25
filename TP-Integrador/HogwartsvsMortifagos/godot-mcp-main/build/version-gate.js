export function parseVersion(versionString) {
    // Handle formats like "4.4.1.stable", "4.3.stable", "4.4.stable.official.49a5bc7b6"
    const match = versionString.trim().match(/^(\d+)\.(\d+)(?:\.(\d+))?/);
    if (!match)
        return null;
    return {
        major: parseInt(match[1], 10),
        minor: parseInt(match[2], 10),
        patch: parseInt(match[3] ?? "0", 10),
        full: versionString.trim(),
    };
}
export function meetsMinimum(actual, required) {
    if (actual.major !== required.major)
        return actual.major > required.major;
    if (actual.minor !== required.minor)
        return actual.minor > required.minor;
    if (required.patch !== undefined)
        return actual.patch >= required.patch;
    return true;
}
