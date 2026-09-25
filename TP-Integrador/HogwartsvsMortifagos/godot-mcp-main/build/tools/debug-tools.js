import { z } from "zod";
export function registerDebugTools(server, bridge) {
    server.tool("godot_set_breakpoint", "Set a breakpoint at a file and line in the running Godot game", {
        file: z.string().describe("File path (res:// or absolute)"),
        line: z.number().int().describe("Line number"),
    }, async ({ file, line }) => {
        try {
            const result = await bridge.send("debug.set_breakpoint", { file, line });
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_remove_breakpoint", "Remove a breakpoint at a file and line", {
        file: z.string().describe("File path (res:// or absolute)"),
        line: z.number().int().describe("Line number"),
    }, async ({ file, line }) => {
        try {
            const result = await bridge.send("debug.remove_breakpoint", { file, line });
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_list_breakpoints", "List all active breakpoints", {}, async () => {
        try {
            const result = await bridge.send("debug.list_breakpoints");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_get_stack_trace", "Get the current stack trace when paused at a breakpoint", {}, async () => {
        try {
            const result = await bridge.send("debug.get_stack_trace");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_get_locals", "Get local variables when paused at a breakpoint", {}, async () => {
        try {
            const result = await bridge.send("debug.get_locals");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_step_over", "Step over the current line (debugger must be paused)", {}, async () => {
        try {
            const result = await bridge.send("debug.step_over");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_step_into", "Step into the current function call (debugger must be paused)", {}, async () => {
        try {
            const result = await bridge.send("debug.step_into");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_step_out", "Step out of the current function (debugger must be paused)", {}, async () => {
        try {
            const result = await bridge.send("debug.step_out");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_continue", "Continue execution after a breakpoint pause", {}, async () => {
        try {
            const result = await bridge.send("debug.continue_execution");
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
}
