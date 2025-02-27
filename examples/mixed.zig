//! Example demonstrating how to combine the wrapped and raw C APIs

const zfltk = @import("zfltk");
const app = zfltk.app;
const Widget = zfltk.Widget;
const Window = zfltk.Window;
const Button = zfltk.Button;
const Color = zfltk.enums.Color;
const std = @import("std");
const fmt = std.fmt;
const c = zfltk.c;

fn butCb(but: *Button(.normal)) void {
    var buf: [32]u8 = undefined;

    const label = fmt.bufPrintZ(
        &buf,
        "X: {d}, Y: {d}",
        .{ c.Fl_event_x(), c.Fl_event_y() },
    ) catch unreachable;

    but.setLabel(label);
}

fn colorButCb(color_but: *Button(.normal), _: ?*anyopaque) void {
    color_but.setColor(Color.fromRgbi(
        c.Fl_show_colormap(color_but.color().toRgbi()),
    ));
}

fn timeoutButCb(_: *Button(.normal), data: ?*anyopaque) void {
    const container: *[2]usize = @ptrCast(@alignCast(data.?));
    const wait_time: f32 = @as(*f32, @ptrFromInt(container[1])).*;

    app.addTimeoutEx(wait_time, timeoutCb, data);
}

fn timeoutCb(data: ?*anyopaque) void {
    const container: *[2]usize = @ptrCast(@alignCast(data.?));

    // Re-interpret our ints as pointers to get our objects back
    var but = Button(.normal).fromRaw(@ptrFromInt(container[0]));
    const wait_time: f32 = @as(*f32, @ptrFromInt(container[1])).*;

    var buf: [32]u8 = undefined;

    const label = fmt.bufPrintZ(
        &buf,
        "{d} seconds passed!\n",
        .{wait_time},
    ) catch unreachable;

    // The same as `but.setLabel(label);`.
    // This is just for demonstration purposes
    c.Fl_Button_set_label(
        but.raw(),
        label.ptr,
    );
}

pub fn main() !void {
    try app.init();
    _ = c.Fl_set_scheme("gtk+");

    var win = try Window.init(.{
        .w = 400,
        .h = 300,
        .label = "Mixed API",
    });

    var but = try Button(.normal).init(.{
        .x = 10,
        .y = 100,
        .w = 380,
        .h = 190,
        .label = "Click to get mouse coords",
    });
    but.setLabelSize(24);
    but.setCallback(butCb);

    var color_but = try Button(.normal).init(.{
        .x = 10,
        .y = 10,
        .w = 185,
        .h = 80,
        .label = "Set my color!",
    });
    color_but.setCallbackEx(colorButCb, null);

    // Change this to whatever you want
    var wait_time: f32 = @floatCast(1);

    var buf: [32]u8 = undefined;
    const label = try fmt.bufPrintZ(
        &buf,
        "Add a {d} second\ntimeout!\n",
        .{wait_time},
    );

    var timeout_but = try Button(.normal).init(.{
        .x = 205,
        .y = 10,
        .w = 185,
        .h = 80,
        .label = label,
    });

    // Create a container to store multiple pointers as usizes
    var container: [2]usize = undefined;
    container[0] = @intFromPtr(timeout_but);
    container[1] = @intFromPtr(&wait_time);

    timeout_but.setCallbackEx(
        timeoutButCb,
        @ptrCast(&container),
    );

    win.end();
    win.show();

    try app.run();
}
