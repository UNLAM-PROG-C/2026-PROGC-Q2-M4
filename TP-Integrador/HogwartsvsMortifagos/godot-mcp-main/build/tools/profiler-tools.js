export function registerProfilerTools(server, bridge) {
    server.tool("godot_start_profiler", "Start capturing performance profiling data in the running Godot game", {}, async () => {
        try {
            const result = await bridge.send("profiler.start");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_stop_profiler", "Stop profiling and return collected performance data", {}, async () => {
        try {
            const result = await bridge.send("profiler.stop");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_get_profiler_data", "Get the currently collected profiler frames without stopping profiling", {}, async () => {
        try {
            const result = await bridge.send("profiler.get_data");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
}
