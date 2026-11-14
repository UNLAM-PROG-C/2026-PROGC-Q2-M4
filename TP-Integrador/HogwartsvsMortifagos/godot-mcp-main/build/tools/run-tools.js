import { z } from "zod";
import { resolveProjectPath } from "../project-utils.js";
function textResult(text) {
    return { content: [{ type: "text", text }] };
}
function errorResult(e) {
    return {
        content: [{ type: "text", text: `Error: ${e.message}` }],
        isError: true,
    };
}
export function registerRunTools(server, processManager, bridge, godotPath) {
    server.tool("godot_run_scene", "Run a Godot project/scene in debug mode", {
        project_path: z.string().optional().describe("Path to the Godot project directory (auto-detected if omitted)"),
        scene: z.string().optional().describe("Specific scene to run (optional)"),
    }, async ({ project_path, scene }) => {
        if (bridge.connected) {
            try {
                const result = await bridge.send("run.play", { scene: scene ?? "" });
                return textResult(JSON.stringify(result, null, 2));
            }
            catch (e) {
                return errorResult(e);
            }
        }
        try {
            const gp = await godotPath();
            await processManager.runProject(gp, resolveProjectPath(project_path), scene);
            return textResult("Project running in debug mode (spawned process)");
        }
        catch (e) {
            return errorResult(e);
        }
    });
    server.tool("godot_stop_scene", "Stop the running Godot scene/project", {}, async () => {
        if (bridge.connected) {
            try {
                const result = await bridge.send("run.stop", {});
                return textResult(JSON.stringify(result, null, 2));
            }
            catch (e) {
                return errorResult(e);
            }
        }
        try {
            const result = await processManager.stopProject();
            return textResult(JSON.stringify({
                stopped: true,
                outputLines: result.output.length,
                errorLines: result.errors.length,
                lastOutput: result.output.slice(-20),
                lastErrors: result.errors.slice(-20),
            }, null, 2));
        }
        catch (e) {
            return errorResult(e);
        }
    });
    server.tool("godot_get_output", "Get stdout/stderr from the running Godot scene", {
        since_line: z.number().optional().describe("Only return output lines after this index (for polling)"),
    }, async ({ since_line }) => {
        if (bridge.connected) {
            try {
                const result = await bridge.send("run.get_output", { since_line });
                return textResult(JSON.stringify(result, null, 2));
            }
            catch (e) {
                return errorResult(e);
            }
        }
        const result = processManager.getDebugOutput();
        const output = since_line ? result.output.slice(since_line) : result.output;
        return textResult(JSON.stringify({ output, total_lines: result.output.length }, null, 2));
    });
    server.tool("godot_is_running", "Check if a Godot scene/project is currently running", {}, async () => {
        if (bridge.connected) {
            try {
                const result = await bridge.send("run.is_running", {});
                return textResult(JSON.stringify(result, null, 2));
            }
            catch (e) {
                return errorResult(e);
            }
        }
        return textResult(JSON.stringify({ running: processManager.isRunning() }, null, 2));
    });
}
