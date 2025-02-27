// TODO: This example needs some extra work to properly port to the new API as
// its a bit larger than other examples but it

const zfltk = @import("zfltk");
const app = zfltk.app;
const widget = zfltk.widget;
const Widget = widget.Widget;
const Window = zfltk.Window;
const Menu = zfltk.Menu;
const enums = zfltk.enums;
const Color = enums.Color;
const TextDisplay = zfltk.TextDisplay;
const dialog = zfltk.dialog;
const FileDialog = zfltk.FileDialog;
const std = @import("std");

// To avoid exiting when hitting escape.
// Also logic can be added to prompt the user to save their work
pub fn winCb(w: *Window) void {
    if (app.event() == .close) {
        w.hide();
    }
}

fn newCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    var editor = TextDisplay(.editor).fromRaw(data.?);
    editor.buffer().?.setText("");
}

pub fn openCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    var editor = TextDisplay(.editor).fromRaw(data.?);
    var dlg = try FileDialog(.file).init(.{});
    dlg.setFilter("*.{txt,zig}");
    dlg.show();
    var fname = dlg.filename();
    if (!std.mem.eql(u8, fname, "")) {
        editor.buffer().?.loadFile(fname) catch unreachable;
    }
}

pub fn saveCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    var editor = TextDisplay(.editor).fromRaw(data.?);
    var dlg = try FileDialog(.save_file).init(.{ .save_as_confirm = true });
    dlg.setFilter("*.{txt,zig}");
    dlg.show();
    var fname = dlg.filename();
    if (!std.mem.eql(u8, fname, "")) {
        editor.buffer().?.saveFile(fname) catch unreachable;
    }
}

pub fn quitCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    var win = widget.Widget.fromRaw(data.?);
    win.hide();
}

pub fn cutCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    const editor = TextDisplay(.editor).fromRaw(data.?);
    editor.cut();
}

pub fn copyCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    const editor = TextDisplay(.editor).fromRaw(data.?);
    _ = editor.copy();
}

pub fn pasteCb(_: *Menu(.menu_bar), data: ?*anyopaque) void {
    const editor = TextDisplay(.editor).fromRaw(data.?);
    editor.paste();
}

pub fn helpCb(_: *Menu(.menu_bar)) void {
    dialog.message(300, 200, "This editor was built using fltk and zig!");
}

pub fn main() !void {
    try app.init();
    app.setScheme(.gtk);
    app.setBackground(Color.fromRgb(211, 211, 211));

    var win = try Window.init(.{
        .w = 800,
        .h = 600,

        .label = "Editor",
    });

    win.freePosition();
    var mymenu = try Menu(.menu_bar).init(.{ .w = 800, .h = 35 });

    var editor = try TextDisplay(.editor).init(.{
        .x = 2,
        .y = 37,
        .w = 800 - 2,
        .h = 600 - 37,
    });

    editor.setLinenumberWidth(24);
    editor.showCursor(true);
    win.end();

    win.add(.{editor});
    win.resizable(editor);

    win.show();
    win.setCallback(winCb);

    mymenu.addEx(
        "&File/New...\t",
        enums.Shortcut.Ctrl | 'n',
        .normal,
        newCb,
        editor,
    );
    mymenu.addEx(
        "&File/Open...\t",
        enums.Shortcut.Ctrl | 'o',
        .normal,
        openCb,
        editor,
    );
    mymenu.addEx(
        "&File/Save...\t",
        enums.Shortcut.Ctrl | 's',
        .menu_divider,
        saveCb,
        editor,
    );
    mymenu.addEx(
        "&File/Quit...\t",
        enums.Shortcut.Ctrl | 'q',
        .normal,
        quitCb,
        win,
    );
    mymenu.addEx(
        "&Edit/Cut...\t",
        enums.Shortcut.Ctrl | 'x',
        .normal,
        cutCb,
        editor,
    );
    mymenu.addEx(
        "&Edit/Copy...\t",
        enums.Shortcut.Ctrl | 'c',
        .normal,
        copyCb,
        editor,
    );
    mymenu.addEx(
        "&Edit/Paste...\t",
        enums.Shortcut.Ctrl | 'v',
        .normal,
        pasteCb,
        editor,
    );
    mymenu.add(
        "&Help/About...\t",
        enums.Shortcut.Ctrl | 'q',
        .normal,
        helpCb,
    );

    var item = mymenu.findItem("&File/Quit...\t");
    item.setLabelColor(Color.fromName(.red));

    try app.run();
}
