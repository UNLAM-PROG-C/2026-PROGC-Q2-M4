import { readdir, readFile, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { getGodotVersion as getVersion } from "../godot-path.js";
import { parseProjectConfig, serializeProjectConfig } from "../parsers/project-parser.js";
import { expandPath } from "../project-utils.js";
export async function listProjects(directory, recursive = false, sortBy, godotVersionFilter) {
    const dir = expandPath(directory);
    const results = [];
    async function scan(currentDir, depth) {
        let entries;
        try {
            entries = await readdir(currentDir, { withFileTypes: true });
        }
        catch {
            return;
        }
        const hasProjectFile = entries.some((e) => e.isFile() && e.name === "project.godot");
        if (hasProjectFile) {
            // Parse project name from project.godot
            let name = path.basename(currentDir);
            try {
                const content = await readFile(path.join(currentDir, "project.godot"), "utf-8");
                const match = content.match(/config\/name="([^"]+)"/);
                if (match) {
                    name = match[1];
                }
            }
            catch {
                // use directory name as fallback
            }
            results.push({ path: currentDir, name });
        }
        if (recursive || depth === 0) {
            for (const entry of entries) {
                if (entry.isDirectory() &&
                    !entry.name.startsWith(".") &&
                    entry.name !== "node_modules" &&
                    entry.name !== ".godot") {
                    await scan(path.join(currentDir, entry.name), depth + 1);
                }
            }
        }
    }
    await scan(dir, 0);
    if (godotVersionFilter) {
        const filtered = [];
        for (const project of results) {
            try {
                const content = await readFile(path.join(project.path, "project.godot"), "utf-8");
                const featuresMatch = content.match(/config\/features=PackedStringArray\(([^)]+)\)/);
                if (featuresMatch) {
                    const versionMatch = featuresMatch[1].match(/"(\d+\.\d+[^"]*)"/);
                    if (versionMatch && versionMatch[1].includes(godotVersionFilter)) {
                        filtered.push(project);
                    }
                }
            }
            catch {
                // skip projects we can't read
            }
        }
        results.length = 0;
        results.push(...filtered);
    }
    if (sortBy === "name") {
        results.sort((a, b) => a.name.localeCompare(b.name));
    }
    else if (sortBy === "path") {
        results.sort((a, b) => a.path.localeCompare(b.path));
    }
    else if (sortBy === "modified") {
        const withMtime = await Promise.all(results.map(async (p) => {
            try {
                const s = await stat(path.join(p.path, "project.godot"));
                return { ...p, mtime: s.mtime.getTime() };
            }
            catch {
                return { ...p, mtime: 0 };
            }
        }));
        withMtime.sort((a, b) => b.mtime - a.mtime);
        results.length = 0;
        results.push(...withMtime.map(({ mtime: _, ...rest }) => rest));
    }
    return results;
}
const EXT_CATEGORIES = {
    ".tscn": "scenes",
    ".gd": "scripts",
    ".gdscript": "scripts",
    ".png": "images",
    ".jpg": "images",
    ".jpeg": "images",
    ".webp": "images",
    ".svg": "images",
    ".wav": "audio",
    ".mp3": "audio",
    ".ogg": "audio",
    ".ttf": "fonts",
    ".otf": "fonts",
};
async function countFiles(dir) {
    const counts = {
        scenes: 0,
        scripts: 0,
        images: 0,
        audio: 0,
        fonts: 0,
        other: 0,
    };
    async function walk(currentDir) {
        let entries;
        try {
            entries = await readdir(currentDir, { withFileTypes: true });
        }
        catch {
            return;
        }
        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
                if (!entry.name.startsWith(".") &&
                    entry.name !== "node_modules") {
                    await walk(fullPath);
                }
            }
            else if (entry.isFile()) {
                const ext = path.extname(entry.name).toLowerCase();
                const category = EXT_CATEGORIES[ext];
                if (category) {
                    counts[category]++;
                }
                else if (ext !== "" &&
                    entry.name !== "project.godot" &&
                    !entry.name.endsWith(".import") &&
                    !entry.name.endsWith(".uid")) {
                    counts.other++;
                }
            }
        }
    }
    await walk(dir);
    return counts;
}
export async function getProjectInfo(projectPath, godotPath) {
    const dir = expandPath(projectPath);
    const projectFile = path.join(dir, "project.godot");
    const content = await readFile(projectFile, "utf-8");
    let name = path.basename(dir);
    const nameMatch = content.match(/config\/name="([^"]+)"/);
    if (nameMatch) {
        name = nameMatch[1];
    }
    let engineVersion = "unknown";
    const featuresMatch = content.match(/config\/features=PackedStringArray\(([^)]+)\)/);
    if (featuresMatch) {
        const features = featuresMatch[1];
        const versionMatch = features.match(/"(\d+\.\d+[^"]*)"/);
        if (versionMatch) {
            engineVersion = versionMatch[1];
        }
    }
    let godotVersion;
    try {
        godotVersion = await getVersion(godotPath);
    }
    catch {
        godotVersion = "unknown";
    }
    const fileCounts = await countFiles(dir);
    return {
        name,
        path: dir,
        godotVersion,
        engineVersion,
        fileCounts,
    };
}
export async function getGodotVersion(godotPath) {
    return getVersion(godotPath);
}
export async function getAutoloads(projectPath) {
    const dir = expandPath(projectPath);
    const projectFile = path.join(dir, "project.godot");
    const content = await readFile(projectFile, "utf-8");
    const config = parseProjectConfig(content);
    const autoloadSection = config.rawSections["autoload"] ?? {};
    return Object.entries(autoloadSection).map(([name, value]) => {
        const enabled = value.startsWith("*");
        const scriptPath = enabled ? value.slice(1) : value;
        return { name, path: scriptPath.replace(/^"(.*)"$/, "$1"), enabled };
    });
}
export async function addAutoload(projectPath, name, scriptPath) {
    const dir = expandPath(projectPath);
    const projectFile = path.join(dir, "project.godot");
    const content = await readFile(projectFile, "utf-8");
    const config = parseProjectConfig(content);
    if (!config.rawSections["autoload"]) {
        config.rawSections["autoload"] = {};
    }
    config.rawSections["autoload"][name] = `"*${scriptPath}"`;
    const newContent = serializeProjectConfig(config.rawSections);
    await writeFile(projectFile, newContent, "utf-8");
}
