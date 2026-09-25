import { z } from "zod";
export function registerScriptTools(server, bridge) {
    server.tool("godot_get_current_script", "Get the currently open script in the Godot editor (path, source, cursor position)", {}, async () => {
        try {
            const result = await bridge.send("script.get_current");
            return {
                content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
            };
        }
        catch (e) {
            return {
                content: [{ type: "text", text: `Error: ${e.message}` }],
                isError: true,
            };
        }
    });
    server.tool("godot_get_selected_code", "Get the currently selected code in the Godot script editor", {}, async () => {
        try {
            const result = await bridge.send("script.get_selected_code");
            return {
                content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
            };
        }
        catch (e) {
            return {
                content: [{ type: "text", text: `Error: ${e.message}` }],
                isError: true,
            };
        }
    });
    server.tool("godot_insert_code", "Insert code at the current cursor position in the Godot script editor", {
        text: z.string().describe("Code text to insert at cursor position"),
    }, async ({ text }) => {
        try {
            const result = await bridge.send("script.insert_at_cursor", { text });
            return {
                content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
            };
        }
        catch (e) {
            return {
                content: [{ type: "text", text: `Error: ${e.message}` }],
                isError: true,
            };
        }
    });
    server.tool("godot_get_open_scripts", "Get list of all open scripts in the Godot editor", {}, async () => {
        try {
            const result = await bridge.send("script.get_open");
            return {
                content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
            };
        }
        catch (e) {
            return {
                content: [{ type: "text", text: `Error: ${e.message}` }],
                isError: true,
            };
        }
    });
    server.tool("godot_create_script", "Create a new GDScript file and attach it to a node", {
        node_path: z.string().describe("Path to the node to attach the script to"),
        script_path: z.string().describe("res:// path where the script will be created (e.g. res://src/player.gd)"),
        template: z.string().optional().describe("Script content (default: minimal extends template)"),
    }, async ({ node_path, script_path, template }) => {
        try {
            const result = await bridge.send("script.create_and_attach", { node_path, script_path, template });
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_detach_script", "Remove the script attached to a node", {
        node_path: z.string().describe("Path to the node to detach the script from"),
    }, async ({ node_path }) => {
        try {
            const result = await bridge.send("script.detach", { node_path });
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
    server.tool("godot_get_script_for_node", "Get the script path attached to a node", {
        node_path: z.string().describe("Node path in the scene tree"),
    }, async ({ node_path }) => {
        try {
            const result = await bridge.send("script.get_for_node", { path: node_path });
            return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        }
        catch (e) {
            return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true };
        }
    });
}
